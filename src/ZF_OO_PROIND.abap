*&---------------------------------------------------------------------*
*& Report  ZF_OO_PROIND
*&
*&---------------------------------------------------------------------*
*& Example of CL_PROGRESS_INDICATOR
*&
*&---------------------------------------------------------------------*

REPORT ZF_OO_PROIND.

*&---------------------------------------------------------------------*
*& SELECTION SCREENS
*&---------------------------------------------------------------------*
TABLES: T001.

SELECTION-SCREEN: BEGIN OF SCREEN 100.
SELECT-OPTIONS R_BUKRS FOR T001-BUKRS.
SELECTION-SCREEN: END OF SCREEN 100.

AT SELECTION-SCREEN ON EXIT-COMMAND.
  LEAVE PROGRAM.

*&---------------------------------------------------------------------*
*&       Class LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_MAIN DEFINITION.

  PUBLIC SECTION.
    METHODS:
      START.

  PRIVATE SECTION.
    METHODS:
      SELECTION,
      LONG_TASK.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_MAIN IMPLEMENTATION.


  METHOD START.
    ME->SELECTION( ).
    ME->LONG_TASK( ).
  ENDMETHOD.                    "START


  METHOD SELECTION.
    CALL SELECTION-SCREEN 100.
  ENDMETHOD.                    "SELECTION


  METHOD LONG_TASK.
    DATA: T_T001 TYPE TABLE OF T001,
          W_T001 TYPE T001,
          N_LINES TYPE SY-TABIX,
          N_LINE TYPE SY-TABIX.


    " Fill T_T001 with filtered Societies
    SELECT * INTO TABLE T_T001
      FROM T001
     WHERE BUKRS IN R_BUKRS.

    " Set 100% lines to be processed
    N_LINES = SY-DBCNT.

    " Loooong process
    LOOP AT T_T001 INTO W_T001.

      " Set it with current tabix, it will be processed number of societies
      N_LINE = SY-TABIX.

      " Update progress indicator
      CL_PROGRESS_INDICATOR=>PROGRESS_INDICATE(
        EXPORTING
          I_TEXT               = | Processing { W_T001-BUKRS } { W_T001-BUTXT } ( { N_LINE } / { N_LINES } )|
          I_PROCESSED          = N_LINE        " Number of Objects Already Processed
          I_TOTAL              = N_LINES       " Total Number of Objects to Be Processed
          I_OUTPUT_IMMEDIATELY = ABAP_TRUE     " X = Display Progress Immediately
      ).

      " Go to sleep
      WAIT UP TO '1' SECONDS.

    ENDLOOP.

  ENDMETHOD.                    "FILL_ALV

ENDCLASS.               "LCL_MAIN


*&---------------------------------------------------------------------*
*& MAIN
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  DATA: GO_MAIN TYPE REF TO LCL_MAIN,
        GO_CX_ROOT TYPE REF TO CX_ROOT.

  TRY.

      CREATE OBJECT GO_MAIN.
      GO_MAIN->START( ).

    CATCH CX_ROOT INTO GO_CX_ROOT.
      BREAK-POINT. " For testing purposes only
  ENDTRY.
