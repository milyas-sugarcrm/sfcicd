/*
 * Description: This class is for Account trigger handler methods business logic
 * Author: Imran
 * Name: AccountTriggerHandler
 * Created Date: 26th Juli 2023
 * Version:1.0.0 - Imran - Account trigger handler methods business logic
 */
public with sharing class AccountTriggerHelper {
  public static void beforeInsert(List<Account> newList) {
    AccountService.checkDuplicateAccount(newList);
  }
  public static void afterInsert(
    List<Account> newList,
    Map<Id, Account> newMap
  ) {
    system.debug('account is intserted' + newList[0]);
  }
}
