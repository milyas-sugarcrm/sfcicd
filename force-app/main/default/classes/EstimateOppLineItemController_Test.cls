@isTest
public class EstimateOppLineItemController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();

    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
    testFactory.createExtraCharges();

    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    Test.StopTest();
  }
  @isTest
  public static void testSaveToggleState() {
    Test.startTest();
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c testLine = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.saveToggleState(pricing.Id, 'pricing', false);
    EstimateOppLineItemController.saveToggleState(
      testLine.Id,
      'extraCharge',
      false
    );
    Test.stopTest();
  }
  @isTest
  public static void testUpdateIndexMethod() {
    List<EstimateEditClass> convertToEstimateLit = new List<EstimateEditClass>();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extracharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    EstimateEditClass extraChargeObj = new EstimateEditClass();
    extraChargeObj.ObjectName = 'extraCharge';
    extraChargeObj.index = 0;
    extraChargeObj.Id = extracharge.Id;
    convertToEstimateLit.add(extraChargeObj);
    EstimateEditClass pricingObj = new EstimateEditClass();
    pricingObj.ObjectName = 'Pricing';
    pricingObj.index = 0;
    pricingObj.Id = pricing.Id;
    convertToEstimateLit.add(pricingObj);
    Test.startTest();
    EstimateOppLineItemController.updateTheIndexOfRecords(
      JSON.serialize(convertToEstimateLit),
      est.Id
    );
    EstimateOppLineItemController.syncEstimates(est.Id);
    EstimateOppLineItemController.getEstimateStatus(est.Id);
    Test.stopTest();
  }
  @isTest
  public static void testaddColorInDb() {
    System.Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String color = 'test';
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];

    List<String> sizes = new List<String>();
    sizes.add('ali');
    sizes.add('blue');
    EstimateOppLineItemController.addColorInDb(pricing.Id, sizes, est.Id);
    EstimateOppLineItemController.getSyncedAccountName(est.Id);
    System.Test.stopTest();
  }
  @isTest
  public static void testaddSizeInDb() {
    System.Test.startTest();
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String size = 'test';
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    List<String> sizes = new List<String>();
    sizes.add('ali');
    sizes.add('blue');
    EstimateOppLineItemController.addSizeInDb(pricing.Id, sizes, est.Id);
    System.Test.StopTest();
  }
  @isTest
  public static void testgetValuesForColorPiklist() {
    System.Test.startTest();
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
    EstimateOppLineItemController.getValuesForColorPiklist(pricing.Id);
    System.Test.StopTest();
  }

  @isTest
  public static void testgetValuesForSizePiklist() {
    System.Test.startTest();
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
    EstimateOppLineItemController.getValuesForSizePiklist(pricing.Id);
    System.Test.StopTest();
  }
  @isTest
  public static void testGetEstimateRelatedOpportunityLineItems() {
    System.Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.getEstimateRelatedOpportunityLineItems(
      est.Id,
      null
    );
    EstimateOppLineItemController.getOpportunityAmountValue(est.Id);
    System.Test.StopTest();
  }
  @isTest
  public static void testRemainingMethods() {
    System.Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.getCountOfEstimateOppLineItems(est.Id);
    EstimateOppLineItemController.getEstimatePreviewLink(est.Id);
    OpportunityLineItem__c test1 = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EstimateOppLineItemController.deleteOpportunityLineItemInDb(test1.Id);
    EstimateOppLineItemController.getOpportunityId(est.Id);
    EstimateOppLineItemController.getOpportunityStage(est.Id);
    EstimateOppLineItemController.getNotSyncedEstimate(est.Id);
    EstimateOppLineItemController.deleteEstimates(est.Id);
    System.Test.StopTest();
  }
  @isTest
  public static void testUpdateBreakdown() {
    System.Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extracharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'pricing',
      'name',
      pricing.Id,
      'updatedValue',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'pricing',
      'quantity',
      pricing.Id,
      '12',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'pricing',
      'retailPrice',
      pricing.Id,
      '12',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'pricing',
      'total',
      pricing.Id,
      '12',
      est.Id
    );
    System.Test.stopTest();
  }
  @isTest
  public static void testUpdateBreakdownCost() {
    Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extracharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'pricing',
      'cost',
      pricing.Id,
      '12',
      est.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdateBreakdown2() {
    Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extracharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'extraCharge',
      'name',
      extracharge.Id,
      'updatedValue',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'extraCharge',
      'quantity',
      extracharge.Id,
      '12',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'extraCharge',
      'retailPrice',
      extracharge.Id,
      '12',
      est.Id
    );
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'extraCharge',
      'total',
      extracharge.Id,
      '12',
      est.Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdateBreakdownExtraCost() {
    Test.startTest();
    Estimate__c est = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ];
    PricingLineItem__c pricing = [
      SELECT Id, Size__c, Color__c
      FROM PricingLineItem__c
      LIMIT 1
    ];
    ExtraChargesEstimate__c extracharge = [
      SELECT Id
      FROM ExtraChargesEstimate__c
      LIMIT 1
    ];
    extraCharge.Margin__c = 10;
    update extracharge;
    EstimateOppLineItemController.updateValuesOfBreakdown(
      'extraCharge',
      'cost',
      extracharge.Id,
      '12',
      est.Id
    );
    Test.stopTest();
  }
  @isTest
  public static void testCloneOpportunityLineItemInDB() {
    List<OpportunityLineItem__c> oppLineItem = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        IsProductExists__c,
        Account__c,
        Imprint_Methods__c,
        Variant_Id__c,
        Quantity_Estimate__c,
        ESPId__c,
        Currency__c,
        Private_Notes__c,
        Product__r.Name,
        Price_Label__c,
        Opportunity__c,
        SKU__c,
        Product__c,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    System.debug(oppLineItem);
    Test.startTest();
    EstimateOppLineItemController.cloneOpportunityLineItemInDB(
      oppLineItem[0].Id
    );
    Test.stopTest();
    List<OpportunityLineItem__c> oppLineItemsAfterClone = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        IsProductExists__c,
        Account__c,
        Imprint_Methods__c,
        Variant_Id__c,
        Quantity_Estimate__c,
        ESPId__c,
        Currency__c,
        Private_Notes__c,
        Product__r.Name,
        Price_Label__c,
        Opportunity__c,
        SKU__c,
        Product__c,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      WHERE Product__r.Name = :oppLineItem[0].Product__r.Name
    ];
    System.assertEquals(true, oppLineItemsAfterClone.size() > 1);
  }

  @isTest
  public static void testUpdateEstimateOppLineItem() {
    try {
      test.startTest();
      Map<String, Object> data = new Map<String, Object>();
      Map<String, Object> pricingData = new Map<String, Object>();
      Map<String, Object> extraChargeData = new Map<String, Object>();

      OpportunityLineItem__c updateProducts = [
        SELECT ID, name
        FROM OpportunityLineItem__c
        LIMIT 1
      ];
      PricingLineItem__c updatePricing = [
        SELECT ID, name
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :updateProducts.Id
        LIMIT 1
      ];
      ExtraChargesEstimate__c updateExtraCharge = [
        SELECT ID, name
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :updateProducts.Id
        LIMIT 1
      ];

      Map<String, Object> pricingJSON = new Map<String, Object>();
      pricingJSON.put('quantity', '23');
      pricingJSON.put('cost', '120');
      pricingJSON.put('retailPrice', '150');
      pricingData.put(updatePricing.id, pricingJSON);

      Map<String, Object> extraChargeJSON = new Map<String, Object>();
      extraChargeJSON.put('name', 'Fixed');
      extraChargeJSON.put('quantity', '14');
      extraChargeJSON.put('cost', '100');
      extraChargeJSON.put('retailPrice', '120');
      extraChargeData.put(updateExtraCharge.id, extraChargeJSON);

      data.put('Pricing', pricingData);
      data.put('extraCharge', extraChargeData);

      EstimateOppLineItemController.updateEstimatesOppLineItemInline(
        JSON.serialize(data)
      );
      test.stopTest();
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
    }
  }

  @isTest
  public static void testAddDefaultPricingRow() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EstimateOppLineItemController.addDefaultPricingRow(lineItem.Id);

    Test.stopTest();
  }

  public static void testUpdateQuanitiesOfrunCharges() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EstimateOppLineItemController.updateQuanitiesOfrunCharges(lineItem.Id);
    Test.stopTest();
  }
  @isTest
  public static void testGetOpportunityLineItemDetails() {
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EstimateOppLineItemController.getOpportunityLineItemDetails(lineItem.Id);

    Test.stopTest();
  }
}
