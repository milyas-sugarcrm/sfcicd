@isTest
public class Test_OrderTriggerService {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );

    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();

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

    Account acc = [SELECT Id, Sales_Terms__c FROM Account LIMIT 1];
    acc.Sales_Terms__c = c.Id;
    update acc;

    Contact con = new Contact();
    con.FirstName = 'Test';
    con.LastName = 'Contact';
    con.Email = 'test@test.com';
    con.AccountId = acc.Id;
    insert con;

    Order workOrder = [SELECT id, Primary_Contact__c FROM Order];
    workOrder.Primary_Contact__c = con.Id;
    update workOrder;

    //Creating PO

    PurchaseOrder_LineItem__c purchaseOrder = new PurchaseOrder_LineItem__c();
    purchaseOrder.WO_Status__c = 'In Process';
    purchaseOrder.Work_Order__c = [SELECT Id, Status FROM Order LIMIT 1].id;
    insert purchaseOrder;

    Test.stopTest();
  }

  @isTest
  public static void ChangeStageofWorkOrder() {
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      Test.startTest();

      Order ord = [SELECT Id, Status FROM Order LIMIT 1];
      ord.Status = '08.1_-_On_Shelf_for_Local_Delivery/Pickup';
      update ord;

      Order ord2 = [SELECT Id, Status FROM Order WHERE Id = :ord.Id];
      Test.stopTest();
    } catch (Exception e) {
      system.debug(e);
    }
  }

  @isTest
  public static void testWorkOrderProductLineItemCreation() {
    Test.startTest();
    List<Order> workOrder = [
      SELECT Id, Status
      FROM Order
      WHERE Number_of_Products__c = 1
    ];
    System.assert(workOrder.size() == 1);
    Test.stopTest();
  }

  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      LIMIT 1
    ];
    opp.isOutdated__c = false;
    update opp;
    Order orde = [
      SELECT
        Account_Owner_Changed__c,
        OrderNumber,
        Status,
        EndDate,
        OpportunityId,
        EffectiveDate,
        Id
      FROM Order
      WHERE OpportunityId = :opp.Id
    ];
    orde.EffectiveDate = System.today();
    update orde;
    Opportunity oppor = [
      SELECT Id, StageName, isOutdated__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];
    Test.StopTest();
    //system.assertEquals(true, oppor.isOutdated__c);
  }

  @isTest
  public static void testWorkOrderEmailNotificationsOnStatusUpdates() {
    Test.startTest();
    Order workOrder = [SELECT Id, Status, OwnerId FROM Order];
    workOrder.Status = '06_-_In_Process-OTHER';
    update workOrder;

    User ownerUser = [
      SELECT Id, Name, Email
      FROM User
      WHERE Id = :workOrder.OwnerId
    ];
    ownerUser.Email = 'test@test.com';
    update ownerUser;

    workOrder.Status = '07 - Post Production';
    update workOrder;
    System.Limits.getEmailInvocations();
    Test.stopTest();

    /*
        Test.startTest();
        workOrder.Status = '07.2 - Shipping to Team Phun';
        update workOrder;
        System.Limits.getEmailInvocations();

        workOrder.Status = '07.3_-_Shipped_Direct_to_Client';
        try{
            update workOrder;
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('Please ensure Invoice Ship Via, Invoice Tracking Number and Shipping Address are filled.'));
        }
        workOrder.Invoice_Ship_Via__c = 'Test';
        workOrder.Invoice_Tracking_Number__c = '123';
        workOrder.ShippingStreet = 'Test Street';
        update workOrder;
        System.Limits.getEmailInvocations();
        
        PurchaseOrder_LineItem__c po = [Select ID, WO_Status__c from PurchaseOrder_LineItem__c where Work_Order__c =: workOrder.id];
        po.Production_Rep__c = 'Sean Burns';
        po.WO_Status__c = 'Billed';
        update po;
        workOrder.Status = '08.1_-_On_Shelf_for_Local_Delivery/Pickup';
        update workOrder;
        System.Limits.getEmailInvocations();
        
        //Reset to Ready for PickUp
        workOrder.Status = '07 - Post Production';
        update workOrder;
        
        workOrder.Status = '08.2 - On Shelf to Ship to Client';
        //update workOrder;
        System.Limits.getEmailInvocations();
        
        //workOrder.Status = '09_-_Complete';
        //update workOrder;
        System.Limits.getEmailInvocations();
        
        Test.stopTest();
		*/
  }

  @istest
  public static void testdeleteOppLineItemsRelatedToWorkOrder() {
    Test.startTest();
    List<Order> workOrders = [SELECT ID, name FROM Order];
    Set<Id> workOrderIds = new Set<Id>();
    for (Order workOrder : workOrders) {
      workOrderIds.add(workOrder.Id);
    }
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :workOrderIds
    ];
    System.assertNotEquals(0, oppLineItems.size());

    delete workOrders;

    oppLineItems = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :workOrderIds
    ];
    System.assertEquals(0, oppLineItems.size());
    Test.StopTest();
  }

  @istest
  public static void testRetainOldOwnerOfWorkOrder() {
    Test.startTest();
    system.debug('111111111111111111111111111111111');
    List<Order> workOrders = [SELECT ID, name, OwnerId, AccountId FROM Order];
    Design_Project__c designProjects = new Design_Project__c();
    designProjects.Work_Order__c = workOrders[0].Id;
    designProjects.Credits__c = 0;
    designProjects.Bank_Credits__c = true;
    designProjects.Estimate__c = null;
    insert designProjects;
    Set<Id> AccountIds = new Set<Id>();
    for (Order workOrder : workOrders) {
      AccountIds.add(workOrder.AccountId);
      workOrder.OwnerId = '005f4000003yg0OAAQ';
    }

    try {
      update workOrders;
    } catch (Exception e) {
      Boolean expectedExceptionThrown = (e.getMessage()
          .contains('Work Order owner cannot be updated'))
        ? true
        : false;
      System.AssertEquals(true, expectedExceptionThrown, e.getMessage());
    }

    List<Account> accounts = [
      SELECT Id, Name, OwnerId
      FROM Account
      WHERE Id IN :AccountIds
    ];
    for (Account acct : accounts) {
      acct.OwnerId = '005f4000003yg0OAAQ';
    }
    update accounts;

    workOrders = [SELECT ID, name, OwnerId FROM Order];
    /*for(Order workOrder:workOrders)
        {
            System.assertEquals('005f4000003mVhHAAU', workOrder.OwnerId);
        }*/
    if (workOrders != null)
      delete workOrders;
    Test.StopTest();
  }

  @isTest
  public static void testMarkInvoicesPaid() {
    List<Order> workOrder = [
      SELECT Id, QbId__c, Balance_Due_Formula__c
      FROM Order
      LIMIT 1
    ];
    OpportunityLineItem__c lineItem = [
      SELECT Id, Work_Order__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    lineItem.Work_Order__c = workOrder[0].Id;
    update lineItem;
    Design_Project__c designProject = new Design_Project__c();
    designProject.Work_Order__c = workOrder[0].Id;
    insert designProject;
    OrderTriggerService.markInvoicesPaid(workOrder);
  }
  @isTest
  public static void testGenerateDepositPDF() {
    Order WO = [SELECT Id, OpportunityId FROM Order LIMIT 1];
    OrderTriggerService.generateDepositPDF(WO.Id, WO.OpportunityId);
  }

  @isTest
  public static void generatePDF() {
    Order wo = [SELECT Id, Deposit_Invoice__c FROM order LIMIT 1];
    test.startTest();
    wo.Deposit_Invoice__c = null;
    update wo;

    Deposit_Invoice__c di = new Deposit_Invoice__c();
    di.Amount_Received__c = 123;

    insert di;

    wo.Deposit_Invoice__c = di.id;
    update wo;

    // OrderTriggerService.generatePDF(WO.Id, WO.OpportunityId);
  }
  @isTest
  public static void testOrderProcess() {
    Order ord = [
      SELECT id, Status, Invoice_Terms__c, Amount_Received__c
      FROM Order
      LIMIT 1
    ];
    ord.Invoice_Terms__c = 'Net';
    update ord;
    ord.Invoice_Terms__c = '50% Down';
    ord.Amount_Received__c = 10;
    ord.Status = '01_-_Waiting_for_Client_Payment';
    update ord;
  }

  @isTest
  public static void markInvoicesPaid() {
    test.startTest();
    List<Order> wo = [SELECT Id, QbId__c FROM order LIMIT 1];
    OrderTriggerService.markInvoicesPaid(wo);
    test.stopTest();
  }
}
