@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic Interface Incidents History'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_INCT_H_GER 

  as select from zdt_inct_h_ger
  association to parent Z_R_INCT_GER as _Incident on $projection.IncUUID = _Incident.IncUuid
{
  key his_uuid              as HisUUID,
  key inc_uuid              as IncUUID,
      his_id                as HisID,
      previous_status       as PreviousStatus,
      new_status            as NewStatus,
      text                  as Text,
      local_created_by      as LocalCreatedBy,
      local_created_at      as LocalCreatedAt,
      local_last_changed_by as LocalLastChangedBy,
      local_last_changed_at as LocalLastChangedAt,
      last_changed_at       as LastChangedAt,
      //  Associations
      _Incident
}

