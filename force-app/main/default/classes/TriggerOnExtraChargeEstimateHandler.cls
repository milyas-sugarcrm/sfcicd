public class TriggerOnExtraChargeEstimateHandler {
  List<ExtraChargesEstimate__c> newExtraCharges;
  Map<Id, ExtraChargesEstimate__c> oldExtraCharges;
  static Boolean firstRun = true;
  static Boolean firstRunForUpdate = true;
  public TriggerOnExtraChargeEstimateHandler(
    List<ExtraChargesEstimate__c> newValues,
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    this.newExtraCharges = newValues;
    this.oldExtraCharges = oldValues;
  }
  public void beforeUpdate() {
    if (firstRunForUpdate) {
      firstRunForUpdate = false;
      //TriggerOnExtraChargesEstimateService.updateDesignProjects(newExtraCharges,oldExtraCharges);
    }
  }
  public void afterUpdate() {
    TriggerOnExtraChargesEstimateService.updateDesignProjectsBeforeUpdate(
      newExtraCharges,
      oldExtraCharges
    );
    TriggerOnExtraChargesEstimateService.updateHistoryafterupdate(
      newExtraCharges,
      oldExtraCharges
    );
    TriggerOnExtraChargesEstimateService.updateSOHistoryafterUpdate(
      newExtraCharges,
      oldExtraCharges
    );
  }
  public void afterInsert() {
    {
      //if(firstRun)
      TriggerOnExtraChargesEstimateService.updateDesignProjectsAfterInsert(
        newExtraCharges,
        oldExtraCharges
      );
      TriggerOnExtraChargesEstimateService.updateHistoryAfterInsert(
        newExtraCharges
      );
      TriggerOnExtraChargesEstimateService.updateSOHistoryafterInsert(
        newExtraCharges
      );
    }
  }
  public void beforeDelete() {
    TriggerOnExtraChargesEstimateService.updateDesignProjectsBeforeDelete(
      oldExtraCharges
    );
    TriggerOnExtraChargesEstimateService.updateHistoryBeforeDelete(
      oldExtraCharges
    );
  }
  public void afterDelete() {
    TriggerOnExtraChargesEstimateService.updateSOHistoryafterDelete(
      oldExtraCharges
    );
  }
}
