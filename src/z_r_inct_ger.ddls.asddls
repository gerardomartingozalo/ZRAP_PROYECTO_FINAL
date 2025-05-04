@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Root Entity Incidents'
@Metadata.ignorePropagatedAnnotations: true

@Metadata.allowExtensions: true


define root view entity Z_R_INCT_GER
  as select from zdt_inct_ger
  composition [0..*] of Z_I_INCT_H_GER as _History
{
  key inc_uuid              as IncUUID,
      incident_id           as IncidentID,
      title                 as Title,
      description           as Description,
      status                as Status,
      priority              as Priority,
      creation_date         as CreationDate,
      changed_date          as ChangedDate,
      responsible           as Responsible,
      @Semantics.user.createdBy: true
      local_created_by      as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at      as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by as LocalLastChangedBy,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,

      //  Associations
      _History

}
