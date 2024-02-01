@isTest
public with sharing class WorkOrderEmailScheduler_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    List<Order> orderList = new List<Order>();
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createPriceBookEntry();
    Test.startTest();
    Order order1 = new Order();
    Opportunity opp = [
      SELECT id, AccountId, Contact__c
      FROM Opportunity
      LIMIT 1
    ];
    order1.OpportunityId = opp.id;
    order1.Invoice_Number__c = 'SalesOrder-' + opp.id + '1';
    order1.Status = '01_-_Waiting_for_Client_Payment';
    order1.EffectiveDate = system.today();
    order1.Invoice_Terms__c = 'Credit Card';
    order1.Primary_Contact__c = opp.Contact__c;
    order1.AccountId = opp.AccountId;
    order1.Invoice_Value__c = 0;
    order1.Invoice_Tax__c = 0;
    order1.Invoice_Discount__c = 0;
    order1.Invoice_Due_Date__c = system.today();
    order1.Invoice_Total__c = 0;
    order1.Invoice_Estimated_Ship_Date__c = '';
    order1.Order_Due_Date__c = System.Date.today().addDays(5);
    order1.OwnerId = UserInfo.getUserId();
    orderList.add(order1);

    Order order2 = new Order();
    order2.OpportunityId = opp.id;
    order2.Invoice_Number__c = 'SalesOrder-' + opp.id + '2';
    order2.Status = '01_-_Waiting_for_Client_Payment';
    order2.EffectiveDate = system.today();
    order2.Invoice_Terms__c = 'Credit Card';
    order2.Primary_Contact__c = opp.Contact__c;
    order2.AccountId = opp.AccountId;
    order2.Invoice_Value__c = 0;
    order2.Invoice_Tax__c = 0;
    order2.Invoice_Discount__c = 0;
    order2.Invoice_Due_Date__c = system.today();
    order2.Invoice_Total__c = 0;
    order2.Invoice_Estimated_Ship_Date__c = '';
    order2.Order_Due_Date__c = System.Date.today().addDays(6);
    order2.OwnerId = UserInfo.getUserId();
    orderList.add(order2);

    Order order3 = new Order();
    order3.OpportunityId = opp.id;
    order3.Invoice_Number__c = 'SalesOrder-' + opp.id + '3';
    order3.Status = '01_-_Waiting_for_Client_Payment';
    order3.EffectiveDate = system.today();
    order3.Invoice_Terms__c = 'Credit Card';
    order3.Primary_Contact__c = opp.Contact__c;
    order3.AccountId = opp.AccountId;
    order3.Invoice_Value__c = 0;
    order3.Invoice_Tax__c = 0;
    order3.Invoice_Discount__c = 0;
    order3.Invoice_Due_Date__c = system.today();
    order3.Invoice_Total__c = 0;
    order3.Invoice_Estimated_Ship_Date__c = '';
    order3.Order_Due_Date__c = System.Date.today().addDays(8);
    order3.OwnerId = UserInfo.getUserId();
    orderList.add(order3);
    insert orderList;

    List<Order> workOrderList = [SELECT Id, Status, OwnerId FROM Order];
    List<Id> orderOwnerId = new List<Id>();
    for (Order workOrder : workOrderList) {
      orderOwnerId.add(workOrder.OwnerId);
    }
    List<User> ownerUsers = [
      SELECT Id, Name, Email
      FROM User
      WHERE Id IN :orderOwnerId
    ];
    for (User ownerUser : ownerUsers) {
      ownerUser.Email = 'test@test.com';
    }
    update ownerUsers;
    Test.stopTest();
  }

  @isTest
  public static void testSendEmailWoDueDate() {
    WorkOrderEmailScheduler wes = new WorkOrderEmailScheduler();
    String CRON_EXP = '0 0 0 ? * * *';
    Test.startTest();
    system.schedule('Test 5 Days until Work Order Due Date', CRON_EXP, wes);
    Test.stopTest();
  }
}
