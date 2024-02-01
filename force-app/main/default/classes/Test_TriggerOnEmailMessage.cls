@isTest
public class Test_TriggerOnEmailMessage {
  @testSetup
  public static void createData() {
    Test_TriggerOnEmailMessageService.createData();
  }

  @isTest
  public static void testApprovalEmailSendCriteria() {
    Test_TriggerOnEmailMessageService.testApprovalEmailSendCriteria();
  }
}
