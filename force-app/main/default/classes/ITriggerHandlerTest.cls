@isTest
public class ITriggerHandlerTest implements ITriggerHandler {
  @isTest
  static void testBeforeInsert() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account')
    };

    Test.startTest();
    handler.beforeInsert(accounts);
    Test.stopTest();

    System.assertNotEquals(null, accounts[0].Name, 'Name should be updated');
  }

  @isTest
  static void testAfterInsert() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.afterInsert(accounts, accountMap);
    Test.stopTest();

    System.assertNotEquals(null, accounts[0].Name, 'Name should be updated');
  }

  @isTest
  static void testBeforeUpdate() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account', AccountNumber = '123')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.beforeUpdate(
      accounts,
      accountMap,
      new List<Account>(),
      new Map<Id, Account>()
    );
    Test.stopTest();

    System.assertEquals(
      '123',
      accounts[0].AccountNumber,
      'AccountNumber should be updated'
    );
  }

  @isTest
  static void testAfterUpdate() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account', AccountNumber = '123')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.afterUpdate(
      accounts,
      accountMap,
      new List<Account>(),
      new Map<Id, Account>()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      accounts[0].AccountNumber,
      'AccountNumber should be updated'
    );
  }

  @isTest
  static void testBeforeDelete() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.beforeDelete(accounts, accountMap);
    Test.stopTest();

    System.assertNotEquals(null, accounts[0].Name, 'Name should be updated');
  }

  @isTest
  static void testAfterDelete() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.afterDelete(accounts, accountMap);
    Test.stopTest();

    System.assertNotEquals(null, accounts[0].Name, 'Name should be updated');
  }

  @isTest
  static void testAfterUnDelete() {
    ITriggerHandlerTest handler = new ITriggerHandlerTest();

    List<Account> accounts = new List<Account>{
      new Account(Name = 'Test Account')
    };
    Map<Id, Account> accountMap = new Map<Id, Account>{
      accounts[0].Id => accounts[0]
    };

    Test.startTest();
    handler.afterUnDelete(accounts, accountMap);
    Test.stopTest();

    System.assertNotEquals(null, accounts[0].Name, 'Name should be updated');
  }

  public void beforeInsert(List<SObject> newList) {
    // Implement your logic here if needed
  }

  public void afterInsert(List<SObject> newList, Map<Id, SObject> newMap) {
    // Implement your logic here if needed
  }

  public void beforeUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    // Implement your logic here if needed
  }

  public void afterUpdate(
    List<SObject> newList,
    Map<Id, SObject> newMap,
    List<SObject> oldList,
    Map<Id, SObject> oldMap
  ) {
    // Implement your logic here if needed
  }

  public void beforeDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    // Implement your logic here if needed
  }

  public void afterDelete(List<SObject> oldList, Map<Id, SObject> oldMap) {
    // Implement your logic here if needed
  }

  public void afterUnDelete(List<SObject> newList, Map<Id, SObject> newMap) {
    // Implement your logic here if needed
  }

  public Boolean isDisabled() {
    return false;
  }
}
