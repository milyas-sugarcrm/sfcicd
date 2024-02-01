public with sharing class PFAEventTriggerHandler implements ITriggerHandler {
  public static Boolean firstRun = true;
  //Use this variable to disable this trigger from transaction
  public static Boolean TriggerDisabled = false;

  //check if the trigger is disabled from transaction
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<PFA_Event__c> eventNewList = (List<PFA_Event__c>) newList;
    PFAEventHelper.beforeInsert(eventNewList);
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    List<PFA_Event__c> eventNewList = (List<PFA_Event__c>) newList;
    Map<Id, PFA_Event__c> eventNewMap = (Map<Id, PFA_Event__c>) newMap;
    PFAEventHelper.afterInsert(eventNewList, eventNewMap);
  }

  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    List<PFA_Event__c> eventNewList = (List<PFA_Event__c>) newList;
    Map<Id, PFA_Event__c> eventOldMap = (Map<Id, PFA_Event__c>) oldMap;
    if (firstRun = true) {
      PFAEventHelper.beforeUpdate(eventNewList, eventOldMap);
    }
  }

  public void afterUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, PFA_Event__c> eventOldMap = (Map<Id, PFA_Event__c>) oldMap;
    List<PFA_Event__c> eventNewList = (List<PFA_Event__c>) newList;
    PFAEventHelper.afterUpdate(eventNewList, eventOldMap);
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    system.debug('beforeDelete event trigger handler' + oldList[0]);
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    system.debug('afterDelete event trigger handler' + oldList[0]);
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
    system.debug('afterUnDelete event trigger handler' + newList[0]);
  }
}
