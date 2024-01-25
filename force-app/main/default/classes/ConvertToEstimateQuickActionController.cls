public with sharing class ConvertToEstimateQuickActionController {
  @AuraEnabled
  public static void makeAccountPrimaryForSyncing(
    String recid,
    String selectedAccount
  ) {
    Opportunity opp = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :recid
    ];

    List<QBO_Details__c> qboDetails = [
      SELECT Id, QBO_Account__c, IsPrimary__c, Account__c
      FROM QBO_Details__c
      WHERE Account__c = :opp.AccountId AND QBO_Account__c = :selectedAccount
    ];
    if (qboDetails != null && qboDetails.size() > 0) {
      qboDetails[0].IsPrimary__c = true;
      update qboDetails;
    }
  }
  @AuraEnabled
  public static List<String> getAccountDropDown(String recId) {
    Opportunity opp;
    List<QBO_Details__c> qboDetails;
    List<String> accountNames;

    opp = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :recId
    ];

    qboDetails = [
      SELECT Id, QBO_Account__c, Id_Type__c, IsPrimary__c, Account__c
      FROM QBO_Details__c
      WHERE Account__c = :opp.AccountId AND Id_Type__c = 'Account'
    ];
    accountNames = new List<String>();
    for (QBO_Details__c qbo : qboDetails) {
      accountNames.add(qbo.QBO_Account__c);
    }

    return accountNames;
  }

  @AuraEnabled
  public static Boolean convertToEstimateInDb(
    String recid,
    String valuesAndIds,
    String selectedAccount
  ) {
    try {
      List<Estimate__c> estimateList = [
        SELECT id, Opportunity__c, Opportunity__r.Margin__c
        FROM Estimate__c
        WHERE Opportunity__c = :recId
      ];
      Decimal oppMargin = [SELECT Margin__c FROM Opportunity WHERE Id = :recId]
      .Margin__c;
      if (estimateList.size() == 0) {
        Estimate__c estimate = new Estimate__c();
        estimate.Opportunity__c = recId;
        estimate.Status__c = 'Converted';
        estimate.In_Hands_Date__c = system.today();
        estimate.Selected_Quickbook_Instance__c = selectedAccount;
        estimate.Terms__c = 'Credit Card';
        if (valuesAndIds == null) {
          insert estimate;
          Opportunity updatedOpp = [
            SELECT Id, Estimate_Number_For_Template__c
            FROM Opportunity
            WHERE Id = :recId
          ];
          updatedOpp.Estimate_Number_For_Template__c = estimate.Name;
          updatedOpp.StageName = 'Estimate';
          updatedOpp.Estimate_Change_Status__c = 'not changed from picklist';
          update updatedOpp;
          return true;
        }
        Map<Id, Decimal> opportunityQuantityMap = new Map<Id, Decimal>();
        List<Id> listOfIds = new List<Id>();
        List<convertToEstimateObject> convertToEstimateLit = (List<convertToEstimateObject>) System.JSON.deserializeStrict(
          valuesAndIds,
          List<convertToEstimateObject>.class
        );

        for (convertToEstimateObject obj : convertToEstimateLit) {
          listOfIds.add(obj.recordId);
        }

        for (convertToEstimateObject obj : convertToEstimateLit) {
          opportunityQuantityMap.put(obj.recordId, Integer.ValueOf(obj.value));
        }

        List<OpportunityLineItem__c> oppLineItemsToBeAddedEstimateUnsorted = [
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
            Product__r.Design_Project__c,
            Product__r.Name,
            Product__r.Product_Supplier_Code__c,
            Quantity_Estimate__c,
            CreatedDate,
            Sorting_Date__c,
            qbo_product_service_id__c
          FROM OpportunityLineItem__c
          WHERE Id = :listOfIds
          ORDER BY Sorting_Date__c ASC
        ];
        List<OpportunityLineItem__c> opportunityLineItemCloneList = new List<OpportunityLineItem__c>();
        List<Id> opportunityLineItemCloneListIds = new List<Id>();

        //  estimate.QB_Update__c = true;
        insert estimate;

        //New Sorting Logic Start
        List<OpportunityLineItem__c> sortedtesOpportunityLineItems = new List<OpportunityLineItem__c>();

        Integer i;
        Integer j;
        for (i = 0; i < oppLineItemsToBeAddedEstimateUnsorted.size(); i++) {
          sortedtesOpportunityLineItems.add(
            oppLineItemsToBeAddedEstimateUnsorted[i]
          );
          for (
            j = oppLineItemsToBeAddedEstimateUnsorted.size() - 1; j > i; j--
          ) {
            if (
              sortedtesOpportunityLineItems[
                  sortedtesOpportunityLineItems.size() - 1
                ]
                .Product__r.Name ==
              oppLineItemsToBeAddedEstimateUnsorted[j].Product__r.Name
            ) {
              sortedtesOpportunityLineItems.add(
                oppLineItemsToBeAddedEstimateUnsorted[j]
              );
              oppLineItemsToBeAddedEstimateUnsorted.remove(j);
            }
          }
        }
        //New Sorting Logic End

        List<OpportunityLineItem__c> oppLineItemsToBeAddedEstimate = new List<OpportunityLineItem__c>();
        oppLineItemsToBeAddedEstimate = sortedtesOpportunityLineItems;

        Opportunity opptoUpdate = [
          SELECT Id, Estimate_Number_For_Template__c
          FROM Opportunity
          WHERE Id = :recId
        ];
        opptoUpdate.Estimate_Number_For_Template__c = estimate.Name;
        opptoUpdate.StageName = 'Estimate';
        opptoUpdate.Estimate_Change_Status__c = 'not changed from picklist';
        update opptoUpdate;

        //map to track the clone opportunityLineItem
        //will be used in making clone of related object

        Map<Id, OpportunityLineItem__c> map_oppLineItem_clonedOppLineItem = new Map<Id, OpportunityLineItem__c>();
        Map<Id, Id> map_clonedoppLineItem_OppLineItem = new Map<Id, Id>();
        List<String> asiNumbers = new List<String>();
        //replicate oppo line items for estimate stage
        for (
          OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
        ) {
          OpportunityLineItem__c newOpp = new OpportunityLineItem__c();
          newOpp = oppLineItem.clone();
          newOpp.qbo_product_service_id__c = oppLineItem.qbo_product_service_id__c;
          newOpp.Name = oppLineItem.Name;
          newOpp.Sorting_Date__c = oppLineItem.Sorting_Date__c;
          newOpp.Private_Notes__c = oppLineItem.Private_Notes__c;
          newOpp.SKU__c = oppLineItem.SKU__c;
          newOpp.Imprint_Information__c = oppLineItem.Imprint_Information__c;
          newOpp.Supplier__c = oppLineItem.Supplier__c;
          newOpp.Imprint_Methods__c = oppLineItem.Imprint_Methods__c;
          newOpp.Description__c = oppLineItem.Description__c;
          newOpp.Additional_Colors__c = oppLineItem.Additional_Colors__c;
          newOpp.Additional_Locations__c = oppLineItem.Additional_Locations__c;
          newOpp.Quantity_Estimate__c = opportunityQuantityMap.get(
            oppLineItem.Id
          );
          newOpp.Estimate__c = estimate.Id;
          newOpp.Product__r.Product_Supplier_Code__c = oppLineItem.Product__r.Product_Supplier_Code__c;
          newOpp.Opportunity__c = null;
          opportunityLineItemCloneList.add(newOpp);
          map_oppLineItem_clonedOppLineItem.put(oppLineItem.Id, newOpp);

          asiNumbers.add(oppLineItem.Product__r.Product_Supplier_Code__c);
        }
        List<Account> vendorAccs = [
          SELECT id, ASI_Number__c, Primary_Category__c
          FROM Account
          WHERE ASI_Number__c IN :asiNumbers
        ];
        for (Account vendorAccount : vendorAccs) {
          for (OpportunityLineItem__c lineItem : opportunityLineItemCloneList) {
            if (
              vendorAccount.ASI_Number__c ==
              lineItem.Product__r.Product_Supplier_Code__c
            ) {
              String primaryCat = vendorAccount.Primary_Category__c;
              Integer productServiceId = Integer.valueOf(
                System.Label.QBO_Promotional_Product_Service_Id
              );

              if (primaryCat == 'Apparel') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance('Apparel')
                    .qbo_product_service_id__c
                );
              } else if (primaryCat == 'Decorator') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance('Decorator')
                    .qbo_product_service_id__c
                );
              } else if (primaryCat == 'Promotional Products') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance(
                      'Promotional_Products'
                    )
                    .qbo_product_service_id__c
                );
              } else if (primaryCat == 'Trade Show & Signage') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance('Trade_Show_Signage')
                    .qbo_product_service_id__c
                );
              } else if (primaryCat == 'Design Services') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance('Design_Services')
                    .qbo_product_service_id__c
                );
              } else if (primaryCat == 'Fulfillment') {
                productServiceId = Integer.valueOf(
                  QBO_Product_Service_Id__mdt.getInstance('Fulfillment')
                    .qbo_product_service_id__c
                );
              }

              lineItem.Account__c = vendorAccount.Id;
              lineItem.qbo_product_service_id__c = productServiceId;
            }
          }
        }
        insert opportunityLineItemCloneList;

        List<String> availableAccs = new List<String>();

        for (Account acc : vendorAccs) {
          availableAccs.add(acc.ASI_Number__c);
        }
        String oppLineItemIds = '';
        for (
          OpportunityLineItem__c oppLineItem : opportunityLineItemCloneList
        ) {
          if (
            oppLineItem.Product__r.CommonSku_Id__c != null &&
            !availableAccs.contains(
              oppLineItem.Product__r.Product_Supplier_Code__c
            )
          ) {
            oppLineItem.qbo_product_service_id__c = Integer.valueOf(
              QBO_Product_Service_Id__mdt.getInstance('Promotional_Products')
                .qbo_product_service_id__c
            );
            if (!oppLineItemIds.contains(oppLineItem.id)) {
              oppLineItemIds = oppLineItemIds + '\'' + oppLineItem.id + '\'';
              if (
                oppLineItem.id !=
                opportunityLineItemCloneList.get(
                    opportunityLineItemCloneList.size() - 1
                  )
                  .id
              )
                oppLineItemIds = oppLineItemIds + ',';
            }
          }
        }
        update opportunityLineItemCloneList;

        if (oppLineItemIds != '') {
          if (oppLineItemIds.endsWith(',')) {
            oppLineItemIds = oppLineItemIds.substring(
              0,
              oppLineItemIds.length() - 1
            );
            Database.executeBatch(new BatchForVendorAccounts(oppLineItemIds));
          } else {
            Database.executeBatch(new BatchForVendorAccounts(oppLineItemIds));
          }
        }
        for (
          OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
        ) {
          OpportunityLineItem__c opportunityLineItem = map_oppLineItem_clonedOppLineItem.get(
            oppLineItem.Id
          );
          map_clonedoppLineItem_OppLineItem.put(
            opportunityLineItem.Id,
            oppLineItem.Id
          );
        }

        List<OpportunityLineItem__c> oppLineItemsCloned = [
          SELECT
            Id,
            Name,
            Estimate__c,
            IsProductExists__c,
            Variant_Id__c,
            ESPId__c,
            Imprint_Information__c,
            Currency__c,
            Private_Notes__c,
            Price_Label__c,
            SKU__c,
            Product__c,
            Quantity_Estimate__c
          FROM OpportunityLineItem__c
          WHERE Id = :opportunityLineItemCloneList
          ORDER BY CreatedDate DESC
        ];

        List<PricingLineItem__c> allPricingRecords = [
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
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
          ORDER BY Quantity__c ASC
        ];

        Map<Id, List<PricingLineItem__c>> OpporLineItemAndPricingListMap = new Map<Id, List<PricingLineItem__c>>();
        List<PricingLineItem__c> pricingRecordListToBeUsedInEstimate = new List<PricingLineItem__c>();

        //making clone of related objects as well like colors sizes pricing etc

        List<ColorLineItem__c> colorsList = [
          SELECT
            Id,
            Name,
            Color__c,
            OpportunityLineItem__c,
            isFromProduct__c,
            isSelected__c,
            Estimate__c
          FROM ColorLineItem__c
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
        ];

        Map<Id, List<ColorLineItem__c>> OpporLineItemAndColorsListMap = new Map<Id, List<ColorLineItem__c>>();

        if (colorsList != null && colorsList.size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<ColorLineItem__c> colorsRelatedToOpportunityLineItem = new List<ColorLineItem__c>();
            for (ColorLineItem__c color : colorsList) {
              if (color.OpportunityLineItem__c == oppLineItem.Id) {
                colorsRelatedToOpportunityLineItem.add(color);
              }
              OpporLineItemAndColorsListMap.put(
                oppLineItem.Id,
                colorsRelatedToOpportunityLineItem
              );
            }
          }
        }

        List<SizeLineItem__c> sizesList = [
          SELECT
            Id,
            OpportunityLineItem__c,
            Size__c,
            isSelected__c,
            isFromProduct__c,
            Estimate__c,
            Name
          FROM SizeLineItem__c
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
        ];
        Map<Id, List<SizeLineItem__c>> OpporLineItemAndSizesListMap = new Map<Id, List<SizeLineItem__c>>();

        if (sizesList != null && sizesList.size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<SizeLineItem__c> SizesRelatedToOpportunityLineItem = new List<SizeLineItem__c>();
            for (SizeLineItem__c size : sizesList) {
              if (size.OpportunityLineItem__c == oppLineItem.Id) {
                sizesRelatedToOpportunityLineItem.add(size);
              }
              OpporLineItemAndSizesListMap.put(
                oppLineItem.Id,
                sizesRelatedToOpportunityLineItem
              );
            }
          }
        }
        Integer pricePosition;
        pricePosition = 0;
        Map<Id, Integer> pricePositionMap = new Map<Id, Integer>();

        if (allPricingRecords != null && allPricingRecords.Size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<PricingLineItem__c> pricingList = new List<PricingLineItem__c>();
            List<ColorLineItem__c> colorsToBeClonedinPricing = new List<ColorLineItem__c>();
            colorsToBeClonedinPricing = OpporLineItemAndColorsListMap.get(
              oppLineItem.Id
            );
            String colorForPricing = null;
            if (
              colorsToBeClonedinPricing != null &&
              colorsToBeClonedinPricing.size() == 1 &&
              colorsToBeClonedinPricing[0].Color__c != null &&
              !(String.isEmpty(colorsToBeClonedinPricing[0].Color__c))
            ) {
              colorForPricing = colorsToBeClonedinPricing[0].Color__c;
            }
            List<SizeLineItem__c> sizesToBeClonedinPricing = new List<SizeLineItem__c>();
            sizesToBeClonedinPricing = OpporLineItemAndSizesListMap.get(
              oppLineItem.Id
            );
            String sizeForPricing = null;
            if (
              sizesToBeClonedinPricing != null &&
              sizesToBeClonedinPricing.size() == 1 &&
              sizesToBeClonedinPricing[0].Size__c != null &&
              !(String.isEmpty(sizesToBeClonedinPricing[0].Size__c))
            ) {
              sizeForPricing = sizesToBeClonedinPricing[0].Size__c;
            }

            for (PricingLineItem__c priceRecord : allPricingRecords) {
              if (priceRecord.OpportunityLineItem__c == oppLineItem.Id) {
                pricingList.add(priceRecord);
              }
            }

            if (pricingList != null && pricingList.Size() > 0) {
              Double previousPriceQauntity;
              Double previousNetCost;
              Double previousMargin;
              Double previousRetailPrice;
              Double previousPricePerUnit;
              Double priceMargin;
              Decimal estimatedQuantity;
              Integer count;

              pricePosition = 0;
              previousPriceQauntity = 0;
              previousNetCost = 0;
              previousMargin = 0;
              previousRetailPrice = 0;
              previousPricePerUnit = 0;
              priceMargin = 0;
              estimatedQuantity = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Quantity_Estimate__c;
              count = 0;
              for (PricingLineItem__c priceRecord : pricingList) {
                count++;
                {
                  if (
                    estimatedQuantity < priceRecord.Quantity__c ||
                    estimatedQuantity == priceRecord.Quantity__c
                  ) {
                    if (
                      estimatedQuantity < priceRecord.Quantity__c &&
                      count > 1
                    ) {
                      break;
                    } else if (
                      estimatedQuantity < priceRecord.Quantity__c &&
                      count == 1
                    ) {
                      pricePosition++;
                      priceMargin = priceRecord.Margin__c;
                      previousMargin = priceRecord.Margin__c;
                      previousPriceQauntity = priceRecord.Quantity__c;
                      previousNetCost = priceRecord.Net_Cost__c;
                      previousRetailPrice = priceRecord.Retail_Price__c;
                      previousPricePerUnit = priceRecord.Price_Per_Unit__c;
                      break;
                    }

                    if (count == pricePosition + 1) {
                      pricePosition++;
                      priceMargin = priceRecord.Margin__c;
                      previousMargin = priceRecord.Margin__c;
                      previousPriceQauntity = priceRecord.Quantity__c;
                      previousNetCost = priceRecord.Net_Cost__c;
                      previousRetailPrice = priceRecord.Retail_Price__c;
                      previousPricePerUnit = priceRecord.Price_Per_Unit__c;
                      break;
                    }
                  } else {
                    pricePosition++;
                    priceMargin = priceRecord.Margin__c;
                    previousMargin = priceRecord.Margin__c;
                    previousPriceQauntity = priceRecord.Quantity__c;
                    previousNetCost = priceRecord.Net_Cost__c;
                    previousRetailPrice = priceRecord.Retail_Price__c;
                    previousPricePerUnit = priceRecord.Price_Per_Unit__c;
                  }
                }
              }
              System.debug('---previousRetailPrice----' + previousRetailPrice);
              System.debug(
                '---previousPricePerUnit----' + previousPricePerUnit
              );
              //we will use price per unit value instaed of Retail Price
              previousRetailPrice = previousPricePerUnit;
              pricePositionMap.put(
                map_oppLineItem_clonedOppLineItem.get(oppLineItem.Id).id,
                pricePosition
              );
              PricingLineItem__c newRecord = new PricingLineItem__c();
              newRecord.Estimated_Quantity__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Quantity_Estimate__c;
              newRecord.Margin__c = previousMargin;
              newRecord.Quantity__c = previousPriceQauntity;
              newRecord.Net_Cost__c = previousNetCost;
              newRecord.Retail_Price__c = previousRetailPrice;
              if (oppMargin != null && oppMargin != 0) {
                newRecord.Margin__c = oppMargin;
                decimal marginCalculation = 1 - (newRecord.Margin__c / 100);
                newRecord.Retail_Price__c =
                  newRecord.Net_Cost__c /
                  (marginCalculation != 0 ? marginCalculation : 1);
                newRecord.Retail_Price__c = newRecord.Retail_Price__c.setScale(
                  2
                );
                newRecord.Total__c =
                  newRecord.Estimated_Quantity__c * newRecord.Retail_Price__c;
                newRecord.Total__c = newRecord.Total__c.setScale(2);
              }

              if (!(String.isEmpty(colorForPricing))) {
                newRecord.Color__c = colorForPricing;
              }
              if (!(String.isEmpty(sizeForPricing))) {
                newRecord.Size__c = sizeForPricing;
              }
              newRecord.Total__c =
                newRecord.Estimated_Quantity__c *
                ((previousRetailPrice == null ? 0 : previousRetailPrice));
              newRecord.OpportunityLineItem__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Id;
              newRecord.Estimate__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Estimate__c;
              newRecord.Display__c = true;
              newRecord.Default__c = false;
              pricingRecordListToBeUsedInEstimate.add(newRecord);

              PricingLineItem__c newDefaultRecordToUseInEdit = new PricingLineItem__c();
              newDefaultRecordToUseInEdit.Estimated_Quantity__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Quantity_Estimate__c;
              newDefaultRecordToUseInEdit.Margin__c = previousMargin;
              newDefaultRecordToUseInEdit.Quantity__c = previousPriceQauntity;
              newDefaultRecordToUseInEdit.Net_Cost__c = previousNetCost;
              newDefaultRecordToUseInEdit.Retail_Price__c = previousRetailPrice;
              if (!(String.isEmpty(colorForPricing))) {
                newDefaultRecordToUseInEdit.Color__c = colorForPricing;
              }
              if (!(String.isEmpty(sizeForPricing))) {
                newDefaultRecordToUseInEdit.Size__c = sizeForPricing;
              }
              newDefaultRecordToUseInEdit.Total__c =
                newDefaultRecordToUseInEdit.Estimated_Quantity__c *
                ((previousRetailPrice == null ? 0 : previousRetailPrice));
              newDefaultRecordToUseInEdit.OpportunityLineItem__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Id;
              newDefaultRecordToUseInEdit.Estimate__c = map_oppLineItem_clonedOppLineItem.get(
                  oppLineItem.Id
                )
                .Estimate__c;
              newDefaultRecordToUseInEdit.Display__c = true;
              newDefaultRecordToUseInEdit.Default__c = true;
              pricingRecordListToBeUsedInEstimate.add(
                newDefaultRecordToUseInEdit
              );
            }

            OpporLineItemAndPricingListMap.put(oppLineItem.Id, pricingList);
          }
        }

        estimate.pricingPositionForExtraCharges__c = pricePosition;

        update estimate;
        insert pricingRecordListToBeUsedInEstimate;

        //copy all the attachments  of opportunity Line Items
        List<OpportunityLineItemAttachment__c> listOfAttachmentRecords = [
          SELECT Id, Name, Estimate__c, OpportunityLineItem__c
          FROM OpportunityLineItemAttachment__c
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
          ORDER BY CreatedDate DESC
        ];

        List<Id> attachmentIdsOlds = new List<Id>();

        List<OpportunityLineItemAttachment__c> newClonedAttachments = new List<OpportunityLineItemAttachment__c>();
        Map<Id, OpportunityLineItemAttachment__c> oldAttachment_newAttachment_map = new Map<Id, OpportunityLineItemAttachment__c>();

        Map<Id, OpportunityLineItemAttachment__c> opporLineItemAndAttachmentMap = new Map<Id, OpportunityLineItemAttachment__c>();
        if (
          oppLineItemsToBeAddedEstimate != null &&
          oppLineItemsToBeAddedEstimate.Size() > 0
        ) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            for (
              OpportunityLineItemAttachment__c attachment : listOfAttachmentRecords
            ) {
              if (attachment.OpportunityLineItem__c == oppLineItem.Id) {
                OpportunityLineItemAttachment__c clonedAttachment = attachment.Clone();
                clonedAttachment.OpportunityLineItem__c = map_oppLineItem_clonedOppLineItem.get(
                    oppLineItem.Id
                  )
                  .Id;
                newClonedAttachments.add(clonedAttachment);
                oldAttachment_newAttachment_map.put(
                  attachment.Id,
                  clonedAttachment
                );
                attachmentIdsOlds.add(attachment.Id);
                opporLineItemAndAttachmentMap.put(oppLineItem.Id, attachment);
              }
            }
          }
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
        }
        insert imagesToBeInserted;

        //we'll make a map of opportunityLineItems and artworks
        //one map of each artwork and related fixed charges
        //one map of each artwork and related run charges

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
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
          ORDER BY CreatedDate ASC
        ];

        Map<Id, List<OpportunityLineItem_ArtWork__c>> OpporLineItemAndArtworksListMap = new Map<Id, List<OpportunityLineItem_ArtWork__c>>();

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

        if (opportunityLineItemArtworkList.Size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<OpportunityLineItem_ArtWork__c> artworksRelatedToOpportunityLineItem = new List<OpportunityLineItem_ArtWork__c>();
            for (
              OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
            ) {
              if (artwork.OpportunityLineItem__c == oppLineItem.Id) {
                artworksRelatedToOpportunityLineItem.add(artwork);
              }
            }
            OpporLineItemAndArtworksListMap.put(
              oppLineItem.Id,
              artworksRelatedToOpportunityLineItem
            );
          }
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
              artworkAndRunChargesMap.put(
                artwork.Id,
                runChargesRelatedToArtwork
              );
            }
          }
        }

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
            AND OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
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
            AND OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
        ];
        Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>> opportunityLineItemAndFixChargesMap = new Map<Id, List<OpportunityLineItem_Add_Fixed_Charge__c>>();
        Map<Id, List<Line_Item_Pricing_RunCharge__c>> opportunityLineItemAndRunChargesMap = new Map<Id, List<Line_Item_Pricing_RunCharge__c>>();

        if (fixedChargesOfOppLineItem.Size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesRelatedToOppLineItem = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
            for (
              OpportunityLineItem_Add_Fixed_Charge__c fixCharge : fixedChargesOfOppLineItem
            ) {
              if (fixCharge.OpportunityLineItem__c == oppLineItem.Id) {
                fixedChargesRelatedToOppLineItem.add(fixCharge);
              }
            }
            opportunityLineItemAndFixChargesMap.put(
              oppLineItem.Id,
              fixedChargesRelatedToOppLineItem
            );
          }
        }
        if (runChargesOfOppLineItem.Size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<Line_Item_Pricing_RunCharge__c> runChargesRelatedToOppLineItem = new List<Line_Item_Pricing_RunCharge__c>();

            for (
              Line_Item_Pricing_RunCharge__c runCharge : runChargesOfOppLineItem
            ) {
              if (runCharge.OpportunityLineItem__c == oppLineItem.Id) {
                runChargesRelatedToOppLineItem.add(runCharge);
              }
            }
            opportunityLineItemAndRunChargesMap.put(
              oppLineItem.Id,
              runChargesRelatedToOppLineItem
            );
          }
        }

        List<OpportunityLineItemAttachment__c> clonedOpoortunityLineItemAttachments = new List<OpportunityLineItemAttachment__c>();
        List<ColorLineItem__c> clonedColorsList = new List<ColorLineItem__c>();
        List<SizeLineItem__c> clonedSizeList = new List<SizeLineItem__c>();
        List<OpportunityLineItem_Add_Fixed_Charge__c> clonedFixedChargesList = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
        List<Line_Item_Pricing_RunCharge__c> clonedRunChargesList = new List<Line_Item_Pricing_RunCharge__c>();
        List<OpportunityLineItem_ArtWork__c> clonedArtWorksList = new List<OpportunityLineItem_ArtWork__c>();
        List<PricingLineItem__c> clonedPrcingList = new List<PricingLineItem__c>();

        for (
          OpportunityLineItem__c clonedOpportunityLineItem : oppLineItemsCloned
        ) {
          Id originalOpportunityLineItem = map_clonedoppLineItem_OppLineItem.get(
            clonedOpportunityLineItem.Id
          );

          List<PricingLineItem__c> pricingListToBeCloned = new List<PricingLineItem__c>();
          pricingListToBeCloned = OpporLineItemAndPricingListMap.get(
            originalOpportunityLineItem
          );
          List<ColorLineItem__c> colorsToBeCloned = new List<ColorLineItem__c>();
          colorsToBeCloned = OpporLineItemAndColorsListMap.get(
            originalOpportunityLineItem
          );
          String color = null;
          if (
            colorsToBeCloned != null &&
            colorsToBeCloned.size() == 1 &&
            colorsToBeCloned[0].Color__c != null &&
            !(String.isEmpty(colorsToBeCloned[0].Color__c))
          ) {
            color = colorsToBeCloned[0].Color__c;
          }
          if (
            pricingListToBeCloned != null &&
            pricingListToBeCloned.Size() > 0
          ) {
            for (PricingLineItem__c pricing : pricingListToBeCloned) {
              PricingLineItem__c clonedPricing = pricing.clone();
              if (color != null) {
                clonedPricing.Color__c = color;
              }
              if (oppMargin != null) {
                clonedPricing.Margin__c = oppMargin;
              }
              clonedPricing.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedPricing.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedPrcingList.add(clonedPricing);
            }
          }

          List<OpportunityLineItem_ArtWork__c> artworksToBeCloned = new List<OpportunityLineItem_ArtWork__c>();
          artworksToBeCloned = OpporLineItemAndArtworksListMap.get(
            originalOpportunityLineItem
          );
          if (artworksToBeCloned != null && artworksToBeCloned.Size() > 0) {
            for (OpportunityLineItem_ArtWork__c artwork : artworksToBeCloned) {
              OpportunityLineItem_ArtWork__c clonedArtwork = artwork.clone();
              clonedArtwork.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedArtwork.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedArtWorksList.add(clonedArtwork);
            }
          }
        }

        insert clonedArtWorksList;

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
          WHERE OpportunityLineItem__c = :oppLineItemsCloned
          ORDER BY CreatedDate DESC
        ];

        Map<Id, Id> oldArtworkId_newArtWork_Map = new Map<Id, Id>();
        Map<Id, OpportunityLineItem_ArtWork__c> newArtworkAndDetailsMap = new Map<Id, OpportunityLineItem_ArtWork__c>(
          [
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
            WHERE OpportunityLineItem__c = :oppLineItemsCloned
            ORDER BY CreatedDate DESC
          ]
        );
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

        //Artworks attachments  to be copied
        //
        //
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
              //  artworkAttachmentMap.put(attachment.LinkedEntityId,attachment);
              if (
                oldArtworkId_newArtWork_Map.get(attachment.LinkedEntityId) !=
                null
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

        //make clone of all the related objects

        for (
          OpportunityLineItem__c clonedOpportunityLineItem : oppLineItemsCloned
        ) {
          Id originalOpportunityLineItem = map_clonedoppLineItem_OppLineItem.get(
            clonedOpportunityLineItem.Id
          );

          OpportunityLineItemAttachment__c attachment = opporLineItemAndAttachmentMap.get(
            originalOpportunityLineItem
          );
          clonedOpoortunityLineItemAttachments.add(attachment);

          List<ColorLineItem__c> colorsToBeCloned = new List<ColorLineItem__c>();
          colorsToBeCloned = OpporLineItemAndColorsListMap.get(
            originalOpportunityLineItem
          );
          if (colorsToBeCloned != null && colorsToBeCloned.Size() > 0) {
            for (ColorLineItem__c color : colorsToBeCloned) {
              ColorLineItem__c clonedColor = color.clone();
              clonedColor.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedColor.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedColorsList.add(clonedColor);
            }
          }
          List<SizeLineItem__c> sizesToBeCloned = new List<SizeLineItem__c>();
          sizesToBeCloned = OpporLineItemAndSizesListMap.get(
            originalOpportunityLineItem
          );
          if (sizesToBeCloned != null && sizesToBeCloned.Size() > 0) {
            for (SizeLineItem__c size : sizesToBeCloned) {
              SizeLineItem__c clonedSize = size.clone();
              clonedSize.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedSize.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedSizeList.add(clonedSize);
            }
          }

          List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesToBeCloned = new List<OpportunityLineItem_Add_Fixed_Charge__c>();

          fixedChargesToBeCloned = opportunityLineItemAndFixChargesMap.get(
            originalOpportunityLineItem
          );

          if (
            fixedChargesToBeCloned != null &&
            fixedChargesToBeCloned.Size() > 0
          ) {
            for (
              OpportunityLineItem_Add_Fixed_Charge__c fixedCharge : fixedChargesToBeCloned
            ) {
              OpportunityLineItem_Add_Fixed_Charge__c clonedFixedCharge = fixedCharge.clone();
              clonedFixedCharge.Title__c = fixedCharge.Title__c;
              clonedFixedCharge.Is_Associated_With_Artwork_c__c = false;
              clonedFixedCharge.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedFixedCharge.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedFixedChargesList.add(clonedFixedCharge);
            }
          }
          List<Line_Item_Pricing_RunCharge__c> runChargesToBeCloned = new List<Line_Item_Pricing_RunCharge__c>();
          runChargesToBeCloned = opportunityLineItemAndRunChargesMap.get(
            originalOpportunityLineItem
          );
          if (runChargesToBeCloned != null && runChargesToBeCloned.Size() > 0) {
            for (
              Line_Item_Pricing_RunCharge__c runCharge : runChargesToBeCloned
            ) {
              Line_Item_Pricing_RunCharge__c clonedRunCharge = runCharge.clone();
              clonedRunCharge.Title__c = runCharge.Title__c;
              clonedRunCharge.Estimate__c = clonedOpportunityLineItem.Estimate__c;
              clonedRunCharge.Is_Associated_With_Artwork__c = false;
              clonedRunCharge.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedRunChargesList.Add(clonedRunCharge);
            }
          }
        }
        //  opportunityLineItemArtworkListCloned
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
                clonedRunCharge.Title__c = runCharge.Title__c;
                clonedRunCharge.Estimate__c = estimate.Id;
                clonedRunCharge.OpportunityLineItem__c = newArtworkAndDetailsMap.get(
                    oldArtworkId_newArtWork_Map.get(artwork.Id)
                  )
                  .OpportunityLineItem__c;
                clonedRunCharge.Is_Associated_With_Artwork__c = true;
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
                clonedFixedCharge.Title__c = fixedCharge.Title__c;
                clonedFixedCharge.Estimate__c = estimate.Id;
                clonedFixedCharge.OpportunityLineItem__c = newArtworkAndDetailsMap.get(
                    oldArtworkId_newArtWork_Map.get(artwork.Id)
                  )
                  .OpportunityLineItem__c;
                clonedFixedCharge.Is_Associated_With_Artwork_c__c = true;
                clonedFixedCharge.OpportunityLineItem_ArtWork__c = oldArtworkId_newArtWork_Map.get(
                  artwork.Id
                );
                clonedFixedChargesList.add(clonedFixedCharge);
              }
            }
          }
        }
        insert clonedColorsList;
        insert clonedSizeList;
        insert clonedPrcingList;
        insert clonedFixedChargesList;
        insert clonedRunChargesList;
        createExtraChargeRecords(estimate, pricePositionMap, oppMargin);
        return true;
      } else {
        return false;
      }
    } catch (Exception ex) {
      System.debug(
        'Error in Convert To Estimate -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
      return null;
    }
  }

  @AuraEnabled
  public static void createExtraChargeRecords(
    Estimate__c estimate,
    Map<Id, Integer> pricePositionMap,
    Decimal oppMargin
  ) {
    try {
      List<Id> opportunityLineItemIdsList = new List<Id>();
      List<OpportunityLineItem__c> opportunityLineItemOfEstimates = [
        SELECT Id, Estimate__c, Quantity_Estimate__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :estimate.Id
      ];

      for (OpportunityLineItem__c opp : opportunityLineItemOfEstimates) {
        opportunityLineItemIdsList.add(opp.Id);
      }

      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfoppLineItems = [
        SELECT
          Id,
          Title__c,
          Cost__c,
          Margin__c,
          Retail_Price__c,
          OpportunityLineItem__c,
          Is_Associated_With_Artwork_c__c,
          OpportunityLineItem_ArtWork__c,
          EstimatedQuantity__c,
          Total__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE
          OpportunityLineItem__c = :opportunityLineItemIdsList
          AND Is_Associated_With_Artwork_c__c = FALSE
      ];
      List<Line_Item_Pricing_RunCharge__c> runChargesOfoppLineItems = [
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
          EstimatedQuantity__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE
          Is_Associated_With_Artwork__c = FALSE
          AND OpportunityLineItem__c = :opportunityLineItemIdsList
      ];

      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfArtworks = [
        SELECT
          Id,
          Title__c,
          Cost__c,
          OpportunityLineItem_ArtWork__c,
          Margin__c,
          Retail_Price__c,
          OpportunityLineItem__c,
          Is_Associated_With_Artwork_c__c,
          EstimatedQuantity__c,
          Total__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE
          OpportunityLineItem__c = :opportunityLineItemIdsList
          AND Is_Associated_With_Artwork_c__c = TRUE
      ];
      List<Line_Item_Pricing_RunCharge__c> runChargesOfArtworks = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Title__c,
          OpportunityLineItem_ArtWork__c,
          Is_Associated_With_Artwork__c,
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          EstimatedQuantity__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem__c = :opportunityLineItemIdsList
      ];

      List<PricingLineItem__c> defaultpricingRecords = [
        SELECT
          Id,
          OpportunityLineItem__c,
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
          OpportunityLineItem__c = :opportunityLineItemIdsList
          AND Default__c = TRUE
          AND Display__c = TRUE
      ];

      Map<Id, PricingLineItem__c> OpportunityLineItemPricingMap = new Map<Id, PricingLineItem__c>();

      if (defaultpricingRecords != null && defaultpricingRecords.size() > 0) {
        for (PricingLineItem__c pricing : defaultpricingRecords) {
          OpportunityLineItemPricingMap.put(
            pricing.OpportunityLineItem__c,
            pricing
          );
        }
      }
      List<ExtraChargesEstimate__c> estimateExtraCharges = new List<ExtraChargesEstimate__c>();
      if (
        fixedChargesOfoppLineItems != null &&
        fixedChargesOfoppLineItems.size() > 0
      ) {
        for (
          OpportunityLineItem_Add_Fixed_Charge__c fixCharge : fixedChargesOfoppLineItems
        ) {
          ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
          extraCharge.OpportunityLineItem__c = fixCharge.OpportunityLineItem__c;
          extraCharge.Charge_Type__c = 'AdditionalCost_FixedCharge';
          extraCharge.Is_Associated_With_Artwork__c = false;

          extraCharge.Margin__c = fixCharge.Margin__c;
          extraCharge.Net_Cost__c = fixCharge.Cost__c;
          extraCharge.Quantity__c = 1;
          extraCharge.Retail_Price__c = fixCharge.Retail_Price__c;
          extraCharge.Title__c = fixCharge.Title__c;
          extraCharge.Total__c = fixCharge.Retail_Price__c;

          if (oppMargin != null && oppMargin != 0) {
            extraCharge.Margin__c = oppMargin;
            decimal marginCalculation = 1 - (extraCharge.Margin__c / 100);
            extraCharge.Retail_Price__c =
              extraCharge.Net_Cost__c /
              (marginCalculation != 0 ? marginCalculation : 1);
            extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(
              2
            );
            extraCharge.Total__c =
              extraCharge.Quantity__c * extraCharge.Retail_Price__c;
            extraCharge.Total__c = extraCharge.Total__c.setScale(2);
          }
          estimateExtraCharges.add(extraCharge);
        }
      }
      if (
        runChargesOfoppLineItems != null &&
        runChargesOfoppLineItems.size() > 0
      ) {
        system.debug('Opp line item run charges not null: ');
        for (
          Line_Item_Pricing_RunCharge__c runCharge : runChargesOfoppLineItems
        ) {
          PricingLineItem__c pricingRecord = OpportunityLineItemPricingMap.get(
            runCharge.OpportunityLineItem__c
          );
          ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
          extraCharge.Title__c = runCharge.Title__c;
          extraCharge.Display__c = 'Include In Price';
          extraCharge.OpportunityLineItem__c = runCharge.OpportunityLineItem__c;
          extraCharge.Charge_Type__c = 'AdditionalCost_RunCharge';
          extraCharge.Is_Associated_With_Artwork__c = false;
          if (oppMargin != null) {
            extraCharge.Margin__c = oppMargin;
          } else {
            extraCharge.Margin__c = pricingRecord.Margin__c;
          }
          extraCharge.Retail_Price__c = pricingRecord.Retail_Price__c;
          extraCharge.Quantity__c = pricingRecord.Estimated_Quantity__c;
          extraCharge.Total__c =
            extraCharge.Quantity__c * extraCharge.Retail_Price__c;

          if (pricePositionMap.get(runCharge.OpportunityLineItem__c) == 1) {
            extraCharge.Net_Cost__c = runCharge.Value1__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 2
          ) {
            extraCharge.Net_Cost__c = runCharge.Value2__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 3
          ) {
            extraCharge.Net_Cost__c = runCharge.Value3__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 4
          ) {
            extraCharge.Net_Cost__c = runCharge.Value4__c;
          } else {
            extraCharge.Net_Cost__c = runCharge.Value5__c;
          }

          decimal marginCalculation = 1 - (extraCharge.Margin__c / 100);
          extraCharge.Retail_Price__c =
            (extraCharge.Net_Cost__c != null ? extraCharge.Net_Cost__c : 0) /
            marginCalculation;
          extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(2);
          extraCharge.Total__c =
            extraCharge.Quantity__c * extraCharge.Retail_Price__c;
          estimateExtraCharges.add(extraCharge);
        }
      }

      if (fixedChargesOfArtworks != null && fixedChargesOfArtworks.size() > 0) {
        for (
          OpportunityLineItem_Add_Fixed_Charge__c fixCharge : fixedChargesOfArtworks
        ) {
          ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
          extraCharge.OpportunityLineItem__c = fixCharge.OpportunityLineItem__c;
          extraCharge.Title__c = fixCharge.Title__c;
          extraCharge.Charge_Type__c = 'AdditionalCost_FixedCharge';
          extraCharge.Is_Associated_With_Artwork__c = true;
          extraCharge.OpportunityLineItem_ArtWork__c = fixCharge.OpportunityLineItem_ArtWork__c;

          extraCharge.Margin__c = fixCharge.Margin__c;
          extraCharge.Net_Cost__c = fixCharge.Cost__c;
          extraCharge.Quantity__c = 1;
          extraCharge.Retail_Price__c = fixCharge.Retail_Price__c;
          extraCharge.Title__c = fixCharge.Title__c;
          extraCharge.Total__c = fixCharge.Total__c;

          if (oppMargin != null && oppMargin != 0) {
            extraCharge.Margin__c = oppMargin;
            decimal marginCalculation = 1 - (extraCharge.Margin__c / 100);
            extraCharge.Retail_Price__c =
              extraCharge.Net_Cost__c /
              (marginCalculation != 0 ? marginCalculation : 1);
            extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(
              2
            );
            extraCharge.Total__c =
              extraCharge.Quantity__c * extraCharge.Retail_Price__c;
            extraCharge.Total__c = extraCharge.Total__c.setScale(2);
          }

          estimateExtraCharges.add(extraCharge);
        }
      }
      if (runChargesOfArtworks != null && runChargesOfArtworks.size() > 0) {
        for (Line_Item_Pricing_RunCharge__c runCharge : runChargesOfArtworks) {
          PricingLineItem__c pricingRecord = OpportunityLineItemPricingMap.get(
            runCharge.OpportunityLineItem__c
          );
          ExtraChargesEstimate__c extraCharge = new ExtraChargesEstimate__c();
          extraCharge.OpportunityLineItem__c = runCharge.OpportunityLineItem__c;
          extraCharge.Title__c = runCharge.Title__c;
          extraCharge.OpportunityLineItem_ArtWork__c = runCharge.OpportunityLineItem_ArtWork__c;
          extraCharge.Charge_Type__c = 'AdditionalCost_RunCharge';
          extraCharge.Is_Associated_With_Artwork__c = true;
          if (oppMargin != null && oppMargin != 0) {
            extraCharge.Margin__c = oppMargin;
          } else {
            extraCharge.Margin__c = pricingRecord.Margin__c;
          }
          extraCharge.Retail_Price__c = pricingRecord.Retail_Price__c;
          extraCharge.Quantity__c = pricingRecord.Estimated_Quantity__c;
          extraCharge.Total__c =
            extraCharge.Quantity__c * extraCharge.Retail_Price__c;
          ////////
          if (pricePositionMap.get(runCharge.OpportunityLineItem__c) == 1) {
            extraCharge.Net_Cost__c = runCharge.Value1__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 2
          ) {
            extraCharge.Net_Cost__c = runCharge.Value2__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 3
          ) {
            extraCharge.Net_Cost__c = runCharge.Value3__c;
          } else if (
            pricePositionMap.get(runCharge.OpportunityLineItem__c) == 4
          ) {
            extraCharge.Net_Cost__c = runCharge.Value4__c;
          } else {
            extraCharge.Net_Cost__c = runCharge.Value5__c;
          }

          decimal marginCalculation = 1 - (extraCharge.Margin__c / 100);
          extraCharge.Retail_Price__c =
            extraCharge.Net_Cost__c / marginCalculation;
          extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(2);
          extraCharge.Total__c =
            extraCharge.Quantity__c * extraCharge.Retail_Price__c;
          estimateExtraCharges.add(extraCharge);
        }
      }
      insert estimateExtraCharges;

      delete runChargesOfArtworks;
      delete fixedChargesOfoppLineItems;
      delete runChargesOfoppLineItems;
      delete fixedChargesOfArtworks;
    } catch (Exception Ex) {
      System.debug(
        'Exception in Adding Charges---->>>>>' +
          Ex.getMessage() +
          Ex.getStackTraceString()
      );
    }
  }

  @AuraEnabled
  public static List<EstimatePopupDetails> getRelatedOpportunityLineItems(
    Id recid
  ) {
    try {
      List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
      List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
        SELECT
          Id,
          Name,
          Description__c,
          Product__r.Id,
          Product__r.Name,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :recid
        ORDER BY Sorting_Date__c ASC
      ];

      //Sorting Logic
      List<OpportunityLineItem__c> relatedOpportunityLineItems = ProductsSorting.sortProducts(
        relatedOpportunityLineItemsUnsorted
      );
      //details of each opportunityLine item
      List<id> oppLineItemIds = new List<id>();
      for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
        EstimatePopupDetails details = new EstimatePopupDetails();
        details.oppLineItemId = oppLineItem.Id;
        details.productId = oppLineItem.Product__r.Id;
        details.productName = oppLineItem.name;
        details.sku = oppLineItem.SKU__c;
        oppLineItemIds.add(oppLineItem.Id);
        detailsToReturn.add(details);
      }

      //creation of map of OpportunityLineItemAttachtment and List of images to each attachment record

      List<OpportunityLineItemAttachment__c> oppLineItemAttachments = [
        SELECT OpportunityLineItem__c, Id
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :oppLineItemIds
      ];

      List<Id> attachmentRecordId = new List<Id>();
      for (
        OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
      ) {
        attachmentRecordId.add(attachment.Id);
      }

      List<ContentDocumentLink> documentIds = new List<ContentDocumentLink>();
      if (oppLineItemAttachments.size() > 0) {
        documentIds = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :attachmentRecordId
        ];
      }

      Map<id, List<ContentDocumentLink>> contentDocumentLinkMap = new Map<id, List<ContentDocumentLink>>();

      for (
        OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
      ) {
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        for (ContentDocumentLink document : documentIds) {
          if (attachment.Id == document.LinkedEntityId) {
            contentDocumentList.add(document);
          }
        }
        contentDocumentLinkMap.put(attachment.Id, contentDocumentList);
      }

      //fetching content version ids of content document id
      Map<Id, Id> mapContentLink_ContentVersion = new Map<id, id>();

      List<Id> lstContentDocumentIds = new List<Id>();
      for (ContentDocumentLink document : documentIds) {
        lstContentDocumentIds.add(document.ContentDocumentId);
      }

      List<ContentVersion> imageFiles = [
        SELECT id, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
      ];

      for (ContentVersion contentVersion : imageFiles) {
        mapContentLink_ContentVersion.put(
          contentVersion.ContentDocumentId,
          contentVersion.id
        );
      }

      //creation of map  of Opportunity Line Item and Opportunity Line Item attachment record

      Map<id, id> opprtunityLineItemToAttachmentRecordMap = new Map<id, id>();
      for (id opporLineItemId : oppLineItemIds) {
        for (
          OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
        ) {
          if (attachment.OpportunityLineItem__c == opporLineItemId) {
            opprtunityLineItemToAttachmentRecordMap.put(
              opporLineItemId,
              attachment.id
            );
          }
        }
      }

      integer index = 0;
      for (EstimatePopupDetails details : detailsToReturn) {
        List<ContentDocumentLink> attachments = new List<ContentDocumentLink>();
        attachments = contentDocumentLinkMap.get(
          opprtunityLineItemToAttachmentRecordMap.get(details.oppLineItemId)
        );
        if (attachments != null && attachments.size() > 0) {
          details.contentVerionId = mapContentLink_ContentVersion.get(
            attachments.get(index).ContentDocumentId
          );
          details.isContentDocumentExist = true;
        }
      }

      Map<id, List<PricingLineItem__c>> pricingMap = new Map<id, List<PricingLineItem__c>>();
      List<PricingLineItem__c> allPricings = [
        SELECT
          OpportunityLineItem__c,
          Price_Per_Unit__c,
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

      for (EstimatePopupDetails details : detailsToReturn) {
        details.pricingDetails = pricingMap.get(details.oppLineItemId);
        details.fixedCharges = fixedChargesMap.get(details.oppLineItemId);
      }
      return detailsToReturn;
    } catch (Exception Ex) {
      System.debug(
        'Exception in Convert To Estimate  ' +
          Ex.getMessage() +
          '+++++++ ' +
          Ex.getStackTraceString()
      );
      return null;
    }
  }

  public static List<EstimatePopupDetails> getRelatedOppLineItems(Id recid) {
    try {
      List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
      List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
        SELECT
          Id,
          Name,
          Description__c,
          Product__r.Id,
          Product__r.Name,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Opportunity__c = :recid
        ORDER BY Sorting_Date__c ASC
      ];

      //Sorting Logic
      List<OpportunityLineItem__c> relatedOpportunityLineItems = ProductsSorting.sortProducts(
        relatedOpportunityLineItemsUnsorted
      );
      //details of each opportunityLine item
      List<id> oppLineItemIds = new List<id>();
      for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
        EstimatePopupDetails details = new EstimatePopupDetails();
        details.oppLineItemId = oppLineItem.Id;
        details.productId = oppLineItem.Product__r.Id;
        details.productName = oppLineItem.name;
        details.sku = oppLineItem.SKU__c;
        oppLineItemIds.add(oppLineItem.Id);
        detailsToReturn.add(details);
      }

      //creation of map of OpportunityLineItemAttachtment and List of images to each attachment record

      List<OpportunityLineItemAttachment__c> oppLineItemAttachments = [
        SELECT OpportunityLineItem__c, Id
        FROM OpportunityLineItemAttachment__c
        WHERE OpportunityLineItem__c = :oppLineItemIds
      ];

      List<Id> attachmentRecordId = new List<Id>();
      for (
        OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
      ) {
        attachmentRecordId.add(attachment.Id);
      }

      List<ContentDocumentLink> documentIds = new List<ContentDocumentLink>();
      if (oppLineItemAttachments.size() > 0) {
        documentIds = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :attachmentRecordId
        ];
      }

      Map<id, List<ContentDocumentLink>> contentDocumentLinkMap = new Map<id, List<ContentDocumentLink>>();

      for (
        OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
      ) {
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        for (ContentDocumentLink document : documentIds) {
          if (attachment.Id == document.LinkedEntityId) {
            contentDocumentList.add(document);
          }
        }
        contentDocumentLinkMap.put(attachment.Id, contentDocumentList);
      }

      //fetching content version ids of content document id
      Map<Id, Id> mapContentLink_ContentVersion = new Map<id, id>();

      List<Id> lstContentDocumentIds = new List<Id>();
      for (ContentDocumentLink document : documentIds) {
        lstContentDocumentIds.add(document.ContentDocumentId);
      }

      List<ContentVersion> imageFiles = [
        SELECT id, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
      ];

      for (ContentVersion contentVersion : imageFiles) {
        mapContentLink_ContentVersion.put(
          contentVersion.ContentDocumentId,
          contentVersion.id
        );
      }

      //creation of map  of Opportunity Line Item and Opportunity Line Item attachment record

      Map<id, id> opprtunityLineItemToAttachmentRecordMap = new Map<id, id>();
      for (id opporLineItemId : oppLineItemIds) {
        for (
          OpportunityLineItemAttachment__c attachment : oppLineItemAttachments
        ) {
          if (attachment.OpportunityLineItem__c == opporLineItemId) {
            opprtunityLineItemToAttachmentRecordMap.put(
              opporLineItemId,
              attachment.id
            );
          }
        }
      }

      integer index = 0;
      for (EstimatePopupDetails details : detailsToReturn) {
        List<ContentDocumentLink> attachments = new List<ContentDocumentLink>();
        attachments = contentDocumentLinkMap.get(
          opprtunityLineItemToAttachmentRecordMap.get(details.oppLineItemId)
        );
        if (attachments != null && attachments.size() > 0) {
          details.contentVerionId = mapContentLink_ContentVersion.get(
            attachments.get(index).ContentDocumentId
          );
          details.isContentDocumentExist = true;
        }
      }

      Map<id, List<PricingLineItem__c>> pricingMap = new Map<id, List<PricingLineItem__c>>();
      List<PricingLineItem__c> allPricings = [
        SELECT
          OpportunityLineItem__c,
          Price_Per_Unit__c,
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

      for (EstimatePopupDetails details : detailsToReturn) {
        details.pricingDetails = pricingMap.get(details.oppLineItemId);
        details.fixedCharges = fixedChargesMap.get(details.oppLineItemId);
      }
      return detailsToReturn;
    } catch (Exception Ex) {
      System.debug(
        'Exception in Convert To Estimate  ' +
          Ex.getMessage() +
          '+++++++ ' +
          Ex.getStackTraceString()
      );
      return null;
    }
  }

  public static List<String> getAccountDD(String recId) {
    Opportunity opp;
    List<QBO_Details__c> qboDetails;
    List<String> accountNames;

    opp = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :recId
    ];

    qboDetails = [
      SELECT Id, QBO_Account__c, Id_Type__c, IsPrimary__c, Account__c
      FROM QBO_Details__c
      WHERE Account__c = :opp.AccountId AND Id_Type__c = 'Account'
    ];
    accountNames = new List<String>();
    for (QBO_Details__c qbo : qboDetails) {
      accountNames.add(qbo.QBO_Account__c);
    }

    return accountNames;
  }

  public static void makeAccountForSyncing(
    String recid,
    String selectedAccount
  ) {
    Boolean IsPrimary;
    Id AccountId;
    String QBO_Details;
    Opportunity opp = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :recid
    ];

    List<QBO_Details__c> qboDetails = [
      SELECT Id, QBO_Account__c, IsPrimary__c, Account__c
      FROM QBO_Details__c
      WHERE Account__c = :opp.AccountId AND QBO_Account__c = :selectedAccount
    ];

    IsPrimary = qboDetails[0].IsPrimary__c;
    AccountId = opp.AccountId;

    if (qboDetails != null && qboDetails.size() > 0) {
      IsPrimary = qboDetails[0].IsPrimary__c;
      AccountId = opp.AccountId;
      qboDetails[0].IsPrimary__c = true;

      update qboDetails;
    }
  }
}
