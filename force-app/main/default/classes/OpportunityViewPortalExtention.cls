public class OpportunityViewPortalExtention {
  private final Opportunity opp;
  Opportunity record = new Opportunity();

  Boolean restRequestNeeded = System.isFuture() || System.isScheduled(); // System.isBatch() too?

  public OpportunityViewPortalExtention() {
    String oppId = ApexPages.currentPage().getParameters().get('id');
    this.opp = [SELECT Id, Name FROM Opportunity WHERE id = :oppId];
    record = [SELECT Id, Name, stageName FROM Opportunity WHERE id = :opp.id];
  }
  public OpportunityViewPortalExtention(
    ApexPages.StandardController stdController
  ) {
    this.opp = (Opportunity) stdController.getRecord();
    record = [SELECT Id, Name, stageName FROM Opportunity WHERE id = :opp.id];
  }

  public List<OpportunityViewPortalModelClass> getDetails() {
    List<OpportunityViewPortalModelClass> activityList = new List<OpportunityViewPortalModelClass>();
    List<Opportunity_ACTIVITIES__c> activities = [
      SELECT
        id,
        Type__c,
        Opportunity__c,
        RelatedObjectId__c,
        Comment__c,
        CreatedDate
      FROM Opportunity_ACTIVITIES__c
      WHERE Opportunity__c = :opp.Id
      ORDER BY CreatedDate DESC
    ];

    /* List<Order> orders = [Select Id, OrderNumber, Invoice_Number__c, Work_Order_Notes__c, Approved_Date__c, Approved_By__c, 
Sale_Order_Status__c  from Order 
where Invoice_Number__c =: 'SalesOrder-'+opp.id AND Approved_By__c!=null 
order by CreatedDate DESC]; */
    List<Estimate__c> estimates = [
      SELECT
        Id,
        Name,
        Notes__c,
        Opportunity__c,
        Approved_Date__c,
        Approved_By__c,
        Client_Approval_Status__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.id AND Approved_By__c != NULL
      ORDER BY CreatedDate DESC
    ];
    List<EmailMessage> emails = [
      SELECT
        Subject,
        FromName,
        FromAddress,
        ToAddress,
        TextBody,
        CreatedDate,
        CcAddress
      FROM EmailMessage
      WHERE RelatedToId = :opp.id
      ORDER BY CreatedDate DESC
    ];

    // comment details
    List<OpportunityLineItem__c> lineItemDetails = [
      SELECT Id, Name
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.id
    ];
    List<String> ids = new List<String>();
    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      ids.add(lineItems.id);
    }
    List<Comment__c> comments = [
      SELECT
        id,
        Name,
        Date__c,
        Proof__c,
        Comment__c,
        User__c,
        Comment_Date__c,
        CreatedBy.firstname,
        CreatedBy.lastname,
        OpportunityLineItem__c
      FROM Comment__c
      ORDER BY Comment_Date__c DESC
    ];
    /// proof images
    /*List <Proof__c> listOfProofs = [SELECT Id, Name, PurchaseOrder_LineItem__c, Status__c, File_Name__c, documentId__c 
                                        FROM Proof__c];
        List <Id> proofImages=new List<Id>();
        for (Proof__c proof : listOfProofs)
        {
            proofImages.add(proof.documentId__c);
        }
        List<ContentVersion> proofImagesList= [SELECT id,ContentDocumentId ,ContentDocument.LatestPublishedVersionID
                                               FROM ContentVersion 
                                               WHERE ContentDocumentId IN :proofImages 
                                              ] ;*/
    //////////////
    List<String> commentIds = new List<String>();
    for (Comment__c commentsIDs : comments) {
      if (commentsIDs.OpportunityLineItem__c != null) {
        commentIds.add(commentsIDs.OpportunityLineItem__c);
      }
    }
    List<OpportunityLineItemAttachment__c> attachements = [
      SELECT id, OpportunityLineItem__c
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c IN :commentIds
    ];
    List<String> attachIds = new List<String>();
    for (OpportunityLineItemAttachment__c attach : attachements) {
      attachIds.add(attach.id);
    }

    Map<Id, List<String>> relatedImagesMap = new Map<Id, List<String>>();
    List<ContentDocumentLink> relatedImages = new List<ContentDocumentLink>();
    if (attachIds != null && attachIds.size() > 0) {
      relatedImages = [
        SELECT
          id,
          ContentDocument.title,
          ContentDocumentId,
          ContentDocument.FileType,
          ContentDocument.CreatedDate,
          ContentDocument.LatestPublishedVersionID,
          LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :attachIds
      ];
      List<Id> contentDocIds = new List<Id>();
      for (ContentDocumentLink image : relatedImages) {
        contentDocIds.add(image.ContentDocumentId);
      }
      List<ContentDistribution> ContentDistributionList = [
        SELECT Id, DistributionPublicUrl, ContentDocumentId, ContentDownloadUrl
        FROM ContentDistribution
        WHERE ContentDocumentId IN :contentDocIds
      ];
      for (ContentDocumentLink image : relatedImages) {
        for (ContentDistribution contentDoc : ContentDistributionList) {
          if (image.ContentDocumentId == contentDoc.ContentDocumentId) {
            System.debug('contentDoc: ' + contentDoc);
            List<String> imgLinks = new List<String>();
            imgLinks.add(contentDoc.ContentDownloadUrl);
            imgLinks.add(contentDoc.DistributionPublicUrl);
            relatedImagesMap.put(image.LinkedEntityId, imgLinks);
          }
        }
      }
    }
    ////
    for (Opportunity_ACTIVITIES__c activity : activities) {
      OpportunityViewPortalModelClass newActivity = new OpportunityViewPortalModelClass();
      if (activity.Type__c == 'Comment') {
        for (Comment__c comment : comments) {
          if (comment.id == activity.Comment__c) {
            newActivity.lineItemComments.add(comment);
            Integer imgCount = 1;
            for (OpportunityLineItemAttachment__c attach : attachements) {
              for (ContentDocumentLink imagesList : relatedImages) {
                if (
                  relatedImagesMap != null &&
                  attach.OpportunityLineItem__c ==
                  comment.OpportunityLineItem__c &&
                  imagesList.LinkedEntityId == attach.id &&
                  imgCount < 2
                ) {
                  System.debug('relatedImagesMap: ' + relatedImagesMap);
                  newActivity.imageName = imagesList.ContentDocument.title;
                  newActivity.imageUrl = relatedImagesMap.get(
                    imagesList.LinkedEntityId
                  )[0];
                  System.debug('imageUrl: ' + newActivity.imageUrl);
                  newActivity.imageExist = true;
                  imgCount++;
                }
              }
            }
            if (newActivity.imageName == null) {
              newActivity.imageExist = false;
            }
            activityList.add(newActivity);
          }
        }
      } else if (activity.Type__c == 'Email') {
        for (EmailMessage email : emails) {
          if (email.id == activity.RelatedObjectId__c) {
            OpportunityViewPortalModelClass.EmailMessages emailMessgae = new OpportunityViewPortalModelClass.EmailMessages();
            emailMessgae.fromName = email.fromName;
            emailMessgae.FromAddress = email.FromAddress;
            emailMessgae.Subject = email.Subject;
            emailMessgae.TextBody = email.TextBody;
            emailMessgae.ToAddress = email.ToAddress;
            emailMessgae.CreatedDate = email.CreatedDate;
            emailMessgae.CcAddress = email.CcAddress;
            newActivity.emailList.add(emailMessgae);
            activityList.add(newActivity);
          }
        }
      }
      /*else if(activity.Type__c == 'Approved' || activity.Type__c == 'Change Requested')
{
for(Order  order: orders)
{
if(order.Invoice_Number__c == activity.RelatedObjectId__c)
{
newActivity.ordersList.add(order); 
newActivity.approvedBy = order.Approved_By__c;
newActivity.approveDate = order.Approved_Date__c;
newActivity.status = activity.Type__c;
activityList.add(newActivity);
}
}
}*/
      else if (
        activity.Type__c == 'Approved' ||
        activity.Type__c == 'Change Requested'
      ) {
        for (Estimate__c estimate : estimates) {
          if (estimate.id == activity.RelatedObjectId__c) {
            newActivity.estimateList.add(estimate);
            newActivity.approvedBy = estimate.Approved_By__c;
            newActivity.approveDate = estimate.Approved_Date__c;
            newActivity.status = activity.Type__c;
            activityList.add(newActivity);
          }
        }
      }
      /* else if(activity.Type__c == 'Proof (Client Approved)' || activity.Type__c == 'Proof (Change Requested)')
            {
                for(Comment__c  comment: comments)
                {
                    if(comment.id == activity.RelatedObjectId__c)
                    {
                        newActivity.proofComments.add(comment);
                        newActivity.approvedBy = comment.User__c;
                        newActivity.status = activity.Type__c;
                        
                        Integer imgCount=1;
                        for(ContentVersion imagesList: proofImagesList)
                        {
                            for(Proof__c proof: listOfProofs)
                            {
                                if(imagesList.ContentDocumentId == proof.documentId__c && proof.id==comment.Proof__c && imgCount<2)
                                {
                                    newActivity.imageUrl = (URL.getSalesforceBaseUrl().toExternalForm() +'/sfc/servlet.shepherd/version/download/'+imagesList.ContentDocument.LatestPublishedVersionID);
                                    imgCount++;
                                }
                            }
                            
                        }
                        activityList.add(newActivity);
                    }
                }
            }*/
    }
    return activityList;
  }

  public Boolean getEstimate() {
    List<Estimate__c> estimate = [
      SELECT id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :opp.id
    ];
    if (
      estimate.size() == 0 &&
      (record.stageName != 'Needs Analysis' &&
      record.stageName != 'Presentation')
    ) {
      return false;
    } else {
      return true;
    }
  }

  /* public Boolean getPOStatus()
    {
        List<PurchaseOrder__c> POs = [SELECT id, Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            List<Id> POIds = new List<Id>();
            for(PurchaseOrder__c po: POs)
            {
                POIds.add(po.id);
            }
            List<PurchaseOrder_LineItem__c> POLineItems = [SELECT id, WO_Status__c,PurchaseOrder__c FROM PurchaseOrder_LineItem__c 
                                                           WHERE PurchaseOrder__c IN: POIds];
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {
                if(items.WO_Status__c !='Shipped' && items.WO_Status__c !='Billed')
                {
                    return false;
                }
            }
        }
        return true;
    }
    public String getPurchaseOrderId()
    {
        List<PurchaseOrder__c> POs = [SELECT id, Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            for(PurchaseOrder__c item: POs)
            {
                return item.id;
            }
        }
        return null;
    }
    public String getProofApprovalStatus()
    {
        List<PurchaseOrder__c> POs = [SELECT id, Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            List<Id> POIds = new List<Id>();
            for(PurchaseOrder__c po: POs)
            {
                POIds.add(po.id);
            }
            List<PurchaseOrder_LineItem__c> POLineItems = [SELECT id, WO_Status__c,PurchaseOrder__c FROM PurchaseOrder_LineItem__c 
                                                           WHERE PurchaseOrder__c IN: POIds];
            
            List <Proof__c> listOfRelatedProofs = [SELECT Id, Name, PurchaseOrder_LineItem__c, Status__c, File_Name__c, documentId__c 
                                                   FROM Proof__c
                                                   WHERE PurchaseOrder_LineItem__c =: POLineItems];
            if(listOfRelatedProofs.size()==0)
            {
                return 'hide';
            }
            else
            {
                for(Proof__c items: listOfRelatedProofs)
                {
                    if(items.Status__c !='Client Approved')
                    {
                        return 'In progress';
                    }
                }
                return 'Done';
            }
            
        }
        return 'hide';
    }*/
  public String getLink() {
    String url = URL.getSalesforceBaseUrl().toExternalForm();
    if (url.contains('visualforce.com')) {
      return url + '/apex';
    } else {
      return url + '/OpportunityViewPotal';
    }
  }
  public Opportunity getOpportunity() {
    return record;
  }
  /*  public List<OpportunityViewPortalModelClass> getProofingOrderStatusDetails()
    {
        List<OpportunityViewPortalModelClass> PurchaseOrdersList = new List<OpportunityViewPortalModelClass>();
        List<String> shippedRecords = new List<String>();
        List<PurchaseOrder__c> POs = [SELECT id, CreatedDate,Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            List<Id> POIds = new List<Id>();
            for(PurchaseOrder__c po: POs)
            {
                POIds.add(po.id);
            }
            List<PurchaseOrder_LineItem__c> POLineItems = [SELECT id, PurchaseOrder__r.CreatedDate,
                                                           Proof_Status__c,WO_Status__c,
                                                           PurchaseOrder__c FROM PurchaseOrder_LineItem__c 
                                                           WHERE PurchaseOrder__c IN: POIds];
            
            List<OpportunityLineItem__c> opportunityLineItems = [SELECT Id, Name, Opportunity__c,PurchaseOrder_LineItem__c
                                                                 FROM OpportunityLineItem__c
                                                                 WHERE PurchaseOrder_LineItem__c =:POLineItems];
            Map<Id, String> namesMap = new Map<Id, String>();
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {
                for(OpportunityLineItem__c lineItem: opportunityLineItems)
                {
                    if(lineItem.PurchaseOrder_LineItem__c == items.id)
                    {
                        namesMap.put(items.id,lineItem.Name);
                    }
                }
            }
            OpportunityViewPortalModelClass poDetails = new OpportunityViewPortalModelClass();
            Integer count = 1;
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {                    
                if((items.Proof_Status__c != 'Client Approved' && items.Proof_Status__c != 'Proofing Complete') && (items.WO_Status__c !='Shipped' && items.WO_Status__c !='Billed'))
                {
                    poDetails.proofRequiredNames.add(count + '- ' + namesMap.get(items.id));
                    poDetails.proofRequiredDate = items.PurchaseOrder__r.CreatedDate.format('yyyy-MM-dd');
                    count++;
                }
            }
            if(poDetails.proofRequiredNames.size()>0)
            {
                PurchaseOrdersList.add(poDetails);  
            }
            
        }
        return PurchaseOrdersList;
    }
    */
  /*  public List<OpportunityViewPortalModelClass> getInProductionOrderStatusDetails()
    {
        List<OpportunityViewPortalModelClass> PurchaseOrdersList = new List<OpportunityViewPortalModelClass>();
        List<String> shippedRecords = new List<String>();
        List<PurchaseOrder__c> POs = [SELECT id, CreatedDate,Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            List<Id> POIds = new List<Id>();
            for(PurchaseOrder__c po: POs)
            {
                POIds.add(po.id);
            }
            List<PurchaseOrder_LineItem__c> POLineItems = [SELECT id, PurchaseOrder__r.CreatedDate,
                                                           Proof_Status__c,WO_Status__c,
                                                           PurchaseOrder__c FROM PurchaseOrder_LineItem__c 
                                                           WHERE PurchaseOrder__c IN: POIds];
            
            List<OpportunityLineItem__c> opportunityLineItems = [SELECT Id, Name, Opportunity__c,PurchaseOrder_LineItem__c
                                                                 FROM OpportunityLineItem__c
                                                                 WHERE PurchaseOrder_LineItem__c =:POLineItems];
            Map<Id, String> namesMap = new Map<Id, String>();
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {
                for(OpportunityLineItem__c lineItem: opportunityLineItems)
                {
                    if(lineItem.PurchaseOrder_LineItem__c == items.id)
                    {
                        namesMap.put(items.id,lineItem.Name);
                    }
                }
            }
            OpportunityViewPortalModelClass poDetails = new OpportunityViewPortalModelClass();
            Integer count = 1;
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {                    
                if((items.Proof_Status__c == 'No Proof Required' || items.Proof_Status__c == 'Client Approved' || items.Proof_Status__c == 'Proofing Complete') && (items.WO_Status__c !='Shipped' && items.WO_Status__c !='Billed'))
                {
                    poDetails.InProductionNames.add(count + '- ' + namesMap.get(items.id));
                    poDetails.InProductionDate = items.PurchaseOrder__r.CreatedDate.format('yyyy-MM-dd');
                    count++;
                }
            }
            if(poDetails.InProductionNames!= null && poDetails.InProductionNames.size()>0)
            {
                PurchaseOrdersList.add(poDetails);  
            }
            
        }
        return PurchaseOrdersList;
    }
    
    public List<OpportunityViewPortalModelClass> getShippedOrderStatusDetails()
    {
        List<OpportunityViewPortalModelClass> PurchaseOrdersList = new List<OpportunityViewPortalModelClass>();
        List<String> shippedRecords = new List<String>();
        List<PurchaseOrder__c> POs = [SELECT id, CreatedDate,Opportunity__c FROM PurchaseOrder__c WHERE Opportunity__c =: opp.id];
        if(POs.size()>0)
        {
            List<Id> POIds = new List<Id>();
            for(PurchaseOrder__c po: POs)
            {
                POIds.add(po.id);
            }
            List<PurchaseOrder_LineItem__c> POLineItems = [SELECT id, PurchaseOrder__r.CreatedDate,
                                                           Proof_Status__c,WO_Status__c,Shipped_Date__c,
                                                           PurchaseOrder__c FROM PurchaseOrder_LineItem__c 
                                                           WHERE PurchaseOrder__c IN: POIds];
            
            List<OpportunityLineItem__c> opportunityLineItems = [SELECT Id, Name, Opportunity__c,PurchaseOrder_LineItem__c
                                                                 FROM OpportunityLineItem__c
                                                                 WHERE PurchaseOrder_LineItem__c =:POLineItems];
            Map<Id, String> namesMap = new Map<Id, String>();
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {
                for(OpportunityLineItem__c lineItem: opportunityLineItems)
                {
                    if(lineItem.PurchaseOrder_LineItem__c == items.id)
                    {
                        namesMap.put(items.id,lineItem.Name);
                    }
                }
            }
            
            for(PurchaseOrder_LineItem__c items: POLineItems)
            {                    
                OpportunityViewPortalModelClass poDetails = new OpportunityViewPortalModelClass();
                if((items.WO_Status__c =='Shipped' || items.WO_Status__c =='Billed'))
                {
                    poDetails.shippedName = namesMap.get(items.id);
                    if(items.Shipped_Date__c !=null)
                    {
                        poDetails.shippedDate = items.Shipped_Date__c.format('yyyy-MM-dd');
                    }
                    poDetails.shippedTrackingID = 'Tracking ID: -'+'';
                    PurchaseOrdersList.add(poDetails);  
                }
            }
            
        }
        return PurchaseOrdersList;
    }*/
}
