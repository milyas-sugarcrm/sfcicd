@isTest
public class generatePDF_Test {
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
    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    //testFactory.createDepositInvoice();
    Test.stopTest();
  }
  @isTest
  public static void testGeneratePDF() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id
      FROM Opportunity
      LIMIT 1
    ];
    generatePdf.generatePdfPrsentation(opp.id, '');
    generatePdf.generatePdfEstimate(opp.id, '');
    generatePdf.generatePdfSalesorder(opp.id, '');
    Test.stopTest();
  }
}
