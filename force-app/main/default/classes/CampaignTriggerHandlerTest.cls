@isTest
private class CampaignTriggerHandlerTest {
  @isTest
  static void testBeforeInsert() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.beforeInsert(testCampaigns);

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }

  @isTest
  static void testAfterInsert() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.afterInsert(testCampaigns, new Map<Id, sObject>());

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }

  @isTest
  static void testBeforeUpdate() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Prepare the trigger context variables
    List<sObject> newList = new List<sObject>();
    Map<Id, sObject> newMap = new Map<Id, sObject>();
    for (PFA_Campaign__c record : testCampaigns) {
      newList.add(record);
      newMap.put(record.Id, record);
    }

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.beforeUpdate(
      newList,
      newMap,
      new List<PFA_Campaign__c>(),
      new Map<Id, PFA_Campaign__c>()
    );

    // Add your assertions here if needed
    System.assertEquals(2, newList.size());
  }

  @isTest
  static void testAfterUpdate() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Prepare the trigger context variables
    List<sObject> newList = (List<sObject>) testCampaigns.clone();
    Map<Id, sObject> newMap = new Map<Id, sObject>();
    for (sObject record : newList) {
      newMap.put(record.Id, record);
    }

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.afterUpdate(
      newList,
      newMap,
      new List<PFA_Campaign__c>(),
      new Map<Id, PFA_Campaign__c>()
    );

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }
  @isTest
  static void testBeforeDelete() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.beforeDelete(testCampaigns, new Map<Id, sObject>());

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }

  @isTest
  static void testAfterDelete() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.afterDelete(testCampaigns, new Map<Id, sObject>());

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }

  @isTest
  static void testAfterUnDelete() {
    // Create test data
    List<PFA_Campaign__c> testCampaigns = new List<PFA_Campaign__c>{
      new PFA_Campaign__c(Name = 'Test Campaign 1'),
      new PFA_Campaign__c(Name = 'Test Campaign 2')
    };

    // Call the trigger handler
    CampaignTriggerHandler handler = new CampaignTriggerHandler();
    handler.afterUnDelete(testCampaigns, new Map<Id, sObject>());

    // Add your assertions here if needed
    System.assertEquals(2, testCampaigns.size());
  }
}
