@isTest
public class Test_ConvertToEstimateQuickAction {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(3);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    //testFactory.createEstimate();
    testFactory.createProducts();
    //testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    TestFactory.createProductLineItemsRelatedItems();
    //TestFactory.createRunCharge();
    // TestFactory.createFixedCharge();
  }
  @isTest
  public static void testConvertToEstimateInDb() {
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Test.startTest();
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      LIMIT 3
    ];
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    List<convertToEstimateObject> objList = new List<convertToEstimateObject>();

    if (oppLineItems != null && oppLineItems.Size() > 0) {
      convertToEstimateObject obj = new convertToEstimateObject();
      Integer values = 2;
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        obj.recordId = oppLine.Id;
        obj.value = values;
        values += 2;
      }
      objList.add(obj);
    }
    gen.writeFieldName('object');
    gen.writeObject(objList);
    String jsonString = gen.getAsString().Remove('"object" :');
    jsonString = jsonString.removeEnd('}');
    jsonString = jsonString.removeStart('{');
    List<Estimate__c> est = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    if (est != null && est.size() > 0) {
      delete est;
    }
    ConvertToEstimateQuickActionController.convertToEstimateInDb(
      opp.Id,
      jsonString,
      'Team Phun'
    );

    test.stopTest();
    ConvertToEstimateQuickActionController.convertToEstimateInDb(
      opp.Id,
      null,
      'Team Phun'
    );
  }
  @isTest
  public static void testGetRelatedOpportunityLineItems() {
    Test.startTest();
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];

    ConvertToEstimateQuickActionController.getAccountDropDown(opp.Id);
    ConvertToEstimateQuickActionController.getAccountDD(opp.Id);
    ConvertToEstimateQuickActionController.makeAccountPrimaryForSyncing(
      opp.Id,
      'Team Phun'
    );
    ConvertToEstimateQuickActionController.makeAccountForSyncing(
      opp.Id,
      'Team Phun'
    );
    ConvertToEstimateQuickActionController.getRelatedOpportunityLineItems(
      opp.Id
    );
    ConvertToEstimateQuickActionController.getRelatedOppLineItems(opp.Id);
    test.stopTest();
  }
}
