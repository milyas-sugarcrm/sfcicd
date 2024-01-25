public class ArtworkTriggerHandler {
  List<OpportunityLineItem_ArtWork__c> newArtworks;
  Map<Id, OpportunityLineItem_ArtWork__c> oldArtworks;
  public ArtworkTriggerHandler(
    List<OpportunityLineItem_ArtWork__c> newValues,
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
  ) {
    this.newArtworks = newValues;
    this.oldArtworks = oldValues;
  }
  public void afterUpdate() {
    ArtworkTriggerService.checkAndUpdateStatusOfOutdatedCheckbox(
      newArtworks,
      oldArtworks
    );
    ArtworkTriggerService.updateHistoryafterupdate(newArtworks, oldArtworks);
    ArtworkTriggerService.updateSOHistoryAfterupdate(newArtworks, oldArtworks);
  }
  public void afterInsert() {
    ArtworkTriggerService.updateHistoryAfterInsert(newArtworks);
    ArtworkTriggerService.updateSOHistoryafterInsert(newArtworks);
  }
  public void beforeDelete() {
    ArtworkTriggerService.updateHistoryBeforeDelete(oldArtworks);
  }
  public void afterDelete() {
    ArtworkTriggerService.updateSOHistoryAfterDelete(oldArtworks);
  }
}
