public class TriggerOnCommentService {
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Comment__c> newValues,
    Map<Id, Comment__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (Comment__c comment : newValues) {
      if (comment.OpportunityLineItem__c != null) {
        relatedOpportunityLineItems.add(comment.OpportunityLineItem__c);
      }
    }
    if (relatedOpportunityLineItems != null) {
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT
          Id,
          Estimate__r.Opportunity__c,
          Work_Order__r.OpportunityId,
          Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];

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
      if (opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
        List<Opportunity> opportunitiesList = [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :opportunitiesToUpdate
        ];
        for (Opportunity opp : opportunitiesList) {
          opp.isOutdated__c = true;
        }
        update opportunitiesList;
      }
    }
  }
}
