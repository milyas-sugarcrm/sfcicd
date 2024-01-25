@isTest
public class TriggerOnOppLineItemAttachment_Test {
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
    test.startTest();
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

    OpportunityLineItemAttachment__c attach = new OpportunityLineItemAttachment__c();
    attach.OpportunityLineItem__c = opportunityLineItem.Id;
    insert attach;
    OpportunityLineItemAttachment__c attachment = [
      SELECT OpportunityLineItem__c, Id, Name, Estimate__c
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c = :opportunityLineItem.Id
      LIMIT 1
    ];

    opp.isOutdated__c = false;
    update opp;
    if (opportunityLineItem != null && attachment != null) {
      attachment.Estimate__c = null;
      update attachment;
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
      attachment = [
        SELECT OpportunityLineItem__c, Id, Name, Estimate__c
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      attachment.Estimate__c = null;
      update attachment;
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
      attachment = [
        SELECT OpportunityLineItem__c, Id, Name, Estimate__c
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      attachment.Estimate__c = null;
      update attachment;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
        LIMIT 1
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      test.stopTest();
    }
  }
}
