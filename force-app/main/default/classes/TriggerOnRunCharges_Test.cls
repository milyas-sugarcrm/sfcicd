@isTest
public class TriggerOnRunCharges_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    Line_Item_Pricing_RunCharge__c runcharges = [
      SELECT
        Id,
        Title__c,
        Value1__c,
        Value2__c,
        Value3__c,
        Value4__c,
        Value5__c,
        EstimatedQuantity__c
      FROM Line_Item_Pricing_RunCharge__c
      WHERE OpportunityLineItem__c = :opportunityLineItem.Id
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    if (opportunityLineItem != null && runcharges != null) {
      runcharges.EstimatedQuantity__c = 12;
      update runcharges;
      Opportunity oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
        LIMIT 1
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      oppor.isOutdated__c = false;
      update oppor;
      Estimate__c est = [
        SELECT Id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :oppor.Id
        LIMIT 1
      ];
      OpportunityLineItem__c oppLineItem = [
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :oppor.Id
        LIMIT 1
      ];

      oppLineItem.Opportunity__c = null;
      oppLineItem.Estimate__c = est.Id;
      update oppLineItem;
      runcharges = [
        SELECT
          Id,
          Title__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          EstimatedQuantity__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      runcharges.Title__c = '100';
      update runcharges;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
        LIMIT 1
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      oppor.isOutdated__c = false;
      update oppor;
      Order ord = [
        SELECT Id, OpportunityId
        FROM Order
        WHERE OpportunityId = :oppor.Id
        LIMIT 1
      ];
      oppLineItem = [
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :est.Id
        LIMIT 1
      ];
      oppLineItem.Estimate__c = null;
      oppLineItem.Work_Order__c = ord.Id;
      update oppLineItem;
      runcharges = [
        SELECT
          Id,
          Title__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          EstimatedQuantity__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      runcharges.Value2__c = 1000;
      update runcharges;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
        LIMIT 1
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      Test.stopTest();
    }
  }
}
