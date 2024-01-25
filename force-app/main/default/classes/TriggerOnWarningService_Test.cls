@isTest
public class TriggerOnWarningService_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }
  @isTest
  public static void testUpdateHistoryAfterInsert() {
    WarningsOpportunityLineItem__c warning = new WarningsOpportunityLineItem__c();
    warning.OpportunityLineItem__c = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ]
    .id;
    warning.Warning__c = 'Test warning...';
    insert warning;
    warning.Warning__c = 'Updated Test warning...';
    update warning;
    delete warning;
  }
}
