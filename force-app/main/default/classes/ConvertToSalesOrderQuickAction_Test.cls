@isTest
public class ConvertToSalesOrderQuickAction_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createAccount('4', 'lhr', 'punjab', 'country');
    testFactory.createEstimate();
    System.Test.startTest();
    testFactory.createProductLineItems();
    TestFactory.createProductLineItemsRelatedItems();
    System.Test.stopTest();
    //TestFactory.createRunCharge();
    //TestFactory.createFixedCharge();

    Product2 pro = [SELECT id FROM product2 LIMIT 1];

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );

    //Execute an update DML on the Pricebook2 record, to make IsStandard to true
    update standardPricebook;

    //Query for the Pricebook2 record, to check IsStandard field
    standardPricebook = [
      SELECT Id, IsStandard
      FROM Pricebook2
      WHERE Id = :standardPricebook.Id
    ];
    //It should return true

    //Create the PricebookEntry
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = pro.Id,
      UnitPrice = 1020,
      IsActive = true
    );
    insert pbe;
    Estimate__c estimate = [
      SELECT id, Client_Approval_Status__c
      FROM Estimate__c
      LIMIT 1
    ];
    estimate.Client_Approval_Status__c = 'Approved';
    update estimate;
  }
  @isTest
  public static void testisValidPricing() {
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];
    Estimate__c estimate = [SELECT ID FROM Estimate__c LIMIT 1];
    User user = [SELECT ID, Design_Bank__c FROM User LIMIT 1];
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    List<ConvertToSalesOrderObject> objList = new List<ConvertToSalesOrderObject>();

    if (oppLineItems != null && oppLineItems.Size() > 0) {
      ConvertToSalesOrderObject obj = new ConvertToSalesOrderObject();
      Boolean value = true;
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        obj.recordId = oppLine.Id;
        obj.value = value;
      }
      objList.add(obj);
    }
    gen.writeFieldName('object');
    gen.writeObject(objList);
    String jsonString = gen.getAsString().Remove('"object" :');
    jsonString = jsonString.removeEnd('}');
    jsonString = jsonString.removeStart('{');
    System.Test.startTest();
    ConvertToSalesOrderQuickActionController.isValidPricing(
      opp.Id,
      jsonString,
      opp,
      estimate,
      user
    );
    System.Test.stopTest();
  }

  @isTest
  public static void testConvertToEstimateInDb() {
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    List<ConvertToSalesOrderObject> objList = new List<ConvertToSalesOrderObject>();

    if (oppLineItems != null && oppLineItems.Size() > 0) {
      ConvertToSalesOrderObject obj = new ConvertToSalesOrderObject();
      Boolean value = true;
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        obj.recordId = oppLine.Id;
        obj.value = value;
      }
      objList.add(obj);
    }
    gen.writeFieldName('object');
    gen.writeObject(objList);
    String jsonString = gen.getAsString().Remove('"object" :');
    jsonString = jsonString.removeEnd('}');
    jsonString = jsonString.removeStart('{');
    System.Test.startTest();
    ConvertToSalesOrderQuickActionController.convertToEstimateInDb(
      opp.Id,
      jsonString
    );
    System.Test.stopTest();
    ConvertToSalesOrderQuickActionController.sendEmail(
      null,
      32,
      [SELECT id FROM Estimate__c LIMIT 1].id,
      [SELECT id, Name FROM Opportunity LIMIT 1]
    );
  }
  @isTest
  public static void testGetRelatedOpportunityLineItems() {
    System.Test.startTest();
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];
    ConvertToSalesOrderQuickActionController.getRelatedOpportunityLineItems(
      opp.Id
    );
    System.Test.stopTest();
  }
}
