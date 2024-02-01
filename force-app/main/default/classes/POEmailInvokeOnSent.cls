public class POEmailInvokeOnSent {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT
        id,
        Name,
        Supplier__c,
        Supplier__r.Name,
        PO_Estimated_Ship_Date__c,
        Carrier__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'PO Sent Notification'
    ];
    string htmlBody = et.HtmlValue;
    if (PO.size() > 0) {
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Supplier__c}',
        PO[0].Supplier__r.Name
      );
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Name}',
        'PO - ' + PO[0].Name
      );

      String toAddress = System.Label.PONotificationEmail;
      List<String> ccAddresses = new List<String>();
      String subject =
        'Follow Up on PO - ' +
        PO[0].Name +
        ' Pending Confirmation';
      POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
    }
  }
}
