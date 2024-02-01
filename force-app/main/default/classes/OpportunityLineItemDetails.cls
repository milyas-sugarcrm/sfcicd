public with sharing class OpportunityLineItemDetails {
  @AuraEnabled
  public String name { get; set; }
  @AuraEnabled
  public Decimal ESPProductId { get; set; }
  @AuraEnabled
  public List<Decimal> pricePerUnit { get; set; }
  @AuraEnabled
  public String supplier { get; set; }
  @AuraEnabled
  public String sku { get; set; }
  @AuraEnabled
  public String tax { get; set; }
  @AuraEnabled
  public String imprintMethods { get; set; }
  @AuraEnabled
  public String imprintingInfo { get; set; }
  @AuraEnabled
  public Decimal marginPercentage { get; set; }
  @AuraEnabled
  public Decimal marginAmount { get; set; }
  @AuraEnabled
  public Decimal total { get; set; }
  @AuraEnabled
  public Decimal subtotal { get; set; }
  @AuraEnabled
  public String description { get; set; }
  @AuraEnabled
  public String privateNotes { get; set; }
  @AuraEnabled
  public Decimal EstimatedQuantity { get; set; }
  @AuraEnabled
  public String priceLabel { get; set; }
  @AuraEnabled
  public List<PricingLineItem__c> pricingDetails { get; set; }
  @AuraEnabled
  public List<Comment__c> comments { get; set; }
  @AuraEnabled
  public List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges {
    get;
    set;
  }
  @AuraEnabled
  public List<Line_Item_Pricing_RunCharge__c> runCharges { get; set; }
  @AuraEnabled
  public List<WarningsOpportunityLineItem__c> warnings { get; set; }
  @AuraEnabled
  public List<OpportunityLineItem_ArtWork__c> artworks { get; set; }
  @AuraEnabled
  public List<Id> ImageContentVersionIds { get; set; }
  @AuraEnabled
  public List<ExtraChargesEstimate__c> internationalCosts { get; set; }
  @AuraEnabled
  public Boolean internationalCostExists { get; set; }
  @AuraEnabled
  public List<extraChargesObject> extraChargeList;
  @AuraEnabled
  public List<ExtraChargesEstimate__c> extraCharges;
  @AuraEnabled
  public List<ArtworkDetailsObject> artworkDetails;
  @AuraEnabled
  public String ProductID { get; set; }
  @AuraEnabled
  public Boolean extraChargesExists { get; set; }
  @AuraEnabled
  public Boolean pricingDetailsExists { get; set; }
  @AuraEnabled
  public Boolean productImageExist { get; set; }
  @AuraEnabled
  public String additionalColors { get; set; }
  @AuraEnabled
  public String additionalLocations { get; set; }
  public OpportunityLineItemDetails() {
    internationalCostExists = false;
    extraChargesExists = false;
    productImageExist = false;
    pricingDetailsExists = false;
    name = '';
    ESPProductId = null;
    supplier = '';
    sku = '';
    imprintMethods = '';
    imprintingInfo = '';
    description = '';
    privateNotes = '';
    priceLabel = '';
    pricingDetails = new List<PricingLineItem__c>();
    comments = new List<Comment__c>();
    fixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    warnings = new List<WarningsOpportunityLineItem__c>();
    artworks = new List<OpportunityLineItem_ArtWork__c>();
    ImageContentVersionIds = new List<Id>();
    extraChargeList = new List<extraChargesObject>();
    extraCharges = new List<ExtraChargesEstimate__c>();
    internationalCosts = new List<ExtraChargesEstimate__c>();
    artworkDetails = new List<ArtworkDetailsObject>();
    additionalColors = '';
    additionalLocations = '';
  }
}
