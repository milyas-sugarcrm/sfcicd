public class OpportunityViewPortalModelClass {
  public String imageUrl { get; set; }
  public String imageName { get; set; }
  public Boolean imageExist { get; set; }
  public String approvedBy { get; set; }
  public DateTime approveDate { get; set; }
  public String status { get; set; }
  public List<Comment__c> lineItemComments { get; set; }
  public List<Comment__c> proofComments { get; set; }
  public List<EmailMessages> emailList { get; set; }
  public List<String> proofRequiredNames { get; set; }
  public String proofRequiredDate { get; set; }
  public List<String> InProductionNames { get; set; }
  public String InProductionDate { get; set; }
  public List<Estimate__c> estimateList { get; set; }
  public String shippedName { get; set; }
  public String shippedDate { get; set; }
  public String shippedTrackingID { get; set; }
  public OpportunityViewPortalModelClass() {
    lineItemComments = new List<Comment__c>();
    proofComments = new List<Comment__c>();
    emailList = new List<EmailMessages>();
    estimateList = new List<Estimate__c>();
    proofRequiredNames = new List<String>();
    InProductionNames = new List<String>();
    shippedName = '';
    shippedDate = '';
    shippedTrackingID = '';
    InProductionDate = '';
    proofRequiredDate = '';
    status = '';
    approvedBy = '';
    imageExist = false;
    approveDate = null;
    imageUrl = '';
    imageName = '';
  }
  public class EmailMessages {
    @AuraEnabled
    public String fromName { get; set; }
    @AuraEnabled
    public String FromAddress { get; set; }
    @AuraEnabled
    public String Subject { get; set; }
    @AuraEnabled
    public String TextBody { get; set; }
    @AuraEnabled
    public String ToAddress { get; set; }
    @AuraEnabled
    public String CcAddress { get; set; }
    @AuraEnabled
    public DateTime CreatedDate { get; set; }
    public EmailMessages() {
      fromName = '';
      FromAddress = '';
      Subject = '';
      TextBody = '';
    }
  }
}
