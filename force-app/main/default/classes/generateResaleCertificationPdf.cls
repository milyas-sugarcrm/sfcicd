public with sharing class generateResaleCertificationPdf {
  @AuraEnabled
  public static Boolean generateResalePDF(String accountID) {
    try {
      Account vendorAccount = [
        SELECT Id, Name
        FROM Account
        WHERE id = :accountID
      ];
      String fileName = vendorAccount.Name + ' Resale Certificate';
      String file_Name_like = '%' + fileName;

      PageReference pdf;
      pdf = Page.resaleCertificationPDF;
      pdf.getParameters().put('id', accountID);

      Blob body;
      if (Test.isRunningTest()) {
        body = blob.valueOf('Unit.Test');
      } else {
        body = pdf.getContentAsPDF();
      }

      ContentVersion conVer = new ContentVersion();
      conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
      conVer.PathOnClient = fileName + '.pdf'; // The files name, extension is very important here which will help the file in preview.
      conVer.Title = fileName; // Display name of the files
      conVer.VersionData = body;
      insert conVer;
      Id conDoc = [
        SELECT ContentDocumentId
        FROM ContentVersion
        WHERE Id = :conVer.Id
      ]
      .ContentDocumentId;

      delete [
        SELECT id
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId = :accountID
          AND ContentDocument.Title LIKE :file_Name_like
      ];

      ContentDocumentLink cDe = new ContentDocumentLink();
      cDe.ContentDocumentId = conDoc;
      cDe.LinkedEntityId = accountID;
      cDe.ShareType = 'V';
      insert cDe;
      return true;
    } catch (Exception e) {
      System.debug('Error in generateResalePDF ');
      return false;
    }
  }
}
