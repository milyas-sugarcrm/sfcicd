trigger TriggerOnContact on Contact(after update, before insert) {
  if (System.Label.Triggers == 'True') {
    if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        Boolean dataChanged = ContactTriggerHandler.checkFieldsChangedForSync(
          Trigger.new,
          Trigger.oldMap
        );
        if (dataChanged) {
          ContactTriggerHandler.updateFieldOnAccount(Trigger.new);
        }
      }
    }
    if (Trigger.isBefore) {
      if (Trigger.isInsert) {
        ContactTriggerHandler.handleRecordType(Trigger.new);
      }
    }
  }
}
