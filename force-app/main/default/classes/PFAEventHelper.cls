public with sharing class PFAEventHelper {
  public static void beforeInsert(List<PFA_Event__c> newList) {
    PFAEventTriggerService.expenseHandle(newList, null);
    //PFAEventTriggerService.handlePFAEventInsertion(newList, null);
  }

  public static void afterInsert(
    List<PFA_Event__c> newList,
    Map<Id, PFA_Event__c> oldmap
  ) {
    //PFAEventTriggerService.createPFAEventBillingRecord(newList);
  }

  public static void beforeUpdate(
    List<PFA_Event__c> newList,
    Map<Id, PFA_Event__c> oldmap
  ) {
    PFAEventTriggerService.StatusHandling(newList, oldmap);
    PFAEventTriggerService.expenseHandle(newList, oldmap);
  }
  public static void afterUpdate(
    List<PFA_Event__c> newList,
    Map<Id, PFA_Event__c> oldmap
  ) {
    system.debug('it is after update');
  }
}
