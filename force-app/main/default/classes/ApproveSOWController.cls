public without sharing class ApproveSOWController {
  public Opportunity opp { get; set; }

  public ApproveSOWController() {
    String opportunityId = ApexPages.currentPage()
      .getParameters()
      .get('opportunityId');
    if (opportunityId != null) {
      opp = [
        SELECT Id, Approved_SOW__c
        FROM Opportunity
        WHERE Id = :opportunityId
        LIMIT 1
      ];
    }
  }

  public PageReference approveOpportunity() {
    if (opp != null) {
      opp.Approved_SOW__c = true;
      opp.StageName = 'Closed Won';
      update opp;
    }
    return null;
  }
}
