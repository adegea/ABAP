*&---------------------------------------------------------------------*
*& Report  ZF_OO_ALV
*&
*&---------------------------------------------------------------------*
*& Template for simple CL_SALV_TABLE
*&
*&---------------------------------------------------------------------*

REPORT zf_oo_alv.

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
    TYPES:
      tt_alv TYPE TABLE OF t001,
      ty_alv TYPE LINE OF tt_alv.

    DATA:
      t_alv TYPE tt_alv.

    METHODS:
      fill_alv,
      show_alv.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.


  METHOD start.
    fill_alv( ).
    show_alv( ).
  ENDMETHOD.                    "START


  METHOD fill_alv.
    SELECT * INTO TABLE t_alv
      FROM t001
     WHERE bukrs IN r_bukrs.
  ENDMETHOD.                    "FILL_ALV


  METHOD show_alv.
    DATA: lo_alv TYPE REF TO cl_salv_table.

    TRY .

        cl_salv_table=>factory(
            IMPORTING
              r_salv_table = lo_alv
            CHANGING
              t_table      = t_alv
          ).

        " Header
        DATA: lo_header    TYPE REF TO cl_salv_form_layout_grid,
              lo_h_label   TYPE REF TO cl_salv_form_label,
              lv_seleccion TYPE string.

        CREATE OBJECT lo_header.
        lv_seleccion = r_bukrs.
        lo_h_label = lo_header->create_label( row = 1 column = 1 ).
        lo_h_label->set_text( |Selection: { lv_seleccion }| ).
        lo_alv->set_top_of_list( lo_header ).
        lo_alv->set_top_of_list_print( lo_header ).

        " Columns
        DATA lo_columns TYPE REF TO cl_salv_columns_table.
        lo_columns = lo_alv->get_columns( ).
        lo_columns->set_optimize( ).

        " Funtions
        DATA lo_functions TYPE REF TO cl_salv_functions_list.
        lo_functions = lo_alv->get_functions( ).
        lo_functions->set_all( ).

        lo_alv->display( ).


      CATCH cx_salv_msg cx_salv_existing cx_salv_data_error cx_salv_not_found INTO DATA(lcx_salv).
        MESSAGE lcx_salv->get_longtext( ) TYPE 'S' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.                    "SHOW_ALV

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
