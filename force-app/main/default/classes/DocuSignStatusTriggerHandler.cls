public with sharing class DocuSignStatusTriggerHandler {
  public static void convertLeadOnStatusCompleted(
    List<dfsle__EnvelopeStatus__c> newStatusList
  ) {
    //     final String COMPLETED = 'Completed';
    //     final String PHUN_FOR_ALL = 'Phun for All';
    //     final String QUALIFIED_STATUS = 'Qualified';
    //     Id pfaRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('PFA Customer Lead').getRecordTypeId();

    //     Set<Id> leadIdsToUpdate = new Set<Id>();
    //     Set<String> leadNames = new Set<String>();
    //     Set<String> leadCompanyNames = new Set<String>();
    //     Set<String> leadEmails = new Set<String>();

    //     for (dfsle__EnvelopeStatus__c statusRecord : newStatusList) {
    //         if (statusRecord.dfsle__Status__c == COMPLETED) {
    //             leadIdsToUpdate.add(statusRecord.dfsle__Lead__c);
    //         }
    //     }

    //     List<Lead> leadsToUpdate = [SELECT Id, Name, Email, Company, QuickBooks_Accounts__c, RecordTypeId FROM Lead WHERE Id IN :leadIdsToUpdate];
    //     // Collect the Lead names and emails for queries outside the loop
    //     for (Lead leadRecord : leadsToUpdate) {
    //         if (leadRecord.QuickBooks_Accounts__c == null && leadRecord.RecordTypeId == pfaRecordTypeIdLead) {
    //             leadRecord.QuickBooks_Accounts__c = PHUN_FOR_ALL;
    //         }
    //         leadNames.add(leadRecord.Name.toLowerCase());
    //         leadCompanyNames.add(leadRecord.Company.toLowerCase());
    //         leadEmails.add(leadRecord.Email.toLowerCase());
    //     }

    //     List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    //     Map<String, Id> accountNameToIdMap = new Map<String, Id>();
    //     Map<String, Id> contactKeyToIdMap = new Map<String, Id>();
    //     Map<Id, Id> contactToAccountIdMap = new Map<Id, Id>(); // New map to store Contact Id to Account Id mapping

    //     // Query Accounts based on Lead Company Name
    //     for (Account existingAccount : [SELECT Id, Name FROM Account WHERE Name IN :leadCompanyNames LIMIT 1]) {
    //         accountNameToIdMap.put(existingAccount.Name.toLowerCase(), existingAccount.Id);
    //     }

    //     // Query Contacts based on Lead Name and Email
    //     for (Contact existingContact : [SELECT Id, Name, Email, AccountId FROM Contact WHERE Name IN :leadNames AND Email IN :leadEmails LIMIT 1]) {
    //         contactKeyToIdMap.put((existingContact.Name + existingContact.Email).toLowerCase(), existingContact.Id);
    //         contactToAccountIdMap.put(existingContact.Id, existingContact.AccountId);
    //     }

    //     for (Lead leadRecord : leadsToUpdate) {
    //         // Use the collected data to set Account and Contact IDs in the LeadConvert object
    //         Database.LeadConvert lc = new Database.LeadConvert();
    //         lc.setLeadId(leadRecord.Id);
    //         lc.setConvertedStatus(QUALIFIED_STATUS);

    //         if (leadRecord.Company != null) {
    //             // Set Account ID if an Account with the same name exists
    //             String lowerCaseCompanyName = leadRecord.Company.toLowerCase();
    //             Id accountId = accountNameToIdMap.get(lowerCaseCompanyName);
    //             if (accountId != null) {
    //                 lc.setAccountId(accountId);
    //             }
    //         }

    //         if (leadRecord.Name != null && leadRecord.Email != null) {
    //             // Set Account and Contact IDs if a Contact with the same name and email exists
    //             String lowerCaseContactKey = (leadRecord.Name.toLowerCase() + leadRecord.Email.toLowerCase());
    //             Id contactId = contactKeyToIdMap.get(lowerCaseContactKey);
    //             if (contactId != null) {
    //                 lc.setContactId(contactId);
    //                 // Set the Account ID to the Account ID associated with the Contact
    //                 lc.setAccountId(contactToAccountIdMap.get(contactId));
    //             }
    //         }
    //         leadConverts.add(lc);
    //     }

    //     // Update the leads
    //     update leadsToUpdate;

    //     // Perform Lead conversion
    //     List<Database.LeadConvertResult> lcrList = Database.convertLead(leadConverts);
    //     for (Database.LeadConvertResult lcr : lcrList) {
    //         if (!lcr.isSuccess()) {
    //             System.debug('Failed Lead Conversion: ' + lcr.getErrors());
    //         }
    //     }
  }
}
