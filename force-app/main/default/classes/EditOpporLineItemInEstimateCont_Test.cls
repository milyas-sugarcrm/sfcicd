@isTest
public class EditOpporLineItemInEstimateCont_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
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
    EditOpporLineItemInEstimateController.getOpportunityLineItemDetails(
      lineItem.Id
    );
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      EditOpporLineItemInEstimateController.setProductPricingFromEsp(
        lineItem.Id
      );
      EditOpporLineItemInEstimateController.getProductPricingFromEsp(
        lineItem.Id
      );
    } catch (Exception ex) {
    }
    Test.stopTest();
  }
  @isTest
  public static void testDeleteBreakdownInDb() {
    Test.startTest();
    PricingLineItem__c pricingRecord = [
      SELECT
        OpportunityLineItem__c,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Show_To_Client__c,
        Total__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c,
        Default__c,
        Id
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.deleteBreakdownInDb(pricingRecord.Id);
    Test.stopTest();
  }
  @isTest
  public static void testDeleteArtworkInDb() {
    Test.startTest();
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT Id, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.deleteArtworkInDb(artwork.Id);
    Test.stopTest();
  }
  @isTest
  public static void testAddArtworkLocationInEstimate() {
    Test.startTest();
    OpportunityLineItem__c oppId = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addArtworkLocationInEstimate(
      oppId.Id
    );
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
    EditOpporLineItemInEstimateController.getArtworkToEdit(artwork.Id);
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
    OpportunityLineItem__c testLineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String OpportunityLineItemId = testLineItem.Id;
    EditOpporLineItemInEstimateController.editArtworkInDatabases(
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
  public static void testUpdateStatusOfExtraCharges() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extraCharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updateStatusOfExtraCharges(
      lineItem.Id,
      extraCharge.Id,
      'test'
    );
    Test.stopTest();
  }
  @isTest
  public static void testAddDefaultPricingRow() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addDefaultPricingRow(lineItem.Id);

    Test.stopTest();
  }

  @isTest
  public static void testUpdatePricingInDb() {
    Test.startTest();
    PricingLineItem__c pricing = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Quantity__c,
        Retail_Price__c,
        Net_Cost__c,
        Margin__c,
        Total__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updatePricingInDb(
      50,
      'quantity',
      pricing.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdatePricingInDbNetCost() {
    Test.startTest();
    PricingLineItem__c pricing = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Quantity__c,
        Retail_Price__c,
        Net_Cost__c,
        Margin__c,
        Total__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updatePricingInDb(
      50,
      'netCost',
      pricing.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdatePricingInDbMargin() {
    Test.startTest();
    PricingLineItem__c pricing = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Quantity__c,
        Retail_Price__c,
        Net_Cost__c,
        Margin__c,
        Total__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updatePricingInDb(
      50,
      'margin',
      pricing.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdatePricingInDbRetailPrice() {
    Test.startTest();
    PricingLineItem__c pricing = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Quantity__c,
        Retail_Price__c,
        Net_Cost__c,
        Margin__c,
        Total__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updatePricingInDb(
      50,
      'retailPrice',
      pricing.Id
    );
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
    EditOpporLineItemInEstimateController.deleteExtraChargesInDb(
      extraCharge.Id
    );
    Test.stopTest();
  }
  @isTest
  public static void testDeleteWarningInDb() {
    Test.startTest();
    WarningsOpportunityLineItem__c warningToDelete = [
      SELECT Id, Warning__c
      FROM WarningsOpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.deleteWarningInDb(warningToDelete.Id);
    Test.stopTest();
  }
  @isTest
  public static void testAddExtraChargesInDBForArtwork() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT id
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addExtraChargesInDBForArtwork(
      lineItem.Id,
      'runCharge',
      artwork.Id
    );
    EditOpporLineItemInEstimateController.addExtraChargesInDBForArtwork(
      lineItem.Id,
      'fixedCharge',
      artwork.Id
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
    EditOpporLineItemInEstimateController.addExtraChargesInDB(
      lineItem.Id,
      'runCharge'
    );
    Test.stopTest();
  }

  @isTest
  public static void testAddExtraChargesInDBFixedCharge() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addExtraChargesInDB(
      lineItem.Id,
      'fixedCharge'
    );
    Test.stopTest();
  }
  @isTest
  public static void testAddExtraChargesInDBBrokerage() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addExtraChargesInDB(
      lineItem.Id,
      'brokerage'
    );
    Test.stopTest();
  }
  @isTest
  public static void testAddExtraChargesInDBInBound() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addExtraChargesInDB(
      lineItem.Id,
      'inboundFreight'
    );
    Test.stopTest();
  }

  @isTest
  public static void testAddExtraChargesInDBDuty() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addExtraChargesInDB(
      lineItem.Id,
      'duty'
    );
    Test.stopTest();
  }
  @isTest
  public static void testUpdateQuanitiesOfrunCharges() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updateQuanitiesOfrunCharges(
      lineItem.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testAddWarningInDB() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.addWarningInDB(lineItem.Id);
    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfDutyExtraChargesInDbTitle() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfDutyExtraChargesInDb(
      'lineItem',
      'title',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfDutyExtraChargesInDbNetCost() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfDutyExtraChargesInDb(
      '12',
      'netCost',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfDutyExtraChargesInDbMargin() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfDutyExtraChargesInDb(
      '12',
      'margin',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfDutyExtraChargesInDbRetailPrice() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfDutyExtraChargesInDb(
      '12',
      'retailPrice',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfDutyExtraChargesInDbPercentage() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfDutyExtraChargesInDb(
      '12',
      'percentage',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }

  @isTest
  public static void testUpdateValuesOfExtraChargesInDb() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfExtraChargesInDb(
      'lineItem',
      'title',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfExtraChargesInDbNetCost() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfExtraChargesInDb(
      '12',
      'netCost',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfExtraChargesInDbMargin() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfExtraChargesInDb(
      '12',
      'margin',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfExtraChargesInDbRetailPrice() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfExtraChargesInDb(
      '12',
      'retailPrice',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateValuesOfExtraChargesInDbQuantity() {
    Test.startTest();
    ExtraChargesEstimate__c extraChargesRecord = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Charge_Type__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Net_Cost__c,
        Default__c
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];

    EditOpporLineItemInEstimateController.updateValuesOfExtraChargesInDb(
      '12',
      'quantity',
      extraChargesRecord.Id
    );

    Test.stopTest();
  }
  @isTest
  public static void testUpdateNotesAndLabelInDb() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpporLineItemInEstimateController.updateNotesAndLabelInDb(
      'abc',
      'privateNotes',
      lineItem.Id
    );
    EditOpporLineItemInEstimateController.updateNotesAndLabelInDb(
      'abc',
      'description',
      lineItem.Id
    );
    EditOpporLineItemInEstimateController.updateNotesAndLabelInDb(
      'abc',
      'productName',
      lineItem.Id
    );
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
    EditOpporLineItemInEstimateController.addColorInDb(
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
    EditOpporLineItemInEstimateController.addSizeInDb(
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
    EditOpporLineItemInEstimateController.getValuesForColorPiklist(
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
    EditOpporLineItemInEstimateController.getValuesForSizePiklist(
      test.Id,
      pricing.Id
    );
  }
}
