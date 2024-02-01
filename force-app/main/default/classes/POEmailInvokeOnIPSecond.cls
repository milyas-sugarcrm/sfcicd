public class POEmailInvokeOnIPSecond {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT
        id,
        Name,
        PO_Completion_Date__c,
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
      WHERE Name = 'PO In Process 2nd Notification'
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
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.PO_Completion_Date__c}',
        PO[0].PO_Completion_Date__c == null
          ? 'Completion Date (TBD)'
          : string.valueOf(PO[0].PO_Completion_Date__c)
      );
    }
    System.debug(htmlbody);
    String toAddress = System.Label.PONotificationEmail;
    List<String> ccAddresses = new List<String>();
    String subject = et.Subject;
    POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
  }
}
