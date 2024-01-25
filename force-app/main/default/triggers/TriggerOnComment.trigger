trigger TriggerOnComment on Comment__c(after insert) {
  if (System.Label.Triggers == 'True') {
    TriggerOnCommentHandler handler = new TriggerOnCommentHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isAfter) {
      if (Trigger.isInsert) {
        handler.afterInsert();
      }
    }
  }

}
