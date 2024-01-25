@isTest
public with sharing class AddProductMainCompWoController_Test {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.addAddressRelatedData();
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
  }
  @isTest
  public static void testGetWorkOrderName() {
    Order order = [SELECT id FROM order LIMIT 1];
    AddProductMainCompWoController.getWorkOrderName(order.id);
  }
}
