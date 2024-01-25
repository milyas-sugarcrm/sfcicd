trigger TriggerOnOrder on Order(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete
) {
  OrderTriggerHandler handler = new OrderTriggerHandler(
    Trigger.new,
    Trigger.oldMap,
    Trigger.newMap
  );

  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      handler.afterInsert();
    }

    if (Trigger.isBefore) {
      handler.beforeInsert();
    }
  }

  if (Trigger.isUpdate) {
    if (Trigger.isAfter) {
      OrderTriggerHandlerForGoogleDrive.handleAfterUpdate(
        Trigger.New,
        Trigger.OldMap
      );
      handler.afterUpdate();
    }
    if (Trigger.isBefore) {
      handler.beforeUpdate();
    }
  }
  if (Trigger.isDelete) {
    if (Trigger.isBefore) {
      handler.beforeDelete();
    }
    if (Trigger.isAfter) {
      handler.afterDelete();
    }
  }
}
