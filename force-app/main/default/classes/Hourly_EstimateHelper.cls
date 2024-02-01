public with sharing class Hourly_EstimateHelper {
  public static void beforeInsert(List<Hourly_Estimate__c> newList) {
    Hourly_EstimateTriggerService.hourlyRateHandle(newList, null);
  }

  public static void beforeUpdate(
    List<Hourly_Estimate__c> newList,
    Map<Id, Hourly_Estimate__c> oldmap
  ) {
    Hourly_EstimateTriggerService.hourlyRateHandle(newList, oldmap);
  }
}
