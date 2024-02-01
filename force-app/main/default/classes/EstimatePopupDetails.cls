public with sharing class EstimatePopupDetails {
  @AuraEnabled
  public String productName;
  @AuraEnabled
  public String productId;
  @AuraEnabled
  public Id oppLineItemId;
  @AuraEnabled
  public Id workOrderId;
  @AuraEnabled
  public String poId { get; set; }
  @AuraEnabled
  public String supplier;
  @AuraEnabled
  public String sku;
  @AuraEnabled
  public List<PricingLineItem__c> pricingDetails;
  @AuraEnabled
  public Id purchaseOrderId;
  @AuraEnabled
  public String poNumber { get; set; }
  @AuraEnabled
  public Id contentVerionId;
  @AuraEnabled
  public boolean isContentDocumentExist;
  @AuraEnabled
  public List<EstimateEditClass> estimateInlineList;
  @AuraEnabled
  public decimal units;
  @AuraEnabled
  public decimal total;
  @AuraEnabled
  public decimal costtotal;
  @AuraEnabled
  public decimal salesPrice;
  @AuraEnabled
  public decimal marginPercentage;
  @AuraEnabled
  public String tax;
  @AuraEnabled
  public String colorSize;
  @AuraEnabled
  public String description;
  @AuraEnabled
  public Shipping__c shippingDetails { get; set; }
  @AuraEnabled
  public Shipping_Information__c shippingInformationDetails { get; set; }
  @AuraEnabled
  public String shippingInfoAddress { get; set; }
  @AuraEnabled
  public String shippingAddress { get; set; }
  @AuraEnabled
  public String shippingName { get; set; }
  @AuraEnabled
  public String shippingShipTo { get; set; }
  @AuraEnabled
  public String shippingCompany { get; set; }
  @AuraEnabled
  public List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges {
    get;
    set;
  }
  @AuraEnabled
  public List<Line_Item_Pricing_RunCharge__c> runCharges { get; set; }
  @AuraEnabled
  public List<ExtraChargesArtWorkDetails> extraChargesWithArtWork { get; set; }
  @AuraEnabled
  public List<OpportunityLineItem_Add_Fixed_Charge__c> fixChargesWithoutArtWork {
    get;
    set;
  }
  @AuraEnabled
  public List<ExtraChargesEstimate__c> extraCharges { get; set; }
  @AuraEnabled
  public List<ExtraChargesEstimate__c> extraChargesWithoutArtWork { get; set; }
  @AuraEnabled
  public List<EstimateEditWithArtWork> estimateInlineListWithArtWork {
    get;
    set;
  }
  @AuraEnabled
  public Boolean validCredit;
  @AuraEnabled
  public Boolean designProduct;
  public EstimatePopupDetails() {
    estimateInlineList = new List<EstimateEditClass>();
    estimateInlineListWithArtWork = new List<EstimateEditWithArtWork>();
    fixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    extraCharges = new List<ExtraChargesEstimate__c>();
    extraChargesWithArtWork = new List<ExtraChargesArtWorkDetails>();
    fixChargesWithoutArtWork = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    runCharges = new List<Line_Item_Pricing_RunCharge__c>();
    extraChargesWithoutArtWork = new List<ExtraChargesEstimate__c>();
    productName = '';
    supplier = '';
    sku = '';
    tax = '';
    marginPercentage = 0;
    salesPrice = 0;
    total = 0;
    costtotal = 0;
    shippingAddress = '';
    shippingInfoAddress = '';
    colorSize = '';
    shippingInformationDetails = new Shipping_Information__c();
    shippingDetails = new Shipping__c();
    pricingDetails = new List<PricingLineItem__c>();
    poNumber = '';
    description = '';
    shippingName = '';
    shippingShipTo = '';
    shippingCompany = '';
  }
}
