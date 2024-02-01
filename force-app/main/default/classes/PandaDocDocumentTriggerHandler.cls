public with sharing class PandaDocDocumentTriggerHandler {
  public static void updateSLADocumentField(
    List<pandadoc__PandaDocDocument__c> newStatusList
  ) {
    final String COMPLETED = 'document.completed';
    Id pfaRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('PFA Customer Lead')
      .getRecordTypeId();
    Set<Id> leadIdsToUpdate = new Set<Id>();

    for (pandadoc__PandaDocDocument__c statusRecord : newStatusList) {
      if (statusRecord.pandadoc__Status__c == COMPLETED) {
        leadIdsToUpdate.add(statusRecord.pandadoc__Lead__c);
      }
    }

    List<Lead> leadsToUpdate = [
      SELECT Id, Name, Email, Company, QuickBooks_Accounts__c, RecordTypeId
      FROM Lead
      WHERE Id IN :leadIdsToUpdate
    ];
    // Collect the Lead names and emails for queries outside the loop
    for (Lead leadRecord : leadsToUpdate) {
      if (leadRecord.RecordTypeId == pfaRecordTypeIdLead) {
        leadRecord.IsSLADocumentCompleted__c = true;
      }
    }
    update leadsToUpdate;
  }
}
