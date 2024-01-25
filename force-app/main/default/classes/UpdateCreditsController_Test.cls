@isTest
public class UpdateCreditsController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }
  @isTest
  public static void testUpdateCredits() {
    Test.setCurrentPageReference(new PageReference('Page.UpdateCredits'));
    System.currentPageReference().getParameters().put('updatedCredits', '20');
    System.currentPageReference()
      .getParameters()
      .put('Id', [SELECT id FROM User LIMIT 1].id);
    Estimate__c est = [SELECT id FROM Estimate__c LIMIT 1];
    System.currentPageReference().getParameters().put('Estimate', est.id);
    System.currentPageReference().getParameters().put('status', 'true');
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM User LIMIT 1]
    );
    UpdateCreditsController ext = new UpdateCreditsController(sc);
    ext.getPreviousRequestStatus();
    ext.addCredits();
    est.Update_Credit_Request_Status__c = 'Rejected';
    update est;
    ext.rejectRequest();
    ext.getPreviousRequestStatus();
    est.Update_Credit_Request_Status__c = 'Approved';
    update est;
    ext.getPreviousRequestStatus();
    est.Update_Credit_Request_Status__c = 'Pending';
    update est;
    ext.getPreviousRequestStatus();
    System.currentPageReference().getParameters().put('status', 'false');
    ext.getPreviousRequestStatus();
    ext.getUserDetails();
    ext.getOppLink();
    ext.getOpportunityDetails();
  }
}
