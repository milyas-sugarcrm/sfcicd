@isTest
public class Test_TriggerOnEmailMessageHandler {
  @testSetup
  public static void createData() {
    Test_TriggerOnEmailMessageService.createData();
  }

  @isTest
  public static void testApprovalEmailSendCriteria() {
    Test_TriggerOnEmailMessageService.testApprovalEmailSendCriteria();
  }
}
