public class QBODetailsTriggerHandler {
  List<QBO_Details__c> newQBODetails;
  Map<Id, QBO_Details__c> oldQBODetails;
  public QBODetailsTriggerHandler(
    List<QBO_Details__c> newValues,
    Map<Id, QBO_Details__c> oldValues
  ) {
    newQBODetails = newValues;
    oldQBODetails = oldValues;
  }
  public void beforeDelete() {
    QBODetailsTriggerService.handleDeletionOfDetails(
      newQBODetails,
      oldQBODetails
    );
  }
}
