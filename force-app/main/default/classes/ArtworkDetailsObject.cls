public with sharing class ArtworkDetailsObject {
  @AuraEnabled
  public OpportunityLineItem_ArtWork__c artwork { get; set; }
  @AuraEnabled
  public List<OpportunityLineItem_ArtWork__c> artworkList { get; set; }
  @AuraEnabled
  public String artworkTitle { get; set; }
  @AuraEnabled
  public Boolean artworkImageExist { get; set; }
  @AuraEnabled
  public Boolean artworkImageSupportExtension { get; set; }
  @AuraEnabled
  public Id contentVersionId { get; set; }

  @AuraEnabled
  public List<ExtraChargesEstimate__c> extraCharges { get; set; }
  public ArtworkDetailsObject() {
    artworkImageSupportExtension = false;
    artwork = new OpportunityLineItem_ArtWork__c();
    extraCharges = new List<ExtraChargesEstimate__c>();
    artworkList = new List<OpportunityLineItem_ArtWork__c>();
  }
}
