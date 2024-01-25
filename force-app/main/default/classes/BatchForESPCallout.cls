public class BatchForESPCallout implements Database.Batchable<String>, Database.AllowsCallouts {
  List<String> urlsAndIds;
  Id OpportunityAttachmentLineItemId;
  Id productId;
  public BatchForESPCallout(List<String> urlsAndIds) {
    this.urlsAndIds = urlsAndIds;
    this.OpportunityAttachmentLineItemId = (Id) urlsAndIds[
      urlsAndIds.size() - 2
    ];
    this.productId = (Id) urlsAndIds[urlsAndIds.size() - 1];
  }
  public Iterable<String> start(Database.BatchableContext bc) {
    List<String> imagesURL = new List<String>();
    for (Integer i = 0; i < (this.urlsAndIds.size() - 2); i++) {
      imagesURL.add(this.urlsAndIds[i]);
    }
    return imagesURL;
  }
  public void execute(Database.BatchableContext bc, List<String> imagesURL) {
    try {
      List<ContentVersion> contentVerFiles = new List<ContentVersion>();
      List<Id> contVerFileIds = new List<Id>();
      List<ContentDocumentLink> contDocLink1 = new List<ContentDocumentLink>();
      List<ContentDocumentLink> contDocLink2 = new List<ContentDocumentLink>();

      for (String imageUrl : imagesURL) {
        Blob imageData = AddProductEspTabController.getImageFromUrl(imageUrl);
        if (imageData != null) {
          ContentVersion ContVerFile = new ContentVersion();
          ContVerFile.VersionData = imageData;
          ContVerFile.Title = 'Preview Presentation';
          ContVerFile.ContentLocation = 's';
          ContVerFile.PathOnClient = 'title.jpg';
          contentVerFiles.add(ContVerFile);
        }
      }
      insert contentVerFiles;

      for (ContentVersion contVerFile : contentVerFiles) {
        contVerFileIds.add(contVerFile.Id);
      }

      List<ContentVersion> conDocs = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contVerFileIds
      ];

      for (ContentVersion ContVerFile : contentVerFiles) {
        for (ContentVersion conDocId : conDocs) {
          if (ContVerFile.Id == conDocId.Id) {
            ContentDocumentLink cDe = new ContentDocumentLink();
            cDe.ContentDocumentId = conDocId.ContentDocumentId;
            cDe.LinkedEntityId = this.OpportunityAttachmentLineItemId;
            cDe.ShareType = 'I';
            cDe.Visibility = 'AllUsers';
            contDocLink1.add(cDe);

            ContentDocumentLink cDe2 = new ContentDocumentLink();
            cDe2.ContentDocumentId = conDocId.ContentDocumentId;
            cDe2.LinkedEntityId = this.productId;
            cDe2.ShareType = 'I';
            cDe2.Visibility = 'AllUsers';
            contDocLink2.add(cDe2);
          }
        }
      }
      insert contDocLink1;
      insert contDocLink2;
    } catch (Exception e) {
      System.debug('Error in inserting images----> ' + e.getMessage());
      string emails = Label.ErrorEmailRecepients;
      System.debug(emails);
      List<String> allEmails = emails.split(';');
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.toAddresses = allEmails;
      message.optOutPolicy = 'FILTER';
      message.subject = 'Error in Inserting Images';
      message.setHtmlBody(
        'Product Id: ' +
          this.productId +
          ', OpportunityAttachmentLineItemId: ' +
          this.OpportunityAttachmentLineItemId +
          ', Exception occured: ' +
          e.getMessage() +
          '---' +
          e.getStackTraceString()
      );
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      if (results[0].success) {
        System.debug('The email was sent successfully to ' + emails);
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    }
  }
  public void finish(Database.BatchableContext bc) {
  }
}
