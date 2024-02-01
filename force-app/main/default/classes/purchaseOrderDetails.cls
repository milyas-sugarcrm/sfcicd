public class purchaseOrderDetails {
  @AuraEnabled
  public Id imageContentVersionId { get; set; }
  @AuraEnabled
  public Id poLineItemId { get; set; }
  @AuraEnabled
  public String productName { get; set; }
  @AuraEnabled
  public String poNumber { get; set; }
  @AuraEnabled
  public String supplier { get; set; }
  @AuraEnabled
  public String supplierUrl { get; set; }
  @AuraEnabled
  public Date shippingDate { get; set; }
  @AuraEnabled
  public String Status { get; set; }
  @AuraEnabled
  public String proofStatus { get; set; }
  @AuraEnabled
  public Date inHandsDate { get; set; }
  @AuraEnabled
  public String shippingMethod { get; set; }
  @AuraEnabled
  public String shippingAddress { get; set; }
  @AuraEnabled
  public String proof { get; set; }
  @AuraEnabled
  public String productionRep { get; set; }
  @AuraEnabled
  public List<String> SKU { get; set; }
  @AuraEnabled
  public String color { get; set; }
  @AuraEnabled
  public String size { get; set; }
  @AuraEnabled
  public String imageVersionId { get; set; }
  @AuraEnabled
  public String poId { get; set; }
  @AuraEnabled
  public String lineItemId { get; set; }
  @AuraEnabled
  public Shipping_Information__c shippingInfo { get; set; }

  public purchaseOrderDetails() {
    proof = '';
    productionRep = '';
    proofStatus = '';
    SKU = new List<String>();
    shippingDate = System.today();
    color = '';
    size = '';
  }
}
