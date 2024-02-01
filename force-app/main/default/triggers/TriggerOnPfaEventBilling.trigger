trigger TriggerOnPfaEventBilling on PFA_Event_Billing__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  TriggerDispatcher.run(new PFAEventBillingTriggerHandler());
}
