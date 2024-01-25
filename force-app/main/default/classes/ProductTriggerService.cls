public class ProductTriggerService {
  public static void updateIsProductExistsField(
    List<Product2> newValues,
    Map<Id, Product2> oldValues
  ) {
    List<Id> productIds = new List<id>();
    for (Product2 pro : newValues) {
      productIds.add(pro.Id);
    }
    List<OpportunityLineItem__c> relatedOppLineItems = [
      SELECT Id, Product__c, SKU__c
      FROM OpportunityLineItem__c
      WHERE Product__c IN :productIds
    ];
    for (OpportunityLineItem__c opp : relatedOppLineItems) {
      opp.IsProductExists__c = false;
    }
    update relatedOppLineItems;
  }
}
