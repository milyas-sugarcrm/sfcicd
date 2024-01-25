public class SalesOrderOppLineItemController {
  public static Decimal checkNullValue(Decimal value) {
    return (value == null) ? 0 : value;
  }

  @AuraEnabled
  public static List<EstimatePopupDetails> getSalesOrderRelatedOpportunityLineItems(
    Id salesId,
    Integer numOfrec
  ) {
    List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
    List<OpportunityLineItem__c> relatedOpportunityLineItems = new List<OpportunityLineItem__c>();
    List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
      SELECT
        Id,
        Name,
        PurchaseOrder_LineItem__c,
        Description__c,
        Product__c,
        Product__r.Name,
        Tax__c,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Work_Order__c,
        Product__r.Id,
        PurchaseOrder_LineItem__r.Name,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :salesId
      ORDER BY Sorting_Date__c ASC
    ];

    //Sorting Logic
    relatedOpportunityLineItems = ProductsSorting.sortProducts(
      relatedOpportunityLineItemsUnsorted
    );
    //details of each opportunityLine item
    List<id> oppLineItemIds = new List<id>();
    List<id> workOrderIds = new List<id>();
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
      EstimatePopupDetails details = new EstimatePopupDetails();
      details.oppLineItemId = oppLineItem.Id;
      details.workOrderId = oppLineItem.Work_Order__c;
      details.productId = oppLineItem.Product__r.Id;
      details.productName = oppLineItem.name;
      details.sku = oppLineItem.SKU__c;
      details.description = oppLineItem.Description__c;
      details.poNumber = oppLineItem.PurchaseOrder_LineItem__r.Name;
      details.poId =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/lightning/r/Opportunity/' +
        oppLineItem.PurchaseOrder_LineItem__c +
        '/view';
      details.purchaseOrderId = oppLineItem.PurchaseOrder_LineItem__c;
      if (oppLineItem.Tax__c == null || oppLineItem.Tax__c == 'E(0%)') {
        details.tax = 'E';
      } else if (oppLineItem.Tax__c == 'SD(7.75%)') {
        details.tax = 'SD';
      } else if (oppLineItem.Tax__c == 'NC(9%)') {
        details.tax = 'NC';
      }
      workOrderIds.add(oppLineItem.Work_Order__c);

      if (
        (numOfrec == 6 && detailsToReturn.size() < numOfrec) || numOfrec != 6
      ) {
        oppLineItemIds.add(oppLineItem.Id);
        detailsToReturn.add(details);
      }
    }
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
        OpportunityLineItem_ArtWork__r.Id,
        OpportunityLineItem_ArtWork__r.Title__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
      ORDER BY CreatedDate ASC
    ];

    //List <PurchaseOrder_LineItem__c> PONumbersList = [SELECT Id, Work_Order__c, Name
    //                                                FROM PurchaseOrder_LineItem__c
    //                                              WHERE Work_Order__c IN: workOrderIds];
    //WHERE (OpportunityLineItem__c IN: oppLineItemIds OR Work_Order__c IN: workOrderIds)];

    for (EstimatePopupDetails details : detailsToReturn) {
      details.units = 0;
      Decimal total = 0;
      Decimal costTotal = 0;
      decimal actualTotal = 0;
      Decimal marginPercentage = 0;
      //OpportunityLineItemDetails lineItemDetails = EditOpporLineItemInEstimateController.getOpportunityLineItemDetails(details.oppLineItemId);
      for (PricingLineItem__c pricing : priceDetails) {
        if (pricing.OpportunityLineItem__c == details.oppLineItemId) {
          details.units =
            details.units +
            ((pricing.Estimated_Quantity__c == null)
              ? 0
              : pricing.Estimated_Quantity__c);
          /// for total and margin percentage
          decimal retailPrice = (pricing.Retail_Price__c == null)
            ? 0
            : pricing.Retail_Price__c;
          total += (pricing.Total__c == null) ? 0 : pricing.Total__c;
          costTotal +=
            (checkNullValue(pricing.Net_Cost__c)) *
            (checkNullValue(pricing.Estimated_Quantity__c));
          actualTotal =
            actualTotal +
            (((pricing.Net_Cost__c == null) ? 0 : pricing.Net_Cost__c) *
            ((pricing.Estimated_Quantity__c == null)
              ? 0
              : pricing.Estimated_Quantity__c));
          if (pricing.Color__c == null || pricing.Color__c == '') {
            if (pricing.Size__c == null || pricing.Size__c == '') {
              pricing.Size__c = 'TBD/TBD';
            } else {
              pricing.Size__c = pricing.Size__c + '/TBD';
            }
          } else if (pricing.Color__c != null || pricing.Color__c != '') {
            if (pricing.Size__c != null || pricing.Size__c != '') {
              pricing.Size__c = pricing.Size__c + '/' + pricing.Color__c;
            } else {
              pricing.Size__c = 'TBD/' + pricing.Color__c;
            }
          }
          details.pricingDetails.add(pricing);
        }
      }
      /////
      Map<Id, String> artworkIds = new Map<Id, String>();
      for (ExtraChargesEstimate__c extraCharge : extraCharges) {
        if (extraCharge.OpportunityLineItem__c == details.oppLineItemId) {
          if (extraCharge.Is_Associated_With_Artwork__c) {
            artworkIds.put(
              extraCharge.OpportunityLineItem_ArtWork__r.id,
              extraCharge.OpportunityLineItem_ArtWork__r.Title__c
            );
          } else {
            details.extraChargesWithoutArtWork.add(extraCharge);
          }
          decimal retailPrice = (extraCharge.Retail_Price__c == null)
            ? 0
            : extraCharge.Retail_Price__c;

          total +=
            (checkNullValue(extraCharge.Retail_Price__c)) *
            (checkNullValue(extraCharge.Quantity__c));
          costTotal +=
            (checkNullValue(extraCharge.Net_Cost__c)) *
            (checkNullValue(extraCharge.Quantity__c));
          // total += (extraCharge.Total__c == null) ? 0 : extraCharge.Total__c;

          actualTotal =
            actualTotal +
            ((checkNullValue(extraCharge.Net_Cost__c)) *
            (checkNullValue(extraCharge.Quantity__c)));
        }
      }
      for (Id artworkId : artworkIds.keySet()) {
        ExtraChargesArtWorkDetails chargesWithArtworks = new ExtraChargesArtWorkDetails();
        for (ExtraChargesEstimate__c extraCharge : extraCharges) {
          if (
            extraCharge.Is_Associated_With_Artwork__c &&
            extraCharge.OpportunityLineItem_ArtWork__r.id == artworkId
          ) {
            chargesWithArtworks.extraChargeswithArtWork.add(extraCharge);
          }
        }
        if (chargesWithArtworks.extraChargeswithArtWork.size() > 0) {
          chargesWithArtworks.artworkName = artworkIds.get(artworkId);
          details.extraChargesWithArtWork.add(chargesWithArtworks);
        }
      }
      details.total = total;
      details.costtotal = costTotal;
      if (total != 0) {
        details.marginPercentage = (((total - actualTotal) / total) * 100)
          .setScale(0);
      } else {
        details.marginPercentage = 0;
      }

      //system.debug('polist.work order: ' + PONumbersList);
      //system.debug('details.purchaseOrderId ' + details.purchaseOrderId );
      /*
for (PurchaseOrder_LineItem__c polist :PONumbersList)
{
if(polist.Id == details.purchaseOrderId)
{
details.poNumber= polist.Name;
}

}
*/
      system.debug(detailsToReturn);
    }
    return detailsToReturn;
  }

  @AuraEnabled
  public static String getSalesOrderInHandDate(Id oppLineId) {
    List<OpportunityLineItem__c> lstOppLineItems = [
      SELECT id, Work_Order__c
      FROM OpportunityLineItem__c
      WHERE id = :oppLineId
    ];
    String salesInHandDate = '';
    if (lstOppLineItems.size() > 0) {
      List<Order> lstOrders = [
        SELECT id, EffectiveDate
        FROM Order
        WHERE id = :lstOppLineItems.get(0).Work_Order__c
      ];
      if (lstOrders.size() > 0) {
        salesInHandDate = lstOrders.get(0).EffectiveDate.format();
      }
    }
    return salesInHandDate;
  }

  @AuraEnabled
  public static Integer getCountOfSalesOrderOppLineItems(Id salesId) {
    return [
        SELECT Id
        FROM OpportunityLineItem__c
        WHERE Work_Order__c = :salesId
      ]
      .size();
  }

  @AuraEnabled
  public static boolean deleteOpportunityLineItemInDb(String salesId) {
    try {
      OpportunityLineItem__c opportunityLine = [
        SELECT Id, Name, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Id = :salesId
      ];
      Id woId = opportunityLine.Work_Order__c;
      delete opportunityLine;
      /*to delete product from QBO invoice by calling updateWorkOrder function which 
            is recalculating the work order amount which in result update the invoice
            */
      EditOpporLineItemInSalesOrderController.updateWorkOrder(woId);
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return false;
    }
  }

  @AuraEnabled
  public static String getSalesOrderPreviewLink(String recId) {
    try {
      Order order = [SELECT id, OpportunityId FROM Order WHERE id = :recId];
      List<OpportunityLineItem__c> opportunityLine = [
        SELECT Id, Work_Order__c
        FROM OpportunityLineItem__c
        WHERE Work_Order__c = :recId
      ];
      if (opportunityLine.size() > 0) {
        return URL.getSalesforceBaseUrl().toExternalForm() +
          '/apex/OpportunitySalesOrderPreview?id=' +
          order.OpportunityId;
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

  //This function handles the inline edit functionality of sales order on WO.

  @AuraEnabled
  public static Boolean updateSaleOrderInlineEdit(string recordData) {
    Map<String, Object> updatedData = new Map<String, Object>();
    Map<String, Object> productData = new Map<String, Object>();
    Map<String, Object> pricingData = new Map<String, Object>();
    Map<String, Object> extraChargeData = new Map<String, Object>();
    List<OpportunityLineItem__c> oppLineItemList = new List<OpportunityLineItem__c>();
    List<Id> pOListId = new List<Id>();
    List<Id> wOListId = new List<Id>();
    ID workOrderID;

    try {
      updatedData = (Map<String, Object>) JSON.deserializeUntyped(recordData);
      for (String key : updatedData.keySet()) {
        if (key == 'Product') {
          productData = (Map<String, Object>) updatedData.get(key);
        } else if (key == 'pricingDetails') {
          pricingData = (Map<String, Object>) updatedData.get(key);
        } else if (key == 'extraCharge') {
          extraChargeData = (Map<String, Object>) updatedData.get(key);
        } else if (key == 'workOrderId') {
          workOrderID = (ID) updatedData.get(key);
        }
      }
      if (productData.size() != 0) {
        updateProduct(productData);
        getRelatedPOWO(oppLineItemList, productData, 'Product');
      }
      if (pricingData.size() != 0) {
        updateProductPricing(pricingData);
        getRelatedPOWO(oppLineItemList, pricingData, 'Pricing');
      }
      if (extraChargeData.size() != 0) {
        updateProductExtraCharge(extraChargeData);
        getRelatedPOWO(oppLineItemList, extraChargeData, 'ExtraCharge');
      }

      if (oppLineItemList.size() > 0) {
        for (OpportunityLineItem__c oPLI : oppLineItemList) {
          pOListId.add(oPLI.PurchaseOrder_LineItem__c);
          wOListId.add(oPLI.Work_Order__c);
        }
      }
      if (workOrderID != null) {
        EditOpporLineItemInSalesOrderController.updateWorkOrder(workOrderID);
        updateSalesOrderSyncStatus(workOrderId, false);
      }
    } catch (Exception e) {
      system.debug(e);
    }
    return true;
  }

  //Update the description of the product.

  public static void updateProduct(Map<String, Object> productData) {
    List<ID> productIds = new List<ID>();
    Boolean dataChanged = false;

    for (String productId : productData.keySet()) {
      productIds.add((ID) productId);
    }

    List<OpportunityLineItem__c> productRecords = [
      SELECT Id, Name, Description__c
      FROM OpportunityLineItem__c
      WHERE id IN :productIds
    ];
    for (OpportunityLineItem__c productRecord : productRecords) {
      Map<String, Object> productLineItem = (Map<String, Object>) productData.get(
        productRecord.id
      );

      if (
        productLineItem.get('Description__c') != productRecord.Description__c &&
        productLineItem.get('Description__c') != null
      ) {
        productRecord.Description__c = (String) productLineItem.get(
          'Description__c'
        );
        dataChanged = true;
      }
    }
    if (dataChanged == true) {
      update productRecords;
    }
  }

  // Update the pricing of a product.

  public static void updateProductPricing(Map<String, Object> pricingData) {
    List<ID> pricingIds = new List<ID>();
    Boolean dataChanged = false;

    for (String pricingId : pricingData.keySet()) {
      pricingIds.add((ID) pricingId);
    }
    List<PricingLineItem__c> pricingRecords = [
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
        OpportunityLineItem__r.Estimate__c
      FROM PricingLineItem__c
      WHERE Id IN :pricingIds
    ];

    for (PricingLineItem__c pricingRecord : pricingRecords) {
      Map<String, Object> priceLineItem = (Map<String, Object>) pricingData.get(
        pricingRecord.id
      );
      if (
        priceLineItem.get('Estimated_Quantity__c') !=
        pricingRecord.Estimated_Quantity__c &&
        priceLineItem.get('Estimated_Quantity__c') != null
      ) {
        pricingRecord.Estimated_Quantity__c = Decimal.valueOf(
            (String) priceLineItem.get('Estimated_Quantity__c')
          )
          .setScale(0);
        dataChanged = true;
      }
      if (
        priceLineItem.get('Net_Cost__c') != pricingRecord.Net_Cost__c &&
        priceLineItem.get('Net_Cost__c') != null
      ) {
        pricingRecord.Net_Cost__c = Decimal.valueOf(
            (String) priceLineItem.get('Net_Cost__c')
          )
          .setScale(3);
        decimal marginCalculation = 1 - (pricingRecord.Margin__c / 100);
        pricingRecord.Retail_Price__c = (pricingRecord.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1))
          .setScale(3);
        dataChanged = true;
      }
      if (
        priceLineItem.get('Retail_Price__c') != pricingRecord.Retail_Price__c &&
        priceLineItem.get('Retail_Price__c') != null
      ) {
        pricingRecord.Retail_Price__c = Decimal.valueOf(
            (String) priceLineItem.get('Retail_Price__c')
          )
          .setScale(3);
        decimal priceCostCalculation = (((pricingRecord.Retail_Price__c == null)
          ? 0
          : pricingRecord.Retail_Price__c) -
        ((pricingRecord.Net_Cost__c == null ? 0 : pricingRecord.Net_Cost__c)));
        if (
          pricingRecord.Retail_Price__c != 0 &&
          pricingRecord.Retail_Price__c != null
        )
          pricingRecord.Margin__c = ((priceCostCalculation /
            pricingRecord.Retail_Price__c) * 100)
            .setScale(3);
        else
          pricingRecord.Margin__c = 0;
        dataChanged = true;
      }
      pricingRecord.Total__c = (pricingRecord.Estimated_Quantity__c *
        pricingRecord.Retail_Price__c)
        .setScale(3);
    }
    if (dataChanged == true) {
      update pricingRecords;
    }
  }

  //Update the extra charge of a product.

  public static void updateProductExtraCharge(
    Map<String, Object> extraChargeData
  ) {
    List<ID> extraChargeIDs = new List<ID>();
    Boolean dataChanged = false;

    for (String extraChargeID : extraChargeData.keySet()) {
      extraChargeIDs.add((ID) extraChargeID);
    }

    List<ExtraChargesEstimate__c> extraChargeRecords = [
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
        OpportunityLineItem_ArtWork__r.Id,
        OpportunityLineItem_ArtWork__r.Title__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE Id IN :extraChargeIDs
    ];

    for (ExtraChargesEstimate__c extraChargeRecord : extraChargeRecords) {
      Map<String, Object> extraChargeLineItem = (Map<String, Object>) extraChargeData.get(
        extraChargeRecord.id
      );

      if (
        extraChargeLineItem.get('Title__c') != extraChargeRecord.Title__c &&
        extraChargeLineItem.get('Title__c') != null
      ) {
        extraChargeRecord.Title__c = (String) extraChargeLineItem.get(
          'Title__c'
        );
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('Quantity__c') !=
        extraChargeRecord.Quantity__c &&
        extraChargeLineItem.get('Quantity__c') != null
      ) {
        extraChargeRecord.Quantity__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('Quantity__c')
          )
          .setScale(0);
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('Net_Cost__c') !=
        extraChargeRecord.Net_Cost__c &&
        extraChargeLineItem.get('Net_Cost__c') != null
      ) {
        extraChargeRecord.Net_Cost__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('Net_Cost__c')
          )
          .setScale(3);
        decimal marginCalculation = 1 - (extraChargeRecord.Margin__c / 100);
        extraChargeRecord.Retail_Price__c = (extraChargeRecord.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1))
          .setScale(3);
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('Retail_Price__c') !=
        extraChargeRecord.Retail_Price__c &&
        extraChargeLineItem.get('Retail_Price__c') != null
      ) {
        extraChargeRecord.Retail_Price__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('Retail_Price__c')
          )
          .setScale(3);
        decimal priceCostCalculation = (((extraChargeRecord.Retail_Price__c ==
          null)
          ? 0
          : extraChargeRecord.Retail_Price__c) -
        ((extraChargeRecord.Net_Cost__c == null
          ? 0
          : extraChargeRecord.Net_Cost__c)));
        if (
          extraChargeRecord.Retail_Price__c != 0 &&
          extraChargeRecord.Retail_Price__c != null
        )
          extraChargeRecord.Margin__c = ((priceCostCalculation /
            extraChargeRecord.Retail_Price__c) * 100)
            .setScale(3);
        else
          extraChargeRecord.Margin__c = 0;
        dataChanged = true;
      }
      extraChargeRecord.Total__c = (extraChargeRecord.Quantity__c *
        extraChargeRecord.Retail_Price__c)
        .setScale(3);
    }
    if (dataChanged == true) {
      update extraChargeRecords;
    }
  }

  /**
   * Fetch related Purchase Order and Work Orders for the OpportunityLineItem
   */
  public static void getRelatedPOWO(
    List<OpportunityLineItem__c> oppLineItemList,
    Map<String, Object> lineItemData,
    String type
  ) {
    List<ID> oppLineItemIds = new List<ID>();
    List<ID> workOrderIds = new List<ID>();
    Map<ID, String> poWOIdsMap = new Map<ID, String>();
    if (type == 'Pricing') {
      List<ID> pricingIds = new List<ID>();
      for (String productId : lineItemData.keySet()) {
        pricingIds.add((ID) productId);
      }
      List<PricingLineItem__c> pricingLineItemList = [
        SELECT Id, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE Id IN :pricingIds
      ];
      for (PricingLineItem__c pLI : pricingLineItemList) {
        oppLineItemIds.add(pLI.OpportunityLineItem__c);
      }
      oppLineItemList.addAll(
        [
          SELECT Id, PurchaseOrder_LineItem__c, Work_Order__c
          FROM OpportunityLineItem__c
          WHERE Id IN :oppLineItemIds
        ]
      );
    } else if (type == 'Product') {
      List<ID> productIds = new List<ID>();
      for (String productId : lineItemData.keySet()) {
        productIds.add((ID) productId);
      }
      oppLineItemList.addAll(
        [
          SELECT Id, PurchaseOrder_LineItem__c, Work_Order__c
          FROM OpportunityLineItem__c
          WHERE id IN :productIds
        ]
      );
    } else if (type == 'ExtraCharge') {
      List<ID> extraChargeIDs = new List<ID>();
      for (String extraChargeID : lineItemData.keySet()) {
        extraChargeIDs.add((ID) extraChargeID);
      }
      List<ExtraChargesEstimate__c> extraChargeRecords = [
        SELECT Id, OpportunityLineItem__c
        FROM ExtraChargesEstimate__c
        WHERE Id IN :extraChargeIDs
      ];
      for (ExtraChargesEstimate__c pLI : extraChargeRecords) {
        oppLineItemIds.add(pLI.OpportunityLineItem__c);
      }
      oppLineItemList.addAll(
        [
          SELECT Id, PurchaseOrder_LineItem__c, Work_Order__c
          FROM OpportunityLineItem__c
          WHERE Id IN :oppLineItemIds
        ]
      );
    }
  }

  /**
   * This function is updating the Bill when the SalesOrder's Save is clicked
   */
  public static Boolean updateBill(List<ID> pOIdList) {
    List<String> POStatusList = new List<String>{
      'In Process',
      'Ready for TP Pickup',
      'Shipped',
      'Received at QC',
      'Ready to Ship/Pickup'
    };
    //opportunitLineItemData
    List<PurchaseOrder_LineItem__c> pOrderList = [
      SELECT Id, WO_Status__c, QBO_Bill__c, WOQBOInstance__c
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :pOIdList
    ];
    Set<Id> purchaseOrdersToBeUpdated = new Set<Id>();
    Map<Id, String> OrderAccountMap = new Map<Id, String>();

    for (PurchaseOrder_LineItem__c pOrder : pOrderList) {
      if (
        POStatusList.contains(pOrder.WO_Status__c) && pOrder.QBO_Bill__c != null
      ) {
        purchaseOrdersToBeUpdated.add(pOrder.Id);
        OrderAccountMap.put(pOrder.Id, pOrder.WOQBOInstance__c);
      }
    }
    // Update the bill syncing
    if (
      purchaseOrdersToBeUpdated.size() > 0 &&
      OrderAccountMap.size() > 0 &&
      !system.isBatch() &&
      !System.isFuture() &&
      !Test.isRunningTest()
    ) {
      QuickbookApiCrud.updatePurchaseOrder(
        purchaseOrdersToBeUpdated,
        OrderAccountMap
      );
      return true;
    }
    return false;
  }
  public static Boolean updateInvoice(String WordOrderID) {
    try {
      Set<Id> orderIdsToBeUpdated = new Set<Id>();
      Map<Id, String> OrderAccountMap = new Map<Id, String>();
      Order woID = [
        SELECT ID, OpportunityId, Quickbooks_Instance__c, QbId__c
        FROM Order
        WHERE ID = :WordOrderID
      ];
      List<Estimate__c> estimates = [
        SELECT id, Opportunity__c, Selected_Quickbook_Instance__c
        FROM Estimate__c
        WHERE Opportunity__c = :woID.OpportunityId
      ];
      if (woID.Quickbooks_Instance__c != 'Phun for All') {
        if (woID.QbId__c != null) {
          orderIdsToBeUpdated.add(woID.ID);
        }

        for (Estimate__c est : estimates) {
          if (woID.OpportunityId == est.Opportunity__c) {
            OrderAccountMap.put(woID.ID, est.Selected_Quickbook_Instance__c);
          }
        }
      }
      if (!System.isBatch() && !System.isFuture()) {
        if (orderIdsToBeUpdated != null && orderIdsToBeUpdated.size() > 0)
          QuickbookApiCrud.updateInvoice(orderIdsToBeUpdated, OrderAccountMap);
        return true;
      }
      return false;
    } catch (Exception e) {
      System.debug(e);
      return false;
    }
  }
  /**
   * This function calls the updateBill to update the bill for the related Purchase Orders
   */
  @AuraEnabled
  public static Boolean syncSalesOrders(String workOrderId) {
    List<OpportunityLineItem__c> oPLICList = [
      SELECT Id, PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :workOrderId
    ];
    List<Id> pOListId = new List<Id>();
    if (oPLICList.size() == 0) {
      throw new AuraHandledException('No Sales Order exists!');
    }
    for (OpportunityLineItem__c oPLIC : oPLICList) {
      if (oPLIC.PurchaseOrder_LineItem__c != null) {
        pOListId.add(oPLIC.PurchaseOrder_LineItem__c);
      }
    }
    Boolean billSynced = updateBill(pOListId);
    Boolean invoiceSynced = updateInvoice(workOrderId);
    if (billSynced || invoiceSynced) {
      updateSalesOrderSyncStatus(workOrderId, true);
      return true;
    }
    return false;
  }

  /**
   * This function gets the sync status for all the Line Items
   */
  @AuraEnabled
  public static String getSalesOrderSyncStatus(Id salesId) {
    for (OrderSyncStatus__c oSS : [
      SELECT Id, isSynced__c
      FROM OrderSyncStatus__c
      WHERE Work_Order__c = :salesId
    ]) {
      if (oSS.isSynced__c == false) {
        return 'Please synchronize the Sales Order with Quickbooks using "Sync Sales Order" in Actions';
      }
    }
    return null;
  }

  /**
   * This function updates the sync status for all the Line Items on the Work Order
   */
  public static void updateSalesOrderSyncStatus(
    String salesId,
    Boolean syncFlag
  ) {
    List<OrderSyncStatus__c> oSSList = [
      SELECT Id, isSynced__c
      FROM OrderSyncStatus__c
      WHERE Work_Order__c = :salesId
    ];
    for (OrderSyncStatus__c oSS : oSSList) {
      oSS.isSynced__c = syncFlag;
    }
    update oSSList;
  }
}
