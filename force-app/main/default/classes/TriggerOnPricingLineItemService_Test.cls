@isTest
public class TriggerOnPricingLineItemService_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    System.Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    System.Test.stopTest();
  }
  @isTest
  public static void testfunction() {
    System.Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
    ];
    PricingLineItem__c pricing = [
      SELECT
        Id,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        OpportunityLineItem__c,
        Margin__c,
        Total__c,
        Estimated_Quantity__c,
        Display__c,
        Color__c,
        Size__c
      FROM PricingLineItem__c
      WHERE OpportunityLineItem__c = :opportunityLineItem.Id
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    System.debug('PRICING VALUE: ' + pricing);
    if (opportunityLineItem != null && pricing != null) {
      pricing.Estimated_Quantity__c = 12;
      update pricing;
      Opportunity oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      oppor.isOutdated__c = false;
      update oppor;
      Estimate__c est = [
        SELECT Id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :oppor.Id
      ];
      OpportunityLineItem__c oppLineItem = [
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :oppor.Id
      ];

      oppLineItem.Opportunity__c = null;
      oppLineItem.Estimate__c = est.Id;
      update oppLineItem;
      pricing = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          OpportunityLineItem__c,
          Margin__c,
          Total__c,
          Estimated_Quantity__c,
          Display__c,
          Color__c,
          Size__c
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :oppLineItem.Id
        LIMIT 1
      ];
      pricing.Margin__c = 100;
      update pricing;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      oppor.isOutdated__c = false;
      update oppor;

      /*Order ord = [Select Id,OpportunityId 
                         FROM Order
                         WhERE OpportunityId =: oppor.Id];
            oppLineItem = [SELECT Id,Opportunity__c,Estimate__c,Work_Order__c 
                           FROM OpportunityLineItem__c 
                           WHERE Estimate__c =: est.Id];
            oppLineItem.Work_Order__c = ord.Id;
            update oppLineItem;
            pricing = [SELECT Id, Quantity__c, Net_Cost__c, Retail_Price__c,OpportunityLineItem__c,Margin__c, Total__c, Estimated_Quantity__c, Display__c, Color__c, Size__c 
                       FROM PricingLineItem__c 
                       WHERE OpportunityLineItem__c =: oppLineItem.Id 
                       LIMIT 1];
            pricing.Net_Cost__c = 1000;
            update pricing;
            oppor = [Select Id,StageName,isOutdated__c
                     FROM Opportunity 
                     WHERE Id =: opp.Id];
            delete pricing; */
    }
    delete pricing;
    System.Test.stopTest();
  }
}
