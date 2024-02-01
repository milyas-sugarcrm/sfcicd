public class EstimateTriggerService {
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Estimate__c> newValues,
    Map<Id, Estimate__c> oldValues
  ) {
    List<Id> relatedOpportunities = new List<Id>();
    for (Estimate__c est : newValues) {
      relatedOpportunities.add(est.Opportunity__c);
    }
    List<Opportunity> updatedOpportunity = new List<Opportunity>();
    if (relatedOpportunities != null && relatedOpportunities.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :relatedOpportunities
        ]
      );
      for (Estimate__c est : newValues) {
        Estimate__c relatedOldValue = oldValues.get(est.Id);
        if (
          relatedOldValue.Default_Tax__c != est.Default_Tax__c ||
          relatedOldValue.Terms__c != est.Terms__c ||
          relatedOldValue.Customer_PO__c != est.Customer_PO__c ||
          relatedOldValue.In_Hands_Date__c != est.In_Hands_Date__c
        ) {
          Opportunity opp = opportunitiesMap.get(est.Opportunity__c);
          opp.isOutdated__c = true;
          updatedOpportunity.add(opp);
        }
      }
      // QuickbookApiCrud.sendEmail('Estimate', String.valueof(updatedOpportunity.size()));
      if (updatedOpportunity.size() > 0)
        update updatedOpportunity;
    }
  }
  public static void populateTheEstimateFields(
    List<Estimate__c> newEst,
    Map<Id, Estimate__c> oldValues
  ) {
    for (Estimate__c est : newEst) {
      est.Default_Tax__c = 'E (0%)';
      est.Order_Date__c = system.today();
      est.Customer_PO__c = 'None';
    }
  }
  /*public static void changeTheStageOfOpportunity(List<Estimate__c> newEst,Map<Id,Estimate__c> oldValues)
{
List<Id> OpportunitiesToUpdate=new List<Id>();

for(Estimate__c est:newEst) 
{
OpportunitiesToUpdate.add(est.Opportunity__c);
}
List <Opportunity> queriedOppList=[SELECT Id, StageName 
FROM Opportunity 
WHERE Id=:OpportunitiesToUpdate];

for(Opportunity opp : queriedOppList)  
{
if(opp.StageName != 'Estimate' && opp.StageName == 'Presentation')
{
opp.StageName='Estimate';
}
}
update queriedOppList;
}*/
  public static void deleteQboRecords(Map<Id, Estimate__c> oldEstimateMap) {
    Set<Id> oppIds = new Set<Id>();
    Set<Id> estimateIds = oldEstimateMap.keySet();
    for (Id key : oldEstimateMap.keySet()) {
      oppIds.add(oldEstimateMap.get(key).Opportunity__c);
    }
    List<Qbo_Details__c> qboRecords = [
      SELECT Id, Account__c, Id_Type__c, Opportunity__c, Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        Opportunity__c = :oppIds
        AND Salesforce_Record_Id__c = :estimateIds
        AND Id_Type__c = 'Estimate'
    ];
    delete qboRecords;
  }
  public static void deleteOppLineItemsRelatedToEstimate(
    List<Estimate__c> newEst,
    Map<Id, Estimate__c> oldEst
  ) {
    Set<Id> estimateIds = oldEst.keySet();

    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id
      FROM OpportunityLineItem__c
      WHERE Estimate__c IN :estimateIds
    ];
    if (oppLineItems.size() > 0) {
      delete oppLineItems;
    }
  }
  public static void deletePDF(Map<Id, Estimate__c> oldEstimateMap) {
    List<Id> oppIds = new List<Id>();
    for (Id key : oldEstimateMap.keySet()) {
      oppIds.add(oldEstimateMap.get(key).Opportunity__c);
    }
    delete [
      SELECT id
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId IN :oppIds
        AND ContentDocument.Title LIKE '%Preview Estimate%'
    ];
  }
  public static void goBackToPresentation(Map<Id, Estimate__c> oldEstimateMap) {
    List<Id> OpportunityIds = new List<Id>();

    for (Id key : oldEstimateMap.keySet()) {
      OpportunityIds.add(oldEstimateMap.get(key).Opportunity__c);
    }
    List<Opportunity> queriedOppList = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :OpportunityIds
    ];

    for (Opportunity opp : queriedOppList) {
      if (opp.StageName == 'Estimate') {
        opp.StageName = 'Presentation';
      }
    }
    update queriedOppList;
  }
  public static void updateDesignProjectOnChangeOwner(
    List<Estimate__c> newEst,
    Map<Id, Estimate__c> oldValues
  ) {
    List<Id> estimateIds = new List<Id>();
    for (Estimate__c estimate : newEst) {
      if (estimate.OwnerId != oldValues.get(estimate.id).OwnerId) {
        estimateIds.add(estimate.id);
      }
    }
    if (estimateIds.size() > 0) {
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Estimate__c IN :estimateIds
      ];
      if (designProjects != null && designProjects.size() > 0) {
        update designProjects;
      }
    }
  }

  public static void deleteEstimateHistory(
    Map<Id, Estimate__c> oldEstimateMap
  ) {
    List<Id> estimateIds = new List<Id>();
    for (Id key : oldEstimateMap.keySet()) {
      estimateIds.add(key);
    }
    List<Estimate_History__c> estimateHistoryList = [
      SELECT id, Estimate__c
      FROM Estimate_History__c
      WHERE Estimate__c IN :estimateIds
    ];
    if (estimateHistoryList.size() > 0)
      delete estimateHistoryList;
  }
}
