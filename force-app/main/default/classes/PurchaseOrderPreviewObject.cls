public class PurchaseOrderPreviewObject {
  public PurchaseOrderPreviewObject() {
    productDetails = new List<ProductDetailsPurchaseOrderPreview>();
    productExtraChargesDetails = new List<ProductDetailsPurchaseOrderPreview>();
    productLineItemName = '';
    quantity = 0;
    total = 0;
  }
  public String productLineItemName { get; set; }
  public Decimal quantity { get; set; }
  public Decimal total { get; set; }
  public List<ProductDetailsPurchaseOrderPreview> productDetails { get; set; }
  public List<ProductDetailsPurchaseOrderPreview> productExtraChargesDetails {
    get;
    set;
  }
  public Boolean extra { get; set; }
}
