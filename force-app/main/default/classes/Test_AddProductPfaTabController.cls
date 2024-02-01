@isTest
public class Test_AddProductPfaTabController {
  @testSetup
  public static void populateData() {
    TestFactoryPfa testFactoryPfa = new TestFactoryPfa(1);
    testFactoryPfa.createOpportunities();
    testFactoryPfa.createProducts();
    testFactoryPfa.createProductLineItems();
  }

  @isTest
  public static void testCreateOpportunityLineItem() {
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];

    ContentVersion cv = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test.jpg',
      VersionData = blob.valueof('Test Content Data'),
      IsMajorVersion = true
    );
    insert cv;

    ContentVersion contentVersionSelect = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];
    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];

    ContentDocumentLink contentlink = new ContentDocumentLink();
    contentlink.LinkedEntityId = prod.id;
    contentlink.ShareType = 'V';
    contentlink.ContentDocumentId = documents[0].Id;
    contentlink.Visibility = 'AllUsers';
    insert contentlink;
    List<Product2> lstProduct = [SELECT id FROM Product2];
    System.debug('lstProduct ' + lstProduct.size());
    if (lstProduct.size() > 0) {
      Pricing_Product__c tmpPricing = new Pricing_Product__c();
      tmpPricing.Product__c = prod.Id;
      tmpPricing.Quantity__c = 4;
      tmpPricing.Net_Cost__c = 4;
      insert tmpPricing;
    }
    Estimate__c estimate = new Estimate__c();
    estimate.In_Hands_Date__c = Date.today();
    estimate.Terms__c = 'Prepay';
    estimate.Customer_PO__c = '4';
    estimate.Opportunity__c = opp.id;
    insert estimate;

    AddProductPfaTabController.createOpportunityLineItem(
      prod.id,
      opp.id,
      estimate.Id,
      'Estimate',
      null
    );
    AddProductPfaTabController.createOpportunityLineItem(
      prod.id,
      opp.id,
      null,
      'Opportunity',
      null
    );
    AddProductPfaTabController.getSearchResults(
      '0',
      '10',
      'Aplhabroder',
      'mug',
      '1',
      'abc'
    );
    AddProductPfaTabController.getSearchResults(
      '',
      '10',
      'Aplhabroder',
      'mug',
      '1',
      ''
    );
    AddProductPfaTabController.getSearchResults(
      '0',
      '',
      'Aplhabroder',
      'mug',
      '1',
      'tabname'
    );
    AddProductPfaTabController.getSearchResults(
      '0',
      '10',
      '',
      'mug',
      '1',
      'adfg'
    );
    AddProductPfaTabController.getSearchResults(
      '0',
      '10',
      'Aplhabroder',
      '',
      '1',
      ''
    );
    AddProductPfaTabController.getSearchResults(
      null,
      null,
      '',
      '',
      '1',
      'designproduct'
    );
  }
  @isTest
  public static void testCreateOpportunityLineItemWithoutPricing() {
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];

    ContentVersion cv = new ContentVersion(
      Title = 'Test',
      PathOnClient = 'Test.jpg',
      VersionData = blob.valueof('Test Content Data'),
      IsMajorVersion = true
    );
    insert cv;

    ContentVersion contentVersionSelect = [
      SELECT Id, Title, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :cv.Id
      LIMIT 1
    ];
    List<ContentDocument> documents = [
      SELECT Id, Title, LatestPublishedVersionId
      FROM ContentDocument
    ];

    ContentDocumentLink contentlink = new ContentDocumentLink();
    contentlink.LinkedEntityId = prod.id;
    contentlink.ShareType = 'V';
    contentlink.ContentDocumentId = documents[0].Id;
    contentlink.Visibility = 'AllUsers';
    insert contentlink;
    List<Product2> lstProduct = [SELECT id FROM Product2];
    System.debug('lstProduct ' + lstProduct.size());
    AddProductPfaTabController.createOpportunityLineItem(
      prod.id,
      opp.id,
      null,
      'Estimate',
      null
    );
    AddProductPfaTabController.createOpportunityLineItem(
      prod.id,
      opp.id,
      null,
      'SalesOrder',
      null
    );
  }
}
