public with sharing class Hourly_EstimateTriggerService {
  // to set the default value of Hourly Rate on Hourly_Estimate
  public static void hourlyRateHandle(
    List<Hourly_Estimate__c> new_Hourly_Estimate_List,
    Map<Id, Hourly_Estimate__c> old_Hourly_Estimate_Map
  ) {
    final String recordName = 'Tier_Expense';
    Tier_Expense__mdt expenseInfo = [
      SELECT Tier_1_Expense__c, Tier_2_Expense__c, Tier_3_Expense__c
      FROM Tier_Expense__mdt
      WHERE DeveloperName = :recordName
      LIMIT 1
    ];
    for (Hourly_Estimate__c estimate : new_Hourly_Estimate_List) {
      if (estimate != null) {
        // insert case
        if (old_Hourly_Estimate_Map == null) {
          if (estimate.Region__c != null && estimate.Hourly_Rate__c == null) {
            if (estimate.Region__c.contains('1')) {
              estimate.Hourly_Rate__c = expenseInfo.Tier_1_Expense__c;
            } else if (estimate.Region__c.contains('2')) {
              estimate.Hourly_Rate__c = expenseInfo.Tier_2_Expense__c;
            } else if (estimate.Region__c.contains('3')) {
              estimate.Hourly_Rate__c = expenseInfo.Tier_3_Expense__c;
            }
          }
        } else if (
          estimate.Region__c != null &&
          estimate.Region__c !=
          old_Hourly_Estimate_Map.get(estimate.Id).Region__c &&
          estimate.Hourly_Rate__c ==
          old_Hourly_Estimate_Map.get(estimate.Id).Hourly_Rate__c
        ) {
          //update case
          if (estimate.Region__c.contains('1')) {
            estimate.Hourly_Rate__c = expenseInfo.Tier_1_Expense__c;
          } else if (estimate.Region__c.contains('2')) {
            estimate.Hourly_Rate__c = expenseInfo.Tier_2_Expense__c;
          } else if (estimate.Region__c.contains('3')) {
            estimate.Hourly_Rate__c = expenseInfo.Tier_3_Expense__c;
          }
        }
      }
    }
  }
}
