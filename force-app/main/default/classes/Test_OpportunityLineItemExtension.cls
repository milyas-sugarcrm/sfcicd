@isTest
public class Test_OpportunityLineItemExtension {
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
  public static void testDataManipulation() {
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Opportunity LIMIT 1]
    );
    OpportunityLineItemExtension ext = new OpportunityLineItemExtension(sc);

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

    List<QuriedOpportunitiesLineItems> listOfItems = ext.getLineItemsList();
    System.assert(listOfItems.size() == 1);
  }

  @isTest
  public static void testAddComment() {
    Test.setCurrentPageReference(new PageReference('Page.PresentationPreview'));
    System.currentPageReference()
      .getParameters()
      .put('comment' + [SELECT id FROM Opportunity LIMIT 1].id, 'My comment');
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Opportunity LIMIT 1]
    );
    OpportunityLineItemExtension ext = new OpportunityLineItemExtension(sc);

    ext.getOppLink();
    ext.getOpportunity();
    ext.addComment();
  }
}
