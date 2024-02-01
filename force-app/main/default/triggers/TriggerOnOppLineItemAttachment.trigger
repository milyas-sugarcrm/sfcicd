trigger TriggerOnOppLineItemAttachment on OpportunityLineItemAttachment__c(
  after update
) {
  if (System.Label.Triggers == 'True') {
    TriggerOnOppLineItemAttachmentHandler handler = new TriggerOnOppLineItemAttachmentHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        handler.afterUpdate();
      }
    }
  }
}
