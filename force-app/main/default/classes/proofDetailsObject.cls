public class proofDetailsObject {
  @AuraEnabled
  public Id proofId { get; set; }
  @AuraEnabled
  public String fileName { get; set; }
  @AuraEnabled
  public Id contentVersionId { get; set; }
  @AuraEnabled
  public String imageUrl { get; set; }
  @AuraEnabled
  public String imagePreviewLink { get; set; }
  @AuraEnabled
  public String status { get; set; }
  @AuraEnabled
  public List<Comment__c> comments { get; set; }

  public proofDetailsObject() {
    fileName = '';
    status = '';
    comments = new List<Comment__c>();
  }
}
