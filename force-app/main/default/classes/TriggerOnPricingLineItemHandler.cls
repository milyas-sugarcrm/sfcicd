public class TriggerOnPricingLineItemHandler {
  List<PricingLineItem__c> newPricingLineItem;
  Map<Id, PricingLineItem__c> oldPricingLineItem;
  static Boolean firstRun = true;
  static Boolean firstRunForUpdate = true;
  public TriggerOnPricingLineItemHandler(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    this.newPricingLineItem = newValues;
    this.oldPricingLineItem = oldValues;
  }
  public void beforeUpdate() {
    if (firstRunForUpdate) {
      firstRunForUpdate = false;
      TriggerOnPricingLineItemService.checkAndUpdateStatusOfOutdatedCheckbox(
        newPricingLineItem,
        oldPricingLineItem
      );
    }
  }
  public void afterUpdate() {
    TriggerOnPricingLineItemService.updateDesignProjectsAfterUpdate(
      newPricingLineItem,
      oldPricingLineItem
    );
    TriggerOnPricingLineItemService.updateHistoryafterupdate(
      newPricingLineItem,
      oldPricingLineItem
    );
    TriggerOnPricingLineItemService.updateSOHistoryafterupdate(
      newPricingLineItem,
      oldPricingLineItem
    );
  }
  public void afterInsert() {
    {
      //if(firstRun)
      TriggerOnPricingLineItemService.updateDesignProjectsAfterInsert(
        newPricingLineItem,
        oldPricingLineItem
      );
      firstRun = false;
      TriggerOnPricingLineItemService.updateHistoryafterInsert(
        newPricingLineItem,
        oldPricingLineItem
      );
      TriggerOnPricingLineItemService.updateSOHistoryafterInsert(
        newPricingLineItem,
        oldPricingLineItem
      );
    }
  }
  public void beforeDelete() {
    TriggerOnPricingLineItemService.updateDesignProjectsBeforeDelete(
      oldPricingLineItem
    );
    TriggerOnPricingLineItemService.updateHistoryAfterDelete(
      oldPricingLineItem
    );
    TriggerOnPricingLineItemService.updateSOHistoryAfterDelete(
      oldPricingLineItem
    );
  }
  public void beforeInsert() {
    //TriggerOnPricingLineItemService.updateDesignProjectsOnBeforeInsert(newPricingLineItem,oldPricingLineItem);
  }
}
