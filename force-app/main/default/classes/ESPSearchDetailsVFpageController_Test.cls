@isTest
public class ESPSearchDetailsVFpageController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    //Test.stopTest();
  }
  @isTest
  public static void testGetSearchResultsFromESP() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    Test.setCurrentPageReference(
      new PageReference('Page.ESPSearchDetailsPage')
    );
    System.currentPageReference().getParameters().put('6075966', 'ProductId');
    System.currentPageReference().getParameters().put('840337293', 'recId');
    System.currentPageReference()
      .getParameters()
      .put('recordFrom', 'Opportunity');
    System.currentPageReference().getParameters().put('true', 'isEspProduct');
    //ApexPages.StandardController sc = new ApexPages.StandardController([SELECT id FROM Opportunity LIMIT 1]);
    ESPSearchDetailsVFpageController ext = new ESPSearchDetailsVFpageController();
    ext.getProductsFromESP('6075966');
    ext.getSearch();
    ext.addSingleProduct();
    ext.addProduct();
    //ext.getProductsFromESP('552674284');
    //ext.getSearch();
    Test.stopTest();
  }
}
