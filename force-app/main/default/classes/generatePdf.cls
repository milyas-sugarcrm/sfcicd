public class generatePdf {
  @AuraEnabled
  public static Boolean generatePdfPrsentation(String oppId, String fileName) {
    try {
      Opportunity opp = [
        SELECT Id, Name, StageName, isOutdated__c
        FROM Opportunity
        WHERE id = :oppId
      ];
      List<OpportunityLineItem__c> oppLineItem = [
        SELECT id, Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :oppId
      ];
      fileName = opp.Name + ' Preview Presentation';
      String file_name = '%' + fileName;
      if (opp.StageName == 'Needs Analysis') {
        return null;
      } else if (oppLineItem.size() == 0 && opp.StageName == 'Presentation') {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return null;
      } else if (oppLineItem.size() == 0) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return false;
      }
      PageReference pdf;
      opp.isOutdated__c = false;
      update opp;
      pdf = Page.OpportunityLineItemsPreviewPDF;
      pdf.getParameters().put('id', OppId);

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
        WHERE LinkedEntityId = :OppId AND ContentDocument.Title LIKE :file_name
      ];

      ContentDocumentLink cDe = new ContentDocumentLink();
      cDe.ContentDocumentId = conDoc;
      cDe.LinkedEntityId = OppId;
      cDe.ShareType = 'V';
      insert cDe;
      return true;
    } catch (Exception ex) {
      System.debug('Exception in geenrating PDF');
      return false;
    }
  }
  @AuraEnabled
  public static Boolean generatePdfEstimate(String oppId, String fileName) {
    try {
      List<Estimate__c> estimates = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :oppId
      ];
      Opportunity opp = [
        SELECT id, Name, isOutdated__c
        FROM Opportunity
        WHERE id = :oppId
      ];
      fileName = opp.Name + ' Preview Estimate';
      String file_name = '%' + fileName;
      List<Id> EstimateIds = new List<Id>();

      for (Estimate__c est : estimates) {
        EstimateIds.add(est.id);
      }
      List<OpportunityLineItem__c> oppLineItem = [
        SELECT id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c IN :EstimateIds
      ];
      if (oppLineItem.size() == 0) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return null;
      }
      if (estimates.size() == 0) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return null;
      }

      PageReference pdf;

      opp.isOutdated__c = false;
      update opp;
      pdf = Page.OpportunityEstimatePreviewPDF;

      pdf.getParameters().put('id', OppId);

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
        WHERE LinkedEntityId = :OppId AND ContentDocument.Title LIKE :file_name
      ];

      ContentDocumentLink cDe = new ContentDocumentLink();
      cDe.ContentDocumentId = conDoc;
      cDe.LinkedEntityId = OppId;
      cDe.ShareType = 'V';
      insert cDe;
      return true;
    } catch (Exception ex) {
      System.debug('Exception in geenrating PDF');
      return false;
    }
  }
  @AuraEnabled
  public static Boolean generatePdfSalesorder(String oppId, String fileName) {
    try {
      List<Order> orders = [
        SELECT id, OpportunityId
        FROM Order
        WHERE OpportunityId = :oppId
      ];
      Opportunity opp = [
        SELECT id, Name, isOutdated__c
        FROM Opportunity
        WHERE id = :oppId
      ];
      fileName = opp.Name + ' Preview Sales Order';
      String file_name = '%' + fileName;
      List<Id> OrderIds = new List<Id>();
      for (Order ord : orders) {
        OrderIds.add(ord.id);
      }
      List<OpportunityLineItem__c> oppLineItem = [
        SELECT id, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Work_Order__c IN :OrderIds
      ];
      if (oppLineItem.size() == 0) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return null;
      }
      if (orders.size() == 0) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            LinkedEntityId = :OppId
            AND ContentDocument.Title LIKE :file_name
        ];
        return null;
      }
      PageReference pdf;
      opp.isOutdated__c = false;
      update opp;
      pdf = Page.OpportunitySalesOrderPreviewPDF;
      pdf.getParameters().put('id', OppId);

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
        WHERE LinkedEntityId = :OppId AND ContentDocument.Title LIKE :file_name
      ];

      ContentDocumentLink cDe = new ContentDocumentLink();
      cDe.ContentDocumentId = conDoc;
      cDe.LinkedEntityId = OppId;
      cDe.ShareType = 'V';
      insert cDe;
      return true;
    } catch (Exception ex) {
      System.debug('Exception in geenrating PDF');
      return false;
    }
  }
}
