public class TriggerOnPricingProductService {
  public static void checkRecordValidation(
    List<Pricing_Product__c> triggerNew
  ) {
    for (Pricing_Product__c priceProduct : triggerNew) {
      List<Pricing_Product__c> products = [
        SELECT id, Product__c, Quantity__c
        FROM Pricing_Product__c
        WHERE Product__c = :priceProduct.Product__c
      ];
      if (products.size() == 5) {
        priceProduct.addError('You cannot insert more than 5 records!');
      } else {
        for (Pricing_Product__c priceProducts : products) {
          if (priceProducts.Quantity__c > priceProduct.Quantity__c) {
            priceProduct.addError(
              'You cannot insert less than ' +
                priceProducts.Quantity__c +
                ' for quantity!'
            );
          }
        }
      }
    }
  }
}
