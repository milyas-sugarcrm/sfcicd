@isTest
public class Test_relatedListOpportunityLineItem {
  @TestSetup
  public static void testSetup() {
    TestFactory testFactory = new TestFactory(5);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createProductLineItems();

    TestFactory.createProductLineItemsRelatedItems();
    TestFactory.createRunCharge();
    TestFactory.createFixedCharge();
  }
  @isTest
  public static void testGetRelatedOpportunityLineItems() {
    OpportunityLineItem__c testOpp = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    relatedListOppotunityLineItem.getRelatedOpportunityLineItems(testOpp.Id);
  }
  @isTest
  public static void testDeleteOpportunityLineItem() {
    test.startTest();
    OpportunityLineItem__c testOpp = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    relatedListOppotunityLineItem.deleteOpportunityLineItemInDb(testOpp.Id);
    test.stopTest();
  }
}
