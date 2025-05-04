@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Entity Incidents'
@Metadata.ignorePropagatedAnnotations: true
define root view entity Z_I_INCTP_GER
  provider contract transactional_interface
  as projection on Z_R_INCT_GER
{
  key IncUUID,
      IncidentID,
      Title,
      Description,
      Status,
      Priority,
      CreationDate,
      ChangedDate,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LastChangedAt,
      /* Associations */
      _History : redirected to composition child Z_I_INCTP_H_GER
}
