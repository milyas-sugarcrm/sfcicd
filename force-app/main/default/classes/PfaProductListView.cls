public with sharing class PfaProductListView {
  static String PRODUCT2_API_NAME = 'Product2';
  static String PFA_PRODUCT = 'PFA Product';

  @AuraEnabled(cacheable=false)
  public static List<PFA_Product_Line_Item__c> getPfaProductLineItems(
    Id campaignId,
    Id oppId,
    Id eventId
  ) {
    if (campaignId != null || oppId != null || eventId != null) {
      List<PFA_Product_Line_Item__c> lineItems = [
        SELECT
          Id,
          Product_Id__c,
          Product_Name__c,
          Product_Category__c,
          Product_Barcode__c,
          Product_MSRP__c
        FROM PFA_Product_Line_Item__c
        WHERE
          PFA_Campaign_Id__c = :campaignID
          AND Opportunity_Id__c = :oppId
          AND PFA_Event__c = :eventId
      ];
      return lineItems;
    } else {
      return null;
    }
  }

  @AuraEnabled(cacheable=false)
  public static void removeLineItem(Id lineItemId) {
    try {
      if (lineItemId != null) {
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
    } catch (Exception ex) {
      System.debug('Error in deleting lineItem' + ex.getMessage());
    }
  }

  @AuraEnabled(cacheable=false)
  public static List<SObject> searchPfaProducts(String searchString) {
    try {
      List<SObject> products = new List<SObject>();
      if (searchString != null && searchString != '') {
        Id pfaProductRecordTypeId = getPfaProductTypeId();
        final String fieldsStr = 'Id, Name, productCategory__c, Barcode__c, MSRP__c';
        final String LimitStr = '7';
        final String query =
          'SELECT ' +
          fieldsStr +
          ' FROM ' +
          PRODUCT2_API_NAME +
          ' WHERE recordTypeId = \'' +
          pfaProductRecordTypeId +
          '\' AND Name LIKE \'%' +
          searchString +
          '%\' LIMIT ' +
          LimitStr;
        products = Database.query(query);
      }
      return products;
    } catch (Exception ex) {
      System.debug('Error in searching Products' + ex.getMessage());
      return null;
    }
  }

  @AuraEnabled(cacheable=false)
  public static Id createLineItem(
    Id productId,
    Id campaignId,
    Id oppId,
    Id eventId
  ) {
    try {
      if (
        productId != null &&
        (campaignId != null ||
        oppId != null ||
        eventId != null)
      ) {
        PFA_Product_Line_Item__c lineItem = new PFA_Product_Line_Item__c();
        lineItem.Product_Id__c = productId;
        lineItem.PFA_Campaign_Id__c = campaignId;
        lineItem.Opportunity_Id__c = oppId;
        lineItem.PFA_Event__c = eventId;
        insert lineItem;
        return lineItem.Id;
      } else {
        return null;
      }
    } catch (Exception ex) {
      System.debug('Error in inserting lineItem' + ex.getMessage());
      return null;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Id getPfaProductTypeId() {
    return CommonUtilitiesPfa.getRecordTypeIdByName(
      PRODUCT2_API_NAME,
      PFA_PRODUCT
    );
  }
}
