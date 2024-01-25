public class POEmailInvokeReadyToShip {
  @InvocableMethod
  public static void invokeEmail(List<Id> poId) {
    List<PurchaseOrder_LineItem__c> PO = [
      SELECT
        id,
        Work_Order__c,
        Name,
        Supplier__c,
        Supplier__r.Name,
        Supplier__r.Billing_Email__c,
        Production_Rep__c,
        Work_Order__r.OrderNumber,
        Work_Order__r.OwnerId
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];
    System.debug(PO);
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'PO Ready to Ship/Pickup 1st Notification'
    ];
    string htmlBody = et.HtmlValue;
    if (PO.size() > 0) {
      List<User> woOwner = [
        SELECT id, Name, Email
        FROM User
        WHERE Id = :PO[0].Work_Order__r.OwnerId
        LIMIT 1
      ];
      List<User> pRep = [
        SELECT id, Name, Email
        FROM User
        WHERE Name = :PO[0].Production_Rep__c
        LIMIT 1
      ];

      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Supplier__c}',
        PO[0].Supplier__r.Name
      );
      htmlBody = htmlBody.replace(
        '{!PurchaseOrder_LineItem__c.Name}',
        'PO - ' + PO[0].Name
      );
      htmlBody = htmlBody.replace(
        '{!Order.Name}',
        PO[0].Work_Order__r.OrderNumber
      );
      htmlBody = htmlBody.replace('{!Order.OwnerFullName}', woOwner[0].Name);

      String toAddress = woOwner[0].Email;
      List<String> ccAddresses = new List<String>();
      String subject =
        'Confirm Ship or Pickup of PO - ' +
        PO[0].Name +
        ' is Communicated to Operations';
      //ccAddresses.add(pRep[0].Email);
      POEmailInvoke.sendEmail(toAddress, ccAddresses, htmlBody, subject);
    }
  }
}
