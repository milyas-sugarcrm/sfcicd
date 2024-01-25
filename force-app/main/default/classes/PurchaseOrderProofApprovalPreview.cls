public class PurchaseOrderProofApprovalPreview {
  private final PurchaseOrder__c po;
  Opportunity record = new Opportunity();
  public PurchaseOrderProofApprovalPreview(
    ApexPages.StandardController stdController
  ) {
    this.po = (PurchaseOrder__c) stdController.getRecord();
  }

  public List<purchaseOrderProofs> getDetails() {
    try {
      List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = [
        SELECT
          PO__c,
          Status__c,
          Production_Rep__c,
          PurchaseOrder__c,
          OpportunityLineItem__c,
          Id
        FROM PurchaseOrder_LineItem__c
        WHERE PurchaseOrder__c = :po.id
      ];
      List<Proof__c> listOfRelatedProofs = [
        SELECT
          Id,
          Name,
          PurchaseOrder_LineItem__c,
          Status__c,
          File_Name__c,
          documentId__c
        FROM Proof__c
        WHERE PurchaseOrder_LineItem__c = :purchaseOrderLineItem
      ];
      List<OpportunityLineItem__c> opportunityLineItems = [
        SELECT
          Id,
          Opportunity__c,
          PurchaseOrder_LineItem__c,
          SKU__c,
          SortOrder__c,
          Shipping_Information__r.In_Hands_Date__c,
          Shipping_Information__r.Ship_To__c,
          Shipping_Information__r.Supplier__c,
          Work_Order__c
        FROM OpportunityLineItem__c
        WHERE PurchaseOrder_LineItem__c = :purchaseOrderLineItem
      ];

      Map<Id, OpportunityLineItem__c> purchaseOrderLineItem_OppLineItemMap = new Map<Id, OpportunityLineItem__c>();

      for (OpportunityLineItem__c opplineItem : opportunityLineItems) {
        purchaseOrderLineItem_OppLineItemMap.put(
          opplineItem.PurchaseOrder_LineItem__c,
          opplineItem
        );
      }
      List<Id> supplierIds = new List<Id>();
      List<Id> shippingInformationId = new List<Id>();
      for (OpportunityLineItem__c opp : opportunityLineItems) {
        supplierIds.add(opp.Shipping_Information__r.Supplier__c);
        shippingInformationId.add(opp.Shipping_Information__c);
      }
      Map<Id, Shipping_Information__c> shippingInformationMap = new Map<Id, Shipping_Information__c>(
        [
          SELECT Id, Name
          FROM Shipping_Information__c
          WHERE Id = :shippingInformationId
        ]
      );
      Map<Id, Account> supplierMap = new Map<Id, Account>(
        [
          SELECT Id, Name
          FROM Account
          WHERE Id = :supplierIds
        ]
      );
      Map<id, List<Proof__c>> purchaseOrderId_proofsMap = new Map<id, List<Proof__c>>();
      for (PurchaseOrder_LineItem__c po : purchaseOrderLineItem) {
        List<Proof__c> listForMap = new List<Proof__c>();
        for (Proof__c proof : listOfRelatedProofs) {
          if (proof.PurchaseOrder_LineItem__c == po.Id) {
            listForMap.add(proof);
          }
        }
        purchaseOrderId_proofsMap.put(po.Id, listForMap);
      }
      List<Comment__c> commentsRelatedToProofs = [
        SELECT Proof__c, Date__c, User__c, Comment__c, Id
        FROM Comment__c
        WHERE Proof__c = :listOfRelatedProofs
        ORDER BY CreatedDate DESC
      ];
      Map<Id, List<Comment__c>> proof_commentsMap = new Map<Id, List<Comment__c>>();
      Map<Id, String> mapContentLink_ContentVersion = new Map<Id, String>();
      Map<Id, String> mapContentLink_previewImage = new Map<Id, String>();
      List<Id> contentVersionIds = new List<Id>();
      for (Proof__c proof : listOfRelatedProofs) {
        contentVersionIds.add(proof.documentId__c);
        List<Comment__c> commentsListForMap = new List<Comment__c>();
        for (Comment__c comm : commentsRelatedToProofs) {
          if (comm.Proof__c == proof.Id) {
            if (comm.Comment__c.contains('Proof (Change Requested)')) {
              if (comm.Comment__c.split('[)]').size() == 1) {
                comm.Comment__c = '';
              } else {
                comm.Comment__c = comm.Comment__c.split('[)]')[1];
              }

              comm.User__c = comm.User__c + ': (Change Requested)';
            }
            if (comm.Comment__c.contains('Proof (Client Approved)')) {
              if (comm.Comment__c.split('[)]').size() == 1) {
                comm.Comment__c = '';
              } else {
                comm.Comment__c = comm.Comment__c.split('[)]')[1];
              }

              comm.User__c = comm.User__c + ': (Approved)';
            }
            commentsListForMap.add(comm);
          }
        }
        proof_commentsMap.put(proof.Id, commentsListForMap);
      }
      List<ContentVersion> productRelatedImageFiles = [
        SELECT id, ContentDocumentId, ContentDocument.LatestPublishedVersionID
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentVersionIds
      ];
      for (ContentVersion contentVersion : productRelatedImageFiles) {
        mapContentLink_previewImage.put(
          contentVersion.ContentDocumentId,
          (URL.getSalesforceBaseUrl().toExternalForm() +
          '/lightning/r/ContentDocument/' +
          contentVersion.ContentDocument.id +
          '/view')
        );
        mapContentLink_ContentVersion.put(
          contentVersion.ContentDocumentId,
          (URL.getSalesforceBaseUrl().toExternalForm() +
          '/sfc/servlet.shepherd/version/download/' +
          contentVersion.ContentDocument.LatestPublishedVersionID)
        );
      }

      List<purchaseOrderProofs> listToReturn = new List<purchaseOrderProofs>();
      for (PurchaseOrder_LineItem__c poLineItem : purchaseOrderLineItem) {
        List<Proof__c> proofsList = new List<Proof__c>();
        proofsList = purchaseOrderId_proofsMap.get(poLineItem.Id);
        if (proofsList != null && proofsList.size() > 0) {
          purchaseOrderProofs poProof = new purchaseOrderProofs();
          poProof.purchaseOrderNumber = poLineItem.PO__c;
          poProof.purchaseOrderId = poLineItem.Id;
          poProof.supplier = supplierMap.get(
              purchaseOrderLineItem_OppLineItemMap.get(poLineItem.Id)
                .Shipping_Information__r.Supplier__c
            )
            .Name;
          List<proofDetailsObject> detailsOfProofs = new List<proofDetailsObject>();

          for (Proof__c proof : proofsList) {
            proofDetailsObject proofObjectToAddInList = new proofDetailsObject();
            proofObjectToAddInList.comments = proof_commentsMap.get(proof.Id);
            proofObjectToAddInList.fileName = proof.File_Name__c;
            if (proof.Status__c == 'Client Approved') {
              proofObjectToAddInList.status = 'Approved proofs';
            } else {
              proofObjectToAddInList.status = 'To be approved';
            }
            proofObjectToAddInList.imageUrl = mapContentLink_ContentVersion.get(
              proof.documentId__c
            );
            proofObjectToAddInList.imagePreviewLink = mapContentLink_previewImage.get(
              proof.documentId__c
            );
            proofObjectToAddInList.proofId = proof.Id;
            detailsOfProofs.add(proofObjectToAddInList);
          }
          poProof.proofs = detailsOfProofs;
          listToReturn.add(poProof);
        }
      }

      return listToReturn;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }
  public void addComment() {
    try {
      Proof__c proof = [
        SELECT Id, Status__c
        FROM Proof__c
        WHERE Id = :Apexpages.currentPage().getParameters().get('recId')
      ];
      if (
        Apexpages.currentPage().getParameters().get('type') ==
        'Proof (Client Approved)'
      ) {
        proof.Status__c = 'Client Approved';
      }
      update proof;

      Comment__c comm = new Comment__c();
      comm.Date__c = System.now().format('MM-dd-yyyy');
      comm.Proof__c = Apexpages.currentPage().getParameters().get('recId');
      comm.Comment__c =
        Apexpages.currentPage().getParameters().get('type') +
        ' ' +
        Apexpages.currentPage().getParameters().get('comment');
      insert comm;

      Comment__c insertedComment = [
        SELECT
          Id,
          Date__c,
          Proof__c,
          Comment_Date__c,
          User__c,
          Comment__c,
          CreatedBy.Name
        FROM Comment__c
        WHERE Id = :comm.Id
      ];
      insertedComment.User__c = insertedComment.CreatedBy.Name;
      update insertedComment;

      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = Apexpages.currentPage().getParameters().get('type');
      PurchaseOrder__c PO = [
        SELECT Opportunity__c
        FROM PurchaseOrder__c
        WHERE id = :po.id
      ];
      activity.RelatedObjectId__c = insertedComment.id;
      activity.Opportunity__c = PO.Opportunity__c;
      activity.Approved_Date__c = Datetime.valueOf(System.now());
      activity.Approved_By__c = insertedComment.User__c;
      insert activity;
    } catch (Exception ex) {
      System.debug('ERROR While adding comment in LineItem' + ex.getMessage());
    }
  }
}
