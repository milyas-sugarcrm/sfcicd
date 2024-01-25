public class PurchaseOrderTriggerService {
  public static void changeTheStageOfOpportunity(
    List<PurchaseOrder__c> newOrders
  ) {
    List<Id> OpportunitiesToUpdate = new List<Id>();

    for (PurchaseOrder__c order : newOrders) {
      OpportunitiesToUpdate.add(order.Opportunity__c);
    }
    List<Opportunity> queriedOppList = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :OpportunitiesToUpdate
    ];

    for (Opportunity opp : queriedOppList) {
      if (opp.StageName != 'Closed Won' && opp.StageName == 'Sales') {
        opp.StageName = 'Closed Won';
      }
    }
    update queriedOppList;
  }
}
