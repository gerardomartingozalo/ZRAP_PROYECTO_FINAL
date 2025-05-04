@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Entity History'
@Metadata.ignorePropagatedAnnotations: true
define view entity Z_I_INCTP_H_GER
  
  as projection on Z_I_INCT_H_GER
{
  key HisUUID,
  key IncUUID,
      HisID,
      PreviousStatus,
      NewStatus,
      Text,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _Incident : redirected to parent Z_I_INCTP_GER
}
