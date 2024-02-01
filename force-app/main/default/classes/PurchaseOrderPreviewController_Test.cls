@isTest
public class PurchaseOrderPreviewController_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.startTest();
    testFactory.addAddressRelatedData();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
    test.stopTest();
  }
  @isTest
  public static void testMethodsGetPurchaseOrderNumber() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    String poNumber = ext.getPurchaseOrderNumber();
    Test.stopTest();
  }
  @isTest
  public static void testMethodsGetOpportunityName() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    String opportunityName = ext.getOpportunityName();
    Test.stopTest();
  }
  @isTest
  public static void testMethodsGetOppLink() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    String oppLink = ext.getOppLink();
    Test.stopTest();
  }
  @isTest
  public static void testMethodsGetChangeStatus() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    String changeStatus = ext.getChangeStatus();
    Test.stopTest();
  }
  @isTest
  public static void testMethodapproveRejectOrder() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.approveRejectOrder();
    Test.stopTest();
  }
  @isTest
  public static void testMethodsetApprove() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.setApprove();
    Test.stopTest();
  }
  @isTest
  public static void testMethodgetShippingDetails() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.getShippingDetails();
    Test.stopTest();
  }

  @isTest
  public static void testMethodgetShippingFirm() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.getShippingFirm();
    Test.stopTest();
  }
  @isTest
  public static void testMethodgetListOfPurchaseOrderLineItem() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.getListOfPurchaseOrderLineItem();
    Test.stopTest();
  }
  @isTest
  public static void testMethodsetChange() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.setChange();
    Test.stopTest();
  }
  @isTest
  public static void testMethodgetPODetail() {
    // Test.startTest();
    //PurchaseOrder_LineItem__c poLineItem = [SELECT id FROM PurchaseOrder_LineItem__c LIMIT 1];
    //ApexPages.StandardController standardController = new ApexPages.StandardController(poLineItem);
    // PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(standardController);
    // Test.stopTest();
    //  ext.getPODetail();
  }
  @isTest
  public static void testMethodgetPurchaseOrderNumber() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    ext.getPurchaseOrderNumber();
    Test.stopTest();
  }
  @isTest
  public static void testMethods() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );

    ext.getAccountDetails();

    ext.getSupplierName();
    Test.stopTest();
  }
  @isTest
  public static void testGetSupplierAddress() {
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPreviewController ext = new PurchaseOrderPreviewController(
      standardController
    );
    Test.startTest();
    ext.getSupplierAddress();
    Test.stopTest();
  }
}
