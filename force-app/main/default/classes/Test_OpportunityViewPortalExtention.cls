@isTest
public class Test_OpportunityViewPortalExtention {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();

    testFactory.createSalesOrder();
    Test.startTest();

    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createActivity();
    testFactory.approveRejectOrder();
    //Test.startTest();
    //testFactory.addAddressRelatedData();
    // testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
    Test.stopTest();
  }
  @isTest
  public static void testGetEmails() {
    Test.startTest();
    Opportunity o = [SELECT id FROM Opportunity LIMIT 1];
    Apexpages.StandardController stdCon = new Apexpages.StandardController(o);
    OpportunityViewPortalExtention testObject = new OpportunityViewPortalExtention(
      stdCon
    );

    OpportunityLineItemAttachment__c attch = new OpportunityLineItemAttachment__c();
    attch.OpportunityLineItem__c = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ]
    .Id;
    insert attch;
    ContentVersion contentVersion = new ContentVersion(
      Title = 'Penguins',
      PathOnClient = 'Penguins.jpg',
      VersionData = Blob.valueOf('Test Content'),
      IsMajorVersion = true
    );
    insert contentVersion;
    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];

    //create ContentDocumentLink  record
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.LinkedEntityId = attch.Id;
    cdl.ContentDocumentId = documents[0].Id;
    cdl.shareType = 'V';
    insert cdl;

    testObject.getDetails();

    testObject.getLink();
    testObject.getOpportunity();
    Test.stopTest();
  }
}
