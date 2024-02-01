trigger TriggerOnArtwork on OpportunityLineItem_ArtWork__c(
  after update,
  after insert,
  before delete,
  after delete
) {
  if (System.Label.Triggers == 'True') {
    ArtworkTriggerHandler handler = new ArtworkTriggerHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        handler.afterUpdate();
      }
      if (Trigger.isInsert) {
        handler.afterInsert();
      }
      if (Trigger.isDelete) {
        handler.afterDelete();
      }
    }
    if (Trigger.isBefore) {
      if (Trigger.isDelete) {
        handler.beforeDelete();
      }
    }
  }

}
