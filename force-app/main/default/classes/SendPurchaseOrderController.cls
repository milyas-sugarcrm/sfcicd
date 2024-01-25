public class SendPurchaseOrderController {
  @AuraEnabled
  public static List<OrgWideEmailAddress> getOrgWideEmail() {
    List<OrgWideEmailAddress> lstEmailAddresses = [
      SELECT Id, Address
      FROM OrgWideEmailAddress
      ORDER BY CreatedDate DESC
    ];
    return lstEmailAddresses;
  }

  @AuraEnabled
  public static String getSubject(Id recordId) {
    PurchaseOrder_LineItem__c PO = [
      SELECT Name
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :recordId
    ];
    string subject = 'Team Phun: PURCHASE ORDER ' + PO.Name;
    return subject;
  }

  @AuraEnabled
  public static String emailTemplatePO(Id recordId) {
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue
      FROM EmailTemplate
      WHERE Name = 'Send Purchase order'
    ];
    PurchaseOrder_LineItem__c PO = [
      SELECT Supplier__r.Name, Work_Order__c, Name
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :recordId
    ];
    string htmlBody = et.HtmlValue;
    htmlBody = htmlBody.replace('{!Vendor}', PO.Supplier__r.Name);
    htmlBody = htmlBody.replace('{!PONumber}', PO.Name);
    return htmlBody;
  }

  @AuraEnabled
  public static List<String> getPOPdf(Id recordId) {
    PurchaseOrder_LineItem__c PO = [
      SELECT Work_Order__c, Name
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :recordId
    ];
    OppLineItemNavController.generatePdfForPurchaseOrder(PO.Work_Order__c);
    List<contentDocumentLink> cdLinks = [
      SELECT LinkedEntityid, ContentDocumentid
      FROM contentDocumentLink
      WHERE LinkedEntityid = :PO.Id
    ];
    List<id> ContentDocumentids = new List<id>();
    String fileName = 'PurchaseOrder#' + PO.Name;
    for (contentDocumentLink cdl : cdLinks) {
      ContentDocumentids.add(cdl.ContentDocumentid);
    }
    ContentVersion cVersion = [
      SELECT
        Id,
        title,
        PathOnClient,
        FileType,
        versiondata,
        CreatedDate,
        ContentDocumentId
      FROM contentversion
      WHERE
        ContentDocumentId IN :ContentDocumentids
        AND title = :fileName
        AND isLatest = TRUE
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    List<String> attachmentData = new List<String>();
    attachmentData.add(cVersion.PathOnClient);
    attachmentData.add(cVersion.ContentDocumentId);
    attachmentData.add(cVersion.Id);
    return attachmentData;
  }

  @AuraEnabled
  public static string getToAddress(Id recordId) {
    PurchaseOrder_LineItem__c PO = [
      SELECT Supplier__c, Supplier__r.Billing_Email__c
      FROM PurchaseOrder_LineItem__c
      WHERE id = :recordId
    ];
    System.debug(PO.Supplier__c);
    System.debug(PO.Supplier__r.Billing_Email__c);
    return PO.Supplier__r.Billing_Email__c;
  }

  @AuraEnabled
  public static Boolean sendMail1(
    Id recordId,
    String fromEmail,
    String toEmail,
    String[] ccEmail,
    String subject,
    String body,
    List<String> cvIds
  ) {
    try {
      PurchaseOrder_LineItem__c PO = [
        SELECT Id, Date_and_Time_Sent__c
        FROM PurchaseOrder_LineItem__c
        WHERE id = :recordId
      ];
      OrgWideEmailAddress EmailAddresses = [
        SELECT Id, Address
        FROM OrgWideEmailAddress
        WHERE Address = :fromEmail
        LIMIT 1
      ];
      List<ContentVersion> cVersions = [
        SELECT
          Id,
          title,
          PathOnClient,
          FileType,
          versiondata,
          CreatedDate,
          ContentDocumentId
        FROM contentversion
        WHERE Id IN :cvIds
      ];

      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

      for (ContentVersion cv : cVersions) {
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
        efa.setBody(cv.versiondata);
        efa.setFileName(cv.PathOnClient);
        fileAttachments.add(efa);
      }

      List<String> email = new List<String>();
      email.add(toEmail);
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      mail.setOrgWideEmailAddressId(EmailAddresses.Id);
      mail.setToAddresses(email);
      if (ccEmail.size() > 0) {
        mail.setCcAddresses(ccEmail);
      }

      mail.setReplyTo('info@teamphun.com');

      mail.setSubject(subject);
      mail.setHtmlBody(body);
      mail.setFileAttachments(fileAttachments);

      mails.add(mail);

      Messaging.sendEmail(mails);

      PO.Date_and_Time_Sent__c = System.now();
      update PO;

      return true;
    } catch (Exception ex) {
      System.debug(ex.getMessage() + '---->>>>>>' + ex.getStackTraceString());
      return false;
    }
  }

  @AuraEnabled
  public static List<sObject> fetchLookUpValues(String searchKeyWord) {
    searchKeyWord += '*';
    List<List<SObject>> searchResults = [
      FIND :searchKeyWord
      IN ALL FIELDS
      RETURNING
        Contact(Id, Name, Email),
        Lead(Id, Name, Email),
        Account(Id, Name, Billing_Email__c)
    ];
    List<sObject> myList = new List<sObject>();
    for (sObject obj : searchResults[0]) {
      myList.add(obj);
    }
    for (sObject obj : searchResults[1]) {
      myList.add(obj);
    }
    return myList;
  }
}
