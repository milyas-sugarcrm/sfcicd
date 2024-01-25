trigger TriggerOnDesignProject on Design_Project__c(
  before update,
  before insert,
  after update,
  before delete
) {
  DesignProjectTriggerHandler handler = new DesignProjectTriggerHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      handler.afterUpdate();
    }
  }
  if (Trigger.isBefore) {
    if (Trigger.isDelete) {
      handler.beforeDelete();
    }
    if (Trigger.isUpdate) {
      handler.beforeUpdate();
    }
  }
}
