public class POEmailInvokeOnReadyForTP {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT
        id,
        Name,
        Supplier__c,
        Supplier__r.Name,
        OwnerId,
        Work_Order__r.OwnerId
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];

    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'PO Ready for TP Pickup'
    ];
    string htmlBody = et.HtmlValue;
    if (PO.size() > 0) {
      List<User> user = [
        SELECT id, Name, Email
        FROM User
        WHERE Id = :PO[0].Work_Order__r.OwnerId
        LIMIT 1
      ];
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Name}',
        'PO - ' + PO[0].Name
      );
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.OwnerFullName}',
        user[0].Name
      );

      String toAddress = System.Label.PONotificationEmail;
      List<String> ccAddresses = new List<String>();
      String subject =
        'Follow Up to Confirm Delivery is Scheduled for PO - ' + PO[0].Name;
      ccAddresses.add(user[0].Email);
      POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
    }
  }
}
