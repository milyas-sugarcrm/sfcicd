public class ProductPrice {
  @AuraEnabled
  public Double quantity { get; set; }
  @AuraEnabled
  public Double price { get; set; }
  @AuraEnabled
  public Double cost { get; set; }
  @AuraEnabled
  public Double profit { get; set; }
  public ProductPrice() {
    quantity = 0;
    price = 0;
    cost = 0;
    profit = 0;
  }
}
