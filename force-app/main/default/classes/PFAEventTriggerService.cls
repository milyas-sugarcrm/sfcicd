public with sharing class PFAEventTriggerService {
  public static void createPFAEventBillingRecord(List<PFA_Event__c> EventList) {
    if (EventList != null && !EventList.isEmpty()) {
      // Create PFA event billing record
      List<PFA_Event_Billing__c> eventBillingRecordsToInsert = new List<PFA_Event_Billing__c>();

      for (PFA_Event__c event : EventList) {
        PFA_Event_Billing__c eventBilling = new PFA_Event_Billing__c();
        eventBilling.Name = event.Name;
        eventBilling.PFA_Event__c = event.Id;
        eventBilling.PFA_Campaign__c = event.PFA_Campaign_Id__c;
        eventBilling.Account__c = event.Account__c;

        eventBillingRecordsToInsert.add(eventBilling);
      }

      if (!eventBillingRecordsToInsert.isEmpty()) {
        insert eventBillingRecordsToInsert;
      }
    }
  }

  public static void StatusHandling(
    List<PFA_Event__c> newEvent,
    Map<Id, PFA_Event__c> oldEvent
  ) {
    PFAEventTriggerHandler.firstRun = false;

    for (PFA_Event__c eve : newEvent) {
      if (eve != null) {
        if (eve.Event_Status__c != oldEvent.get(eve.Id).Event_Status__c) {
          if (eve.Event_Status__c == '02. Canceled') {
            eve.Event_Workflow_Status__c = '01. No Brand Ambassador';
          }
        } else if (eve.Response_back_from_Popbooking__c == true) {
          eve.Event_Workflow_Status__c = '03. Scheduled';
          eve.Event_Status__c = '01. Active';
        } else {
          if (eve.Contact__c != null) {
            eve.BA_assigned_manually__c = true;
            eve.Event_Workflow_Status__c = '02. Awaiting Response';
            eve.Event_Status__c = '01. Active';
          } else {
            eve.BA_assigned_by_popbooking__c = true;
            eve.Event_Workflow_Status__c = '02. Awaiting Response';
            eve.Event_Status__c = '01. Active';
          }
        }
      }
    }
  }

  // to set the default value of expense on event
  public static void expenseHandle(
    List<PFA_Event__c> newEvent,
    Map<Id, PFA_Event__c> oldEvent
  ) {
    final String recordName = 'Tier_Expense';
    Tier_Expense__mdt expenseInfo = [
      SELECT Tier_1_Expense__c, Tier_2_Expense__c, Tier_3_Expense__c
      FROM Tier_Expense__mdt
      WHERE DeveloperName = :recordName
      LIMIT 1
    ];
    for (PFA_Event__c eve : newEvent) {
      if (eve != null) {
        // insert case
        if (oldEvent == null) {
          if (eve.Regions__c != null && eve.Total_Expense__c == null) {
            if (eve.Regions__c.contains('1')) {
              eve.Total_Expense__c = expenseInfo.Tier_1_Expense__c;
            } else if (eve.Regions__c.contains('2')) {
              eve.Total_Expense__c = expenseInfo.Tier_2_Expense__c;
            } else if (eve.Regions__c.contains('3')) {
              eve.Total_Expense__c = expenseInfo.Tier_3_Expense__c;
            }
          }
        } else if (
          eve.Regions__c != null &&
          eve.Regions__c != oldEvent.get(eve.Id).Regions__c &&
          eve.Total_Expense__c == oldEvent.get(eve.Id).Total_Expense__c
        ) {
          //update case
          if (eve.Regions__c.contains('1')) {
            eve.Total_Expense__c = expenseInfo.Tier_1_Expense__c;
          } else if (eve.Regions__c.contains('2')) {
            eve.Total_Expense__c = expenseInfo.Tier_2_Expense__c;
          } else if (eve.Regions__c.contains('3')) {
            eve.Total_Expense__c = expenseInfo.Tier_3_Expense__c;
          }
        }
      }
    }
  }
  // Check Initial Deposit and event association with PFA Campaign
  public static void handlePFAEventInsertion(
    List<PFA_Event__c> newEvent,
    Map<Id, PFA_Event__c> oldEvent
  ) {
    Map<String, String> billingStatusMap = new Map<String, String>();
    List<Id> pfaCampaignList = new List<Id>();
    for (PFA_Event__c event : newEvent) {
      pfaCampaignList.add(event.PFA_Campaign_Id__c);
    }
    List<PFA_Event_Billing__c> initialBillingsList = [
      SELECT
        Id,
        Name,
        PFA_Campaign__c,
        Invoice_Status__c,
        Is_Initial_Deposit_Billing__c
      FROM PFA_Event_Billing__c
      WHERE
        Is_Initial_Deposit_Billing__c = TRUE
        AND PFA_Campaign__c IN :pfaCampaignList
    ];

    for (PFA_Event_Billing__c eventBillingRec : initialBillingsList) {
      billingStatusMap.put(
        eventBillingRec.PFA_Campaign__c,
        eventBillingRec.Invoice_Status__c
      );
    }

    for (PFA_Event__c event : newEvent) {
      if (billingStatusMap.get(event.PFA_Campaign_Id__c) != 'Paid') {
        event.addError(
          'Cannot create Event as required Initial Payment is not Paid'
        );
      }
    }
  }
}
