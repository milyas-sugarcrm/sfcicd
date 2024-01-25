trigger TriggerOnWarning on WarningsOpportunityLineItem__c(
  after update,
  after insert,
  before delete
) {
  TriggerOnWarningHandler handler = new TriggerOnWarningHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      handler.afterUpdate();
    }
    if (Trigger.isInsert) {
      handler.afterInsert();
    }
  }
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      handler.beforeDelete();
    }
  }
}
