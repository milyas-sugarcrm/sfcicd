@isTest
private class TestApproveSOWController {
  @testSetup
  static void setupTestData() {
    List<RecordType> pfaCustomerRecordType = [
      SELECT Id
      FROM RecordType
      WHERE
        SObjectType = 'Opportunity'
        AND DeveloperName = 'PFA_Customer_Opportunity'
      LIMIT 1
    ];
    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today()
    );
    if (pfaCustomerRecordType.size() > 0) {
      testOpportunity.RecordTypeId = pfaCustomerRecordType[0].Id;
    }
    insert testOpportunity;
  }

  @isTest
  static void testApproveOpportunity() {
    List<Opportunity> testOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

    if (testOpportunity.size() > 0) {
      // Set up the PageReference for the controller
      PageReference pageRef = Page.ApproveSOW;
      Test.setCurrentPage(pageRef);
      pageRef.getParameters().put('opportunityId', testOpportunity[0].Id);

      // Instantiate the controller
      ApproveSOWController controller = new ApproveSOWController();
      controller.opp = testOpportunity[0];

      // Call the approveOpportunity method
      Test.startTest();
      controller.approveOpportunity();
      Test.stopTest();

      // Verify that the Opportunity has been updated
      Opportunity updatedOpportunity = [
        SELECT Id, Approved_SOW__c, StageName
        FROM Opportunity
        WHERE Id = :testOpportunity[0].Id
        LIMIT 1
      ];
      System.assertEquals(
        true,
        updatedOpportunity.Approved_SOW__c,
        'Opportunity Approved_SOW__c not True'
      );
      System.assertEquals(
        'Closed Won',
        updatedOpportunity.StageName,
        'Opportunity Stage not Colsed Won'
      );
    }
  }
}
