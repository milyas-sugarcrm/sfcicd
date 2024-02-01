public class TriggerOnOppLineItemAttachmentService {
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<OpportunityLineItemAttachment__c> newValues,
    Map<Id, OpportunityLineItemAttachment__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (OpportunityLineItemAttachment__c attachment : newValues) {
      relatedOpportunityLineItems.add(attachment.OpportunityLineItem__c);
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

      if (oppLineItem.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Opportunity__c);
      } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Estimate__r.Opportunity__c);
      } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
        opportunitiesToUpdate.add(oppLineItem.Work_Order__r.OpportunityId);
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
      for (OpportunityLineItemAttachment__c attachment : newValues) {
        OpportunityLineItem__c oppLineItem = opportunityLineItemMap.get(
          attachment.OpportunityLineItem__c
        );
        if (oppLineItem.Opportunity__c != null) {
          Opportunity opp = opportunitiesMap.get(oppLineItem.Opportunity__c);
          opp.isOutdated__c = true;
          updatedOpportunity.add(opp);
        } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
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
        }
      }
      update updatedOpportunity;
    }
  }
}
