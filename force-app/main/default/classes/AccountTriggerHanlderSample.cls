/*
 * Description: This class is for Account trigger handler
 * Author: Imran
 * Name: AccountTriggerHandler
 * Created Date: 26th July 2023
 * Version:1.0.0 - Imran - Account trigger events
 */
public with sharing class AccountTriggerHanlderSample implements ITriggerHandler {
  //Use this variable to disable this trigger from transaction
  public static Boolean TriggerDisabled = false;

  //check if the trigger is disabled from transaction
  public Boolean isDisabled() {
    return TriggerDisabled;
  }

  public void beforeInsert(List<sObject> newList) {
    List<Account> accNewList = (List<Account>) newList;
  }

  public void afterInsert(List<sObject> newList, Map<Id, sObject> newMap) {
    List<Account> accNewList = (List<Account>) newList;
    Map<Id, Account> accNewMap = (Map<Id, Account>) newMap;
    AccountTriggerHelper.afterInsert(accNewList, accNewMap);
  }
  public void beforeUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, Account> accNewMap = (Map<Id, Account>) newMap;
    Map<Id, Account> accOldMap = (Map<Id, Account>) oldMap;
  }
  public void afterUpdate(
    List<sObject> newList,
    Map<Id, sObject> newMap,
    List<sObject> oldList,
    Map<Id, sObject> oldMap
  ) {
    Map<Id, Account> accOldMap = (Map<Id, Account>) oldMap;
    List<Account> accNewList = (List<Account>) newList;
  }
  public void beforeDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterDelete(List<sObject> oldList, Map<Id, sObject> oldMap) {
  }

  public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
  }
}
