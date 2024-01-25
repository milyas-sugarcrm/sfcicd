@isTest
public class Test_OpportunityLineItemsPfaController {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }
  @isTest
  public static void testDataManipulation() {
    test.startTest();
    Opportunity opp = [
      SELECT Id
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItemsPfaController.checkEstimateExists(opp.Id);
    OpportunityLineItemsPfaController.getOpportunityStage(opp.Id);
    List<OpportunityLineItem__c> lineItems = [
      SELECT Id, Estimate__c
      FROM OpportunityLineItem__c
    ];
    for (OpportunityLineItem__c oppitem : lineItems) {
      oppitem.Estimate__c = null;
    }
    update lineItems;
    OpportunityLineItemsPfaController.getRelatedOpportunityLineItemsPfa(
      [SELECT id FROM Opportunity LIMIT 1].id,
      6
    );

    OpportunityLineItemsPfaController.getRelatedOpportunityLineItemsPfa(
      [SELECT id FROM Opportunity LIMIT 1].id,
      13
    );

    //System.assertEquals(OpportunityLineItemsPfaController.getPresentationPreviewLink(opp.id),URL.getSalesforceBaseUrl().toExternalForm()+'/apex/PresentationPreview?id='+ opp.id);

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Boolean dataDeleted = OpportunityLineItemsPfaController.deleteOpportunityLineItemInDb(
      lineItem.id
    );
    System.assert(dataDeleted);

    dataDeleted = OpportunityLineItemsPfaController.deleteOpportunityLineItemInDb(
      lineItem.Id
    );
    System.assert(dataDeleted == false);
    test.stopTest();
  }

  @isTest
  public static void testCloneOpportunityLineItemInDB() {
    List<OpportunityLineItem__c> oppLineItem = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        IsProductExists__c,
        Account__c,
        Imprint_Methods__c,
        Variant_Id__c,
        Quantity_Estimate__c,
        ESPId__c,
        Currency__c,
        Private_Notes__c,
        Product__r.Name,
        Price_Label__c,
        Opportunity__c,
        SKU__c,
        Product__c,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    System.debug(oppLineItem);
    Test.startTest();
    OpportunityLineItemsPfaController.cloneOpportunityLineItemInDB(
      oppLineItem[0].Id
    );
    Test.stopTest();
    List<OpportunityLineItem__c> oppLineItemsAfterClone = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        IsProductExists__c,
        Account__c,
        Imprint_Methods__c,
        Variant_Id__c,
        Quantity_Estimate__c,
        ESPId__c,
        Currency__c,
        Private_Notes__c,
        Product__r.Name,
        Price_Label__c,
        Opportunity__c,
        SKU__c,
        Product__c,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      WHERE Product__r.Name = :oppLineItem[0].Product__r.Name
    ];
    System.assertEquals(true, oppLineItemsAfterClone.size() > 1);
  }
}
