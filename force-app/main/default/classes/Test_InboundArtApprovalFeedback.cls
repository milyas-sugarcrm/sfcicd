@isTest
public class Test_InboundArtApprovalFeedback {
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

    acc.Sales_Terms__c = c.Id;
    insert acc;

    Order workOrder = new Order();
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
  public static void testInboundArtApprovalFeedback() {
    Messaging.InboundEmail email = new Messaging.InboundEmail();
    Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

    email.subject = 'Your Order is Waiting for Your Approval';

    //Add Binary attachment
    Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
    binaryAttachment.body = blob.valueOf('Test Binary Attachment');
    binaryAttachment.fileName = 'testBinary.txt';
    binaryAttachment.mimeTypeSubType = 'text/plain';
    email.binaryAttachments = new List<Messaging.inboundEmail.BinaryAttachment>{
      binaryAttachment
    };

    //Add Text atatchment
    Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
    textAttachment.body = 'Test Text Attachment';
    textAttachment.fileName = 'testText.txt';
    textAttachment.mimeTypeSubType = 'texttwo/plain';
    email.textAttachments = new List<Messaging.inboundEmail.TextAttachment>{
      textAttachment
    };

    //Work Order process
    Order workOrder = [
      SELECT Id
      FROM Order
      WHERE Status = '01_-_Waiting_for_Client_Payment'
      LIMIT 1
    ];
    workOrder.Status = '03_-_Proof_Sent_-_Waiting_for_Approval';
    update workOrder;

    email.plainTextBody =
      'Let us know if you have any questions.' +
      'APPROVED <http://approveorder.force.com/OrderActions?Id=' +
      workOrder.Id;

    InboundArtApprovalFeedback testInboundArtApprovalFeedback = new InboundArtApprovalFeedback();
    testInboundArtApprovalFeedback.handleInboundEmail(email, env);

    List<Order> workOrders = [
      SELECT Id
      FROM Order
      WHERE Status = '02_-_Send_Mock_Up_to_Client_for_Approval'
    ];
    System.assert(workOrders.size() == 1);
  }
}
