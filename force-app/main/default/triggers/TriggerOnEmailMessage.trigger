trigger TriggerOnEmailMessage on EmailMessage(after insert) {
  TriggerOnEmailMessageHandler handler = new TriggerOnEmailMessageHandler(
    Trigger.new
  );

  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      handler.afterInsert();
    }
  }
}
