public with sharing class artworkResults {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public String imprintType { get; set; }
  @AuraEnabled
  public String title { get; set; }
  @AuraEnabled
  public String proofRequired { get; set; }
  @AuraEnabled
  public String logoName { get; set; }
  @AuraEnabled
  public String logoSize { get; set; }
  @AuraEnabled
  public String logoColor { get; set; }
  @AuraEnabled
  public String repeatLogo { get; set; }
  @AuraEnabled
  public String supplierNotes { get; set; }
  @AuraEnabled
  public String documentId { get; set; }
  @AuraEnabled
  public String opportunityLineItem { get; set; }
  @AuraEnabled
  public integer counter { get; set; }
  @AuraEnabled
  public Boolean artworkImageSupportExtension { get; set; }
}
