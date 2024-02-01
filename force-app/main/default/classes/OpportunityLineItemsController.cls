public class OpportunityLineItemsController {
  @AuraEnabled
  public static Boolean checkEstimateExists(String recid) {
    try {
      List<Estimate__c> estimateList = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :recId
      ];
      return estimateList.size() != 0;
    } catch (Exception ex) {
      System.debug(
        'Error in  Estimate -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
      return null;
    }
  }

  @AuraEnabled
  public static List<EstimatePopupDetails> getRelatedOpportunityLineItems(
    Id recid,
    Integer numOfrec
  ) {
    List<OpportunityLineItem__c> relatedOpportunityLineItems = [
      SELECT
        Id,
        Name,
        Description__c,
        Product__c,
        Product__r.Name,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Opportunity__c = :recid AND Estimate__c = NULL
      ORDER BY Sorting_Date__c ASC
    ];

    //New Sorting Logic Start
    List<OpportunityLineItem__c> sortedtesOpportunityLineItems = new List<OpportunityLineItem__c>();

    for (Integer i = 0; i < relatedOpportunityLineItems.size(); i++) {
      sortedtesOpportunityLineItems.add(relatedOpportunityLineItems[i]);
      for (Integer j = relatedOpportunityLineItems.size() - 1; j > i; j--) {
        if (
          sortedtesOpportunityLineItems[
              sortedtesOpportunityLineItems.size() - 1
            ]
            .Product__r.Name == relatedOpportunityLineItems[j].Product__r.Name
        ) {
          sortedtesOpportunityLineItems.add(relatedOpportunityLineItems[j]);
          relatedOpportunityLineItems.remove(j);
        }
      }
    }

    //New Sorting Logic End

    //details of each opportunityLine item
    List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
    List<id> oppLineItemIds = new List<id>();

    List<OpportunityLineItem__c> sortedDetails = new List<OpportunityLineItem__c>();

    sortedDetails = sortedtesOpportunityLineItems;

    for (OpportunityLineItem__c oppLineItem : sortedDetails) {
      EstimatePopupDetails details = new EstimatePopupDetails();
      details.oppLineItemId = oppLineItem.Id;
      details.productId = oppLineItem.Product__r.Id;
      details.productName = oppLineItem.name;
      details.sku = oppLineItem.SKU__c;
      oppLineItemIds.add(oppLineItem.Id);
      if ((numOfrec == 6 && detailsToReturn.size() < numOfrec) || numOfrec != 6)
        detailsToReturn.add(details);
    }
    Map<id, List<PricingLineItem__c>> pricingMap = new Map<id, List<PricingLineItem__c>>();
    List<PricingLineItem__c> allPricings = [
      SELECT
        OpportunityLineItem__c,
        price_per_Unit__c,
        Show_To_Client__c,
        Net_Cost__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Id
      FROM PricingLineItem__c
      WHERE OpportunityLineItem__c = :oppLineItemIds
    ];

    for (id pricingId : oppLineItemIds) {
      Integer pricingCount = 0;
      List<PricingLineItem__c> priceList = new List<PricingLineItem__c>();
      for (PricingLineItem__c prices : allPricings) {
        if (pricingId == prices.OpportunityLineItem__c && pricingCount < 5) {
          priceList.add(prices);
          pricingCount++;
        }
      }
      pricingMap.put(pricingId, priceList);
    }

    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges = [
      SELECT
        Id,
        Title__c,
        Is_Associated_With_Artwork_c__c,
        Counter__c,
        Cost__c,
        Margin__c,
        Retail_Price__c,
        CreatedDate,
        OpportunityLineItem_ArtWork__r.Title__c,
        OpportunityLineItem_ArtWork__r.Id,
        OpportunityLineItem_ArtWork__r.Counter__c,
        OpportunityLineItem__c
      FROM OpportunityLineItem_Add_Fixed_Charge__c
      WHERE OpportunityLineItem__c = :oppLineItemIds
      ORDER BY CreatedDate ASC
    ];

    Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>> fixedChargesMap = new Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>>();
    for (Id opplineItemId : oppLineItemIds) {
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixchargesList = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
      for (OpportunityLineItem_Add_Fixed_Charge__c fixCharge : fixedCharges) {
        if (fixCharge.OpportunityLineItem__c == opplineItemId) {
          fixchargesList.add(fixCharge);
        }
      }
      fixedChargesMap.put(opplineItemId, fixchargesList);
    }

    List<Line_Item_Pricing_RunCharge__c> runcharges = [
      SELECT
        Id,
        Name,
        Counter__c,
        Estimate__c,
        EstimatedQuantity__c,
        CreatedDate,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem_ArtWork__r.Title__c,
        OpportunityLineItem_ArtWork__r.Id,
        OpportunityLineItem_ArtWork__r.Counter__c,
        OpportunityLineItem__c,
        Title__c,
        Value1__c,
        Value2__c,
        Value3__c,
        Value_1_show__c,
        Value_2_show__c,
        Value_3_show__c,
        Value_4_show__c,
        Value_5_show__c,
        Value4__c,
        Value5__c
      FROM Line_Item_Pricing_RunCharge__c
      WHERE opportunityLineItem__c = :oppLineItemIds
      ORDER BY CreatedDate ASC
    ];

    Map<Id, List<Line_Item_Pricing_RunCharge__c>> runChargesMap = new Map<Id, List<Line_Item_Pricing_RunCharge__c>>();

    for (Id opplineItemId : oppLineItemIds) {
      List<Line_Item_Pricing_RunCharge__c> runChargesList = new List<Line_Item_Pricing_RunCharge__c>();
      for (Line_Item_Pricing_RunCharge__c runCharge : runcharges) {
        if (runCharge.OpportunityLineItem__c == opplineItemId) {
          runChargesList.add(runCharge);
        }
      }
      runChargesMap.put(opplineItemId, runChargesList);
    }

    Map<Id, String> artworkIds = new Map<Id, String>();
    for (EstimatePopupDetails details : detailsToReturn) {
      details.pricingDetails = pricingMap.get(details.oppLineItemId);
      for (PricingLineItem__c price : details.pricingDetails) {
        if (price.Quantity__c != null) {
          price.Quantity__c = price.Quantity__c.setScale(2);
        }
        if (price.Total__c != null) {
          price.Total__c = price.Total__c.setScale(2);
        }
        if (price.Margin__c != null) {
          price.Margin__c = price.Margin__c.setScale(0);
        }
      }
      details.fixedCharges = fixedChargesMap.get(details.oppLineItemId);
      for (
        OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : details.fixedCharges
      ) {
        fixedCharge.Margin__c = fixedCharge.Margin__c.setScale(0);
        fixedCharge.Retail_Price__c = fixedCharge.Retail_Price__c.setScale(2);
        if (fixedCharge.Is_Associated_With_Artwork_c__c) {
          artworkIds.put(
            fixedCharge.OpportunityLineItem_ArtWork__r.id,
            fixedCharge.OpportunityLineItem_ArtWork__r.Title__c
          );
        } else {
          details.fixChargesWithoutArtWork.add(fixedCharge);
        }
      }
      details.runCharges = runChargesMap.get(details.oppLineItemId);
      for (Id artworkId : artworkIds.keySet()) {
        ExtraChargesArtWorkDetails chargesWithArtworks = new ExtraChargesArtWorkDetails();
        for (
          OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : details.fixedCharges
        ) {
          if (
            fixedCharge.Is_Associated_With_Artwork_c__c &&
            fixedCharge.OpportunityLineItem_ArtWork__r.id == artworkId
          ) {
            chargesWithArtworks.fixedCharges.add(fixedCharge);
            //details.extraChargesWithArtWork.fixedCharges.add(fixedCharge);
          }
        }
        if (chargesWithArtworks.fixedCharges.size() > 0) {
          chargesWithArtworks.artworkName = artworkIds.get(artworkId);
          details.extraChargesWithArtWork.add(chargesWithArtworks);
        }
      }
    }

    return detailsToReturn;
  }

  @AuraEnabled
  public static Integer getCountOfOpportunityLineItems(Id recid) {
    return [
        SELECT Id
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :recid AND Estimate__c = NULL
      ]
      .size();
  }

  @AuraEnabled
  public static boolean deleteOpportunityLineItemInDb(String recid) {
    try {
      OpportunityLineItem__c opportunityLine = [
        SELECT Id, Name
        FROM OpportunityLineItem__c
        WHERE Id = :recid
      ];
      delete opportunityLine;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return false;
    }
  }

  @AuraEnabled
  public static String getPresentationPreviewLink(String recId) {
    try {
      List<OpportunityLineItem__c> opportunityLine = [
        SELECT Id, Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :recId
      ];
      if (opportunityLine.size() > 0) {
        return URL.getSalesforceBaseUrl().toExternalForm() +
          '/apex/PresentationPreview?id=' +
          recId;
      } else {
        return 'false';
      }
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return 'false';
    }
  }

  @AuraEnabled
  public static String getOpportunityStage(String recId) {
    try {
      Opportunity opp = [
        SELECT Id, stageName
        FROM Opportunity
        WHERE Id = :recid
      ];
      return opp.stageName;
    } catch (Exception ex) {
      System.debug('Error in getting stage ---->>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static Boolean cloneOpportunityLineItemInDB(Id recId) {
    try {
      List<OpportunityLineItem__c> lineItem = [
        SELECT
          Id,
          Name,
          Additional_Locations__c,
          Account__c,
          Additional_Colors__c,
          Opportunity__c,
          Description__c,
          Estimate__c,
          IsProductExists__c,
          Variant_Id__c,
          Product__r.CommonSku_Id__c,
          Supplier__c,
          ESPId__c,
          Imprint_Methods__c,
          Currency__c,
          Private_Notes__c,
          Price_Label__c,
          Imprint_Information__c,
          SKU__c,
          Product__c,
          isProductFromESP__c,
          Quantity_Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id = :recId
      ];
      List<PricingLineItem__c> PricingRecords = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Total__c,
          Margin__c,
          Show_To_Client__c,
          Estimate__c,
          Price_Per_Unit__c
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      OpportunityLineItem__c newOpp = new OpportunityLineItem__c();
      newOpp = lineItem[0].clone();
      insert newOpp;

      // Copy pricings
      List<PricingLineItem__c> lst_PricingLineItem = new List<PricingLineItem__c>();
      for (PricingLineItem__c obj : PricingRecords) {
        PricingLineItem__c tmp = obj.Clone();
        tmp.OpportunityLineItem__c = newOpp.id;
        lst_PricingLineItem.add(tmp);
      }
      insert lst_PricingLineItem;

      // Copy colors
      List<ColorLineItem__c> lst_Color_Product = [
        SELECT Id, Color__c, OpportunityLineItem__c, isSelected__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<ColorLineItem__c> lstColorsLineItem = new List<ColorLineItem__c>();
      for (ColorLineItem__c colorObj : lst_Color_Product) {
        ColorLineItem__c colorsLineItem = colorObj.Clone();
        colorsLineItem.OpportunityLineItem__c = newOpp.id;
        lstColorsLineItem.add(colorsLineItem);
      }
      insert lstColorsLineItem;

      // Copy Sizes
      List<SizeLineItem__c> lst_Size_Product = [
        SELECT Id, Size__c, OpportunityLineItem__c, isSelected__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<SizeLineItem__c> lstSizesLineItem = new List<SizeLineItem__c>();
      for (SizeLineItem__c sizeObj : lst_Size_Product) {
        SizeLineItem__c sizeLineItem = sizeObj.Clone();
        sizeLineItem.OpportunityLineItem__c = newOpp.id;
        lstSizesLineItem.add(sizeLineItem);
      }
      insert lstSizesLineItem;

      // Copy Comments
      List<Comment__c> comments = [
        SELECT
          OpportunityLineItem__c,
          Name,
          Date__c,
          Comment__c,
          Comment_Date__c,
          User__c
        FROM Comment__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<Comment__c> clonedComments = new List<Comment__c>();
      if (comments != null && comments.size() > 0) {
        for (Comment__c comment : comments) {
          Comment__c newComment = comment.clone();
          newComment.OpportunityLineItem__c = newOpp.id;
          clonedComments.add(newComment);
        }
      }
      insert clonedComments;
      // Copy Artworks
      List<OpportunityLineItem_ArtWork__c> opportunityLineItemArtworkList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c,
          Counter__c,
          Title__c,
          Estimate__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      List<OpportunityLineItem_ArtWork__c> clonedArtWorksList = new List<OpportunityLineItem_ArtWork__c>();
      if (
        opportunityLineItemArtworkList != null &&
        opportunityLineItemArtworkList.Size() > 0
      ) {
        for (
          OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
        ) {
          OpportunityLineItem_ArtWork__c clonedArtwork = artwork.clone();
          clonedArtwork.OpportunityLineItem__c = newOpp.id;
          clonedArtWorksList.add(clonedArtwork);
        }
      }
      insert clonedArtWorksList;

      //Artworks attachments  to be copied
      List<OpportunityLineItem_ArtWork__c> opportunityLineItemArtworkListCloned = [
        SELECT
          Id,
          OpportunityLineItem__c,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c,
          Counter__c,
          Title__c,
          Estimate__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :newOpp.Id
        ORDER BY CreatedDate DESC
      ];
      Map<Id, Id> oldArtworkId_newArtWork_Map = new Map<Id, Id>();
      Integer index = 0;
      for (
        OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkListCloned
      ) {
        oldArtworkId_newArtWork_Map.put(
          opportunityLineItemArtworkList.get(index).Id,
          artwork.Id
        );
        index++;
      }
      List<Id> artworkIds = new List<Id>();
      if (
        opportunityLineItemArtworkList != null &&
        opportunityLineItemArtworkList.Size() > 0
      ) {
        for (
          OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
        ) {
          artworkIds.add(artwork.Id);
        }
      }
      if (artworkIds != null && artworkIds.Size() > 0) {
        List<ContentDocumentLink> allAttachmentRelatedToArtworks = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :artworkIds
        ];
        List<ContentDocumentLink> clonedAttachmentList = new List<ContentDocumentLink>();
        if (
          allAttachmentRelatedToArtworks != null &&
          allAttachmentRelatedToArtworks.Size() > 0
        ) {
          for (
            ContentDocumentLink attachment : allAttachmentRelatedToArtworks
          ) {
            if (
              oldArtworkId_newArtWork_Map.get(attachment.LinkedEntityId) != null
            ) {
              ContentDocumentLink attach = new ContentDocumentLink();
              attach = attachment.Clone();
              attach.LinkedEntityId = oldArtworkId_newArtWork_Map.get(
                attachment.LinkedEntityId
              );
              attach.ShareType = 'V';
              clonedAttachmentList.add(attach);
            }
          }
        }
        insert clonedAttachmentList;
      }
      ///// // Copy Artworks Fixed and Run Charges
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfArtworks = [
        SELECT
          Title__c,
          Retail_Price__c,
          Cost__c,
          Margin__c,
          OpportunityLineItem__c,
          Is_Associated_With_Artwork_c__c,
          OpportunityLineItem_ArtWork__c,
          Counter__c,
          Estimate__c,
          Id
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE
          Is_Associated_With_Artwork_c__c = TRUE
          AND OpportunityLineItem_ArtWork__c = :opportunityLineItemArtworkList
      ];
      List<Line_Item_Pricing_RunCharge__c> runChargesOfArtworks = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Title__c,
          Is_Associated_With_Artwork__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          Counter__c,
          OpportunityLineItem_ArtWork__c,
          Estimate__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem_ArtWork__c = :opportunityLineItemArtworkList
      ];
      Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>> artworkAndFixedChargesMap = new Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>>();
      Map<Id, List<Line_Item_Pricing_RunCharge__c>> artworkAndRunChargesMap = new Map<Id, List<Line_Item_Pricing_RunCharge__c>>();
      List<Line_Item_Pricing_RunCharge__c> clonedRunChargesList = new List<Line_Item_Pricing_RunCharge__c>();
      List<OpportunityLineItem_Add_Fixed_Charge__c> clonedFixedChargesList = new List<OpportunityLineItem_Add_Fixed_Charge__c>();

      if (opportunityLineItemArtworkList.Size() > 0) {
        if (fixedChargesOfArtworks.Size() > 0) {
          for (
            OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
          ) {
            List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesRelatedToArtwork = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
            for (
              OpportunityLineItem_Add_Fixed_Charge__c fixCharges : fixedChargesOfArtworks
            ) {
              if (fixCharges.OpportunityLineItem_ArtWork__c == artwork.Id) {
                fixedChargesRelatedToArtwork.add(fixCharges);
              }
            }
            artworkAndFixedChargesMap.put(
              artwork.Id,
              fixedChargesRelatedToArtwork
            );
          }
        }

        if (runChargesOfArtworks.Size() > 0) {
          for (
            OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
          ) {
            List<Line_Item_Pricing_RunCharge__c> runChargesRelatedToArtwork = new List<Line_Item_Pricing_RunCharge__c>();
            for (
              Line_Item_Pricing_RunCharge__c runCharge : runChargesOfArtworks
            ) {
              if (runCharge.OpportunityLineItem_ArtWork__c == artwork.Id) {
                runChargesRelatedToArtwork.add(runCharge);
              }
            }
            artworkAndRunChargesMap.put(artwork.Id, runChargesRelatedToArtwork);
          }
        }

        for (
          OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
        ) {
          List<Line_Item_Pricing_RunCharge__c> runChargesToBeCloned = new List<Line_Item_Pricing_RunCharge__c>();
          runChargesToBeCloned = artworkAndRunChargesMap.get(artwork.Id);
          if (runChargesToBeCloned != null && runChargesToBeCloned.Size() > 0) {
            for (
              Line_Item_Pricing_RunCharge__c runCharge : runChargesToBeCloned
            ) {
              if (
                runCharge.OpportunityLineItem__c ==
                artwork.OpportunityLineItem__c
              ) {
                Line_Item_Pricing_RunCharge__c clonedRunCharge = runCharge.clone();
                clonedRunCharge.OpportunityLineItem__c = newOpp.Id;
                clonedRunCharge.OpportunityLineItem_ArtWork__c = oldArtworkId_newArtWork_Map.get(
                  artwork.Id
                );
                clonedRunChargesList.Add(clonedRunCharge);
              }
            }
          }

          List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesToBeCloned = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
          fixedChargesToBeCloned = artworkAndFixedChargesMap.get(artwork.Id);

          if (
            fixedChargesToBeCloned != null &&
            fixedChargesToBeCloned.Size() > 0
          ) {
            for (
              OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : fixedChargesToBeCloned
            ) {
              if (
                fixedCharge.OpportunityLineItem__c ==
                artwork.OpportunityLineItem__c
              ) {
                OpportunityLineItem_Add_Fixed_Charge__c clonedFixedCharge = fixedCharge.clone();
                clonedFixedCharge.OpportunityLineItem__c = newOpp.Id;
                clonedFixedCharge.OpportunityLineItem_ArtWork__c = oldArtworkId_newArtWork_Map.get(
                  artwork.Id
                );
                clonedFixedChargesList.add(clonedFixedCharge);
              }
            }
          }
        }
        if (clonedRunChargesList != null && clonedRunChargesList.size() > 0)
          insert clonedRunChargesList;
        if (clonedFixedChargesList != null && clonedFixedChargesList.size() > 0)
          insert clonedFixedChargesList;
      }

      /// Copy fixed and run charges
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfOppLineItem = [
        SELECT
          Title__c,
          Retail_Price__c,
          Cost__c,
          Margin__c,
          OpportunityLineItem__c,
          Is_Associated_With_Artwork_c__c,
          OpportunityLineItem_ArtWork__c,
          Counter__c,
          Estimate__c,
          Id
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE
          Is_Associated_With_Artwork_c__c = FALSE
          AND OpportunityLineItem__c = :recId
      ];
      List<Line_Item_Pricing_RunCharge__c> runChargesOfOppLineItem = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Title__c,
          Is_Associated_With_Artwork__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          Counter__c,
          OpportunityLineItem_ArtWork__c,
          Estimate__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE
          Is_Associated_With_Artwork__c = FALSE
          AND OpportunityLineItem__c = :recId
      ];
      List<OpportunityLineItem_Add_Fixed_Charge__c> clonedFixedChargesListNew = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
      if (
        fixedChargesOfOppLineItem != null &&
        fixedChargesOfOppLineItem.Size() > 0
      ) {
        for (
          OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : fixedChargesOfOppLineItem
        ) {
          OpportunityLineItem_Add_Fixed_Charge__c clonedFixedCharge = fixedCharge.clone();
          clonedFixedCharge.OpportunityLineItem__c = newOpp.Id;
          clonedFixedChargesListNew.add(clonedFixedCharge);
        }
      }
      insert clonedFixedChargesListNew;
      List<Line_Item_Pricing_RunCharge__c> clonedRunChargesListNew = new List<Line_Item_Pricing_RunCharge__c>();
      if (
        runChargesOfOppLineItem != null &&
        runChargesOfOppLineItem.Size() > 0
      ) {
        for (
          Line_Item_Pricing_RunCharge__c runCharge : runChargesOfOppLineItem
        ) {
          Line_Item_Pricing_RunCharge__c clonedRunCharge = runCharge.clone();
          clonedRunCharge.OpportunityLineItem__c = newOpp.Id;
          clonedRunChargesListNew.Add(clonedRunCharge);
        }
      }
      insert clonedRunChargesListNew;

      //copy all the attachments  of opportunity Line Items
      List<OpportunityLineItemAttachment__c> listOfAttachmentRecords = [
        SELECT Id, Name, Estimate__c, OpportunityLineItem__c
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate DESC
      ];

      List<Id> attachmentIdsOlds = new List<Id>();

      List<OpportunityLineItemAttachment__c> newClonedAttachments = new List<OpportunityLineItemAttachment__c>();
      Map<Id, OpportunityLineItemAttachment__c> oldAttachment_newAttachment_map = new Map<Id, OpportunityLineItemAttachment__c>();

      for (
        OpportunityLineItemAttachment__c attachment : listOfAttachmentRecords
      ) {
        OpportunityLineItemAttachment__c clonedAttachment = attachment.Clone();
        clonedAttachment.OpportunityLineItem__c = newOpp.Id;
        newClonedAttachments.add(clonedAttachment);
        oldAttachment_newAttachment_map.put(attachment.Id, clonedAttachment);
        attachmentIdsOlds.add(attachment.Id);
      }
      insert newClonedAttachments;
      Map<Id, List<ContentDocumentLink>> oldAttachmentRecordId_images_map = new Map<Id, List<ContentDocumentLink>>();
      List<ContentDocumentLink> imagesToBeInserted = new List<ContentDocumentLink>();
      List<ContentDocumentLink> allDocumentIds = new List<ContentDocumentLink>();
      if (attachmentIdsOlds != null && attachmentIdsOlds.Size() > 0) {
        allDocumentIds = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :attachmentIdsOlds
          ORDER BY ContentDocument.CreatedDate DESC
        ];
      }
      for (
        OpportunityLineItemAttachment__c attachment : listOfAttachmentRecords
      ) {
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        for (ContentDocumentLink document : allDocumentIds) {
          if (document.LinkedEntityId == attachment.Id) {
            contentDocumentList.add(document);
          }
        }
        oldAttachmentRecordId_images_map.put(
          attachment.Id,
          contentDocumentList
        );
      }
      if (allDocumentIds != null && allDocumentIds.Size() > 0) {
        for (ContentDocumentLink image : allDocumentIds) {
          ContentDocumentLink clonedImage = image.Clone();
          clonedImage.LinkedEntityId = oldAttachment_newAttachment_map.get(
              image.LinkedEntityId
            )
            .Id;
          clonedImage.ShareType = 'V';
          imagesToBeInserted.add(clonedImage);
        }
        insert imagesToBeInserted;
      }
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in cloning product--->' +
          ex.getMessage() +
          '--->' +
          ex.getStackTraceString()
      );
      return false;
    }
  }
}
