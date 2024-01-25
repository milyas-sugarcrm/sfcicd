@isTest
public class ProductsSorting_Test {
  @isTest
  public static void ProductSort_Test() {
    OpportunityLineItem__c lineitem1 = new OpportunityLineItem__c(
      Name = 'TEST-1'
    );
    OpportunityLineItem__c lineitem2 = new OpportunityLineItem__c(
      Name = 'TEST-2'
    );
    OpportunityLineItem__c lineitem3 = new OpportunityLineItem__c(
      Name = 'TEST-3'
    );
    OpportunityLineItem__c lineitem4 = new OpportunityLineItem__c(
      Name = 'TEST-1'
    );
    List<OpportunityLineItem__c> unsortedProducts = new List<OpportunityLineItem__c>();
    unsortedProducts.add(lineitem1);
    unsortedProducts.add(lineitem2);
    unsortedProducts.add(lineitem3);
    unsortedProducts.add(lineitem4);
    insert unsortedProducts;
    List<OpportunityLineItem__c> relatedOpportunityLineItems = ProductsSorting.sortProducts(
      unsortedProducts
    );
  }
}
