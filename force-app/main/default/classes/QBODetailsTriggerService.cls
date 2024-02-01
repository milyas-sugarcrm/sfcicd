public class QBODetailsTriggerService {
  public static void handleDeletionOfDetails(
    List<QBO_Details__c> newValues,
    Map<Id, QBO_Details__c> oldValues
  ) {
    system.debug(newValues);
    for (QBO_Details__c qboDetails : oldValues.Values()) {
      if (qboDetails.Id_Type__c == 'Account') {
        qboDetails.addError(
          'Qbo details record related to account cant be deleted'
        );
      }
    }
  }
}
