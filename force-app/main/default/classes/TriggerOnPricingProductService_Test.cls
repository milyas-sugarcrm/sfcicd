@isTest
public class TriggerOnPricingProductService_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    testFactory.createProducts();
  }
  @isTest
  public static void testCheckValidationOnPricingProductInsert() {
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    List<Pricing_Product__c> priceProducts = new List<Pricing_Product__c>();
    for (Integer i = 0; i < 6; i++) {
      Pricing_Product__c price = new Pricing_Product__c();
      price.Quantity__c = i;
      price.Product__c = prod.id;
      priceProducts.add(price);
    }
    insert priceProducts;
    Pricing_Product__c price = new Pricing_Product__c();
    price.Quantity__c = 10;
    price.Product__c = prod.id;
    priceProducts.add(price);
    insert price;
  }
}
