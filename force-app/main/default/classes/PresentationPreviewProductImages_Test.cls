@isTest
public class PresentationPreviewProductImages_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testGetAttachedImagesToProduct() {
    OpportunityLineItem__c oppLine = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
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

    oppLine.ContentDocument_ID__c = documents[0].Id;
    update oppLine;

    Test.startTest();
    PresentationPreviewProductImagesCon.getAttachedImagesToProduct(oppLine.id);

    oppLine.ContentDocument_ID__c = '';
    update oppLine;

    PresentationPreviewProductImagesCon.getAttachedImagesToProduct(oppLine.id);
    Test.stopTest();
  }

  @isTest
  public static void testSetAttachedImagesToProduct() {
    OpportunityLineItem__c oppLine = [
      SELECT Id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
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

    Test.startTest();
    PresentationPreviewProductImagesCon.setAttachedImagesToProduct(
      oppLine.id,
      documents[0].Id
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetOpportunityStage() {
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Test.startTest();
    String res = PresentationPreviewProductImagesCon.getOpportunityStage(
      opp.id
    );
    Test.stopTest();
  }
}
