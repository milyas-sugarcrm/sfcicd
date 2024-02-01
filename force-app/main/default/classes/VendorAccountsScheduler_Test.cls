@isTest
public with sharing class VendorAccountsScheduler_Test {
  @TestSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createPriceBookEntry();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createOppProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testCalculateFields() {
    VendorAccountsScheduler vas = new VendorAccountsScheduler();
    String CRON_EXP = '0 0 0 ? * * *';
    Test.startTest();
    Order ord = [SELECT Id FROM Order LIMIT 1];
    ord.Invoice_Date__c = System.Date.today();
    update ord;
    system.schedule('Test calculate Vendor Account Fields1', CRON_EXP, vas);
    Test.stopTest();
  }
}
