public with sharing class AddProductTeamPhunTabController {
  @AuraEnabled
  public static boolean createOpportunityLineItem(
    String productId,
    String opportunityId,
    String estimateId,
    String recordFrom,
    String workOrderId
  ) {
    try {
      List<Color_Product__c> lst_Color_Product = new List<Color_Product__c>();
      List<Size_Product__c> lst_Size_Product = new List<Size_Product__c>();
      List<ContentDocumentLink> productRelatedImages;
      List<Id> lstEstimateIds = new List<Id>();
      List<Id> lstOppIds = new List<Id>();
      productRelatedImages = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :productId AND LinkedEntity.Type = 'Product2'
      ];
      Product2 relatedProduct = [
        SELECT
          Id,
          Name,
          Product_Cost__c,
          productBrand__c,
          Sales_Tax_Category__c,
          Sales_Price_Rate__c,
          productCategory__c,
          Description,
          Purchasing_Info__c,
          Supplier__c,
          Design_Project__c,
          Product_Supplier_Code__c,
          Net_Price__c,
          CommonSku_Id__c,
          commonSkuVariantId__c,
          Supplier_Name_Esp__c,
          qbo_product_service_id__c
        FROM Product2
        WHERE id = :productId
      ];
      List<Pricing_Product__c> productPricing = [
        SELECT Id, Product__c, Quantity__c, Net_Cost__c, Retail_Price__c
        FROM Pricing_Product__c
        WHERE Product__c = :productId
      ];
      lst_Color_Product = [
        SELECT Id, Color__c, Name, Product__c, Image__c
        FROM Color_Product__c
        WHERE Product__c = :productId
      ];
      lst_Size_Product = [
        SELECT Id, Size__c, Name, Product__c
        FROM Size_Product__c
        WHERE Product__c = :productId
      ];
      //create oppo line item record from the selected product
      OpportunityLineItem__c opportunityLineItem = new OpportunityLineItem__c();
      opportunityLineItem.Product__c = relatedProduct.id;
      opportunityLineItem.Name = relatedProduct.Name;
      opportunityLineItem.Description__c = relatedProduct.Description;
      opportunityLineItem.Supplier__c = relatedProduct.Supplier__c;
      opportunityLineItem.isProductFromESP__c = true;
      //qbo product service id is being saved here so that we could link line item with correct product and service id
      opportunityLineItem.qbo_product_service_id__c = relatedProduct.qbo_product_service_id__c;
      if (recordFrom == 'Opportunity') {
        opportunityLineItem.Opportunity__c = opportunityId;
      } else if (recordFrom == 'Estimate') {
        opportunityLineItem.Estimate__c = estimateId;
        lstEstimateIds.add(Id.valueOf(estimateId));
      }
      //if the adding product coming from Sales Order Tab of Work Order module
      //then attach oppo line item with work order
      else if (recordFrom == 'SalesOrder') {
        opportunityLineItem.Work_Order__c = workOrderId;
        opportunityLineItem.Estimate__c = null;
        //create empty shipping information record for newly added product in SalesOrder from Team Phun or Design tab
        Shipping_Information__c shippingInformationObj = new Shipping_Information__c();
        insert shippingInformationObj;
        opportunityLineItem.Shipping_Information__c = shippingInformationObj.id;
      }

      insert opportunityLineItem;
      if (lstEstimateIds.size() > 0) {
        List<Estimate__c> lstEstimates = [
          SELECT id, QB_Update__c, Data_Changed__c
          FROM Estimate__c
          WHERE id IN :lstEstimateIds
        ];
        for (Estimate__c est : lstEstimates) {
          est.QB_Update__c = true;
          est.Data_Changed__c = true;
        }
        update lstEstimates;
      }
      //to replicate product pricing records and link them with the oppo line item
      List<PricingLineItem__c> lineItemPricings = new List<PricingLineItem__c>();
      for (Pricing_Product__c pricing : productPricing) {
        PricingLineItem__c newPriceToAdd = new PricingLineItem__c();
        newPriceToAdd.Margin__c = 0;
        newPriceToAdd.OpportunityLineItem__c = opportunityLineItem.Id;
        newPriceToAdd.Quantity__c = pricing.Quantity__c;
        newPriceToAdd.Net_Cost__c = pricing.Net_Cost__c;
        newPriceToAdd.Retail_Price__c = pricing.Retail_Price__c;
        if (newPriceToAdd.Net_Cost__c != null) {
          newPriceToAdd.Show_To_Client__c = true;
        }
        if (Label.Default_Margin_Value != null) {
          if (newPriceToAdd.Retail_Price__c == null) {
            newPriceToAdd.Retail_Price__c = 0;
          }
          if (newPriceToAdd.Net_Cost__c == null) {
            newPriceToAdd.Net_Cost__c = 0;
          }
          decimal priceCostCalculation =
            newPriceToAdd.Retail_Price__c - newPriceToAdd.Net_Cost__c;
          if (
            newPriceToAdd.Retail_Price__c != null &&
            newPriceToAdd.Retail_Price__c != 0
          ) {
            newPriceToAdd.Margin__c =
              (priceCostCalculation / newPriceToAdd.Retail_Price__c) * 100;
          } else {
            newPriceToAdd.Margin__c = 0;
          }
          newPriceToAdd.Margin__c = newPriceToAdd.Margin__c.setScale(2);
          newPriceToAdd.Total__c =
            newPriceToAdd.Quantity__c * newPriceToAdd.Retail_Price__c;
          decimal marginCalculation = 1 - (newPriceToAdd.Margin__c / 100);
          if (marginCalculation != 0) {
            newPriceToAdd.Price_Per_Unit__c =
              newPriceToAdd.Net_Cost__c / marginCalculation;
            newPriceToAdd.Price_Per_Unit__c = newPriceToAdd.Price_Per_Unit__c.setScale(
              2
            );
          }
        }
        lineItemPricings.add(newPriceToAdd);
      }
      insert lineItemPricings;

      //if the selected product have linked pricing records then create pricing record from
      //the 1st pricing record and mark it as default at the estimate or slaes order stage that will used for the edit
      if (
        productPricing != null &&
        productPricing.Size() > 0 &&
        (recordFrom == 'Estimate' ||
        recordFrom == 'SalesOrder')
      ) {
        Integer index = 0;
        List<PricingLineItem__c> pricingRecordListToBeUsedInEstimate = new List<PricingLineItem__c>();
        PricingLineItem__c newRecord = new PricingLineItem__c();
        newRecord.Estimated_Quantity__c = 1;
        newRecord.Margin__c = 0.00;
        newRecord.Quantity__c = 0;

        newRecord.Net_Cost__c = productPricing.get(index).Net_Cost__c;
        newRecord.Retail_Price__c = productPricing.get(index).Retail_Price__c;

        newRecord.Total__c = productPricing.get(index).Retail_Price__c;
        newRecord.OpportunityLineItem__c = opportunityLineItem.Id;
        newRecord.Display__c = true;
        newRecord.Default__c = false;
        if (lst_Size_Product.size() == 1) {
          newRecord.Size__c = lst_Size_Product.get(0).Size__c;
        }
        if (lst_Color_Product.size() == 1) {
          newRecord.Color__c = lst_Color_Product.get(0).Color__c;
        }
        newRecord.Estimate__c = estimateId;
        pricingRecordListToBeUsedInEstimate.add(newRecord);

        PricingLineItem__c newDefaultRecordToUseInEdit = new PricingLineItem__c();
        newDefaultRecordToUseInEdit.Estimated_Quantity__c = 1;
        newDefaultRecordToUseInEdit.Margin__c = 0.00;
        newDefaultRecordToUseInEdit.Quantity__c = 0;
        newDefaultRecordToUseInEdit.Net_Cost__c = productPricing.get(index)
          .Net_Cost__c;
        newDefaultRecordToUseInEdit.Retail_Price__c = productPricing.get(index)
          .Retail_Price__c;

        newDefaultRecordToUseInEdit.Total__c = productPricing.get(index)
          .Retail_Price__c;
        newDefaultRecordToUseInEdit.OpportunityLineItem__c = opportunityLineItem.Id;
        newDefaultRecordToUseInEdit.Display__c = true;
        newDefaultRecordToUseInEdit.Default__c = true;
        if (lst_Size_Product.size() == 1) {
          newDefaultRecordToUseInEdit.Size__c = lst_Size_Product.get(0).Size__c;
        }
        if (lst_Color_Product.size() == 1) {
          newDefaultRecordToUseInEdit.Color__c = lst_Color_Product.get(0)
            .Color__c;
        }
        newDefaultRecordToUseInEdit.Estimate__c = estimateId;
        pricingRecordListToBeUsedInEstimate.add(newDefaultRecordToUseInEdit);

        insert pricingRecordListToBeUsedInEstimate;
      }
      //if the selected product doesn't have linked pricing record then create pricing records
      // at the estimate or Sales Order stage that will used for the edit
      else if (recordFrom == 'Estimate' || recordFrom == 'SalesOrder') {
        List<PricingLineItem__c> pricingRecordListToBeUsedInEstimate = new List<PricingLineItem__c>();

        PricingLineItem__c newRecord = new PricingLineItem__c();
        newRecord.Estimated_Quantity__c = 1;
        newRecord.Margin__c = 0.00;
        newRecord.Quantity__c = 0;

        newRecord.Net_Cost__c = 0;
        newRecord.Retail_Price__c = 0;

        newRecord.Total__c = 0;
        newRecord.OpportunityLineItem__c = opportunityLineItem.Id;
        newRecord.Display__c = true;
        newRecord.Default__c = false;
        if (recordFrom == 'Estimate') {
          newRecord.Estimate__c = estimateId;
        }
        pricingRecordListToBeUsedInEstimate.add(newRecord);

        PricingLineItem__c newDefaultRecordToUseInEdit = new PricingLineItem__c();
        newDefaultRecordToUseInEdit.Estimated_Quantity__c = 1;
        newDefaultRecordToUseInEdit.Margin__c = 0.00;
        newDefaultRecordToUseInEdit.Quantity__c = 0;
        newDefaultRecordToUseInEdit.Net_Cost__c = 0;
        newDefaultRecordToUseInEdit.Retail_Price__c = 0;

        newDefaultRecordToUseInEdit.Total__c = 0;
        newDefaultRecordToUseInEdit.OpportunityLineItem__c = opportunityLineItem.Id;
        newDefaultRecordToUseInEdit.Display__c = true;
        newDefaultRecordToUseInEdit.Default__c = true;
        if (recordFrom == 'Estimate') {
          newDefaultRecordToUseInEdit.Estimate__c = estimateId;
        }
        pricingRecordListToBeUsedInEstimate.add(newDefaultRecordToUseInEdit);
        insert pricingRecordListToBeUsedInEstimate;
      }
      OpportunityLineItemAttachment__c attachment = new OpportunityLineItemAttachment__c();
      attachment.OpportunityLineItem__c = opportunityLineItem.Id;
      insert attachment;

      List<ColorLineItem__c> lstColorsLineItem = new List<ColorLineItem__c>();
      List<SizeLineItem__c> lstSizesLineItem = new List<SizeLineItem__c>();
      for (Color_Product__c colorObj : lst_Color_Product) {
        ColorLineItem__c colorsLineItem = new ColorLineItem__c();

        colorsLineItem.Color__c = colorObj.Color__c;
        colorsLineItem.OpportunityLineItem__c = opportunityLineItem.id;
        colorsLineItem.isSelected__c = true;
        lstColorsLineItem.add(colorsLineItem);
      }
      insert lstColorsLineItem;
      for (Size_Product__c sizeObj : lst_Size_Product) {
        SizeLineItem__c sizeLineItem = new SizeLineItem__c();
        sizeLineItem.Size__c = sizeObj.Size__c;
        sizeLineItem.isSelected__c = true;
        sizeLineItem.OpportunityLineItem__c = opportunityLineItem.id;
        lstSizesLineItem.add(sizeLineItem);
      }
      insert lstSizesLineItem;

      List<ContentDocumentLink> opportunityLineItemRelatedImages = new List<ContentDocumentLink>();
      for (ContentDocumentLink image : productRelatedImages) {
        ContentDocumentLink img = new ContentDocumentLink();
        img.ContentDocumentId = image.ContentDocumentId;
        img.LinkedEntityId = attachment.Id;
        img.ShareType = 'V';
        opportunityLineItemRelatedImages.add(img);
      }
      insert opportunityLineItemRelatedImages;
      if (recordFrom == 'SalesOrder') {
        SalesOrderOppLineItemController.updateSalesOrderSyncStatus(
          workOrderId,
          false
        );
        EditOpporLineItemInSalesOrderController.updateWorkOrder(workOrderId);
      }
      return true;
    } catch (Exception Ex) {
      System.debug(
        'Exception in Create Opportunity Line Item -->>>>>>' + Ex.getMessage()
      );
      return false;
    }
  }
  @AuraEnabled
  public static String getOpportunityId(string recId) {
    try {
      List<Estimate__c> estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE id = :recId
      ];
      if (estimate != null && estimate.size() > 0) {
        if (estimate[0].Opportunity__c != null) {
          return estimate[0].Opportunity__c;
        } else {
          return recId;
        }
      } else {
        return recId;
      }
    } catch (Exception ex) {
      System.debug(
        'Error in deleting Opportunity Line Item ---->>>>>' + ex.getMessage()
      );
      return 'false';
    }
  }
  @AuraEnabled
  public static List<QueriedProducts> getSearchResults(
    String netMin,
    String netMax,
    String supplier,
    String searchName,
    String offset,
    String tabName
  ) {
    try {
      integer netMinimum;
      integer netMaximum;
      List<QueriedProducts> finalListOfProductsWithAttatchmentIds = new List<QueriedProducts>();
      List<Product2> queriedProducts;
      List<ContentDocumentLink> productRelatedImages;
      List<Color_Product__c> productColors;
      List<Size_Product__c> productSizes;
      String query =
        'Select id,Name,IsActive,Product_Cost__c,Description,ProductCode,CommonSku_Id__c,Design_Project__c,Product_Supplier_Code__c,productBrand__c,Supplier__c,Net_Price__c ' +
        'From Product2 ';
      Map<String, String> conditions = new Map<String, String>();
      if (supplier != null && supplier != '') {
        conditions.put('supplier', '\'%' + supplier + '%\'');
      }
      if (searchName != null && searchName != '') {
        conditions.put('searchName', '\'%' + searchName + '%\'');
      }
      if (netMin != null && netMin != '') {
        conditions.put('min', netMin);
      }
      if (netMax != null && netMax != '') {
        conditions.put('max', netMax);
      }
      Integer count = 0;
      if (conditions.size() > 0) {
        query += ' Where ';
        //////////////////

        ///////////////////
        for (String key : conditions.KeySet()) {
          if (key == 'supplier') {
            if (count != 0) {
              query += ' AND Supplier__c like ' + conditions.get(key) + ' ';
              count++;
            } else {
              query += ' Supplier__c like ' + conditions.get(key) + ' ';
              count++;
            }
          } else if (key == 'searchName') {
            if (count != 0) {
              query += ' AND Name like ' + conditions.get(key) + ' ';
              count++;
            } else {
              query += ' Name like ' + conditions.get(key) + ' ';
              count++;
            }
          } else if (key == 'min') {
            if (count != 0) {
              query +=
                ' AND Net_Price__c >= ' +
                Decimal.ValueOf(conditions.get(key)) +
                ' ';
              count++;
            } else {
              query +=
                ' Net_Price__c >= ' +
                Decimal.ValueOf(conditions.get(key)) +
                ' ';
              count++;
            }
          } else if (key == 'max') {
            if (count != 0) {
              query +=
                ' AND Net_Price__c <= ' +
                Decimal.ValueOf(conditions.get(key)) +
                ' ';
              count++;
            } else {
              query +=
                ' Net_Price__c <= ' +
                Decimal.ValueOf(conditions.get(key)) +
                ' ';
              count++;
            }
          }
        }
      }
      // String offset = '0';
      if (count != 0) {
        query += ' AND IsActive = true AND CommonSku_Id__c = null ';
      } else {
        query += 'Where IsActive = true AND CommonSku_Id__c = null ';
      }
      if (tabName == 'designproduct') {
        query += ' AND Design_Project__c = true  ';
      } else {
        query += ' AND Design_Project__c = false ';
      }
      List<Product2> queriedProductsTotalCount = Database.query(query);
      Integer valueOffset = Integer.valueOf(offset) - 1;
      query += ' ORDER BY name Limit 24 OFFSET ' + valueOffset;
      System.debug(query);
      queriedProducts = Database.query(query);

      if (queriedProducts != null && queriedProducts.Size() > 0) {
        List<id> ids = new List<id>();
        for (Product2 p : queriedProducts) {
          ids.add(p.id);
        }

        productRelatedImages = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :ids AND LinkedEntity.Type = 'Product2'
        ];
        productsizes = [
          SELECT Size__c, Product__c
          FROM Size_Product__c
          WHERE Product__c IN :ids
        ];
        productcolors = [
          SELECT Color__c, Product__c
          FROM Color_Product__c
          WHERE Product__c IN :ids
        ];
        List<Pricing_Product__c> productPrices = [
          SELECT Net_Cost__c, Product__c, Quantity__c, Retail_Price__c
          FROM Pricing_Product__c
          WHERE Product__c IN :ids
        ];

        Map<Id, Id> mapContentLink_ContentVersion = new Map<Id, Id>();
        List<Id> lstContentDocumentIds = new List<Id>();
        for (ContentDocumentLink obj : productRelatedImages) {
          lstContentDocumentIds.add(obj.ContentDocumentId);
        }
        List<ContentVersion> productRelatedImageFiles = [
          SELECT id, ContentDocumentId
          FROM ContentVersion
          WHERE
            ContentDocumentId IN :lstContentDocumentIds
            AND FileType != 'PDF'
        ];
        for (ContentVersion contentVersion : productRelatedImageFiles) {
          mapContentLink_ContentVersion.put(
            contentVersion.ContentDocumentId,
            contentVersion.id
          );
        }

        for (Product2 product : queriedProducts) {
          QueriedProducts p = new QueriedProducts();
          p.id = product.id == null ? null : product.id;
          p.name = product.Name == null ? null : product.Name;
          p.ProductCode = product.ProductCode == null
            ? null
            : product.ProductCode;

          p.description = product.Description == null
            ? null
            : product.Description;
          p.productSupplierCode = product.Product_Supplier_Code__c == null
            ? null
            : product.Product_Supplier_Code__c;
          p.productBrand = product.productBrand__c == null
            ? null
            : product.productBrand__c;
          p.supplier = product.Supplier__c == null ? null : product.Supplier__c;
          p.commonSkuId = product.CommonSku_Id__c == null
            ? null
            : product.CommonSku_Id__c;

          p.netPrice = product.Net_Price__c == null
            ? null
            : product.Net_Price__c;
          p.productCost = product.Product_Cost__c == null
            ? null
            : product.Product_Cost__c;
          p.profit =
            (p.netPrice == null ? 0 : p.netPrice) -
            (p.productCost == null ? 0 : p.productCost);
          String productColorTemp = '';
          for (Color_Product__c prodColor : productColors) {
            if (prodColor.Product__c == p.id) {
              productColorTemp =
                productColorTemp +
                ' ' +
                prodColor.Color__c +
                ',';
            }
          }
          for (Pricing_Product__c prodPrice : productPrices) {
            if (prodPrice.Product__c == p.id) {
              ProductPrice newPrice = new ProductPrice();
              newPrice.cost = prodPrice.Net_Cost__c;
              newPrice.price = prodPrice.Retail_Price__c;
              newPrice.quantity = prodPrice.Quantity__c;
              if (newPrice.cost != null && newPrice.price != null)
                newPrice.profit = newPrice.price - newPrice.cost;
              p.prices.add(newPrice);
            }
          }

          p.productColor = productColorTemp.removeEnd(',');
          String ProductSizeTemp = '';
          for (Size_Product__c prodSize : productSizes) {
            if (prodSize.Product__c == p.id) {
              ProductSizeTemp = ProductSizeTemp + +prodSize.Size__c + ',';
            }
          }
          p.productSize = ProductSizeTemp.removeEnd(',');
          for (ContentDocumentLink attatchment : productRelatedImages) {
            if (attatchment.LinkedEntityId == p.id) {
              if (
                mapContentLink_ContentVersion.containskey(
                  attatchment.ContentDocumentid
                )
              ) {
                p.attatchmentIds.add(
                  mapContentLink_ContentVersion.get(
                    attatchment.ContentDocumentid
                  )
                );
              }
            }
          }
          if (p.attatchmentIds.size() > 0) {
            //TODO : Purpose?
            p.imageUrl = p.attatchmentIds.get(0);
            // p.attatchmentIds.remove(0);
          }
          p.totalProducts = String.valueOf(queriedProductsTotalCount.size());
          finalListOfProductsWithAttatchmentIds.add(p);
        }

        return finalListOfProductsWithAttatchmentIds;
      }
      return null;
    } catch (Exception ex) {
      System.debug(
        'Exception is ->>>>>>>>>>>>>>>>>>>>>>>>>' +
          ex.getMessage() +
          ' ' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
}
