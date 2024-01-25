public with sharing class ExpensesMiscellaneousTriggerService {
  // to set the default value of Estimated_Cost__c on ExpensesMiscellaneous
  public static void hourlyRateHandle(
    List<Expenses_Miscellaneous__c> new_ExpensesMiscellaneous_List,
    Map<Id, Expenses_Miscellaneous__c> old_ExpensesMiscellaneous_Map
  ) {
    final String recordName = 'cost1';

    Expense_Cost_SOW__mdt expenseInfo = [
      SELECT
        Materials_Samples_Purchase__c,
        PFA_Handling_Fees__c,
        Scheduling_Reporting_Software__c,
        Shipping_Postage_Handling__c,
        Storage__c
      FROM Expense_Cost_SOW__mdt
      WHERE DeveloperName = :recordName
      LIMIT 1
    ];
    for (Expenses_Miscellaneous__c expense : new_ExpensesMiscellaneous_List) {
      if (expense != null) {
        // insert case
        if (old_ExpensesMiscellaneous_Map == null) {
          if (
            expense.Expense_Type__c != null &&
            expense.Estimated_Cost__c == null
          ) {
            if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_1)) {
              expense.Estimated_Cost__c = expenseInfo.Materials_Samples_Purchase__c;
            } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_2)) {
              expense.Estimated_Cost__c = expenseInfo.Storage__c;
            } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_3)) {
              expense.Estimated_Cost__c = expenseInfo.PFA_Handling_Fees__c;
            } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_4)) {
              expense.Estimated_Cost__c = expenseInfo.Shipping_Postage_Handling__c;
            } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_5)) {
              expense.Estimated_Cost__c = expenseInfo.Scheduling_Reporting_Software__c;
            }
          }
        } else if (
          expense.Expense_Type__c != null &&
          expense.Expense_Type__c !=
          old_ExpensesMiscellaneous_Map.get(expense.Id).Expense_Type__c &&
          expense.Estimated_Cost__c ==
          old_ExpensesMiscellaneous_Map.get(expense.Id).Estimated_Cost__c
        ) {
          //update case
          if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_1)) {
            expense.Estimated_Cost__c = expenseInfo.Materials_Samples_Purchase__c;
          } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_2)) {
            expense.Estimated_Cost__c = expenseInfo.Storage__c;
          } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_3)) {
            expense.Estimated_Cost__c = expenseInfo.PFA_Handling_Fees__c;
          } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_4)) {
            expense.Estimated_Cost__c = expenseInfo.Shipping_Postage_Handling__c;
          } else if (expense.Expense_Type__c.contains(Constants.EXP_TYPE_5)) {
            expense.Estimated_Cost__c = expenseInfo.Scheduling_Reporting_Software__c;
          }
        }
      }
    }
  }
}
