public class TriggerOnFixedChargesHandler {
  List<OpportunityLineItem_Add_Fixed_Charge__c> newFixedCharges;
  Map<Id, OpportunityLineItem_Add_Fixed_Charge__c> oldFixedCharges;
  public TriggerOnFixedChargesHandler(
    List<OpportunityLineItem_Add_Fixed_Charge__c> newValues,
    Map<Id, OpportunityLineItem_Add_Fixed_Charge__c> oldValues
  ) {
    this.newFixedCharges = newValues;
    this.oldFixedCharges = oldValues;
  }
  public void afterUpdate() {
    TriggerOnFixedChargesService.checkAndUpdateStatusOfOutdatedCheckbox(
      newFixedCharges,
      oldFixedCharges
    );
  }
}
