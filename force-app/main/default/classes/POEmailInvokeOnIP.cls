public class POEmailInvokeOnIP {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT
        id,
        Name,
        Supplier__c,
        Supplier__r.Name,
        PO_Estimated_Ship_Date__c,
        Carrier__c,
        Preferred_Carrier__c,
        Supplier__r.Billing_Email__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'PO In Process 1st Notification'
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
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.PO_Estimated_Ship_Date__c}',
        PO[0].PO_Estimated_Ship_Date__c == null
          ? 'Estimated Ship Date (TBD)'
          : string.valueOf(PO[0].PO_Estimated_Ship_Date__c)
      );
      if (PO[0].Preferred_Carrier__c == null) {
        htmlBody = htmlBody.replace(
          '{!PurchaseOrder_LineItem__c.Carrier__c}',
          'Carrier (TBD)'
        );
      } else if (PO[0].Preferred_Carrier__c == 'Other') {
        htmlBody = htmlBody.replace(
          '{!PurchaseOrder_LineItem__c.Carrier__c}',
          PO[0].Carrier__c
        );
      } else {
        htmlBody = htmlBody.replace(
          '{!PurchaseOrder_LineItem__c.Carrier__c}',
          PO[0].Preferred_Carrier__c
        );
      }

      if (PO[0].Supplier__r.Billing_Email__c != null) {
        String toAddress = PO[0].Supplier__r.Billing_Email__c;
        List<String> ccAddresses = new List<String>();
        String subject = et.Subject;
        ccAddresses.add(System.Label.PONotificationEmail);
        POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
      }
    }
  }
}
