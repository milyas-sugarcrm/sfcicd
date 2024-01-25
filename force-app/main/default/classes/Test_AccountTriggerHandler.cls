@isTest
public class Test_AccountTriggerHandler {
  @testSetup
  public static void createData() {
    Test_QuickbookApiCrud.createData();
  }
  @isTest
  public static void testSendCustomer() {
    Test_QuickbookApiCrud.testSendCustomer();
  }
  @isTest
  public static void testSendVendor() {
    Test_QuickbookApiCrud.testSendVendor();
  }

  @isTest
  public static void testWebsite() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account();
    acc.Name = 'Test Aasdasccount';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    acc.Website = 'https://www.google.com';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Art_Approval_Email__c = 'test@test.com';
    Test.startTest();
    insert acc;
    Test.stopTest();
  }

  @isTest
  public static void testSameBillingAddress() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account();
    acc.Name = 'Test asdAccount';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    acc.Website = 'https://www.google.com';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Art_Approval_Email__c = 'test@test.com';
    Test.startTest();
    insert acc;
    Test.stopTest();
  }

  @isTest
  public static void testUpdateWorkOrderOwnerCheckbox() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    List<Account> accounts = [SELECT Id, OwnerId FROM Account];
    Set<Id> accountIds = new Set<Id>();
    for (Account acct : accounts) {
      accountIds.add(acct.Id);
      acct.OwnerId = '005f4000003yg0OAAQ';
    }
    List<Order> workOrders = [
      SELECT Id, OwnerId, Account_Owner_Changed__c
      FROM Order
      WHERE AccountId IN :accountIds
    ];
    for (Order workOrder : workOrders) {
      System.assertEquals(false, workOrder.Account_Owner_Changed__c);
      System.assertEquals('005f4000003mVhHAAU', workOrder.OwnerId);
    }
    Test.startTest();
    update accounts;

    workOrders = [
      SELECT Id, OwnerId, Account_Owner_Changed__c
      FROM Order
      WHERE AccountId IN :accountIds
    ];
    for (Order workOrder : workOrders) {
      System.assertEquals(true, workOrder.Account_Owner_Changed__c);
      System.assertNotEquals('005f4000003yg0OAAQ', workOrder.OwnerId);
    }
    Test.stopTest();
  }

  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    Test.startTest();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    Test.stopTest();

    List<Account> accounts = [SELECT Id, OwnerId, BillingCity FROM Account];

    for (Account acct : accounts) {
      acct.BillingCity = 'Address updated';
    }
    update accounts;
  }
  @isTest
  public static void testUpdateShippingInfo() {
    Test.startTest();
    List<Account> accounts = [
      SELECT Id, OwnerId, ShippingCountry
      FROM Account
      WHERE RecordType.Name = 'Vendor Account'
      LIMIT 1
    ];
    List<Shipping__c> shippingRecs = new List<Shipping__c>();
    Shipping__c shippingRec1 = new Shipping__c();
    shippingRec1.Decorator__c = accounts[0].Id;
    shippingRecs.add(shippingRec1);
    Shipping__c shippingRec2 = new Shipping__c();
    shippingRec2.Supplier__c = accounts[0].Id;
    shippingRecs.add(shippingRec2);
    insert shippingRecs;
    accounts[0].ShippingCountry = 'Test Update Shipping Country';
    update accounts;
    Test.stopTest();
  }

  @isTest
  static void testSetArtApprovalEmailBilling() {
    // Create test data
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Account acc0 = new Account();
    acc0.Name = 'Test asdAccount';
    acc0.Billing_Email__c = 'test@test.com';
    acc0.BillingStreet = 'Test Billing Address';
    acc0.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc0.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    acc0.Website = 'https://www.google.com';
    acc0.QuickBooks_Accounts__c = 'Team Phun';
    acc0.Art_Approval_Email__c = 'oldEmail2@gmail.com';

    insert acc0;

    Contact con = new Contact();
    con.FirstName = 'Rt1';
    con.LastName = 'Test Contact1';
    con.AccountId = acc0.Id;
    insert con;

    Contact con2 = new Contact();
    con2.FirstName = 'Rt1';
    con2.LastName = 'Test Contact1';
    con2.AccountId = acc0.Id;
    insert con2;

    Account acc = new Account();
    acc.Name = 'Test asdAccount1';
    acc.Billing_Email__c = 'test@test1.com';
    acc.BillingStreet = 'Test Billing Address1';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    acc.Website = 'https://www.google.com';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Art_Approval_Email__c = 'oldEmail1@gmail1.com';
    acc.Billing_Contact__c = con.id;
    insert acc;

    Order order = new Order();
    order.Status = '01_-_Waiting_for_Client_Payment';
    order.EffectiveDate = system.today();
    order.Invoice_Terms__c = 'Credit Card';
    order.Invoice_Value__c = 0;
    order.Invoice_Tax__c = 0;
    order.Invoice_Discount__c = 0;
    order.Invoice_Due_Date__c = system.today();
    order.Invoice_Total__c = 0;
    order.Invoice_Estimated_Ship_Date__c = '';
    order.Quickbooks_Instance__c = 'Team Phun';
    order.QbId__c = '123';

    // Create a map of old accounts for comparison
    Map<Id, Account> oldAccountsMap = new Map<Id, Account>();
    oldAccountsMap.put(
      acc.Id,
      new Account(
        Id = acc.Id,
        Name = 'Test asdAccount',
        Billing_Email__c = 'test@test.com',
        BillingStreet = 'Test Billing Address',
        RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Customer Account')
          .getRecordTypeId(),
        Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1]
        .Id,
        Website = 'https://www.google.com',
        QuickBooks_Accounts__c = 'Team Phun',
        Art_Approval_Email__c = 'oldEmail1',
        Billing_Contact__c = con2.id
      )
    );

    // Call the method to be tested
    AccountTriggerHandler.SetArtApprovalEmailBilling(
      new List<Account>{ acc },
      oldAccountsMap
    );

    // Retrieve the updated orders
    List<Order> updatedOrders = [
      SELECT Id, Art_Approval_Email__c, Billing_Contact__c
      FROM Order
      WHERE AccountId = :acc.id
    ];

    Test.stopTest();
  }

  @isTest
  public static void testConvertFlowsToApex() {
    Test.startTest();
    List<Account> accounts = [
      SELECT
        Id,
        OwnerId,
        ShippingCountry,
        Lead_Record_Id__c,
        Copy_to_Shipping_Address__c,
        BillingCity,
        BillingCountry,
        BillingPostalCode,
        BillingState,
        BillingStreet
      FROM Account
      WHERE RecordType.Name = 'Vendor Account'
    ];
    accounts[0].Lead_Record_Id__c = '0128M0000004PCUQA2';
    accounts[0].Copy_to_Shipping_Address__c = true;
    AccountTriggerHandler.handleRecordType(accounts);

    update accounts;
    Test.stopTest();
  }
}
