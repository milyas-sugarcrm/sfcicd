trigger TriggerOnPandaDocDocument on pandadoc__PandaDocDocument__c(
  after update
) {
  if (Trigger.isAfter) {
    if (Trigger.isUpdate) {
      PandaDocDocumentTriggerHandler.updateSLADocumentField(Trigger.new);
    }
  }
}
