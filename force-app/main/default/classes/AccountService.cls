/*
 * Description: This class is for Account related functionalities
 * Author: Imran
 * Created Date: 27th July 2023
 * Name: AccountService
 * Version:1.0.0 - Imran - 27th July 2023
 */
public class AccountService {
  public static List<Account> updateAccountWithOutTrigger(
    List<Account> accountList
  ) {
    if (accountList != null && !accountList.isEmpty()) {
      AccountTriggerHanlderSample.TriggerDisabled = true;
      update accountList;
      AccountTriggerHanlderSample.TriggerDisabled = false;
    }
    return accountList;
  }

  public static List<Account> updateAccount(List<Account> accountList) {
    if (accountList != null && !accountList.isEmpty()) {
      update accountList;
    }
    // testing
    return accountList;
  }
  //example method
  public static list<Account> getAccountsByName(list<String> acctNames) {
    list<Account> lstAccount = new List<Account>();
    lstAccount = [SELECT Id, Name FROM Account WHERE Name = :acctNames];
    return lstAccount;
  }
  // This method is not needed. Use Duplicate rules
  public static void checkDuplicateAccount(List<Account> lstNewAccount) {
    List<String> accountNameList = new List<String>();
    for (Account accoun : lstNewAccount) {
      accountNameList.add(accoun.Name);
    }
    List<Account> listOfExistingAccounts = getAccountsByName(accountNameList);
    for (Account acc : listOfExistingAccounts) {
      for (Account accoun : lstNewAccount) {
        if (acc.Name == accoun.Name && acc.Id != accoun.Id) {
          accoun.addError(System.label.Duplicate_Accounts);
        }
      }
    }
  }
}
