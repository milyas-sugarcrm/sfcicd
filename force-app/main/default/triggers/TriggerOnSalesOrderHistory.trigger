trigger TriggerOnSalesOrderHistory on Sales_Order_History__c(after insert) {
  TriggerOnSalesOrderHistoryHandler handler = new TriggerOnSalesOrderHistoryHandler(
    Trigger.new,
    Trigger.oldMap
  );
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      handler.afterInsert();
    }
  }
}
