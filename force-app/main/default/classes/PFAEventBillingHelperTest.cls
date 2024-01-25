@isTest
public with sharing class PFAEventBillingHelperTest {
  @isTest
  static void testAfterInsert() {
    // Create test data
    PFA_Event_Billing__c testEventBilling = new PFA_Event_Billing__c(
      Name = 'Test'
    );
    List<PFA_Event_Billing__c> testEventBillingList = new List<PFA_Event_Billing__c>{
      testEventBilling
    };

    // Insert test data
    Test.startTest();
    insert testEventBillingList;
    Test.stopTest();

    Map<Id, PFA_Event_Billing__c> testEventBillingMap = new Map<Id, PFA_Event_Billing__c>();
    testEventBillingMap.put(testEventBilling.Id, testEventBilling);

    PFAEventBillingHelper.afterInsert(
      testEventBillingList,
      testEventBillingMap
    );
  }
}
