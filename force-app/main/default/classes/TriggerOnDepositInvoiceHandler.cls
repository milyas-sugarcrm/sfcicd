public class TriggerOnDepositInvoiceHandler {
  List<Deposit_Invoice__c> newDepositInvoice;
  Map<Id, Deposit_Invoice__c> oldDepositInvoice;
  public TriggerOnDepositInvoiceHandler(
    List<Deposit_Invoice__c> newValues,
    Map<Id, Deposit_Invoice__c> oldValues
  ) {
    this.newDepositInvoice = newValues;
    this.oldDepositInvoice = oldValues;
  }
  public void afterInsert() {
    TriggerOnDepositInvoiceService.generatePDF(newDepositInvoice);
  }
}
