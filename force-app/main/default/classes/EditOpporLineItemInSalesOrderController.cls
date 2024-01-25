public class EditOpporLineItemInSalesOrderController {
  @AuraEnabled
  public static OpportunityLineItemDetails getOpportunityLineItemDetails(
    String recId
  ) {
    OpportunityLineItemDetails details = new OpportunityLineItemDetails();
    try {
      OpportunityLineItem__c opportunitLineItemData = [
        SELECT
          Account__r.Name,
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
          Quantity_Estimate__c,
          Id
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
      if (opportunitLineItemData.Account__r != null)
        details.supplier = opportunitLineItemData.Account__r.Name;
      details.description = opportunitLineItemData.Description__c;
      details.imprintMethods = opportunitLineItemData.Imprint_Methods__c;
      details.priceLabel = opportunitLineItemData.Price_Label__c;
      details.privateNotes = opportunitLineItemData.Private_Notes__c;
      details.name = opportunitLineItemData.Name;
      details.sku = opportunitLineItemData.SKU__c;
      details.EstimatedQuantity = opportunitLineItemData.Quantity_Estimate__c;
      details.ProductID = opportunitLineItemData.Product__c;

      details.pricingDetails = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Size__c,
          Color__c,
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
        ORDER BY CreatedDate ASC
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
      List<Id> contentDocumnetList = new List<Id>();
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
      }
      for (ContentDocumentLink obj : artworkRelatedImages) {
        artworkContentDocumentMap.put(
          obj.LinkedEntityId,
          obj.ContentDocumentId
        );
      }
      for (ContentDocumentLink obj : artworkRelatedImages) {
        contentDocumnetList.add(obj.ContentDocumentId);
      }
      List<ContentVersion> artworkRelatedImageFiles = [
        SELECT id, FileType, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocumnetList AND FileType != 'PDF'
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
          System.debug('artDetailsObject--->>>>>>>>>>>>>>>' + artDetailsObject);
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
      decimal actualTotal = 0;
      Decimal marginPercentage = 0;
      Decimal marginAmount = 0;
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        decimal retailPrice = (extraCharge.Retail_Price__c == null)
          ? 0
          : extraCharge.Retail_Price__c;
        if (retailPrice != 0) {
          decimal price = (extraCharge.Net_Cost__c == null)
            ? 0
            : extraCharge.Net_Cost__c;
          decimal quanitity = (extraCharge.Quantity__c == null)
            ? 0
            : extraCharge.Quantity__c;
          actualTotal = actualTotal + (price * quanitity);
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
        decimal price = (rec.Net_Cost__c == null) ? 0 : rec.Net_Cost__c;
        decimal quanitity = (rec.Estimated_Quantity__c == null)
          ? 0
          : rec.Estimated_Quantity__c;
        actualTotal = actualTotal + (price * quanitity);
        total += (rec.Total__c == null) ? 0 : rec.Total__c;
      }
      details.subtotal = actualTotal;
      details.total = total;
      details.marginAmount = total - actualTotal;
      if (total != 0) {
        details.marginPercentage = (((total - actualTotal) / total) * 100)
          .setScale(2);
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
            priceObj.Net_Cost__c = lstESPPrices.get(counter).Cost;
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
            );
            priceObj.Total__c =
              priceObj.Net_Cost__c / (1 - (priceObj.Margin__c / 100));
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
  public static boolean editArtworkInDatabases(
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
      integer index = 0;
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

      List<ContentDocumentLink> documentIds = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recId
        ORDER BY ContentDocument.CreatedDate DESC
      ];

      if (documentIds.size() != 0) {
        ContentDocumentLink updatedDocument = documentIds.get(index).clone();
        updatedDocument.LinkedEntityId = artwork.Id;
        updatedDocument.ShareType = 'V';
        delete documentIds;
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
  public static boolean updateProductPricingInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    system.debug('In updateProductPricingInDb');
    try {
      PricingLineItem__c pricingToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Estimated_Quantity__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          OpportunityLineItem__r.Work_Order__c,
          Size__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];

      OpportunityLineItem__c oppLineItem = [
        SELECT Id, SKU__c, PurchaseOrder_LineItem__c
        FROM OpportunityLineItem__c
        WHERE Id = :pricingToUpdate.OpportunityLineItem__c
      ];

      List<ExtraChargesEstimate__c> extraChargesToUpdate = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          Total__c,
          Retail_Price__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          OpportunityLineItem__c = :pricingToUpdate.OpportunityLineItem__c
          AND Charge_Type__c = 'AdditionalCost_RunCharge'
      ];
      System.debug(pricingToUpdate.OpportunityLineItem__r.Work_Order__c);
      if (updatekey == 'quantity') {
        pricingToUpdate.Estimated_Quantity__c = decimal.valueOf(updatedValue)
          .setScale(0);
        pricingToUpdate.Total__c =
          pricingToUpdate.Estimated_Quantity__c *
          pricingToUpdate.Retail_Price__c;
        pricingToUpdate.Total__c = pricingToUpdate.Total__c.setScale(2);
        for (ExtraChargesEstimate__c extCharge : extraChargesToUpdate) {
          extCharge.Quantity__c = decimal.valueOf(updatedValue).setScale(0);
          extCharge.Total__c =
            extCharge.Quantity__c * extraChargesToUpdate[0].Retail_Price__c;
          extCharge.Total__c = extCharge.Total__c.setScale(2);
        }
      } else if (updateKey == 'netCost') {
        pricingToUpdate.Net_Cost__c = decimal.valueOf(updatedValue).setScale(2);
        decimal marginCalculation = 1 - (pricingToUpdate.Margin__c / 100);
        pricingToUpdate.Retail_Price__c =
          pricingToUpdate.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        pricingToUpdate.Retail_Price__c = pricingToUpdate.Retail_Price__c.setScale(
          2
        );
        pricingToUpdate.Total__c =
          pricingToUpdate.Estimated_Quantity__c *
          pricingToUpdate.Retail_Price__c;
        pricingToUpdate.Total__c = pricingToUpdate.Total__c.setScale(2);
      } else if (updateKey == 'margin') {
        pricingToUpdate.Margin__c = decimal.valueOf(updatedValue);
        decimal marginCalculation = 1 - (pricingToUpdate.Margin__c / 100);
        pricingToUpdate.Retail_Price__c =
          pricingToUpdate.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        pricingToUpdate.Retail_Price__c = pricingToUpdate.Retail_Price__c.setScale(
          2
        );
        pricingToUpdate.Total__c =
          pricingToUpdate.Estimated_Quantity__c *
          pricingToUpdate.Retail_Price__c;
        pricingToUpdate.Total__c = pricingToUpdate.Total__c.setScale(2);
      } else if (updateKey == 'sku') {
        oppLineItem.SKU__c = updatedValue;
      }
      update pricingToUpdate;
      system.debug('Pricing Update');
      update extraChargesToUpdate;
      update oppLineItem;
      EditOpporLineItemInSalesOrderController.updateWorkOrder(
        pricingToUpdate.OpportunityLineItem__r.Work_Order__c
      );

      if (!system.isBatch() && !System.isFuture() && !Test.isRunningTest()) {
        //opportunitLineItemData
        List<PurchaseOrder_LineItem__c> pOrderList = [
          SELECT Id, WO_Status__c, QBO_Bill__c, WOQBOInstance__c
          FROM PurchaseOrder_LineItem__c
          WHERE Id = :oppLineItem.PurchaseOrder_LineItem__c
        ];
        Set<Id> purchaseOrdersToBeUpdated = new Set<Id>();
        Map<Id, String> OrderAccountMap = new Map<Id, String>();
        for (PurchaseOrder_LineItem__c pOrder : pOrderList) {
          if (
            pOrder.WO_Status__c != 'Completed' &&
            pOrder.QBO_Bill__c != null
          ) {
            purchaseOrdersToBeUpdated.add(pOrder.Id);
            OrderAccountMap.put(pOrder.Id, pOrder.WOQBOInstance__c);
          }
        }
        // Update the bill syncing
        if (purchaseOrdersToBeUpdated.size() > 0 && OrderAccountMap.size() > 0)
          QuickbookApiCrud.updatePurchaseOrder(
            purchaseOrdersToBeUpdated,
            OrderAccountMap
          );
      }

      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Pricing ->>' + ex.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static boolean updateExtraChargesInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      ExtraChargesEstimate__c extraChargesToUpdate = [
        SELECT
          Id,
          Title__c,
          Quantity__c,
          Charge_Type__c,
          Total__c,
          Retail_Price__c,
          Margin__c,
          OpportunityLineItem__c,
          OpportunityLineItem__r.Work_Order__c,
          OpportunityLineItem__r.PurchaseOrder_LineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recordToUpdate
      ];

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
          OpportunityLineItem__c = :extraChargesToUpdate.OpportunityLineItem__c
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      if (pricingDetails != null && pricingDetails.size() > 0) {
        for (PricingLineItem__c pricingRecord : pricingDetails) {
          quantity += pricingRecord.Estimated_Quantity__c;
          total += pricingRecord.Net_Cost__c.setScale(2);
        }
      }

      Decimal sumOfBreakdownCharges = quantity * total;

      if (updatekey == 'quantity') {
        extraChargesToUpdate.Quantity__c = decimal.valueOf(updatedValue)
          .setScale(0);
        extraChargesToUpdate.Total__c =
          extraChargesToUpdate.Quantity__c *
          extraChargesToUpdate.Retail_Price__c;
        extraChargesToUpdate.Total__c = extraChargesToUpdate.Total__c.setScale(
          2
        );
      } else if (updateKey == 'netCost') {
        extraChargesToUpdate.Net_Cost__c = decimal.valueOf(updatedValue)
          .setScale(2);
        System.debug(extraChargesToUpdate.Net_Cost__c);
        decimal marginCalculation = 1 - (extraChargesToUpdate.Margin__c / 100);
        extraChargesToUpdate.Retail_Price__c = (extraChargesToUpdate.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1))
          .setScale(2);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          2
        );
        extraChargesToUpdate.Total__c =
          extraChargesToUpdate.Quantity__c *
          extraChargesToUpdate.Retail_Price__c;
        extraChargesToUpdate.Total__c = extraChargesToUpdate.Total__c.setScale(
          2
        );
      } else if (updateKey == 'margin') {
        extraChargesToUpdate.Margin__c = decimal.valueOf(updatedValue)
          .setScale(2);
        decimal marginCalculation = 1 - (extraChargesToUpdate.Margin__c / 100);
        extraChargesToUpdate.Retail_Price__c =
          extraChargesToUpdate.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          2
        );
        extraChargesToUpdate.Total__c =
          extraChargesToUpdate.Quantity__c *
          extraChargesToUpdate.Retail_Price__c;
        extraChargesToUpdate.Total__c = extraChargesToUpdate.Total__c.setScale(
          2
        );
      } else if (updateKey == 'title') {
        extraChargesToUpdate.Title__c = updatedValue;
      } else if (updateKey == 'dutyExtraChargesNetCost') {
        extraChargesToUpdate.Net_cost__c = Decimal.valueOf(updatedValue)
          .setScale(2);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          3
        );
        extraChargesToUpdate.Margin__c = extraChargesToUpdate.Margin__c.setScale(
          3
        );
        extraChargesToUpdate.Net_Cost__c = extraChargesToUpdate.Net_Cost__c.setScale(
          3
        );

        extraChargesToUpdate.Duty_Percentage__c = ((extraChargesToUpdate.Net_Cost__c *
          100) / sumOfBreakdownCharges)
          .setScale(2);
        decimal marginCalculation = 1 - (extraChargesToUpdate.Margin__c / 100);
        extraChargesToUpdate.Retail_Price__c = (extraChargesToUpdate.Net_Cost__c /
          marginCalculation)
          .setScale(2);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          2
        );
        extraChargesToUpdate.Total__c = (extraChargesToUpdate.Quantity__c *
          extraChargesToUpdate.Retail_Price__c)
          .setScale(2);
      } else if (updateKey == 'dutyPercentage') {
        extraChargesToUpdate.Duty_Percentage__c = Decimal.valueOf(updatedValue)
          .setScale(3);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          3
        );
        extraChargesToUpdate.Margin__c = extraChargesToUpdate.Margin__c.setScale(
          3
        );
        extraChargesToUpdate.Net_Cost__c = extraChargesToUpdate.Net_Cost__c.setScale(
          3
        );

        extraChargesToUpdate.Net_Cost__c = (sumOfBreakdownCharges *
          (extraChargesToUpdate.Duty_Percentage__c / 100))
          .setScale(2);
        decimal marginCalculation = 1 - (extraChargesToUpdate.Margin__c / 100);
        extraChargesToUpdate.Retail_Price__c = (extraChargesToUpdate.Net_Cost__c /
          marginCalculation)
          .setScale(2);
        extraChargesToUpdate.Retail_Price__c = extraChargesToUpdate.Retail_Price__c.setScale(
          2
        );
        extraChargesToUpdate.Total__c = (extraChargesToUpdate.Quantity__c *
          extraChargesToUpdate.Retail_Price__c)
          .setScale(2);
      }
      update extraChargesToUpdate;
      EditOpporLineItemInSalesOrderController.updateWorkOrder(
        extraChargesToUpdate.OpportunityLineItem__r.Work_Order__c
      );

      if (!system.isBatch() && !System.isFuture() && !Test.isRunningTest()) {
        //opportunitLineItemData
        List<PurchaseOrder_LineItem__c> pOrderList = [
          SELECT Id, WO_Status__c, QBO_Bill__c, WOQBOInstance__c
          FROM PurchaseOrder_LineItem__c
          WHERE
            Id = :extraChargesToUpdate.OpportunityLineItem__r.PurchaseOrder_LineItem__c
        ];
        Set<Id> purchaseOrdersToBeUpdated = new Set<Id>();
        Map<Id, String> OrderAccountMap = new Map<Id, String>();
        for (PurchaseOrder_LineItem__c pOrder : pOrderList) {
          if (
            pOrder.WO_Status__c != 'Completed' &&
            pOrder.QBO_Bill__c != null
          ) {
            purchaseOrdersToBeUpdated.add(pOrder.Id);
            OrderAccountMap.put(pOrder.Id, pOrder.WOQBOInstance__c);
          }
        }
        // Update the bill syncing
        if (purchaseOrdersToBeUpdated.size() > 0 && OrderAccountMap.size() > 0)
          QuickbookApiCrud.updatePurchaseOrder(
            purchaseOrdersToBeUpdated,
            OrderAccountMap
          );
      }

      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Pricing ->>' + ex.getMessage());
      return false;
    }
  }

  public static Boolean updateWorkOrder(Id workOrderId) {
    try {
      Order WO = [
        SELECT Id, Invoice_Total__c, Invoice_Value__c, Order_Amount__c
        FROM Order
        WHERE Id = :workOrderId
      ];

      List<OpportunityLineItem__c> oppLineItems = [
        SELECT id
        FROM OpportunityLineItem__c
        WHERE Work_Order__c = :WO.Id
      ];

      List<PricingLineItem__c> allPricingRecords = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Color__c,
          Size__c,
          Estimated_Quantity__c,
          Retail_Price__c,
          Total__c,
          Margin__c,
          Show_To_Client__c,
          Estimate__c,
          Display__c,
          Default__c,
          Credit_Available__c
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :oppLineItems
      ];

      List<ExtraChargesEstimate__c> extraCharges = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Charge_Type__c,
          Display__c,
          Duty_Percentage__c,
          Is_Associated_With_Artwork__c,
          Margin__c,
          Net_Cost__c,
          OpportunityLineItem_ArtWork__c,
          Quantity__c,
          Retail_Price__c,
          Title__c,
          Total__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :oppLineItems
      ];

      Decimal total = 0;
      Decimal extraChargesTotal = 0;
      for (OpportunityLineItem__c LineItem : oppLineItems) {
        for (PricingLineItem__c Pricing : allPricingRecords) {
          // Code to compute total price of the Items related to OppLineItems
          if (
            Pricing.OpportunityLineItem__c == LineItem.Id &&
            Pricing.Display__c == true &&
            Pricing.Default__c == false
          ) {
            if (
              Pricing.Estimated_Quantity__c == null ||
              Pricing.Retail_Price__c == null
            ) {
              Total += 0;
            } else {
              total += (Pricing.Estimated_Quantity__c *
              Pricing.Retail_Price__c);
            }
          }
        }
        for (ExtraChargesEstimate__c extraPricing : extraCharges) {
          // Code to compute extra charges for each object
          if (extraPricing.OpportunityLineItem__c == LineItem.Id) {
            if (
              extraPricing.Quantity__c == null ||
              extraPricing.Retail_Price__c == null
            ) {
              extraChargesTotal += 0;
            } else {
              extraChargesTotal += (extraPricing.Quantity__c *
              extraPricing.Retail_Price__c);
            }
          }
        }
      }

      WO.Invoice_Total__c = total + extraChargesTotal;
      WO.Invoice_Value__c = WO.Invoice_Total__c;
      WO.Order_Amount__c = WO.Invoice_Total__c;
      update WO;
      //APICRUD
      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Order ->>' + ex.getMessage());
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
          OpportunityLineItem__r.Work_Order__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem_ArtWork__c = :recId
      ];
      Id workOrderId = extraChargesOfArtwork[0]
        .OpportunityLineItem__r.Work_Order__c;
      delete extraChargesOfArtwork;
      delete artwork;
      updateWorkOrder(workOrderId);
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
          Default__c,
          OpportunityLineItem__r.Work_Order__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :recId
      ];
      Id workOrderId = extraChargesRecord[0]
        .OpportunityLineItem__r.Work_Order__c;
      delete extraChargesRecord;
      updateWorkOrder(workOrderId);
      return true;
    } catch (Exception ex) {
      System.debug('Exception in deleting Warning->>>>>>>>>' + Ex.getMessage());
      return false;
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
        extraCharge.Display__c = 'Display To Client';
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
}
