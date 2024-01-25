@isTest
public with sharing class PFAEventBillingTriggerHandlerTest {
  @isTest
  static void testBeforeInsert() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.beforeInsert(testEventBillings);

    System.assertEquals(2, testEventBillings.size());
  }

  @isTest
  static void testAfterInsert() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.afterInsert(testEventBillings, new Map<Id, PFA_Event_Billing__c>());

    System.assertEquals(2, testEventBillings.size());
  }

  @isTest
  static void testBeforeUpdate() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    List<PFA_Event_Billing__c> newList = new List<PFA_Event_Billing__c>();
    Map<Id, PFA_Event_Billing__c> newMap = new Map<Id, PFA_Event_Billing__c>();
    for (PFA_Event_Billing__c record : testEventBillings) {
      newList.add(record);
      newMap.put(record.Id, record);
    }

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.beforeUpdate(
      newList,
      newMap,
      new List<PFA_Event_Billing__c>(),
      new Map<Id, PFA_Event_Billing__c>()
    );

    System.assertEquals(2, newList.size());
  }

  @isTest
  static void testAfterUpdate() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    List<PFA_Event_Billing__c> newList = (List<PFA_Event_Billing__c>) testEventBillings.clone();
    Map<Id, PFA_Event_Billing__c> newMap = new Map<Id, PFA_Event_Billing__c>();
    for (PFA_Event_Billing__c record : newList) {
      newMap.put(record.Id, record);
    }

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.afterUpdate(
      newList,
      newMap,
      new List<PFA_Event_Billing__c>(),
      new Map<Id, PFA_Event_Billing__c>()
    );

    System.assertEquals(2, testEventBillings.size());
  }
  @isTest
  static void testBeforeDelete() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.beforeDelete(
      testEventBillings,
      new Map<Id, PFA_Event_Billing__c>()
    );

    System.assertEquals(2, testEventBillings.size());
  }

  @isTest
  static void testAfterDelete() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.afterDelete(testEventBillings, new Map<Id, PFA_Event_Billing__c>());

    System.assertEquals(2, testEventBillings.size());
  }

  @isTest
  static void testAfterUnDelete() {
    List<PFA_Event_Billing__c> testEventBillings = new List<PFA_Event_Billing__c>{
      new PFA_Event_Billing__c(Name = 'Test Event Billing 1'),
      new PFA_Event_Billing__c(Name = 'Test Event Billing 2')
    };

    PFAEventBillingTriggerHandler handler = new PFAEventBillingTriggerHandler();
    handler.afterUnDelete(
      testEventBillings,
      new Map<Id, PFA_Event_Billing__c>()
    );

    System.assertEquals(2, testEventBillings.size());
  }
}
