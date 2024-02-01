public with sharing class ExpensesMiscellaneousTriggerHandler implements ITriggerHandler {
  public static Boolean firstRun = true;
  //Use this variable to disable this trigger from transaction
  public static Boolean TriggerDisabled = false;

  //check if the trigger is disabled from transaction
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<Expenses_Miscellaneous__c> ExpensesMiscellaneousNewList = (List<Expenses_Miscellaneous__c>) newList;
    ExpensesMiscellaneousHelper.beforeInsert(ExpensesMiscellaneousNewList);
  }

  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    List<Expenses_Miscellaneous__c> ExpensesMiscellaneousNewList = (List<Expenses_Miscellaneous__c>) newList;
    Map<Id, Expenses_Miscellaneous__c> ExpensesMiscellaneousOldMap = (Map<Id, Expenses_Miscellaneous__c>) oldMap;
    if (firstRun = true) {
      ExpensesMiscellaneousHelper.beforeUpdate(
        ExpensesMiscellaneousNewList,
        ExpensesMiscellaneousOldMap
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
