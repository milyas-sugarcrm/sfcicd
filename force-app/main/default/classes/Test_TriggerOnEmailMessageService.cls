@isTest
public class Test_TriggerOnEmailMessageService {
  @testSetup
  public static void createData() {
    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.Art_Approval_Email__c = 'test@test.com';

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

    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Sales_Terms__c = c.Id;
    insert acc;

    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.Amount = 1000;
    opp.Estimated_Amount__c = 500;
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = System.today();
    opp.AccountId = acc.Id;
    insert opp;
    opp.StageName = 'Presentation';
    update opp;
    Estimate__c est = new Estimate__c();
    est.Opportunity__c = opp.Id;
    insert est;
    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;

    TestFactory testFactory = new TestFactory(1);
    System.Test.startTest();
    testFactory.createProducts();
    testFactory.createProductLineItems();
    TestFactory.createProductLineItemsRelatedItems();
    System.Test.stopTest();
    Product2 pro = [SELECT id FROM product2 LIMIT 1];

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );

    //Execute an update DML on the Pricebook2 record, to make IsStandard to true
    update standardPricebook;

    //Query for the Pricebook2 record, to check IsStandard field
    standardPricebook = [
      SELECT Id, IsStandard
      FROM Pricebook2
      WHERE Id = :standardPricebook.Id
    ];
    //It should return true

    //Create the PricebookEntry
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = pro.Id,
      UnitPrice = 1020,
      IsActive = true
    );
    insert pbe;
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
  }

  @isTest
  public static void testApprovalEmailSendCriteria() {
    Order workOrder = [SELECT Id, Status FROM Order LIMIT 1];
    EmailMessage approvalEmail = createApprovalEmail(workOrder.Id);
    List<EmailMessage> listEmailMessages = new List<EmailMessage>();
    listEmailMessages.add(approvalEmail);

    Test.startTest();

    try {
      insert approvalEmail;
    } catch (Exception e) {
      e.getMessage()
        .contains(
          'Email can not be sent. Work Order Status must be at Send Mock Up to Client for Approval.'
        );
    }

    workOrder.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
    update workOrder;

    try {
      insert approvalEmail;
    } catch (Exception e) {
      e.getMessage().contains('Email can not be sent with out attachment.');
    }

    TriggerOnEmailMessageService.updateWorkOrder(listEmailMessages, true);

    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    EmailMessage email = new EmailMessage();
    email.FromAddress = 'test@abc.org';
    email.Incoming = true;
    email.ToAddress = 'test@xyz.org';
    email.HtmlBody = 'Test email body';
    email.RelatedToId = opp.id;
    email.Subject = System.label.Opportunity_Presentation_Email_Subject;
    List<EmailMessage> emailMessagesForPresentation = new List<EmailMessage>();
    emailMessagesForPresentation.add(email);
    try {
      insert email;
    } catch (Exception e) {
      System.debug('e.getMessage(): ' + e.getMessage());
      System.assert(
        e.getMessage()
          .contains(
            'Attachment is outdated..Kindly generate pdf from button at the top.'
          )
      );
    }
    TriggerOnEmailMessageService.validatePresentationAttachtment(email);
    TriggerOnEmailMessageService.validatePurchaseOrderAttachment(email);
    TriggerOnEmailMessageService.validateDepositInvoiceAttachment(email);
    TriggerOnEmailMessageService.validateSalesOrderAttachment(email);
    TriggerOnEmailMessageService.validateEstimateAttachment(email);
    TriggerOnEmailMessageService.checkPresentationAttachment(
      emailMessagesForPresentation
    );
    EmailMessage email2 = new EmailMessage();
    email2.FromAddress = 'test@abc.org';
    email2.Incoming = true;
    email2.ToAddress = 'test@xyz.org';
    email2.HtmlBody = 'Test email body';
    email2.RelatedToId = opp.id;
    email2.Subject = System.label.Opportunity_Estimate_Email_Subject;
    List<EmailMessage> emailMessagesForEstimate = new List<EmailMessage>();
    emailMessagesForEstimate.add(email2);
    try {
      insert email2;
    } catch (Exception e) {
    }
    TriggerOnEmailMessageService.checkPresentationAttachment(
      emailMessagesForEstimate
    );

    EmailMessage email3 = new EmailMessage();
    email3.FromAddress = 'test@abc.org';
    email3.Incoming = true;
    email3.ToAddress = 'test@xyz.org';

    email3.HtmlBody = 'Test email body';
    email3.RelatedToId = opp.id;
    email3.Subject = System.label.Opportunity_Deposit_Invoice_Email_Subject;
    List<EmailMessage> emailMessagesForDepositInvoice = new List<EmailMessage>();
    emailMessagesForDepositInvoice.add(email3);
    try {
      insert email3;
    } catch (Exception e) {
    }
    TriggerOnEmailMessageService.checkPresentationAttachment(
      emailMessagesForDepositInvoice
    );

    EmailMessage email4 = new EmailMessage();
    email4.FromAddress = 'test@abc.org';
    email4.Incoming = true;
    email4.ToAddress = 'test@xyz.org';

    email4.HtmlBody = 'Test email body';
    email4.RelatedToId = opp.id;
    email4.Subject = System.label.Opportunity_Purchase_Order_Email_Subject;

    List<EmailMessage> emailMessagesForPurchaseOrder = new List<EmailMessage>();
    emailMessagesForDepositInvoice.add(email4);
    try {
      insert email4;
    } catch (Exception e) {
    }
    TriggerOnEmailMessageService.checkPresentationAttachment(
      emailMessagesForPurchaseOrder
    );

    EmailMessage email5 = new EmailMessage();
    email5.FromAddress = 'test@abc.org';
    email5.Incoming = true;
    email5.ToAddress = 'test@xyz.org';

    email5.HtmlBody = 'Test email body';
    email5.RelatedToId = opp.id;
    email5.Subject = System.label.Opportunity_Sales_Order_Email_Subject;
    List<EmailMessage> emailMessagesForSalesOrder = new List<EmailMessage>();
    emailMessagesForSalesOrder.add(email5);
    try {
      insert email5;
    } catch (Exception e) {
    }
    TriggerOnEmailMessageService.checkPresentationAttachment(
      emailMessagesForSalesOrder
    );

    Test.stopTest();
  }

  public static EmailMessage createApprovalEmail(Id orderId) {
    EmailMessage email = new EmailMessage();
    email.FromAddress = 'test@abc.org';
    email.Incoming = true;
    email.ToAddress = 'test@xyz.org';
    email.Subject = System.label.Work_Order_Approval_Email_Subject;
    email.HtmlBody = 'Test email body';
    email.RelatedToId = orderId;

    return email;
  }

  public static void createProduct(Id orderId) {
    Product2 prod = new Product2(
      Name = 'Laptop X200',
      Family = 'Hardware',
      Product_Cost__c = 123
    );
    insert prod;

    PricebookEntry standardPrice = new PricebookEntry(
      Pricebook2Id = Test.getStandardPricebookId(),
      Product2Id = prod.Id,
      UnitPrice = 10000,
      IsActive = true
    );
    insert standardPrice;

    OrderItem item = new OrderItem();
    item.OrderId = orderId;
    item.UnitPrice = 123;
    item.Quantity = 123;
    item.PricebookEntryId = standardPrice.Id;
    insert item;
  }
}
