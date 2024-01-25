trigger TriggerOnOpportunityLineItem on OpportunityLineItem__c(
  after insert,
  after update,
  before delete,
  after delete
) {
  TriggerOnOpportunityLineItemHandler handler = new TriggerOnOpportunityLineItemHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      handler.beforeDelete();
    }
  } else if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      handler.afterUpdate();
    } else if (Trigger.isInsert) {
      handler.afterInsert();
    }
  }
}
