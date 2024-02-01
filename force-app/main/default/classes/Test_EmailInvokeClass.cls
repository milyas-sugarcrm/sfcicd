@isTest
public class Test_EmailInvokeClass {
  @TestSetup
  public static void createData() {
    Test_EmailInvokeOnSMTCFAClass.createData();
  }

  @isTest
  public static void testSendEmail() {
    Test_EmailInvokeOnSMTCFAClass.testSendEmail();
  }
}
