public class EmailInvokeOnOBAPClass {
  @InvocableMethod
  public static void sendEmail(List<Id> OrderId) {
    Order wo = [
      SELECT
        id,
        account.ownerId,
        status,
        MockupClientApproval24HourEmailSent__c,
        OrderNumber,
        OrderBlankApprovedDeposit24HourEmailSent__c,
        ProofSentWaitingApproval24HourEmailSent__c
      FROM order
      WHERE id = :OrderId
    ];
    User orderAccountOwner = [
      SELECT id, email
      FROM user
      WHERE id = :wo.Account.ownerId
    ];
    List<User> Jesse = [
      SELECT id, email
      FROM user
      WHERE name = 'Jesse Goodwick'
      LIMIT 1
    ];
    if (
      wo.Status == '04_-_Order_Blanks-Approved/Deposit' &&
      wo.OrderBlankApprovedDeposit24HourEmailSent__c == false
    ) {
      EmailInvokeClass.sendEmail(
        orderAccountOwner,
        Jesse,
        wo,
        '24HoursSinceStageOnOBAP'
      );
    }
  }
}
