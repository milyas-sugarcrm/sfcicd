@isTest
public class Test_TriggerOnDepositInvoice {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    testFactory.createProducts();
    testFactory.createEstimate();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createDepositInvoice();
  }
  @isTest
  public static void testDepositAfterUpdateTrigger() {
    Order order = [SELECT id, Deposit_Invoice__c FROM Order LIMIT 1];
    Deposit_Invoice__c depositInfo = [
      SELECT id, Allow_credit_card__c
      FROM Deposit_Invoice__c
      WHERE id = :order.Deposit_Invoice__c
    ];
    depositInfo.Allow_credit_card__c = false;
    update depositInfo;
    // TriggerOnDepositInvoiceService.generatePDF(lst_OppLineItem);
  }
}
