*&---------------------------------------------------------------------*
*& Report  ZF_OO_LOGS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zf_oo_logs.

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
    DATA:
      o_msg_log TYPE REF TO if_reca_message_list.

    METHODS:
      constructor,
      start.

ENDCLASS.               "LCL_MAIN

*&---------------------------------------------------------------------*
*&       Class (Implementation)  LCL_MAIN
*&---------------------------------------------------------------------*
*        Text
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.


  METHOD constructor.
    " Object and subobject must be created in SLG0
    me->o_msg_log = cf_reca_message_list=>create( id_object       = 'RECA'
                                                  id_subobject    = 'MISC' ).
  ENDMETHOD.                    "CONSTRUCTOR


  METHOD start.

    " Fill T_T001 with filter societies
    SELECT * INTO TABLE @data(lt_t001)
      FROM t001
     WHERE bukrs IN @r_bukrs.

    IF sy-dbcnt = 0.
      me->o_msg_log->add(
        EXPORTING
          id_msgty = 'W'
          id_msgid = '00'            " Messages: Message Class
          id_msgno = '398'           " Messages: Message Number
          id_msgv1 = 'No hay datos'  " 1st Message Variable as Text
      ).
      RETURN.
    ENDIF.


    " Check if Business partner is filled.
    LOOP AT lt_t001 INTO DATA(ls_t001).

      IF ls_t001-rcomp IS NOT INITIAL.
        me->o_msg_log->add(
          EXPORTING
            id_msgty = 'S'
            id_msgid = '00'            " Messages: Message Class
            id_msgno = '398'           " Messages: Message Number
            id_msgv1 = ls_t001-bukrs    " 1st Message Variable as Text
            id_msgv2 = ls_t001-butxt    " 2nd Message Variable as Text
            id_msgv3 = ls_t001-rcomp    " 3rd Message Variable as Text
        ).
      ELSE.
        me->o_msg_log->add(
          EXPORTING
            id_msgty = 'E'
            id_msgid = '00'            " Messages: Message Class
            id_msgno = '398'           " Messages: Message Number
            id_msgv1 = ls_t001-bukrs    " 1st Message Variable as Text
            id_msgv2 = ls_t001-butxt    " 2nd Message Variable as Text
            id_msgv3 = |--> T001-RCOMP is empty|    " 3rd Message Variable as Text
        ).
      ENDIF.

      " Throw exception
      IF ls_t001-bukrs = 'FR90'.
        RAISE EXCEPTION TYPE cx_salv_export_error. " By example
      ENDIF.

    ENDLOOP.


  ENDMETHOD.                    "START

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

      CREATE OBJECT go_main.
      go_main->start( ).

    CATCH cx_root INTO DATA(go_cx_root).
      go_main->o_msg_log->add_from_exception( EXPORTING io_exception = go_cx_root ).
  ENDTRY.

  " Show result
  IF go_main->o_msg_log->has_messages_of_msgty( id_msgty = 'W' if_or_higher = abap_true ) = abap_true.

    " Display collected messages
    DATA: gt_log_handle TYPE bal_t_logh.
    APPEND go_main->o_msg_log->get_handle( ) TO gt_log_handle.
    CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
      EXPORTING
        i_t_log_handle = gt_log_handle.

  ELSE.
    MESSAGE 'OK' TYPE 'I'.
  ENDIF.
