CLASS lhc_Incident DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    CONSTANTS: BEGIN OF mc_status,
                 open        TYPE zde_status_i_ger VALUE 'OP',
                 in_progress TYPE zde_status_i_ger VALUE 'IP',
                 pending     TYPE zde_status_i_ger VALUE 'PE',
                 completed   TYPE zde_status_i_ger VALUE 'CO',
                 closed      TYPE zde_status_i_ger VALUE 'CL',
                 canceled    TYPE zde_status_i_ger VALUE 'CN',
               END OF mc_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Incident RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Incident RESULT result.

    METHODS changeStatus FOR MODIFY
      IMPORTING keys FOR ACTION Incident~changeStatus RESULT result.

    METHODS setHistory FOR MODIFY
      IMPORTING keys FOR ACTION Incident~setHistory.

    METHODS setDefaultValues FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Incident~setDefaultValues.

    METHODS setDefaultHistory FOR DETERMINE ON SAVE
      IMPORTING keys FOR Incident~setDefaultHistory.

    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateMandatoryFields.

    METHODS validateMandatoryDescription FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateMandatoryDescription.

    METHODS validateMandatoryPriority FOR VALIDATE ON SAVE
      IMPORTING keys FOR Incident~validateMandatoryPriority.

    METHODS get_history_index EXPORTING ev_incuuid      TYPE sysuuid_x16
                              RETURNING VALUE(rv_index) TYPE zde_his_id_ger.

ENDCLASS.

CLASS lhc_Incident IMPLEMENTATION.

  METHOD get_history_index.

** Fill history data
    SELECT FROM zdt_inct_h_ger
      FIELDS MAX( his_id ) AS max_his_id
      WHERE inc_uuid EQ @ev_incuuid AND
            his_uuid IS NOT NULL
      INTO @rv_index.
  ENDMETHOD.

  METHOD get_instance_features.


    DATA lv_history_index TYPE zde_his_id_ger.


    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
       ENTITY Incident
         FIELDS ( Status )
         WITH CORRESPONDING #( keys )
       RESULT DATA(incidents)
       FAILED failed.

** Disable changeStatus for Incidents Creation
    DATA(lv_create_action) = lines( incidents ).
    IF lv_create_action EQ 1.
      lv_history_index = get_history_index( IMPORTING ev_incuuid = incidents[ 1 ]-IncUUID ).
    ELSE.
      lv_history_index = 1.
    ENDIF.

    result = VALUE #( FOR incident IN incidents
                          ( %tky                   = incident-%tky
                            %action-ChangeStatus   = COND #( WHEN incident-Status = mc_status-completed OR
                                                                  incident-Status = mc_status-closed    OR
                                                                  incident-Status = mc_status-canceled  OR
                                                                  lv_history_index = 0
                                                             THEN if_abap_behv=>fc-o-disabled
                                                             ELSE if_abap_behv=>fc-o-enabled )

                            %assoc-_History       = COND #( WHEN incident-Status = mc_status-completed OR
                                                                 incident-Status = mc_status-closed    OR
                                                                 incident-Status = mc_status-canceled  OR
                                                                 lv_history_index = 0
                                                            THEN if_abap_behv=>fc-o-disabled
                                                            ELSE if_abap_behv=>fc-o-enabled )
                          ) ).


*solo habilitamos el boton de Change Status si es el ADMIN o responsable
    DATA(lv_technical_name) = cl_abap_context_info=>get_user_technical_name( ).


    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
       ENTITY Incident
         FIELDS ( Status Responsible )
         WITH CORRESPONDING #( keys )
       RESULT DATA(incidents1)
       FAILED failed.


    LOOP AT incidents1 INTO DATA(ls_incidents1).
      IF  requested_features-%action-ChangeStatus = if_abap_behv=>mk-on AND ls_incidents1-Responsible <> lv_technical_name AND lv_technical_name <> 'ADMIN'.

        result = VALUE #( FOR incident IN incidents1
                               ( %tky                   = incident-%tky
                                 %action-ChangeStatus   = if_abap_behv=>fc-o-disabled )
                               ).
      else.
              result = VALUE #( FOR incident IN incidents1
                               ( %tky                   = incident-%tky
                                 %action-ChangeStatus   = if_abap_behv=>fc-o-enabled )
                               ).

          exit.

      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_authorizations.

*    " Solo verificamos autorizaciones si se solicita actualizar
*    IF requested_authorizations-%update = if_abap_behv=>mk-on.
*      " Obtener el usuario actual del sistema
*      DATA(lv_current_user) = cl_abap_context_info=>get_user_technical_name( ).
*      " Verificar si es administrador
*      DATA(lv_is_admin) = xsdbool( lv_current_user = 'ADMIN' ).
*
*      " Leer datos de las incidencias para verificar el usuario asignado
*      READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
*        ENTITY Incident
*        FIELDS ( Responsible )
*        WITH CORRESPONDING #( keys )
*        RESULT DATA(incidents)
*        FAILED failed.
*
*      " Verificar autorización para cada incidencia
*      LOOP AT incidents INTO DATA(incident).
*        " ¿Es administrador o el responsable asignado a la incidencia?
*        IF lv_is_admin = abap_true OR incident-Responsible = lv_current_user.
*          APPEND VALUE #( %tky = incident-%tky
*                          %update = if_abap_behv=>auth-allowed ) TO result.
*        ELSE.
*          APPEND VALUE #( %tky = incident-%tky
*                          %update = if_abap_behv=>auth-unauthorized ) TO result.
*        ENDIF.
*      ENDLOOP.
*    ELSE.
*      " Para otras operaciones permitir acceso
*      LOOP AT keys ASSIGNING FIELD-SYMBOL(<key>).
*        APPEND VALUE #( %tky = <key>-%tky
*                        %update = if_abap_behv=>auth-allowed ) TO result.
*      ENDLOOP.
*    ENDIF.


  ENDMETHOD.

  METHOD get_global_authorizations.




  ENDMETHOD.

  METHOD changeStatus.

* Declaration of necessary variables
    DATA: lt_updated_root_entity TYPE TABLE FOR UPDATE z_r_inct_ger,
          lt_association_entity  TYPE TABLE FOR CREATE z_r_inct_ger\_History,
          lv_status              TYPE zde_status_i_ger,
          lv_text                TYPE zde_text_ger,
          lv_exception           TYPE string,
          lv_error               TYPE c,
          ls_incident_history    TYPE zdt_inct_h_ger,
          lv_max_his_id          TYPE zde_his_id_ger,
          lv_wrong_status        TYPE zde_status_i_ger.

** Iterate through the keys records to get parameters for validations
    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
         ENTITY Incident
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(incidents)
         FAILED failed.

** Get parameters
    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
** Get Status
      lv_status = keys[ KEY id %tky = <incident>-%tky ]-%param-status.

**  It is not possible to change the pending (PE) to Completed (CO) or Closed (CL) status
      IF <incident>-Status EQ mc_status-pending AND lv_status EQ mc_status-closed OR
         <incident>-Status EQ mc_status-pending AND lv_status EQ mc_status-completed.
** Set authorizations
        APPEND VALUE #( %tky = <incident>-%tky ) TO failed-incident.

        lv_wrong_status = lv_status.
* Customize error messages
        APPEND VALUE #( %tky = <incident>-%tky
                        %msg = NEW zcl_incident_messages_ger( textid = zcl_incident_messages_ger=>status_invalid
                                                            status = lv_wrong_status
                                                            severity = if_abap_behv_message=>severity-error )
                        %state_area = 'VALIDATE_COMPONENT'
                         ) TO reported-incident.
        lv_error = abap_true.
        EXIT.
      ENDIF.

      "Si el estatus es IN PROGRESS asignamos un responsable
      "Este responsable sera a partir de ese momento el unico que puede modificar el estatus o el ADMIN
      IF lv_status EQ mc_status-in_progress.
        APPEND VALUE #( %tky = <incident>-%tky
                        ChangedDate = cl_abap_context_info=>get_system_date( )
                        Status = lv_status
                        Responsible = cl_abap_context_info=>get_user_technical_name( )
                        ) TO lt_updated_root_entity.

      ELSE.
        APPEND VALUE #( %tky = <incident>-%tky
                        ChangedDate = cl_abap_context_info=>get_system_date( )
                        Status = lv_status
                        ) TO lt_updated_root_entity.
      ENDIF.

** Obtenemos el Texto del formulario
      lv_text = keys[ KEY id %tky = <incident>-%tky ]-%param-text.

*incrementamos el ID del historial
      lv_max_his_id = get_history_index(
                  IMPORTING
                    ev_incuuid = <incident>-IncUUID ).

      IF lv_max_his_id IS INITIAL.
        ls_incident_history-his_id = 1.
      ELSE.
        ls_incident_history-his_id = lv_max_his_id + 1.
      ENDIF.

      ls_incident_history-new_status = lv_status.
      ls_incident_history-text = lv_text.

*le asignamos UUID
      TRY.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lo_error).
          lv_exception = lo_error->get_text(  ).
      ENDTRY.

*Creamos la tabla para actualizar la entidad
      IF ls_incident_history-his_id IS NOT INITIAL.
*
        APPEND VALUE #( %tky = <incident>-%tky
                        %target = VALUE #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              PreviousStatus = <incident>-Status
                                              NewStatus = ls_incident_history-new_status
                                              Text = ls_incident_history-text ) )
                                               ) TO lt_association_entity.
      ENDIF.
    ENDLOOP.


    UNASSIGN <incident>.

*Si no hay error
** The process is interrupted because a change of status from pending (PE) to Completed (CO) or Closed (CL) is not permitted.
    CHECK lv_error IS INITIAL.

** Modify status in Root Entity
    MODIFY ENTITIES OF z_r_inct_ger IN LOCAL MODE
    ENTITY Incident
    UPDATE  FIELDS ( ChangedDate
                     Status
                     Responsible )
    WITH lt_updated_root_entity.

    FREE incidents. " Free entries in incidents

    MODIFY ENTITIES OF z_r_inct_ger IN LOCAL MODE
     ENTITY Incident
     CREATE BY \_History FIELDS ( HisUUID
                                  IncUUID
                                  HisID
                                  PreviousStatus
                                  NewStatus
                                  Text )
        AUTO FILL CID
        WITH lt_association_entity
     MAPPED mapped
     FAILED failed
     REPORTED reported.

** Read root entity entries updated
    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
    ENTITY Incident
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT incidents
    FAILED failed.

** Update User Interface
    result = VALUE #( FOR incident IN incidents ( %tky = incident-%tky
                                                  %param = incident ) ).



  ENDMETHOD.

  METHOD setHistory.

** Declaration of necessary variables
    DATA: lt_updated_root_entity TYPE TABLE FOR UPDATE z_r_inct_ger,
          lt_association_entity  TYPE TABLE FOR CREATE z_r_inct_ger\_History,
          lv_exception           TYPE string,
          ls_incident_history    TYPE zdt_inct_h_ger,
          lv_max_his_id          TYPE zde_his_id_ger.

** Iterate through the keys records to get parameters for validations
    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
         ENTITY Incident
         ALL FIELDS WITH CORRESPONDING #( keys )
         RESULT DATA(incidents).

** Get parameters
    LOOP AT incidents ASSIGNING FIELD-SYMBOL(<incident>).
      lv_max_his_id = get_history_index( IMPORTING ev_incuuid = <incident>-IncUUID ).

      IF lv_max_his_id IS INITIAL.
        ls_incident_history-his_id = 1.
      ELSE.
        ls_incident_history-his_id = lv_max_his_id + 1.
      ENDIF.

      TRY.
          ls_incident_history-inc_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        CATCH cx_uuid_error INTO DATA(lo_error).
          lv_exception = lo_error->get_text(  ).
      ENDTRY.

      IF ls_incident_history-his_id IS NOT INITIAL.
        APPEND VALUE #( %tky = <incident>-%tky
                        %target = VALUE #( (  HisUUID = ls_incident_history-inc_uuid
                                              IncUUID = <incident>-IncUUID
                                              HisID = ls_incident_history-his_id
                                              NewStatus = <incident>-Status
                                              Text = 'First Incident' ) )
                                               ) TO lt_association_entity.
      ENDIF.
    ENDLOOP.
    UNASSIGN <incident>.

    FREE incidents. " Free entries in incidents

    MODIFY ENTITIES OF z_r_inct_ger IN LOCAL MODE
     ENTITY Incident
     CREATE BY \_History FIELDS ( HisUUID
                                  IncUUID
                                  HisID
                                  PreviousStatus
                                  NewStatus
                                  Text )
        AUTO FILL CID
        WITH lt_association_entity.

  ENDMETHOD.

  METHOD setDefaultValues.

** Read root entity entries
    READ ENTITIES OF z_r_inct_ger  IN LOCAL MODE
     ENTITY Incident
     FIELDS ( CreationDate
              Status ) WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).

** This important for logic
    DELETE incidents WHERE CreationDate IS NOT INITIAL.

    CHECK incidents IS NOT INITIAL.

** Get Last index from Incidents
    SELECT FROM zdt_inct_ger
      FIELDS MAX( incident_id ) AS max_inct_id
      WHERE incident_id IS NOT NULL
      INTO @DATA(lv_max_inct_id).

    IF lv_max_inct_id IS INITIAL.
      lv_max_inct_id = 1.
    ELSE.
      lv_max_inct_id += 1.
    ENDIF.

** Modify status in Root Entity
    MODIFY ENTITIES OF z_r_inct_ger  IN LOCAL MODE
      ENTITY Incident
      UPDATE
      FIELDS ( IncidentID
               CreationDate
               Status )
      WITH VALUE #(  FOR incident IN incidents ( %tky = incident-%tky
                                                 IncidentID = lv_max_inct_id
                                                 CreationDate = cl_abap_context_info=>get_system_date( )
                                                 Status       = mc_status-open )  ).



  ENDMETHOD.

  METHOD setDefaultHistory.

** Execute internal action to update Flight Date
    MODIFY ENTITIES OF z_r_inct_ger IN LOCAL MODE
    ENTITY Incident
    EXECUTE setHistory
       FROM CORRESPONDING #( keys ).
  ENDMETHOD.


  METHOD validateMandatoryFields.

    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
     ENTITY Incident
     FIELDS ( Title Description Priority )
     WITH CORRESPONDING #( keys )
     RESULT DATA(incidents).
*
*
    LOOP AT incidents INTO DATA(incident).
*

      " Validar Title
      IF incident-Title IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incident-%tky
                        %msg = NEW zcl_incident_messages_ger(
                               textid   = zcl_incident_messages_ger=>mandatory_Title
                               severity = if_abap_behv_message=>severity-error
                                )
                        %element-Title = if_abap_behv=>mk-on
                        %state_area = 'VALIDATE_COMPONENT'
                      ) TO reported-incident.
      ENDIF.

    ENDLOOP.



  ENDMETHOD.

  METHOD validateMandatoryDescription.

    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
   ENTITY Incident
   FIELDS ( Title Description Priority )
   WITH CORRESPONDING #( keys )
   RESULT DATA(incidents).
*
*
    LOOP AT incidents INTO DATA(incident).
*

      " Validar Title
      IF incident-Description IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incident-%tky
                        %msg = NEW zcl_incident_messages_ger(
                               textid   = zcl_incident_messages_ger=>mandatory_Description
                               severity = if_abap_behv_message=>severity-error
                                )
                        %element-Description = if_abap_behv=>mk-on
                        %state_area = 'VALIDATE_COMPONENT'
                      ) TO reported-incident.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

  METHOD validateMandatoryPriority.

    READ ENTITIES OF z_r_inct_ger IN LOCAL MODE
 ENTITY Incident
 FIELDS ( Title Description Priority )
 WITH CORRESPONDING #( keys )
 RESULT DATA(incidents).
*
*
    LOOP AT incidents INTO DATA(incident).
*

      " Validar Title
      IF incident-Priority IS INITIAL.

        APPEND VALUE #( %tky = incident-%tky ) TO failed-incident.

        APPEND VALUE #( %tky = incident-%tky
                        %msg = NEW zcl_incident_messages_ger(
                               textid   = zcl_incident_messages_ger=>mandatory_priority
                               severity = if_abap_behv_message=>severity-error
                                )
                        %element-Priority = if_abap_behv=>mk-on
                        %state_area = 'VALIDATE_COMPONENT'
                      ) TO reported-incident.
      ENDIF.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
