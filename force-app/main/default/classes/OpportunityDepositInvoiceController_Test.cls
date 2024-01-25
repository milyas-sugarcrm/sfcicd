@isTest
public class OpportunityDepositInvoiceController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createDepositInvoice();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testMethods() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Order LIMIT 1]
    );
    OpportunityDepositInvoiceController ext = new OpportunityDepositInvoiceController(
      sc
    );
    String billingAddress = ext.getBillingAddress();
    String shippingAddress = ext.getShippingAddress();
    ext.getSalesOrderDetails();
    ext.getSubTotal();
    ext.getTotalPlusTax();
    ext.getDepositDetails();

    Test.stopTest();
  }

  @isTest
  public static void testMethods2() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Order LIMIT 1]
    );
    OpportunityDepositInvoiceController ext = new OpportunityDepositInvoiceController(
      sc
    );

    List<OpportunityDepositInvoice> listOfItems = ext.getLineItemsList();
    ext.getOppLink();
    ext.getOpportunity();
    Test.stopTest();
  }
  @isTest
  public static void testMethods3() {
    Test.startTest();

    Test.stopTest();
  }
}
