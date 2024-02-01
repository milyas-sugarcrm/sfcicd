@isTest
public class Test_ApproveOrderController {
  @testSetup
  public static void createData() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    insert acc;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = System.today();
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Estimate';
    update opp;
    TestFactory testFactoryObj = new TestFactory();
    TestFactoryObj.createPriceBookEntry();
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
  }

  @isTest
  public static void testUpdateStatus() {
    Order workOrder = [SELECT Id, Status FROM Order LIMIT 1];

    PageReference pageRef = Page.ApproveOrder;
    pageRef.getParameters().put('Id', String.valueOf(workOrder.Id));
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController sc = new ApexPages.StandardController(
      workOrder
    );
    ApproveOrderController approveOrder = new ApproveOrderController(sc);

    Test.startTest();
    approveOrder.updateStatus();
    Test.stopTest();

    workOrder = [SELECT Id, Status FROM Order LIMIT 1];
    workOrder.Status = '03_-_Proof_Sent_-_Waiting_for_Approval';
    update workOrder;
    //System.assertEquals(workOrder.Status, '04_-_Order_Blanks-Approved/Deposit');
  }
}
