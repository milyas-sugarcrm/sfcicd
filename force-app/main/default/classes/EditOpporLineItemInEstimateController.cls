public with sharing class EditOpporLineItemInEstimateController {
  @AuraEnabled
  public static void syncRecord(String recId) {
    List<Id> OppIds = new List<Id>();
    List<Estimate__c> lstEstimate = [
      SELECT Id, Opportunity__c, QB_Update__c
      FROM Estimate__c
      WHERE Opportunity__c = :recId
    ];
    for (Estimate__c est : lstEstimate) {
      est.QB_Update__c = true;
      OppIds.add(est.Opportunity__c);
    }
    List<Opportunity> lstOpp = [
      SELECT id
      FROM Opportunity
      WHERE id = :OppIds
    ];
    if (lstOpp.size() > 0 && lstEstimate.size() > 0) {
      update lstEstimate;
      update lstOpp;
    }
  }

  public static void estimateUpdated(Estimate__c estimateObj) {
    estimateObj.Data_Changed__c = true;
  }

  @AuraEnabled
  public static void updateTotalOfRecords(String recId) {
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Margin__c,
        Retail_Price__c,
        Charge_Type__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :recId
    ];
    List<PricingLineItem__c> pricingDetails = [
      SELECT
        Id,
        Quantity__c,
        Color__c,
        Size__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        Show_To_Client__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c,
        Default__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c = :recId
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    for (PricingLineItem__c pricing : pricingDetails) {
      pricing.Total__c =
        ((pricing.Estimated_Quantity__c == null)
          ? 0
          : pricing.Estimated_Quantity__c) *
        ((pricing.Retail_Price__c == null) ? 0 : pricing.Retail_Price__c);
      pricing.Total__c = pricing.Total__c.setScale(2);
    }
    update pricingDetails;
    for (ExtraChargesEstimate__c extraCharge : extraCharges) {
      extraCharge.Total__c =
        ((extraCharge.Quantity__c == null) ? 0 : extraCharge.Quantity__c) *
        ((extraCharge.Retail_Price__c == null)
          ? 0
          : extraCharge.Retail_Price__c);
      extraCharge.Total__c = extraCharge.Total__c.setScale(2);
    }
    update extraCharges;
  }
  @AuraEnabled
  public static OpportunityLineItemDetails getOpportunityLineItemDetails(
    String recId
  ) {
    OpportunityLineItemDetails details = new OpportunityLineItemDetails();
    try {
      updateTotalOfRecords(recId);
      OpportunityLineItem__c opportunitLineItemData = [
        SELECT
          Supplier__c,
          Tax__c,
          Total__c,
          Price_Label__c,
          Private_Notes__c,
          SortOrder__c,
          SKU__c,
          Opportunity__c,
          Product__c,
          Imprint_Methods__c,
          Product__r.CommonSku_Id__c,
          Imprint_Information__c,
          Description__c,
          Estimate__r.Default_Tax__c,
          Name,
          Quantity_Estimate__c,
          Id,
          Additional_Colors__c,
          Additional_Locations__c
        FROM OpportunityLineItem__c
        WHERE Id = :recId
      ];
      List<OpportunityLineItemAttachment__c> attachment = [
        SELECT OpportunityLineItem__c, Id
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<ContentDocumentLink> documents = new List<ContentDocumentLink>();
      if (attachment != null && attachment.Size() > 0) {
        integer index = 0;
        documents = [
          SELECT Id, LinkedEntityId, ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId = :attachment[index].Id
        ];
      }

      //fetching content version ids of content document id
      Map<Id, Id> mapContentLink_ContentVersion = new Map<id, id>();

      List<Id> lstContentDocumentIds = new List<Id>();
      for (ContentDocumentLink document : documents) {
        lstContentDocumentIds.add(document.ContentDocumentId);
      }

      List<ContentVersion> imageFiles = [
        SELECT id, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
      ];

      for (ContentVersion contentVersion : imageFiles) {
        details.ImageContentVersionIds.add(contentVersion.Id);
      }
      if (details.ImageContentVersionIds.size() == 0) {
        details.productImageExist = false;
      } else {
        details.productImageExist = true;
      }
      if (opportunitLineItemData.Product__r.CommonSku_Id__c != null) {
        details.ESPProductId = opportunitLineItemData.Product__r.CommonSku_Id__c;
      }
      system.debug('imprinting info is : ');
      system.debug(opportunitLineItemData.Imprint_Information__c);
      details.supplier = opportunitLineItemData.Supplier__c;
      details.ProductID = opportunitLineItemData.Product__c;
      details.tax = opportunitLineItemData.Tax__c;
      details.description = opportunitLineItemData.Description__c;
      details.imprintMethods = opportunitLineItemData.Imprint_Methods__c;
      details.imprintingInfo = opportunitLineItemData.Imprint_Information__c;
      details.priceLabel = opportunitLineItemData.Price_Label__c;
      details.privateNotes = opportunitLineItemData.Private_Notes__c;
      details.name = opportunitLineItemData.Name;
      details.sku = opportunitLineItemData.SKU__c;
      details.additionalColors = opportunitLineItemData.Additional_Colors__c;
      details.additionalLocations = opportunitLineItemData.Additional_Locations__c;
      details.EstimatedQuantity = opportunitLineItemData.Quantity_Estimate__c;

      details.comments = [
        SELECT
          Comment_Date__c,
          User__c,
          Comment__c,
          OpportunityLineItem__c,
          Id,
          CreatedDate
        FROM Comment__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      details.pricingDetails = [
        SELECT
          Id,
          Quantity__c,
          Color__c,
          Size__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      for (PricingLineItem__c pricing : details.pricingDetails) {
        if (pricing.Size__c == null) {
          pricing.Size__c = 'TBD';
        }
        if (pricing.Color__c == null) {
          pricing.Color__c = 'TBD';
        }
        pricing.Size__c = pricing.Size__c + '/' + pricing.Color__c;
      }
      details.fixedCharges = [
        SELECT
          Id,
          Title__c,
          Is_Associated_With_Artwork_c__c,
          Counter__c,
          Cost__c,
          Margin__c,
          Retail_Price__c,
          CreatedDate,
          OpportunityLineItem_ArtWork__r.Counter__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      details.runCharges = [
        SELECT
          Id,
          Title__c,
          Is_Associated_With_Artwork__c,
          Counter__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          CreatedDate,
          OpportunityLineItem_ArtWork__r.Counter__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      details.warnings = [
        SELECT Id, Warning__c, CreatedDate
        FROM WarningsOpportunityLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      details.artworks = [
        SELECT Id, Title__c, OpportunityLineItem__c, CreatedDate
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate DESC
      ];
      details.extraCharges = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = FALSE
          AND OpportunityLineItem__c = :recId
          AND Is_Associated_With_Artwork__c = FALSE
          AND Charge_Type__c != 'InternationalCost_InboundFreight'
          AND Charge_Type__c != 'InternationalCost_Brokerage'
          AND Charge_Type__c != 'InternationalCost_Duty'
        ORDER BY CreatedDate ASC
      ];
      details.internationalCosts = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Charge_Type__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Is_Associated_With_Artwork__c = FALSE
          AND Charge_Type__c != 'AdditionalCost_RunCharge'
          AND Charge_Type__c != 'AdditionalCost_FixedCharge'
        ORDER BY CreatedDate ASC
      ];
      details.internationalCostExists = details.internationalCosts.size() > 0;
      details.extraChargesExists = details.extraCharges.size() > 0;
      details.pricingDetailsExists = details.pricingDetails.size() > 0;

      List<OpportunityLineItem_ArtWork__c> artworks = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Imprint_Type__c,
          logo_Name__c,
          Proof_Required__c,
          Logo_Size__c,
          Repeat_Logo__c,
          Logo_Color__c,
          Supplier_Notes__c,
          Document_ID__c,
          Title__c,
          Estimate__c,
          Counter__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :recId
      ];

      List<ExtraChargesEstimate__c> extraChargesOfArtwork = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          OpportunityLineItem_ArtWork__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem__c = :recId
      ];

      List<Id> artworkIds = new List<Id>();
      List<ContentDocumentLink> artworkRelatedImages = new List<ContentDocumentLink>();
      Map<Id, Id> contentLinkContentVersionMap = new Map<Id, Id>();
      Map<Id, String> artworkFileTypes = new Map<Id, String>();
      List<Id> contentDocumentList = new List<Id>();
      Map<Id, Id> artworkContentDocumentMap = new Map<Id, Id>();

      for (OpportunityLineItem_ArtWork__c art : artworks) {
        artworkIds.add(art.Id);
      }
      if (artworkIds != null && artworkIds.size() > 0) {
        artworkRelatedImages = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :artworkIds
        ];

        for (ContentDocumentLink obj : artworkRelatedImages) {
          artworkContentDocumentMap.put(
            obj.LinkedEntityId,
            obj.ContentDocumentId
          );
          contentDocumentList.add(obj.ContentDocumentId);
        }
        List<ContentVersion> artworkRelatedImageFiles = [
          SELECT id, FileType, ContentDocumentId
          FROM ContentVersion
          WHERE ContentDocumentId IN :contentDocumentList AND FileType != 'PDF'
        ];
        for (ContentVersion contentVersion : artworkRelatedImageFiles) {
          contentLinkContentVersionMap.put(
            contentVersion.ContentDocumentId,
            contentVersion.id
          );
          artworkFileTypes.put(
            contentVersion.ContentDocumentId,
            contentVersion.FileType
          );
        }
      }
      if (
        extraChargesOfArtwork != null &&
        extraChargesOfArtwork.size() > 0 &&
        artworks != null &&
        artworks.size() > 0
      ) {
        for (OpportunityLineItem_ArtWork__c art : artworks) {
          ArtworkDetailsObject artDetailsObject = new ArtworkDetailsObject();
          artDetailsObject.artwork = art;
          artDetailsObject.contentVersionId = contentLinkContentVersionMap.get(
            artworkContentDocumentMap.get(art.Id)
          );

          if (
            artworkFileTypes.get(artworkContentDocumentMap.get(art.Id)) ==
            'JPG' ||
            artworkFileTypes.get(artworkContentDocumentMap.get(art.Id)) ==
            'JPEG' ||
            artworkFileTypes.get(artworkContentDocumentMap.get(art.Id)) == 'PNG'
          ) {
            artDetailsObject.artworkImageSupportExtension = true;
          } else {
            artDetailsObject.artworkImageSupportExtension = false;
          }
          List<ExtraChargesEstimate__c> extraChargeList = new List<ExtraChargesEstimate__c>();
          for (ExtraChargesEstimate__c extraCharge : extraChargesOfArtwork) {
            if (extraCharge.OpportunityLineItem_ArtWork__c == art.Id) {
              extraChargeList.add(extraCharge);
            }
          }
          artDetailsObject.extraCharges = extraChargeList;

          details.artworkDetails.add(artDetailsObject);
        }
      }

      List<ExtraChargesEstimate__c> extraCharges = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      Decimal total = 0;
      Decimal actualTotal = 0;
      Decimal marginPercentage = 0;
      Decimal marginAmount = 0;
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        Decimal retailPrice = (extraCharge.Retail_Price__c == null)
          ? 0
          : extraCharge.Retail_Price__c;
        if (retailPrice != 0) {
          actualTotal =
            actualTotal +
            ((extraCharge.Net_Cost__c != null ? extraCharge.Net_Cost__c : 0) *
            extraCharge.Quantity__c);
        }

        total += (extraCharge.Total__c == null) ? 0 : extraCharge.Total__c;
      }

      List<PricingLineItem__c> pricing = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];

      for (PricingLineItem__c rec : pricing) {
        Decimal retailPrice = (rec.Retail_Price__c == null)
          ? 0
          : rec.Retail_Price__c;
        if (retailPrice != 0) {
          actualTotal =
            actualTotal +
            ((rec.Net_Cost__c != null ? rec.Net_Cost__c : 0) *
            (rec.Estimated_Quantity__c != null
              ? rec.Estimated_Quantity__c
              : 0));
        }
        total += (rec.Total__c == null) ? 0 : rec.Total__c;
      }
      details.subtotal = actualTotal;
      details.total = total;
      opportunitLineItemData.Total__c = total;
      details.marginAmount = total - actualTotal;
      if (opportunitLineItemData.Total__c != 0) {
        details.marginPercentage = ((details.marginAmount /
          opportunitLineItemData.Total__c) * 100)
          .setScale(3);
      } else {
        details.marginPercentage = 0;
      }
      return details;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM getOpportunityLineItemDetails FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }

  @AuraEnabled
  public static String getOpportunityStage(String recid) {
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
  public static void setProductPricingFromEsp(String recId) {
    if (recId != null) {
      List<PricingLineItem__c> lstPrices = [
        SELECT
          id,
          Quantity__c,
          Estimated_Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY Quantity__c ASC
      ];

      List<OpportunityLineItem__c> lstOppItem = [
        SELECT Id, Product__c
        FROM OpportunityLineItem__c
        WHERE id = :recId
      ];

      Id productId = null;
      List<ESPProduct.Prices> lstESPPrices = getProductPricingFromEsp(recId);
      if (lstOppItem.size() > 0) {
        productId = lstOppItem.get(0).Product__c;
      }
      List<Pricing_Product__c> lstProductPrices = new List<Pricing_Product__c>();
      if (productId != null) {
        lstProductPrices = [
          SELECT Id, Name, Product__c, Quantity__c, Net_Cost__c, Retail_Price__c
          FROM Pricing_Product__c
          WHERE Product__c = :productId
          ORDER BY Quantity__c ASC
        ];
        Integer counter = 0;
        for (Pricing_Product__c priceObj : lstProductPrices) {
          if (counter < lstESPPrices.size()) {
            priceObj.Net_Cost__c = lstESPPrices.get(counter).Cost.setScale(2);
            counter++;
          }
        }
        system.debug('lstPrices---->>>>>>>' + lstPrices);
        if (lstProductPrices.size() > 0) {
          update lstProductPrices;
        }
      }
      if (lstPrices.size() > 0) {
        if (lstESPPrices != null) {
          Integer counter = 0;
          for (PricingLineItem__c priceObj : lstPrices) {
            priceObj.Net_Cost__c = getNetCost(
                priceObj.Estimated_Quantity__c,
                lstProductPrices
              )
              .setScale(2);
            priceObj.Total__c =
              priceObj.Net_Cost__c /
              (1 - (priceObj.Margin__c / 100)).setScale(2);
          }
        }

        update lstPrices;
      }
    }
  }
  @AuraEnabled
  public static Decimal getNetCost(
    Decimal quantity,
    List<Pricing_Product__c> allPricingRecords
  ) {
    if (allPricingRecords != null && allPricingRecords.Size() > 0) {
      Double previousPriceQauntity = 0;
      Double previousNetCost = 0;
      Double previousRetailPrice = 0;

      Decimal estimatedQuantity = quantity;
      for (Pricing_Product__c priceRecord : allPricingRecords) {
        if (
          priceRecord.Quantity__c == estimatedQuantity ||
          (estimatedQuantity > previousPriceQauntity &&
          estimatedQuantity <= priceRecord.Quantity__c)
        ) {
          previousPriceQauntity = priceRecord.Quantity__c;
          previousNetCost = priceRecord.Net_Cost__c;
          previousRetailPrice = priceRecord.Retail_Price__c;
          break;
        } else {
          previousPriceQauntity = priceRecord.Quantity__c;
          previousNetCost = priceRecord.Net_Cost__c;
          previousRetailPrice = priceRecord.Retail_Price__c;
        }
      }
      system.debug('quantity---->>>>' + quantity);

      system.debug('cost---->>>>' + previousNetCost);

      return previousNetCost;
    }
    return 0;
  }
  @AuraEnabled
  public static List<ESPProduct.Prices> getProductPricingFromEsp(
    String opportunityLineItemId
  ) {
    if (opportunityLineItemId != null) {
      List<OpportunityLineItem__c> lstOppLineItem = [
        SELECT Product__r.CommonSku_Id__c, Product__r.commonSkuVariantId__c
        FROM OpportunityLineItem__c
        WHERE id = :opportunityLineItemId
      ];
      if (lstOppLineItem.size() > 0) {
        String commonSkuId = String.valueOf(
          lstOppLineItem.get(0).Product__r.CommonSku_Id__c
        );
        String commonSkuVariantId = String.valueOf(
          lstOppLineItem.get(0).Product__r.commonSkuVariantId__c
        );
        String espEndPoint =
          System.Label.ESP_URL +
          'products/' +
          commonSkuId +
          '/configure.json';
        String authorizationHeader = System.Label.ESP_Key;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(espEndPoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responeJson = res.getBody();
        ESPProduct singleProduct = new ESPProduct();
        Boolean result = singleProduct.parse(responeJson, espEndPoint);
        List<ESPProduct.Prices> lstPrices = singleProduct.getPricesOfSpecificProduct(
          commonSkuVariantId
        );
        List<ESPProduct.Prices> lstPricesLimit = new List<ESPProduct.Prices>();
        Integer counter = 0;
        for (ESPProduct.Prices obj : lstPrices) {
          if (counter < 5) {
            lstPricesLimit.add(obj);
          }
          counter++;
        }
        return lstPricesLimit;
      }
    }
    return null;
  }
  @AuraEnabled
  public static boolean deleteBreakdownInDb(String recId) {
    try {
      PricingLineItem__c pricingRecord = [
        SELECT
          SystemModstamp,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Show_To_Client__c,
          Total__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c,
          Id
        FROM PricingLineItem__c
        WHERE id = :recId
      ];
      Id opportunityLineItemId = pricingRecord.OpportunityLineItem__c;
      delete pricingRecord;
      updateQuanitiesOfrunCharges(opportunityLineItemId);
      return true;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN deleteBreakdownInDb FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static boolean deleteArtworkInDb(String recId) {
    try {
      OpportunityLineItem_ArtWork__c artwork = [
        SELECT Id, OpportunityLineItem__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];
      List<ExtraChargesEstimate__c> extraChargesOfArtwork = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          OpportunityLineItem_ArtWork__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem_ArtWork__c = :recId
      ];
      delete extraChargesOfArtwork;
      delete artwork;

      return true;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM getOpportunityLineItemDetails FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails addArtworkLocationInEstimate(
    String recId
  ) {
    try {
      OpportunityLineItem_ArtWork__c artwork = new OpportunityLineItem_ArtWork__c();
      artwork.OpportunityLineItem__c = recId;
      artwork.Title__c = 'Artwork Title';
      insert artwork;

      Decimal quantity = 0;
      List<PricingLineItem__c> pricingDetails = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      if (pricingDetails != null && pricingDetails.size() > 0) {
        for (PricingLineItem__c pricingRecord : pricingDetails) {
          quantity += pricingRecord.Estimated_Quantity__c;
        }
      }

      ExtraChargesEstimate__c fixedCostExtraCharge = new ExtraChargesEstimate__c();
      fixedCostExtraCharge.OpportunityLineItem__c = recId;
      fixedCostExtraCharge.Charge_Type__c = 'AdditionalCost_FixedCharge';
      fixedCostExtraCharge.Is_Associated_With_Artwork__c = true;
      fixedCostExtraCharge.OpportunityLineItem_ArtWork__c = artwork.Id;
      fixedCostExtraCharge.Margin__c = 0;
      fixedCostExtraCharge.Net_Cost__c = 0;
      fixedCostExtraCharge.Quantity__c = 1;
      fixedCostExtraCharge.Retail_Price__c = 0;
      fixedCostExtraCharge.Title__c = 'Setup Cost';
      fixedCostExtraCharge.Total__c = 0;
      insert fixedCostExtraCharge;

      ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
      extraCharge.OpportunityLineItem__c = recId;
      extraCharge.OpportunityLineItem_ArtWork__c = artwork.Id;
      extraCharge.Charge_Type__c = 'AdditionalCost_RunCharge';
      extraCharge.Is_Associated_With_Artwork__c = true;
      extraCharge.Margin__c = 0;
      extraCharge.Title__c = 'Imprint Cost';
      extraCharge.Retail_Price__c = 0;
      extraCharge.Quantity__c = quantity;
      extraCharge.Total__c = 0;
      extraCharge.Display__c = 'Include In Price';
      extraCharge.Net_Cost__c = 0;
      insert extraCharge;

      return getOpportunityLineItemDetails(recId);
    } catch (Exception ex) {
      System.debug(
        'ERROR IN addArtworkLocationInEstimate FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }

  @AuraEnabled
  public static OpportunityLineItem_ArtWork__c getArtworkToEdit(String recId) {
    try {
      OpportunityLineItem_ArtWork__c artwork = [
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
          Title__c,
          Counter__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];
      return artwork;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN GETARTWORKTOEDIT--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static Boolean editArtworkInDatabases(
    String recId,
    String imprintType,
    String proofRequired,
    String logoName,
    String logoSize,
    String logoColor,
    String repeatLogo,
    String supplierNotes,
    String documentId,
    String title,
    String OpportunityLineItemId
  ) {
    try {
      Integer index = 0;
      OpportunityLineItem_ArtWork__c artwork = [
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
          Title__c,
          Counter__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];

      artwork.Imprint_Type__c = imprintType;
      artwork.Logo_Color__c = logoColor;
      artwork.logo_Name__c = logoName;
      artwork.Logo_Size__c = logoSize;
      artwork.Proof_Required__c = proofRequired;
      artwork.Repeat_Logo__c = repeatLogo;
      artwork.Supplier_Notes__c = supplierNotes;
      artwork.Title__c = title;

      //document id handling

      List<ContentDocumentLink> contentDocumentList = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recId
        ORDER BY ContentDocument.CreatedDate DESC
      ];

      if (contentDocumentList.size() != 0) {
        ContentDocumentLink updatedDocument = contentDocumentList.get(index)
          .clone();
        updatedDocument.LinkedEntityId = artwork.Id;
        updatedDocument.ShareType = 'V';
        delete contentDocumentList;
        insert updatedDocument;
        artwork.Document_ID__c = updatedDocument.ContentDocumentId;
      }

      update artwork;
      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN EDITING ARTWORK' + ex.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static OpportunityLineItemDetails updateStatusOfExtraCharges(
    String recId,
    String recordToUpdate,
    String value
  ) {
    try {
      List<ExtraChargesEstimate__c> extraChargeRecord = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Charge_Type__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recordToUpdate
      ];
      if (extraChargeRecord != null && extraChargeRecord.size() > 0) {
        extraChargeRecord.get(0).Display__c = value;
        update extraChargeRecord;
      }
      return getOpportunityLineItemDetails(recId);
    } catch (Exception ex) {
      System.debug(
        'ERROR IN updateStatusOfExtraCharges FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails addDefaultPricingRow(String recId) {
    try {
      List<PricingLineItem__c> pricingDetails = [
        SELECT
          Id,
          Color__c,
          Size__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Display__c = TRUE
          AND Default__c = TRUE
        ORDER BY CreatedDate ASC
      ];
      if (pricingDetails != null && pricingDetails.size() > 0) {
        PricingLineItem__c pricingRecord = pricingDetails.get(0).clone();
        pricingRecord.OpportunityLineItem__c = recId;
        pricingRecord.Default__c = false;
        pricingRecord.Color__c = (pricingDetails.get(0).Color__c != null
          ? pricingDetails.get(0).Color__c
          : null);
        pricingRecord.Size__c = (pricingDetails.get(0).Size__c != null
          ? pricingDetails.get(0).Size__c
          : null);
        insert pricingRecord;
        updateQuanitiesOfrunCharges(recId);
      }

      return getOpportunityLineItemDetails(recId);
    } catch (Exception ex) {
      System.debug(
        'ERROR IN addDefaultPricingRow FUNCTION ->>' +
          ex.getMessage() +
          '---->>>>>>' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static Boolean deleteExtraChargesInDb(String recId) {
    try {
      List<ExtraChargesEstimate__c> extraChargesRecord = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Charge_Type__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Net_Cost__c,
          Default__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recId
      ];
      delete extraChargesRecord;
      return true;
    } catch (Exception ex) {
      System.debug('Exception in deleting Warning->>>>>>>>>' + Ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static Boolean deleteWarningInDb(String recId) {
    List<WarningsOpportunityLineItem__c> warningToDelete = [
      SELECT Id, Warning__c
      FROM WarningsOpportunityLineItem__c
      WHERE Id = :recId
    ];
    system.debug(warningToDelete);
    delete warningToDelete;
    return true;
  }
  @AuraEnabled
  public static OpportunityLineItemDetails addExtraChargesInDBForArtwork(
    String recId,
    String chargeType,
    String artworkId
  ) {
    try {
      ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
      extraCharge.OpportunityLineItem__c = recId;
      extraCharge.Is_Associated_With_Artwork__c = true;
      extraCharge.OpportunityLineItem_ArtWork__c = artworkId;
      extraCharge.Margin__c = 0;
      extraCharge.Net_Cost__c = 0;
      extraCharge.Quantity__c = 1;
      extraCharge.Retail_Price__c = 0;
      extraCharge.Total__c = 0;

      if (chargeType == 'runCharge') {
        //calculate the quantity to be added
        //TO DO
        Decimal quantity = 0;
        List<PricingLineItem__c> pricingDetails = [
          SELECT
            Id,
            Quantity__c,
            Net_Cost__c,
            Retail_Price__c,
            Margin__c,
            Total__c,
            Show_To_Client__c,
            Estimate__c,
            Estimated_Quantity__c,
            Display__c,
            Default__c
          FROM PricingLineItem__c
          WHERE
            OpportunityLineItem__c = :recId
            AND Display__c = TRUE
            AND Default__c = FALSE
          ORDER BY CreatedDate ASC
        ];
        if (pricingDetails != null && pricingDetails.size() > 0) {
          for (PricingLineItem__c pricingRecord : pricingDetails) {
            quantity += pricingRecord.Estimated_Quantity__c;
          }
        }
        extraCharge.Display__c = 'Include In Price';
        extraCharge.Quantity__c = quantity;
        extraCharge.Charge_Type__c = 'AdditionalCost_RunCharge';
        extraCharge.Title__c = ' ';
      } else if (chargeType == 'fixedCharge') {
        extraCharge.Display__c = 'Display To Client';
        extraCharge.Charge_Type__c = 'AdditionalCost_FixedCharge';
        extraCharge.Title__c = ' ';
      }
      insert extraCharge;
      return getOpportunityLineItemDetails(recId);
    } catch (Exception ex) {
      System.debug(
        'Exception in adding extra Charge Warning->>>>>>>>>' +
          Ex.getMessage() +
          Ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static Boolean addExtraChargesInDB(String recId, String chargeType) {
    try {
      ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
      extraCharge.OpportunityLineItem__c = recId;
      extraCharge.Is_Associated_With_Artwork__c = false;
      extraCharge.Margin__c = 0;
      extraCharge.Net_Cost__c = 0;
      extraCharge.Quantity__c = 1;
      extraCharge.Retail_Price__c = 0;
      extraCharge.Total__c = 0;

      if (chargeType == 'runCharge') {
        //calculate the quantity to be added
        //TO DO
        Decimal quantity = 0;
        List<PricingLineItem__c> pricingDetails = [
          SELECT
            Id,
            Quantity__c,
            Net_Cost__c,
            Retail_Price__c,
            Margin__c,
            Total__c,
            Show_To_Client__c,
            Estimate__c,
            Estimated_Quantity__c,
            Display__c,
            Default__c
          FROM PricingLineItem__c
          WHERE
            OpportunityLineItem__c = :recId
            AND Display__c = TRUE
            AND Default__c = FALSE
          ORDER BY CreatedDate ASC
        ];
        if (pricingDetails != null && pricingDetails.size() > 0) {
          for (PricingLineItem__c pricingRecord : pricingDetails) {
            quantity += pricingRecord.Estimated_Quantity__c;
          }
        }
        extraCharge.Quantity__c = quantity;
        extraCharge.Charge_Type__c = 'AdditionalCost_RunCharge';
        extraCharge.Title__c = 'Run Charge';
        extraCharge.Display__c = 'Include In Price';
      } else if (chargeType == 'fixedCharge') {
        extraCharge.Charge_Type__c = 'AdditionalCost_FixedCharge';
        extraCharge.Title__c = 'Fixed Charge';
      } else if (chargeType == 'brokerage') {
        extraCharge.Charge_Type__c = 'InternationalCost_Brokerage';
        extraCharge.Title__c = 'Brokerage';
      } else if (chargeType == 'inboundFreight') {
        extraCharge.Charge_Type__c = 'InternationalCost_InboundFreight';
        extraCharge.Title__c = 'Inbound Frieght';
      } else if (chargeType == 'duty') {
        extraCharge.Charge_Type__c = 'InternationalCost_Duty';
        extraCharge.Title__c = 'Duty';
        extraCharge.Duty_Percentage__c = 0;
      }

      insert extraCharge;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Exception in adding extra Charge Warning->>>>>>>>>' +
          Ex.getMessage() +
          Ex.getStackTraceString()
      );
      return false;
    }
  }
  @AuraEnabled
  public static Boolean addWarningInDB(String recId) {
    try {
      WarningsOpportunityLineItem__c warning = new WarningsOpportunityLineItem__c();
      warning.OpportunityLineItem__c = recId;
      warning.Warning__c = 'This product contains a chemical known to the State of California to cause cancer, birth defects or other reproductive harm.  For more information, go to <a href="https://www.P65Warnings.ca.gov" target="_blank">https://www.P65Warnings.ca.gov</a>';
      insert warning;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in Adding Warning in DB------>>>>>>>' + ex.getMessage()
      );
      return false;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updateValuesOfDutyExtraChargesInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      List<ExtraChargesEstimate__c> extraChargesRecord = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Charge_Type__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          OpportunityLineItem__r.Estimate__c,
          Net_Cost__c,
          Default__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recordToUpdate
      ];
      if (extraChargesRecord != null && extraChargesRecord.size() > 0) {
        ExtraChargesEstimate__c record = extraChargesRecord.get(0);
        Id EstimatesId = record.OpportunityLineItem__r.Estimate__c;
        Set<Id> setEstimateIds = new Set<Id>();
        setEstimateIds.add(EstimatesId);
        Boolean dataChanged = false;

        if (updateKey != 'delete') {
          //record.Net_Cost__c = Decimal.ValueOf(updatedValue);
          Decimal total = 0;
          Decimal quantity = 0;
          List<PricingLineItem__c> pricingDetails = [
            SELECT
              Id,
              Quantity__c,
              Net_Cost__c,
              Retail_Price__c,
              Margin__c,
              Total__c,
              Estimate__c,
              Estimated_Quantity__c,
              Display__c,
              Default__c
            FROM PricingLineItem__c
            WHERE
              OpportunityLineItem__c = :record.OpportunityLineItem__c
              AND Display__c = TRUE
              AND Default__c = FALSE
            ORDER BY CreatedDate ASC
          ];
          if (pricingDetails != null && pricingDetails.size() > 0) {
            for (PricingLineItem__c pricingRecord : pricingDetails) {
              quantity += pricingRecord.Estimated_Quantity__c;
              total += pricingRecord.Net_Cost__c.setScale(2);
              setEstimateIds.add(pricingRecord.Estimate__c);
            }
          }
          Decimal sumOfBreakdownCharges = quantity * total;

          if (updateKey == 'title') {
            record.Title__c = updatedValue;
            dataChanged = true;
          } else if (updateKey == 'netCost') {
            record.Net_cost__c = Decimal.valueOf(updatedValue).setScale(2);
            //   record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            // record.Margin__c = record.Margin__c.setScale(3);
            // record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            record.Duty_Percentage__c = ((record.Net_Cost__c * 100) /
              sumOfBreakdownCharges)
              .setScale(2);
            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = (record.Net_Cost__c / marginCalculation)
              .setScale(2);
            //   record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            record.Total__c = (record.Quantity__c * record.Retail_Price__c)
              .setScale(2);
            dataChanged = true;
          } else if (updateKey == 'margin') {
            record.Margin__c = Decimal.valueOf(updatedValue).setScale(2);
            //        record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //      record.Margin__c = record.Margin__c.setScale(3);
            //    record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = (record.Net_Cost__c / marginCalculation)
              .setScale(2);
            // record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            record.Total__c = (record.Quantity__c * record.Retail_Price__c)
              .setScale(2);
            dataChanged = true;
          } else if (updateKey == 'retailPrice') {
            record.Retail_Price__c = Decimal.valueOf(updatedValue).setScale(2);
            //               record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //             record.Margin__c = record.Margin__c.setScale(3);
            //           record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal priceCostCalculation =
              record.Retail_Price__c - record.Net_Cost__c;
            record.Margin__c = ((priceCostCalculation /
              record.Retail_Price__c) * 100)
              .setScale(2);
            //         record.Margin__c =  record.Margin__c.setScale(3);
            record.Total__c = (record.Quantity__c * record.Retail_Price__c)
              .setScale(2);
            dataChanged = true;
          } else if (updateKey == 'percentage') {
            record.Duty_Percentage__c = Decimal.valueOf(updatedValue)
              .setScale(3);
            //                record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //              record.Margin__c = record.Margin__c.setScale(3);
            //            record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            record.Net_Cost__c = (sumOfBreakdownCharges *
              (record.Duty_Percentage__c / 100))
              .setScale(2);
            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = (record.Net_Cost__c / marginCalculation)
              .setScale(2);
            //          record.Retail_Price__c = record.Retail_Price__c.setScale(2);
            record.Total__c = (record.Quantity__c * record.Retail_Price__c)
              .setScale(2);
            dataChanged = true;
          }
          update record;
          if (dataChanged == true) {
            List<Id> lstEstimate = new List<Id>();
            for (Id keyId : setEstimateIds) {
              lstEstimate.add(keyId);
            }
            updateEstimates(lstEstimate);
          }
          return getOpportunityLineItemDetails(record.OpportunityLineItem__c);
        }
        return getOpportunityLineItemDetails(record.OpportunityLineItem__c);
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updateValuesOfExtraChargesInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      List<ExtraChargesEstimate__c> extraChargesRecord = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Charge_Type__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          OpportunityLineItem__r.Estimate__c,
          Net_Cost__c,
          Default__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recordToUpdate
      ];
      if (extraChargesRecord != null && extraChargesRecord.size() > 0) {
        Integer index = 0;
        ExtraChargesEstimate__c record = extraChargesRecord.get(index);
        Id EstimatesId = record.OpportunityLineItem__r.Estimate__c;
        List<Id> lstEstimateIds = new List<Id>();
        lstEstimateIds.add(EstimatesId);
        Boolean dataChanged = false;
        if (updateKey != 'delete') {
          if (updateKey == 'title') {
            record.Title__c = updatedValue;
            dataChanged = true;
          } else if (updateKey == 'quantity') {
            record.Quantity__c = Decimal.valueOf(updatedValue);
            record.Total__c =
              Decimal.valueOf(updatedValue) * record.Retail_Price__c;
            dataChanged = true;
          } else if (updateKey == 'netCost') {
            system.debug('record-->>' + record);
            record.Net_Cost__c = Decimal.valueOf(updatedValue);
            //                   record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //                 record.Margin__c = record.Margin__c.setScale(3);
            //               record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = record.Net_Cost__c / marginCalculation;
            //             record.Retail_Price__c= record.Retail_Price__c.setScale(3);
            record.Total__c = record.Quantity__c * record.Retail_Price__c;
            dataChanged = true;
          } else if (updateKey == 'margin') {
            record.Margin__c = Decimal.valueOf(updatedValue);
            //                  record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //                record.Margin__c = record.Margin__c.setScale(3);
            //              record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = record.Net_Cost__c / marginCalculation;
            //            record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            record.Total__c = record.Quantity__c * record.Retail_Price__c;
            dataChanged = true;
          } else if (updateKey == 'retailPrice') {
            record.Retail_Price__c = Decimal.valueOf(updatedValue);
            //             record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //           record.Margin__c = record.Margin__c.setScale(3);
            //         record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal priceCostCalculation =
              record.Retail_Price__c - record.Net_Cost__c;
            record.Margin__c =
              (priceCostCalculation / record.Retail_Price__c) * 100;
            //      record.Margin__c =  record.Margin__c.setScale(3);
            record.Total__c = record.Quantity__c * record.Retail_Price__c;
            dataChanged = true;
          }
          update record;
          if (dataChanged == true) {
            updateEstimates(lstEstimateIds);
          }
          return getOpportunityLineItemDetails(record.OpportunityLineItem__c);
        }
        return getOpportunityLineItemDetails(record.OpportunityLineItem__c);
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static void updateQuanitiesOfrunCharges(String recId) {
    try {
      List<ExtraChargesEstimate__c> runCharges = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Margin__c,
          Retail_Price__c,
          Charge_Type__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Charge_Type__c = 'AdditionalCost_RunCharge'
        ORDER BY CreatedDate ASC
      ];
      Decimal quantity = 0;
      List<PricingLineItem__c> pricingDetails = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Default__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];

      List<Id> lstEstimateIds = new List<Id>();
      if (pricingDetails != null && pricingDetails.size() > 0) {
        for (PricingLineItem__c pricingRecord : pricingDetails) {
          quantity += pricingRecord.Estimated_Quantity__c;
          lstEstimateIds.add(pricingRecord.Estimate__c);
        }
      }
      for (ExtraChargesEstimate__c extraCharge : runCharges) {
        extraCharge.Quantity__c = quantity;
      }
      System.debug('lstEstimateIds' + lstEstimateIds.size());
      update runCharges;
      updateEstimates(lstEstimateIds);
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
    }
  }
  public static void updateEstimates(List<Id> lstEstimateIds) {
    List<Estimate__c> lstEstimate = [
      SELECT id, Data_Changed__c
      FROM Estimate__c
      WHERE id IN :lstEstimateIds
    ];
    for (Estimate__c estimateObj : lstEstimate) {
      estimateObj.Data_Changed__c = true;
    }
    update lstEstimate;
  }

  @AuraEnabled
  public static OpportunityLineItemDetails updatePricingInDb(
    Decimal updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      List<PricingLineItem__c> pricingRecord = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Retail_Price__c,
          Net_Cost__c,
          Margin__c,
          Total__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      List<Id> lstEstimateIds = new List<Id>();
      if (pricingRecord != null && pricingRecord.size() > 0) {
        Integer index = 0;
        Boolean dataChanges = false;
        PricingLineItem__c record = pricingRecord.get(index);
        lstEstimateIds.add(record.Estimate__c);
        if (updateKey != 'delete') {
          if (updateKey == 'quantity') {
            record.Estimated_Quantity__c = updatedValue;
            record.Total__c = updatedValue * record.Retail_Price__c;
            dataChanges = true;
          } else if (updateKey == 'netCost') {
            record.Net_Cost__c = updatedValue;
            //              record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //            record.Margin__c = record.Margin__c.setScale(3);
            //          record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = record.Net_Cost__c / marginCalculation;
            //        record.Retail_Price__c= record.Retail_Price__c.setScale(3);
            record.Total__c =
              record.Estimated_Quantity__c * record.Retail_Price__c;
            dataChanges = true;
          } else if (updateKey == 'margin') {
            record.Margin__c = updatedValue;
            //                 record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //               record.Margin__c = record.Margin__c.setScale(3);
            //             record.Net_Cost__c = record.Net_Cost__c.setScale(3);
            //system.debug('Retail_Price__c --->>>>>>' +record.Retail_Price__c);
            // system.debug('Net_Cost__c --->>>>>>' +record.Net_Cost__c);

            decimal marginCalculation = 1 - (record.Margin__c / 100);
            record.Retail_Price__c = record.Net_Cost__c / marginCalculation;
            //  system.debug('Retail_Price__c Without set scale --->>>>>>' +record.Retail_Price__c);
            //           record.Retail_Price__c= record.Retail_Price__c.setScale(3);
            record.Total__c =
              record.Estimated_Quantity__c * record.Retail_Price__c;

            dataChanges = true;
            // system.debug('margin --->>>>>>' +record.Margin__c);
            // system.debug('Retail_Price__c --->>>>>>' +record.Retail_Price__c);
          } else if (updateKey == 'retailPrice') {
            record.Retail_Price__c = updatedValue;
            //                 record.Retail_Price__c = record.Retail_Price__c.setScale(3);
            //               record.Margin__c = record.Margin__c.setScale(3);
            //             record.Net_Cost__c = record.Net_Cost__c.setScale(3);

            decimal priceCostCalculation =
              record.Retail_Price__c - record.Net_Cost__c;
            system.debug('Retail_Price__c --->>>>>>' + record.Retail_Price__c);
            system.debug('Net_Cost__c --->>>>>>' + record.Net_Cost__c);

            record.Margin__c =
              (priceCostCalculation / record.Retail_Price__c) * 100;
            system.debug('margin without scale --->>>>>>' + record.Margin__c);
            //              record.Margin__c=  record.Margin__c.setScale(3);
            record.Total__c =
              record.Estimated_Quantity__c * record.Retail_Price__c;
            dataChanges = true;
            //       system.debug('margin --->>>>>>' +record.Margin__c);
            //      system.debug('Retail_Price__c --->>>>>>' +record.Retail_Price__c);
          }

          update record;

          if (updateKey == 'quantity') {
            updateQuanitiesOfrunCharges(record.OpportunityLineItem__c);
          } else {
            if (dataChanges == true) {
              updateEstimates(lstEstimateIds);
            }
          }
        }
        return getOpportunityLineItemDetails(record.OpportunityLineItem__c);
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static Boolean updateWarningValueInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      WarningsOpportunityLineItem__c warning = [
        SELECT Warning__c, OpportunityLineItem__c, Id
        FROM WarningsOpportunityLineItem__c
        WHERE Id = :recordToUpdate
      ];
      warning.Warning__c = updatedValue;
      update warning;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static Boolean updateNotesAndLabelInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      OpportunityLineItem__c opportunitLineItemData = [
        SELECT
          Supplier__c,
          Price_Label__c,
          Private_Notes__c,
          SortOrder__c,
          SKU__c,
          Opportunity__c,
          Product__c,
          Imprint_Methods__c,
          Description__c,
          SystemModstamp,
          Name,
          Id,
          Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id = :recordToUpdate
      ];
      List<ID> lstEstimateIds = new List<ID>();
      lstEstimateIds.add(opportunitLineItemData.Estimate__c);

      if (updateKey == 'privateNotes') {
        opportunitLineItemData.Private_Notes__c = updatedValue;
      } else if (updateKey == 'description') {
        opportunitLineItemData.Description__c = updatedValue;
      } else if (updateKey == 'productName') {
        opportunitLineItemData.Name = updatedValue;
      }
      update opportunitLineItemData;
      System.debug('====================================================');
      System.debug(lstEstimateIds);
      updateEstimates(lstEstimateIds);
      System.debug(
        '1111111111111111111111111111111111111111111111111111111111'
      );

      return true;
    } catch (Exception Ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + Ex.getStackTraceString()
      );
      return false;
    }
  }

  @AuraEnabled
  public static Boolean addColorInDb(
    String recId,
    List<String> color,
    String lineItemId
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Color__c, Estimate__c
        FROM PricingLineItem__c
        WHERE id = :recId
      ];
      List<Id> lstEstimateIds = new List<Id>();
      lstEstimateIds.add(priceDetails.Estimate__c);
      updateEstimates(lstEstimateIds);
      priceDetails.Color__c = color[0];
      update priceDetails;
      ColorLineItem__c newColor = new ColorLineItem__c();
      newColor.Color__c = color[0];
      newColor.isSelected__c = true;
      newColor.OpportunityLineItem__c = lineItemId;
      insert newColor;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addColorInDb--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static Boolean addSizeInDb(
    String recId,
    List<String> size,
    String lineItemId
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Size__c, Estimate__c
        FROM PricingLineItem__c
        WHERE id = :recId
      ];
      List<Id> lstEstimateIds = new List<Id>();
      lstEstimateIds.add(priceDetails.Estimate__c);
      updateEstimates(lstEstimateIds);
      priceDetails.Size__c = size[0];
      update priceDetails;
      SizeLineItem__c newSize = new SizeLineItem__c();
      newSize.Size__c = size[0];
      newSize.isSelected__c = true;
      newSize.OpportunityLineItem__c = lineItemId;
      insert newSize;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addSizeInDb--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static List<OppLineItemSizes> getValuesForSizePiklist(
    String recId,
    String sizeId
  ) {
    try {
      List<SizeLineItem__c> sizesList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      PricingLineItem__c priceDetails = [
        SELECT Id, Size__c
        FROM PricingLineItem__c
        WHERE id = :sizeId
      ];
      List<OppLineItemSizes> listToReturn = new List<OppLineItemSizes>();
      boolean availableSize = false;
      for (SizeLineItem__c size : sizesList) {
        OppLineItemSizes s = new OppLineItemSizes();
        if (priceDetails.Size__c == size.Size__c) {
          availableSize = true;
          s.isSelected = true;
        } else {
          s.isSelected = false;
        }
        s.id = size.Id;
        s.size = size.Size__c;
        listToReturn.add(s);
      }
      if (priceDetails.Size__c != null && !(availableSize)) {
        OppLineItemSizes s = new OppLineItemSizes();
        s.id = priceDetails.Id;
        s.size = priceDetails.Size__c;
        s.isSelected = true;
        listToReturn.add(s);
      }
      return listToReturn;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForSizePiklist--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static List<OppLineItemColors> getValuesForColorPiklist(
    String recId,
    String priceId
  ) {
    try {
      List<ColorLineItem__c> colorsList = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      PricingLineItem__c priceDetails = [
        SELECT Id, Color__c
        FROM PricingLineItem__c
        WHERE id = :priceId
      ];
      boolean availableColor = false;
      List<OppLineItemColors> listToReturn = new List<OppLineItemColors>();

      for (ColorLineItem__c color : colorsList) {
        OppLineItemColors col = new OppLineItemColors();
        if (priceDetails.Color__c == color.Color__c) {
          availableColor = true;
        }
        if (priceDetails.Color__c == color.Color__c) {
          availableColor = true;
          col.isSelected = true;
        } else {
          col.isSelected = false;
        }

        col.id = color.Id;
        col.color = color.Color__c;
        listToReturn.add(col);
      }

      if (priceDetails.Color__c != null && !(availableColor)) {
        OppLineItemColors col = new OppLineItemColors();
        col.id = priceDetails.Id;
        col.color = priceDetails.Color__c;
        col.isSelected = true;
        listToReturn.add(col);
      }
      return listToReturn;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForColorPiklist--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }
}
