@isTest
public class Test_EmailInvokeOnSMTCFAClass {
  @TestSetup
  public static void createData() {
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
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    // acc.QB_Record_ID__c = '1';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Sales_Terms__c = [SELECT Id FROM Sales_Term__c LIMIT 1].Id;
    acc.Art_Approval_Email__c = 'abc@test.com';
    insert acc;
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = system.today();

    opp.AccountId = acc.Id;
    insert opp;

    Opportunity opp1 = [SELECT Id, StageName FROM Opportunity LIMIT 1];
    opp1.StageName = 'Presentation';
    update opp1;

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

    Order ord = new Order();
    ord.AccountId = acc.id;
    ord.OpportunityId = opp.id;
    ord.EffectiveDate = Date.newInstance(2019, 1, 1);
    ord.Status = '01_-_Waiting_for_Client_Payment';
    ord.Invoice_Number__c = '123';
    ord.Invoice_Discount__c = 123;
    ord.Invoice_Value__c = 123;
    ord.Invoice_Total__c = 123;
    ord.Invoice_Tax__c = 0;
    insert ord;
    OrderItem item = new OrderItem();
    item.OrderId = ord.id;
    item.UnitPrice = 123;
    item.Quantity = 123;
    item.PricebookEntryId = standardPrice.Id;
    insert item;
  }

  @isTest
  public static void testSendEmail() {
    List<Order> listOrders = [SELECT id FROM order];
    List<Id> listOrderIds = new List<Id>();
    for (Order ord : listOrders) {
      ord.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
      listOrderIds.add(ord.id);
    }
    update listOrders;
    EmailInvokeOnSMTCFAClass.sendEmail(listOrderIds);

    listOrders = [SELECT id, MockupClientApproval24HourEmailSent__c FROM order];
    for (Order ord : listOrders) {
      System.assertEquals(true, ord.MockupClientApproval24HourEmailSent__c);
    }
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations());

    //Now we verify that if on same stage, and the function is called again, emails are not sent out
    EmailInvokeOnSMTCFAClass.sendEmail(listOrderIds);
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations());
  }
}
