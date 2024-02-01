@isTest
public class TriggerOnArtworkService_Test {
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
  public static void testMethods() {
    Test.startTest();
    OpportunityLineItem_ArtWork__c artWork = [
      SELECT id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    artWork.Title__c = 'Updated Title';
    artWork.logo_Name__c = 'Test';
    artWork.Logo_Size__c = 'Test';
    artWork.Logo_Color__c = 'Test';
    artWork.Supplier_Notes__c = 'Test';
    artWork.Proof_Required__c = 'Email Proof';
    artWork.Repeat_Logo__c = 'Yes';
    artWork.Imprint_Type__c = 'Cutting';
    update artWork;
    delete artWork;
    Test.stopTest();
  }
}
