public class TriggerOnRunChargesService {
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Line_Item_Pricing_RunCharge__c> newValues,
    Map<Id, Line_Item_Pricing_RunCharge__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (Line_Item_Pricing_RunCharge__c runCharges : newValues) {
      relatedOpportunityLineItems.add(runCharges.OpportunityLineItem__c);
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
      for (Line_Item_Pricing_RunCharge__c runCharges : newValues) {
        Line_Item_Pricing_RunCharge__c relatedOldValue = oldValues.get(
          runCharges.Id
        );

        if (
          relatedOldValue.Title__c != runCharges.Title__c ||
          relatedOldValue.Value1__c != runCharges.Value1__c ||
          relatedOldValue.Value2__c != runCharges.Value2__c ||
          relatedOldValue.Value3__c != runCharges.Value3__c ||
          relatedOldValue.Value4__c != runCharges.Value4__c ||
          relatedOldValue.Value5__c != runCharges.Value5__c ||
          relatedOldValue.EstimatedQuantity__c !=
          runCharges.EstimatedQuantity__c
        ) {
          OpportunityLineItem__c oppLineItem = opportunityLineItemMap.get(
            runCharges.OpportunityLineItem__c
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
