@isTest
public class UpdatePurchaseOrderAccount_Test {
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
}
