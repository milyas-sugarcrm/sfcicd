trigger TriggerOnContentVersion on ContentVersion(after insert) {
  ContentVersionTriggerHandler handler = new ContentVersionTriggerHandler(
    Trigger.new
  );

  if (Trigger.isInsert) {
    if (Trigger.isAfter) {
      handler.afterInsert();
    }
  }
}
