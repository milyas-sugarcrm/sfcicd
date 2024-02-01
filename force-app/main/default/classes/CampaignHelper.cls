public with sharing class CampaignHelper {
  public static void afterInsert(List<PFA_Campaign__c> newList) {
    CampaignTriggerService.PopulateIdOnOpp(newList);
    CampaignTriggerService.populateOppProducts(newList);
  }
}
