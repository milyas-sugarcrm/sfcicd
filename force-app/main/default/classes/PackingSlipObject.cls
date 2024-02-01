public class PackingSlipObject {
  public String productLineItemName { get; set; }
  public List<ProductDetailsForPackingSlip> productDetails { get; set; }

  public PackingSlipObject() {
    productDetails = new List<ProductDetailsForPackingSlip>();
    productLineItemName = '';
  }
}
