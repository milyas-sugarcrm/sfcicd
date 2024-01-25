trigger TriggerOnQBODetails on QBO_Details__c(before delete) {
  if (System.Label.Triggers == 'True') {
    QBODetailsTriggerHandler triggerHandler = new QBODetailsTriggerHandler(
      Trigger.new,
      Trigger.oldMap
    );
    if (Trigger.isBefore) {
      if (Trigger.isDelete) {
        triggerHandler.beforeDelete();
      }
    }
  }

}
