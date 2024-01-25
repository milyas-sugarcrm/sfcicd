public with sharing class PFAEventBillingTriggerHandler implements ITriggerHandler {
  //Use this variable to disable this trigger from transaction
  public static Boolean TriggerDisabled = false;

  //check if the trigger is disabled from transaction
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<PFA_Event_Billing__c> eventBillingNewList = (List<PFA_Event_Billing__c>) newList;
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    List<PFA_Event_Billing__c> eventBillingNewList = (List<PFA_Event_Billing__c>) newList;
    Map<Id, PFA_Event_Billing__c> eventBillingNewMap = (Map<Id, PFA_Event_Billing__c>) newMap;
    PFAEventBillingHelper.afterInsert(eventBillingNewList, eventBillingNewMap);
  }

  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, PFA_Event_Billing__c> eventBillingNewMap = (Map<Id, PFA_Event_Billing__c>) newMap;
    Map<Id, PFA_Event_Billing__c> eventBillingOldMap = (Map<Id, PFA_Event_Billing__c>) oldMap;
  }

  public void afterUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, PFA_Event_Billing__c> eventBillingNewMap = (Map<Id, PFA_Event_Billing__c>) newMap;
    Map<Id, PFA_Event_Billing__c> eventBillingOldMap = (Map<Id, PFA_Event_Billing__c>) oldMap;
    List<PFA_Event_Billing__c> eventBillingNewList = (List<PFA_Event_Billing__c>) newList;
    PFAEventBillingHelper.afterUpdate(
      eventBillingNewList,
      eventBillingNewMap,
      eventBillingOldMap
    );
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    List<PFA_Event_Billing__c> deletedEventBillingList = (List<PFA_Event_Billing__c>) oldList;
    Map<Id, PFA_Event_Billing__c> deletedEventBillingMap = (Map<Id, PFA_Event_Billing__c>) oldMap;
    PFAEventBillingHelper.afterDelete(
      deletedEventBillingList,
      deletedEventBillingMap
    );
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
  }
}
