public class TriggerOnWarningService {
  public static Id changedByUser = [
    SELECT id
    FROM User
    WHERE id = :UserInfo.getUserId()
  ]
  .id;

  public static void updateHistoryAfterUpdate(
    List<WarningsOpportunityLineItem__c> newValues,
    Map<Id, WarningsOpportunityLineItem__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        relatedOpportunityLineItems.add(warning.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == warning.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        if (estimateIds.get(warning.OpportunityLineItem__c) != null) {
          if (warning.Warning__c != oldValues.get(warning.id).Warning__c) {
            Estimate_History__c estHistory = new Estimate_History__c();
            estHistory.Estimate__c = estimateIds.get(
              warning.OpportunityLineItem__c
            );
            estHistory.Related_Object_Id__c = warning.OpportunityLineItem__c;
            estHistory.Changed_field__c = 'Warning';
            estHistory.New_Value__c = warning.Warning__c;
            estHistory.Previous_Value__c = oldValues.get(warning.id).Warning__c;
            estHistory.Changed_By__c = changedByUser;
            estimateHistoryList.add(estHistory);
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
  public static void updateHistoryAfterInsert(
    List<WarningsOpportunityLineItem__c> newValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        relatedOpportunityLineItems.add(warning.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == warning.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (WarningsOpportunityLineItem__c warning : newValues) {
        if (estimateIds.get(warning.OpportunityLineItem__c) != null) {
          if (warning.Warning__c != null) {
            Estimate_History__c estHistory = new Estimate_History__c();
            estHistory.Estimate__c = estimateIds.get(
              warning.OpportunityLineItem__c
            );
            estHistory.Related_Object_Id__c = warning.OpportunityLineItem__c;
            estHistory.Changed_field__c = 'Warning';
            estHistory.New_Value__c = warning.Warning__c;
            estHistory.Previous_Value__c = null;
            estHistory.Changed_By__c = changedByUser;
            estimateHistoryList.add(estHistory);
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
  public static void updateHistoryBeforeDelete(
    Map<Id, WarningsOpportunityLineItem__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (Id key : oldValues.keySet()) {
        relatedOpportunityLineItems.add(
          oldValues.get(key).OpportunityLineItem__c
        );
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (Id key : oldValues.keySet()) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == oldValues.get(key).OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (Id key : oldValues.keySet()) {
        if (
          estimateIds.get(oldValues.get(key).OpportunityLineItem__c) != null
        ) {
          if (oldValues.get(key).Warning__c != null) {
            Estimate_History__c estHistory = new Estimate_History__c();
            estHistory.Estimate__c = estimateIds.get(
              oldValues.get(key).OpportunityLineItem__c
            );
            estHistory.Related_Object_Id__c = oldValues.get(key)
              .OpportunityLineItem__c;
            estHistory.Changed_field__c = 'Warning';
            estHistory.New_Value__c = null;
            estHistory.Previous_Value__c = oldValues.get(key).Warning__c;
            estHistory.Changed_By__c = changedByUser;
            estimateHistoryList.add(estHistory);
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
}
