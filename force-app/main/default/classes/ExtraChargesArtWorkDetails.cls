public class ExtraChargesArtWorkDetails {
  @AuraEnabled
  public String artworkName;
  @AuraEnabled
  public List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges {
    get;
    set;
  }
  @AuraEnabled
  public List<ExtraChargesEstimate__c> extraChargeswithArtWork { get; set; }

  public ExtraChargesArtWorkDetails() {
    fixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    extraChargeswithArtWork = new List<ExtraChargesEstimate__c>();
    artworkName = '';
  }
}
