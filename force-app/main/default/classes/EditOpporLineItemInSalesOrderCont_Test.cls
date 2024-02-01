@isTest
public class EditOpporLineItemInSalesOrderCont_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.StartTest();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
    testFactory.createExtraCharges();
    Test.StopTest();
  }
  @isTest
  public static void testGetOpportunityLineItemDetails() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.getOpportunityLineItemDetails(
      lineItem.Id
    );
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      EditOpporLineItemInSalesOrderController.setProductPricingFromEsp(
        lineItem.Id
      );
      EditOpporLineItemInSalesOrderController.getProductPricingFromEsp(
        lineItem.Id
      );
    } catch (Exception ex) {
    }
    Test.stopTest();
  }
  @isTest
  public static void testGetArtworkToEdit() {
    Test.startTest();
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT Id, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.getArtworkToEdit(artwork.Id);
    Test.stopTest();
  }
  @isTest
  public static void testEditArtworkInDatabases() {
    Test.startTest();
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT id
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    String recId = artwork.Id;
    String imprintType = '';
    String proofRequired = 'test';
    String logoName = 'test';
    String logoSize = 'test';
    String logoColor = 'test';
    String repeatLogo = 'No';
    String supplierNotes = 'test';
    String documentId = '';
    String title = 'test';
    OpportunityLineItem__c testLine = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String OpportunityLineItemId = testLine.Id;
    EditOpporLineItemInSalesOrderController.editArtworkInDatabases(
      recId,
      imprintType,
      proofRequired,
      logoName,
      logoSize,
      logoColor,
      repeatLogo,
      supplierNotes,
      documentId,
      title,
      OpportunityLineItemId
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdateProductPricingInDB1() {
    PricingLineItem__c pricingToUpdate = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Estimated_Quantity__c,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        OpportunityLineItem__r.Work_Order__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateProductPricingInDb(
        '12',
        'quantity',
        (String) pricingToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'netCost', (String)pricingToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'margin', (String)pricingToUpdate.Id));
    Test.stopTest();
  }

  @isTest
  public static void testUpdateProductPricingInDB2() {
    PricingLineItem__c pricingToUpdate = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Estimated_Quantity__c,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        OpportunityLineItem__r.Work_Order__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'quantity', (String)pricingToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateProductPricingInDb(
        '12',
        'netCost',
        (String) pricingToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'margin', (String)pricingToUpdate.Id));
    Test.stopTest();
  }

  @isTest
  public static void testUpdateProductPricingInDB3() {
    PricingLineItem__c pricingToUpdate = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Estimated_Quantity__c,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        OpportunityLineItem__r.Work_Order__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'quantity', (String)pricingToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateProductPricingInDb('12', 'netCost', (String)pricingToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateProductPricingInDb(
        '12',
        'margin',
        (String) pricingToUpdate.Id
      )
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb1() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('12', 'quantity', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('39', 'netCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('46', 'margin', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('testTitle', 'title', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('30', 'dutyExtraChargesNetCost', (String)extraChargesToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        '50',
        'dutyPercentage',
        (String) extraChargesToUpdate.Id
      )
    );

    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb2() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        '12',
        'quantity',
        (String) extraChargesToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('39', 'netCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('46', 'margin', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('testTitle', 'title', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('30', 'dutyExtraChargesNetCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('50', 'dutyPercentage', (String)extraChargesToUpdate.Id));

    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb3() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('12', 'quantity', (String)extraChargesToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        '39',
        'netCost',
        (String) extraChargesToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('46', 'margin', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('testTitle', 'title', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('30', 'dutyExtraChargesNetCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('50', 'dutyPercentage', (String)extraChargesToUpdate.Id));

    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb4() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('12', 'quantity', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('39', 'netCost', (String)extraChargesToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        '46',
        'margin',
        (String) extraChargesToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('testTitle', 'title', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('30', 'dutyExtraChargesNetCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('50', 'dutyPercentage', (String)extraChargesToUpdate.Id));

    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb5() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('12', 'quantity', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('39', 'netCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('46', 'margin', (String)extraChargesToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        'testTitle',
        'title',
        (String) extraChargesToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('30', 'dutyExtraChargesNetCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('50', 'dutyPercentage', (String)extraChargesToUpdate.Id));

    Test.stopTest();
  }

  @isTest
  public static void testUpdateExtraChargesInDb6() {
    ExtraChargesEstimate__c extraChargesToUpdate = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Total__c,
        Retail_Price__c,
        Margin__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Work_Order__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    Test.startTest();
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('12', 'quantity', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('39', 'netCost', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('46', 'margin', (String)extraChargesToUpdate.Id));
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('testTitle', 'title', (String)extraChargesToUpdate.Id));
    System.assertEquals(
      true,
      EditOpporLineItemInSalesOrderController.updateExtraChargesInDb(
        '30',
        'dutyExtraChargesNetCost',
        (String) extraChargesToUpdate.Id
      )
    );
    //System.assertEquals(true, EditOpporLineItemInSalesOrderController.updateExtraChargesInDb('50', 'dutyPercentage', (String)extraChargesToUpdate.Id));

    Test.stopTest();
  }

  @isTest
  public static void testaddColorInDb() {
    Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String color = 'test';
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];

    List<String> colors = new List<String>();
    colors.add('ali');
    colors.add('blue');
    EditOpporLineItemInSalesOrderController.addColorInDb(
      pricing.Id,
      colors,
      test.id
    );
  }
  @isTest
  public static void testaddSizeInDb() {
    Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String size = 'test';
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];

    List<String> sizes = new List<String>();
    sizes.add('ali');
    sizes.add('blue');
    EditOpporLineItemInSalesOrderController.addSizeInDb(
      pricing.Id,
      sizes,
      test.id
    );
  }
  @isTest
  public static void testgetValuesForColorPiklist() {
    Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.getValuesForColorPiklist(
      test.Id,
      pricing.Id
    );
  }

  @isTest
  public static void testgetValuesForSizePiklist() {
    Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.getValuesForSizePiklist(
      test.Id,
      pricing.Id
    );
  }
  @isTest
  public static void testDeleteArtworkInDb() {
    Test.startTest();
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT Id, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.deleteArtworkInDb(artwork.Id);
    Test.stopTest();
  }
  @isTest
  public static void testDeleteExtraChargesInDb() {
    Test.startTest();
    ExtraChargesEstimate__c extraCharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.deleteExtraChargesInDb(
      extraCharge.Id
    );
    Test.stopTest();
  }
  @isTest
  public static void testAddExtraChargesInDBRuncharge() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInSalesOrderController.addExtraChargesInDB(
      lineItem.Id,
      'runCharge'
    );
    EditOpporLineItemInSalesOrderController.addExtraChargesInDB(
      lineItem.Id,
      'duty'
    );
    EditOpporLineItemInSalesOrderController.addExtraChargesInDB(
      lineItem.Id,
      'fixedCharge'
    );
    EditOpporLineItemInSalesOrderController.addExtraChargesInDB(
      lineItem.Id,
      'brokerage'
    );
    EditOpporLineItemInSalesOrderController.addExtraChargesInDB(
      lineItem.Id,
      'inboundFreight'
    );
    Test.stopTest();
  }
}
