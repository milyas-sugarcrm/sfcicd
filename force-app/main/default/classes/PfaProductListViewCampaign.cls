public with sharing class PfaProductListViewCampaign {
  @AuraEnabled(cacheable=false)
  public static List<PFA_Product_Line_Item__c> getPfaProducts(Id campaignID) {
    List<PFA_Product_Line_Item__c> lineItems = [
      SELECT
        Id,
        Product_Id__c,
        Product_Name__c,
        Product_Category__c,
        Product_Barcode__c,
        Product_MSRP__c
      FROM PFA_Product_Line_Item__c
      WHERE PFA_Campaign_Id__c = :campaignID
    ];
    return lineItems;
  }

  @AuraEnabled(cacheable=false)
  public static void removeLineItem(Id lineItemId) {
    List<PFA_Product_Line_Item__c> lineitemsToDelete = new List<PFA_Product_Line_Item__c>();
    lineitemsToDelete = [
      SELECT Id
      FROM PFA_Product_Line_Item__c
      WHERE Id = :lineItemId
    ];
    if (!lineitemsToDelete.isEmpty()) {
      delete lineitemsToDelete;
    }
  }

  @AuraEnabled(cacheable=false)
  public static List<SObject> searchPfaProducts(String searchString) {
    Id pfaProductRecordTypeId = Schema.getGlobalDescribe()
      .get('Product2')
      .getDescribe()
      .getRecordTypeInfosByName()
      .get('PFA Product')
      .getRecordTypeId();
    String query =
      'SELECT Id, Name, productCategory__c, Barcode__c, MSRP__c FROM Product2' +
      ' WHERE recordTypeId = \'' +
      pfaProductRecordTypeId +
      '\' AND Name LIKE \'%' +
      searchString +
      '%\' LIMIT 5';
    List<SObject> products = Database.query(query);
    return products;
  }

  @AuraEnabled(cacheable=false)
  public static Id createLineItem(Id productId, Id CampaignId) {
    PFA_Product_Line_Item__c lineItem = new PFA_Product_Line_Item__c();
    lineItem.Product_Id__c = productId;
    lineItem.PFA_Campaign_Id__c = CampaignId;
    insert lineItem;
    return lineItem.Id;
  }

  @AuraEnabled(cacheable=true)
  public static Id getPfaProductTypeId() {
    return CommonUtilitiesPfa.getRecordTypeIdByName('Product2', 'PFA Product');
  }
}
