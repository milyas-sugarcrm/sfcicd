public with sharing class ContactTriggerHandler {
  public static boolean checkFieldsChangedForSync(
    List<Contact> lstNewAccount,
    Map<Id, Contact> mapOldAccount
  ) {
    if (
      lstNewAccount != null &&
      mapOldAccount != null &&
      mapOldAccount.size() > 0
    ) {
      for (Contact con : lstNewAccount) {
        if (
          con.LastName != mapOldAccount.get(con.Id).LastName ||
          con.Phone != mapOldAccount.get(con.Id).Phone ||
          con.MobilePhone != mapOldAccount.get(con.Id).MobilePhone ||
          con.FirstName != mapOldAccount.get(con.Id).FirstName
        ) {
          return true;
        }
      }
    }
    return false;
  }

  public static void updateFieldOnAccount(List<Contact> lstNewContact) {
    Id contactId = lstNewContact[0].id;
    System.debug('contactId' + contactId);
    List<Account> accountsToUpdate = [
      SELECT Id, Sync_Billing_Contact__c
      FROM Account
      WHERE Billing_Contact__c = :contactId
    ];
    for (Account acc : accountsToUpdate) {
      if (acc.Sync_Billing_Contact__c == true) {
        acc.Sync_Billing_Contact__c = false;
      } else {
        acc.Sync_Billing_Contact__c = true;
      }
    }
    update accountsToUpdate;
  }

  public static void handleRecordType(List<Contact> newContacts) {
    Id recordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Contact')
      .getRecordTypeId();
    Id pfaRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('PFA Customer Lead')
      .getRecordTypeId();
    Id recordTypeIdContactBA = Schema.SObjectType.Contact.getRecordTypeInfosByName()
      .get('Brand Ambassadors')
      .getRecordTypeId();
    Id pfaRecordTypeIdLeadBAL = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Brand Ambassador Lead')
      .getRecordTypeId();
    for (Contact contact : newContacts) {
      if (contact.Lead_Record_Id__c != null) {
        if (contact.Lead_Record_Id__c == pfaRecordTypeIdLead) {
          contact.RecordTypeId = recordTypeIdContact;
        } else if (contact.Lead_Record_Id__c == pfaRecordTypeIdLeadBAL) {
          contact.RecordTypeId = recordTypeIdContactBA;
        }
      }
    }
  }
}
