public with sharing class PfaProductListViewOpportunity {
  @AuraEnabled(cacheable=false)
  public static List<PFA_Product_Line_Item__c> getPfaProductsofOpp(Id oppId) {
    List<PFA_Product_Line_Item__c> oppLineitems = [
      SELECT
        Id,
        Product_Id__c,
        Product_Name__c,
        Product_Category__c,
        Product_Barcode__c,
        Product_MSRP__c
      FROM PFA_Product_Line_Item__c
      WHERE Opportunity_Id__c = :oppId
    ];
    return oppLineitems;
  }

  @AuraEnabled(cacheable=false)
  public static void removeOppLineItem(Id oppLineItemId) {
    List<PFA_Product_Line_Item__c> oppLineitemsToDelete = new List<PFA_Product_Line_Item__c>();
    oppLineitemsToDelete = [
      SELECT Id
      FROM PFA_Product_Line_Item__c
      WHERE Id = :oppLineItemId
    ];
    if (!oppLineitemsToDelete.isEmpty()) {
      delete oppLineitemsToDelete;
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
  public static Id createOppLineItem(Id productId, Id OppId) {
    PFA_Product_Line_Item__c lineItem = new PFA_Product_Line_Item__c();
    lineItem.Product_Id__c = productId;
    lineItem.Opportunity_Id__c = OppId;
    insert lineItem;
    return lineItem.Id;
  }

  @AuraEnabled(cacheable=true)
  public static Id getPfaProductTypeId() {
    return CommonUtilitiesPfa.getRecordTypeIdByName('Product2', 'PFA Product');
  }
}
