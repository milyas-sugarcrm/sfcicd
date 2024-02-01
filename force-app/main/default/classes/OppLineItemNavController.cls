public class OppLineItemNavController {
  @AuraEnabled
  public static List<User> getSystemUsers() {
    try {
      List<User> userList = [
        SELECT Name
        FROM User
        WHERE IsActive = TRUE
      ];
      System.debug(userList);
      if (userList != null || userList.size() > 0) {
        return userList;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception in getting users---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static boolean updatePurchaseOrders(
    Id lineitem_id,
    String production_rep
  ) {
    try {
      List<PurchaseOrder_LineItem__c> orderList = [
        SELECT Id, Production_Rep__c
        FROM PurchaseOrder_LineItem__c
        WHERE Id = :lineitem_id
      ];
      if (orderList != null && orderList.size() > 0) {
        orderList.get(0).Production_Rep__c = production_rep;
        update orderList;
        return true;
      }
      return false;
    } catch (Exception ex) {
      System.debug(
        'Exception in getting Purchase Orders---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static Boolean generatePdfForPurchaseOrder(Id orderId) {
    try {
      List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = [
        SELECT
          WO_Status__c,
          Production_Rep__c,
          PurchaseOrder__c,
          OpportunityLineItem__c,
          Id,
          Name
        FROM PurchaseOrder_LineItem__c
        WHERE Work_Order__c = :orderId
      ];
      List<String> fileName = new List<String>();
      for (PurchaseOrder_LineItem__c poLineItems : purchaseOrderLineItem) {
        fileName.add('PurchaseOrder#' + poLineItems.Name);
      }
      Integer count = 0;
      List<ContentVersion> contentVersions = new List<ContentVersion>();
      List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
      if (
        purchaseOrderLineItem.size() != null &&
        purchaseOrderLineItem.size() > 0
      ) {
        delete [
          SELECT id
          FROM ContentDocumentLink
          WHERE
            (LinkedEntityId = :orderId
            OR LinkedEntityId = :purchaseOrderLineItem)
            AND ContentDocument.Title = :fileName
        ];

        for (PurchaseOrder_LineItem__c poLineItems : purchaseOrderLineItem) {
          PageReference pdf;

          pdf = Page.PurchaseOrderPreviewPdf;
          pdf.getParameters().put('id', poLineItems.Id);

          Blob body;
          if (Test.isRunningTest()) {
            body = blob.valueOf('Unit.Test');
          } else {
            body = pdf.getContentAsPDF();
          }

          ContentVersion conVer = new ContentVersion();
          conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
          conVer.PathOnClient = fileName[count] + '.pdf'; // The files name, extension is very important here which will help the file in preview.
          conVer.Title = fileName[count++]; // Display name of the files
          conVer.VersionData = body;
          contentVersions.add(conVer);
        }
        insert contentVersions;
        List<ContentVersion> contentVersionList = [
          SELECT Id, ContentDocumentId
          FROM ContentVersion
          WHERE Id = :contentVersions
        ];
        Map<Id, Id> cvToPoLineItems = new Map<Id, Id>();
        for (PurchaseOrder_LineItem__c poLineItems : purchaseOrderLineItem) {
          for (ContentVersion cv : contentVersions) {
            if (cv.Title == 'PurchaseOrder#' + poLineItems.Name) {
              cvToPoLineItems.put(cv.Id, poLineItems.Id);
            }
          }
        }
        for (ContentVersion conVer : contentVersionList) {
          ContentDocumentLink cDe = new ContentDocumentLink();
          cDe.ContentDocumentId = conVer.ContentDocumentId;
          cDe.LinkedEntityId = orderId;
          cDe.ShareType = 'V';
          conDocLink.add(cDe);

          ContentDocumentLink cDe2 = new ContentDocumentLink();
          cDe2.ContentDocumentId = conVer.ContentDocumentId;
          cDe2.LinkedEntityId = cvToPoLineItems.get(conVer.Id);
          cDe2.ShareType = 'V';
          conDocLink.add(cDe2);
        }
        insert conDocLink;
        return true;
      }
      return true;
    } catch (Exception ex) {
      System.debug('Exception in geenrating PDF');
      return false;
    }
  }
  /*   @AuraEnabled
    public static List <purchaseOrderProofs> changeAllProofsUploadedStatus(Id purchaseOrderId, Boolean changedStatus )
    {
        try
        {
            
            PurchaseOrder_LineItem__c purchaseOrderLineItem = [SELECT All_proofs_uploaded__c, PurchaseOrder__c, 
                                                               OpportunityLineItem__c, Id 
                                                               FROM PurchaseOrder_LineItem__c 
                                                               WHERE id =: purchaseOrderId];
            List <Proof__c> listOfRelatedProofs = [SELECT Id, Name, PurchaseOrder_LineItem__c, Status__c, File_Name__c, documentId__c 
                                                   FROM Proof__c
                                                   WHERE PurchaseOrder_LineItem__c =: purchaseOrderLineItem.id];
            String proofStatus = null;
            if(changedStatus == false)
            {
                proofStatus = 'Awaiting Proof';
            }
            else if(listOfRelatedProofs.size() == 0)
            {
                
                purchaseOrderLineItem.Proof_Status__c = 'Proofing Complete';
                
            }
            else if(listOfRelatedProofs.size() > 0)
            {
                
                for(Proof__c proof: listOfRelatedProofs)
                {
                    if(proof.Status__c != 'Client Aprroved' && proof.Status__c != 'Proofing Complete')
                    {
                        proofStatus = proof.Status__c;
                        break;
                    }
                }
            }
            if(proofStatus == null)
            {
                purchaseOrderLineItem.Proof_Status__c = 'Client Aprroved';
            }
            else
            {
                purchaseOrderLineItem.Proof_Status__c = proofStatus;
            }
            purchaseOrderLineItem.All_proofs_uploaded__c = changedStatus;
            update purchaseOrderLineItem;
            
            return getDetailsRelatedPurchaseOrderProofs(purchaseOrderId);
        }
        catch (Exception ex)
        {
            System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null; 
        }
    }
    @AuraEnabled
    public  static List <purchaseOrderProofs> createNewProof (Id documentId , String fileName ,Id purchaseOrderLineItemId , Id purchaseOrderId )
    {
        try
        {
            Proof__c proof = new Proof__c ();
            proof.Status__c = 'Pending Approval';
            proof.PurchaseOrder_LineItem__c = purchaseOrderLineItemId;
            proof.File_Name__c = fileName;
            //   proof.documentId__c = documentId;
            insert proof;
            
            ContentDocumentLink previousLink = [SELECT ContentDocumentId, LinkedEntityId, ContentDocument.CreatedDate 
                                                FROM ContentDocumentLink 
                                                where ContentDocumentId = :documentId 
                                                Order BY ContentDocument.CreatedDate DESC
                                                LIMIT 1];
            ContentDocumentLink clonedImage = previousLink.Clone();
            clonedImage.LinkedEntityId = proof.Id;
            clonedImage.ContentDocumentId = documentId;
            insert clonedImage;
            delete previousLink;
            return getDetailsRelatedPurchaseOrderProofs(purchaseOrderId);
        }
        catch (Exception ex)
        {
            System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null; 
        }
    }
    @AuraEnabled
    public static List <purchaseOrderProofs> changeStatusOfProofPicklist(Id proofId , Id purchaseOrderId, String changedStatus )
    {
        try
        {
            if(changedStatus == 'Change Requested' )
            {
               // addCommentForProofInDB(proofId, purchaseOrderId, '(Request Change)');
            }
            else if (changedStatus == 'Client Approved')
            {
                //addCommentForProofInDB(proofId, purchaseOrderId, '(Approved)');
            }
            Proof__c proof = [SELECT Id, Status__c ,PurchaseOrder_LineItem__c
                              FROM Proof__c
                              WHERE Id =: proofId];
            proof.Status__c = changedStatus;
            update proof;
            PurchaseOrder_LineItem__c poLineItem = [SELECT id, All_proofs_uploaded__c,Proof_Status__c, PurchaseOrder__c 
                                                    FROM PurchaseOrder_LineItem__c 
                                                    WHERE id =: proof.PurchaseOrder_LineItem__c Limit 1]; 
            List<Proof__c> proofList = [SELECT Id, Status__c ,PurchaseOrder_LineItem__c 
                              FROM Proof__c
                              WHERE PurchaseOrder_LineItem__c =: poLineItem.id];
            String proofStatus = null;
            if(poLineItem.All_proofs_uploaded__c == false)
            {
                proofStatus = 'Awaiting Proof';
            }
            else if(proofList.size() == 1)
            {
                proofStatus = proof.Status__c;
            }
            else if(proofList.size() > 1)
            {
                
                for(Proof__c pf: proofList)
                {
                    if(pf.Status__c != 'Client Aprroved' && pf.Status__c != 'Proofing Complete')
                    {
                        proofStatus = pf.Status__c;
                        break;
                    }
                }
            }
            if(proofStatus == null)
            {
                poLineItem.Proof_Status__c = 'Client Aprroved';
            }
            else
            {
                poLineItem.Proof_Status__c = proofStatus;
            }
            update poLineItem;
            return getDetailsRelatedPurchaseOrderProofs(purchaseOrderId);
        }   
        catch (Exception ex)
        {
            System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null; 
        }
    } */
  @AuraEnabled
  public static void addCommentForMarkAsDropDown(String poNumber, String key) {
    try {
      PurchaseOrder_LineItem__c poLineItem = [
        SELECT
          Id,
          WO_Status__c,
          Proof__c,
          OpportunityLineItem__c,
          PurchaseOrder__c,
          Name
        FROM PurchaseOrder_LineItem__c
        WHERE Name = :poNumber
      ];
      if (key == 'fax') {
        addCommentAndAttachment(
          poLineItem.Id,
          false,
          null,
          'Submitted PO#' + poLineItem.Name + ' by ' + key
        );
      } else if (key == 'Supplier site') {
        addCommentAndAttachment(
          poLineItem.Id,
          false,
          null,
          'Submitted PO#' + poLineItem.Name + ' on ' + key
        );
      } else if (key == 'ftp') {
        addCommentAndAttachment(
          poLineItem.Id,
          false,
          null,
          'Submitted PO#' + poLineItem.Name + ' by ' + key
        );
      } else if (key == 'submitted') {
        addCommentAndAttachment(
          poLineItem.Id,
          false,
          null,
          'Submitted PO#' + poLineItem.Name
        );
      }
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }
  /*  @AuraEnabled
    public static List <purchaseOrderProofs> addCommentForProofInDB (Id proofId , Id purchaseOrderId, String comment )
    {
        try
        {
            
            Comment__c comm = new Comment__c ();
            comm.Comment__c = comment;
            comm.Date__c = System.now().format('MM-dd-yyyy');
            comm.Proof__c = proofId;
            insert comm;
            
            Comment__c insertedComment = [SELECT Id, Date__c, Proof__c, Comment_Date__c, User__c, Comment__c, CreatedBy.Name 
                                          FROM Comment__c
                                          WHERE Id =: comm.Id];
            insertedComment.User__c = insertedComment.CreatedBy.Name ; 
            update insertedComment;
            /// Insert Activity for change or approve
            if(comment == '(Request Change)' || comment=='(Approved)')
            {
                Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
                if(comment == '(Request Change)')
                {
                     activity.Type__c = 'Proof (Change Requested)';  
                }
                else if(comment=='(Approved)')
                {
                    activity.Type__c = 'Proof (Client Approved)';  
                }
                
                PurchaseOrder__c PO = [SELECT Opportunity__c FROM PurchaseOrder__c WHERE id =: purchaseOrderId];
                activity.RelatedObjectId__c = insertedComment.id;
                activity.Opportunity__c = PO.Opportunity__c;
                activity.Approved_Date__c = Datetime.valueOf(System.now());
                activity.Approved_By__c = insertedComment.User__c;
                insert activity; 
            }
            return getDetailsRelatedPurchaseOrderProofs(purchaseOrderId);
        }
        catch (Exception ex)
        {
            System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static List <purchaseOrderProofs> getDetailsRelatedPurchaseOrderProofs (Id purchaseOrderId)
    {
        try
        {
            List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = [SELECT All_proofs_uploaded__c,PO__c, WO_Status__c, Production_Rep__c, PurchaseOrder__c, OpportunityLineItem__c, Id 
                                                                     FROM PurchaseOrder_LineItem__c 
                                                                     WHERE PurchaseOrder__c =: purchaseOrderId];
            List <Proof__c> listOfRelatedProofs = [SELECT Id, Name, PurchaseOrder_LineItem__c, Status__c, File_Name__c, documentId__c 
                                                   FROM Proof__c
                                                   WHERE PurchaseOrder_LineItem__c =: purchaseOrderLineItem];
            List<OpportunityLineItem__c> opportunityLineItems = [SELECT Id, Opportunity__c,PurchaseOrder_LineItem__c, SKU__c, SortOrder__c,Shipping_Information__r.In_Hands_Date__c,Shipping_Information__r.Ship_To__c, Shipping_Information__r.Supplier__c, Work_Order__c 
                                                                 FROM OpportunityLineItem__c
                                                                 WHERE PurchaseOrder_LineItem__c =:purchaseOrderLineItem];
            
            Map<Id,OpportunityLineItem__c> purchaseOrderLineItem_OppLineItemMap = new Map<Id,OpportunityLineItem__c>();
            
            for(OpportunityLineItem__c opplineItem : opportunityLineItems)
            {
                purchaseOrderLineItem_OppLineItemMap.put(opplineItem.PurchaseOrder_LineItem__c,opplineItem );
            }
            List<Id> supplierIds = new List<Id>();
            List<Id> shippingInformationId =  new List<Id>();
            for (OpportunityLineItem__c opp : opportunityLineItems)
            {
                supplierIds.add( opp.Shipping_Information__r.Supplier__c);
                shippingInformationId.add(opp.Shipping_Information__c);
            }
            Map<Id,Shipping_Information__c> shippingInformationMap = new Map<Id,Shipping_Information__c>([Select Id,Name 
                                                                                                          From Shipping_Information__c
                                                                                                          Where Id =: shippingInformationId]);
            Map<Id, Account> supplierMap = new Map<Id, Account>([SELECT Id, Name
                                                                 FROM Account 
                                                                 WHERE Id =: supplierIds]);
            Map<id,List<Proof__c>> purchaseOrderId_proofsMap = new Map<id,List<Proof__c>>();
            for(PurchaseOrder_LineItem__c po : purchaseOrderLineItem)
            {
                List<Proof__c> listForMap = new List<Proof__c>();
                for (Proof__c proof : listOfRelatedProofs)
                {
                    if (proof.PurchaseOrder_LineItem__c == po.Id)
                    {
                        listForMap.add(proof);
                    }
                }
                purchaseOrderId_proofsMap.put(po.Id, listForMap);
            }
            List <Comment__c> commentsRelatedToProofs = [SELECT Proof__c, Date__c, User__c, Comment__c, Id 
                                                         FROM Comment__c 
                                                         WHERE Proof__c =: listOfRelatedProofs
                                                         ORDER BY CreatedDate
                                                         ASC];
            Map<Id,List<Comment__c>> proof_commentsMap = new Map<Id,List<Comment__c>>();
            Map<Id,Id> mapContentLink_ContentVersion = new Map<Id,Id>();
            List<Id> contentVersionIds = new List<Id>();
            for (Proof__c proof : listOfRelatedProofs)
            {
                System.debug('contentVersionIds '+proof.documentId__c);
                contentVersionIds.add(proof.documentId__c);
                List<Comment__c> commentsListForMap = new List<Comment__c>();
                for(Comment__c comm : commentsRelatedToProofs)
                {
                    if(comm.Proof__c == proof.Id)
                    {
                        commentsListForMap.add(comm);
                    }
                }
                proof_commentsMap.put(proof.Id , commentsListForMap);
            }
            List<ContentVersion> productRelatedImageFiles= [SELECT id,ContentDocumentId 
                                                            FROM ContentVersion 
                                                            WHERE ContentDocumentId IN :contentVersionIds 
                                                            ] ;       
            System.debug('productRelatedImageFiles '+productRelatedImageFiles.size());
            for(ContentVersion contentVersion:productRelatedImageFiles)
            {
                mapContentLink_ContentVersion.put(contentVersion.ContentDocumentId,contentVersion.id);
                System.debug('contentVersion '+contentVersion.ContentDocumentId);

            }
            System.debug('mapContentLink_ContentVersion---->>>>>> +' + mapContentLink_ContentVersion);
            
            List <purchaseOrderProofs> listToReturn = new List <purchaseOrderProofs> ();
            for(PurchaseOrder_LineItem__c poLineItem : purchaseOrderLineItem)
            {
                List <Proof__c> proofsList = new List <Proof__c>();
                proofsList = purchaseOrderId_proofsMap.get(poLineItem.Id);
                if (proofsList != null && proofsList.size() > 0)
                {
                    
                    purchaseOrderProofs poProof = new purchaseOrderProofs();
                    poProof.purchaseOrderNumber = poLineItem.PO__c;
                    poProof.purchaseOrderId = poLineItem.Id;
                    poProof.allProofUploadedStatus = poLineItem.All_proofs_uploaded__c;
                    poProof.supplier =  supplierMap.get(purchaseOrderLineItem_OppLineItemMap.get(poLineItem.Id).Shipping_Information__r.Supplier__c).Name;
                    List <proofDetailsObject> detailsOfProofs = new List <proofDetailsObject>();
                    
                    for(Proof__c proof : proofsList)
                    {
                        proofDetailsObject  proofObjectToAddInList = new proofDetailsObject();
                        proofObjectToAddInList.comments =  proof_commentsMap.get(proof.Id);
                        proofObjectToAddInList.fileName = proof.File_Name__c;
                        proofObjectToAddInList.status = proof.Status__c;
                        proofObjectToAddInList.contentVersionId = mapContentLink_ContentVersion.get(proof.documentId__c);
                        proofObjectToAddInList.proofId = proof.Id;
                        detailsOfProofs.add(proofObjectToAddInList);
                    }
                    poProof.proofs = detailsOfProofs;
                    system.debug('prooofsss---->>>>>> ' + poProof); 
                    listToReturn.add(poProof);
                }
                
            }
            
            return listToReturn;
                    
        }
        catch (Exception ex)
        {
            System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null;
        }
    }*/
  /* @AuraEnabled
 	public static Boolean regeneratePurchaseOrder (String purchaseOrder)
    {
        system.Debug(purchaseOrder);
        PurchaseOrder__c po = [SELECT Id, Opportunity__c 
                               FROM PurchaseOrder__c 
                               WHERE id =: purchaseOrder];
        List <PurchaseOrder_LineItem__c> poItems = [SELECT Id, CreatedDate, SystemModstamp, PO__c, Shipped_Date__c
                                                    FROM PurchaseOrder_LineItem__c
                                                    where PurchaseOrder__c =: purchaseOrder ];
        Id opp = po.Opportunity__c;
        List<Proof__c> proofs = [SELECT Id FROM Proof__c 
                                 WHERE PurchaseOrder_LineItem__c =: poItems];
        delete [SELECT Id FROM Comment__c WHERE Proof__c =: proofs ];
        delete [SELECT Id FROM Comment__c WHERE PurchaseOrder_LineItem__c =: poItems];
        delete [SELECT Id FROM PurchaseOrder_LineItem__c WHERE Id=:poItems ];
        delete po;
        ShippingOppLineItemController.createPurchaseOrderInDb(null,true,opp);
        
        return true;
    }*/
  @AuraEnabled
  public static List<purchaseOrderDetails> deletPurchaseOrderLineItems(
    Id recordToDelete,
    Id purchaseOrderId
  ) {
    List<Proof__c> proofs = [
      SELECT Id
      FROM Proof__c
      WHERE PurchaseOrder_LineItem__c = :recordToDelete
    ];
    delete [SELECT Id FROM Comment__c WHERE Proof__c = :proofs];
    delete [
      SELECT Id
      FROM Comment__c
      WHERE PurchaseOrder_LineItem__c = :recordToDelete
    ];
    delete [
      SELECT Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :recordToDelete
    ];
    return getDetailsRelatedPurchaseOrder(purchaseOrderId);
  }
  @AuraEnabled
  public static List<purchaseOrderDetails> getDetailsRelatedPurchaseOrder(
    Id purchaseOrderId
  ) {
    List<ContentDocumentLink> relatedImages = new List<ContentDocumentLink>();

    List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = [
      SELECT
        Proof_Status__c,
        WO_Status__c,
        Proof__c,
        Production_Rep__c,
        PurchaseOrder__c,
        OpportunityLineItem__c,
        OpportunityLineItem__r.Name,
        Id,
        Name
      FROM PurchaseOrder_LineItem__c
      WHERE Work_Order__c = :purchaseOrderId
    ];
    List<OpportunityLineItem__c> opportunityLineItems = [
      SELECT
        Id,
        Opportunity__c,
        Name,
        PurchaseOrder_LineItem__c,
        Product__c,
        Is_Associated_With_Artwork__c,
        SKU__c,
        SortOrder__c,
        Shipping_Information__r.In_Hands_Date__c,
        Shipping_Information__r.Ship_To__c,
        Shipping_Information__r.Supplier__c,
        Work_Order__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :purchaseOrderLineItem
    ];
    System.debug(opportunityLineItems);
    List<Id> supplierIds = new List<Id>();
    List<Id> opportunityLineItemsIds = new List<Id>();
    List<Id> opportunityLineItemsAttachmentsIds = new List<Id>();
    Map<Id, String> purchaseOrderToProductNameMap = new Map<Id, String>();

    for (OpportunityLineItem__c opp : opportunityLineItems) {
      supplierIds.add(opp.Shipping_Information__r.Supplier__c);
      opportunityLineItemsIds.add(opp.Id);
      purchaseOrderToProductNameMap.put(
        opp.PurchaseOrder_LineItem__c,
        opp.Name
      );
    }
    List<OpportunityLineItemAttachment__c> lstOpportunityLineItemsAttachments = [
      SELECT OpportunityLineItem__c, Id
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c = :opportunityLineItemsIds
    ];
    Map<Id, Id> mapOppItemToAttachment = new Map<Id, Id>();
    for (
      OpportunityLineItemAttachment__c oppLineItemAttachmentObj : lstOpportunityLineItemsAttachments
    ) {
      opportunityLineItemsAttachmentsIds.add(oppLineItemAttachmentObj.Id);
      mapOppItemToAttachment.put(
        oppLineItemAttachmentObj.Id,
        oppLineItemAttachmentObj.OpportunityLineItem__c
      );
    }
    if (opportunityLineItemsAttachmentsIds.size() > 0) {
      relatedImages = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :opportunityLineItemsAttachmentsIds
      ];
    }
    Map<Id, Account> supplierMap = new Map<ID, Account>(
      [
        SELECT Id, Name
        FROM Account
        WHERE Id = :supplierIds
      ]
    );
    Map<Id, Id> mapContentLink_ContentVersion = new Map<Id, Id>();
    Map<Id, Id> opportunityLineItem_contentDocumentIdMap = new Map<Id, Id>();
    List<Id> lstContentDocumentIds = new List<Id>();
    if (relatedImages.size() > 0) {
      for (ContentDocumentLink obj : relatedImages) {
        lstContentDocumentIds.add(obj.ContentDocumentId);
        Id OppId = mapOppItemToAttachment.get(obj.LinkedEntityId);
        opportunityLineItem_contentDocumentIdMap.put(
          OppId,
          obj.ContentDocumentId
        );
      }
    }
    List<ContentVersion> productRelatedImageFiles = [
      SELECT id, ContentDocumentId
      FROM ContentVersion
      WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
    ];
    for (ContentVersion contentVersion : productRelatedImageFiles) {
      mapContentLink_ContentVersion.put(
        contentVersion.ContentDocumentId,
        contentVersion.id
      );
    }
    Map<Id, List<OpportunityLineItem__c>> purchaseOrder_OpportunityLuineItemListMap = new Map<Id, List<OpportunityLineItem__c>>();

    for (OpportunityLineItem__c opp : opportunityLineItems) {
      if (
        purchaseOrder_OpportunityLuineItemListMap.containsKey(
          opp.PurchaseOrder_LineItem__c
        )
      ) {
        purchaseOrder_OpportunityLuineItemListMap.get(
            opp.PurchaseOrder_LineItem__c
          )
          .add(opp);
      } else {
        List<OpportunityLineItem__c> oppLineItem = new List<OpportunityLineItem__c>();
        oppLineItem.add(opp);
        purchaseOrder_OpportunityLuineItemListMap.put(
          opp.PurchaseOrder_LineItem__c,
          oppLineItem
        );
      }
    }
    List<purchaseOrderDetails> purchaseOrdersData = new List<purchaseOrderDetails>();
    List<Id> opportunityLineItemIds = new List<Id>();

    if (purchaseOrderLineItem != null && purchaseOrderLineItem.size() > 0) {
      for (PurchaseOrder_LineItem__c lineItem : purchaseOrderLineItem) {
        purchaseOrderDetails poData = new purchaseOrderDetails();
        List<OpportunityLineItem__c> oppLineItem = purchaseOrder_OpportunityLuineItemListMap.get(
          lineItem.Id
        );
        List<String> skus = new List<String>();
        if (lineItem.Proof_Status__c != null) {
          poData.proofStatus = lineItem.Proof_Status__c;
          poData.proof = lineItem.Proof_Status__c;
        } else {
          poData.proofStatus = 'No Proof Required';
          poData.proof = 'No Proof Required';
        }
        poData.productName = purchaseOrderToProductNameMap.get(lineItem.Id);
        poData.poNumber = lineItem.Name;
        Boolean imageFound = false;
        poData.poId =
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/lightning/r/Opportunity/' +
          lineItem.id +
          '/view';
        if (oppLineItem != null) {
          for (OpportunityLineItem__c oppLineItemObj : oppLineItem) {
            skus.add(oppLineItemObj.SKU__c);
            if (oppLineItemObj != null && imageFound == false) {
              if (
                opportunityLineItem_contentDocumentIdMap.containsKey(
                  oppLineItemObj.Id
                )
              ) {
                poData.imageVersionId = mapContentLink_ContentVersion.get(
                  opportunityLineItem_contentDocumentIdMap.get(
                    oppLineItemObj.Id
                  )
                );
                imageFound = true;
              }
            }
          }
          if (oppLineItem.get(0) != null) {
            poData.inHandsDate = oppLineItem.get(0)
              .Shipping_Information__r.In_Hands_Date__c;
            poData.supplier = supplierMap.get(
                oppLineItem.get(0).Shipping_Information__r.Supplier__c
              )
              .Name;
            poData.supplierUrl =
              URL.getSalesforceBaseUrl().toExternalForm() +
              '/lightning/r/Account/' +
              supplierMap.get(
                  oppLineItem.get(0).Shipping_Information__r.Supplier__c
                )
                .id +
              '/view';
          }
        }
        if (lineItem.WO_Status__c != null) {
          poData.Status = lineItem.WO_Status__c;
        } else {
          poData.Status = 'Open';
        }

        poData.poLineItemId = lineItem.Id;
        poData.SKU = skus;
        poData.productionRep = lineItem.Production_Rep__c;
        purchaseOrdersData.add(poData);
      }
      return purchaseOrdersData;
    }
    return null;
  }

  @AuraEnabled
  public static List<CommentsDetailsObject> getNotesAttachmentData(
    Id purchaseOrderLineItemId
  ) {
    try {
      List<Comment__c> comments = [
        SELECT
          Id,
          Comment__c,
          User__c,
          PurchaseOrder_LineItem__c,
          Comment_Date__c
        FROM Comment__c
        WHERE PurchaseOrder_LineItem__c = :purchaseOrderLineItemId
      ];
      List<Id> commentIds = new List<Id>();

      if (comments != null && comments.size() > 0) {
        List<CommentsDetailsObject> commentsDetailsToReturn = new List<CommentsDetailsObject>();
        for (Comment__c comm : comments) {
          commentIds.add(comm.Id);
        }
        List<ContentDocumentLink> contentDocuments = [
          SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
          FROM ContentDocumentLink
          WHERE LinkedEntityId = :commentIds
        ];
        Map<Id, Id> commentIdContentDocumentIdMap = new Map<Id, Id>();
        for (ContentDocumentLink doc : contentDocuments) {
          commentIdContentDocumentIdMap.put(
            doc.LinkedEntityId,
            doc.ContentDocumentId
          );
        }

        PurchaseOrder_LineItem__c purchaseOrderData = [
          SELECT
            Id,
            WO_Status__c,
            Proof__c,
            Production_Rep__c,
            OpportunityLineItem__r.SKU__c,
            OpportunityLineItem__r.Supplier__c,
            PurchaseOrder__c,
            Name
          FROM PurchaseOrder_LineItem__c
          WHERE Id = :purchaseOrderLineItemId
        ];
        for (Comment__c comm : comments) {
          CommentsDetailsObject obj = new CommentsDetailsObject();
          obj.comment = comm.Comment__c;
          obj.User = comm.User__c;
          obj.documentId = commentIdContentDocumentIdMap.get(comm.Id);
          obj.poNumber = purchaseOrderData.Name;
          obj.commentDate = comm.Comment_Date__c;
          obj.supplier = purchaseOrderData.OpportunityLineItem__r.Supplier__c;
          commentsDetailsToReturn.add(obj);
        }
        return commentsDetailsToReturn;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static void addCommentForPicklistChange(
    String poNumber,
    String picklistStatus
  ) {
    try {
      PurchaseOrder_LineItem__c poLineItem = [
        SELECT
          Id,
          WO_Status__c,
          Proof__c,
          OpportunityLineItem__c,
          PurchaseOrder__c,
          Name
        FROM PurchaseOrder_LineItem__c
        WHERE Name = :poNumber
      ];
      poLineItem.WO_Status__c = picklistStatus;
      if (picklistStatus == 'Shipped' || picklistStatus == 'Billed') {
        poLineItem.Shipped_Date__c = System.now();
      }

      update poLineItem;
      addCommentAndAttachment(
        poLineItem.Id,
        false,
        null,
        'PO#' + poLineItem.Name + ' flagged as ' + pickListStatus
      );
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }
  @AuraEnabled
  public static List<CommentsDetailsObject> addCommentAndAttachment(
    Id purchaseOrderId,
    Boolean isFileUploaded,
    String documentId,
    String comment
  ) {
    system.debug('comment-->>' + comment);

    Comment__c comm = new Comment__c();
    comm.Comment__c = comment;
    comm.Date__c = System.now().format('MM-dd-yyyy');
    comm.PurchaseOrder_LineItem__c = purchaseOrderId;
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
    if (isFileUploaded) {
      ContentDocumentLink contentDocument = [
        SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
        FROM ContentDocumentLink
        WHERE
          ContentDocumentId = :documentId
          AND LinkedEntityId = :purchaseOrderId
      ];
      ContentDocumentLink updatedDocument = contentDocument.clone();
      updatedDocument.LinkedEntityId = comm.Id;
      insert updatedDocument;
      delete contentDocument;
    }
    return getNotesAttachmentData(purchaseOrderId);
  }

  @AuraEnabled
  public static Id getPurchaseOrderId(Id oppId) {
    try {
      List<PurchaseOrder__c> purchaseOrderList = [
        SELECT Id, Purchase_Order_Date__c, Opportunity__c
        FROM PurchaseOrder__c
        WHERE Opportunity__c = :oppId
      ];
      if (purchaseOrderList != null && purchaseOrderList.size() > 0) {
        return purchaseOrderList.get(0).Id;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static Id getPurchaseOrderIdForWorkOrders(Id workId) {
    try {
      Order orderRecord = [SELECT OpportunityId FROM Order WHERE Id = :workId];
      Id oppId = orderRecord.OpportunityId;
      /*List<PurchaseOrder__c> purchaseOrderList = [SELECT Id, Purchase_Order_Date__c, Opportunity__c 
FROM PurchaseOrder__c
WHERE Opportunity__c =: oppId];*/
      List<PurchaseOrder_LineItem__c> purchaseOrderList = [
        SELECT Id, Production_Rep__c
        FROM PurchaseOrder_LineItem__c
        WHERE Work_Order__c = :workId
      ];
      if (purchaseOrderList != null && purchaseOrderList.size() > 0) {
        return purchaseOrderList.get(0).Id;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static String getOpportunityName(Id oppId) {
    List<Opportunity> opps = [
      SELECT Id, Name
      FROM Opportunity
      WHERE Id = :oppId
    ];
    if (opps.size() > 0) {
      for (Opportunity opp : opps) {
        return opp.Name;
      }
    }
    return null;
  }
  @AuraEnabled
  public static String getOpportunityStage(Id oppId) {
    Opportunity opp = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :oppId
    ];
    if (opp != null)
      return opp.StageName;
    else
      return null;
  }
  @AuraEnabled
  public static Id getEstimateOfOpportunity(Id oppId) {
    List<Estimate__c> oppEstimate = [
      SELECT Id, Name
      FROM Estimate__c
      WHERE Opportunity__c = :oppId
    ];
    if (oppEstimate.size() > 0) {
      return oppEstimate[0].Id;
    } else {
      return null;
    }
  }

  @AuraEnabled
  public static Id getWorkOrderOfOpportunity(Id oppId) {
    try {
      Integer index = 0;
      List<Order> oppWorkOrder = [
        SELECT Id, Name
        FROM Order
        WHERE OpportunityId = :oppId
      ];
      if (oppWorkOrder != null && oppWorkOrder.size() > 0) {
        return oppWorkOrder.get(index).Id;
      } else {
        return null;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }

  // @AuraEnabled
  // public static Id getWorkOrder(Id oppId)
  // {
  //     // return oppId;
  //     try
  //     {
  //         Integer index = 0;
  //         List<Order> oppWorkOrder = [SELECT Id, Name
  //                                     FROM Order
  //                                     where Id = :oppId
  //                                    ];
  //         if(oppWorkOrder != null && oppWorkOrder.size()>0)
  //         {
  //             return oppWorkOrder.get(index).Id;
  //         }
  //         else
  //         {
  //             return null;
  //         }
  //     }
  //     catch (Exception ex)
  //     {
  //         System.debug('Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage());
  //         return null;
  //     }
  // }

  @AuraEnabled
  public static Id getPurchaseOpportunity(Id oppId) {
    try {
      Integer index = 0;
      String SalesOrderInvoiceNo = 'SalesOrder-' + oppId;
      List<Order> oppWorkOrder = [
        SELECT Id, Name
        FROM Order
        WHERE Invoice_Number__c = :SalesOrderInvoiceNo
      ];
      if (oppWorkOrder != null && oppWorkOrder.size() > 0) {
        return oppWorkOrder.get(index).Id;
      } else {
        return null;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static String getUserPic() {
    try {
      User u = [
        SELECT u.SmallPhotoUrl, u.FullPhotoUrl
        FROM User u
        WHERE u.id = :Userinfo.getUserid()
      ];
      String PhotoLink = u.FullPhotoUrl;
      return PhotoLink;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
      return null;
    }
  }

  /*@AuraEnabled
    public static String getProofApprovalPageLink(Id purchaseOrderId)
    {
        try 
        {
            List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = [SELECT PO__c, WO_Status__c, Production_Rep__c, PurchaseOrder__c, OpportunityLineItem__c, Id 
                                                                     FROM PurchaseOrder_LineItem__c 
                                                                     WHERE PurchaseOrder__c =: purchaseOrderId];
            List <Proof__c> listOfRelatedProofs = [SELECT Id, Name, PurchaseOrder_LineItem__c, Status__c, File_Name__c, documentId__c 
                                                   FROM Proof__c
                                                   WHERE PurchaseOrder_LineItem__c =: purchaseOrderLineItem];
            if(listOfRelatedProofs != null && listOfRelatedProofs.size()>0)
            {
                return URL.getSalesforceBaseUrl().toExternalForm()+'/apex/PurchaseOrderProofApprovalPage?id=';
            }
            else
            {
                return null;
            }
        }
        catch (Exception ex)
        {
            System.debug('Exception in fetching preview proofapproval page link ---->>>>' + ex.getStackTraceString() + ex.getMessage());
            return null;
        }
        
    }*/
}
