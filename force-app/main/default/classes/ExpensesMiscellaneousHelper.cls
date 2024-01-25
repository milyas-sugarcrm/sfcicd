public with sharing class ExpensesMiscellaneousHelper {
  public static void beforeInsert(List<Expenses_Miscellaneous__c> newList) {
    ExpensesMiscellaneousTriggerService.hourlyRateHandle(newList, null);
  }

  public static void beforeUpdate(
    List<Expenses_Miscellaneous__c> newList,
    Map<Id, Expenses_Miscellaneous__c> oldmap
  ) {
    ExpensesMiscellaneousTriggerService.hourlyRateHandle(newList, oldmap);
  }
}
