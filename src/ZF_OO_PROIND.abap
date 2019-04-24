*&---------------------------------------------------------------------*
*& Report  ZF_OO_PROIND
*&
*&---------------------------------------------------------------------*
*& Example of CL_PROGRESS_INDICATOR
*&
*&---------------------------------------------------------------------*

REPORT zf_oo_proind.

*&---------------------------------------------------------------------*
*& SELECTION SCREENS
*&---------------------------------------------------------------------*
TABLES: t001.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS r_bukrs FOR t001-bukrs.
SELECTION-SCREEN END OF BLOCK b1.


*&---------------------------------------------------------------------*
*&       Class LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_main DEFINITION.

  PUBLIC SECTION.
    METHODS:
      start.

  PRIVATE SECTION.
    METHODS:
      long_task.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.


  METHOD start.
    long_task( ).
  ENDMETHOD.                    "START


  METHOD long_task.

    " Fill T_T001 with filtered Societies
    SELECT * INTO TABLE @DATA(lt_t001)
      FROM t001
     WHERE bukrs IN @r_bukrs.

    " Set 100% lines to be processed
    DATA(ln_lines) = sy-dbcnt.

    " Loooong process
    LOOP AT lt_t001 INTO DATA(ls_t001).

      " Set it with current tabix, it will be societies processed so far
      DATA(ln_line) = sy-tabix.

      " Update progress indicator
      cl_progress_indicator=>progress_indicate(
        EXPORTING
          i_text               = | Processing { ls_t001-bukrs } { ls_t001-butxt } ( { ln_line } / { ln_lines } )|
          i_processed          = ln_line        " Number of Objects Already Processed
          i_total              = ln_lines       " Total Number of Objects to Be Processed
          i_output_immediately = abap_true     " X = Display Progress Immediately
      ).

      " Go to sleep
      WAIT UP TO '1' SECONDS.

    ENDLOOP.

  ENDMETHOD.                    "FILL_ALV

ENDCLASS.               "LCL_MAIN


*&---------------------------------------------------------------------*
*& GLOBAL
*&---------------------------------------------------------------------*
DATA: go_main TYPE REF TO lcl_main.

*&---------------------------------------------------------------------*
*& INITIALIZATION
*&---------------------------------------------------------------------*
INITIALIZATION.
  CREATE OBJECT go_main.

*&---------------------------------------------------------------------*
*& MAIN
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  TRY.

      go_main->start( ).

    CATCH cx_root INTO DATA(go_cx_root).
      MESSAGE go_cx_root->get_longtext( ) TYPE 'S' DISPLAY LIKE 'E'.
      BREAK-POINT. " For testing purposes only
  ENDTRY.
