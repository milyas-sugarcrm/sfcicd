public class QuriedProductsForOpportunityEstimate {
  public String id { get; set; }
  public String name { get; set; }
  public String color { get; set; }
  public String size { get; set; }
  public String description { get; set; }
  public Double lineItemQuantity { get; set; }
  public Double lineItemPricing { get; set; }
  public String lineItemPricingColor { get; set; }
  public String lineItemPricingSize { get; set; }
  public decimal lineItemPricingAmount { get; set; }
  public decimal lineItemTotalPricingAmount { get; set; }
  public List<ExtraChargesEstimate__c> lineItemExtraCharges { get; set; }
  public String lineItemColors { get; set; }
  public String lineItemSizes { get; set; }
  public List<OpportunityLineItem_ArtWork__c> lineItemArtWork { get; set; }
  public List<OpportunityLineItem_Add_Fixed_Charge__c> lineItemFixedCharges {
    get;
    set;
  }
  public List<Line_Item_Pricing_RunCharge__c> lineItemRunCharges { get; set; }
  public List<PricingLineItem__c> lineItemPricings { get; set; }
  public List<ArtworkDetailsObject> artworkDetails { get; set; }
  public List<Images> filesDownloadURL { get; set; }
  public String activeImage { get; set; }
  public Images img { get; set; }
  public String activeImagePreviewLink { get; set; }
  public Boolean imageExits { get; set; }
  public QuriedProductsForOpportunityEstimate() {
    id = '';
    name = '';
    color = '';
    size = '';
    description = '';
    lineItemQuantity = 0;
    lineItemPricing = 0;
    lineItemPricingColor = '0';
    lineItemPricingSize = '0';
    lineItemPricingAmount = 0;
    lineItemTotalPricingAmount = 0;
    lineItemColors = '';
    lineItemSizes = '';
    activeImage = null;
    artworkDetails = new List<ArtworkDetailsObject>();
    lineItemExtraCharges = new List<ExtraChargesEstimate__c>();
    lineItemArtWork = new List<OpportunityLineItem_ArtWork__c>();
    lineItemFixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    lineItemRunCharges = new List<Line_Item_Pricing_RunCharge__c>();
    filesDownloadURL = new List<Images>();
    lineItemExtraCharges = new List<ExtraChargesEstimate__c>();
    lineItemPricings = new List<PricingLineItem__c>();
  }
}
