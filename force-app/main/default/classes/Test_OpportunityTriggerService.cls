@isTest
public class Test_OpportunityTriggerService {
  private class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode;
    private String status;
    private String responseBody;

    public MockHttpResponse(
      Integer statusCode,
      String status,
      String responseBody
    ) {
      this.statusCode = statusCode;
      this.status = status;
      this.responseBody = responseBody;
    }

    public HTTPResponse respond(HttpRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(statusCode);
      res.setStatus(status);
      res.setBody(responseBody);
      return res;
    }
  }
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
    List<Opportunity> opportunities = [
      SELECT Id, AccountId
      FROM Opportunity
    ];
    Account acc = [
      SELECT Id, QBO_Accounts_Count__c
      FROM Account
      WHERE QBO_Accounts_Count__c > 0
      LIMIT 1
    ];

    for (Opportunity opp : opportunities) {
      opp.AccountId = acc.Id;
    }
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
    List<opportunity> oppList = [
      SELECT id, StageName, Margin__c
      FROM opportunity
    ];
    system.debug('opportunity: ' + oppList);
    List<OpportunityLineItem__c> oplineitem = [
      SELECT Id, Estimate__c, Opportunity__c, Opportunity__r.Margin__c
      FROM OpportunityLineItem__c
    ];
    system.debug('opplineitem: ' + oplineitem);
  }
  @isTest
  public static void testCreateEstimate() {
    Test.startTest();

    Opportunity opp = new Opportunity(Name = 'Opp');
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = Date.today();
    Account acc = [
      SELECT Id, QBO_Accounts_Count__c
      FROM Account
      WHERE QBO_Accounts_Count__c > 0
      LIMIT 1
    ];
    opp.AccountId = acc.Id;
    insert opp;
    Opportunity oppor = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    oppor.StageName = 'Presentation';
    update oppor;

    Estimate__c est = new Estimate__c();
    est.Opportunity__c = oppor.Id;
    insert est;
    oppor = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    oppor.StageName = 'Estimate';
    oppor.Estimate_Change_Status__c = 'not changed from picklist';
    update oppor;

    Test.stopTest();
  }
  @isTest
  public static void testCreateEstimateAndSync() {
    Test.startTest();
    List<Opportunity> opps = [SELECT ID, name, StageName FROM Opportunity];
    List<Id> oppIds = new List<Id>();
    for (Opportunity opp : opps) {
      oppIds.add(opp.Id);
    }
    OpportunityTriggerService.createAndSyncEstimate(oppIds);
    Test.stopTest();
  }
  @isTest
  public static void testRecalculateTotalOfLineItem() {
    Test.startTest();
    List<Estimate__c> estimates = [
      SELECT Id
      FROM Estimate__c
      LIMIT 2
    ];
    Set<Id> estIds = new Set<Id>();
    for (Estimate__c est : estimates) {
      estIds.add(est.Id);
    }
    OpportunityTriggerService.recalculateTotalOfLineItem(estIds);
    Test.stopTest();
  }
  @isTest
  public static void testGetMapOfSyncedQBORecordsAndAccount() {
    Test.startTest();
    List<Opportunity> opportunities = [
      SELECT Id
      FROM Opportunity
      LIMIT 2
    ];
    Set<Id> oppIds = new Set<Id>();
    for (Opportunity opp : opportunities) {
      oppIds.add(opp.Id);
    }
    OpportunityTriggerService.getMapOfSyncedQBORecordsAndAccount(oppIds);
    Test.stopTest();
  }
  @istest
  public static void testdeleteOppLineItemsRelatedToOpportunity() {
    Test.startTest();
    List<Opportunity> opps = [SELECT ID, name, StageName FROM Opportunity];
    Set<Id> oppIds = new Set<Id>();
    for (Opportunity opp : opps) {
      oppIds.add(opp.Id);
    }
    Opportunity opp = [SELECT id, name, StageName FROM Opportunity LIMIT 1];
    opp.name = 'Test Opp';

    List<Estimate__c> lstEstimates = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.id
    ];
    List<OpportunityLineItem__c> lstOppLineItem = new List<OpportunityLineItem__c>();
    Set<Id> lstEstimateIds = new Set<Id>();
    for (Estimate__c estimateObj : lstEstimates) {
      OpportunityLineItem__c oppLineItemObj = new OpportunityLineItem__c();
      oppLineItemObj.Name = 'Test';
      oppLineItemObj.Total_QBO__c = 12.6;
      oppLineItemObj.Estimate__c = estimateObj.id;
      lstOppLineItem.add(oppLineItemObj);
      lstEstimateIds.add(estimateObj.id);
      estimateObj.Estimate_QB_Id__c = '12';
    }
    insert lstOppLineItem;
    SYstem.debug('opp Stage ' + opp.StageName);
    update opp;
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Opportunity__c IN :oppIds
    ];
    System.assertNotEquals(0, oppLineItems.size());

    // delete opps;

    oppLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Opportunity__c IN :oppIds
    ];
    System.assertEquals(1, oppLineItems.size());

    OpportunityTriggerService.recalculateTotalOfLineItem(lstEstimateIds);
    Test.stopTest();
  }

  @istest
  public static void testStageOpportunity() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.Art_Approval_Email__c = 'test@test.com';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    //acc.QB_Record_ID__c = '1';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    Opportunity opp1 = new Opportunity();
    opp1.Name = 'Test Opp';
    opp1.Amount = 1000;
    opp1.Estimated_Amount__c = 500;
    opp1.StageName = 'Needs Analysis';
    opp1.CloseDate = Date.today();

    insert acc;
    opp1.AccountId = acc.Id;
    opp1.Contact__c = con.Id;
    insert opp1;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = Date.today();
    opp.AccountId = acc.Id;
    opp.Contact__c = con.Id;
    insert opp;
    opp.StageName = 'Presentation';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;
    List<Opportunity> lstOpp = new List<Opportunity>();
    lstOpp.add(opp);
    OpportunityTriggerService.populatePresentationFieldsBeforeInsert(lstOpp);
    Estimate__c estimate = new Estimate__c(
      In_Hands_Date__c = Date.today(),
      Terms__c = 'Prepay',
      Customer_PO__c = '4',
      Opportunity__c = opp.id,
      Estimate_QB_Id__c = '5'
    );
    insert estimate;
    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;

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
    Order order = new Order();
    order.OpportunityId = opp.id;
    order.Invoice_Number__c = 'SalesOrder-' + opp.id;
    order.Status = '01_-_Waiting_for_Client_Payment';
    order.EffectiveDate = system.today();
    order.Invoice_Terms__c = 'Credit Card';
    //order.Primary_Contact__c = opp.Contact__c;
    order.AccountId = opp.AccountId;
    //   order.Account_Name__c = 'testName';
    order.Invoice_Value__c = 0;
    order.Invoice_Tax__c = 0;
    order.Invoice_Discount__c = 0;
    order.Invoice_Due_Date__c = system.today();
    order.Invoice_Total__c = 0;
    order.Invoice_Estimated_Ship_Date__c = '';
    insert order;
    try {
      opp.StageName = 'Sales';
      update opp;
    } catch (Exception ex) {
      System.assertEquals(
        true,
        ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')
      );
    }
    Test.stopTest();
  }
  @istest
  public static void TestUpdateMarginAtPresentationStage() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    List<Opportunity> Opportunities = new List<Opportunity>();
    Map<id, opportunity> oldMapOpp = new Map<id, opportunity>();
    TestFactory testFactory = new TestFactory(1);
    Test.startTest();
    Opportunities = testFactory.TestDataForUpdateMargin();
    for (opportunity opp : Opportunities) {
      opp.Margin__c = 45;
      opp.StageName = 'Presentation';
      oldMapOpp.put(opp.id, opp);
    }
    update Opportunities;
    OpportunityTriggerService.updateMarginAtPresentationStage(
      Opportunities,
      oldMapOpp
    );

    Test.stopTest();
  }
  @istest
  public static void TestUpdateMarginAtEstimationStage() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    List<Opportunity> Opportunities = new List<Opportunity>();
    Map<id, opportunity> oldMapOpp = new Map<id, opportunity>();
    TestFactory testFactory = new TestFactory(1);
    Test.startTest();
    Opportunities = testFactory.TestDataForUpdateMargin();
    for (opportunity opp : Opportunities) {
      oldMapOpp.put(opp.id, opp);
      opp.Margin__c = 25;
      opp.StageName = 'Estimate';
      opp.Estimate_Change_Status__c = 'not changed from picklist';
    }
    try {
      update Opportunities;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    OpportunityTriggerService.updateMargin(Opportunities, oldMapOpp);
    Test.stopTest();
  }

  @IsTest
  static void testCompareOpportunities() {
    Test.startTest();
    RecordType vendorRecordType = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND Name = 'Vendor Account'
      LIMIT 1
    ];
    Account testAccount = new Account(
      Name = 'Test Account',
      RecordTypeId = vendorRecordType.Id,
      Billing_Email__c = 'test@test.com',
      BillingStreet = 'Test Billing Address',
      Art_Approval_Email__c = 'test@test.com',
      QuickBooks_Accounts__c = 'Team Phun'
    );
    insert testAccount;
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opp',
      StageName = 'Needs Analysis',
      AccountId = testAccount.Id,
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId()
    );
    insert testOpp;

    Opportunity testOpp1 = new Opportunity(
      Name = 'Test Opp',
      StageName = 'Needs Analysis',
      AccountId = testAccount.Id,
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId()
    );
    insert testOpp1;

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(201, 'Created', '{"id": "msFYActMfJHqNTKH8YSvF1"}')
    );
    new OpportunityTriggerService().compareOpportunities(testOpp, testOpp1);
    Test.stopTest();
  }
  @IsTest
  static void testEstimateStageChecks() {
    RecordType vendorRecordType = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Account' AND Name = 'Vendor Account'
      LIMIT 1
    ];
    Account testAccount = new Account(
      Name = 'Test Account',
      RecordTypeId = vendorRecordType.Id,
      Billing_Email__c = 'test@test.com',
      BillingStreet = 'Test Billing Address',
      Art_Approval_Email__c = 'test@test.com',
      QuickBooks_Accounts__c = 'Team Phun'
    );
    insert testAccount;

    Opportunity testOpp = new Opportunity(
      Name = 'Test Opp',
      StageName = 'Needs Analysis',
      AccountId = testAccount.Id,
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId()
    );
    insert testOpp;

    Opportunity oldOpp = testOpp;

    testOpp = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :testOpp.Id
    ];

    testOpp.StageName = 'Presentation';
    update testOpp;

    Estimate__c est = new Estimate__c();
    est.Opportunity__c = testOpp.Id;
    insert est;

    testOpp = [
      SELECT Id, StageName, AccountId, CloseDate
      FROM Opportunity
      WHERE Id = :testOpp.Id
    ];

    testOpp.StageName = 'Estimate';
    testOpp.Estimate_Change_Status__c = 'not changed from picklist';
    testOpp.Estimated_Amount__c = null;

    update testOpp;

    Map<Id, Opportunity> oldOpps = new Map<Id, Opportunity>{
      oldOpp.Id => oldOpp
    };

    Map<Id, Account> linkedAccounts = new Map<Id, Account>{
      testAccount.Id => testAccount
    };

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(201, 'Created', '{"id": "msFYActMfJHqNTKH8YSvF1"}')
    );
    OpportunityTriggerService.estimateStageChecks(
      new List<Opportunity>{ testOpp },
      oldOpps,
      linkedAccounts
    );
    Test.stopTest();
  }

  @isTest
  static void testCreateCampaignOnOppClose() {
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      OwnerId = UserInfo.getUserId(),
      Billing_Contact_Email_PFA__c = 'test@email.com',
      Campaign_POC__c = 'Test POC',
      Campaign_POC_Email__c = 'poc@email.com',
      Campaign_Start_Date__c = Date.today(),
      Campaign_End_Date__c = Date.today() + 30,
      CloseDate = Date.today() + 30
    );
    Account acc = [
      SELECT Id, QBO_Accounts_Count__c
      FROM Account
      WHERE QBO_Accounts_Count__c > 0
      LIMIT 1
    ];
    testOpp.AccountId = acc.Id;

    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    testOpp.ContactId = con.id;

    insert testOpp;

    List<Opportunity> opps = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :testOpp.Id
    ];
    OpportunityTriggerService.CreateCampaignOnOppClose(opps);

    List<PFA_Campaign__c> campaigns = [SELECT Id FROM PFA_Campaign__c];
    System.assertEquals(0, campaigns.size());
  }

  // Test method to cover the case where no opportunities meet the criteria
  @isTest
  static void testCreateCampaignOnOppClose_NoOpportunities() {
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId()
    );

    insert testOpp;

    List<Opportunity> opps = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :testOpp.Id
    ];
    OpportunityTriggerService.CreateCampaignOnOppClose(opps);

    List<PFA_Campaign__c> campaigns = [SELECT Id FROM PFA_Campaign__c];
    System.assertEquals(0, campaigns.size());
  }

  @isTest
  static void testDeleteOpp() {
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId(),
      Lead_Record_Id__c = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get('Brand Ambassador Lead')
        .getRecordTypeId()
    );
    insert testOpp;
    delete testOpp;
  }

  @isTest
  static void testCreateEstimate2() {
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity createEstimate 123',
      StageName = 'Needs Analysis',
      CloseDate = Date.today() + 30,
      OwnerId = UserInfo.getUserId()
    );
    Test.startTest();
    insert testOpp;
    List<Opportunity> opps = [
      SELECT Id, StageName, Order_Amount__c
      FROM Opportunity
      WHERE Name = 'Test Opportunity createEstimate 123'
    ];
    Map<Id, Opportunity> opps2 = new Map<Id, Opportunity>(
      [
        SELECT Id, StageName, Order_Amount__c
        FROM Opportunity
        WHERE Name = 'Test Opportunity createEstimate 123'
      ]
    );
    Map<Id, Account> linkedAccs = new Map<Id, Account>(
      [SELECT Id, Name FROM Account LIMIT 1]
    );
    Estimate__c es = [SELECT id, Opportunity__c FROM Estimate__c LIMIT 1];
    es.Opportunity__c = opps[0].id;
    update es;
    OpportunityTriggerService.createEstimate(opps, opps2, linkedAccs);
    Test.stopTest();
  }
}
