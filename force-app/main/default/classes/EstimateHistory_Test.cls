@isTest
public class EstimateHistory_Test {
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
  public static void testGetEstimateHistory() {
    Estimate_History__c estHistory = new Estimate_History__c();
    estHistory.Estimate__c = [SELECT id FROM Estimate__c LIMIT 1].id;
    estHistory.Related_Object_Id__c = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ]
    .id;
    estHistory.Changed_field__c = 'Warning';
    estHistory.New_Value__c = 'New Value';
    estHistory.Previous_Value__c = 'Old Value';
    insert estHistory;
    EstimateHistory.getHistory([SELECT id FROM Estimate__c LIMIT 1].id);
  }
}
