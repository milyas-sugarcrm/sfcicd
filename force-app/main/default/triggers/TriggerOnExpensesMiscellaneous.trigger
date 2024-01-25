trigger TriggerOnExpensesMiscellaneous on Expenses_Miscellaneous__c(
  before insert,
  after insert,
  before update,
  after update,
  before delete,
  after delete,
  after undelete
) {
  system.debug('Expenses_Miscellaneous__c called');
  TriggerDispatcher.run(new ExpensesMiscellaneousTriggerHandler());
}
