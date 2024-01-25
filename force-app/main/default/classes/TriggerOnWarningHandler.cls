public class TriggerOnWarningHandler {
  List<WarningsOpportunityLineItem__c> newWarnings;
  Map<Id, WarningsOpportunityLineItem__c> oldWarnings;
  public TriggerOnWarningHandler(
    List<WarningsOpportunityLineItem__c> newValues,
    Map<Id, WarningsOpportunityLineItem__c> oldValues
  ) {
    this.newWarnings = newValues;
    this.oldWarnings = oldValues;
  }
  public void afterUpdate() {
    TriggerOnWarningService.updateHistoryAfterUpdate(newWarnings, oldWarnings);
  }
  public void afterInsert() {
    TriggerOnWarningService.updateHistoryAfterInsert(newWarnings);
  }
  public void beforeDelete() {
    TriggerOnWarningService.updateHistoryBeforeDelete(oldWarnings);
  }
}
