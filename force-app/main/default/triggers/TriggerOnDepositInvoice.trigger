trigger TriggerOnDepositInvoice on Deposit_Invoice__c(
  after update,
  after insert
) {
  TriggerOnDepositInvoiceHandler handler = new TriggerOnDepositInvoiceHandler(
    Trigger.new,
    Trigger.oldMap
  );

  if (Trigger.isAfter) {
    handler.afterInsert();
  }

}
