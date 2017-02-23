*&---------------------------------------------------------------------*
*& Report  ZF_OO_LOGS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZF_OO_LOGS.

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
    DATA:
      O_MSG_LOG TYPE REF TO IF_RECA_MESSAGE_LIST.

    METHODS:
      CONSTRUCTOR,
      START.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS LCL_MAIN IMPLEMENTATION.


  METHOD CONSTRUCTOR.
    " Object and subobject must be created in SLG0
    ME->O_MSG_LOG = CF_RECA_MESSAGE_LIST=>CREATE( ID_OBJECT       = 'RECA'
                                                  ID_SUBOBJECT    = 'MISC' ).
  ENDMETHOD.                    "CONSTRUCTOR


  METHOD START.
    DATA: T_T001 TYPE TABLE OF T001,
          W_T001 TYPE T001.

    " Data selection
    CALL SELECTION-SCREEN 100.

    " Fill T_T001 with filter societies
    SELECT * INTO TABLE T_T001
      FROM T001
     WHERE BUKRS IN R_BUKRS.

    IF SY-DBCNT = 0.
      ME->O_MSG_LOG->ADD(
        EXPORTING
          ID_MSGTY = 'W'
          ID_MSGID = '00'            " Messages: Message Class
          ID_MSGNO = '398'           " Messages: Message Number
          ID_MSGV1 = 'No hay datos'  " 1st Message Variable as Text
      ).
      RETURN.
    ENDIF.


    " Check if Business partner is filled.
    LOOP AT T_T001 INTO W_T001.

      IF W_T001-RCOMP IS NOT INITIAL.
        ME->O_MSG_LOG->ADD(
          EXPORTING
            ID_MSGTY = 'S'
            ID_MSGID = '00'            " Messages: Message Class
            ID_MSGNO = '398'           " Messages: Message Number
            ID_MSGV1 = W_T001-BUKRS    " 1st Message Variable as Text
            ID_MSGV2 = W_T001-BUTXT    " 2nd Message Variable as Text
            ID_MSGV3 = W_T001-RCOMP    " 3rd Message Variable as Text
        ).
      ELSE.
        ME->O_MSG_LOG->ADD(
          EXPORTING
            ID_MSGTY = 'E'
            ID_MSGID = '00'            " Messages: Message Class
            ID_MSGNO = '398'           " Messages: Message Number
            ID_MSGV1 = W_T001-BUKRS    " 1st Message Variable as Text
            ID_MSGV2 = W_T001-BUTXT    " 2nd Message Variable as Text
            ID_MSGV3 = |--> T001-RCOMP is empty|    " 3rd Message Variable as Text
        ).
      ENDIF.

      " Throw exception
      IF W_T001-BUKRS = 'FR90'.
        RAISE EXCEPTION TYPE CX_SALV_EXPORT_ERROR. " By example
      ENDIF.

    ENDLOOP.


  ENDMETHOD.                    "START

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
      GO_MAIN->O_MSG_LOG->ADD_FROM_EXCEPTION( EXPORTING IO_EXCEPTION = GO_CX_ROOT ).
  ENDTRY.

  " Show result
  IF GO_MAIN->O_MSG_LOG->HAS_MESSAGES_OF_MSGTY( ID_MSGTY = 'W' IF_OR_HIGHER = ABAP_TRUE ) = ABAP_TRUE.

    " Display collected messages
    DATA: T_LOG_HANDLE TYPE BAL_T_LOGH.
    APPEND GO_MAIN->O_MSG_LOG->GET_HANDLE( ) TO T_LOG_HANDLE.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        I_T_LOG_HANDLE = T_LOG_HANDLE.

  ELSE.
    MESSAGE 'OK' TYPE 'I'.
  ENDIF.
