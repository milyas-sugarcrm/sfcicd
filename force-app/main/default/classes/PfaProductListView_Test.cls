@isTest
public class PfaProductListView_Test {
  static Id campaignId;
  static Id oppId;
  static Id productId;
  static Id LineItemId;
  static Id testId = 'a20000000000000000';

  @TestSetup
  static void setupTestData() {
    TestFactoryPfa testFactoryPfa = new TestFactoryPfa(1);
    testFactoryPfa.createOpportunities();
    testFactoryPfa.createProducts();
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    productId = prod.Id;
    oppId = opp.Id;
    LineItemId = PfaProductListView.createLineItem(
      productId,
      null,
      oppId,
      null
    );
  }

  @isTest
  static void testGetPfaProducts_NoRecords() {
    List<PFA_Product_Line_Item__c> lineItems = PfaProductListView.getPfaProductLineItems(
      testId,
      testId,
      testId
    );
    System.assertEquals(0, lineItems.size());
  }

  @isTest
  static void testRemoveLineItem() {
    PfaProductListView.removeLineItem(testId);
    List<PFA_Product_Line_Item__c> deletedLineItems = [
      SELECT Id
      FROM PFA_Product_Line_Item__c
      WHERE Id = :testId
    ];
    System.assertEquals(0, deletedLineItems.size());
  }

  @isTest
  static void testSearchPfaProducts() {
    List<SObject> products = PfaProductListView.searchPfaProducts('Test');
    System.assertNotEquals(0, products.size());
  }

  @isTest
  static void testCreateLineItem() {
    Id lineItemId = PfaProductListView.createLineItem(
      productId,
      null,
      oppId,
      null
    );
    System.assertEquals(null, lineItemId);
  }

  @isTest
  static void testGetPfaProductTypeId() {
    Id recordTypeId = PfaProductListView.getPfaProductTypeId();
    System.assertNotEquals(null, recordTypeId);
  }
}
