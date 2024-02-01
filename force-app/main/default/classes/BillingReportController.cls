public with sharing class BillingReportController {
  @AuraEnabled(cacheable=true)
  public static List<PFA_Event__c> getEventBillingRecords(String filterString) {
    if (filterString != '') {
      String queryString =
        'SELECT Id, Total_Cost__c, Name, Event_Status__c, Account__r.Name, Contact__r.Name, PFA_Campaign_Id__r.Name, Event_End_Date__c, Generate_Invoice__c FROM PFA_Event__c Where Event_Status__c != \'02. Canceled\' AND Generate_Invoice__c = true AND Event_Billing_record_created__c = false ' +
        filterString;
      return Database.query(queryString);
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static Id createRecords(
    List<String> recordIds,
    Date eventStartDate,
    Date eventEndDate
  ) {
    Id eventBillingReportId = null;
    List<PFA_Event__c> events = [
      SELECT
        Id,
        Name,
        PFA_Campaign_Id__c,
        Account__c,
        Event_Billing_record_created__c,
        Total_Cost__c
      FROM PFA_Event__c
      WHERE Id IN :recordIds
    ];

    if (!events.isEmpty()) {
      eventBillingReportId = createPFAEventBillingRecord(
        events,
        eventStartDate,
        eventEndDate
      );
    }
    return eventBillingReportId;
  }

  public static Id createPFAEventBillingRecord(
    List<PFA_Event__c> events,
    Date eventStartDate,
    Date eventEndDate
  ) {
    List<PFA_Event_Billing__c> eventBillingRecordsToInsert = new List<PFA_Event_Billing__c>();
    List<PFA_Event__c> eventsToUpdate = new List<PFA_Event__c>();

    Date startDate = eventStartDate;
    Date endDate = eventEndDate;

    Datetime eventStartDateTime = Datetime.newInstance(
      startDate.year(),
      startDate.month(),
      startDate.day()
    );
    startDate = eventStartDateTime.date();

    Datetime eventEndDateTime = Datetime.newInstance(
      endDate.year(),
      endDate.month(),
      endDate.day()
    );
    endDate = eventEndDateTime.date();

    PFA_Event_Billing_Report__c eventBillingReport = new PFA_Event_Billing_Report__c();
    eventBillingReport.Name =
      String.valueOf(startDate) +
      ' - ' +
      String.valueOf(endDate);

    insert eventBillingReport;

    for (PFA_Event__c event : events) {
      PFA_Event_Billing__c eventBilling = new PFA_Event_Billing__c(
        Name = event.Name,
        PFA_Event__c = event.Id,
        PFA_Campaign__c = event.PFA_Campaign_Id__c,
        Account__c = event.Account__c,
        PFA_Event_Billing_Report__c = eventBillingReport.Id,
        Total_Amount__c = event.Total_Cost__c,
        Balance_Due__c = event.Total_Cost__c
      );

      event.Event_Billing_record_created__c = true;
      eventBillingRecordsToInsert.add(eventBilling);
      eventsToUpdate.add(event);
    }

    if (!eventBillingRecordsToInsert.isEmpty()) {
      insert eventBillingRecordsToInsert;
    }

    if (!eventsToUpdate.isEmpty()) {
      PFAEventTriggerHandler.TriggerDisabled = true;
      update eventsToUpdate;
      PFAEventTriggerHandler.TriggerDisabled = false;
    }

    return eventBillingReport.Id;
  }
}
