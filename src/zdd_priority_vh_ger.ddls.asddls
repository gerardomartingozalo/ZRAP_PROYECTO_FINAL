@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help Priority Status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}

@VDM.viewType: #COMPOSITE
@Search.searchable: true


define view entity ZDD_PRIORITY_VH_GER 
as select from zdt_priority_ger

{
      @ObjectModel.text.element:['PriorityDescription']
  key priority_code        as PriorityCode,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text:true
      priority_description as PriorityDescription
}
