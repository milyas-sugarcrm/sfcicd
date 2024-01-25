@istest
public class PurchaseOrderProofApprovalPreview_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.startTest();
    testFactory.addAddressRelatedData();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
    Test.stopTest();
  }
  @isTest
  public static void testGetRelatedPurchaseOrderDataAndProof() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM PurchaseOrder__c LIMIT 1]
    );
    PurchaseOrderProofApprovalPreview ext = new PurchaseOrderProofApprovalPreview(
      sc
    );
    ext.getDetails();
    Test.stopTest();
  }
  @isTest
  public static void testAddComment() {
    Test.setCurrentPageReference(
      new PageReference('Page.PurchaseOrderProofApprovalPage')
    );
    System.currentPageReference()
      .getParameters()
      .put('comment' + [SELECT id FROM Proof__c LIMIT 1].id, 'My comment');
    System.currentPageReference()
      .getParameters()
      .put('type', 'Proof (Client Approved)');
    System.currentPageReference()
      .getParameters()
      .put('recId', [SELECT id FROM Proof__c LIMIT 1].id);
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM PurchaseOrder__c LIMIT 1]
    );
    PurchaseOrderProofApprovalPreview ext = new PurchaseOrderProofApprovalPreview(
      sc
    );
    ext.addComment();
  }
}
