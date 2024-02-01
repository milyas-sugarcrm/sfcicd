public class EstimateOppLineItemController {
  @AuraEnabled
  public static List<EstimatePopupDetails> updateTheIndexOfRecords(
    String recordsObjectList,
    String recordId
  ) {
    List<EstimateEditClass> convertToEstimateLit = (List<EstimateEditClass>) System.JSON.deserialize(
      recordsObjectList,
      List<EstimateEditClass>.class
    );
    List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
    List<PricingLineItem__c> pricingList = new List<PricingLineItem__c>();

    for (EstimateEditClass obj : convertToEstimateLit) {
      if (obj.ObjectName == 'extraCharge') {
        ExtraChargesEstimate__c ext = new ExtraChargesEstimate__c();
        ext.Id = obj.Id;
        ext.index__c = obj.index;
        extraChargesList.add(ext);
      } else if (obj.ObjectName == 'Pricing') {
        PricingLineItem__c pricing = new PricingLineItem__c();
        pricing.Id = obj.Id;
        pricing.index__c = obj.index;
        pricingList.add(pricing);
      }
    }
    if (extraChargesList.size() > 0) {
      update extraChargesList;
    }
    if (pricingList.size() > 0) {
      update pricingList;
    }
    return getEstimateRelatedOpportunityLineItems(recordId, null);
  }
  @AuraEnabled
  public static List<EstimatePopupDetails> getEstimateRelatedOpportunityLineItems(
    Id estId,
    Integer numOfrec
  ) {
    try {
      Decimal totalCredit = [
        SELECT Design_Bank__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ][0]
      .Design_Bank__c;
      List<OpportunityLineItem__c> relatedOpportunityLineItems = [
        SELECT
          Id,
          Name,
          Description__c,
          Product__c,
          Product__r.Id,
          Product__r.Name,
          Product__r.Design_Project__c,
          Product__r.Sales_Price_Rate__c,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Tax__c,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :estId
        ORDER BY Sorting_Date__c ASC
      ];

      List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
      List<id> oppLineItemIds = new List<id>();
      //Sorting Logic
      List<OpportunityLineItem__c> sortedDetails = ProductsSorting.sortProducts(
        relatedOpportunityLineItems
      );

      for (OpportunityLineItem__c oppLineItem : sortedDetails) {
        EstimatePopupDetails details = new EstimatePopupDetails();
        details.oppLineItemId = oppLineItem.Id;
        details.productId = oppLineItem.Product__r.Id;
        details.productName = oppLineItem.name;
        details.salesPrice = oppLineItem.Product__r.Sales_Price_Rate__c;
        details.designProduct = oppLineItem.Product__r.Design_Project__c;
        details.sku = oppLineItem.SKU__c;
        if (oppLineItem.Tax__c == null || oppLineItem.Tax__c == 'E(0%)') {
          details.tax = 'E';
        } else if (oppLineItem.Tax__c == 'SD(7.75%)') {
          details.tax = 'SD';
        } else if (oppLineItem.Tax__c == 'NC(9%)') {
          details.tax = 'NC';
        }
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
          index__c,
          Color__c,
          Size__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c,
          Subtotal_Toggle__c,
          Show_To_Client__c,
          Estimate__c,
          Estimated_Quantity__c,
          Display__c,
          Credit_Available__c,
          Default__c,
          OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE
          OpportunityLineItem__c IN :oppLineItemIds
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY index__c ASC
      ];
      List<ExtraChargesEstimate__c> extraCharges = [
        SELECT
          Id,
          Title__c,
          index__c,
          Quantity__c,
          Subtotal_Toggle__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Credit_Available__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem_ArtWork__r.Title__c,
          OpportunityLineItem_ArtWork__r.Id,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c IN :oppLineItemIds
        ORDER BY index__c ASC
      ];
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :oppLineItemIds
      ];

      Integer count = 0;
      Decimal subTotal = 0;
      Decimal total = 0;
      for (EstimatePopupDetails details : detailsToReturn) {
        List<EstimateEditClass> estimateBreakdownList = new List<EstimateEditClass>();
        for (PricingLineItem__c pricing : priceDetails) {
          if (pricing.OpportunityLineItem__c == details.oppLineItemId) {
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
            EstimateEditClass estBreakdownObj = new EstimateEditClass();
            estBreakdownObj.Id = pricing.Id;
            estBreakdownObj.ObjectName = 'Pricing';
            estBreakdownObj.toggle = pricing.Subtotal_Toggle__c;
            estBreakdownObj.Quantity = pricing.Estimated_Quantity__c;
            estBreakdownObj.cost = pricing.Net_Cost__c;
            estBreakdownObj.retailPrice = pricing.Retail_Price__c;
            estBreakdownObj.isCreditAvailable = pricing.Credit_Available__c;
            if (
              estBreakdownObj.Quantity == null ||
              estBreakdownObj.retailPrice == null
            ) {
              estBreakdownObj.TotalPrice = 0;
            } else {
              estBreakdownObj.TotalPrice =
                estBreakdownObj.Quantity * estBreakdownObj.retailPrice;
            }
            if (
              estBreakdownObj.cost != null &&
              estBreakdownObj.Quantity != null &&
              details.designProduct
            ) {
              if (
                estBreakdownObj.retailPrice != null &&
                estBreakdownObj.retailPrice < estBreakdownObj.cost
              )
                estBreakdownObj.usedCredits =
                  (estBreakdownObj.Quantity * estBreakdownObj.cost) -
                  estBreakdownObj.TotalPrice;
              else
                estBreakdownObj.usedCredits = 0;
            } else
              estBreakdownObj.usedCredits = 0;
            estBreakdownObj.TotalPrice = estBreakdownObj.TotalPrice.setScale(2);
            subtotal = subtotal.setScale(2);
            subtotal += estBreakdownObj.TotalPrice;
            total += estBreakdownObj.TotalPrice;
            estBreakdownObj.subtotal = subtotal;
            if (pricing.Subtotal_Toggle__c == true) {
              subTotal = 0;
            }
            estBreakdownObj.Color = pricing.Color__c;
            estBreakdownObj.Size = pricing.Size__c;
            estBreakdownObj.ProductName = pricing.Size__c;
            estBreakdownObj.index = Integer.valueOf(pricing.index__c);
            estimateBreakdownList.add(estBreakdownObj);
            //  estimateBreakdownList.
          }
        }

        Map<Id, String> artworkIds = new Map<Id, String>();
        for (ExtraChargesEstimate__c extraCharge : extraCharges) {
          if (extraCharge.OpportunityLineItem__c == details.oppLineItemId) {
            EstimateEditClass estBreakdownObj = new EstimateEditClass();
            estBreakdownObj.Id = extraCharge.Id;
            estBreakdownObj.ObjectName = 'extraCharge';
            estBreakdownObj.ProductName = extraCharge.Title__c;
            estBreakdownObj.toggle = extraCharge.Subtotal_Toggle__c;
            estBreakdownObj.recordType = extraCharge.Charge_Type__c;
            estBreakdownObj.cost = extraCharge.Net_Cost__c;
            estBreakdownObj.Quantity = extraCharge.Quantity__c;
            estBreakdownObj.retailPrice = extraCharge.Retail_Price__c.setScale(
              2
            );
            estBreakdownObj.isCreditAvailable = extraCharge.Credit_Available__c;
            if (
              estBreakdownObj.Quantity == null ||
              estBreakdownObj.retailPrice == null
            ) {
              estBreakdownObj.TotalPrice = 0;
            } else {
              estBreakdownObj.TotalPrice =
                estBreakdownObj.Quantity * estBreakdownObj.retailPrice;
            }
            if (
              estBreakdownObj.cost != null &&
              estBreakdownObj.Quantity != null &&
              details.designProduct
            ) {
              if (
                estBreakdownObj.retailPrice != null &&
                estBreakdownObj.retailPrice < estBreakdownObj.cost
              )
                estBreakdownObj.usedCredits =
                  (estBreakdownObj.Quantity * estBreakdownObj.cost) -
                  estBreakdownObj.TotalPrice;
              else
                estBreakdownObj.usedCredits = 0;
            } else
              estBreakdownObj.usedCredits = 0;
            subtotal = subtotal.setScale(2);
            subtotal += estBreakdownObj.TotalPrice;
            total += estBreakdownObj.TotalPrice;
            estBreakdownObj.subtotal = subtotal;
            if (extraCharge.Subtotal_Toggle__c == true) {
              subTotal = 0;
            }
            estBreakdownObj.index = Integer.valueOf(extraCharge.index__c);
            estimateBreakdownList.add(estBreakdownObj);
          }
        }
        details.estimateInlineList = estimateBreakdownList;
      }
      count = 0;
      subTotal = 0;
      total = 0;
      for (EstimatePopupDetails details : detailsToReturn) {
        details.estimateInlineList = sortList(details.estimateInlineList);
        for (EstimateEditClass estBreakdownObj : details.estimateInlineList) {
          subtotal = subtotal.setScale(2);
          subtotal += estBreakdownObj.TotalPrice;
          total += estBreakdownObj.TotalPrice;
          estBreakdownObj.subtotal = subtotal;
          if (estBreakdownObj.toggle == true) {
            subTotal = 0;
          }
          // estBreakdownObj.index
        }
      }

      //update designProjects;
      Estimate__c estimate = [
        SELECT Id, Opportunity__c
        FROM Estimate__c
        WHERE Id = :estId
      ];
      Opportunity opp = [
        SELECT Id, Amount
        FROM Opportunity
        WHERE Id = :estimate.Opportunity__c
      ];
      opp.Amount = total;
      opp.Amount = opp.Amount.setScale(2);
      if (detailsToReturn.size() > 0) {
        detailsToReturn[0].total = total;
      }
      // update opp;
      return detailsToReturn;
    } catch (Exception ex) {
      System.debug(
        'Error in getting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return null;
    }
  }
  public static List<EstimateEditClass> sortList(
    List<EstimateEditClass> breakdownList
  ) {
    Integer n = breakdownList.size();
    for (integer i = 1; i < n; i++) {
      EstimateEditClass current = breakdownList[i];
      integer j = i - 1;
      while (j >= 0 && current.index < breakdownList[j].index) {
        breakdownList[j + 1] = breakdownList[j];
        j--;
      }
      // at this point we've exited, so j is either -1
      // or it's at the first element where current >= a[j]
      breakdownList[j + 1] = current;
    }
    return breakdownList;
  }

  @AuraEnabled
  public static Boolean addColorInDb(
    String recId,
    List<String> color,
    String estimateId
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Color__c, Estimate__c, OpportunityLineItem__c
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
      newColor.OpportunityLineItem__c = priceDetails.OpportunityLineItem__c;
      insert newColor;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addColorInDb--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static List<EstimatePopupDetails> updateColor(
    String recId,
    List<String> color,
    String estimateId,
    Integer numOfrec
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Color__c, Estimate__c, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE id = :recId
      ];
      List<Id> lstEstimateIds = new List<Id>();
      lstEstimateIds.add(priceDetails.Estimate__c);
      updateEstimates(lstEstimateIds);
      priceDetails.Color__c = color[0];
      update priceDetails;
      return getEstimateRelatedOpportunityLineItems(estimateId, numOfrec);
    } catch (Exception ex) {
      System.debug('EXCEPTION IN updateColor--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static Boolean addSizeInDb(
    String recId,
    List<String> size,
    String estimateId
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Size__c, Estimate__c, OpportunityLineItem__c
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
      newSize.OpportunityLineItem__c = priceDetails.OpportunityLineItem__c;
      insert newSize;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addSizeInDb--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static List<EstimatePopupDetails> updateSize(
    String recId,
    List<String> size,
    String estimateId,
    Integer numOfrec
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Size__c, Estimate__c, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE id = :recId
      ];
      List<Id> lstEstimateIds = new List<Id>();
      lstEstimateIds.add(priceDetails.Estimate__c);
      updateEstimates(lstEstimateIds);
      priceDetails.Size__c = size[0];
      update priceDetails;
      return getEstimateRelatedOpportunityLineItems(estimateId, numOfrec);
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addSizeInDb--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static List<OppLineItemSizes> getValuesForSizePiklist(String sizeId) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Size__c, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE id = :sizeId
      ];
      List<SizeLineItem__c> sizesList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :priceDetails.OpportunityLineItem__c
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
    String priceId
  ) {
    try {
      PricingLineItem__c priceDetails = [
        SELECT Id, Color__c, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE id = :priceId
      ];
      List<ColorLineItem__c> colorsList = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :priceDetails.OpportunityLineItem__c
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
  public static Boolean saveToggleState(
    String recId,
    String objectName,
    Boolean state
  ) {
    if (objectName == 'Pricing') {
      PricingLineItem__c pricingRecord = [
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
          Subtotal_Toggle__c,
          OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE Id = :recId
      ];
      pricingRecord.Subtotal_Toggle__c = state;
      update pricingRecord;
      return true;
    } else {
      ExtraChargesEstimate__c extraCharge = [
        SELECT
          Id,
          Title__c,
          Subtotal_Toggle__c,
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
        WHERE Id = :recId
      ];
      extraCharge.Subtotal_Toggle__c = state;
      update extraCharge;
      return true;
    }
  }

  @AuraEnabled
  public static List<EstimatePopupDetails> updateValuesOfBreakdown(
    String objectName,
    String fieldToUpdate,
    String idValue,
    String updatedValue,
    String estId
  ) {
    if (objectName == 'Pricing') {
      PricingLineItem__c pricingRecord = [
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
        WHERE Id = :idValue
      ];

      Id EstimatesId = pricingRecord.OpportunityLineItem__r.Estimate__c;
      Set<Id> setEstimateIds = new Set<Id>();
      setEstimateIds.add(EstimatesId);
      Boolean dataChanged = false;
      if (fieldToUpdate == 'size') {
      } else if (fieldToUpdate == 'color') {
      } else if (fieldToUpdate == 'quantity') {
        pricingRecord.Estimated_Quantity__c = Decimal.valueOf(updatedValue);
        pricingRecord.Total__c =
          pricingRecord.Estimated_Quantity__c * pricingRecord.Retail_Price__c;
        pricingRecord.Total__c = pricingRecord.Total__c.setScale(2);
        dataChanged = true;
      } else if (fieldToUpdate == 'retailPrice') {
        pricingRecord.Retail_Price__c = (Decimal.ValueOf(updatedValue) != null
          ? Decimal.ValueOf(updatedValue)
          : 0);
        decimal priceCostCalculation = (((pricingRecord.Retail_Price__c == null)
          ? 0
          : pricingRecord.Retail_Price__c) -
        ((pricingRecord.Net_Cost__c == null ? 0 : pricingRecord.Net_Cost__c)));
        if (
          pricingRecord.Retail_Price__c != 0 &&
          pricingRecord.Retail_Price__c != null
        )
          pricingRecord.Margin__c =
            (priceCostCalculation / pricingRecord.Retail_Price__c) * 100;
        else
          pricingRecord.Margin__c = 0;
        pricingRecord.Margin__c = pricingRecord.Margin__c.setScale(2);
        pricingRecord.Retail_Price__c = pricingRecord.Retail_Price__c.setScale(
          2
        );
        pricingRecord.Total__c =
          pricingRecord.Estimated_Quantity__c * pricingRecord.Retail_Price__c;
        pricingRecord.Total__c = pricingRecord.Total__c.setScale(2);
        dataChanged = true;
      } else if (fieldToUpdate == 'cost') {
        pricingRecord.Net_Cost__c = decimal.valueOf(updatedValue);
        pricingRecord.Net_Cost__c = pricingRecord.Net_Cost__c.setScale(2);
        decimal marginCalculation = 1 - (pricingRecord.Margin__c / 100);
        pricingRecord.Retail_Price__c =
          pricingRecord.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        pricingRecord.Retail_Price__c = pricingRecord.Retail_Price__c.setScale(
          2
        );

        pricingRecord.Total__c =
          pricingRecord.Estimated_Quantity__c * pricingRecord.Retail_Price__c;
        pricingRecord.Total__c = pricingRecord.Total__c.setScale(2);
        dataChanged = true;
      } else if (fieldToUpdate == 'total') {
        pricingRecord.Retail_Price__c =
          Decimal.ValueOf(updatedValue) / pricingRecord.Estimated_Quantity__c;
        pricingRecord.Retail_Price__c = pricingRecord.Retail_Price__c
          .setScale(2);
        pricingRecord.Total__c = Decimal.ValueOf(updatedValue);
        dataChanged = true;
      }

      if (dataChanged == true) {
        List<Id> lstEstimate = new List<Id>();
        for (Id keyId : setEstimateIds) {
          lstEstimate.add(keyId);
        }
        updateEstimates(lstEstimate);
      }
      update pricingRecord;
    } else {
      ExtraChargesEstimate__c extraCharge = [
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
          OpportunityLineItem__r.Estimate__c,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE Id = :idValue
      ];
      Id EstimatesId = extraCharge.OpportunityLineItem__r.Estimate__c;
      Set<Id> setEstimateIds = new Set<Id>();
      setEstimateIds.add(EstimatesId);
      Boolean dataChanged = false;
      if (fieldToUpdate == 'name') {
        extraCharge.Title__c = updatedValue;
        dataChanged = true;
      } else if (fieldToUpdate == 'quantity') {
        extraCharge.Quantity__c = Decimal.ValueOf(updatedValue);
        dataChanged = true;
      } else if (fieldToUpdate == 'retailPrice') {
        extraCharge.Retail_Price__c = Decimal.ValueOf(updatedValue);
        decimal priceCostCalculation =
          extraCharge.Retail_Price__c -
          (extraCharge.Net_Cost__c != null ? extraCharge.Net_Cost__c : 0);
        if (
          extraCharge.Retail_Price__c != null &&
          extraCharge.Retail_Price__c != 0
        )
          extraCharge.Margin__c =
            (priceCostCalculation / extraCharge.Retail_Price__c) * 100;
        else
          extraCharge.Margin__c = 0;
        extraCharge.Margin__c = extraCharge.Margin__c.setScale(2);
        extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(2);
        dataChanged = true;
      } else if (fieldToUpdate == 'cost') {
        extraCharge.Net_Cost__c = decimal.valueOf(updatedValue);
        extraCharge.Net_Cost__c = extraCharge.Net_Cost__c.setScale(2);
        decimal marginCalculation = 1 - (extraCharge.Margin__c / 100);
        extraCharge.Retail_Price__c =
          extraCharge.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(2);
        dataChanged = true;
      } else if (fieldToUpdate == 'total') {
        extraCharge.Retail_Price__c =
          Decimal.ValueOf(updatedValue) / extraCharge.Quantity__c;
        extraCharge.Retail_Price__c = extraCharge.Retail_Price__c.setScale(2);
        extraCharge.Total__c = Decimal.ValueOf(updatedValue);
        dataChanged = true;
      }
      if (dataChanged == true) {
        List<Id> lstEstimate = new List<Id>();
        for (Id keyId : setEstimateIds) {
          lstEstimate.add(keyId);
        }
        updateEstimates(lstEstimate);
      }
      update extraCharge;
    }
    return getEstimateRelatedOpportunityLineItems(estId, null);
  }
  @AuraEnabled
  public static String getSyncedAccountName(Id estId) {
    List<Estimate__c> est = [
      SELECT Id, Selected_Quickbook_Instance__c
      FROM Estimate__c
      WHERE Id = :estId
    ];
    if (est != null && est.size() > 0) {
      return est[0].Selected_Quickbook_Instance__c;
    }
    return null;
  }

  @AuraEnabled
  public static Decimal getOpportunityAmountValue(String estId) {
    Estimate__c estimate = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Id = :estId
    ];
    if (estimate != null) {
      Opportunity opp = [
        SELECT Id, Amount
        FROM Opportunity
        WHERE Id = :estimate.Opportunity__c
      ];
      return opp.Amount;
    } else
      return null;
  }

  @AuraEnabled
  public static Integer getCountOfEstimateOppLineItems(Id estId) {
    return [
        SELECT Id
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :estId
      ]
      .size();
  }

  @AuraEnabled
  public static boolean deleteOpportunityLineItemInDb(String estId) {
    try {
      OpportunityLineItem__c opportunityLine = [
        SELECT Id, Name, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id = :estId
      ];

      delete opportunityLine;

      List<ID> ListEstimates = new List<ID>();
      ListEstimates.add(opportunityLine.Estimate__c);

      updateEstimates(ListEstimates);

      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return false;
    }
  }

  @AuraEnabled
  public static String getEstimatePreviewLink(String recId) {
    try {
      Estimate__c estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      List<OpportunityLineItem__c> opportunityLine = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Estimate__c = :recId
      ];
      if (opportunityLine.size() > 0) {
        return URL.getSalesforceBaseUrl().toExternalForm() +
          '/apex/OpportunityEstimatePreview?id=' +
          estimate.Opportunity__c;
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
  public static String getOpportunityId(String recId) {
    try {
      Estimate__c estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      if (estimate.Opportunity__c != null) {
        return estimate.Opportunity__c;
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
  public static String getNotSyncedEstimate(String recId) {
    try {
      List<Estimate__c> lstEstimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE
          id = :recId
          AND Selected_Quickbook_Instance__c != 'Phun for All'
          AND (QB_Update__c = TRUE
          OR Data_Changed__c = TRUE)
      ];
      if (lstEstimate.size() > 0) {
        return 'Please synchronize the estimate with Quickbooks using "Sync Estimate" in Actions';
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static String getOpportunityStage(String recid) {
    try {
      Estimate__c estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      Opportunity opp = [
        SELECT Id, stageName
        FROM Opportunity
        WHERE Id = :estimate.Opportunity__c
      ];
      return opp.stageName;
    } catch (Exception ex) {
      System.debug('Error in getting stage ---->>>>>' + ex.getMessage());
      return null;
    }
  }

  @AuraEnabled
  public static Boolean deleteEstimates(String recid) {
    try {
      delete [SELECT id FROM Estimate__c WHERE id = :recid];
      return true;
    } catch (Exception ex) {
      System.debug('Error in deleting estimate ---->>>>>' + ex.getMessage());
      return null;
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
  public static Boolean syncEstimates(String recid) {
    try {
      List<Estimate__c> lstEstimate = [
        SELECT Id, Opportunity__c, QB_Update__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      List<Id> lstOppIds = new List<Id>();
      for (Estimate__c est : lstEstimate) {
        est.QB_Update__c = true;
        lstOppIds.add(est.Opportunity__c);
      }
      List<Opportunity> lstOpp = [
        SELECT id
        FROM Opportunity
        WHERE id = :lstOppIds
      ];
      if (lstOpp.size() > 0 && lstEstimate.size() > 0) {
        update lstEstimate;
        update lstOpp;
      }
      return true;
    } catch (Exception ex) {
      System.debug('Error in syncing estimate ---->>>>>' + ex.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static List<String> getEstimateStatus(String recId) {
    try {
      Estimate__c estimate = [
        SELECT Id, Client_Approval_Status__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      if (estimate != null) {
        List<String> response = new List<String>();
        response.add(
          URL.getSalesforceBaseUrl().toExternalForm() +
            '/lightning/r/Estimate__c/' +
            recId +
            '/view'
        );
        if (estimate.Client_Approval_Status__c == null) {
          response.add('Estimate is not Approved yet.');
        } else if (estimate.Client_Approval_Status__c == 'Approved') {
          response.add('Estimate is Approved. ');
        } else if (estimate.Client_Approval_Status__c == 'Change Requested') {
          response.add('Change Requested');
        }
        if (response.size() > 0)
          return response;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Error in getting status estimate ---->>>>>' + ex.getMessage()
      );
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
          Quantity_Estimate__c,
          qbo_product_service_id__c
        FROM OpportunityLineItem__c
        WHERE Id = :recId
      ];
      List<PricingLineItem__c> PricingRecords = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          index__c,
          Color__c,
          Size__c,
          Subtotal_Toggle__c,
          Estimated_Quantity__c,
          Display__c,
          Net_Cost__c,
          Retail_Price__c,
          Total__c,
          Margin__c,
          Default__c,
          Credit_Available__c,
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
      List<ExtraChargesEstimate__c> runChargesOfArtworks = [
        SELECT
          Id,
          Title__c,
          index__c,
          Quantity__c,
          Subtotal_Toggle__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Credit_Available__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem_ArtWork__r.Title__c,
          OpportunityLineItem_ArtWork__r.Id,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = TRUE
          AND OpportunityLineItem_ArtWork__c = :opportunityLineItemArtworkList
      ];
      Map<Id, List<ExtraChargesEstimate__c>> artworkAndRunChargesMap = new Map<Id, List<ExtraChargesEstimate__c>>();
      List<ExtraChargesEstimate__c> clonedRunChargesList = new List<ExtraChargesEstimate__c>();

      if (opportunityLineItemArtworkList.Size() > 0) {
        if (runChargesOfArtworks.Size() > 0) {
          for (
            OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
          ) {
            List<ExtraChargesEstimate__c> runChargesRelatedToArtwork = new List<ExtraChargesEstimate__c>();
            for (ExtraChargesEstimate__c runCharge : runChargesOfArtworks) {
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
          List<ExtraChargesEstimate__c> runChargesToBeCloned = new List<ExtraChargesEstimate__c>();
          runChargesToBeCloned = artworkAndRunChargesMap.get(artwork.Id);
          if (runChargesToBeCloned != null && runChargesToBeCloned.Size() > 0) {
            for (ExtraChargesEstimate__c runCharge : runChargesToBeCloned) {
              if (
                runCharge.OpportunityLineItem__c ==
                artwork.OpportunityLineItem__c
              ) {
                ExtraChargesEstimate__c clonedRunCharge = runCharge.clone();
                clonedRunCharge.OpportunityLineItem__c = newOpp.Id;
                clonedRunCharge.OpportunityLineItem_ArtWork__c = oldArtworkId_newArtWork_Map.get(
                  artwork.Id
                );
                clonedRunChargesList.Add(clonedRunCharge);
              }
            }
          }
        }
        if (clonedRunChargesList != null && clonedRunChargesList.size() > 0)
          insert clonedRunChargesList;
      }

      /// Copy fixed and run charges
      List<ExtraChargesEstimate__c> runChargesOfOppLineItem = [
        SELECT
          Id,
          Title__c,
          index__c,
          Quantity__c,
          Subtotal_Toggle__c,
          Charge_Type__c,
          Margin__c,
          Retail_Price__c,
          Total__c,
          Display__c,
          Duty_Percentage__c,
          Credit_Available__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem_ArtWork__r.Title__c,
          OpportunityLineItem_ArtWork__r.Id,
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE
          Is_Associated_With_Artwork__c = FALSE
          AND OpportunityLineItem__c = :recId
      ];

      List<ExtraChargesEstimate__c> clonedRunChargesListNew = new List<ExtraChargesEstimate__c>();
      if (
        runChargesOfOppLineItem != null &&
        runChargesOfOppLineItem.Size() > 0
      ) {
        for (ExtraChargesEstimate__c runCharge : runChargesOfOppLineItem) {
          ExtraChargesEstimate__c clonedRunCharge = runCharge.clone();
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

      //Update the estimates
      Set<ID> SetEstimates = new Set<ID>();
      for (OpportunityLineItem__c opp : lineItem) {
        SetEstimates.add(opp.Estimate__c);
      }
      List<ID> ListEstimates = new List<ID>(SetEstimates);
      updateEstimates(ListEstimates);

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

  /*
        This function will update the Inline Estimate on Opportunity.
    */
  @AuraEnabled
  public static void updateEstimatesOppLineItemInline(string recordData) {
    Map<String, Object> updatedData = new Map<String, Object>();
    Map<String, Object> pricingData = new Map<String, Object>();
    Map<String, Object> extraChargeData = new Map<String, Object>();
    Set<ID> lstEstimatesProduct = new Set<ID>();
    Set<ID> lstEstimatesExtraCharge = new Set<ID>();

    try {
      updatedData = (Map<String, Object>) JSON.deserializeUntyped(recordData);
      for (String key : updatedData.keySet()) {
        if (key == 'Pricing') {
          pricingData = (Map<String, Object>) updatedData.get(key);
        } else if (key == 'extraCharge') {
          extraChargeData = (Map<String, Object>) updatedData.get(key);
        }
      }
      if (pricingData.size() != 0) {
        lstEstimatesProduct = updateProductPricing(pricingData);
      }
      if (extraChargeData.size() != 0) {
        lstEstimatesExtraCharge = updateProductExtraCharge(extraChargeData);
      }
      if (
        lstEstimatesProduct.size() != 0 ||
        lstEstimatesExtraCharge.size() != 0
      ) {
        Set<ID> allEstimatesSet = new Set<ID>();

        for (ID estimatesProduct : lstEstimatesProduct) {
          allEstimatesSet.add(estimatesProduct);
        }
        for (ID estimatesExtraCharge : lstEstimatesExtraCharge) {
          allEstimatesSet.add(estimatesExtraCharge);
        }

        List<ID> allEstimatesList = new List<ID>(allEstimatesSet);

        if (allEstimatesList.size() != 0) {
          updateEstimates(allEstimatesList);
        }
      }
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /*
        This function will update the Pricing of Product.
    */
  public static Set<Id> updateProductPricing(Map<String, Object> pricingData) {
    List<ID> pricingIds = new List<ID>();
    Id EstimatesId;
    Set<Id> setEstimateIds = new Set<Id>();
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
      EstimatesId = pricingRecord.OpportunityLineItem__r.Estimate__c;
      setEstimateIds.add(EstimatesId);
      if (
        priceLineItem.get('quantity') != pricingRecord.Estimated_Quantity__c &&
        priceLineItem.get('quantity') != null
      ) {
        pricingRecord.Estimated_Quantity__c = Decimal.valueOf(
            (String) priceLineItem.get('quantity')
          )
          .setScale(0);
        dataChanged = true;
      }
      if (
        priceLineItem.get('cost') != pricingRecord.Net_Cost__c &&
        priceLineItem.get('cost') != null
      ) {
        pricingRecord.Net_Cost__c = Decimal.valueOf(
            (String) priceLineItem.get('cost')
          )
          .setScale(3);
        decimal marginCalculation = 1 - (pricingRecord.Margin__c / 100);
        pricingRecord.Retail_Price__c =
          pricingRecord.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        pricingRecord.Retail_Price__c = pricingRecord.Retail_Price__c.setScale(
          3
        );
        dataChanged = true;
      }
      if (
        priceLineItem.get('retailPrice') != pricingRecord.Retail_Price__c &&
        priceLineItem.get('retailPrice') != null
      ) {
        pricingRecord.Retail_Price__c = Decimal.valueOf(
            (String) priceLineItem.get('retailPrice')
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
          pricingRecord.Margin__c =
            (priceCostCalculation / pricingRecord.Retail_Price__c) * 100;
        else
          pricingRecord.Margin__c = 0;
        pricingRecord.Margin__c = pricingRecord.Margin__c.setScale(3);
        dataChanged = true;
      }
      pricingRecord.Total__c = (pricingRecord.Estimated_Quantity__c *
        pricingRecord.Retail_Price__c)
        .setScale(3);
    }
    if (dataChanged == true) {
      update pricingRecords;
    }
    return setEstimateIds;
  }
  /*
        This function will update the Extra Charge on a Product.
    */
  public static Set<Id> updateProductExtraCharge(
    Map<String, Object> extraChargeData
  ) {
    List<ID> extraChargeIDs = new List<ID>();
    Id EstimatesId;
    Set<Id> setEstimateIds = new Set<Id>();
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
        Net_Cost__c,
        OpportunityLineItem__r.Estimate__c
      FROM ExtraChargesEstimate__c
      WHERE Id IN :extraChargeIDs
    ];

    for (ExtraChargesEstimate__c extraChargeRecord : extraChargeRecords) {
      Map<String, Object> extraChargeLineItem = (Map<String, Object>) extraChargeData.get(
        extraChargeRecord.id
      );
      EstimatesId = extraChargeRecord.OpportunityLineItem__r.Estimate__c;
      setEstimateIds.add(EstimatesId);
      if (
        extraChargeLineItem.get('name') != extraChargeRecord.Title__c &&
        extraChargeLineItem.get('name') != null
      ) {
        extraChargeRecord.Title__c = (String) extraChargeLineItem.get('name');
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('quantity') != extraChargeRecord.Quantity__c &&
        extraChargeLineItem.get('quantity') != null
      ) {
        extraChargeRecord.Quantity__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('quantity')
          )
          .setScale(0);
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('cost') != extraChargeRecord.Net_Cost__c &&
        extraChargeLineItem.get('cost') != null
      ) {
        extraChargeRecord.Net_Cost__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('cost')
          )
          .setScale(3);
        decimal marginCalculation = 1 - (extraChargeRecord.Margin__c / 100);
        extraChargeRecord.Retail_Price__c =
          extraChargeRecord.Net_Cost__c /
          (marginCalculation != 0 ? marginCalculation : 1);
        extraChargeRecord.Retail_Price__c = extraChargeRecord.Retail_Price__c.setScale(
          3
        );
        dataChanged = true;
      }
      if (
        extraChargeLineItem.get('retailPrice') !=
        extraChargeRecord.Retail_Price__c &&
        extraChargeLineItem.get('retailPrice') != null
      ) {
        extraChargeRecord.Retail_Price__c = Decimal.valueOf(
            (String) extraChargeLineItem.get('retailPrice')
          )
          .setScale(3);
        decimal priceCostCalculation =
          extraChargeRecord.Retail_Price__c -
          (extraChargeRecord.Net_Cost__c != null
            ? extraChargeRecord.Net_Cost__c
            : 0);
        if (
          extraChargeRecord.Retail_Price__c != null &&
          extraChargeRecord.Retail_Price__c != 0
        )
          extraChargeRecord.Margin__c =
            (priceCostCalculation / extraChargeRecord.Retail_Price__c) * 100;
        else
          extraChargeRecord.Margin__c = 0;
        extraChargeRecord.Margin__c = extraChargeRecord.Margin__c.setScale(3);
        extraChargeRecord.Retail_Price__c = extraChargeRecord.Retail_Price__c.setScale(
          3
        );
        dataChanged = true;
      }
      extraChargeRecord.Total__c = (extraChargeRecord.Quantity__c *
        extraChargeRecord.Retail_Price__c)
        .setScale(3);
    }
    if (dataChanged == true) {
      update extraChargeRecords;
    }
    return setEstimateIds;
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
}
