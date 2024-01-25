@isTest
public class TriggerOnExtraChargesEstimate_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    //testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    System.Test.startTest();
    ExtraChargesEstimate__c pricing = [
      SELECT Id, Margin__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    pricing.Margin__c = 100;
    pricing.Title__c = 'test';
    pricing.Quantity__c = 2;
    pricing.Net_Cost__c = 23;
    pricing.Duty_Percentage__c = 2;
    pricing.Charge_Type__c = 'InternationalCost_Duty';
    update pricing;
    delete pricing;
    System.Test.stopTest();
  }
}
