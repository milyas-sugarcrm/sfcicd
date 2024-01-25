trigger TriggerOnExtraChargesEstimate on ExtraChargesEstimate__c(
  after update,
  before update,
  before delete,
  after delete,
  after insert
) {
  TriggerOnExtraChargeEstimateHandler handler = new TriggerOnExtraChargeEstimateHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      handler.afterInsert();
    }
    if (Trigger.isUpdate) {
      handler.afterUpdate();
    }
    if (Trigger.isDelete) {
      handler.afterDelete();
    }
  }
  if (Trigger.isBefore) {
    if (Trigger.isUpdate) {
      //handler.beforeUpdate();
    }
    if (Trigger.isDelete) {
      handler.beforeDelete();
    }
  }
}
