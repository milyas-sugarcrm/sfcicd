@isTest
public class Test_EditOpportunityLineItemArtwork {
  @TestSetup
  public static void setData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
  }
  @isTest
  public static void testGetValuesForSizeTextBox() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getValuesForSizeTextBox(test.Id);
  }
  @isTest
  public static void testGetValuesForColorTextBox() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getValuesForColorTextBox(test.Id);
  }
  @isTest
  public static void testUpdateColorsList() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    List<String> colors = new List<String>();
    colors.add('element');
    colors.add('test');
    EditOpportunityLineItemArtworkController.UpdateColorsList(test.Id, colors);
  }
  @isTest
  public static void testUpdateSizesList() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    List<String> sizes = new List<String>();
    sizes.add('element');
    sizes.add('test');
    EditOpportunityLineItemArtworkController.UpdateSizesList(test.Id, sizes);
  }
  @isTest
  public static void testaddColorInDb() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String color = 'test';
    EditOpportunityLineItemArtworkController.addColorInDb(test.Id, color);
  }
  @isTest
  public static void testaddSizeInDb() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String size = 'test';
    EditOpportunityLineItemArtworkController.addSizeInDb(test.Id, size);
  }
  @isTest
  public static void testgetValuesForColorPiklist() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getValuesForColorPiklist(test.Id);
  }

  @isTest
  public static void testgetValuesForSizePiklist() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getValuesForSizePiklist(test.Id);
  }
  @isTest
  public static void testGetArtworkToEdit() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getArtworkToEdit(test.Id);
  }

  @isTest
  public static void testdeleteArtworkInDb() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT id
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.deleteArtworkInDb(
      test.Id,
      artwork.Id
    );
  }
  @isTest
  public static void testGetArtworks() {
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    EditOpportunityLineItemArtworkController.getArtworks(test.Id);
  }

  @isTest
  public static void testeditArtworkInDatabases() {
    OpportunityLineItem_ArtWork__c artwork = [
      SELECT id
      FROM OpportunityLineItem_ArtWork__c
      LIMIT 1
    ];
    String recId = artwork.Id;
    String imprintType = '';
    String proofRequired = 'test';
    String logoName = 'test';
    String logoSize = 'test';
    String logoColor = 'test';
    String repeatLogo = 'No';
    String supplierNotes = 'test';
    String documentId = '';
    String title = 'test';
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String OpportunityLineItemId = test.Id;
    EditOpportunityLineItemArtworkController.editArtworkInDatabases(
      recId,
      imprintType,
      proofRequired,
      logoName,
      logoSize,
      logoColor,
      repeatLogo,
      supplierNotes,
      documentId,
      title,
      OpportunityLineItemId
    );
  }
  @isTest
  public static void testSaveArtworkInDatabases() {
    String imprintType = '';
    String proofRequired = 'test';
    String logoName = 'test';
    String logoSize = 'test';
    String logoColor = 'test';
    String repeatLogo = 'No';
    String supplierNotes = 'test';
    String documentId = '';
    String title = 'test';
    OpportunityLineItem__c test = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    String recId = test.Id;
    EditOpportunityLineItemArtworkController.saveArtworkInDatabases(
      recId,
      imprintType,
      proofRequired,
      logoName,
      logoSize,
      logoColor,
      repeatLogo,
      supplierNotes,
      documentId,
      title
    );
  }
}
