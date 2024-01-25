@isTest
public class Test_QuickbookScheduler {
  @testSetup
  public static void createData() {
    TestFactory factory = new TestFactory();
    factory.createConfiguration();

    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    QB_Credentials__c qbc = new QB_Credentials__c();
    qbc.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadf';
    qbc.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbc.RealMId__c = '5165118946516321';
    qbc.Synced_Account_Title__c = 'Team Phun';
    insert qbc;

    QB_Credentials__c qbcPFA = new QB_Credentials__c();
    qbcPFA.Access_token__c = 'akjdkjnakcnhjsvavkgdvsaytsevfuysabldlciublsdiuabiudlbfsadf';
    qbcPFA.Refresh_token__c = 'ajsndkjbakhucbuydasiycbyuasic';
    qbcPFA.RealMId__c = '5165118946516321';
    qbcPFA.Synced_Account_Title__c = 'Phun for All';
    insert qbcPFA;

    Sales_Term__c c = new Sales_Term__c();
    c.Name = 'Net30';
    c.Type__c = 'STANDARD';
    c.Active__c = true;
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
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Art_Approval_Email__c = 'test@abc.com';
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    insert acc;

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
      QBO_Invoice_Number__c = '1070',
      Bill_Date__c = Date.today(),
      Bill_Due_Date__c = Date.today().addDays(30),
      Payment_Link__c = 'https://example.com/payment-link',
      Total_Amount__c = 375.00,
      QBO_Invoice_Id__c = '239',
      Balance_Due__c = 375.00,
      Quickbooks_Instance__c = 'Phun for All',
      Updated_From_QBO_Scheduler__c = false
    );

    insert newBillingRecord;

    Test.startTest();
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = Date.today();
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Presentation';
    update opp;
    Test.stopTest();

    QBO_Details__c qbo = new QBO_Details__c();
    qbo.QBO_Account__c = 'Team Phun';
    qbo.Id_Type__c = 'Account';
    qbo.Account__c = acc.Id;
    qbo.QB_Id__c = '123';
    qbo.Salesforce_Record_Id__c = acc.Id;
    insert qbo;

    factory.createPriceBookEntry();
    String pricebookId = [SELECT id FROM PriceBookEntry LIMIT 1].id;

    Order workOrder = new Order();
    workOrder.OpportunityId = opp.Id;
    workOrder.AccountId = acc.Id;
    workOrder.EffectiveDate = System.today();
    workOrder.Status = '01_-_Waiting_for_Client_Payment';
    workOrder.Invoice_Number__c = '123';
    workOrder.Invoice_Value__c = 123;
    workOrder.Invoice_Total__c = 123;
    workOrder.Invoice_Tax__c = 123;
    workOrder.Invoice_Discount__c = 100;
    workOrder.Client_Due_Date__c = '27/9';
    workOrder.Art_Approval_Email__c = 'test@abc.com';
    workOrder.Invoice_Estimated_Ship_Date__c = '27/9';
    insert workOrder;

    Product2 prod = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      Product_Cost__c = 123
    );
    prod.Sales_Price_Rate__c = 1;
    prod.Purchasing_Info__c = 'test';
    prod.Product_Supplier_Code__c = 'test';
    prod.Supplier__c = 'alphabroder';
    prod.Net_Price__c = 10;

    insert prod;

    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = prod.Id,
      UnitPrice = 10000,
      IsActive = true
    );
    insert standardPrice;

    OrderItem item = new OrderItem();
    item.OrderId = workOrder.Id;
    item.UnitPrice = 123;
    item.Quantity = 123;
    item.PricebookEntryId = standardPrice.Id;
    insert item;

    Id adminProfileId = [
      SELECT Id, Name
      FROM Profile
      WHERE Name = 'System Administrator'
      LIMIT 1
    ]
    .Id;
    List<User> adminUser = [
      SELECT Id, ProfileId
      FROM User
      WHERE ProfileId = :adminProfileId
      LIMIT 1
    ];

    List<SchedulerLastRun__c> scRunList = new List<SchedulerLastRun__c>();
    SchedulerLastRun__c scRun = new SchedulerLastRun__c();
    scRun.LastExecution__c = System.now();
    scRun.Last_Sent_Email_Time__c = System.now().addHours(-2);
    scRun.accountTitle__c = 'Team Phun';
    scRunList.add(scRun);

    SchedulerLastRun__c scRunPFA = new SchedulerLastRun__c();
    scRunPFA.LastExecution__c = System.now();
    scRunPFA.Last_Sent_Email_Time__c = System.now().addHours(-2);
    scRunPFA.accountTitle__c = 'Phun for All';
    scRunPFA.SetupOwnerId = adminUser[0].Id;
    scRunList.add(scRunPFA);

    insert scRunList;

    QBOSync_Errors__c errorRecord = new QBOSync_Errors__c();
    errorRecord.Error_Message__c = 'Test';
    insert errorRecord;

    TestFactoryConvertToSalesOrder tf = new TestFactoryConvertToSalesOrder();
    tf.createEstimate();
    tf.createProductLineItems();
    tf.createProductLineItemsRelatedItems();

    OpportunityLineItem__c oppLineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Design_Project__c designProject = new Design_Project__c();
    designProject.Work_Order__c = workOrder.id;
    designProject.Name = 'Design Product ';
    designProject.Product__c = oppLineItem.id;
    insert designProject;
    designProject.Bank_Credits__c = true;
    designProject.Credits__c = 0;
    update designProject;
  }

  @isTest
  public static void testGetDateFromString() {
    QuickbookScheduler.getDateFromString('12-31-2012');
  }
  @isTest
  public static void testAddQbError() {
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    QBOSync_Errors__c errorRecord = new QBOSync_Errors__c();
    errorRecord.Error_Message__c = 'Test';
    errorRecord.Name = 'objectName';
    errorRecord.resolved__c = false;
    insert errorRecord;
    QuickbookScheduler.addQBError('objectName', 'qbError');
    QuickbookScheduler.getDataClient(System.now());
  }
  @isTest
  public static void testScheduler() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());

    QuickbookScheduler m = new QuickbookScheduler();
    String seconds = '0';
    String minutes = '0';
    String hours = '*';
    String dayOfMonth = '*';
    String month = '*';
    String dayOfWeek = '?';
    String year = '*';

    String sch =
      seconds +
      ' ' +
      minutes +
      ' ' +
      hours +
      ' ' +
      dayOfMonth +
      ' ' +
      month +
      ' ' +
      dayOfWeek +
      ' ' +
      year;

    system.schedule('Quickbooks Scheduler run at x minutes', sch, m);
    Test.stopTest();
  }
}
