public class TriggerOnOpportunityLineItemHandler {
  List<OpportunityLineItem__c> newOppLineItem;
  Map<Id, OpportunityLineItem__c> oldOppLineItem;
  public TriggerOnOpportunityLineItemHandler(
    List<OpportunityLineItem__c> newValues,
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    this.newOppLineItem = newValues;
    this.oldOppLineItem = oldValues;
  }
  public void afterUpdate() {
    TriggerOnOpportunityLineItemService.checkAndUpdateStatusOfOutdatedCheckbox(
      newOppLineItem,
      oldOppLineItem
    );
    TriggerOnOpportunityLineItemService.updateHistoryAfterUpdate(
      newOppLineItem,
      oldOppLineItem
    );
    TriggerOnOpportunityLineItemService.updateSOHistoryafterupdate(
      newOppLineItem,
      oldOppLineItem
    );
  }

  public void afterInsert() {
    TriggerOnOpportunityLineItemService.checkAndUpdateStatusOfOutdatedCheckboxAfterInsert(
      newOppLineItem
    );
    TriggerOnOpportunityLineItemService.createDesignProjects(newOppLineItem);
    TriggerOnOpportunityLineItemService.updateHistoryAfterInsert(
      newOppLineItem
    );
    TriggerOnOpportunityLineItemService.updateSOHistoryafterInsert(
      newOppLineItem
    );
  }

  public void beforeDelete() {
    TriggerOnOpportunityLineItemService.deleteRecordsRelatedToOppLineItems(
      newOppLineItem,
      oldOppLineItem
    );
    TriggerOnOpportunityLineItemService.updateHistoryBeforeDelete(
      oldOppLineItem
    );
    TriggerOnOpportunityLineItemService.updateSOHistoryAfterDelete(
      oldOppLineItem
    );
  }
}
