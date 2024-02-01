public class TriggerOnSalesOrderHistoryHandler {
  List<Sales_Order_History__c> newSOHistory;
  Map<Id, Sales_Order_History__c> oldSOHistory;
  static Boolean firstRun = true;
  static Boolean firstRunForUpdate = true;
  public TriggerOnSalesOrderHistoryHandler(
    List<Sales_Order_History__c> newValues,
    Map<Id, Sales_Order_History__c> oldValues
  ) {
    this.newSOHistory = newValues;
    this.oldSOHistory = oldValues;
  }
  public void afterInsert() {
    TriggerOnSalesOrderHistoryService.deleteExtraSOHistory(
      newSOHistory,
      oldSOHistory
    );
  }
}
