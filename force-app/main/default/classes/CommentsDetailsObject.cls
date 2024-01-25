public class CommentsDetailsObject {
  @AuraEnabled
  public String comment { get; set; }
  @AuraEnabled
  public Datetime commentDate { get; set; }
  @AuraEnabled
  public String user { get; set; }
  @AuraEnabled
  public String supplier { get; set; }
  @AuraEnabled
  public String opportunityName { get; set; }
  @AuraEnabled
  public String documentId { get; set; }
  @AuraEnabled
  public String poNumber { get; set; }
}
