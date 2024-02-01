public class OpportunityDepositInvoice {
  public String name { get; set; }
  public Double lineItemQuantity { get; set; }
  public Double lineItemPricing { get; set; }
  public decimal lineItemPricingAmount { get; set; }
  public List<ExtraChargesEstimate__c> lineItemExtraCharges { get; set; }
  public List<PricingLineItem__c> lineItemPricings { get; set; }
  public OpportunityDepositInvoice() {
    lineItemQuantity = 0;
    lineItemPricing = 0;
    lineItemPricingAmount = 0;
    lineItemExtraCharges = new List<ExtraChargesEstimate__c>();
    lineItemPricings = new List<PricingLineItem__c>();
  }
}
