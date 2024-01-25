@isTest
public class Test_EditOpportunityLineItemController {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('bStreet', 'bCity', 'bState', 'bCountry');
    testFactory.createEstimate();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProducts();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
    Test.stopTest();
  }
  @isTest
  public static void test() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    WarningsOpportunityLineItem__c warningsToBeAdded = [
      SELECT id
      FROM WarningsOpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemController.updateWarningValueInDb(
      'Test warning',
      '',
      warningsToBeAdded.id
    );
  }

  @isTest
  public static void testRunChargesValueInDB() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    string tempId = '';
    string totalPrice = '';
    EditOpportunityLineItemController.updateRunChargeValueinDB(
      '22',
      'Value1',
      string.valueOf(
        [
          SELECT Id
          FROM Line_Item_Pricing_RunCharge__c
          LIMIT 1
        ]
        .id
      )
    );
    // EditOpportunityLineItemController.updateRunChargeValueinDB('22',
    //                                                            'Value2' ,
    //                                                            string.valueOf([SELECT Id
    //                                                                            FROM Line_Item_Pricing_RunCharge__c LIMIT 1].id));
    // EditOpportunityLineItemController.updateRunChargeValueinDB('22',
    //                                                            'Value3' ,
    //                                                            string.valueOf([SELECT Id
    //                                                                            FROM Line_Item_Pricing_RunCharge__c LIMIT 1].id));
    // EditOpportunityLineItemController.updateRunChargeValueinDB('22',
    //                                                            'Value4' ,
    //                                                            string.valueOf([SELECT Id
    //                                                                            FROM Line_Item_Pricing_RunCharge__c LIMIT 1].id));
    // EditOpportunityLineItemController.updateRunChargeValueinDB('22',
    //                                                            'Value5' ,
    //                                                            string.valueOf([SELECT Id
    //                                                                            FROM Line_Item_Pricing_RunCharge__c LIMIT 1].id));
    // EditOpportunityLineItemController.updateRunChargeValueinDB('Updated Title',
    //                                                            'title' ,
    //                                                            string.valueOf([SELECT Id
    //                                                                            FROM Line_Item_Pricing_RunCharge__c LIMIT 1].id));
    EditOpportunityLineItemController.updateRunChargeValueinDB(
      'Updated Title',
      'title',
      ''
    );
    PricingLineItem__c pricing = [SELECT id FROM PricingLineItem__c LIMIT 1];
    Line_Item_Pricing_RunCharge__c runCharge = [
      SELECT Id
      FROM Line_Item_Pricing_RunCharge__c
      LIMIT 1
    ];
    Test.stopTest();
    EditOpportunityLineItemController.deleteRunChargeinDB(
      runCharge.id,
      lineItem.id
    );
  }

  @isTest
  public static void testRunCharges() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    string tempId = '';
    string totalPrice = '';

    EditOpportunityLineItemController.addRunCharges(
      string.valueOf(lineItem.id),
      'Title',
      '22',
      '22',
      '22',
      '22',
      '22',
      [
        SELECT Title__c
        FROM OpportunityLineItem_ArtWork__c
        LIMIT 1
      ]
      .Title__c
    );
    EditOpportunityLineItemController.addRunCharges(
      string.valueOf(lineItem.id),
      'Title',
      '22',
      '22',
      '22',
      '22',
      '22',
      'Wrong art work title'
    );
    PricingLineItem__c pricing = [SELECT id FROM PricingLineItem__c LIMIT 1];
    Line_Item_Pricing_RunCharge__c runCharge = [
      SELECT Id
      FROM Line_Item_Pricing_RunCharge__c
      LIMIT 1
    ];
    EditOpportunityLineItemController.deleteRunChargeinDB(
      runCharge.id,
      lineItem.id
    );
    Test.stopTest();
  }
  @isTest
  public static void testWarnings() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    System.assert(
      EditOpportunityLineItemController.addWarningInDB(lineItem.id)
    );
    System.assert(
      EditOpportunityLineItemController.deleteWarningInDb(
        [SELECT Id FROM WarningsOpportunityLineItem__c LIMIT 1].id
      )
    );
    System.assert(
      EditOpportunityLineItemController.deleteWarningInDb('') == false
    );

    Test.stopTest();
  }
  @isTest
  public static void testFixedCharges() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    string tempId = '';
    string totalPrice = '';

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();

    System.assert(
      EditOpportunityLineItemController.addFixedCharges(
        string.valueOf(lineItem.id),
        'Title',
        art.Title__c
      ) == true
    );

    System.assert(
      EditOpportunityLineItemController.addFixedCharges(
        string.valueOf(lineItem.id),
        'Title',
        'Wrong Art work title'
      ) == false
    );

    // System.assertEquals(EditOpportunityLineItemController.updateFixedChargesInDb('22.00',
    //                                                                              'title' ,
    //                                                                              string.valueOf([SELECT Id
    //                                                                                              FROM OpportunityLineItem_Add_Fixed_Charge__c LIMIT 1].id)),([SELECT Id, Title__c, Cost__c, Margin__c, Retail_Price__c FROM OpportunityLineItem_Add_Fixed_Charge__c  LIMIT 1]));
    EditOpportunityLineItemController.updateFixedChargesInDb(
      '22.00',
      'cost',
      string.valueOf(
        [SELECT Id FROM OpportunityLineItem_Add_Fixed_Charge__c LIMIT 1].id
      )
    );
    // System.assert(EditOpportunityLineItemController.updateFixedChargesInDb('22.00',
    //                                                                        'margin' ,
    //                                                                        string.valueOf([SELECT Id
    //                                                                                        FROM OpportunityLineItem_Add_Fixed_Charge__c LIMIT 1].id))==([SELECT Id, Title__c, Cost__c, Margin__c, Retail_Price__c FROM OpportunityLineItem_Add_Fixed_Charge__c  LIMIT 1]));
    // System.assert(EditOpportunityLineItemController.updateFixedChargesInDb('22.00',
    //                                                                        'retail' ,
    //                                                                        string.valueOf([SELECT Id
    //                                                                                        FROM OpportunityLineItem_Add_Fixed_Charge__c LIMIT 1].id))==([SELECT Id, Title__c, Cost__c, Margin__c, Retail_Price__c FROM OpportunityLineItem_Add_Fixed_Charge__c  LIMIT 1]));
    EditOpportunityLineItemController.updateFixedChargesInDb(
      '22.00',
      'retail',
      ''
    );
    Test.stopTest();
  }
  @isTest
  public static void testComments() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    System.assert(
      EditOpportunityLineItemController.addCommentsInDb(
        lineItem.id,
        'My Comment',
        'Username'
      )
    );
    Test.StopTest();
  }

  @isTest
  public static void testListItems() {
    Test.startTest();
    EditOpportunityLineItemController.getOpportunityLineItemDetails(
      [SELECT id FROM OpportunityLineItem__c LIMIT 1].id
    );
    Test.stopTest();
  }

  @isTest
  public static void testOtherItems() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Test.startTest();

    EditOpportunityLineItemController.updateMarginInDb(
      '22',
      'Unused variable',
      string.valueOf(
        [
          SELECT Id
          FROM PricingLineItem__c
          LIMIT 1
        ]
        .id
      ),
      ''
    );
    EditOpportunityLineItemController.updateMarginInDb(
      '22',
      'Unused variable',
      '',
      ''
    );
    System.assert(
      EditOpportunityLineItemController.updateQuantityInDb(
        '22',
        'Unused variable',
        string.valueOf(
          [
            SELECT Id
            FROM PricingLineItem__c
            LIMIT 1
          ]
          .id
        )
      )
    );

    EditOpportunityLineItemController.updateCostInDb(
      '22',
      'Unused variable',
      string.valueOf(
        [
          SELECT Id
          FROM PricingLineItem__c
          LIMIT 1
        ]
        .id
      )
    );
    EditOpportunityLineItemController.updateCostInDb(
      '22',
      'Unused variable',
      ''
    );

    System.assert(
      EditOpportunityLineItemController.updateNotesAndLabelInDb(
        'Updated Notes',
        'privateNotes',
        string.valueOf(lineItem.id)
      )
    );
    System.assert(
      EditOpportunityLineItemController.updateNotesAndLabelInDb(
        '22',
        'priceLabel',
        string.valueOf(lineItem.id)
      )
    );
    System.assert(
      EditOpportunityLineItemController.updateNotesAndLabelInDb(
        '22',
        'priceLabel',
        ''
      ) == false
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetPricingFromEsp() {
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      List<OpportunityLineItem__c> lstOppLineItem = [
        SELECT Id
        FROM OpportunityLineItem__c
      ];
      String oppId = null;
      if (lstOppLineItem.size() > 0) {
        oppId = lstOppLineItem.get(0).Id;
      }
      Test.startTest();
      EditOpportunityLineItemController.getProductPricingFromEsp(oppId);
      Test.stopTest();
    } catch (Exception ex) {
    }
  }

  @isTest
  public static void testSetPricingFromEsp() {
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      List<OpportunityLineItem__c> lstOppLineItem = [
        SELECT Id
        FROM OpportunityLineItem__c
      ];
      String oppId = null;
      if (lstOppLineItem.size() > 0) {
        oppId = lstOppLineItem.get(0).Id;
      }
      Test.startTest();
      EditOpportunityLineItemController.setProductPricingFromEsp(oppId);
      Test.stopTest();
    } catch (Exception ex) {
    }
  }

  @isTest
  public static void testUpdatePricePerUnit() {
    List<OpportunityLineItem_ArtWork__c> lstOppLineItem = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
    ];
    String oppId = null;
    if (lstOppLineItem.size() > 0) {
      oppId = lstOppLineItem.get(0).OpportunityLineItem__c;
    }
    List<string> allItems = EditOpportunityLineItemController.getArtworksForPickList(
      oppId
    );
    System.assert(allItems.size() > 0);
    OpportunityLineItem_ArtWork__c art = [
      SELECT Id, Title__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];

    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    PricingLineItem__c pricinglineItem = new PricingLineItem__c();
    pricinglineItem.OpportunityLineItem__c = lineItem.Id;
    insert pricinglineItem;
    Test.startTest();
    string tempId = '';
    string totalPrice = '';
    EditOpportunityLineItemController.updatePricePerUnit(
      '22',
      'total1',
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id)
    );
    EditOpportunityLineItemController.updatePricePerUnit(
      '22',
      'total2',
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id)
    );
    EditOpportunityLineItemController.updatePricePerUnit(
      '22',
      'total3',
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id)
    );
    EditOpportunityLineItemController.updatePricePerUnit(
      '22',
      'total4',
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id)
    );
    EditOpportunityLineItemController.updatePricePerUnit(
      '22',
      'total5',
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id)
    );

    EditOpportunityLineItemController.updateTotalInDb(
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id),
      '22'
    );
    EditOpportunityLineItemController.updateClientClickInDb(
      string.valueOf([SELECT id FROM PricingLineItem__c LIMIT 1].id),
      'True',
      'showToClient1'
    );
    Test.stopTest();
  }
}
