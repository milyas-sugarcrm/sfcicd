public with sharing class AddProductMainCompWoController {
  @AuraEnabled
  public static String getWorkOrderName(String workOrderId) {
    Order order = [SELECT OrderNumber FROM order WHERE id = :workOrderId];
    return order.OrderNumber;
  }
}
