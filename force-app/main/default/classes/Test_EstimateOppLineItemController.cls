@isTest
public class Test_EstimateOppLineItemController {
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
    Test.startTest();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createExtraCharges();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testDataManipulation() {
    test.startTest();
    Estimate__c est = [SELECT id FROM Estimate__c LIMIT 1];
    EstimateOppLineItemController.getEstimateRelatedOpportunityLineItems(
      [SELECT id FROM Estimate__c LIMIT 1].id,
      6
    );

    EstimateOppLineItemController.getEstimateRelatedOpportunityLineItems(
      [SELECT id FROM Estimate__c LIMIT 1].id,
      13
    );

    Estimate__c estimate = [SELECT id, Opportunity__c FROM Estimate__c LIMIT 1];
    System.assertEquals(
      EstimateOppLineItemController.getEstimatePreviewLink(estimate.id),
      URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/OpportunityEstimatePreview?id=' +
        estimate.Opportunity__c
    );

    System.assertEquals(
      EstimateOppLineItemController.getOpportunityId(estimate.id),
      estimate.Opportunity__c
    );
    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Boolean dataDeleted = EstimateOppLineItemController.deleteOpportunityLineItemInDb(
      lineItem.id
    );
    System.assert(dataDeleted);

    dataDeleted = EstimateOppLineItemController.deleteOpportunityLineItemInDb(
      lineItem.Id
    );
    System.assert(dataDeleted == false);

    EstimateOppLineItemController.getOpportunityStage(est.Id);
    EstimateOppLineItemController.deleteEstimates(est.Id);
    test.stopTest();
  }

  @isTest
  public static void testGetNotSyncedRecords() {
    test.startTest();
    EstimateOppLineItemController.getNotSyncedEstimate(
      [SELECT id FROM Estimate__c LIMIT 1].id
    );
    EstimateOppLineItemController.syncEstimates(
      [SELECT id FROM Estimate__c LIMIT 1].id
    );
    EstimateOppLineItemController.getCountOfEstimateOppLineItems(
      [SELECT id FROM Estimate__c LIMIT 1].id
    );

    test.stopTest();
  }
}
