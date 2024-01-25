trigger triggerOnProduct2 on Product2(before delete) {
  if (System.Label.Triggers == 'True') {
    ProductTriggerHandler handler = new ProductTriggerHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isBefore) {
      if (Trigger.isDelete) {
        handler.beforeDelete();
      }
    }
  }
}
