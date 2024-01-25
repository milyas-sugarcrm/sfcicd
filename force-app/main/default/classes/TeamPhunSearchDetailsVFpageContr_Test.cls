@isTest
public class TeamPhunSearchDetailsVFpageContr_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createProductsPrices();
    testFactory.createProductLineItems();
  }
  @isTest
  public static void testGetSearchResultsFromESP() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    Test.setCurrentPageReference(
      new PageReference('Page.TeamPhunSearchDetailsPage')
    );
    System.currentPageReference().getParameters().put('123', 'ProductId');
    //ApexPages.StandardController sc = new ApexPages.StandardController([SELECT id FROM Opportunity LIMIT 1]);
    TeamPhunSearchDetailsVFpageController ext = new TeamPhunSearchDetailsVFpageController();
    ext.getSearchResults();
    ext.getSearch();
    Test.stopTest();
  }
}
