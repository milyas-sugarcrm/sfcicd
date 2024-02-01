public class EmailInvokeOnSMTCFAClass {
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
      WHERE id IN :OrderId
    ];

    List<User> jared = [
      SELECT id, email
      FROM user
      WHERE name = 'Jared Lazar'
      LIMIT 1
    ];

    if (wo != null && wo.size() > 0) {
      User orderAccountOwner = [
        SELECT id, email
        FROM user
        WHERE id = :wo[0].Account.ownerId
      ];

      if (
        wo[0].Status == '02_-_Send_Mock_Up_to_Client_for_Approval' &&
        wo[0].MockupClientApproval24HourEmailSent__c == false
      ) {
        EmailInvokeClass.sendEmail(
          orderAccountOwner,
          jared,
          wo[0],
          '24HoursSinceStageOnSMTCFA'
        );
      }
    }
  }
}
