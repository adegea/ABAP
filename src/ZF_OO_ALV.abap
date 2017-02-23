*&---------------------------------------------------------------------*
*& Report  ZF_OO_ALV
*&
*&---------------------------------------------------------------------*
*& Template for simple CL_SALV_TABLE
*&
*&---------------------------------------------------------------------*

REPORT ZF_OO_ALV.

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
    TYPES:
      TT_ALV TYPE TABLE OF T001,
      TY_ALV TYPE LINE OF TT_ALV.

    DATA:
      T_ALV TYPE TT_ALV.

    METHODS:
      SELECTION_ALV,
      FILL_ALV,
      SHOW_ALV.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_MAIN IMPLEMENTATION.


  METHOD START.
    ME->SELECTION_ALV( ).
    ME->FILL_ALV( ).
    ME->SHOW_ALV( ).
  ENDMETHOD.                    "START


  METHOD SELECTION_ALV.
    CALL SELECTION-SCREEN 100.
  ENDMETHOD.


  METHOD FILL_ALV.
    SELECT * INTO TABLE ME->T_ALV
      FROM T001
     WHERE BUKRS IN R_BUKRS.
  ENDMETHOD.                    "FILL_ALV


  METHOD SHOW_ALV.
    DATA: O_ALV TYPE REF TO CL_SALV_TABLE.

    TRY .

        CL_SALV_TABLE=>FACTORY(
            IMPORTING
              R_SALV_TABLE = O_ALV
            CHANGING
              T_TABLE      = ME->T_ALV
          ).

        " Header
        DATA: O_HEADER  TYPE REF TO CL_SALV_FORM_LAYOUT_GRID,
              O_H_LABEL TYPE REF TO CL_SALV_FORM_LABEL,
              S_SELECCION TYPE STRING.

        CREATE OBJECT O_HEADER.
        S_SELECCION = R_BUKRS.
        O_H_LABEL = O_HEADER->CREATE_LABEL( ROW = 1 COLUMN = 1 ).
        O_H_LABEL->SET_TEXT( |Selection: { S_SELECCION }| ).
        O_ALV->SET_TOP_OF_LIST( O_HEADER ).
        O_ALV->SET_TOP_OF_LIST_PRINT( O_HEADER ).

        " Columns
        DATA O_COLUMNS TYPE REF TO CL_SALV_COLUMNS_TABLE.
        O_COLUMNS = O_ALV->GET_COLUMNS( ).
        O_COLUMNS->SET_OPTIMIZE( ).

        " Funtions
        DATA O_FUNCTIONS TYPE REF TO CL_SALV_FUNCTIONS_LIST.
        O_FUNCTIONS = O_ALV->GET_FUNCTIONS( ).
        O_FUNCTIONS->SET_ALL( ).

        O_ALV->DISPLAY( ).

      CATCH CX_SALV_MSG.
      CATCH CX_SALV_EXISTING.
      CATCH CX_SALV_DATA_ERROR.
      CATCH CX_SALV_NOT_FOUND.
    ENDTRY.
  ENDMETHOD.                    "SHOW_ALV

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
