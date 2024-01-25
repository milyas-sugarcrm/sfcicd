@isTest
public class Test_TriggerOnOpportunityLineItemService {
  @testSetup
  public static void createData() {
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
    testFactory.createProductLineItems();
    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testApprovalEmailSendCriteria() {
    Test.startTest();
    List<OpportunityLineItem__c> lst_OppLineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.stopTest();
  }

  @isTest
  public static void testCheckUpdate() {
    test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c, Name
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    if (opportunityLineItem != null) {
      opportunityLineItem.Name = 'asdsad';
      update opportunityLineItem;
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
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :oppor.Id
        LIMIT 1
      ];

      oppLineItem.Opportunity__c = null;
      oppLineItem.Estimate__c = est.Id;
      oppLineItem.Name = 'asdsad';
      update oppLineItem;

      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      //   system.assertEquals(true, oppor.isOutdated__c);
      oppor.isOutdated__c = false;
      update oppor;
      Order ord = [
        SELECT Id, OpportunityId
        FROM Order
        WHERE OpportunityId = :oppor.Id
        LIMIT 1
      ];
      oppLineItem = [
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :est.Id
        LIMIT 1
      ];
      oppLineItem.Estimate__c = null;
      oppLineItem.Work_Order__c = ord.Id;
      oppLineItem.Name = 'asdsad';
      update oppLineItem;

      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
        LIMIT 1
      ];
      // system.assertEquals(true, oppor.isOutdated__c);
    }
    test.stopTest();
  }

  @istest
  public static void testDeleteRecordsRelatedToOppLineItems() {
    test.startTest();
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
    ];
    Set<Id> oppLineItemIds = new Set<Id>();
    for (OpportunityLineItem__c oppLineItem : oppLineItems) {
      oppLineItemIds.add(oppLineItem.Id);
    }
    delete oppLineItems;

    System.assertEquals(
      0,
      [
          SELECT Id
          FROM Comment__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM ColorLineItem__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM SizeLineItem__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM PricingLineItem__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM Line_Item_Pricing_RunCharge__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM OpportunityLineItem_Add_Fixed_Charge__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM WarningsOpportunityLineItem__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM OpportunityLineItem_ArtWork__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    System.assertEquals(
      0,
      [
          SELECT Id
          FROM OpportunityLineItemAttachment__c
          WHERE OpportunityLineItem__c IN :oppLineItemIds
        ]
        .size()
    );
    test.stopTest();
  }
}
