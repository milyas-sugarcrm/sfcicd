@isTest
public class OppDepositInvoiceActionController_Test {
  public static TestFactory testFactory = new TestFactory(1);
  @testSetup
  public static void populateData() {
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createDepositInvoice();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
  }

  @isTest
  public static void testMethods() {
    Order order = [SELECT id FROM Order LIMIT 1];
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();

    DepositInvoiceObject obj = new DepositInvoiceObject();

    obj.deposit_percent = 12;
    obj.amount_recieved = 10;
    obj.confirmation = '001';
    //obj.date_recieved = '02-02-2020';
    obj.Allow_credit_card = true;

    gen.writeFieldName('object');
    gen.writeObject(obj);
    String jsonString = gen.getAsString().Remove('"object" :');
    jsonString = jsonString.removeEnd('}');
    jsonString = jsonString.removeStart('{');
    OppDepositInvoiceActionController.getTotal(order.Id, jsonString);
    Deposit_Invoice__c depositInfo = [
      SELECT id
      FROM Deposit_Invoice__c
      LIMIT 1
    ];
    delete depositInfo;
    OppDepositInvoiceActionController.getTotal(order.Id, jsonString);
  }
}
