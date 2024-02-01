@isTest
public class Test_ContactTriggerHandler {
  @isTest
  static void testCheckFieldsChangedForSync() {
    Contact con1 = new Contact(
      FirstName = 'John',
      LastName = 'Doe',
      Phone = '1234567890',
      MobilePhone = '9876543210',
      Lead_Record_Id__c = '0126S000001Ell5QAC'
    );
    Contact con2 = new Contact(
      FirstName = 'Jane',
      LastName = 'Smith',
      Phone = '5555555555',
      MobilePhone = '9999999999'
    );
    insert new List<Contact>{ con1, con2 };

    Map<Id, Contact> oldContactsMap = new Map<Id, Contact>();
    oldContactsMap.put(con1.Id, con1.clone());
    oldContactsMap.put(con2.Id, con2.clone());

    con1.FirstName = 'Updated';
    con2.LastName = 'Updated';
    update con1;
    Boolean result = ContactTriggerHandler.checkFieldsChangedForSync(
      new List<Contact>{ con1, con2 },
      oldContactsMap
    );
    System.assertEquals(true, result);
  }

  @isTest
  static void testUpdateFieldOnAccount() {
    // Create test data
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Phone = '1234567890',
      MobilePhone = '9876543210'
    );
    insert testContact;

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account();
    acc.Name = 'Test Aasdasccount';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Art_Approval_Email__c = 'test@gmail.com';
    acc.Website = 'https://www.google.com';
    acc.QuickBooks_Accounts__c = 'Phun for All';
    acc.Billing_Contact__c = testContact.Id;
    Test.startTest();
    insert acc;
    ContactTriggerHandler.updateFieldOnAccount(
      new List<Contact>{ testContact }
    );
    Test.stopTest();
  }
}
