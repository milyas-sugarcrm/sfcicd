public with sharing class PFAEventBillingHelper {
  public static void afterInsert(
    List<PFA_Event_Billing__c> newList,
    Map<Id, PFA_Event_Billing__c> newMap
  ) {
    PFAEventBillingTriggerService.createInvoiceForEventBillingInQbo(newMap);
  }
  public static void afterDelete(
    List<PFA_Event_Billing__c> deletedEventBillingList,
    Map<Id, PFA_Event_Billing__c> deletedEventBillingMap
  ) {
    PFAEventBillingTriggerService.deleteEventInvoiceFromQBO(
      deletedEventBillingList
    );
  }
  public static void afterUpdate(
    List<PFA_Event_Billing__c> eventBillingNewList,
    Map<Id, PFA_Event_Billing__c> eventBillingNewMap,
    Map<Id, PFA_Event_Billing__c> eventBillingOldMap
  ) {
    PFAEventBillingTriggerService.updateInvoiceForEventBillingInQbo(
      eventBillingNewList,
      eventBillingOldMap
    );
    PFAEventBillingTriggerService.createInvoiceInQBOIfNotCreatedAlready(
      eventBillingNewMap
    );
  }
}
