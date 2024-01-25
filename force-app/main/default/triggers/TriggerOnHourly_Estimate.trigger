trigger TriggerOnHourly_Estimate on Hourly_Estimate__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  system.debug('TriggerOnHourly_Estimate called');
  TriggerDispatcher.run(new Hourly_EstimateTriggerHandler());
}
