public with sharing class PFAEventBillingTriggerService {
  public static void createInvoiceForEventBillingInQbo(
    Map<Id, PFA_Event_Billing__c> newEventBillingMap
  ) {
    if (newEventBillingMap != null && !newEventBillingMap.isEmpty()) {
      Map<Id, String> billingRecIdvsQBOInstance = new Map<Id, String>();

      for (Id eventBillingId : newEventBillingMap.keySet()) {
        PFA_Event_Billing__c billingRec = newEventBillingMap.get(
          eventBillingId
        );
        billingRecIdvsQBOInstance.put(
          eventBillingId,
          billingRec.Quickbooks_Instance__c
        );
      }

      QuickbookApiCrud.createPFAEventBillingInvoiceInQBO(
        newEventBillingMap.keySet(),
        billingRecIdvsQBOInstance
      );
    }
  }

  public static void deleteEventInvoiceFromQBO(
    List<PFA_Event_Billing__c> deletedEventBillingList
  ) {
    for (PFA_Event_Billing__c billingRec : deletedEventBillingList) {
      Map<Id, String> billingRecIdvsQBOInstance = new Map<Id, String>();
      Id billingRecId = billingRec.Id;
      String qboInvoiceId = billingRec.QBO_Invoice_Id__c;
      String qboInvoiceDocNumber = billingRec.QBO_Invoice_Number__c;
      billingRecIdvsQBOInstance.put(
        billingRecId,
        billingRec.Quickbooks_Instance__c
      );
      QuickbookApiCrud.deletePFAEventBillingInvoiceInQBO(
        billingRecId,
        qboInvoiceId,
        qboInvoiceDocNumber,
        billingRecIdvsQBOInstance
      );
    }
  }

  public static void updateInvoiceForEventBillingInQbo(
    List<PFA_Event_Billing__c> eventBillingNewList,
    Map<Id, PFA_Event_Billing__c> eventBillingOldMap
  ) {
    if (eventBillingNewList != null && !eventBillingNewList.isEmpty()) {
      Set<Id> eventBillingIdsSet = new Set<Id>();
      Map<Id, String> billingRecIdvsQBOInstance = new Map<Id, String>();
      for (PFA_Event_Billing__c eventBillingRec : eventBillingNewList) {
        eventBillingIdsSet.add(eventBillingRec.Id);
        billingRecIdvsQBOInstance.put(
          eventBillingRec.Id,
          eventBillingRec.Quickbooks_Instance__c
        );
      }
      if (checkFieldsChangedForSync(eventBillingNewList, eventBillingOldMap)) {
        QuickbookApiCrud.updatePFAEventBillingInvoiceInQBO(
          eventBillingIdsSet,
          billingRecIdvsQBOInstance
        );
      }
    }
  }
  public static boolean checkFieldsChangedForSync(
    List<PFA_Event_Billing__c> lstNewPfaBiling,
    Map<Id, PFA_Event_Billing__c> mapOldPfaBiling
  ) {
    if (
      lstNewPfaBiling != null &&
      mapOldPfaBiling != null &&
      mapOldPfaBiling.size() > 0
    ) {
      for (PFA_Event_Billing__c bill : lstNewPfaBiling) {
        if (bill.Updated_From_QBO_Scheduler__c == true) {
          return false;
        }
        if (
          bill.Bill_Due_Date__c !=
          mapOldPfaBiling.get(bill.Id).Bill_Due_Date__c ||
          bill.Total_Amount__c != mapOldPfaBiling.get(bill.Id).Total_Amount__c
        ) {
          return true;
        }
      }
    }
    return false;
  }
  public static void createInvoiceInQBOIfNotCreatedAlready(
    Map<Id, PFA_Event_Billing__c> newEventBillingMap
  ) {
    if (newEventBillingMap != null && !newEventBillingMap.isEmpty()) {
      Map<Id, String> billingRecIdvsQBOInstance = new Map<Id, String>();

      for (Id eventBillingId : newEventBillingMap.keySet()) {
        PFA_Event_Billing__c billingRec = newEventBillingMap.get(
          eventBillingId
        );
        billingRecIdvsQBOInstance.put(
          eventBillingId,
          billingRec.Quickbooks_Instance__c
        );
      }
      for (Id billId : newEventBillingMap.keySet()) {
        PFA_Event_Billing__c billingRec = newEventBillingMap.get(billId);
        if (billingRec.QBO_Invoice_Id__c == null) {
          QuickbookApiCrud.createPFAEventBillingInvoiceInQBO(
            newEventBillingMap.keySet(),
            billingRecIdvsQBOInstance
          );
        }
      }
    }
  }
}
