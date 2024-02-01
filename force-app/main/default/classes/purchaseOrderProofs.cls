public class purchaseOrderProofs {
  @AuraEnabled
  public Id purchaseOrderId { get; set; }
  @AuraEnabled
  public Boolean allProofUploadedStatus { get; set; }
  @AuraEnabled
  public String purchaseOrderNumber { get; set; }
  @AuraEnabled
  public String supplier { get; set; }
  @AuraEnabled
  public String shipTo { get; set; }
  @AuraEnabled
  public List<proofDetailsObject> proofs { get; set; }

  public purchaseOrderProofs() {
    purchaseOrderNumber = '';
    supplier = '';
    allProofUploadedStatus = false;
    shipTo = '';
    proofs = new List<proofDetailsObject>();
  }
}
