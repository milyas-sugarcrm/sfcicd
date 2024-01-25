@isTest
public class TriggerOnComment_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.startTest();
    Opportunity opp1 = new Opportunity(Name = 'Opp ' + 1);
    opp1.StageName = 'Needs Analysis';
    opp1.CloseDate = Date.today();
    insert opp1;
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    Comment__c comm = new Comment__c();
    comm.Comment__c = 'hello';
    comm.OpportunityLineItem__c = opportunityLineItem.Id;
    insert comm;
    Opportunity oppor = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];
    system.assertEquals(true, oppor.isOutdated__c);
    Test.stopTest();
  }
}
