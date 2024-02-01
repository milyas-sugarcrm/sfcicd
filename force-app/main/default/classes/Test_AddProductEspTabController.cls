@isTest
public class Test_AddProductEspTabController {
  @testsetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createProductsPrices();
    testFactory.createSalesOrder();

    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testGetSearchResultsFromESP() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());

    AddProductEspTabController.getSearchResultsFromESP(
      'searchName',
      'supplier',
      'netMin',
      'netMax',
      'market',
      'FilterCategories',
      'FilterColors',
      'FilterImprintingMethods',
      'FilterLineNames',
      'FilterPrices',
      'FilterSizes',
      'FilterSuppliers',
      'FilterMaterials',
      'FilterStates',
      'FilterAsiNumbers',
      'FilterThemes',
      'FilterTradeNames',
      'FilterShapes',
      'sortType',
      '',
      '',
      '',
      '',
      '',
      '10',
      '',
      '',
      1,
      ''
    );
    AddProductEspTabController.getSpecificProductDetails('200286593');
    //  AddProductEspTabController.getProductDetails('200286593');
    Test.stopTest();
  }

  @isTest
  public static void testverify_Updated_ESP_Pricing() {
    Product2 p2 = [SELECT id FROM Product2 LIMIT 1];
    ESPProduct espProductObj2 = new ESPProduct();
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());

    AddProductEspTabController.verify_Updated_ESP_Pricing(
      null,
      espProductObj2,
      p2
    );

    Test.stopTest();
  }

  @isTest
  public static void testFetchImage() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    Set<String> setImageLink = new Set<String>();
    setImageLink.add('test.com');
    Opportunity opp = [
      SELECT id
      FROM opportunity
      LIMIT 1
    ];
    Product2 prod = new Product2();
    prod.Name = 'Test Prod';
    prod.Product_Cost__c = 22;
    prod.Sales_Price_Rate__c = 22;
    prod.Sales_Tax_Category__c = 'Nontaxable';
    prod.Purchasing_Info__c = 'Info';
    prod.Supplier__c = 'Alphabroder';
    prod.Product_Supplier_Code__c = 'Code';
    prod.Net_Price__c = 22;
    insert prod;
    // AddProductEspTabController.fetchImageAndStore(setImageLink,opp.id,prod.id);
    Test.stopTest();
  }

  @isTest
  public static void testAddProductPresentationEsp() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    Opportunity opp = [
      SELECT id
      FROM opportunity
      LIMIT 1
    ];
    String oppId = opp.id;
    AddProductEspTabController.createOpportunityLineItemEsp(
      '5074907',
      oppId,
      'testVariantId',
      null,
      'Opportunity',
      'test',
      'Test',
      'Test',
      'Brown',
      'S'
    );

    List<Product2> testProduct = [
      SELECT id, CommonSku_Id__c, Sales_Tax_Category__c
      FROM Product2
      WHERE CommonSku_Id__c = 5074907
    ];
    List<Pricing_Product__c> pricingProduct = [
      SELECT Net_Cost__c
      FROM Pricing_Product__c
    ];
    List<Color_Product__c> colorProduct = [
      SELECT Name, Color__c
      FROM Color_Product__c
    ];
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT isProductFromESP__c, ESPId__c, Currency__c
      FROM OpportunityLineItem__c
      WHERE ESPId__c = 5074907
    ];
    Test.stopTest();
  }

  /* @isTest
    public static void testAddProductEstimateItemEsp()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class , new MockTestResponse()); 
        Opportunity opp = [SELECT id 
                           FROM opportunity 
                           LIMIT 1];
        String oppId = opp.id;
        String estimateId = null;
        List<Estimate__c>lstEstimate = [SELECT id 
                                        FROM Estimate__c];
        if(lstEstimate.size()>0){
            estimateId = lstEstimate.get(0).id;
        }
        AddProductEspTabController.createOpportunityLineItemEsp('550396415', oppId , '840880292',estimateId,'Opportunity');
        
        List<Product2> testProduct = [select id,CommonSku_Id__c,Sales_Tax_Category__c FROM Product2 WHERE CommonSku_Id__c = 5074907];        
        List<Pricing_Product__c> pricingProduct = [SELECT Net_Cost__c 
                                                   FROM Pricing_Product__c];        
        List<Color_Product__c> colorProduct = [SELECT Name,Color__c 
                                               FROM Color_Product__c];        
        List<OpportunityLineItem__c> oppLineItems = [SELECT isProductFromESP__c,ESPId__c,Currency__c 
                                                     FROM OpportunityLineItem__c 
                                                     WHERE ESPId__c = 5074907];
        Test.stopTest(); 
         Set<String> setImageLink = new Set<String>();
 
        AddProductEspTabController.createOpportunityLineItemEsp('550396415', oppId , '840880292',estimateId,'Opportunity');
    } 
    */
  @isTest
  public static void testGetVariants() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());

    AddProductEspTabController.getVariants('testId');

    AddProductEspTabController.getVars('testId');
    //Assertions in this function to be placed in next milestone when variant functionality is completed
    Test.stopTest();
  }

  @isTest
  public static void testGetVariantsUpdated() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    ESPProduct_Test.testParse();
    AddProductEspTabController.getVariants('553105201');
    //Assertions in this function to be placed in next milestone when variant functionality is completed

    Test.stopTest();
  }

  @isTest
  public static void Test1() {
    //getOpportunityId
    Test.startTest();
    Opportunity opp1 = [SELECT id FROM Opportunity LIMIT 1];
    System.assertEquals(
      (String) opp1.id,
      AddProductEspTabController.getOpportunityId((String) opp1.id)
    );
    Estimate__c est = [SELECT id, Opportunity__c FROM Estimate__c LIMIT 1];
    System.assertEquals(
      (String) est.Opportunity__c,
      AddProductEspTabController.getOpportunityId((String) est.id)
    );
    AddProductEspTabController.sendEmail('subject', 'body');
    Test.stopTest();
  }
  @isTest
  public static void Test2() {
    //getOpportunityId
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    AddProductEspTabController.getImageFromUrl('testURL');
    Product2 prd = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Estimate__c est = [SELECT id, Opportunity__c FROM Estimate__c LIMIT 1];
    Order order = [SELECT id FROM Order LIMIT 1];
    System.assertEquals(
      true,
      AddProductEspTabController.reportBackToASI(
        (String) opp.Id,
        (String) est.Id,
        'adPosition'
      )
    );
    //System.assertEquals(true,AddProductEspTabController.createOpportunityLineItemEsp('112233', (String)opp.Id, (String)opp.Id, (String)est.Id, (String)est.Id, 'adPosition', 'Opportunity'));
    AddProductEspTabController.createOpportunityLineItemEsp(
      '112233',
      (String) opp.Id,
      '841055601',
      (String) est.Id,
      (String) est.Id,
      'adPosition',
      'Estimate',
      null,
      'Test',
      'Test'
    );
    System.assertEquals(
      false,
      AddProductEspTabController.createOpportunityLineItemEsp(
        (String) prd.Id,
        (String) opp.Id,
        (String) opp.Id,
        (String) est.Id,
        (String) est.Id,
        'adPosition',
        'Opportunity',
        null,
        'Test',
        'Test'
      )
    );
    System.assertEquals(
      false,
      AddProductEspTabController.createOpportunityLineItemEsp(
        (String) prd.Id,
        (String) opp.Id,
        (String) opp.Id,
        (String) est.Id,
        (String) est.Id,
        'adPosition',
        'Estimate',
        null,
        'Test',
        'Test'
      )
    );
    AddProductEspTabController.createOpportunityLineItemEsp(
      '123456',
      (String) opp.Id,
      '1234567',
      null,
      null,
      'adPosition',
      'SalesOrder',
      (String) order.id,
      'Test',
      'Test'
    );
    AddProductEspTabController.createOpportunityLineItemEsp(
      '112233',
      (String) opp.Id,
      '841055601',
      (String) est.Id,
      (String) est.Id,
      'adPosition',
      'SalesOrder',
      null,
      'Test',
      'Test'
    );
    List<String> imageLink = new List<String>();
    imageLink.add('tests');
    Set<String> setStr = new Set<String>();
    setStr.add('test');
    AddProductEspTabController.fetchImagesAndStore(imageLink, opp.Id, est.Id);
    AddProductEspTabController.fetchImageAndStore(setStr, opp.Id, est.Id);
    Test.stopTest();
  }
  @isTest
  public static void Test3() {
    //getOpportunityId
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new Test_MockCallOut());
    AddProductEspTabController.getImageFromUrl('testURL');
    Product2 prd = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Estimate__c est = [SELECT id, Opportunity__c FROM Estimate__c LIMIT 1];
    Order order = [SELECT id FROM Order LIMIT 1];
    System.debug('---order id -----' + order.id);
    System.assertEquals(
      true,
      AddProductEspTabController.reportBackToASI(
        (String) opp.Id,
        (String) est.Id,
        'adPosition'
      )
    );
    //System.assertEquals(true,AddProductEspTabController.createOpportunityLineItemEsp('112233', (String)opp.Id, (String)opp.Id, (String)est.Id, (String)est.Id, 'adPosition', 'Opportunity'));
    AddProductEspTabController.createOpportunityLineItemEsp(
      '112233',
      (String) opp.Id,
      '841055601',
      (String) est.Id,
      (String) est.Id,
      'adPosition',
      'SalesOrder',
      null,
      'Test',
      'Test'
    );
    System.assertEquals(
      false,
      AddProductEspTabController.createOpportunityLineItemEsp(
        (String) prd.Id,
        (String) opp.Id,
        (String) opp.Id,
        (String) est.Id,
        (String) est.Id,
        'adPosition',
        'SalesOrder',
        null,
        'Test',
        'Test'
      )
    );

    Test.stopTest();
  }
  @isTest
  public static void testGetProductServiceID() {
    Test.startTest();
    Account acc1 = [SELECT Id, Primary_Category__c FROM Account LIMIT 1];
    acc1.Primary_Category__c = 'Apparel';
    update acc1;
    AddProductEspTabController.getProductServiceId(acc1.Id);

    Account acc2 = [SELECT Id, Primary_Category__c FROM Account LIMIT 1];
    acc2.Primary_Category__c = 'Decorator';
    update acc2;
    AddProductEspTabController.getProductServiceId(acc2.Id);

    // Account acc3 = [SELECT Id,Primary_Category__c from Account Limit 1];
    // acc3.Primary_Category__c = 'Design Services';
    // update acc3;
    // AddProductEspTabController.getProductServiceId(acc3.Id);

    Account acc4 = [SELECT Id, Primary_Category__c FROM Account LIMIT 1];
    acc4.Primary_Category__c = 'Trade Show & Signage';
    update acc4;
    AddProductEspTabController.getProductServiceId(acc4.Id);

    Account acc5 = [SELECT Id, Primary_Category__c FROM Account LIMIT 1];
    acc5.Primary_Category__c = 'Promotional Products';
    update acc5;
    AddProductEspTabController.getProductServiceId(acc5.Id);

    //Account acc6 = [SELECT Id,Primary_Category__c from Account Limit 1];
    //acc6.Primary_Category__c = 'Fulfillment';
    //update acc6;
    //AddProductEspTabController.getProductServiceId(acc6.Id);

    Test.stopTest();
  }
}
