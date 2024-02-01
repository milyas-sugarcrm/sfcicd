public class LeadTriggerHandler {
  public static void handleBeforeInsert(List<Lead> newLeads) {
    LeadTriggerService.LeadProcess(newLeads, true);
  }

  public static void handleBeforeUpdate(
    List<Lead> newLeads,
    Map<Id, Lead> oldLeadMap
  ) {
    LeadTriggerService.LeadProcess(newLeads, false);
  }

  public static void handleBeforeDelete(List<Lead> deletedLeads) {
  }

  public static void handleAfterInsert(
    List<Lead> newLeads,
    Map<Id, Lead> newLeadMap
  ) {
  }

  public static void handleAfterUpdate(
    List<Lead> updatedLeads,
    List<Lead> oldLeads,
    Map<Id, Lead> newLeadMap,
    Map<Id, Lead> oldLeadMap
  ) {
  }
}
