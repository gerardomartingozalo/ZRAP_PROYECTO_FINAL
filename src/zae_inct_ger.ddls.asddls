@EndUserText.label: 'Abstract Entity Incidents'
define abstract entity ZAE_INCT_GER

{
    @EndUserText.label: 'New Status'
    @Consumption.valueHelpDefinition: [{ entity: { name :'ZDD_STATUS_VH_GER',
                                        element: 'text' },
                               useForValidation: true  } ]
    status_code    : zde_status_i_ger;
    @EndUserText.label: 'Observation'
    observation    : abap.char(80);
}
