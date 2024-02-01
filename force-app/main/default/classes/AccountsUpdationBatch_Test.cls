@isTest
public class AccountsUpdationBatch_Test {
  @isTest
  public static void testAccountUpdation() {
    List<Account> lstAccount = new List<Account>();
    for (Integer i = 0; i < 200; i++) {
      Account acc = new Account();
      acc.Name = 'Name' + i;
      acc.QuickBooks_Accounts__c = 'Team Phun';
      acc.BillingStreet = '101';
      acc.QB_Record_ID__c = String.valueOf(i + 100);
      acc.Billing_Email__c = 'saad.ahmad@rolustech.net';
      lstAccount.add(acc);
    }
    insert lstAccount;
    Test.startTest();
    AccountsUpdationBatch obj = new AccountsUpdationBatch();
    DataBase.executeBatch(obj);

    Test.stopTest();
  }
}
