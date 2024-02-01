@isTest
public class TriggerOnArtwork_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.startTest();
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
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
    ];
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT
        Id,
        Imprint_Type__c,
        Proof_Required__c,
        logo_Name__c,
        Logo_Size__c,
        Logo_Color__c,
        Repeat_Logo__c,
        Supplier_Notes__c,
        Document_ID__c,
        Title__c
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c = :opportunityLineItem.Id
      LIMIT 1
    ];
    Estimate__c est1 = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.Id
    ];
    opp.isOutdated__c = false;
    artwork.OpportunityLineItem__c = opportunityLineItem.Id;
    artwork.Estimate__c = est1.id;
    update opp;
    if (opportunityLineItem != null && artwork != null) {
      artwork.logo_Name__c = '12';
      update artwork;
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
      artwork = [
        SELECT
          Id,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c,
          Title__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      artwork.Imprint_Type__c = '100';
      update artwork;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      system.assertEquals(true, oppor.isOutdated__c);
      oppor.isOutdated__c = false;
      update oppor;
      Order ord = [
        SELECT Id, OpportunityId
        FROM Order
        WHERE OpportunityId = :oppor.Id
      ];
      oppLineItem = [
        SELECT Id, Opportunity__c, Estimate__c, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :est.Id
      ];
      oppLineItem.Estimate__c = null;
      oppLineItem.Work_Order__c = ord.Id;
      update oppLineItem;
      artwork = [
        SELECT
          Id,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c,
          Title__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :opportunityLineItem.Id
        LIMIT 1
      ];
      artwork.Logo_Color__c = '1000';
      update artwork;
      oppor = [
        SELECT Id, StageName, isOutdated__c
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      system.assertEquals(true, oppor.isOutdated__c);

      Test.stopTest();
    }
  }

  @isTest
  public static void testSOHistory() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    OpportunityLineItem__c opportunityLineItem = [
      SELECT Id, Opportunity__c, Work_Order__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.Id
    ];
    OpportunityLineItem_ArtWork__c artwork1 = new OpportunityLineItem_ArtWork__c();
    artwork1.Title__c = 'artwork1';
    artwork1.Imprint_Type__c = 'Logo Dome';
    artwork1.Proof_Required__c = 'None';
    artwork1.logo_Name__c = 'artwork1';
    artwork1.Logo_Size__c = '12';
    artwork1.Logo_Color__c = 'Black';
    artwork1.Repeat_Logo__c = 'No';
    artwork1.Supplier_Notes__c = 'notes';
    artwork1.Document_ID__c = '123';
    artwork1.OpportunityLineItem__c = opportunityLineItem.id;
    insert artwork1;
    artwork1.Title__c = 'artwork2';
    artwork1.Imprint_Type__c = 'Logo Magic';
    artwork1.Proof_Required__c = 'Email Proof';
    artwork1.logo_Name__c = 'artwork2';
    artwork1.Logo_Size__c = '13';
    artwork1.Logo_Color__c = 'White';
    artwork1.Repeat_Logo__c = 'Yes';
    artwork1.Supplier_Notes__c = 'notes2';
    artwork1.Document_ID__c = '234';
    update artwork1;
    List<Sales_Order_History__c> SOHistory = [
      SELECT New_Value__c, Old_Value__c
      FROM Sales_Order_History__c
      WHERE
        Work_Order__c = :opportunityLineItem.Work_Order__c
        AND Old_Value__c = 'artwork1'
    ];
    if (SOHistory.size() > 0) {
      system.assertEquals(SOHistory[0].New_Value__c, 'artwork2');
    }

    delete artwork1;
    Test.stopTest();
  }
}
