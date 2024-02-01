public class relatedListOppotunityLineItem {
  @AuraEnabled
  public static List<OpportunityLineItem__c> getRelatedOpportunityLineItems(
    Id recid
  ) {
    return [
      SELECT
        Id,
        Name,
        Description__c,
        Product__c,
        Product__r.Name,
        SKU__c,
        Supplier__c,
        CreatedDate
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :recid
      ORDER BY CreatedDate DESC
    ];
  }

  @AuraEnabled
  public static boolean deleteOpportunityLineItemInDb(String recid) {
    try {
      OpportunityLineItem__c opportunityLine = [
        SELECT Id, Name
        FROM OpportunityLineItem__c
        WHERE Id = :recid
      ];
      delete opportunityLine;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return false;
    }
  }
}
