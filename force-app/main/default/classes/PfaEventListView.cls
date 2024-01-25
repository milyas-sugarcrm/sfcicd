public with sharing class PfaEventListView {
  @AuraEnabled(cacheable=false)
  public static List<PFA_Event__c> getEvents(Id campaignId, String status) {
    if (campaignId != null) {
      String query =
        'SELECT Id, Name, start_date_and_time__c, Event_End_Date__c, Contact__r.Name, Schedule_Confirmation__c, Event_Status__c, Event_Workflow_Status__c FROM PFA_Event__c WHERE PFA_Campaign_Id__c = \'' +
        campaignId +
        '\'';
      if (status != null && status != 'All Events') {
        query += ' AND Event_Status__c LIKE \'%' + status + '%\'';
      }
      return Database.query(query);
    }
    return null;
  }

  @AuraEnabled(cacheable=false)
  public static void deleteEventRecord(Id eventId) {
    try {
      if (eventId != null) {
        List<PFA_Event__c> eventsToDelete = new List<PFA_Event__c>();
        eventsToDelete = [SELECT Id FROM PFA_Event__c WHERE Id = :eventId];
        if (!eventsToDelete.isEmpty()) {
          delete eventsToDelete;
        }
      }
    } catch (Exception ex) {
      System.debug('Error in deleting pfa event Record: ' + ex.getMessage());
    }
  }

  @AuraEnabled(cacheable=false)
  public static Id getClientAccountId(Id campaignId) {
    Id clientAccountId;
    if (campaignId != null) {
      List<PFA_Campaign__c> campaignRecord = [
        SELECT Id, Name, PFA_Client__c, PFA_Opportunity__c
        FROM PFA_Campaign__c
        WHERE Id = :campaignId
        LIMIT 1
      ];
      if (campaignRecord.size() != 0) {
        clientAccountId = campaignRecord[0].PFA_Client__c;
        return clientAccountId;
      }
    }
    return null;
  }
}
