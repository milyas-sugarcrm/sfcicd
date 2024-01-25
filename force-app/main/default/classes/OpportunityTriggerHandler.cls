public class OpportunityTriggerHandler {
  Map<Id, Account> linkedAccs;
  public static Boolean firstRun1 = true;
  public static Boolean firstRun2 = true;
  List<Opportunity> newOpps;
  Map<Id, Opportunity> oldOpps;
  public OpportunityTriggerHandler(
    List<Opportunity> newValues,
    Map<Id, Opportunity> oldValues
  ) {
    newOpps = newValues;
    oldOpps = oldValues;
    Set<Id> oppIds = new Set<Id>();
    if (newOpps != null) {
      for (Opportunity opp : newOpps) {
        oppIds.add(opp.AccountId);
      }
      linkedAccs = new Map<Id, Account>(
        [
          SELECT Id, QBO_Accounts_Count__c, RecordTypeId, RecordType.Name
          FROM Account
          WHERE Id = :oppIds
        ]
      );
    }
  }
  public void beforeInsert() {
    OpportunityTriggerService.handleRecordType(newOpps);
    OpportunityTriggerService.restricStagesBeforeInsert(newOpps);
    OpportunityTriggerService.estimateStageChecks(newOpps, null, linkedAccs);
    OpportunityTriggerService.populatePresentationFieldsBeforeInsert(newOpps);
  }
  public void afterInsert() {
    OpportunityTriggerService.DeleteOpp(newOpps); // Calling this Fucntion to delete an Opportunity.
    OpportunityTriggerService.createHourlyEstimates(newOpps);
    OpportunityTriggerService.createExpensesMiscellaneous(newOpps);
  }

  public void beforeUpdate() {
    OpportunityTriggerService.populatePresentationFields(newOpps, oldOpps);
    OpportunityTriggerService.restrictStage(newOpps, oldOpps);
    OpportunityTriggerService.checkAndUpdateStatusOfOutdatedCheckbox(
      newOpps,
      oldOpps
    );
    OpportunityTriggerService.ChangeOwner(newOpps, oldOpps);
    OpportunityTriggerService.handleSowApprovalDate(newOpps, oldOpps);
  }

  public void afterUpdate() {
    OpportunityTriggerService.updateMargin(newOpps, oldOpps);
    OpportunityTriggerService.updateMarginAtPresentationStage(newOpps, oldOpps);

    if (firstRun1 == true) {
      OpportunityTriggerService.CreateCampaignOnOppClose(newOpps);
      OpportunityTriggerService.createInitialBillingForCampaign(newOpps);
    }

    if (!system.isBatch() && !System.isFuture() && firstRun2 == true) {
      OpportunityTriggerService.createEstimate(newOpps, oldOpps, linkedAccs);
      firstRun2 = false;
    }
  }

  public void beforeDelete() {
    if (!system.isBatch() && !System.isFuture()) {
      OpportunityTriggerService.deleteOppLineItemsRelatedToOpportunity(
        newOpps,
        oldOpps
      );
    }
  }
}
