trigger TriggerOnLead on Lead(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      LeadTriggerHandler.handleBeforeInsert(Trigger.new);
      LeadTriggerHandlerforPFA.setLeadRecordType(Trigger.new); // Need to uncomment it on QA2
    }
    if (Trigger.isUpdate) {
      LeadTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
      LeadTriggerHandlerforPFA.sendEmailAndBellNotification(
        Trigger.new,
        Trigger.oldMap
      ); // Need to uncomment it on QA2
      //LeadTriggerHandlerforPFA.setStatusOnInsert(Trigger.new, Trigger.oldMap);              // Need to uncomment it on QA2
    }
    if (Trigger.isDelete) {
      LeadTriggerHandler.handleBeforeDelete(Trigger.old);
    }
  }
  if (Trigger.isAfter) {
    if (Trigger.isInsert) {
      LeadTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap);
    }
    if (Trigger.isUpdate) {
      LeadTriggerHandler.handleAfterUpdate(
        Trigger.new,
        Trigger.old,
        Trigger.newMap,
        Trigger.oldMap
      );
      LeadTriggerHandlerforPFA.convertLeadOnStatusCompleted(
        Trigger.new,
        Trigger.oldMap
      );
    }
  }
}
