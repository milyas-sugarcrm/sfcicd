public class TriggerOnPricingProductHandler {
  List<Pricing_Product__c> newProductPrice;
  Map<Id, Pricing_Product__c> oldProductPrice;
  public TriggerOnPricingProductHandler(
    List<Pricing_Product__c> newValues,
    Map<Id, Pricing_Product__c> oldValues
  ) {
    this.newProductPrice = newValues;
    this.oldProductPrice = oldValues;
  }
  public void beforeInsert() {
    TriggerOnPricingProductService.checkRecordValidation(newProductPrice);
  }
}
