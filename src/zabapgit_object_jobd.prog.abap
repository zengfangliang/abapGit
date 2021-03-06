*&---------------------------------------------------------------------*
*&  Include  zabapgit_object_jobd
*&---------------------------------------------------------------------*

CLASS lcl_object_jobd DEFINITION INHERITING FROM lcl_objects_super FINAL.

  PUBLIC SECTION.
    INTERFACES zif_abapgit_object.

  PRIVATE SECTION.
    TYPES: ty_jd_name TYPE c LENGTH 32.

ENDCLASS.

CLASS lcl_object_jobd IMPLEMENTATION.

  METHOD zif_abapgit_object~has_changed_since.

    rv_changed = abap_true.

  ENDMETHOD.

  METHOD zif_abapgit_object~changed_by.

    rv_user = c_user_unknown.

  ENDMETHOD.

  METHOD zif_abapgit_object~get_metadata.

    rs_metadata = get_metadata( ).
    rs_metadata-delete_tadir = abap_true.

  ENDMETHOD.

  METHOD zif_abapgit_object~exists.

    DATA: jd_name TYPE ty_jd_name.

    jd_name = ms_item-obj_name.

    TRY.
        CALL METHOD ('CL_JR_JD_MANAGER')=>('CHECK_JD_EXISTENCE')
          EXPORTING
            im_jd_name     = jd_name
          IMPORTING
            ex_is_existing = rv_bool.

      CATCH cx_root.
        zcx_abapgit_exception=>raise( |JOBD not supported| ).
    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_object~serialize.

    DATA: lr_job_definition TYPE REF TO data,
          lo_job_definition TYPE REF TO object,
          jd_name           TYPE ty_jd_name.

    FIELD-SYMBOLS: <ls_job_definition> TYPE any,
                   <field>             TYPE any.

    jd_name = ms_item-obj_name.

    TRY.
        CREATE DATA lr_job_definition TYPE ('CL_JR_JOB_DEFINITION=>TY_JOB_DEFINITION').
        ASSIGN lr_job_definition->* TO <ls_job_definition>.
        ASSERT sy-subrc = 0.

        CREATE OBJECT lo_job_definition TYPE ('CL_JR_JOB_DEFINITION')
          EXPORTING
            im_jd_name = jd_name.

        CALL METHOD lo_job_definition->('GET_JD_ATTRIBUTES')
          IMPORTING
            ex_jd_attributes = <ls_job_definition>.

        ASSIGN COMPONENT 'JDPACKAGE' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'BTCJOB_USER' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'OWNER' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'CREATED_DATE' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'CREATED_TIME' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'CHANGED_DATE' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        ASSIGN COMPONENT 'CHANGED_TIME' OF STRUCTURE <ls_job_definition> TO <field>.
        CLEAR <field>.

        io_xml->add( iv_name = 'JOBD'
                     ig_data = <ls_job_definition> ).

      CATCH cx_root.
        zcx_abapgit_exception=>raise( |Error serializing JOBD| ).
    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_object~deserialize.

    DATA: lr_job_definition TYPE REF TO data,
          lo_job_definition TYPE REF TO object,
          jd_name           TYPE ty_jd_name.

    FIELD-SYMBOLS: <ls_job_definition> TYPE any,
                   <field>             TYPE any.

    jd_name = ms_item-obj_name.

    TRY.
        CREATE DATA lr_job_definition TYPE ('CL_JR_JOB_DEFINITION=>TY_JOB_DEFINITION').
        ASSIGN lr_job_definition->* TO <ls_job_definition>.
        ASSERT sy-subrc = 0.

        io_xml->read(
          EXPORTING
            iv_name = 'JOBD'
          CHANGING
            cg_data = <ls_job_definition> ).

        CREATE OBJECT lo_job_definition TYPE ('CL_JR_JOB_DEFINITION')
          EXPORTING
            im_jd_name = jd_name.


        ASSIGN COMPONENT 'JDPACKAGE' OF STRUCTURE <ls_job_definition> TO <field>.

        <field> = iv_package.

        CALL METHOD lo_job_definition->('CREATE_JD')
          EXPORTING
            im_jd_attributes = <ls_job_definition>.

      CATCH cx_root.
        zcx_abapgit_exception=>raise( |Error deserializing JOBD| ).
    ENDTRY.

    lcl_objects_activation=>add_item( ms_item ).

  ENDMETHOD.

  METHOD zif_abapgit_object~delete.

    DATA: lo_job_definition TYPE REF TO object,
          jd_name           TYPE c LENGTH 32.

    jd_name = ms_item-obj_name.

    TRY.
        CREATE OBJECT lo_job_definition TYPE ('CL_JR_JOB_DEFINITION')
          EXPORTING
            im_jd_name = jd_name.

        CALL METHOD lo_job_definition->('DELETE_JD').

      CATCH cx_root.
        zcx_abapgit_exception=>raise( |Error deleting JOBD| ).
    ENDTRY.

  ENDMETHOD.

  METHOD zif_abapgit_object~jump.

    DATA: obj_name TYPE e071-obj_name.

    obj_name = ms_item-obj_name.

    CALL FUNCTION 'TR_OBJECT_JUMP_TO_TOOL'
      EXPORTING
        iv_pgmid          = 'R3TR'
        iv_object         = ms_item-obj_type
        iv_obj_name       = obj_name
        iv_action         = 'SHOW'
      EXCEPTIONS
        jump_not_possible = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise( |Error from TR_OBJECT_JUMP_TO_TOOL, JOBD| ).
    ENDIF.

  ENDMETHOD.

  METHOD zif_abapgit_object~compare_to_remote_version.

    CREATE OBJECT ro_comparison_result TYPE lcl_comparison_null.

  ENDMETHOD.

ENDCLASS.
