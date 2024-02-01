public class TriggerOnSalesOrderHistoryService {
  public static void deleteExtraSOHistory(
    List<Sales_Order_History__c> newValues,
    Map<Id, Sales_Order_History__c> oldValues
  ) {
    List<Id> workOrderIds = new List<Id>();

    //find the total count of SOHistory records SOHistory's WorkOrder
    AggregateResult countSOHistory = [
      SELECT count(Id)
      FROM Sales_Order_History__c
      WHERE Work_Order__c = :newValues[0].Work_Order__c
    ];

    Integer countToDeleteSOHistoryRecords = Integer.valueof(
      system.label.OldSOHistoryRecordToDelete
    );
    if (Test.isRunningTest()) {
      countToDeleteSOHistoryRecords = 1;
    }

    //get WOIds for where SOHistories are more than what is mentioned in system.label.OldSOHistoryRecordToDelete
    if ((Integer) countSOHistory.get('expr0') > countToDeleteSOHistoryRecords) {
      //get SOHIstory records which are older and delete those Ids
      List<Sales_Order_History__c> SOHIdsToDelete = [
        SELECT Id
        FROM Sales_Order_History__c
        WHERE Work_Order__c = :newValues[0].Work_Order__c
        ORDER BY CreatedDate DESC
        OFFSET :countToDeleteSOHistoryRecords
      ];
      if (SOHIdsToDelete.size() > 0) {
        delete SOHIdsToDelete;
      }
    }
  }
}
