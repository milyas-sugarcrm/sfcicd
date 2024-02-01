public with sharing class QueriedProducts {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public String totalProducts { get; set; }
  @AuraEnabled
  public String name { get; set; }
  @AuraEnabled
  public String description { get; set; }
  @AuraEnabled
  public String productSupplierCode { get; set; }
  @AuraEnabled
  public String productBrand { get; set; }
  @AuraEnabled
  public String supplier { get; set; }
  @AuraEnabled
  public Decimal commonSkuId { get; set; }
  @AuraEnabled
  public String ProductCode { get; set; }
  @AuraEnabled
  public String productColor { get; set; }
  @AuraEnabled
  public String productSize { get; set; }
  @AuraEnabled
  public Decimal netPrice { get; set; }
  @AuraEnabled
  public Decimal profit { get; set; }
  @AuraEnabled
  public Decimal productCost { get; set; }
  @AuraEnabled
  public List<id> attatchmentIds { get; set; }
  @AuraEnabled
  public String imageUrl { get; set; }
  @AuraEnabled
  public Boolean imageExits { get; set; }
  @AuraEnabled
  public Boolean productCodeExist { get; set; }
  @AuraEnabled
  public Boolean productColorsExist { get; set; }
  @AuraEnabled
  public Boolean productSizesExist { get; set; }
  @AuraEnabled
  public Boolean productSupplierExist { get; set; }
  @AuraEnabled
  public Boolean commonSkuIdExist { get; set; }
  @AuraEnabled
  public Boolean pricingExist { get; set; }
  @AuraEnabled
  public Boolean productSupplierCodeExist { get; set; }
  @AuraEnabled
  public List<ProductPrice> prices { get; set; }
  public QueriedProducts() {
    prices = new List<ProductPrice>();
    id = '';
    name = '';
    description = '';
    productCost = 0;
    pricingExist = false;
    productSupplierCode = '';
    commonSkuId = 0;
    ProductCode = '';
    productSize = '';
    productColor = '';
    productBrand = '';
    supplier = '';
    netPrice = 0;
    profit = 0;
    attatchmentIds = new List<id>();
    imageUrl = '';
    totalProducts = '';
    imageExits = false;
  }
}
