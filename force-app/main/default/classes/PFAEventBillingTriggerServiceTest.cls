@isTest
public with sharing class PFAEventBillingTriggerServiceTest {
  @TestSetup
  public static void makeData() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Id pfaCustomerAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('PFA Customer Account')
      .getRecordTypeId();
    // Create a new Account record
    Account newAccount = new Account(
      Name = 'Test Account',
      Industry = 'Technology',
      BillingCity = 'Test City',
      RecordTypeId = pfaCustomerAccRecordType,
      QuickBooks_Accounts__c = 'Phun for All'
    );
    insert newAccount;

    Id pfaCustomerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();
    // Create a new Opportunity record
    Opportunity newOpportunity = new Opportunity(
      Name = 'Test PFA Opportunity',
      AccountId = newAccount.Id,
      StageName = 'Needs Analysis',
      CloseDate = Date.today().addDays(30),
      Amount = 10000,
      Probability = 25,
      RecordTypeId = pfaCustomerOppRecordType
    );
    insert newOpportunity;

    PFA_Campaign__c newCampaign = new PFA_Campaign__c(
      Name = 'Test PFA Campaign',
      PFA_Client__c = newAccount.Id,
      PFA_Opportunity__c = newOpportunity.Id
    );
    insert newCampaign;

    PFA_Event_Billing__c testEventBilling = new PFA_Event_Billing__c(
      Name = 'Test Event Billing',
      PFA_Campaign__c = newCampaign.Id,
      Account__c = newAccount.Id,
      Quickbooks_Instance__c = 'Phun for All',
      QBO_Invoice_Id__c = '234',
      QBO_Invoice_Number__c = '1010',
      Total_Amount__c = 11,
      Bill_Due_Date__c = System.now().date(),
      Updated_From_QBO_Scheduler__c = false
    );
    insert testEventBilling;
  }

  @isTest
  static void testCreateInvoiceForEventBillingInQbo() {
    List<PFA_Event_Billing__c> eventBillingList = [
      SELECT
        Id,
        Name,
        PFA_Campaign__c,
        Account__c,
        Quickbooks_Instance__c,
        QBO_Invoice_Id__c,
        QBO_Invoice_Number__c,
        Total_Amount__c
      FROM PFA_Event_Billing__c
      WHERE Name = 'Test Event Billing'
      LIMIT 1
    ];
    Map<Id, PFA_Event_Billing__c> testEventBillingMap = new Map<Id, PFA_Event_Billing__c>();

    for (PFA_Event_Billing__c billingRec : eventBillingList) {
      testEventBillingMap.put(billingRec.Id, billingRec);
    }
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFAEventBillingTriggerService.createInvoiceForEventBillingInQbo(
      testEventBillingMap
    );
    Test.stopTest();
  }

  @isTest
  static void testDeleteEventInvoiceFromQBO() {
    List<PFA_Event_Billing__c> eventBillingList = [
      SELECT
        Id,
        Name,
        PFA_Campaign__c,
        Account__c,
        Quickbooks_Instance__c,
        QBO_Invoice_Id__c,
        QBO_Invoice_Number__c
      FROM PFA_Event_Billing__c
      WHERE Name = 'Test Event Billing'
      LIMIT 1
    ];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFAEventBillingTriggerService.deleteEventInvoiceFromQBO(eventBillingList);
    Test.stopTest();
  }

  @isTest
  static void testUpdateInvoiceForEventBillingInQbo() {
    List<PFA_Event_Billing__c> eventBillingList = [
      SELECT
        Id,
        Name,
        PFA_Campaign__c,
        Account__c,
        Updated_From_QBO_Scheduler__c,
        Bill_Due_Date__c,
        Quickbooks_Instance__c,
        QBO_Invoice_Id__c,
        QBO_Invoice_Number__c
      FROM PFA_Event_Billing__c
      WHERE Name = 'Test Event Billing'
      LIMIT 1
    ];
    PFA_Event_Billing__c billRec = eventBillingList[0];
    billRec.Total_Amount__c = 12;
    update billRec;

    Map<Id, PFA_Event_Billing__c> testEventBillingMap = new Map<Id, PFA_Event_Billing__c>();

    for (PFA_Event_Billing__c billingRec : eventBillingList) {
      testEventBillingMap.put(billingRec.Id, billingRec);
    }

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFAEventBillingTriggerService.updateInvoiceForEventBillingInQbo(
      eventBillingList,
      testEventBillingMap
    );
    Test.stopTest();
  }
}
