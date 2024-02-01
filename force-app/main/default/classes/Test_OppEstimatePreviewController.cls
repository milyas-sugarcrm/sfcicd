@isTest
public class Test_OppEstimatePreviewController {
  public static TestFactory testFactory = new TestFactory(1);
  @testSetup
  public static void populateData() {
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createContact();
    testFactory.createEstimate();
    testFactory.createProducts();
    System.Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    System.Test.stopTest();
  }

  @isTest
  public static void testMethods() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Opportunity LIMIT 1]
    );
    OppEstimatePreviewController ext = new OppEstimatePreviewController(sc);
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
    ext.getBillingAddress();
    ext.getBillingAddressPreview();
    ext.getShippingAddress();
    ext.getShippingAddressPreview();
    Estimate__c estimate = ext.getEstimateDetails();
    decimal totalPrice = ext.getPageTotal();
    ext.getTax();
    ext.getTotalPlusTax();
    ext.getOppLink();
    ext.getOpportunity();
    ext.approveRejectEstimate();
    ext.setApprove();
    ext.setChange();
    ext.sendUnapproveEmail();
    ext.getChangeStatus();
    List<QuriedProductsForOpportunityEstimate> listOfItems = ext.getLineItemsList();
    Test.stopTest();
  }
}
