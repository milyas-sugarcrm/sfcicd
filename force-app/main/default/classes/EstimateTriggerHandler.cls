public class EstimateTriggerHandler {
  List<Estimate__c> newEst;
  Map<Id, Estimate__c> oldEst;
  public EstimateTriggerHandler(
    List<Estimate__c> newValues,
    Map<Id, Estimate__c> oldValues
  ) {
    newEst = newValues;
    oldEst = oldValues;
  }
  public void afterUpdate() {
    EstimateTriggerService.checkAndUpdateStatusOfOutdatedCheckbox(
      newEst,
      oldEst
    );
    EstimateTriggerService.updateDesignProjectOnChangeOwner(newEst, oldEst);
  }
  public void afterInsert() {
    if (!system.isBatch() && !System.isFuture()) {
      //EstimateTriggerService.changeTheStageOfOpportunity(newEst,null);
    }
  }
  public void beforeInsert() {
    if (!system.isBatch() && !System.isFuture()) {
      EstimateTriggerService.populateTheEstimateFields(newEst, null);
    }
  }
  public void beforeDelete() {
    if (!system.isBatch() && !System.isFuture()) {
      EstimateTriggerService.deleteOppLineItemsRelatedToEstimate(
        newEst,
        oldEst
      );
      EstimateTriggerService.deletePDF(oldEst);
      EstimateTriggerService.deleteEstimateHistory(oldEst);
      EstimateTriggerService.deleteQboRecords(oldEst); //
    }
  }
  public void afterDelete() {
    EstimateTriggerService.goBackToPresentation(oldEst);
  }
}
