public class EmailInvokeOnPSWFACClass {
  @InvocableMethod
  public static void sendEmail(List<Id> OrderId) {
    List<Order> wo = [
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
    List<User> orderAccountOwner = [
      SELECT id, email
      FROM user
      WHERE id = :wo[0].Account.ownerId
    ];
    if (
      wo[0].Status == '03_-_Proof_Sent_-_Waiting_for_Approval' &&
      wo[0].ProofSentWaitingApproval24HourEmailSent__c == false
    ) {
      EmailInvokeClass.sendEmail(
        orderAccountOwner[0],
        null,
        wo[0],
        '24HoursSinceStageOnPSWFAC'
      );
    }
  }
}
