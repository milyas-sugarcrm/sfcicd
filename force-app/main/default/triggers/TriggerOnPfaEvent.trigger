trigger TriggerOnPfaEvent on PFA_Event__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  TriggerDispatcher.run(new PFAEventTriggerHandler());
}
