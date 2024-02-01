public class TriggerOnOppLineItemAttachmentHandler {
  List<OpportunityLineItemAttachment__c> newRunCharges;
  Map<Id, OpportunityLineItemAttachment__c> oldRunCharges;
  public TriggerOnOppLineItemAttachmentHandler(
    List<OpportunityLineItemAttachment__c> newValues,
    Map<Id, OpportunityLineItemAttachment__c> oldValues
  ) {
    this.newRunCharges = newValues;
    this.oldRunCharges = oldValues;
  }
  public void afterUpdate() {
    TriggerOnOppLineItemAttachmentService.checkAndUpdateStatusOfOutdatedCheckbox(
      newRunCharges,
      oldRunCharges
    );
  }
}
