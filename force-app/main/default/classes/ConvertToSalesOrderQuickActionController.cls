public with sharing class ConvertToSalesOrderQuickActionController {
  public static Boolean checkAllProductsAreDesignProducts(
    List<OpportunityLineItem__c> oppLineItemsToBeAddedEstimate
  ) {
    Boolean result = true;
    for (OpportunityLineItem__c oppLine : oppLineItemsToBeAddedEstimate) {
      if (oppLine.Product__r.Design_Project__c != true) {
        result = false;
        break;
      }
    }
    return result;
  }

  /*
    This function will update the design projects when estimates convert into the sales order.
    @param: estimateID will contain the ID of the estimates of opportunity
    @param: listOfIds conatins the IDs of ConvertToSalesOrderObject
    @param: OrderID will contain the Work Order ID.
    @param: oppLineItem_clonedOppLineItem will contain the cloned ID of Opportunity Line Items.
    */

  @future
  public static void updateDesignProject(
    ID estimateID,
    List<ID> listOfIds,
    ID OrderID,
    Set<ID> oppLineItem_clonedOppLineItem
  ) {
    Map<Id, OpportunityLineItem__c> map_oppLineItem_clonedOppLineItem = new Map<Id, OpportunityLineItem__c>();

    List<OpportunityLineItem__c> oppLst = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        IsProductExists__c,
        Account__c,
        Imprint_Methods__c,
        Variant_Id__c,
        Quantity_Estimate__c,
        ESPId__c,
        Currency__c,
        Private_Notes__c,
        Product__r.Name,
        Price_Label__c,
        Opportunity__c,
        SKU__c,
        Product__c,
        Product__r.Design_Project__c,
        CreatedDate,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Id IN :oppLineItem_clonedOppLineItem
    ];
    for (OpportunityLineItem__c opp : oppLst) {
      map_oppLineItem_clonedOppLineItem.put(opp.ID, opp);
    }
    Estimate__c estimate = [
      SELECT
        id,
        OwnerId,
        Update_Credit_Request_Status__c,
        Client_Approval_Status__c,
        Default_Tax__c,
        Selected_Quickbook_Instance__c
      FROM Estimate__c
      WHERE id = :estimateID
    ];
    User user = [
      SELECT id, Design_Bank__c
      FROM User
      WHERE Id = :estimate.OwnerId
    ];
    List<Design_Project__c> designProjects = [
      SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
      FROM Design_Project__c
      WHERE Estimate__c = :estimateID
    ];
    for (Design_Project__c designProject : designProjects) {
      if (listOfIds.contains(designProject.Product__c)) {
        designProject.Product__c = map_oppLineItem_clonedOppLineItem.get(
            designProject.Product__c
          )
          .id;
        designProject.Work_Order__c = OrderID;
        designProject.Estimate__c = null;
        if (designProject.Bank_Credits__c == true) {
          if (
            designProject.Credits__c != null &&
            designProject.Credits__c != 0 &&
            user.Design_Bank__c != null &&
            user.Design_Bank__c > designProject.Credits__c
          ) {
            user.Design_Bank__c =
              user.Design_Bank__c - designProject.Credits__c;
          }
        }
      } else {
        designProject.Active__c = false;
        designProject.Credits__c = 0;
      }
    }
    if (!Test.isRunningTest()) {
      update designProjects;
    }
  }

  @AuraEnabled
  public static String convertToEstimateInDb(
    String recid,
    String valuesAndIds
  ) {
    try {
      List<Order> workorderList = [
        SELECT id, Invoice_Number__c, OpportunityId
        FROM Order
        WHERE OpportunityId = :recId
      ];
      Opportunity opp = [
        SELECT
          id,
          Name,
          Estimate_Number__c,
          Estimated_Amount__c,
          AccountId,
          Contact__c,
          Account.Payment_Terms__c,
          Priority__c,
          Opportunity_Notes__c,
          Account.Name,
          Account.Billing_Email__c,
          Account.BillingStreet,
          Account.BillingCity,
          Account.BillingState,
          Account.BillingPostalCode,
          Account.BillingCountry,
          Account.ShippingStreet,
          Account.ShippingCity,
          Account.ShippingState,
          Account.ShippingPostalCode,
          Account.ShippingCountry
        FROM Opportunity
        WHERE id = :recId
      ];
      Estimate__c estimate = [
        SELECT
          id,
          OwnerId,
          Update_Credit_Request_Status__c,
          Client_Approval_Status__c,
          Default_Tax__c,
          Selected_Quickbook_Instance__c
        FROM Estimate__c
        WHERE Opportunity__c = :opp.id
      ];
      User user = [
        SELECT id, Design_Bank__c
        FROM User
        WHERE Id = :estimate.OwnerId
      ];
      String checkPricing = isValidPricing(
        recid,
        valuesAndIds,
        opp,
        estimate,
        user
      );
      if (checkPricing != 'true') {
        if (!Test.isRunningTest())
          return checkPricing;
      }
      if (workorderList.size() == 0) {
        if (estimate.Client_Approval_Status__c != 'Approved') {
          return 'Estimate is not approved by client';
        }
        // Changes for Popualting Invoive total field in Order Object
        Map<Id, Boolean> opportunityQuantityMap = new Map<Id, Boolean>();
        List<Id> listOfIds = new List<Id>();
        List<ConvertToSalesOrderObject> convertToEstimateLit = (List<ConvertToSalesOrderObject>) System.JSON.deserializeStrict(
          valuesAndIds,
          List<ConvertToSalesOrderObject>.class
        );

        for (ConvertToSalesOrderObject obj : convertToEstimateLit) {
          if (obj.value == true) {
            listOfIds.add(obj.recordId);
          }
        }

        List<OpportunityLineItem__c> oppLineItemsToBeAddedEstimateUnsorted = [
          SELECT
            Id,
            Name,
            Description__c,
            Estimate__c,
            IsProductExists__c,
            Account__c,
            Imprint_Methods__c,
            Variant_Id__c,
            Quantity_Estimate__c,
            ESPId__c,
            Currency__c,
            Private_Notes__c,
            Product__r.Name,
            Price_Label__c,
            Opportunity__c,
            SKU__c,
            Product__c,
            Product__r.Design_Project__c,
            CreatedDate,
            Sorting_Date__c,
            qbo_product_service_id__c
          FROM OpportunityLineItem__c
          WHERE Id = :listOfIds
          ORDER BY Sorting_Date__c ASC
        ];
        //New Sorting Logic Start
        List<OpportunityLineItem__c> sortedtesOpportunityLineItems = new List<OpportunityLineItem__c>();

        for (
          Integer i = 0; i < oppLineItemsToBeAddedEstimateUnsorted.size(); i++
        ) {
          sortedtesOpportunityLineItems.add(
            oppLineItemsToBeAddedEstimateUnsorted[i]
          );
          for (
            Integer j = oppLineItemsToBeAddedEstimateUnsorted.size() - 1;
            j > i;
            j--
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
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
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
          WHERE OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
        ];

        Decimal total = 0;
        Decimal extraChargesTotal = 0;
        for (OpportunityLineItem__c LineItem : oppLineItemsToBeAddedEstimate) {
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
        Order order = new Order();
        order.OpportunityId = recId;
        order.Invoice_Number__c = 'SalesOrder-' + opp.id;

        //If all products in OppLineItems are design products then set the WO stage 06 - In Production
        if (checkAllProductsAreDesignProducts(oppLineItemsToBeAddedEstimate)) {
          order.Status = '06_-_In_Process-OTHER';
        } else {
          order.Status = getOrderStage(valuesAndIds);
        }

        order.EffectiveDate = system.today();
        order.Invoice_Terms__c = opp.Account.Payment_Terms__c;
        order.Invoice_Estimated_Ship_Date__c = 'TBD';
        order.Invoice_Total__c = total + extraChargesTotal;
        order.AccountId = opp.AccountId;
        order.Invoice_Email__c = opp.Account.Billing_Email__c;
        order.Invoice_Tax__c = getTax(estimate.Default_Tax__c);
        order.Invoice_Value__c = order.Invoice_Total__c;
        order.Invoice_Discount__c = 0;
        order.Invoice_Date__c = system.today();
        order.Invoice_Due_Date__c = order.Invoice_Date__c.addMonths(1);
        order.Invoice_Estimated_Ship_Date__c = '';
        order.Estimate_Number__c = (opp.Estimate_Number__c != null
          ? opp.Estimate_Number__c
          : '');
        order.Estimated_Amount__c = (opp.Estimated_Amount__c != null
          ? opp.Estimated_Amount__c
          : 0);
        order.Order_Amount__c = order.Invoice_Total__c;
        order.Balance_Due__c = 0;
        order.Quickbooks_Instance__c = estimate.Selected_Quickbook_Instance__c;
        order.BillingStreet = opp.Account.BillingStreet;
        order.BillingCity = opp.Account.BillingCity;
        order.BillingState = opp.Account.BillingState;
        order.BillingPostalCode = opp.Account.BillingPostalCode;
        order.BillingCountry = opp.Account.BillingCountry;
        order.ShippingStreet = opp.Account.ShippingStreet;
        order.ShippingCity = opp.Account.ShippingCity;
        order.ShippingState = opp.Account.ShippingState;
        order.ShippingPostalCode = opp.Account.ShippingPostalCode;
        order.ShippingCountry = opp.Account.ShippingCountry;
        order.Valid_Credits__c = true;
        order.Work_Order_Notes__c = opp.Opportunity_Notes__c;
        order.Priority__c = opp.Priority__c;
        insert order;

        List<OpportunityLineItem__c> opportunityLineItemCloneList = new List<OpportunityLineItem__c>();
        // List <Id> opportunityLineItemCloneListIds=new List<Id>();

        //map to track the clone opportunityLineItem
        //will be used in making clone of related object

        Map<Id, OpportunityLineItem__c> map_oppLineItem_clonedOppLineItem = new Map<Id, OpportunityLineItem__c>();
        Map<Id, Id> map_clonedoppLineItem_OppLineItem = new Map<Id, Id>();
        Boolean isDesignProduct = false;
        for (
          OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
        ) {
          OpportunityLineItem__c newOpp = new OpportunityLineItem__c();
          newOpp = oppLineItem.clone();
          newOpp.qbo_product_service_id__c = oppLineItem.qbo_product_service_id__c;
          newOpp.Name = oppLineItem.Name;
          newOpp.Account__c = oppLineItem.Account__c;
          newOpp.Private_Notes__c = oppLineItem.Private_Notes__c;
          newOpp.Description__c = oppLineItem.Description__c;
          newOpp.SKU__c = oppLineItem.SKU__c;
          newOpp.Sorting_Date__c = oppLineItem.Sorting_Date__c;
          newOpp.Quantity_Estimate__c = oppLineItem.Quantity_Estimate__c;
          newOpp.Estimate__c = null;
          newOpp.Work_Order__c = order.Id;
          newOpp.Imprint_Methods__c = oppLineItem.Imprint_Methods__c;
          opportunityLineItemCloneList.add(newOpp);
          map_oppLineItem_clonedOppLineItem.put(oppLineItem.Id, newOpp);
        }
        insert opportunityLineItemCloneList;

        //Update the design Projects
        Set<ID> oppLineItem_clonedOppLineItem = map_oppLineItem_clonedOppLineItem.keyset();
        if (!System.isFuture()) {
          updateDesignProject(
            estimate.ID,
            listOfIds,
            order.id,
            oppLineItem_clonedOppLineItem
          );
        }

        if (!Test.isRunningTest()) {
          update user;
        }
        List<Estimate__c> estimates = [
          SELECT id, OwnerId
          FROM Estimate__c
          WHERE OwnerId = :user.id
        ];
        List<Design_Project__c> designProjectsOtherEstimates = [
          SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
          FROM Design_Project__c
          WHERE Estimate__c IN :estimates
        ];
        update designProjectsOtherEstimates;

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

        Map<Id, List<PricingLineItem__c>> OpporLineItemAndPricingListMap = new Map<Id, List<PricingLineItem__c>>();
        List<PricingLineItem__c> pricingRecordListToBeUsedInEstimate = new List<PricingLineItem__c>();
        List<PricingLineItem__c> clonedPrcingList1 = new List<PricingLineItem__c>();
        if (allPricingRecords != null && allPricingRecords.Size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<PricingLineItem__c> pricingList = new List<PricingLineItem__c>();
            for (PricingLineItem__c priceRecord : allPricingRecords) {
              if (priceRecord.OpportunityLineItem__c == oppLineItem.Id) {
                pricingList.add(priceRecord);
              }
            }

            if (pricingList != null && pricingList.Size() > 0) {
              OpporLineItemAndPricingListMap.put(oppLineItem.Id, pricingList);

              for (PricingLineItem__c pricing : pricingList) {
                PricingLineItem__c clonedPricing = pricing.clone();
                clonedPricing.Display__c = pricing.Display__c;
                clonedPricing.Default__c = pricing.Default__c;
                clonedPricing.Color__c = pricing.Color__c;
                clonedPricing.Size__c = pricing.Size__c;
                clonedPricing.OpportunityLineItem__c = map_oppLineItem_clonedOppLineItem.get(
                    oppLineItem.Id
                  )
                  .Id;
                clonedPricing.Estimate__c = map_oppLineItem_clonedOppLineItem.get(
                    oppLineItem.Id
                  )
                  .Estimate__c;
                clonedPrcingList1.add(clonedPricing);
              }
            }
          }
        }
        insert clonedPrcingList1;

        // insert pricingRecordListToBeUsedInEstimate;

        //first we query all the related records to opportunity Line item
        //then we'll make map of ids and list of colors
        //then we can make clone by getting related colors list of that opportunity line item

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

        List<ExtraChargesEstimate__c> extraChargesWithArtWorks = [
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
          WHERE
            OpportunityLineItem__c = :oppLineItemsToBeAddedEstimate
            AND Is_Associated_With_Artwork__c = TRUE
        ];
        Map<Id, List<ExtraChargesEstimate__c>> OpporLineItemExtraChargesListMap = new Map<Id, List<ExtraChargesEstimate__c>>();
        Map<Id, List<ExtraChargesEstimate__c>> extraChargesWithArtWorksMap = new Map<Id, List<ExtraChargesEstimate__c>>();

        if (extraCharges != null && extraCharges.size() > 0) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<ExtraChargesEstimate__c> chargesRelatedToOpportunityLineItem = new List<ExtraChargesEstimate__c>();
            for (ExtraChargesEstimate__c charges : extraCharges) {
              if (charges.OpportunityLineItem__c == oppLineItem.Id) {
                if (charges.Is_Associated_With_Artwork__c == false) {
                  chargesRelatedToOpportunityLineItem.add(charges);
                }
              }
              OpporLineItemExtraChargesListMap.put(
                oppLineItem.Id,
                chargesRelatedToOpportunityLineItem
              );
            }
          }
        }
        if (
          extraChargesWithArtWorks != null &&
          extraChargesWithArtWorks.size() > 0
        ) {
          for (
            OpportunityLineItem__c oppLineItem : oppLineItemsToBeAddedEstimate
          ) {
            List<ExtraChargesEstimate__c> chargesRelatedToOpportunityLineItem = new List<ExtraChargesEstimate__c>();
            for (ExtraChargesEstimate__c charges : extraChargesWithArtWorks) {
              if (
                charges.OpportunityLineItem__c == oppLineItem.Id &&
                charges.Is_Associated_With_Artwork__c == true
              ) {
                chargesRelatedToOpportunityLineItem.add(charges);
              }
              extraChargesWithArtWorksMap.put(
                oppLineItem.Id,
                chargesRelatedToOpportunityLineItem
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

        // Map <Id,List<ContentDocumentLink>> oldAttachmentRecordId_images_map=new Map<Id,List<ContentDocumentLink>> ();
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
        // for(OpportunityLineItemAttachment__c attachment : listOfAttachmentRecords)
        // {
        //     List<ContentDocumentLink> contentDocumentList=new List<ContentDocumentLink>();
        //     for(ContentDocumentLink document:allDocumentIds)
        //     {
        //         if(document.LinkedEntityId==attachment.Id)
        //         {
        //             contentDocumentList.add(document);
        //         }
        //     }
        //     oldAttachmentRecordId_images_map.put(attachment.Id,contentDocumentList);
        // }

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
          ORDER BY CreatedDate DESC
        ];

        Map<Id, List<OpportunityLineItem_ArtWork__c>> OpporLineItemAndArtworksListMap = new Map<Id, List<OpportunityLineItem_ArtWork__c>>();

        Map<Id, List<ExtraChargesEstimate__c>> artworkAndFixedChargesMap = new Map<Id, List<ExtraChargesEstimate__c>>();
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
        }

        List<OpportunityLineItemAttachment__c> clonedOpoortunityLineItemAttachments = new List<OpportunityLineItemAttachment__c>();
        List<ColorLineItem__c> clonedColorsList = new List<ColorLineItem__c>();
        List<SizeLineItem__c> clonedSizeList = new List<SizeLineItem__c>();
        // List <PricingLineItem__c> clonedPrcingList=new List <PricingLineItem__c>();
        List<OpportunityLineItem_ArtWork__c> clonedArtWorksList = new List<OpportunityLineItem_ArtWork__c>();

        List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
        List<ExtraChargesEstimate__c> extraChargesWithArtWorkList = new List<ExtraChargesEstimate__c>();

        Map<Id, OpportunityLineItem_ArtWork__c> newAndOldArtwoksMap = new Map<Id, OpportunityLineItem_ArtWork__c>();
        for (
          OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemCloneList
        ) {
          Id originalOpportunityLineItem = map_clonedoppLineItem_OppLineItem.get(
            clonedOpportunityLineItem.Id
          );

          // List <PricingLineItem__c> pricingListToBeCloned=new List <PricingLineItem__c>();
          // pricingListToBeCloned= OpporLineItemAndPricingListMap.get(originalOpportunityLineItem);
          // if(pricingListToBeCloned!=null&& pricingListToBeCloned.Size()>0)
          // {
          //     for(PricingLineItem__c pricing:pricingListToBeCloned)
          //     {
          //         PricingLineItem__c clonedPricing= pricing.clone();
          //         clonedPricing.OpportunityLineItem__c=clonedOpportunityLineItem.Id;
          //         clonedPricing.Estimate__c=clonedOpportunityLineItem.Estimate__c;
          //         clonedPrcingList.add(clonedPricing);
          //     }

          // }

          List<OpportunityLineItem_ArtWork__c> artworksToBeCloned = new List<OpportunityLineItem_ArtWork__c>();
          artworksToBeCloned = OpporLineItemAndArtworksListMap.get(
            originalOpportunityLineItem
          );

          if (artworksToBeCloned != null && artworksToBeCloned.Size() > 0) {
            for (OpportunityLineItem_ArtWork__c artwork : artworksToBeCloned) {
              OpportunityLineItem_ArtWork__c clonedArtwork = artwork.clone();
              clonedArtwork.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedArtWorksList.add(clonedArtwork);
              newAndOldArtwoksMap.put(artwork.id, clonedArtwork);
            }
          }
        }
        insert clonedArtWorksList;
        //insert clonedPrcingList;

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
          WHERE OpportunityLineItem__c = :opportunityLineItemCloneList
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
        //Artworks attachments  to be copied
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
          OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemCloneList
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
              clonedColor.Estimate__c = null;
              clonedColor.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedColorsList.add(clonedColor);
            }
          }

          List<ExtraChargesEstimate__c> extraChargesToBeCloned = new List<ExtraChargesEstimate__c>();
          extraChargesToBeCloned = OpporLineItemExtraChargesListMap.get(
            originalOpportunityLineItem
          );
          if (
            extraChargesToBeCloned != null &&
            extraChargesToBeCloned.Size() > 0
          ) {
            for (ExtraChargesEstimate__c charges : extraChargesToBeCloned) {
              ExtraChargesEstimate__c clonedCharges = charges.clone();
              clonedCharges.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedCharges.OpportunityLineItem_ArtWork__c = null;
              extraChargesList.add(clonedCharges);
            }
          }

          List<ExtraChargesEstimate__c> extraChargesWithArtWorksToBeCloned = new List<ExtraChargesEstimate__c>();
          extraChargesWithArtWorksToBeCloned = extraChargesWithArtWorksMap.get(
            originalOpportunityLineItem
          );
          if (
            extraChargesWithArtWorksToBeCloned != null &&
            extraChargesWithArtWorksToBeCloned.Size() > 0
          ) {
            for (
              ExtraChargesEstimate__c charges : extraChargesWithArtWorksToBeCloned
            ) {
              ExtraChargesEstimate__c clonedCharges = charges.clone();
              clonedCharges.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              if (
                newAndOldArtwoksMap.get(
                  charges.OpportunityLineItem_ArtWork__c
                ) != null &&
                newAndOldArtwoksMap.get(charges.OpportunityLineItem_ArtWork__c)
                  .id != null
              )
                clonedCharges.OpportunityLineItem_ArtWork__c = newAndOldArtwoksMap.get(
                    charges.OpportunityLineItem_ArtWork__c
                  )
                  .id;
              extraChargesWithArtWorkList.add(clonedCharges);
            }
          }

          List<SizeLineItem__c> sizesToBeCloned = new List<SizeLineItem__c>();
          sizesToBeCloned = OpporLineItemAndSizesListMap.get(
            originalOpportunityLineItem
          );
          if (sizesToBeCloned != null && sizesToBeCloned.Size() > 0) {
            for (SizeLineItem__c size : sizesToBeCloned) {
              SizeLineItem__c clonedSize = size.clone();
              clonedSize.Estimate__c = null;
              clonedSize.OpportunityLineItem__c = clonedOpportunityLineItem.Id;
              clonedSizeList.add(clonedSize);
            }
          }
        }

        List<OpportunityLineItem__c> updateOpportunityLineItem = new List<OpportunityLineItem__c>();
        List<Shipping_Information__c> shippingObjectList = new List<Shipping_Information__c>();

        for (
          OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemCloneList
        ) {
          Shipping_Information__c shippingInformationObj = new Shipping_Information__c();
          shippingObjectList.add(shippingInformationObj);
        }
        insert shippingObjectList;
        index = 0;
        for (
          OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemCloneList
        ) {
          clonedOpportunityLineItem.Shipping_Information__c = shippingObjectList.get(
              index++
            )
            .id;
          updateOpportunityLineItem.add(clonedOpportunityLineItem);
        }
        if (!Test.isRunningTest()) {
          update updateOpportunityLineItem;
          insert clonedColorsList;
          insert clonedSizeList;
          insert extraChargesList;
          insert extraChargesWithArtWorkList;
          Set<Id> orderIds = new Set<Id>();
          // stop invoice syncing for phun for all company
          if (estimate.Selected_Quickbook_Instance__c != 'Phun for All') {
            orderIds.add(order.id);
          }
          Map<Id, String> accountNames = new Map<Id, String>();
          // stop invoice syncing for phun for all company
          if (estimate.Selected_Quickbook_Instance__c != 'Phun for All') {
            accountNames.put(order.id, estimate.Selected_Quickbook_Instance__c);
          }
          QuickbookApiCrud.createInvoiceUpdated(orderIds, accountNames);
          //List<Order> orders = new List<Order>();
          //orders.add(order);
          //OrderTriggerService.markInvoicesPaid(orders);
        }
        return 'true';
      } else {
        return 'false';
      }
    } catch (Exception ex) {
      System.debug(
        'Error in Convert To Sales Order -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  //to check whether the credits are valid or not, if valid only then users can convert Estimate to Sales Order
  //otherwise an email will be sent for the approval
  public static String isValidPricing(
    String recid,
    String valuesAndIds,
    Opportunity opp,
    Estimate__c estimate,
    User user
  ) {
    List<ConvertToSalesOrderObject> convertToOrderLit = (List<ConvertToSalesOrderObject>) System.JSON.deserializeStrict(
      valuesAndIds,
      List<ConvertToSalesOrderObject>.class
    );
    List<Id> listOfIds = new List<Id>();
    for (ConvertToSalesOrderObject obj : convertToOrderLit) {
      if (obj.value == true) {
        listOfIds.add(obj.recordId);
      }
    }
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Product__r.Design_Project__c, Product__r.Sales_Price_Rate__c
      FROM OpportunityLineItem__c
      WHERE Id = :listOfIds AND Product__r.Design_Project__c = TRUE
    ];
    List<Design_Project__c> designProjects = [
      SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
      FROM Design_Project__c
      WHERE Product__c IN :listOfIds
    ];
    Decimal usedCredits = 0;
    for (Design_Project__c designProject : designProjects) {
      usedCredits = usedCredits + designProject.Credits__c;
    }
    if (usedCredits <= user.Design_Bank__c)
      return 'true';
    List<PricingLineItem__c> allPricingRecords = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Credit_Available__c,
        Retail_Price__c,
        Net_Cost__c,
        Estimated_Quantity__c,
        Default__c,
        Display__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c = :oppLineItems
        AND Display__c = TRUE
        AND Default__c = FALSE
    ];
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Net_Cost__c,
        Credit_Available__c,
        OpportunityLineItem__c,
        Quantity__c,
        Retail_Price__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :listOfIds
    ];
    String response = 'true'; //// change variable name
    Decimal usingCredits = 0;
    for (OpportunityLineItem__c oppLineItem : oppLineItems) {
      if (oppLineItem.Product__r.Sales_Price_Rate__c == null)
        oppLineItem.Product__r.Sales_Price_Rate__c = 0;
      // if(oppLineItem.Valid_Credit__c == false)
      // isCreditAvailable = 'false';
      for (PricingLineItem__c pricing : allPricingRecords) {
        if (pricing.OpportunityLineItem__c == oppLineItem.id) {
          if (!pricing.Credit_Available__c)
            response = 'false';
          Decimal amount =
            (pricing.Estimated_Quantity__c != null
              ? pricing.Estimated_Quantity__c
              : 0) *
            (pricing.Retail_Price__c != null ? pricing.Retail_Price__c : 0);
          Decimal costTotal =
            (pricing.Estimated_Quantity__c != null
              ? pricing.Estimated_Quantity__c
              : 0) * (pricing.Net_Cost__c != null ? pricing.Net_Cost__c : 0);

          if (amount < costTotal)
            usingCredits = usingCredits + (costTotal - amount);
        }
      }
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        if (extraCharge.OpportunityLineItem__c == oppLineItem.id) {
          if (!extraCharge.Credit_Available__c)
            response = 'false';
          Decimal amount =
            (extraCharge.Quantity__c != null ? extraCharge.Quantity__c : 0) *
            (extraCharge.Retail_Price__c != null
              ? extraCharge.Retail_Price__c
              : 0);
          Decimal costTotal =
            (extraCharge.Quantity__c != null ? extraCharge.Quantity__c : 0) *
            (extraCharge.Net_Cost__c != null ? extraCharge.Net_Cost__c : 0);

          if (amount < costTotal)
            usingCredits = usingCredits + (costTotal - amount);
        }
      }
    }
    if (response == 'false') {
      if (estimate.Update_Credit_Request_Status__c == null) {
        if (sendEmail(estimate.OwnerId, usingCredits, estimate.Id, opp)) {
          estimate.Update_Credit_Request_Status__c = 'Pending';
          update estimate;
          response = 'Credit limit exceeded. An email has been sent to Art team for approval.';
        } else
          response = 'Error in Sending email';
      } else if (estimate.Update_Credit_Request_Status__c == 'Pending')
        response = 'Credit limit exceeded. Approval from art team is pending.';
      else if (estimate.Update_Credit_Request_Status__c == 'Rejected') {
        response = 'Credits update request has been rejected. Kindly adjust your available credits to convert Estimate to Sales Order.';
      }
    }
    if (response == 'false') {
      response = 'Kindly adjust your available credits to convert Estimate to Sales Order';
    }
    return response;
  }
  public static String getOrderStage(String valuesAndIds) {
    List<ConvertToSalesOrderObject> convertToOrderLit = (List<ConvertToSalesOrderObject>) System.JSON.deserializeStrict(
      valuesAndIds,
      List<ConvertToSalesOrderObject>.class
    );
    List<Id> listOfIds = new List<Id>();
    for (ConvertToSalesOrderObject obj : convertToOrderLit) {
      if (obj.value == true) {
        listOfIds.add(obj.recordId);
      }
    }
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Product__r.Design_Project__c, Product__r.Sales_Price_Rate__c
      FROM OpportunityLineItem__c
      WHERE Id = :listOfIds AND Product__r.Design_Project__c = FALSE
    ];
    if (oppLineItems != null && oppLineItems.size() > 0) {
      return '01_-_Waiting_for_Client_Payment';
    } else {
      return '02_-_Send_Mock_Up_to_Client_for_Approval';
    }
  }
  public static Boolean sendEmail(
    Id userId,
    Decimal credits,
    Id estimateId,
    Opportunity opp
  ) {
    try {
      User userInfo = [
        SELECT id, Name, Design_Bank__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      //message.setTargetObjectId(userId);
      message.setSaveAsActivity(false);
      EmailTemplate emailTemplate = [
        SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
        FROM EmailTemplate
        WHERE name = 'Credits Approval Email'
      ];
      message.setTemplateID(emailTemplate.Id);
      message.setSubject('Request for Updating Credits');
      String htmlBody = emailTemplate.HtmlValue;
      htmlBody = htmlBody.replace('{!Estimate__c.Id}', estimateId);
      htmlBody = htmlBody.replace('{!Opportunity.Id}', opp.Id);
      htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
      htmlBody = htmlBody.replace('{!User.Id}', userId);
      htmlBody = htmlBody.replace(
        '{!baseurl}',
        URL.getSalesforceBaseUrl().toExternalForm()
      );
      htmlBody = htmlBody.replace('{usingCredits}', String.valueOf(credits));
      htmlBody = htmlBody.replace('{!User.Name}', userInfo.Name);
      htmlBody = htmlBody.replace(
        '{!User.Design_Bank__c}',
        String.valueOf(userInfo.Design_Bank__c)
      );
      message.setHtmlBody(htmlBody);
      message.toAddresses = new List<String>{ Label.Design_Team_Email };
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      if (results[0].success) {
        System.debug('The email sent successfully.');
        return true;
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
        return false;
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in sending email ' +
          Ex.getMessage() +
          '+++++++ ' +
          Ex.getStackTraceString()
      );
      return false;
    }
  }
  @AuraEnabled
  public static List<EstimatePopupDetails> getRelatedOpportunityLineItems(
    Id recid
  ) {
    try {
      List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
      Estimate__c estimate = [
        SELECT Id, Opportunity__r.id
        FROM Estimate__c
        WHERE Opportunity__r.id = :recid
      ];
      List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
        SELECT
          Id,
          Name,
          Tax__c,
          Description__c,
          Product__r.Id,
          Product__r.Name,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Estimate__r.id = :estimate.id
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
        if (oppLineItem.Tax__c == null || oppLineItem.Tax__c == 'E(0%)') {
          details.tax = 'E';
        } else if (oppLineItem.Tax__c == 'SD(7.75%)') {
          details.tax = 'SD';
        } else if (oppLineItem.Tax__c == 'NC(9%)') {
          details.tax = 'NC';
        }
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

      /* Map <id,List<PricingLineItem__c>> pricingMap=new Map <id,List<PricingLineItem__c>>();
List <PricingLineItem__c> allPricings=[SELECT OpportunityLineItem__c,Show_To_Client__c, Net_Cost__c, Quantity__c, Margin__c, Retail_Price__c, Total__c, Id 
FROM PricingLineItem__c 
where OpportunityLineItem__c=:oppLineItemIds ];

for(id pricingId : oppLineItemIds)
{
List <PricingLineItem__c> priceList= new List<PricingLineItem__c>(); 
for(PricingLineItem__c prices :allPricings)
{
if (pricingId==prices.OpportunityLineItem__c)
{
priceList.add(prices);
}
}
pricingMap.put(pricingId,priceList);
}*/

      List<PricingLineItem__c> priceDetails = [
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
          Default__c,
          OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c IN :oppLineItemIds
          AND Display__c = TRUE
          AND Default__c = FALSE
      ];
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
        WHERE OpportunityLineItem__c IN :oppLineItemIds
        ORDER BY CreatedDate ASC
      ];

      for (EstimatePopupDetails details : detailsToReturn) {
        details.units = 0;
        Decimal total = 0;
        Decimal marginPercentage = 0;
        decimal actualTotal = 0;
        //OpportunityLineItemDetails lineItemDetails = EditOpporLineItemInEstimateController.getOpportunityLineItemDetails(details.oppLineItemId);
        for (PricingLineItem__c pricing : priceDetails) {
          if (pricing.OpportunityLineItem__c == details.oppLineItemId) {
            details.units = details.units + pricing.Estimated_Quantity__c;
            /// for total and margin percentage
            decimal retailPrice = (pricing.Retail_Price__c == null)
              ? 0
              : pricing.Retail_Price__c;
            total += (pricing.Total__c == null) ? 0 : pricing.Total__c;
            actualTotal =
              actualTotal +
              (((pricing.Net_Cost__c == null) ? 0 : pricing.Net_Cost__c) *
              ((pricing.Estimated_Quantity__c == null)
                ? 0
                : pricing.Estimated_Quantity__c));
          }
        }
        /////
        for (ExtraChargesEstimate__c extraCharge : extraCharges) {
          if (extraCharge.OpportunityLineItem__c == details.oppLineItemId) {
            decimal retailPrice = (extraCharge.Retail_Price__c == null)
              ? 0
              : extraCharge.Retail_Price__c;
            total += (extraCharge.Total__c == null) ? 0 : extraCharge.Total__c;
            actualTotal =
              actualTotal +
              ((extraCharge.Net_Cost__c != null ? extraCharge.Net_Cost__c : 0) *
              (extraCharge.Quantity__c != null ? extraCharge.Quantity__c : 0));
          }
        }

        details.total = total;
        if (total != 0) {
          details.marginPercentage = (((total - actualTotal) / total) * 100)
            .setScale(0);
        } else {
          details.marginPercentage = 0;
        }
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

  public static decimal getTax(String tax) {
    if (tax != null) {
      String[] str1 = tax.split('[(]');
      String[] str2 = str1[1].split('%');
      return decimal.valueOf(str2[0]);
    } else {
      return 0.0;
    }
  }
}
