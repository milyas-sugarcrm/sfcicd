public class TriggerOnRunChargesHandler {
  List<Line_Item_Pricing_RunCharge__c> newRunCharges;
  Map<Id, Line_Item_Pricing_RunCharge__c> oldRunCharges;
  public TriggerOnRunChargesHandler(
    List<Line_Item_Pricing_RunCharge__c> newValues,
    Map<Id, Line_Item_Pricing_RunCharge__c> oldValues
  ) {
    this.newRunCharges = newValues;
    this.oldRunCharges = oldValues;
  }
  public void afterUpdate() {
    TriggerOnRunChargesService.checkAndUpdateStatusOfOutdatedCheckbox(
      newRunCharges,
      oldRunCharges
    );
  }
}
