public with sharing class EstimateHistory {
  @AuraEnabled
  public static List<Estimate_History__c> getHistory(String recId) {
    List<Estimate_History__c> estimateHistoryList = [
      SELECT
        id,
        Name,
        CreatedDate,
        Estimate__c,
        Changed_field__c,
        New_Value__c,
        Changed_By__r.FirstName,
        Changed_By__r.LastName,
        Previous_Value__c,
        Related_Object_Id__c
      FROM Estimate_History__c
      WHERE Estimate__c = :recId
      ORDER BY CreatedDate DESC
    ];
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (Estimate_History__c rec : estimateHistoryList) {
      relatedOpportunityLineItems.add(rec.Related_Object_Id__c);
    }
    List<OpportunityLineItem__c> opportunityLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Id IN :relatedOpportunityLineItems
    ];
    for (Estimate_History__c rec : estimateHistoryList) {
      for (OpportunityLineItem__c lineItem : opportunityLineItems) {
        if (rec.Related_Object_Id__c == lineItem.id)
          rec.Name = lineItem.Name;
      }
    }

    if (estimateHistoryList != null && estimateHistoryList.size() > 0)
      return estimateHistoryList;
    else
      return null;
  }
}
