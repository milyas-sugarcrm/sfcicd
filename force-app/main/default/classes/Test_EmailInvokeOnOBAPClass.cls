@isTest
public class Test_EmailInvokeOnOBAPClass {
  @TestSetup
  public static void createData() {
    Test_EmailInvokeOnSMTCFAClass.createData();
  }

  @isTest
  public static void testSendEmail() {
    List<Order> listOrders = [SELECT id FROM order];
    List<Id> listOrderIds = new List<Id>();
    for (Order ord : listOrders) {
      ord.Status = '04_-_Order_Blanks-Approved/Deposit';
      listOrderIds.add(ord.id);
    }
    update listOrders;
    EmailInvokeOnOBAPClass.sendEmail(listOrderIds);
    listOrders = [
      SELECT id, OrderBlankApprovedDeposit24HourEmailSent__c
      FROM order
    ];
    for (Order ord : listOrders) {
      System.assertEquals(
        true,
        ord.OrderBlankApprovedDeposit24HourEmailSent__c
      );
    }
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations());
    //Now we verify that if on same stage, and the function is called again, emails are not sent out
    EmailInvokeOnOBAPClass.sendEmail(listOrderIds);
    System.assertEquals(listOrders.size(), Limits.getEmailInvocations());
  }
}
