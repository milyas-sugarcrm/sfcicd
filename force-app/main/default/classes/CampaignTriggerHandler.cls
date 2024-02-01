public with sharing class CampaignTriggerHandler implements ITriggerHandler {
  public static Boolean TriggerDisabled = false;
  public static Boolean firstRun = true;
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<PFA_Campaign__c> eventNewList = (List<PFA_Campaign__c>) newList;
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    List<PFA_Campaign__c> newListCamp = (List<PFA_Campaign__c>) newList;
    CampaignHelper.afterInsert(newListCamp);
  }

  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    List<PFA_Campaign__c> eventNewList = (List<PFA_Campaign__c>) newList;
    Map<Id, PFA_Campaign__c> eventOldMap = (Map<Id, PFA_Campaign__c>) oldMap;
  }

  public void afterUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, PFA_Campaign__c> eventOldMap = (Map<Id, PFA_Campaign__c>) oldMap;
    List<PFA_Campaign__c> eventNewList = (List<PFA_Campaign__c>) newList;
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
