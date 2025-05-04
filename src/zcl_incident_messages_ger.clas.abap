CLASS zcl_incident_messages_ger DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_t100_dyn_msg .
    INTERFACES if_t100_message .
    INTERFACES if_abap_behv_message .

    CONSTANTS:
      gc_msgid TYPE symsgid VALUE 'ZMC_INCT_MESSAGE_GER',

      BEGIN OF status_invalid,
        msgid TYPE symsgid VALUE 'ZMC_INCT_MESSAGE_GER',
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'MV_STATUS',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF status_invalid,

      BEGIN OF mandatory_Title,
        msgid TYPE symsgid VALUE 'ZMC_INCT_MESSAGE_GER',
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_FIELD',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF mandatory_Title,

      BEGIN OF mandatory_Description,
        msgid TYPE symsgid VALUE 'ZMC_INCT_MESSAGE_GER',
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_FIELD',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF mandatory_Description,

      BEGIN OF mandatory_Priority,
        msgid TYPE symsgid VALUE 'ZMC_INCT_MESSAGE_GER',
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_FIELD',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF mandatory_Priority.

    METHODS constructor
      IMPORTING
        textid                LIKE if_t100_message=>t100key OPTIONAL
        attr1                 TYPE string OPTIONAL
        attr2                 TYPE string OPTIONAL
        attr3                 TYPE string OPTIONAL
        attr4                 TYPE string OPTIONAL
        previous              LIKE previous OPTIONAL
        travel_id             TYPE /dmo/travel_id OPTIONAL
        booking_id            TYPE /dmo/booking_id OPTIONAL
        booking_supplement_id TYPE /dmo/booking_supplement_id OPTIONAL
        agency_id             TYPE /dmo/agency_id OPTIONAL
        customer_id           TYPE /dmo/customer_id OPTIONAL
        carrier_id            TYPE /dmo/carrier-carrier_id OPTIONAL
        connection_id         TYPE /dmo/connection-connection_id OPTIONAL
        supplement_id         TYPE /dmo/supplement-supplement_id OPTIONAL
        begin_date            TYPE /dmo/begin_date OPTIONAL
        end_date              TYPE /dmo/end_date OPTIONAL
        booking_date          TYPE /dmo/booking_date OPTIONAL
        flight_date           TYPE /dmo/flight_date OPTIONAL
        status                TYPE zde_status_i_ger OPTIONAL
        currency_code         TYPE /dmo/currency_code OPTIONAL
        severity              TYPE if_abap_behv_message=>t_severity OPTIONAL
        uname                 TYPE syuname OPTIONAL
        field                 type string OPTIONAL.


    DATA:
      mv_attr1                 TYPE string,
      mv_attr2                 TYPE string,
      mv_attr3                 TYPE string,
      mv_attr4                 TYPE string,
      mv_travel_id             TYPE /dmo/travel_id,
      mv_booking_id            TYPE /dmo/booking_id,
      mv_booking_supplement_id TYPE /dmo/booking_supplement_id,
      mv_agency_id             TYPE /dmo/agency_id,
      mv_customer_id           TYPE /dmo/customer_id,
      mv_carrier_id            TYPE /dmo/carrier-carrier_id,
      mv_connection_id         TYPE /dmo/connection-connection_id,
      mv_supplement_id         TYPE /dmo/supplement-supplement_id,
      mv_begin_date            TYPE /dmo/begin_date,
      mv_end_date              TYPE /dmo/end_date,
      mv_booking_date          TYPE /dmo/booking_date,
      mv_flight_date           TYPE /dmo/flight_date,
      mv_status                TYPE zde_status_i_ger,
      mv_currency_code         TYPE /dmo/currency_code,
      mv_uname                 TYPE syuname,
      mv_field                 type string.


  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_incident_messages_ger IMPLEMENTATION.


  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(  previous = previous ) .

    me->mv_attr1                 = attr1.
    me->mv_attr2                 = attr2.
    me->mv_attr3                 = attr3.
    me->mv_attr4                 = attr4.
    me->mv_travel_id             = travel_id.
    me->mv_booking_id            = booking_id.
    me->mv_booking_supplement_id = booking_supplement_id.
    me->mv_agency_id             = agency_id.
    me->mv_customer_id           = customer_id.
    me->mv_carrier_id            = carrier_id.
    me->mv_connection_id         = connection_id.
    me->mv_supplement_id         = supplement_id.
    me->mv_begin_date            = begin_date.
    me->mv_end_date              = end_date.
    me->mv_booking_date          = booking_date.
    me->mv_flight_date           = flight_date.
    me->mv_status                = status.
    me->mv_currency_code         = currency_code.
    me->mv_uname                 = uname.
    me->mv_field                 = field.


    if_abap_behv_message~m_severity = severity.

    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
