public class DesignProjectTriggerHandler {
  List<Design_Project__c> newDesignProjects;
  Map<Id, Design_Project__c> oldDesignProjects;
  public DesignProjectTriggerHandler(
    List<Design_Project__c> newValues,
    Map<Id, Design_Project__c> oldValues
  ) {
    this.newDesignProjects = newValues;
    this.oldDesignProjects = oldValues;
  }
  public void afterUpdate() {
    //DesignProjectTriggerService.updateDesignBank(oldDesignProjects, newDesignProjects);
    DesignProjectTriggerService.checkValidityforEstimateCreditsAfterUpdate(
      oldDesignProjects,
      newDesignProjects
    );
  }
  public void beforeUpdate() {
    DesignProjectTriggerService.updateOnCompletedDesignProject(
      oldDesignProjects,
      newDesignProjects
    );
  }
  public void beforeDelete() {
    DesignProjectTriggerService.updateDesignBankOnDeletion(oldDesignProjects);
  }
}
