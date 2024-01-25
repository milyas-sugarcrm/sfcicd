public class TriggerOnFixedChargesService {
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<OpportunityLineItem_Add_Fixed_Charge__c> newValues,
    Map<Id, OpportunityLineItem_Add_Fixed_Charge__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : newValues) {
      relatedOpportunityLineItems.add(fixedCharge.OpportunityLineItem__c);
    }
    List<OpportunityLineItem__c> opportunityLineItem = [
      SELECT
        Id,
        Estimate__r.Opportunity__c,
        Work_Order__r.OpportunityId,
        Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Id IN :relatedOpportunityLineItems
    ];
    Map<Id, OpportunityLineItem__c> opportunityLineItemMap = new Map<Id, OpportunityLineItem__c>(
      [
        SELECT
          Id,
          Estimate__r.Opportunity__c,
          Work_Order__r.OpportunityId,
          Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ]
    );

    List<Id> opportunitiesToUpdate = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
      Id opportunityId = null;

      if (oppLineItem.Estimate__r.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Estimate__r.Opportunity__c);
      } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
        opportunitiesToUpdate.add(oppLineItem.Work_Order__r.OpportunityId);
      } else if (oppLineItem.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Opportunity__c);
      }
    }
    List<Opportunity> updatedOpportunity = new List<Opportunity>();
    if (opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :opportunitiesToUpdate
        ]
      );
      for (OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : newValues) {
        //SELECT Id, Title__c, Cost__c, Margin__c, Retail_Price__c, EstimatedQuantity__c FROM OpportunityLineItem_Add_Fixed_Charge__c
        OpportunityLineItem_Add_Fixed_Charge__c relatedOldValue = oldValues.get(
          fixedCharge.Id
        );

        if (
          relatedOldValue.Title__c != fixedCharge.Title__c ||
          relatedOldValue.Cost__c != fixedCharge.Cost__c ||
          relatedOldValue.Margin__c != fixedCharge.Margin__c ||
          relatedOldValue.Retail_Price__c != fixedCharge.Retail_Price__c ||
          relatedOldValue.EstimatedQuantity__c !=
          fixedCharge.EstimatedQuantity__c
        ) {
          OpportunityLineItem__c oppLineItem = opportunityLineItemMap.get(
            fixedCharge.OpportunityLineItem__c
          );

          if (oppLineItem.Estimate__r.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Estimate__r.Opportunity__c
            );
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Work_Order__r.OpportunityId
            );
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          } else if (oppLineItem.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(oppLineItem.Opportunity__c);
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          }
        }
      }
      update updatedOpportunity;
    }
  }
}
