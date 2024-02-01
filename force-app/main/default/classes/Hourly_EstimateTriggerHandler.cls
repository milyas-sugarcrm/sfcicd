public with sharing class Hourly_EstimateTriggerHandler implements ITriggerHandler {
  public static Boolean firstRun = true;
  //Use this variable to disable this trigger from transaction
  public static Boolean TriggerDisabled = false;

  //check if the trigger is disabled from transaction
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<Hourly_Estimate__c> Hourly_EstimateNewList = (List<Hourly_Estimate__c>) newList;
    Hourly_EstimateHelper.beforeInsert(Hourly_EstimateNewList);
  }

  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    List<Hourly_Estimate__c> Hourly_EstimateNewList = (List<Hourly_Estimate__c>) newList;
    Map<Id, Hourly_Estimate__c> Hourly_EstimateOldMap = (Map<Id, Hourly_Estimate__c>) oldMap;
    if (firstRun = true) {
      Hourly_EstimateHelper.beforeUpdate(
        Hourly_EstimateNewList,
        Hourly_EstimateOldMap
      );
    }
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    system.debug('afterInsert event trigger handler');
  }

  public void afterUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    system.debug('afterUpdate event trigger handler');
  }

  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    system.debug('beforeDelete event trigger handler');
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
    system.debug('afterDelete event trigger handler');
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
    system.debug('afterUnDelete event trigger handler');
  }
}
