@isTest
public class Test_QuickbookApiCrud {
  @testSetup
  public static void createData() {
    TestFactory factory = new TestFactory();
    //   Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    factory.createConfiguration();

    List<QB_Credentials__c> qbcList = new List<QB_Credentials__c>();
    QB_Credentials__c qbc = new QB_Credentials__c();
    qbc.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadf';
    qbc.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbc.RealMId__c = '5165118946516322';
    qbc.Synced_Account_Title__c = 'Team Phun';
    qbcList.add(qbc);
    QB_Credentials__c qbc2 = new QB_Credentials__c();
    qbc2.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadg';
    qbc2.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbc2.RealMId__c = '5165118946516322';
    qbc2.Synced_Account_Title__c = 'Team Phun';
    qbcList.add(qbc2);
    QB_Credentials__c qbc3 = new QB_Credentials__c();
    qbc3.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadg';
    qbc3.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbc3.RealMId__c = '5165118946516322';
    qbc3.Synced_Account_Title__c = 'Phun for All';
    qbcList.add(qbc3);
    insert qbcList;

    Sales_Term__c c = new Sales_Term__c();
    c.Name = 'Net30';
    c.Type__c = 'STANDARD';
    c.Active__c = true;
    c.QBO_Account__c = 'Team Phun';
    c.sparse__c = false;
    c.Id__c = '1';
    c.SyncToken__c = '0';
    c.DueDays__c = 30;
    c.DiscountDays__c = 0;
    insert c;
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.Art_Approval_Email__c = 'testArt@gmail.com.invalid';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    //  acc.QB_Record_ID__c = '1';
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    acc.QuickBooks_Accounts__c = 'Team Phun';
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();
    insert acc;
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Presentation';
    update opp;

    Quickbooks_Accounts_Configurations__c config = new Quickbooks_Accounts_Configurations__c();
    config.Name = 'test 1';
    config.QB_Access_token_End_Point__c = 'asdsadasdasdsadas';
    config.QB_API_End_Point__c = 'asdasdasddsadasdas';
    config.QB_Authorization_End_Point__c = 'asdasdsadasdasdsada';
    config.QB_Authorization_Scope__c = 'asdasdasdsa';
    config.QB_Client_Id__c = 'asdasdasdasdas';
    config.QB_Client_Secret__c = 'asdasdas';
    config.QB_ID__c = '123';
    config.QBO_Custom_Field_1__c = 'asdasdsadsada';
    config.QBO_Custom_Field_1_Id__c = '1';
    config.QB_Redirect_URI__c = 'asdasdasdas';
    config.Quickbooks_Account_Tittle__c = 'Phun for All';
    config.Service_Id_Breakdown__c = 'asdasdasdsada';
    config.Service_Id_Brokerage__c = 'asdasdas';
    config.Service_Id_Duty__c = 'asdsadsadas';
    config.Service_Id_FixedCharges__c = 'asdasdasdas';
    config.Service_Id_InboundFreight__c = 'asdasdasda';
    config.Service_Id_RunCharges__c = 'asdsadas';
    insert config;

    Account accPFA = new Account();
    accPFA.Name = 'PFA Customer Accont';
    accPFA.Billing_Email__c = 'test@test.com';
    accPFA.BillingStreet = 'Test Billing Address';
    accPFA.QuickBooks_Accounts__c = 'Phun for All';
    accPFA.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('PFA Customer Account')
      .getRecordTypeId();
    insert accPFA;

    PFA_Event_Billing__c newBillingRecord = new PFA_Event_Billing__c(
      Name = 'Test Event Billing Record',
      Account__c = [
        SELECT Id, Name
        FROM Account
        WHERE Name = 'PFA Customer Accont'
        LIMIT 1
      ]
      .Id,
      Is_Initial_Deposit_Billing__c = true,
      QBO_Invoice_Number__c = '',
      Bill_Date__c = Date.today(),
      Bill_Due_Date__c = Date.today().addDays(30),
      Payment_Link__c = 'https://example.com/payment-link',
      Total_Amount__c = 375.00,
      QBO_Invoice_Id__c = '',
      Balance_Due__c = 375.00,
      Quickbooks_Instance__c = 'Phun for All',
      Updated_From_QBO_Scheduler__c = false
    );

    insert newBillingRecord;

    QBO_Details__c qbo = new QBO_Details__c();
    qbo.QBO_Account__c = 'Team Phun';
    qbo.Id_Type__c = 'Account';
    qbo.Account__c = acc.Id;
    qbo.QB_Id__c = '123';
    qbo.Salesforce_Record_Id__c = acc.Id;
    insert qbo;
    QBO_Details__c qbo2 = new QBO_Details__c();
    qbo2.QBO_Account__c = 'Team Phun';
    qbo2.Id_Type__c = 'Account';
    qbo2.Account__c = acc.Id;
    qbo2.QB_Id__c = '123';
    qbo2.Salesforce_Record_Id__c = acc.Id;
    insert qbo2;
    QBO_Details__c qbo3 = new QBO_Details__c();
    qbo3.QBO_Account__c = 'Phun for All';
    qbo3.Id_Type__c = 'Account';
    qbo3.Account__c = accPFA.Id;
    qbo3.QB_Id__c = '123';
    qbo3.Salesforce_Record_Id__c = accPFA.Id;
    insert qbo3;

    factory.createPriceBookEntry();

    Estimate__c estimate = new Estimate__c();
    estimate.In_Hands_Date__c = Date.today();
    estimate.Terms__c = 'Prepay';
    estimate.Customer_PO__c = '4';
    estimate.Opportunity__c = opp.id;
    estimate.Selected_Quickbook_Instance__c = 'Team Phun';

    insert estimate;
    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;

    estimate.Customer_PO__c = '5';
    update estimate;

    Order order = new Order();
    order.OpportunityId = opp.id;
    order.Invoice_Number__c = 'SalesOrder-' + opp.id;
    order.Status = '01_-_Waiting_for_Client_Payment';
    order.EffectiveDate = system.today();
    order.Invoice_Terms__c = 'Credit Card';
    order.Primary_Contact__c = opp.Contact__c;
    order.AccountId = opp.AccountId;
    order.Invoice_Value__c = 0;
    order.Invoice_Tax__c = 0;
    order.Invoice_Discount__c = 0;
    order.Invoice_Due_Date__c = system.today();
    order.Invoice_Total__c = 0;
    order.Invoice_Estimated_Ship_Date__c = '';
    order.Quickbooks_Instance__c = 'Team Phun';
    order.QbId__c = '123';
    //  order.Pric=pricebookId;
    insert order;

    OpportunityLineItem__c oppLineItem = new OpportunityLineItem__c();
    oppLineItem.Estimate__c = estimate.Id;
    oppLineItem.Work_Order__c = order.id;
    oppLineItem.Quantity_Estimate__c = 10;
    oppLineItem.Total_QBO__c = 13;
    insert oppLineItem;

    PricingLineItem__c price = new PricingLineItem__c();
    price.OpportunityLineItem__c = oppLineItem.id;
    price.Total__c = 54;
    price.Retail_Price__c = 2;
    price.Quantity__c = 2;
    price.Color__c = 'test';
    price.Size__c = 'test';
    price.Display__c = true;
    price.Default__c = false;
    price.Estimated_Quantity__c = 2;
    insert price;

    List<ExtraChargesEstimate__c> charges = new List<ExtraChargesEstimate__c>();
    ExtraChargesEstimate__c extraCharges = new ExtraChargesEstimate__c();
    extraCharges.Charge_Type__c = 'AdditionalCost_FixedCharge';
    extraCharges.Quantity__c = 12;
    extraCharges.OpportunityLineItem__c = oppLineItem.Id;
    extraCharges.Title__c = 'test';
    extraCharges.Retail_Price__c = 25;
    charges.add(extraCharges);

    ExtraChargesEstimate__c extraCharges2 = new ExtraChargesEstimate__c();
    extraCharges2.Charge_Type__c = 'AdditionalCost_RunCharge';
    extraCharges2.Quantity__c = 12;
    extraCharges2.OpportunityLineItem__c = oppLineItem.Id;
    extraCharges2.Title__c = 'test';
    extraCharges2.Retail_Price__c = 25;
    charges.add(extraCharges2);

    ExtraChargesEstimate__c extraCharges3 = new ExtraChargesEstimate__c();
    extraCharges3.Charge_Type__c = 'InternationalCost_InboundFreight';
    extraCharges3.Quantity__c = 12;
    extraCharges3.OpportunityLineItem__c = oppLineItem.Id;
    extraCharges3.Title__c = 'test';
    extraCharges3.Retail_Price__c = 25;
    charges.add(extraCharges3);

    ExtraChargesEstimate__c extraCharges4 = new ExtraChargesEstimate__c();
    extraCharges4.Charge_Type__c = 'InternationalCost_Brokerage';
    extraCharges4.Quantity__c = 12;
    extraCharges4.OpportunityLineItem__c = oppLineItem.Id;
    extraCharges4.Title__c = 'test';
    extraCharges4.Retail_Price__c = 25;
    charges.add(extraCharges4);

    ExtraChargesEstimate__c extraCharges5 = new ExtraChargesEstimate__c();
    extraCharges5.Charge_Type__c = 'InternationalCost_Duty';
    extraCharges5.Quantity__c = 12;
    extraCharges5.OpportunityLineItem__c = oppLineItem.Id;
    extraCharges5.Title__c = 'test';
    extraCharges5.Retail_Price__c = 25;
    charges.add(extraCharges5);
    insert charges;

    TestFactory testFactory = new TestFactory(1);
    testFactory.createPriceBookEntry();
    String pricebookId = [SELECT id FROM PriceBookEntry LIMIT 1].id;
    Test.startTest();
    testFactory.addAddressRelatedData();
    testFactory.createProducts();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
    Test.stopTest();
  }

  @isTest
  public static void testSendCustomer() {
    //  Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account();
    acc.Name = 'Testasdda Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Art_Approval_Email__c = 'testArt@gmail.com.invalid';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();

    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    insert acc;

    QBO_Details__c qbo = new QBO_Details__c();
    qbo.QBO_Account__c = 'Team Phun';
    qbo.Id_Type__c = 'Account';
    qbo.Account__c = acc.Id;
    qbo.QB_Id__c = '123';
    qbo.Salesforce_Record_Id__c = acc.Id;

    Test.startTest();

    insert qbo;
    Test.stopTest();
    acc = [SELECT Id FROM Account WHERE Id = :acc.Id];
  }
  @isTest
  public static void testSendVendor() {
    //  Test.setMock(HttpCalloutMock.Class, new MockTestResponse());

    Account acc = new Account();
    acc.Name = 'Testasdsadas Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.QuickBooks_Accounts__c = 'Team Phun;Phun for All';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Vendor Account')
      .getRecordTypeId();
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    insert acc;
    Test.stopTest();
    acc = [SELECT Id FROM Account WHERE Id = :acc.Id];
  }
  @isTest
  public static void testCreateEstimateWithOppLineItems() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Account acc = [
      SELECT id, QuickBooks_Accounts__c
      FROM Account
      WHERE QuickBooks_Accounts__c = :'Team Phun'
      LIMIT 1
    ];

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Presentation';
    update opp;

    Estimate__c estimate = new Estimate__c();
    estimate.Opportunity__c = opp.Id;
    estimate.Status__c = 'Converted';
    estimate.In_Hands_Date__c = system.today();
    estimate.Selected_Quickbook_Instance__c = 'Team Phun';
    estimate.Estimate_QB_Id__c = '63';
    estimate.Terms__c = 'Credit Card';
    insert estimate;
    OpportunityLineItem__c opplineItems = [
      SELECT Id, Estimate__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    opplineItems.Estimate__c = estimate.Id;
    update opplineItems;

    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;

    //   System.assert(est.Estimate_Number__c == null);

    opp.Estimated_Amount__c = 88;
    update opp;
    Set<Id> OppoIds = new Set<Id>();
    Set<Id> estimateId = new Set<Id>();
    OppoIds.add(opp.Id);
    estimateId.add(estimate.Id);
    QuickbookApiCrud.createEstimate(OppoIds, estimateId, 'Team Phun');

    QuickbookApiCrud.updateEstimate(OppoIds, estimateId, 'Team Phun');

    Test.stopTest();
  }
  @isTest
  public static void testAccountRelatedRecords() {
    // getAccountJson(Account acc,String objectType,String qbId,String syncToken,String accountTitle)
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Account acc = [
      SELECT
        Id,
        IsDeleted,
        Fax,
        MasterRecordId,
        Name,
        Type,
        RecordTypeId,
        ParentId,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        BillingLatitude,
        BillingLongitude,
        BillingGeocodeAccuracy,
        BillingAddress,
        ShippingStreet,
        ShippingCity,
        ShippingState,
        ShippingPostalCode,
        ShippingCountry,
        ShippingLatitude,
        ShippingLongitude,
        ShippingGeocodeAccuracy,
        ShippingAddress,
        Phone,
        AccountNumber,
        Website,
        PhotoUrl,
        Industry,
        NumberOfEmployees,
        Description,
        OwnerId,
        CreatedDate,
        CreatedById,
        LastModifiedDate,
        LastModifiedById,
        SystemModstamp,
        LastActivityDate,
        LastViewedDate,
        LastReferencedDate,
        Jigsaw,
        JigsawCompanyId,
        AccountSource,
        SicDesc,
        Taxable__c,
        Exemption_Details__c,
        ASI_Number__c,
        Billing_Contact__c,
        Default_Tax_Code__c,
        Facebook__c,
        Instagram__c,
        Linkedin__c,
        Notes__c,
        Payment_Terms__c,
        Preferred_Payment_Method__c,
        QB_Record_ID__c,
        Billing_Email__c,
        Tags__c,
        Tax_Exemption_Code__c,
        Vendor_Rating__c,
        Sub_Category__c,
        AIM_Supplier__c,
        Third_Party_Shipping__c,
        Art_Approval_Email__c,
        Payment_Method__c,
        Sales_Terms__c,
        Tax_Code__c,
        Imported__c,
        Lead_Id__c,
        Copy_to_Shipping_Address__c,
        Account_Owner_Email__c,
        QuickBooks_Accounts__c,
        QBO_Accounts_Count__c,
        Billing_Contact__r.FirstName,
        Billing_Contact__r.LastName,
        Billing_Contact__r.MobilePhone,
        Billing_Contact__r.Phone
      FROM Account
      WHERE QuickBooks_Accounts__c = :'Team Phun'
      LIMIT 1
    ];
    QuickbookApiCrud.getAccountJson(acc, 'Customer', '123', '2', 'Team Phun');

    Test.stopTest();
  }
  @isTest
  public static void testOtherFunctions() {
    Test.startTest();
    QuickbookApiCrud.authenticationErrorEmail('test', 'test', 'Test');
    QuickbookApiCrud.customErrorEmail('test', null, 'asd', 'asd');
    Test.stopTest();
  }
  @isTest
  public static void testCreateEstimate() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Account acc = [
      SELECT id, QuickBooks_Accounts__c
      FROM Account
      WHERE QuickBooks_Accounts__c = :'Team Phun'
      LIMIT 1
    ];

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Presentation';
    update opp;

    Estimate__c estimate = new Estimate__c();
    estimate.Opportunity__c = opp.Id;
    estimate.Status__c = 'Converted';
    estimate.In_Hands_Date__c = system.today();
    estimate.Selected_Quickbook_Instance__c = 'Team Phun';
    estimate.Estimate_QB_Id__c = '63';
    estimate.Terms__c = 'Credit Card';
    insert estimate;
    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;

    //   System.assert(est.Estimate_Number__c == null);

    opp.Estimated_Amount__c = 88;
    update opp;
    Set<Id> OppoIds = new Set<Id>();
    Set<Id> estimateId = new Set<Id>();
    OppoIds.add(opp.Id);
    estimateId.add(estimate.Id);
    QuickbookApiCrud.createEstimate(OppoIds, estimateId, 'Team Phun');

    QBO_Details__c qbo = new QBO_Details__c();
    qbo.QBO_Account__c = 'Team Phun';
    qbo.Id_Type__c = 'Estimate';
    qbo.Account__c = acc.Id;
    qbo.QB_Id__c = '43612';
    qbo.Salesforce_Record_Id__c = estimate.Id;
    insert qbo;

    QuickbookApiCrud.updateEstimate(OppoIds, estimateId, 'Team Phun');
    Order order = [SELECT id FROM Order LIMIT 1];
    PurchaseOrder_LineItem__c po = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    Set<Id> poIds = new Set<Id>();
    poIds.add(po.id);
    Set<Id> orderIds = new Set<Id>();
    orderIds.add(order.id);
    Map<Id, String> accountNames = new Map<Id, String>();
    accountNames.put(order.id, 'Team Phun');
    // QuickbookApiCrud.createInvoice(order.id,'Team Phun');
    //QuickbookApiCrud.createInvoice(order.id,'Team Phun');
    QuickbookApiCrud.createInvoiceUpdated(orderIds, accountNames);
    accountNames.put(order.id, 'Team Phun');
    QuickbookApiCrud.createInvoiceUpdated(orderIds, accountNames);
    accountNames = new Map<Id, String>();
    accountNames.put(po.id, 'Team Phun');
    QuickbookApiCrud.createPurchaseOrder(poIds, accountNames);
    QuickbookApiCrud.updatePurchaseOrder(poIds, accountNames);
    accountNames.put(po.id, 'Team Phun');
    QuickbookApiCrud.createPurchaseOrder(poIds, accountNames);
    QuickbookApiCrud.updatePurchaseOrder(poIds, accountNames);
    QuickbookApiCrud.deleteBillfromQBO(po.id, '123', '111', accountNames);
    Test.stopTest();
  }
  @isTest
  public static void testGetAccountQBOIdMap() {
    Test.startTest();
    List<Account> accountsList = [
      SELECT id, QuickBooks_Accounts__c
      FROM Account
      WHERE QuickBooks_Accounts__c = :'Team Phun'
    ];
    Set<Id> accountIds = new Set<Id>();
    for (Account acc : accountsList) {
      accountIds.add(acc.Id);
    }
    QuickbookApiCrud.getAccountQBOIdMap(accountIds, 'Team Phun');
    QuickbookApiCrud.syncCustomer(accountIds, 'Team Phun');
    QuickbookApiCrud.syncVendor(accountIds, 'Team Phun');
    Test.stopTest();
  }

  @isTest
  public static void testUpdateEstimate() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Opportunity opp = [
      SELECT
        Id,
        IsDeleted,
        StageName,
        Amount,
        Description,
        Probability,
        CloseDate,
        Type,
        Name
      FROM Opportunity
      LIMIT 1
    ];
    Set<Id> oppIds = new Set<Id>();
    Set<Id> estimateIds = new Set<Id>();
    oppIds.add(opp.Id);

    Estimate__c est = [
      SELECT Id, Estimate_Number__c, Estimate_QB_Id__c
      FROM Estimate__c
      LIMIT 1
    ];
    est.Estimate_QB_Id__c = '43600';
    update est;
    estimateIds.add(est.Id);

    QuickbookApiCrud.updateEstimate(oppIds, estimateIds, 'Team Phun');

    Test.stopTest();
  }

  @isTest
  public static void testGetSyncToken() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Set<String> estimateIds = new Set<String>();
    estimateIds.add('154');
    System.assert(
      QuickbookApiCrud.getSyncTokenMap(estimateIds, 'Team Phun') != null
    );
    Test.stopTest();
  }

  @isTest
  public static void testUpdateInvoice() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Opportunity opp = [
      SELECT
        Id,
        IsDeleted,
        StageName,
        Amount,
        Description,
        Probability,
        CloseDate,
        Type,
        Name
      FROM Opportunity
      LIMIT 1
    ];
    Set<Id> oppIds = new Set<Id>();
    Set<Id> estimateIds = new Set<Id>();
    oppIds.add(opp.Id);

    Estimate__c est = [
      SELECT Id, Estimate_Number__c, Estimate_QB_Id__c
      FROM Estimate__c
      LIMIT 1
    ];
    est.Estimate_QB_Id__c = '43600';
    update est;
    estimateIds.add(est.Id);
    Order order = [SELECT Id FROM Order LIMIT 1];
    Set<Id> orderIds = new Set<Id>();
    orderIds.add(order.id);
    Map<Id, String> accountNames = new Map<Id, String>();
    accountNames.put(order.id, 'Team Phun');
    QuickbookApiCrud.updateInvoice(orderIds, accountNames);

    accountNames = new Map<Id, String>();
    accountNames.put(order.id, 'Team Phun');
    QuickbookApiCrud.updateInvoice(orderIds, accountNames);

    Test.stopTest();
  }

  @isTest
  public static void testMakePayment() {
    try {
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());

      Order ord = [
        SELECT Id, Name, Quickbooks_Instance__c, QbId__c, AccountId
        FROM Order
        LIMIT 1
      ];

      Quickbooks_Accounts_Configurations__c config = new Quickbooks_Accounts_Configurations__c();
      config.Name = 'test';
      config.QB_Access_token_End_Point__c = 'asdsadasdasdsadasdsad';
      config.QB_API_End_Point__c = 'asdasdasddsadasdasdasd';
      config.QB_Authorization_End_Point__c = 'asdasdsadasdasdsadasdas';
      config.QB_Authorization_Scope__c = 'asdasdasdsadasd';
      config.QB_Client_Id__c = 'asdasdasdasdasdas';
      config.QB_Client_Secret__c = 'asdasdasdasd';
      config.QB_ID__c = '123';
      config.QBO_Custom_Field_1__c = 'asdasdsadsadasdas';
      config.QBO_Custom_Field_1_Id__c = '1';
      config.QB_Redirect_URI__c = 'asdasdasdasdasd';
      config.Quickbooks_Account_Tittle__c = 'Team Phun';
      config.Service_Id_Breakdown__c = 'asdasdasdsadasdas';
      config.Service_Id_Brokerage__c = 'asdasdasdasd';
      config.Service_Id_Duty__c = 'asdsadsadasdasd';
      config.Service_Id_FixedCharges__c = 'asdasdasdasdasd';
      config.Service_Id_InboundFreight__c = 'asdasdasdasdas';
      config.Service_Id_RunCharges__c = 'asdsadasdas';
      insert config;

      Set<Id> ordIDs = new Set<Id>();
      Map<ID, String> OrderAccountMap = new Map<ID, String>();
      Map<ID, String> orderToQbIdMap = new Map<ID, String>();

      ordIDs.add(ord.Id);
      OrderAccountMap.put(ord.Id, ord.Quickbooks_Instance__c);
      orderToQbIdMap.put(ord.Id, ord.QbId__c);

      QuickbookApiCrud.makePayment(ordIDs, OrderAccountMap, orderToQbIdMap);

      Test.stopTest();
    } catch (Exception e) {
      System.debug(e);
    }
  }

  @isTest
  public static void testUpdatePFAInvoice() {
    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFA_Event_Billing__c eventBillingRec = [
      SELECT
        Id,
        Name,
        Account__c,
        QBO_Invoice_Number__c,
        Total_Amount__c,
        Payment_Link__c,
        QBO_Invoice_Id__c,
        Quickbooks_Instance__c
      FROM PFA_Event_Billing__c
      LIMIT 1
    ];
    Set<Id> eventBillingIds = new Set<Id>();
    eventBillingIds.add(eventBillingRec.Id);

    Map<Id, String> QBOAccountName = new Map<Id, String>();
    QBOAccountName.put(
      eventBillingRec.id,
      eventBillingRec.Quickbooks_Instance__c
    );
    QuickbookApiCrud.updatePFAEventBillingInvoiceInQBO(
      eventBillingIds,
      QBOAccountName
    );

    Test.stopTest();
  }

  @isTest
  public static void testCreatePFAInvoice() {
    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFA_Event_Billing__c eventBillingRec = [
      SELECT
        Id,
        Name,
        Account__c,
        QBO_Invoice_Number__c,
        Total_Amount__c,
        Payment_Link__c,
        QBO_Invoice_Id__c,
        Quickbooks_Instance__c
      FROM PFA_Event_Billing__c
      LIMIT 1
    ];
    Set<Id> eventBillingIds = new Set<Id>();
    eventBillingIds.add(eventBillingRec.Id);

    Map<Id, String> QBOAccountName = new Map<Id, String>();
    QBOAccountName.put(
      eventBillingRec.id,
      eventBillingRec.Quickbooks_Instance__c
    );
    QuickbookApiCrud.createPFAEventBillingInvoiceInQBO(
      eventBillingIds,
      QBOAccountName
    );

    Test.stopTest();
  }

  @isTest
  public static void testDeletePFAInvoice() {
    Test.startTest();

    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PFA_Event_Billing__c eventBillingRec = [
      SELECT
        Id,
        Name,
        Account__c,
        QBO_Invoice_Number__c,
        Total_Amount__c,
        Payment_Link__c,
        QBO_Invoice_Id__c,
        Quickbooks_Instance__c
      FROM PFA_Event_Billing__c
      LIMIT 1
    ];
    Set<Id> eventBillingIds = new Set<Id>();
    eventBillingIds.add(eventBillingRec.Id);

    Map<Id, String> QBOAccountName = new Map<Id, String>();
    QBOAccountName.put(
      eventBillingRec.id,
      eventBillingRec.Quickbooks_Instance__c
    );
    QuickbookApiCrud.deletePFAEventBillingInvoiceInQBO(
      eventBillingRec.Id,
      eventBillingRec.QBO_Invoice_Id__c,
      eventBillingRec.QBO_Invoice_Number__c,
      QBOAccountName
    );

    Test.stopTest();
  }
}
