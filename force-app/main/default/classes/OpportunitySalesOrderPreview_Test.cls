@isTest
public class OpportunitySalesOrderPreview_Test {
  public static TestFactory testFactory = new TestFactory(1);
  @testSetup
  public static void populateData() {
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();

    testFactory.createSalesOrder();
    testFactory.createProductLineItems();

    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    Test.stopTest();
  }

  @isTest
  public static void testMethods() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Opportunity LIMIT 1]
    );
    OpportunitySalesOrderPreviewController ext = new OpportunitySalesOrderPreviewController(
      sc
    );
    Map<String, String> billingAddress = ext.getBillingAddress();
    ext.getBillingAddressPreview();
    Map<String, String> shippingAddress = ext.getShippingAddress();
    ext.getShippingAddressPreview();
    Order order = ext.getSalesOrderDetails();
    decimal totalPrice = ext.getPageTotal();

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
    List<QuriedProductsForOpportunityEstimate> listOfItems = ext.getLineItemsList();
    ext.setApprove();
    ext.setChange();
    ext.getChangeStatus();
    ext.getOppLink();
    ext.approveRejectOrder();
    ext.getTotalPlusTax();
    Test.stopTest();
  }
}
