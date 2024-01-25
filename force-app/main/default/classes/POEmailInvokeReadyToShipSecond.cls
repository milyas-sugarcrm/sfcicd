public class POEmailInvokeReadyToShipSecond {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT id, Work_Order__c, Name, Work_Order__r.OwnerId
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'PO Ready to Ship/Pickup 2nd Notification'
    ];
    string htmlBody = et.HtmlValue;
    if (PO.size() > 0) {
      List<User> woOwner = [
        SELECT id, Name, Email
        FROM User
        WHERE Id = :PO[0].Work_Order__r.OwnerId
        LIMIT 1
      ];
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Name}',
        'PO - ' + PO[0].Name
      );

      String toAddress = System.Label.PONotificationEmail;
      List<String> ccAddresses = new List<String>();
      String subject =
        'Reminder to PO - ' +
        PO[0].Name +
        ' Add Shipping Information or Notify Client for Pickup';
      ccAddresses.add(woOwner[0].Email);
      POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
    }
  }
}
