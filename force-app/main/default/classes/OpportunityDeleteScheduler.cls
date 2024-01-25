global class OpportunityDeleteScheduler implements Schedulable {
  private List<Id> opportunityIdsToDelete;

  global OpportunityDeleteScheduler(List<Id> oppIds) {
    this.opportunityIdsToDelete = oppIds;
  }

  global void execute(SchedulableContext sc) {
    deleteOpportunities();
  }
  private void deleteOpportunities() {
    List<Opportunity> oppListToDelete = [
      SELECT Id
      FROM Opportunity
      WHERE Id IN :opportunityIdsToDelete
    ];
    if (!oppListToDelete.isEmpty()) {
      delete oppListToDelete;
    }
  }
}
