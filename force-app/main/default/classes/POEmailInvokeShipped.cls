public class POEmailInvokeShipped {
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
        Work_Order__r.Account_Name__c,
        Work_Order__r.Invoice_Number__c,
        Work_Order__r.OwnerId,
        Account__r.Name,
        In_Hands_Date__c,
        InfoEmailField__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :poId
      LIMIT 1
    ];

    String emailText = '';
    if (PO.size() > 0 && PO[0].Work_Order__c != null) {
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
      List<OpportunityLineItem__c> oppLICList = [
        SELECT Id, Name, Description__c
        FROM OpportunityLineItem__c
        WHERE PurchaseOrder_LineItem__c = :poId
      ];
      String lightningURL = URL.getSalesforceBaseUrl().toExternalForm();
      lightningURL = lightningURL.replace('my.salesforce', 'lightning.force');
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.toAddresses = new List<String>{
        PO[0].InfoEmailField__c,
        woOwner[0].Email
      };
      message.subject =
        PO[0].Work_Order__r.Account_Name__c +
        ' Invoice ' +
        PO[0].Work_Order__r.Invoice_Number__c +
        ' is shipping to Team Phun';
      emailText = '<p>Hello Phunions,</p>';
      emailText =
        emailText +
        '<p>PO ' +
        '<a href="' +
        lightningURL +
        '/' +
        PO[0].Id +
        '">' +
        PO[0].Name +
        '</a>' +
        ' from ' +
        '<a href="' +
        lightningURL +
        '/' +
        PO[0].Supplier__c +
        '">' +
        PO[0].Supplier__r.Name +
        '</a>' +
        ' for ' +
        PO[0].Account__r.Name +
        ' is shipping to Team Phun. Please prepare for Quality Assurance.</p>';

      String getRelatedProducts = '';
      //loop over to create Products
      for (OpportunityLineItem__c oppLIC : oppLICList) {
        getRelatedProducts =
          getRelatedProducts +
          oPPLIC.Name +
          ' | ' +
          oPPLIC.Description__c +
          ' | In Hands Date: ' +
          PO[0].In_Hands_Date__c +
          '</br>';
      }
      if (oppLICList.size() > 0) {
        emailText = emailText + '<p>' + getRelatedProducts + '</p>';
      }

      emailText =
        emailText +
        '<a href="' +
        lightningURL +
        '/' +
        PO[0].Id +
        '">' +
        PO[0].Name +
        '</a>';
      emailText = emailText + '<br/><br/>Thanks,<br/>Ralph the Rooster';
      message.setHTMLBody(emailText);
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      try {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      } catch (Exception e) {
        System.debug('The email failed to send: ');
      }
    }
  }
}
