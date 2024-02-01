public with sharing class PresentationPreviewProductImagesCon {
  @AuraEnabled(cacheable=true)
  public static map<Id, Boolean> getAttachedImagesToProduct(
    String oppLineItemId
  ) {
    try {
      Map<Id, Boolean> mapContentLink_ContentVersion = new Map<Id, Boolean>();
      Set<ID> oppLineItemAttachmentIds = new Set<ID>();
      Set<ID> contentDocIds = new Set<ID>();

      OpportunityLineItem__c oppLineItem = [
        SELECT Id, ContentDocument_ID__c
        FROM OpportunityLineItem__c
        WHERE Id = :oppLineItemId
      ];
      List<OpportunityLineItemAttachment__c> opplineItemAttachments = [
        SELECT Id
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :oppLineItemId
      ];

      for (
        OpportunityLineItemAttachment__c opplineAttachment : opplineItemAttachments
      ) {
        oppLineItemAttachmentIds.add(opplineAttachment.Id);
      }
      List<ContentDocumentLink> contentdoclinks = [
        SELECT Id, ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :oppLineItemAttachmentIds
      ];

      for (ContentDocumentLink contentdoclink : contentdoclinks) {
        contentDocIds.add(contentdoclink.ContentDocumentId);
      }
      List<ContentVersion> imageFiles = [
        SELECT id, FileType, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocIds AND FileType != 'PDF'
      ];
      for (ContentVersion contentVersion : imageFiles) {
        if (
          oppLineItem.ContentDocument_ID__c == contentVersion.ContentDocumentId
        ) {
          mapContentLink_ContentVersion.put(
            contentVersion.ContentDocumentId,
            true
          );
        } else {
          mapContentLink_ContentVersion.put(
            contentVersion.ContentDocumentId,
            false
          );
        }
      }
      return mapContentLink_ContentVersion;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static Boolean setAttachedImagesToProduct(
    String oppLineItemId,
    String contentDocId
  ) {
    try {
      OpportunityLineItem__c oppLineItem = [
        SELECT Id, ContentDocument_ID__c
        FROM OpportunityLineItem__c
        WHERE Id = :oppLineItemId
      ];
      oppLineItem.ContentDocument_ID__c = String.valueOf(contentDocId);
      update oppLineItem;
      return true;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static string getOpportunityStage(String opportunityId) {
    try {
      Opportunity opp = [
        SELECT Id, stageName
        FROM Opportunity
        WHERE Id = :opportunityId
      ];
      return opp.stageName;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
