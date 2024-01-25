public class DepositInvoiceObject {
  @AuraEnabled
  public decimal deposit_percent;
  @AuraEnabled
  public decimal amount_recieved;
  @AuraEnabled
  public String confirmation;
  @AuraEnabled
  public String date_recieved;
  @AuraEnabled
  public Boolean Allow_credit_card;
  @AuraEnabled
  public decimal total;
  @AuraEnabled
  public String depositInvoicePreview;
  public void DepositInvoiceObject() {
    Allow_credit_card = false;
    total = 0;
    depositInvoicePreview = '';
  }
}
