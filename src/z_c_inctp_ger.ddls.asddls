@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View Incidents'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true

define root view entity Z_C_INCTP_GER 
  provider contract transactional_query
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
      _History : redirected to composition child Z_C_INCTP_H_GER 
}
