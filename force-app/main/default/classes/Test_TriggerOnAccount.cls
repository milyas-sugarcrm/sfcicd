@isTest
public class Test_TriggerOnAccount {
  @testSetup
  public static void createData() {
    Test_QuickbookApiCrud.createData();
  }
  @isTest
  public static void testTriggerOnAccount() {
    Test_QuickbookApiCrud.testSendCustomer();
  }

  @isTest
  public static void testUpdateWorkOrderOwnerCheckbox() {
    Test_AccountTriggerHandler.testUpdateWorkOrderOwnerCheckbox();
  }
}
