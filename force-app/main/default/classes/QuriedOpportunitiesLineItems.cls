public class QuriedOpportunitiesLineItems {
  public String id { get; set; }
  public String name { get; set; }
  public String description { get; set; }
  public List<String> lineItemColors { get; set; }
  public Boolean colorSize { get; set; }
  public List<PricingLineItem__c> lineItemPricing { get; set; }
  public List<OpportunityLineItem_Add_Fixed_Charge__c> lineItemFixedCharges {
    get;
    set;
  }
  public Boolean fixedChargesSize { get; set; }
  public List<Line_Item_Pricing_RunCharge__c> lineItemRunCharges { get; set; }
  public Boolean runChargesSize { get; set; }
  public Boolean pricingSize { get; set; }
  public List<String> lineItemSizes { get; set; }
  public Boolean sizesSize { get; set; }
  public List<Comment__c> lineItemComments { get; set; }
  public List<Images> filesDownloadURL { get; set; }
  public String activeImage { get; set; }
  public Images img { get; set; }
  public String activeImagePreviewLink { get; set; }
  public Boolean imageExits { get; set; }
  public QuriedOpportunitiesLineItems() {
    id = null;
    name = '';
    description = '';
    colorSize = false;
    pricingSize = false;
    runChargesSize = false;
    activeImagePreviewLink = null;
    lineItemColors = new List<String>();
    lineItemPricing = new List<PricingLineItem__c>();
    lineItemFixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    lineItemRunCharges = new List<Line_Item_Pricing_RunCharge__c>();
    lineItemSizes = new List<String>();
    lineItemComments = new List<Comment__c>();
    filesDownloadURL = new List<Images>();
    activeImage = null;
  }
}
