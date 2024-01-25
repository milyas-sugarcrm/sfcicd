@istest
public class Test_EstimateTriggerService {
  @testSetup
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
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    Estimate__c est = [
      SELECT
        Id,
        Status__c,
        In_Hands_Date__c,
        Customer_PO__c,
        Opportunity__c,
        Default_Tax__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.Id
    ];
    est.Customer_PO__c = 'asdasdas';
    update est;
    Opportunity oppor = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    Test.stopTest();
  }
  @istest
  public static void testDeleteOppLineItemsRelatedToEstimate() {
    Test.startTest();
    List<Estimate__c> estimates = [SELECT Id, Name FROM Estimate__c];

    delete estimates;

    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id
      FROM OpportunityLineItem__c
      WHERE Estimate__c = :estimates[0].Id
    ];

    Test.stopTest();
  }
}
