public class OpportunityLineItemExtension {
  public final Opportunity opp { get; set; }
  //public String recId {get; set;}
  Boolean restRequestNeeded = System.isFuture() || System.isScheduled(); // System.isBatch() too?
  public OpportunityLineItemExtension() {
    String oppId = ApexPages.currentPage().getParameters().get('id');
    this.opp = [
      SELECT Id, Name, Owner.Name, Owner.Email
      FROM Opportunity
      WHERE id = :oppId
    ];
  }

  public OpportunityLineItemExtension(
    ApexPages.StandardController stdController
  ) {
    this.opp = (Opportunity) stdController.getRecord();
  }

  public List<QuriedOpportunitiesLineItems> getLineItemsList() {
    List<QuriedOpportunitiesLineItems> LineItemsList = new List<QuriedOpportunitiesLineItems>();
    List<OpportunityLineItem__c> lineItemDetailsUnsorted = [
      SELECT
        Id,
        Name,
        Description__c,
        Product__r.id,
        Product__r.Name,
        CreatedDate,
        Sorting_Date__c,
        ContentDocument_ID__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :opp.id
      ORDER BY Sorting_Date__c ASC
    ];

    //Sorting Logic
    List<OpportunityLineItem__c> lineItemDetails = ProductsSorting.sortProducts(
      lineItemDetailsUnsorted
    );
    List<String> ids = new List<String>();
    List<Id> selectContentDocIds = new List<Id>();
    Map<Id, String> selectImageRelatedToOpp = new Map<Id, String>();

    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      ids.add(lineItems.id);
      if (lineItems.ContentDocument_ID__c != null) {
        selectContentDocIds.add(lineItems.ContentDocument_ID__c);
      }
    }
    List<ContentDistribution> CDList = [
      SELECT ContentDocumentId, ContentDownloadUrl
      FROM ContentDistribution
      WHERE ContentDocumentId IN :selectContentDocIds
    ];

    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      for (ContentDistribution cd : CDList) {
        if (lineItems.ContentDocument_ID__c == cd.ContentDocumentId) {
          selectImageRelatedToOpp.put(lineItems.Id, cd.ContentDownloadUrl);
        }
      }
    }

    List<ColorLineItem__c> colors;
    List<PricingLineItem__c> pricing;
    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges;
    List<Line_Item_Pricing_RunCharge__c> runcharges;
    List<SizeLineItem__c> sizes;
    List<Comment__c> comments;
    List<ContentDocumentLink> relatedImages = new List<ContentDocumentLink>();
    colors = [
      SELECT OpportunityLineItem__c, Color__c
      FROM ColorLineItem__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    pricing = [
      SELECT
        OpportunityLineItem__c,
        Quantity__c,
        Net_Cost__c,
        Price_Per_Unit__c,
        Retail_Price__c,
        Show_To_Client__c
      FROM PricingLineItem__c
      WHERE OpportunityLineItem__c IN :ids AND Show_To_Client__c = TRUE
    ];
    fixedCharges = [
      SELECT OpportunityLineItem__c, Name, Retail_Price__c, Title__c
      FROM OpportunityLineItem_Add_Fixed_Charge__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    runcharges = [
      SELECT
        Id,
        Name,
        OpportunityLineItem__c,
        Value_1_show__c,
        Value_2_show__c,
        Value_3_show__c,
        Value_4_show__c,
        Value_5_show__c,
        Title__c,
        Value1__c,
        Value2__c,
        Value3__c,
        Value4__c,
        Value5__c
      FROM Line_Item_Pricing_RunCharge__c
      WHERE opportunityLineItem__c IN :ids
    ];
    sizes = [
      SELECT OpportunityLineItem__c, Size__c
      FROM SizeLineItem__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    comments = [
      SELECT
        OpportunityLineItem__c,
        Name,
        Date__c,
        Comment__c,
        Comment_Date__c,
        User__c
      FROM Comment__c
      WHERE OpportunityLineItem__c IN :ids
      ORDER BY CreatedDate ASC
    ];
    List<OpportunityLineItemAttachment__c> attachements = [
      SELECT id, OpportunityLineItem__c
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    List<String> attachmentiIds = new List<String>();
    for (OpportunityLineItemAttachment__c attachment : attachements) {
      attachmentiIds.add(attachment.id);
    }
    Map<Id, List<String>> relatedImagesMap = new Map<Id, List<String>>();
    if (attachmentiIds.size() > 0) {
      relatedImages = [
        SELECT
          id,
          ContentDocument.CreatedDate,
          ContentDocument.LatestPublishedVersionID,
          LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :attachmentiIds
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
            List<String> imgLinks = new List<String>();
            imgLinks.add(contentDoc.ContentDownloadUrl);
            imgLinks.add(contentDoc.DistributionPublicUrl);
            relatedImagesMap.put(image.LinkedEntityId, imgLinks);
          }
        }
      }
    }

    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      QuriedOpportunitiesLineItems lItems = new QuriedOpportunitiesLineItems();
      lItems.id = lineItems.id;
      lItems.name = lineItems.Name;
      lItems.description = lineItems.Description__c;
      for (ColorLineItem__c colorsList : colors) {
        if (colorsList.OpportunityLineItem__c == lineItems.id) {
          lItems.lineItemColors.add(colorsList.Color__c + ', ');
        }
      }
      if (lItems.lineItemColors.size() > 0) {
        lItems.lineItemColors[
          lItems.lineItemColors.size() - 1
        ] = lItems.lineItemColors[lItems.lineItemColors.size() - 1]
          .replaceAll(',', '');
        lItems.lineItemColors[
          lItems.lineItemColors.size() - 1
        ] = lItems.lineItemColors[lItems.lineItemColors.size() - 1];
      }
      if (lItems.lineItemColors.size() > 0)
        lItems.colorSize = true;
      else
        lItems.colorSize = false;
      Integer pricingCount = 0;
      integer Count, minus;

      Set<Id> opportunityLineItemIds = new Set<Id>();
      for (PricingLineItem__c pricingList : pricing) {
        opportunityLineItemIds.add(pricingList.OpportunityLineItem__c);
      }

      Map<Id, Line_Item_Pricing_RunCharge__c> opportunityLineItemToRunChargeMap = new Map<Id, Line_Item_Pricing_RunCharge__c>();
      if (!opportunityLineItemIds.isEmpty()) {
        List<Line_Item_Pricing_RunCharge__c> runChargesList = [
          SELECT
            Id,
            Value_1_show__c,
            Value_2_show__c,
            Value_3_show__c,
            Value_4_show__c,
            Value_5_show__c,
            Title__c,
            opportunityLineItem__c
          FROM Line_Item_Pricing_RunCharge__c
          WHERE opportunityLineItem__c IN :opportunityLineItemIds
        ];

        for (Line_Item_Pricing_RunCharge__c runCharge : runChargesList) {
          opportunityLineItemToRunChargeMap.put(
            runCharge.opportunityLineItem__c,
            runCharge
          );
        }
      }

      // Continue processing using the collected data
      for (PricingLineItem__c pricingList : pricing) {
        count = 5;
        minus = 0;
        Line_Item_Pricing_RunCharge__c runCharge = opportunityLineItemToRunChargeMap.get(
          pricingList.OpportunityLineItem__c
        );
        if (runCharge != null) {
          if (!runCharge.Value_1_show__c) {
            minus++;
          }
          if (!runCharge.Value_2_show__c) {
            minus++;
          }
          if (!runCharge.Value_3_show__c) {
            minus++;
          }
          if (!runCharge.Value_4_show__c) {
            minus++;
          }
          if (!runCharge.Value_5_show__c) {
            minus++;
          }
        }

        count = count - minus;
        if (
          pricingList.OpportunityLineItem__c == lineItems.id &&
          pricingCount < count
        ) {
          lItems.lineItemPricing.add(pricingList);
          pricingCount++;
        }
      }

      if (lItems.lineItemPricing.size() > 0)
        lItems.pricingSize = true;
      else
        lItems.pricingSize = false;
      for (
        OpportunityLineItem_Add_Fixed_Charge__c fixedChargesList : fixedCharges
      ) {
        if (fixedChargesList.OpportunityLineItem__c == lineItems.id) {
          lItems.lineItemFixedCharges.add(fixedChargesList);
        }
      }

      if (lItems.lineItemFixedCharges.size() > 0)
        lItems.fixedChargesSize = true;
      else
        lItems.fixedChargesSize = false;

      for (Line_Item_Pricing_RunCharge__c runcharge : runcharges) {
        if (runcharge.OpportunityLineItem__c == lineItems.id) {
          lItems.lineItemRunCharges.add(runcharge);
        }
      }
      if (lItems.lineItemRunCharges.size() > 0)
        lItems.runChargesSize = true;
      else
        lItems.runChargesSize = false;
      for (SizeLineItem__c sizesList : sizes) {
        if (sizesList.OpportunityLineItem__c == lineItems.id) {
          lItems.lineItemSizes.add(sizesList.Size__c + ', ');
        }
      }
      if (lItems.lineItemSizes.size() > 0) {
        lItems.lineItemSizes[
          lItems.lineItemSizes.size() - 1
        ] = lItems.lineItemSizes[lItems.lineItemSizes.size() - 1]
          .replaceAll(',', '');
        lItems.lineItemSizes[
          lItems.lineItemSizes.size() - 1
        ] = lItems.lineItemSizes[lItems.lineItemSizes.size() - 1];
      }
      if (lItems.lineItemSizes.size() > 0)
        lItems.sizesSize = true;
      else
        lItems.sizesSize = false;
      for (Comment__c commentList : comments) {
        if (commentList.OpportunityLineItem__c == lineItems.id) {
          lItems.lineItemComments.add(commentList);
        }
      }
      Integer imgCount = 0;
      List<String> activeImagelink = new List<String>();
      for (ContentDocumentLink imagesList : relatedImages) {
        for (OpportunityLineItemAttachment__c attachment : attachements) {
          if (
            lineItems.id == attachment.OpportunityLineItem__c &&
            imagesList.LinkedEntityId == attachment.id &&
            imgCount < 5
          ) {
            if (relatedImagesMap != null && relatedImagesMap.size() > 0) {
              activeImagelink.add(
                relatedImagesMap.get(imagesList.LinkedEntityId)[0]
              );
              Images img = new Images();
              img.imageDownloadLink = relatedImagesMap.get(
                imagesList.LinkedEntityId
              )[0];
              img.imagePreviewLink = relatedImagesMap.get(
                imagesList.LinkedEntityId
              )[1];
              lItems.filesDownloadURL.add(img);
              imgCount++;
              break;
            }
          }
        }
      }
      if (lItems.filesDownloadURL.size() > 0) {
        if (lineItems.ContentDocument_ID__c != null) {
          for (Id oppId : selectImageRelatedToOpp.keySet()) {
            lItems.activeImage = selectImageRelatedToOpp.get(lItems.Id);
            break;
          }
        } else {
          lItems.activeImage = lItems.filesDownloadURL[0].imageDownloadLink;
        }
        lItems.activeImagePreviewLink = lItems.filesDownloadURL[0]
          .imagePreviewLink;
        lItems.imageExits = true;
      } else {
        lItems.imageExits = false;
      }
      LineItemsList.add(lItems);
    }
    return lineItemsList;
  }

  public String getOppLink() {
    return URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/r/Opportunity/' +
      opp.id +
      '/view';
  }

  public Opportunity getOpportunity() {
    return opp;
  }

  public void addComment() {
    System.debug(
      'Record ID: ' + Apexpages.currentPage().getParameters().get('recId')
    );
    try {
      Comment__c comm = new Comment__c();
      //comm.Comment_Date__c = System.now();
      comm.Date__c = System.now().format('MM-dd-yyyy');
      comm.Comment__c = Apexpages.currentPage()
        .getParameters()
        .get('comment' + Apexpages.currentPage().getParameters().get('recId'));
      comm.User__c = Apexpages.currentPage()
        .getParameters()
        .get('username' + Apexpages.currentPage().getParameters().get('recId'));
      comm.OpportunityLineItem__c = Apexpages.currentPage()
        .getParameters()
        .get('recId');
      insert comm;

      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = 'Comment';
      activity.RelatedObjectId__c = comm.OpportunityLineItem__c;
      activity.Comment__c = comm.id;
      activity.Opportunity__c = opp.id;
      insert activity;
    } catch (Exception ex) {
      System.debug('ERROR While adding comment in LineItem' + ex.getMessage());
    }
  }
}
