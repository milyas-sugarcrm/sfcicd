public class ProductTriggerHandler {
  ////////////////// No need to deploy
  List<Product2> newPro;
  Map<Id, Product2> oldPro;

  public ProductTriggerHandler(
    List<Product2> newValues,
    Map<Id, Product2> oldValues
  ) {
    newPro = newValues;
    oldPro = oldValues;
  }
  public void beforeDelete() {
    ProductTriggerService.updateIsProductExistsField(oldPro.values(), null);
  }
}
