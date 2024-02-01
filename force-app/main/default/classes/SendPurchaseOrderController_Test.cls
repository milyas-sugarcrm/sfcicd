@isTest
public class SendPurchaseOrderController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.startTest();
    testFactory.addAddressRelatedData();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
    test.stopTest();
  }

  @isTest
  public static void test1() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT Id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    System.debug(PO.Id);
    SendPurchaseOrderController.emailTemplatePO(PO.Id);
    SendPurchaseOrderController.getSubject(PO.Id);
    SendPurchaseOrderController.getToAddress(PO.Id);
    SendPurchaseOrderController.getOrgWideEmail();
    SendPurchaseOrderController.fetchLookUpValues('zohaib');

    Blob body = blob.valueOf('Unit.Test');
    ContentVersion conVer = new ContentVersion();
    conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
    conVer.PathOnClient = 'test.pdf'; // The files name, extension is very important here which will help the file in preview.
    conVer.Title = 'test001'; // Display name of the files
    conVer.VersionData = body;
    insert conVer;

    ContentVersion cV = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      LIMIT 1
    ];
    List<String> cvIds = new List<String>();
    cvIds.add(cV.Id);
    ContentDocumentLink cDe = new ContentDocumentLink();
    cDe.ContentDocumentId = cV.ContentDocumentId;
    cDe.LinkedEntityId = PO.Id;
    cDe.ShareType = 'V';
    insert cDe;

    SendPurchaseOrderController.getPOPdf(PO.Id);
    List<String> ccEmail = new List<String>();
    ccEmail.add('salman.arif@rolustech.com');
    SendPurchaseOrderController.sendMail1(
      PO.Id,
      'mehwish.jabeen@rolustech.net',
      'muhammad.zohaib@rolustech.net',
      ccEmail,
      'Test Subject',
      'Test Body',
      cvIds
    );
    Test.stopTest();
  }
}
