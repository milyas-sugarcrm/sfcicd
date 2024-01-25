trigger TriggerOnEstimate on Estimate__c(
  after insert,
  before delete,
  after delete,
  before insert,
  after update
) {
  if (System.Label.Triggers == 'True') {
    EstimateTriggerHandler handler = new EstimateTriggerHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        handler.afterInsert();
      } else if (Trigger.isUpdate) {
        handler.afterUpdate();
      } else if (Trigger.isDelete) {
        handler.afterDelete();
      }
    }
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        handler.beforeInsert();
      } else if (Trigger.isDelete) {
        handler.beforeDelete();
      }
    }
  }
}
