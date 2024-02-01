public class generateSowPdf {
  public Opportunity opp;

  public generateSowPdf(ApexPages.StandardController controller) {
    opp = (Opportunity) controller.getRecord();
  }
  public void genPdfSow() {
    String oppId = opp.Id;
    try {
      Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE id = :oppId];

      String fileName = opp.Name + ' SOW Document';

      PageReference sowPdf;
      sowPdf = Page.SOW;
      sowPdf.getParameters().put('id', oppId);

      Blob body;
      if (Test.isRunningTest()) {
        body = blob.valueOf('Unit.Test');
      } else {
        body = sowPdf.getContentAsPDF();
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
        SELECT Id
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId = :oppId
          AND ContentDocument.Title LIKE '% SOW Document'
      ];

      ContentDocumentLink cDe = new ContentDocumentLink();
      cDe.ContentDocumentId = conDoc;
      cDe.LinkedEntityId = OppId;
      cDe.ShareType = 'V';
      insert cDe;
    } catch (Exception ex) {
      System.debug('Exception in geenrating PDF');
    }
  }
}
