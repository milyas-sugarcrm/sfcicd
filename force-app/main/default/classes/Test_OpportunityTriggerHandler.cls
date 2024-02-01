@isTest
public class Test_OpportunityTriggerHandler {
  @testSetup
  public static void createData() {
    QB_Credentials__c qbc = new QB_Credentials__c();
    qbc.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadf';
    qbc.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbc.RealMId__c = '5165118946516321';
    insert qbc;
    //Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }
  @isTest
  public static void checkAndUpdateStatusOfOutdatedCheckbox() {
    //Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    opp.Name = 'Hello';
    opp.isOutdated__c = false;
    update opp;
    Opportunity oppor = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];
    Test.stopTest();
    // system.assertEquals(true, oppor.isOutdated__c);
  }
  @isTest
  public static void testCreateEstimateOnUpdate() {
    try {
      //Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
      Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

      Account acc = new Account();
      acc.Name = 'Test Account';
      acc.Billing_Email__c = 'test@test.com';
      acc.BillingStreet = 'Test Billing Address';
      acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('Customer Account')
        .getRecordTypeId();
      //acc.QB_Record_ID__c = '1';

      Contact con = new Contact();
      con.FirstName = 'Rt';
      con.LastName = 'Test Contact';
      con.AccountId = acc.Id;
      insert con;

      Opportunity opp = new Opportunity();
      opp.Name = 'Test Opp';
      opp.Amount = 1000;
      opp.Estimated_Amount__c = 500;
      opp.StageName = 'Proposal';
      opp.CloseDate = system.today();
      Test.startTest();
      insert acc;
      opp.AccountId = acc.Id;
      opp.Contact__c = con.Id;
      insert opp;
      opp.StageName = 'Estimate';
      update opp;
      Test.stopTest();
    } catch (Exception ex) {
      system.debug('error');
    }
  }
  @isTest
  public static void testPopulatePresentationFields() {
    //Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Test.startTest();
    Account acc = new Account();
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Name = 'Test Account2';
    acc.Billing_Email__c = 'test2@test.com';
    acc.Art_Approval_Email__c = 'tes2@test.com';
    acc.BillingStreet = 'Test Billing Address2';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    //acc.QB_Record_ID__c = '2';
    insert acc;

    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.AccountId = acc.Id;
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();
    opp.Contact__c = con.Id;
    insert opp;

    opp.StageName = 'Presentation';
    update opp;
    Opportunity opport3 = [
      SELECT Id, In_Hands_Date__c, Currency__c, Presentation_Style__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    Opportunity opport2 = [
      SELECT Id, In_Hands_Date__c, Currency__c, Presentation_Style__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    System.assertEquals(system.today(), opport2.In_Hands_Date__c);
    System.assertEquals('USD', opport2.Currency__c);
    System.assertEquals('List', opport2.Presentation_Style__c);
  }
  @isTest
  public static void testCreateEstimateOnInsert() {
    //Test.setMock(HttpCalloutMock.Class, new MockTestResponse());
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    Account acc = new Account();
    acc.Name = 'Test Account3';
    acc.Billing_Email__c = 'tes3t@test.com';
    acc.BillingStreet = 'Test3 Billing Address';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Art_Approval_Email__c = 'tes3t@test.com';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    // acc.QB_Record_ID__c = '3';

    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp2';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();
    Test.startTest();
    insert acc;
    opp.Contact__c = con.Id;
    opp.AccountId = acc.Id;

    insert opp;
    Test.stopTest();

    opp = [SELECT Id, Estimate_Number__c FROM Opportunity WHERE Id = :opp.Id];
    //System.assert(opp.Estimate_Number__c != null);
  }
}
