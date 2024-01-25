@isTest
public class Test_EmailInvokeOnPSWFACClass {
  @TestSetup
  public static void createData() {
    Test_EmailInvokeOnSMTCFAClass.createData();
  }

  @isTest
  public static void testSendEmail() {
    List<Order> listOrders = [SELECT id FROM order];
    List<Id> listOrderIds = new List<Id>();
    for (Order ord : listOrders) {
      ord.Status = '03_-_Proof_Sent_-_Waiting_for_Approval';
      listOrderIds.add(ord.id);
    }
    update listOrders;
    EmailInvokeOnPSWFACClass.sendEmail(listOrderIds);
    listOrders = [
      SELECT id, ProofSentWaitingApproval24HourEmailSent__c
      FROM order
    ];
    for (Order ord : listOrders) {
      System.assertEquals(true, ord.ProofSentWaitingApproval24HourEmailSent__c);
    }
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations()); //Now we verify that if on same stage, and the function is called again, emails are not sent out
    EmailInvokeOnPSWFACClass.sendEmail(listOrderIds);
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations());
  }
}
