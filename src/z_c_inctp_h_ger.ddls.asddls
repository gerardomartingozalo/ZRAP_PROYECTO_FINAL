@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View History'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true

define view entity Z_C_INCTP_H_GER 

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
      _Incident : redirected to parent Z_C_INCTP_GER 
}
