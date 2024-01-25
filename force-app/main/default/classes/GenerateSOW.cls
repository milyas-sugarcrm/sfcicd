public class GenerateSOW {
  public static final String PREPARE_AND_SEND_SOW = 'Prepare & Send SOW';

  @AuraEnabled
  public static Map<String, Object> generateSowPdfHandler(Id oppId) {
    String msg = 'SOW Document Generated Successfully.';
    Map<String, Object> response = new Map<String, Object>{
      'success' => 'true',
      'msg' => msg
    };

    try {
      Opportunity opportunity = [
        SELECT
          Id,
          Name,
          StageName,
          Aws_File_Name__c,
          Signor_Email_PFA__c,
          Signor_Name_PFA__c
        FROM Opportunity
        WHERE id = :oppId
        LIMIT 1
      ];

      if (opportunity == null || opportunity.StageName == 'Closed Won') {
        msg = 'Either Opportunity not found or it is alredy Closed Won.';
        System.debug(msg);
        response = new Map<String, Object>{
          'success' => 'false',
          'msg' => msg
        };
        return response;
      }

      String fileName = opportunity.Name + ' SOW Document';
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
      conVer.PathOnClient = fileName + '.pdf';
      conVer.Title = fileName;
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

      opportunity.StageName = PREPARE_AND_SEND_SOW;
      update opportunity;

      /*
       * Process created SOW for PandaDoc if
       * opportunity.Signor_Email_PFA__c is not empty
       */
      if (!String.isBlank(opportunity.Signor_Email_PFA__c)) {
        System.debug('SOW Generate on AWS/Pandadoc Start---');
        SowPandaDocHandler.initialProcessingOffOppSow(
          conDoc,
          conVer.Title,
          opportunity.Id,
          opportunity.Aws_File_Name__c
        );
        System.debug('SOW Generate on AWS/Pandadoc End---');
      }
      return response;
    } catch (Exception ex) {
      msg =
        'Exception in generating PDF : ' +
        ex.getMessage() +
        ' : Cause : ' +
        ex.getCause();
      System.debug(msg);

      response = new Map<String, Object>{ 'success' => 'false', 'msg' => msg };
      return response;
    }
  }
}
