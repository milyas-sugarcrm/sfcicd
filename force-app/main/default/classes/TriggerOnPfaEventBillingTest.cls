@isTest
public with sharing class TriggerOnPfaEventBillingTest {
  @isTest
  static void testTriggerOnPfaEventBilling() {
    PFA_Event_Billing__c testEventBilling = new PFA_Event_Billing__c(
      Name = 'Test Event Billing'
    );
    // insert testEventBilling;

    // Map<Id, PFA_Event_Billing__c> testEventBillingMap = new Map<Id, PFA_Event_Billing__c>();
    // testEventBillingMap.put(testEventBilling.Id, testEventBilling);

    Test.startTest();
    insert testEventBilling;
    Test.StopTest();
  }
}
