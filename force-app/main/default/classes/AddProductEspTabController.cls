public with sharing class AddProductEspTabController {
  @AuraEnabled
  public static ESPProducts getSearchResultsFromESP(
    String searchName,
    String supplier,
    String netMin,
    String netMax,
    String market,
    String FilterCategories,
    String FilterColors,
    String FilterImprintingMethods,
    String FilterLineNames,
    String FilterPrices,
    String FilterSizes,
    String FilterSuppliers,
    String FilterMaterials,
    String FilterStates,
    String FilterAsiNumbers,
    String FilterThemes,
    String FilterTradeNames,
    String FilterShapes,
    String sortType,
    String newFilter,
    String fullColorProcessFilter,
    String madeInUSAFilter,
    String canadianFriendFilter,
    String canadianPricedFilter,
    String minQuantity,
    String FilterProdTime,
    String FilterPreferred,
    Integer pageToDisplay,
    String rating
  ) {
    String finalQuery;
    finalQuery = searchName;
    String Costprice;
    Costprice = '';
    if (FilterPrices != null) {
      String finalPrice;
      finalPrice = FilterPrices.replace('$', '');
      finalPrice = finalPrice.replaceAll('-', 'to');
      if (finalPrice.contains('and Over')) {
        finalPrice = finalPrice.replaceAll('and Over', 'to');
      }
      if (finalPrice.contains('and Under')) {
        finalPrice = finalPrice.replaceAll('and Under', '');
        finalPrice = 'to ' + finalPrice;
      }
      Costprice = '[' + finalPrice + ']';
    }
    string tier1Filter =
      ((FilterCategories != null &&
        FilterCategories.length() > 0 &&
        FilterCategories != '--')
        ? ' category:' + FilterCategories + ' '
        : '') +
      ((FilterColors != null &&
        FilterColors.length() > 0 &&
        FilterColors != '--')
        ? 'color:' + FilterColors + ' '
        : '') +
      ((FilterSizes != null &&
        FilterSizes.length() > 0 &&
        FilterSizes != '--')
        ? 'size:' + FilterSizes + ' '
        : '') +
      ((market != null &&
        market != '--')
        ? (market.equals('CAN')
            ? 'supplier_country:Canada'
            : 'supplier_country:USA') + ' '
        : '') +
      ((FilterSuppliers != null &&
        FilterSuppliers.length() > 0 &&
        FilterSuppliers != '--')
        ? 'supplier:' + FilterSuppliers + ' '
        : '') +
      ((FilterMaterials != null &&
        FilterMaterials.length() > 0 &&
        FilterMaterials != '--')
        ? 'material:' + FilterMaterials + ' '
        : '') +
      ((FilterAsiNumbers != null &&
        FilterAsiNumbers.length() > 0 &&
        FilterAsiNumbers != '--')
        ? 'asi:' + FilterAsiNumbers + ' '
        : '') +
      ((FilterPreferred != null &&
        FilterPreferred.length() > 0 &&
        FilterPreferred != '--')
        ? 'preferred:' + FilterPreferred + ' '
        : '') +
      ((minQuantity != null &&
        minQuantity.length() > 0)
        ? 'quantity:' + minQuantity + ' '
        : '') +
      ((FilterPrices != null &&
        FilterPrices.length() > 0 &&
        FilterPrices != '--')
        ? 'cost:' + Costprice + ' '
        : '') +
      ((FilterProdTime != null &&
        FilterProdTime.length() > 0)
        ? 'production_time:' + FilterProdTime + ' '
        : '') +
      +((netMin != null &&
        netMin.length() > 0)
        ? ('price:[' +
          netMin +
          ' to ' +
          ((netMax != null && netMax.length() > 0) ? netMax : '') +
          ']')
        : ((netMax != null &&
            netMax.length() > 0)
            ? 'price:[0 to ' + netMax + ']'
            : ''));
    string tier2Filter =
      ((FilterImprintingMethods != null &&
        FilterImprintingMethods.length() > 0 &&
        FilterImprintingMethods != '--')
        ? 'imprint_method:' + FilterImprintingMethods + ' '
        : '') +
      ((FilterLineNames != null &&
        FilterLineNames.length() > 0 &&
        FilterLineNames != '--')
        ? 'line_name:' + FilterLineNames + ' '
        : '') +
      //      ((FilterPrices!= null && FilterPrices!= '--') ? 'price:' + FilterPrices +' ': '') +
      ((FilterStates != null &&
        FilterStates.length() > 0 &&
        FilterStates != '--')
        ? 'supplier_state:' + FilterStates + ' '
        : '') +
      ((FilterThemes != null &&
        FilterThemes.length() > 0 &&
        FilterThemes != '--')
        ? 'theme:' + FilterThemes + ' '
        : '') +
      ((FilterTradeNames != null &&
        FilterTradeNames.length() > 0 &&
        FilterTradeNames != '--')
        ? 'trade_name:' + FilterTradeNames + ' '
        : '') +
      ((rating != null &&
        rating.length() > 0)
        ? 'supplier_rating:' + rating + ' '
        : '') +
      ((FilterShapes != null &&
        FilterShapes.length() > 0 &&
        FilterShapes != '--')
        ? 'shape:' + FilterShapes + ' '
        : '');
    string booleanFilter =
      (newFilter.equalsIgnoreCase('true') ? 'is_new:1 ' : '') +
      (fullColorProcessFilter.equalsIgnoreCase('true')
        ? 'is_full_color_process:1 '
        : '') +
      (madeInUSAFilter.equalsIgnoreCase('true') ? 'is_made_in_usa:1 ' : '') +
      (canadianFriendFilter.equalsIgnoreCase('true')
        ? 'canadian_friendly:1 '
        : '') +
      (canadianPricedFilter.equalsIgnoreCase('true')
        ? 'is_canadian_priced:1 '
        : '');
    if (tier1Filter.length() > 1) {
      finalQuery = finalQuery + ' ' + tier1Filter.removeEnd(',');
    }
    if (tier2Filter.length() > 1) {
      finalQuery = finalQuery + ' ' + tier2Filter.removeEnd(',');
    }
    if (booleanFilter.length() > 1) {
      finalQuery = finalQuery + ' ' + booleanFilter.removeEnd(',');
    }
    System.debug('finalQuery---==>> ' + finalQuery);
    return getProductsFromESP(
      EncodingUtil.urlEncode(finalQuery, 'UTF-8'),
      sortType,
      pageToDisplay
    );
  }

  public static void verify_Updated_ESP_Pricing(
    String variantId,
    ESPProduct singleProduct,
    Product2 product
  ) {
    Map<Decimal, Pricing_Product__c> existingProductPricing = new Map<Decimal, Pricing_Product__c>();
    Map<Decimal, ESPProduct.Prices> quanityToEspPricingMap = new Map<Decimal, ESPProduct.Prices>();
    Map<String, Pricing_Product__c> updatedProductPricing = new Map<String, Pricing_Product__c>();
    List<Pricing_Product__c> productPricingToBeDeleted = new List<Pricing_Product__c>();
    List<Pricing_Product__c> new_Pricing_Product = new List<Pricing_Product__c>();
    List<Pricing_Product__c> update_Pricing_Product = new List<Pricing_Product__c>();

    List<Pricing_Product__c> lst_Pricing_Product = [
      SELECT Id, Quantity__c, Net_Cost__c, Retail_Price__c, Product__c
      FROM Pricing_Product__c
      WHERE Product__c = :product.Id
    ];

    for (Pricing_Product__c pricing_Product : lst_Pricing_Product) {
      existingProductPricing.put(pricing_Product.Quantity__c, pricing_Product);
    }

    if (singleProduct != null) {
      //This would ensure that commonSkuVariantId is also not null
      List<ESPProduct.Prices> espListPrices = singleProduct.getPricesOfSpecificProduct(
        variantId
      );
      if (!espListPrices.isEmpty()) {
        for (ESPProduct.Prices espPrice : espListPrices) {
          quanityToEspPricingMap.put(espPrice.Quantity.From_Z, espPrice);
        }

        //update the existing
        for (Pricing_Product__c pricing_Product : lst_Pricing_Product) {
          if (quanityToEspPricingMap.containsKey(pricing_Product.Quantity__c)) {
            ESPProduct.Prices esp_Product_Pricing = quanityToEspPricingMap.get(
              pricing_Product.Quantity__c
            );
            if (esp_Product_Pricing != null) {
              if (
                pricing_Product.Retail_Price__c != esp_Product_Pricing.Price ||
                pricing_Product.Net_Cost__c != esp_Product_Pricing.Cost
              ) {
                pricing_Product.Retail_Price__c = esp_Product_Pricing.Price;
                pricing_Product.Net_Cost__c = esp_Product_Pricing.Cost;
                update_Pricing_Product.add(pricing_Product);
              }
            }
          }
        }

        for (Decimal qunatity : quanityToEspPricingMap.keySet()) {
          if (!existingProductPricing.containsKey(qunatity)) {
            ESPProduct.Prices esp_Product_Pricing = quanityToEspPricingMap.get(
              qunatity
            );
            //create new pricing
            Pricing_Product__c tmpProduct = new Pricing_Product__c();
            tmpProduct.Quantity__c = esp_Product_Pricing.Quantity.From_Z;
            tmpProduct.Net_Cost__c = esp_Product_Pricing.Cost;
            tmpProduct.Retail_Price__c = esp_Product_Pricing.Price;
            tmpProduct.Product__c = product.Id;
            new_Pricing_Product.add(tmpProduct);
          }
        }

        //remove the qunatity changed item.
        for (Pricing_Product__c product_pricing : lst_Pricing_Product) {
          if (
            !quanityToEspPricingMap.containsKey(product_pricing.Quantity__c)
          ) {
            productPricingToBeDeleted.add(product_pricing);
          }
        }

        try {
          if (update_Pricing_Product.size() > 0) {
            update update_Pricing_Product;
          }
          if (productPricingToBeDeleted.size() > 0) {
            delete productPricingToBeDeleted;
          }
          if (new_Pricing_Product.size() > 0) {
            insert new_Pricing_Product;
          }
        } catch (Exception e) {
          System.debug(
            'Exexcption in verify_Updated_ESP_Pricing ----> ' +
              e.getMessage() +
              ' -- ' +
              e.getStackTraceString()
          );
        }
      }
    }
  }

  @AuraEnabled
  public static boolean createOpportunityLineItemEsp(
    String productId,
    String opportunityId,
    String variantId,
    String estimateId,
    String adId,
    String adPosition,
    String recordFrom,
    String workOrderId,
    String variantColor,
    String variantSize
  ) {
    try {
      String espEndPoint;
      String authorizationHeader;
      String responeJson;
      if (productId != null && adId != null && adPosition != null) {
        reportBackToASI(productId, adId, adPosition);
      }
      //to fetch selected product detail from ESP
      espEndPoint =
        System.Label.ESP_URL +
        'products/' +
        productId +
        '/configure.json';
      authorizationHeader = System.Label.ESP_Key;
      List<Id> lstEstimateIds = new List<Id>();
      List<Id> lstOpportunityIds = new List<Id>();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(espEndPoint);
      req.setMethod('GET');
      req.setHeader('Authorization', authorizationHeader);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      responeJson = res.getBody();
      ESPProduct singleProduct = new ESPProduct();
      //ESP product parsing
      Boolean result = singleProduct.parse(responeJson, espEndPoint);
      if (res.getStatusCode() == 200 && result == true) {
        String espEndPoint2;
        String authorizationHeader2;
        String responeJson2;
        String ImprintingInfo;
        Integer commonSkuId;
        Integer commonSkuVariantId;
        commonSkuVariantId = null;
        ImprintingInfo = singleProduct.ImprintingInfo;
        commonSkuId = singleProduct.Id;
        // to fetch supplier info from ESP using ASI number
        espEndPoint2 =
          System.Label.ESP_URL +
          'suppliers/search.json?q=' +
          singleProduct.SupplierObj.AsiNumber;
        authorizationHeader2 = System.Label.ESP_Key;
        HttpRequest req2 = new HttpRequest();
        req2.setEndpoint(espEndPoint2);
        req2.setMethod('GET');
        req2.setHeader('Authorization', authorizationHeader2);
        Http http2 = new Http();
        HTTPResponse res2 = http2.send(req2);
        if (res2.getStatusCode() == 200) {
          responeJson2 = res2.getBody();
          //Supplier parsing
          ESPSupplier supplierDetails = ESPSupplier.parse(responeJson2);
          commonSkuId = singleProduct.Id;
          commonSkuVariantId = null;
          List<Product2> result_product;
          //to check whether the selected product already exist in the system or not
          if (variantId != null) {
            try {
              commonSkuVariantId = Integer.valueOf(variantId);
            } catch (Exception ex) {
            }
            result_product = [
              SELECT
                id,
                Name,
                CommonSku_Id__c,
                Description,
                Product_Cost__c,
                Sales_Price_Rate__c,
                Sales_Tax_Category__c,
                Purchasing_Info__c,
                Net_Price__c,
                Product_Supplier_Code__c,
                ProductCode,
                qbo_product_service_id__c
              FROM Product2
              WHERE
                CommonSku_Id__c = :commonSkuId
                AND commonSkuVariantId__c = :commonSkuVariantId
            ];
          } else {
            result_product = [
              SELECT
                id,
                Name,
                CommonSku_Id__c,
                Description,
                Product_Cost__c,
                Sales_Price_Rate__c,
                Sales_Tax_Category__c,
                Purchasing_Info__c,
                Net_Price__c,
                Product_Supplier_Code__c,
                ProductCode,
                qbo_product_service_id__c
              FROM Product2
              WHERE CommonSku_Id__c = :commonSkuId
            ];
          }
          Product2 product;
          if (result_product.size() > 0) {
            product = result_product.get(0);
          }
          List<PricingLineItem__c> lst_PricingLineItem = new List<PricingLineItem__c>();
          List<Pricing_Product__c> lst_Pricing_Product = new List<Pricing_Product__c>();
          List<Color_Product__c> lst_Color_Product = new List<Color_Product__c>();
          List<Size_Product__c> lst_Size_Product = new List<Size_Product__c>();
          Boolean newProductInserted = true;
          //if selected product is not present in the system then create that product and related records too,
          // to maintain ESP products in Salesforce
          if (product == null) {
            product = new Product2();
            product.CommonSku_Id__c = singleProduct.Id;
            product.commonSkuVariantId__c = commonSkuVariantId;
            if (singleProduct.SupplierObj != null) {
              product.Supplier_Name_Esp__c = singleProduct.SupplierObj.Name;
            }
            product.Name = singleProduct.Name;
            product.Description = singleProduct.Description;
            product.Product_Cost__c = 0;
            product.Sales_Price_Rate__c = 0;
            product.Sales_Tax_Category__c = 'Nontaxable';
            product.Purchasing_Info__c = 'N/A';
            product.Net_Price__c = 0;
            product.Product_Supplier_Code__c = singleProduct.SupplierObj.AsiNumber;
            product.ProductCode = singleProduct.NumberValue;
            //Every Product selected from ESP will be a promotional product
            product.qbo_product_service_id__c = Integer.valueOf(
              System.Label.QBO_Promotional_Product_Service_Id
            );
            insert product;
            if (singleProduct != null) {
              //create price records for product using ESP detail
              List<ESPProduct.Prices> lstPrices = singleProduct.getPricesOfSpecificProduct(
                variantId
              );
              if (lstPrices != null) {
                for (ESPProduct.Prices obj : lstPrices) {
                  Pricing_Product__c tmpProduct = new Pricing_Product__c();
                  tmpProduct.Quantity__c = obj.Quantity.From_Z;
                  tmpProduct.Net_Cost__c = obj.Cost;
                  tmpProduct.Retail_Price__c = obj.Price;
                  tmpProduct.Product__c = product.Id;
                  lst_Pricing_Product.add(tmpProduct);
                }
              }
              insert lst_Pricing_Product;
              //create product color records for product using ESP detail
              List<ESPProduct.Values> lstValues = singleProduct.getSpecificProductColorDetails(
                variantId
              );
              if (lstValues != null) {
                for (ESPProduct.Values obj : lstValues) {
                  Color_Product__c tmpProductColor = new Color_Product__c();
                  tmpProductColor.Color__c = obj.Name;
                  tmpProductColor.Name = obj.Code;
                  tmpProductColor.Product__c = product.Id;
                  tmpProductColor.Image__c = obj.ImageUrl;
                  lst_Color_Product.add(tmpProductColor);
                }
                if (lst_Color_Product.size() > 0) {
                  insert lst_Color_Product;
                }
              }
              //create color records for product using ESP detail
              List<ESPProduct.Values> lstSizes = singleProduct.getSpecificProductSizeDetails(
                variantId
              );
              if (lstSizes != null) {
                for (ESPProduct.Values obj : lstSizes) {
                  Size_Product__c tmpProductSize = new Size_Product__c();
                  tmpProductSize.Size__c = obj.Name;
                  tmpProductSize.Name = obj.Code;
                  tmpProductSize.Product__c = product.Id;
                  lst_Size_Product.add(tmpProductSize);
                }
                if (lstSizes.size() > 0) {
                  insert lst_Size_Product;
                }
              }
            }
          }
          //if selected product is already present in the system then fetch existing related records(price, color and size) to replicate them and link with oppo line item
          else {
            newProductInserted = false;
            verify_Updated_ESP_Pricing(variantId, singleProduct, product);
            lst_Pricing_Product = [
              SELECT Id, Quantity__c, Net_Cost__c, Retail_Price__c, Product__c
              FROM Pricing_Product__c
              WHERE Product__c = :product.Id
            ];
            lst_Color_Product = [
              SELECT Id, Color__c, Name, Product__c, Image__c
              FROM Color_Product__c
              WHERE Product__c = :product.Id
            ];
            lst_Size_Product = [
              SELECT Id, Size__c, Name, Product__c
              FROM Size_Product__c
              WHERE Product__c = :product.Id
            ];
          }
          //sendEmail('newProductInserted '+newProductInserted+' VariantId ---'+variantId+ '== '+espEndPoint,+String.valueOf(product)+String.valueOf(lst_Pricing_Product)+'\n\n/n/n'+String.valueOf(singleProduct));

          //create oppo line item record and linked selected product with this
          OpportunityLineItem__c opportunityLineItem = new OpportunityLineItem__c();
          opportunityLineItem.ESPId__c = integer.ValueOf(productId);
          opportunityLineItem.Name = product.Name;
          opportunityLineItem.Description__c = singleProduct.getCustomDescription(
            variantId
          );
          if (
            opportunityLineItem.Description__c != null &&
            opportunityLineItem.Description__c.endsWith('null')
          ) {
            opportunityLineItem.Description__c = opportunityLineItem.Description__c.removeEnd(
              'null'
            );
          }
          opportunityLineItem.Product__c = product.id;
          opportunityLineItem.Imprint_Information__c = ImprintingInfo;
          opportunityLineItem.Imprint_Methods__c = getImprintingMethods(
            singleProduct.ImprintingObj
          );
          opportunityLineItem.isProductFromESP__c = true;
          opportunityLineItem.SKU__c = singleProduct.getsku(variantId);
          //to link created oppo line item with the appropriate stage(Presentation, Estimate or Sales Order)
          if (recordFrom == 'Opportunity') {
            opportunityLineItem.Opportunity__c = Id.valueOf(opportunityId);
          } else if (recordFrom == 'Estimate') {
            opportunityLineItem.Estimate__c = Id.valueOf(estimateId);
            lstEstimateIds.add(Id.valueOf(estimateId));
          } else if (recordFrom == 'SalesOrder') {
            //create empty shipping information record for newly added product in SalesOrder from ESP tab
            Shipping_Information__c shippingInformationObj = new Shipping_Information__c();
            insert shippingInformationObj;
            opportunityLineItem.Shipping_Information__c = shippingInformationObj.id;
            opportunityLineItem.Work_Order__c = Id.valueOf(workOrderId);
          }
          opportunityLineItem.Supplier__c = singleProduct.SupplierObj != null
            ? singleProduct.SupplierObj.Name
            : '';
          opportunityLineItem.Variant_Id__c = variantId;
          List<String> additionalColors = new List<String>();
          List<String> additionalLocations = new List<String>();
          if (
            singleProduct.ImprintingObj != null &&
            singleProduct.ImprintingObj.Options != null
          ) {
            for (ESPProduct.Options val : singleProduct.ImprintingObj.Options) {
              if (val.Name != null && val.Name == 'Additional Colors') {
                if (val.Groups != null) {
                  for (ESPProduct.Groups groupValue : val.Groups) {
                    additionalColors.add(groupValue.Name);
                  }
                }
              }
              if (val.Name != null && val.Name == 'Additional Location') {
                if (val.Groups != null) {
                  for (ESPProduct.Groups groupValue : val.Groups) {
                    additionalLocations.add(groupValue.Name);
                  }
                }
              }
            }
          }
          if (additionalColors.size() > 0) {
            opportunityLineItem.Additional_Colors__c = string.join(
              additionalColors,
              ', '
            );
          }
          if (additionalLocations.size() > 0) {
            opportunityLineItem.Additional_Locations__c = string.join(
              additionalLocations,
              ', '
            );
          }
          insert opportunityLineItem;
          //if product has been added at the estimate stage then update that product, so that we could show sync with QuickBook warning message
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
          //create  PricingLineItem__c, ColorLineItem__c and SizeLineItem__c from the already existing product,
          //if product doesn't exist then from rececntly created product
          //and linked them with the oppo line item record
          for (Pricing_Product__c obj : lst_Pricing_Product) {
            PricingLineItem__c tmp = new PricingLineItem__c();
            tmp.Quantity__c = obj.Quantity__c;
            tmp.Net_Cost__c = obj.Net_Cost__c;
            tmp.Retail_Price__c = obj.Retail_Price__c;
            if (tmp.Net_Cost__c != null) {
              tmp.Show_To_Client__c = true;
            }
            if (Label.Default_Margin_Value != null) {
              decimal priceCostCalculation = 0;
              if (
                tmp != null &&
                tmp.Retail_Price__c != null &&
                tmp.Net_Cost__c != null
              ) {
                priceCostCalculation = tmp.Retail_Price__c - tmp.Net_Cost__c;
              }

              if (
                tmp != null &&
                tmp.Retail_Price__c != null &&
                tmp.Retail_Price__c != 0
              ) {
                tmp.Margin__c =
                  (priceCostCalculation / tmp.Retail_Price__c) * 100;
              } else {
                tmp.Margin__c = 0;
              }
              tmp.Margin__c = tmp.Margin__c.setScale(2);
              if (tmp != null && tmp.Retail_Price__c != null)
                tmp.Total__c = tmp.Quantity__c * tmp.Retail_Price__c;
              else {
                tmp.Total__c = 0;
              }
            }
            tmp.OpportunityLineItem__c = opportunityLineItem.id;
            decimal marginCalculation = 1 - (tmp.Margin__c / 100);
            if (marginCalculation != 0) {
              tmp.Price_Per_Unit__c =
                (tmp.Net_Cost__c != null ? tmp.Net_Cost__c : 0) /
                marginCalculation;
              tmp.Price_Per_Unit__c = tmp.Price_Per_Unit__c.setScale(2);
            }
            lst_PricingLineItem.add(tmp);
          }

          insert lst_PricingLineItem;
          List<ColorLineItem__c> lstColorsLineItem = new List<ColorLineItem__c>();
          List<SizeLineItem__c> lstSizesLineItem = new List<SizeLineItem__c>();
          for (Color_Product__c colorObj : lst_Color_Product) {
            String productColor = colorObj.Color__c;
            if (
              variantColor != null &&
              variantColor.trim() == productColor.trim()
            ) {
              ColorLineItem__c colorsLineItem = new ColorLineItem__c();
              colorsLineItem.Color__c = colorObj.Color__c;
              colorsLineItem.OpportunityLineItem__c = opportunityLineItem.id;
              colorsLineItem.isSelected__c = true;
              lstColorsLineItem.add(colorsLineItem);
            } else if (variantColor == null) {
              ColorLineItem__c colorsLineItem = new ColorLineItem__c();
              colorsLineItem.Color__c = colorObj.Color__c;
              colorsLineItem.OpportunityLineItem__c = opportunityLineItem.id;
              colorsLineItem.isSelected__c = true;
              lstColorsLineItem.add(colorsLineItem);
            }
          }
          insert lstColorsLineItem;
          for (Size_Product__c sizeObj : lst_Size_Product) {
            if (variantSize != null && variantSize == sizeObj.Size__c) {
              SizeLineItem__c sizeLineItem = new SizeLineItem__c();
              sizeLineItem.Size__c = sizeObj.Size__c;
              sizeLineItem.isSelected__c = true;
              sizeLineItem.OpportunityLineItem__c = opportunityLineItem.id;
              lstSizesLineItem.add(sizeLineItem);
            } else if (variantSize == null) {
              SizeLineItem__c sizeLineItem = new SizeLineItem__c();
              sizeLineItem.Size__c = sizeObj.Size__c;
              sizeLineItem.isSelected__c = true;
              sizeLineItem.OpportunityLineItem__c = opportunityLineItem.id;
              lstSizesLineItem.add(sizeLineItem);
            }
          }
          insert lstSizesLineItem;
          //If product is being added at the estimate stage then create a pricing rceord
          //that will be used as default pricing of the product in estimate and salesorder
          if (
            lst_PricingLineItem.size() > 0 &&
            (estimateId != null ||
            workOrderId != null)
          ) {
            List<PricingLineItem__c> pricingRecordList = new List<PricingLineItem__c>();
            PricingLineItem__c firstPricingObj = lst_PricingLineItem.get(0);
            PricingLineItem__c newRecord = new PricingLineItem__c();
            newRecord.Estimated_Quantity__c = firstPricingObj.Quantity__c;
            newRecord.Margin__c = firstPricingObj.Margin__c;
            newRecord.Quantity__c = firstPricingObj.Quantity__c;
            newRecord.Net_Cost__c = firstPricingObj.Net_Cost__c;
            newRecord.Retail_Price__c = firstPricingObj.Retail_Price__c;
            if (
              newRecord.Retail_Price__c != null &&
              newRecord.Estimated_Quantity__c != null
            )
              newRecord.Total__c =
                newRecord.Estimated_Quantity__c * newRecord.Retail_Price__c;
            newRecord.OpportunityLineItem__c = opportunityLineItem.Id;
            newRecord.Estimate__c = estimateId;
            newRecord.Display__c = true;
            newRecord.Default__c = false;

            if (variantSize != null) {
              newRecord.Size__c = variantSize;
            } else if (lst_Size_Product.size() == 1) {
              newRecord.Size__c = lst_Size_Product.get(0).Size__c;
            }
            if (variantColor != null) {
              newRecord.Color__c = variantColor;
            } else if (lst_Color_Product.size() == 1) {
              newRecord.Color__c = lst_Color_Product.get(0).Color__c;
            }
            pricingRecordList.add(newRecord);
            PricingLineItem__c newDefaultRecordToUseInEdit = new PricingLineItem__c();
            newDefaultRecordToUseInEdit.Estimated_Quantity__c = firstPricingObj.Quantity__c;
            newDefaultRecordToUseInEdit.Margin__c = firstPricingObj.Margin__c;
            newDefaultRecordToUseInEdit.Quantity__c = firstPricingObj.Quantity__c;
            newDefaultRecordToUseInEdit.Net_Cost__c = firstPricingObj.Net_Cost__c;
            newDefaultRecordToUseInEdit.Retail_Price__c = firstPricingObj.Retail_Price__c;
            if (
              newRecord.Retail_Price__c != null &&
              newRecord.Estimated_Quantity__c != null
            )
              newDefaultRecordToUseInEdit.Total__c =
                newRecord.Estimated_Quantity__c * newRecord.Retail_Price__c;
            newDefaultRecordToUseInEdit.OpportunityLineItem__c = opportunityLineItem.Id;
            newDefaultRecordToUseInEdit.Estimate__c = estimateId;
            newDefaultRecordToUseInEdit.Display__c = true;
            newDefaultRecordToUseInEdit.Default__c = true;
            if (variantSize != null) {
              newDefaultRecordToUseInEdit.Size__c = variantSize;
            } else if (lst_Size_Product.size() == 1) {
              newDefaultRecordToUseInEdit.Size__c = lst_Size_Product.get(0)
                .Size__c;
            }
            if (variantColor != null) {
              newDefaultRecordToUseInEdit.Color__c = variantColor;
            } else if (lst_Color_Product.size() == 1) {
              newDefaultRecordToUseInEdit.Color__c = lst_Color_Product.get(0)
                .Color__c;
            }
            pricingRecordList.add(newDefaultRecordToUseInEdit);
            if (pricingRecordList.size() > 0) {
              insert pricingRecordList;
            }
          }
          //create attchment records from the product image
          if (opportunityLineItem.id != null) {
            OpportunityLineItemAttachment__c opportunityLineItemAttachment = new OpportunityLineItemAttachment__c();
            opportunityLineItemAttachment.OpportunityLineItem__c = opportunityLineItem.id;
            insert opportunityLineItemAttachment;
            if (!Test.isRunningTest()) {
              fetchImageAndStore(
                singleProduct.getImagesOfSpecificProduct(variantId),
                opportunityLineItemAttachment.id,
                product.id
              );
              fetchImagesAndStore(
                singleProduct.LstImages,
                opportunityLineItemAttachment.id,
                product.id
              );
            }
          }
          //to create or update the vendor account and sync it in the appropriate QuickBook company
          if (
            (recordFrom == 'Estimate' ||
            recordFrom == 'SalesOrder') &&
            singleProduct != null &&
            singleProduct.SupplierObj != null &&
            singleProduct.SupplierObj.AsiNumber != null
          ) {
            //to get appopriate company name
            String quickBookCompanyName = null;
            if (recordFrom == 'Estimate') {
              Estimate__c est = [
                SELECT id, Selected_Quickbook_Instance__c
                FROM Estimate__c
                WHERE id = :estimateId
              ];
              quickBookCompanyName = est.Selected_Quickbook_Instance__c;
            } else if (recordFrom == 'SalesOrder') {
              Order order = [
                SELECT id, Quickbooks_Instance__c
                FROM Order
                WHERE id = :workOrderId
              ];
              quickBookCompanyName = order.Quickbooks_Instance__c;
            }

            List<Account> accs = [
              SELECT
                id,
                ASI_Number__c,
                Billing_Email__c,
                QuickBooks_Accounts__c,
                billingstreet,
                billingcountry,
                billingcity,
                billingstate,
                billingPostalCode,
                ESP_Rating__c,
                Phone,
                Fax,
                Instagram__c,
                Facebook__c,
                Twitter__c,
                Linkedin__c,
                Youtube__c,
                Website
              FROM Account
              WHERE ASI_Number__c = :singleProduct.SupplierObj.AsiNumber
            ];

            if (accs != null && accs.size() < 1) {
              Account newVendor = new Account();
              newVendor.Name = singleProduct.SupplierObj.Name;
              newVendor.ASI_Number__c = singleProduct.SupplierObj.AsiNumber;
              newVendor.QuickBooks_Accounts__c = quickBookCompanyName;
              newVendor.RecordTypeId = [
                SELECT SobjectType, Id, Name
                FROM RecordType
                WHERE Name LIKE 'Vendor%' AND SobjectType = 'Account'
                LIMIT 1
              ]
              .id;
              newVendor.Billing_Email__c = singleProduct.SupplierObj.email;
              if (
                supplierDetails.Results.get(0) != null &&
                supplierDetails.Results.get(0).Address != null
              ) {
                if (supplierDetails.Results.get(0).Address.Street1 != null) {
                  newVendor.billingstreet = supplierDetails.Results.get(0)
                    .Address.Street1;
                }
                if (supplierDetails.Results.get(0).Address.City != null) {
                  newVendor.billingcity = supplierDetails.Results.get(0)
                    .Address.City;
                }
                if (supplierDetails.Results.get(0).Address.State != null) {
                  newVendor.billingstate = supplierDetails.Results.get(0)
                    .Address.State;
                }
                if (supplierDetails.Results.get(0).Address.Zip != null) {
                  newVendor.billingPostalCode = supplierDetails.Results.get(0)
                    .Address.Zip;
                }
                if (supplierDetails.Results.get(0).Address.Country != null) {
                  newVendor.billingcountry = supplierDetails.Results.get(0)
                    .Address.Country;
                }
              }
              if (singleProduct.SupplierObj.Rating != null) {
                newVendor.ESP_Rating__c = String.valueOf(
                  singleProduct.SupplierObj.Rating
                );
              }
              newVendor.Phone = singleProduct.SupplierObj.Phone;
              newVendor.Fax = singleProduct.SupplierObj.FaxNumber;
              if (
                singleProduct.SupplierObj.WebsitesList != null &&
                singleProduct.SupplierObj.WebsitesList.size() > 0
              ) {
                for (String website : singleProduct.SupplierObj.WebsitesList) {
                  if (website.contains('instagram')) {
                    newVendor.Instagram__c = website;
                  } else if (website.contains('facebook')) {
                    newVendor.Facebook__c = website;
                  } else if (website.contains('twitter')) {
                    newVendor.Twitter__c = website;
                  } else if (website.contains('linkedin')) {
                    newVendor.Linkedin__c = website;
                  } else if (website.contains('youtube')) {
                    newVendor.Youtube__c = website;
                  } else if (String.isBlank(newVendor.Website)) {
                    newVendor.Website = website;
                  }
                }
              }
              //default primary category will be Promotional Products for every new vednor from ESP
              newVendor.Primary_Category__c = 'Promotional Products';
              System.debug(
                '-------AddPorductESPTabController-------' +
                newVendor.Primary_Category__c
              );
              insert newVendor;
              Integer productServiceId = getProductServiceId(newVendor.id);
              opportunityLineItem.Account__c = newVendor.id;
              opportunityLineItem.qbo_product_service_id__c = productServiceId;
              update opportunityLineItem;
            } else {
              if (String.isBlank(accs.get(0).Billing_Email__c))
                accs.get(0).Billing_Email__c = singleProduct.SupplierObj.email;
              if (
                supplierDetails.Results.get(0) != null &&
                supplierDetails.Results.get(0).Address != null
              ) {
                if (
                  supplierDetails.Results.get(0).Address.Street1 != null &&
                  String.isBlank(accs.get(0).billingstreet)
                ) {
                  accs.get(0).billingstreet = supplierDetails.Results.get(0)
                    .Address.Street1;
                }
                if (
                  supplierDetails.Results.get(0).Address.City != null &&
                  String.isBlank(accs.get(0).billingcity)
                ) {
                  accs.get(0).billingcity = supplierDetails.Results.get(0)
                    .Address.City;
                }
                if (
                  supplierDetails.Results.get(0).Address.State != null &&
                  String.isBlank(accs.get(0).billingstate)
                ) {
                  accs.get(0).billingstate = supplierDetails.Results.get(0)
                    .Address.State;
                }
                if (
                  supplierDetails.Results.get(0).Address.Zip != null &&
                  String.isBlank(accs.get(0).billingPostalCode)
                ) {
                  accs.get(0).billingPostalCode = supplierDetails.Results.get(0)
                    .Address.Zip;
                }
                if (
                  supplierDetails.Results.get(0).Address.Country != null &&
                  String.isBlank(accs.get(0).billingcountry)
                ) {
                  accs.get(0).billingcountry = supplierDetails.Results.get(0)
                    .Address.Country;
                }
              }
              if (
                singleProduct.SupplierObj.Rating != null &&
                String.isBlank(accs.get(0).ESP_Rating__c)
              ) {
                accs.get(0).ESP_Rating__c = String.valueOf(
                  singleProduct.SupplierObj.Rating
                );
              }
              if (String.isBlank(accs.get(0).Phone))
                accs.get(0).Phone = singleProduct.SupplierObj.Phone;
              if (String.isBlank(accs.get(0).Fax))
                accs.get(0).Fax = singleProduct.SupplierObj.FaxNumber;
              if (
                singleProduct.SupplierObj.WebsitesList != null &&
                singleProduct.SupplierObj.WebsitesList.size() > 0
              ) {
                for (String website : singleProduct.SupplierObj.WebsitesList) {
                  if (
                    website.contains('instagram') &&
                    String.isBlank(accs.get(0).Instagram__c)
                  ) {
                    accs.get(0).Instagram__c = website;
                  } else if (
                    website.contains('facebook') &&
                    String.isBlank(accs.get(0).Facebook__c)
                  ) {
                    accs.get(0).Facebook__c = website;
                  } else if (
                    website.contains('twitter') &&
                    String.isBlank(accs.get(0).Twitter__c)
                  ) {
                    accs.get(0).Twitter__c = website;
                  } else if (
                    website.contains('linkedin') &&
                    String.isBlank(accs.get(0).Linkedin__c)
                  ) {
                    accs.get(0).Linkedin__c = website;
                  } else if (
                    website.contains('youtube') &&
                    String.isBlank(accs.get(0).Youtube__c)
                  ) {
                    accs.get(0).Youtube__c = website;
                  } else if (String.isBlank(accs.get(0).Website)) {
                    accs.get(0).Website = website;
                  }
                }
              }
              //if vendor account already exist but for different company
              //then attach it with this company as well
              if (
                accs != null &&
                accs.size() > 0 &&
                accs.get(0).QuickBooks_Accounts__c != null &&
                quickBookCompanyName != null
              ) {
                if (
                  !accs.get(0)
                    .QuickBooks_Accounts__c.contains(quickBookCompanyName)
                ) {
                  accs.get(0).QuickBooks_Accounts__c =
                    accs.get(0).QuickBooks_Accounts__c +
                    ';' +
                    quickBookCompanyName;
                }
              } else {
                accs.get(0).QuickBooks_Accounts__c = quickBookCompanyName;
              }
              opportunityLineItem.Account__c = accs.get(0).id;
              Integer productServiceId = getProductServiceId(accs.get(0).id);
              //Every Product selected from ESP will be a promotional product
              opportunityLineItem.qbo_product_service_id__c = productServiceId;
              update opportunityLineItem;
              update accs;
            }
          }
          if (recordFrom == 'SalesOrder') {
            SalesOrderOppLineItemController.updateSalesOrderSyncStatus(
              workOrderId,
              false
            );
            EditOpporLineItemInSalesOrderController.updateWorkOrder(
              workOrderId
            );
          }
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in Create Opportunity Line Item -->>>>>>' + Ex.getMessage()
      );
      System.debug(
        'Exception in Create Opportunity Line Item -->>>>>>' + Ex.getCause()
      );
      System.debug(
        'Exception in Create Opportunity Line Item -->>>>>>' +
        Ex.getStackTraceString()
      );
      return false;
    }
  }

  /**
   * This function will return QBO product Service against the vendor primary category
   * @param accId
   * @return  `String` QBO product service id
   */
  public static Integer getProductServiceId(String accId) {
    Account a = [SELECT id, Primary_Category__c FROM Account WHERE id = :accId];
    String primaryCat;
    Integer productServiceId;
    primaryCat = a.Primary_Category__c;
    productServiceId = Integer.valueOf(
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
    } else if (primaryCat == 'Promotional Products') {
      productServiceId = Integer.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Promotional_Products')
          .qbo_product_service_id__c
      );
    } else if (primaryCat == 'Trade Show & Signage') {
      productServiceId = Integer.valueOf(
        QBO_Product_Service_Id__mdt.getInstance('Trade_Show_Signage')
          .qbo_product_service_id__c
      );
    }

    return productServiceId;
  }

  public static String getAuthorizationToken() {
    String body =
      'app_code=' +
      System.Label.ESP_app_Code +
      '&asi_number=' +
      System.Label.ESP_asi_number +
      '&username=' +
      System.Label.ESP_username +
      '&Password=' +
      System.Label.Password +
      '&Kick=1';
    String espEndPoint = System.Label.ESP_URL + 'login.json';
    List<Id> lstEstimateIds = new List<Id>();
    List<Id> lstOpportunityIds = new List<Id>();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(espEndPoint);
    req.setMethod('POST');
    req.setTimeout(120000);
    req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    req.setBody(body);
    Http http = new Http();
    HTTPResponse res = http.send(req);
    String responeJson = res.getBody();
    if (res.getStatusCode() == 200) {
      Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
        responeJson
      );
      return String.ValueOf(results.get('Token'));
    }
    return null;
  }
  public static Boolean reportBackToASI(
    String productId,
    String adId,
    String adPosition
  ) {
    try {
      String espEndPoint;
      String body;
      body =
        'log[]={"record":{"schema":"MONY01","immediate":true,"adaction_cd":"PRSI",' +
        '"hits_cnt":1,"product_id":' +
        productId +
        ',"ad_id":' +
        adId +
        ',"adindex":' +
        adPosition +
        ',"appCode":"' +
        System.Label.ESP_app_Code +
        '",' +
        '"appVersion":"1.0.0","moduleCode":"PRDRES","moduleVersion":"-1","moduleVersionId":"-1"}}';
      /*   String body = '{"record":{"schema":"MONY01","immediate":true,"adaction_cd":"PRSI",'
            +'"hits_cnt":1,"product_id":"552727157","ad_id":"20070088","adindex":"1","appCode":"WESP",'
            +'"appVersion":"1.0.0","moduleCode":"PRDRES","moduleVersion":"-'
            +'1","moduleVersionId":"-1"}}';*/
      espEndPoint = 'https://espweb.asicentral.com/common/statshandler.ashx'; //System.Label.ESP_URL;  //'https://api.asicentral.com';//
      List<Id> lstEstimateIds = new List<Id>();
      List<Id> lstOpportunityIds = new List<Id>();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(espEndPoint);
      req.setMethod('POST');
      req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      req.setBody(body);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      System.debug('StatusCode for reporting back: ' + res.getStatusCode());
      if (res.getStatusCode() == 200)
        return true;
      else
        return false;
    } catch (Exception Ex) {
      System.debug(
        'Exception--->' + Ex.getMessage() + '----->' + Ex.getStackTraceString()
      );
      return false;
    }
  }
  @AuraEnabled
  public static detailsForSingleProduct getSpecificProductDetails(
    String productId
  ) {
    try {
      String espEndPoint =
        System.Label.ESP_URL +
        'products/' +
        productId +
        '/configure.json';
      String authorizationHeader = System.Label.ESP_Key;
      List<Id> lstEstimateIds = new List<Id>();
      List<Id> lstOpportunityIds = new List<Id>();
      HttpRequest req = new HttpRequest();
      req.setEndpoint(espEndPoint);
      req.setMethod('GET');
      req.setHeader('Authorization', authorizationHeader);
      Http http = new Http();
      HTTPResponse res = http.send(req);
      String responeJson = res.getBody();
      System.debug(
        '--------getSpecificProductDetails-------------' + res.getBody()
      );
      ESPProduct singleProduct = new ESPProduct();
      Boolean result = singleProduct.parse(responeJson, espEndPoint);
      detailsForSingleProduct colorsSizesImprintMethods = new detailsForSingleProduct();
      colorsSizesImprintMethods.sizes = '';
      colorsSizesImprintMethods.colors = '';
      colorsSizesImprintMethods.imprintMethods = '';
      colorsSizesImprintMethods.email = '';
      colorsSizesImprintMethods.website = '';

      if (result == true) {
        List<ESPProduct.Values> lstValues = singleProduct.getAllSizes();
        List<String> retVal = new List<String>();
        Boolean retValSize = false;
        if (lstValues != null) {
          for (ESPProduct.Values obj : lstValues) {
            if (obj.Name != null) {
              retVal.add(obj.Name);
              if (retVal.size() > 10) {
                retValSize = true;
                break;
              }
            }
          }
          colorsSizesImprintMethods.sizes = ' ' + string.join(retVal, ', ');
          if (retValSize == true) {
            colorsSizesImprintMethods.sizes =
              colorsSizesImprintMethods.sizes + ' ...';
          }
        }
        //colorsSizesImprintMethods.sizes = colorsSizesImprintMethods.sizes.removeEnd(',');
        List<ESPProduct.Values> colorValues = singleProduct.getAllColors();
        List<String> retValColors = new List<String>();
        Boolean colorRetValSize1;
        colorRetValSize1 = false;
        if (colorValues != null) {
          for (ESPProduct.Values obj : colorValues) {
            if (obj.Name != null) {
              retValColors.add(obj.Name);
              if (retValColors.size() > 7) {
                colorRetValSize1 = true;
                break;
              }
            }
            // colorsSizesImprintMethods.colors =' '+ colorsSizesImprintMethods.colors +' '+ obj.Name + ',';
          }
          if (retValColors.size() > 0) {
            colorsSizesImprintMethods.colors =
              ' ' + string.join(retValColors, ', ');
            if (colorRetValSize1 == true) {
              colorsSizesImprintMethods.colors =
                colorsSizesImprintMethods.colors + ' ...';
            }
          }
        }
        //colorsSizesImprintMethods.colors = colorsSizesImprintMethods.colors.removeEnd(',');
        if (singleProduct.isConfirmed != null) {
          colorsSizesImprintMethods.isConfirmed = singleProduct.isConfirmed;
        }
        colorsSizesImprintMethods.email = singleProduct.SupplierObj.email;
        colorsSizesImprintMethods.imprintMethods =
          ' ' + getImprintingMethods(singleProduct.ImprintingObj);
        colorsSizesImprintMethods.website = singleProduct.SupplierObj.Websites;
        List<Price> pricesList = new List<Price>();
        List<ESPProduct.Prices> lstPrices = singleProduct.LstPrices;
        if (lstPrices != null) {
          for (ESPProduct.Prices obj : lstPrices) {
            if (
              obj != null &&
              obj.Quantity != null &&
              obj.Price != null &&
              obj.Cost != null
            ) {
              Price tmpProduct = new Price();
              tmpProduct.quantity = obj.Quantity.From_Z;
              tmpProduct.cost = obj.Cost;
              tmpProduct.price = obj.Price;
              tmpProduct.profit = tmpProduct.price - tmpProduct.cost;
              pricesList.add(tmpProduct);
            }
          }
          if (pricesList.size() > 0) {
            colorsSizesImprintMethods.prices = pricesList;
            if (singleProduct.PriceIncludes != null) {
              colorsSizesImprintMethods.pricesIncludes = singleProduct.PriceIncludes;
            }
          } else {
            /////////////////////////////////
            if (singleProduct.lstVariants != null) {
              if (
                singleProduct.lstVariants.size() > 0 &&
                singleProduct.lstVariants[0] != null
              ) {
                if (singleProduct.lstVariants[0].Prices != null) {
                  List<Price> priceList = new List<Price>();
                  for (
                    ESPProduct.Prices pr : singleProduct.lstVariants[0].Prices
                  ) {
                    Price tempPr = new Price();
                    if (
                      pr.Cost != null &&
                      pr.Price != null &&
                      pr.Quantity != null &&
                      pr.Quantity.From_Z != null
                    ) {
                      tempPr.quantity = pr.Quantity.From_Z;
                      tempPr.cost = pr.Cost;
                      tempPr.price = pr.Price;
                      tempPr.profit = pr.price - pr.cost;
                      pricesList.add(tempPr);
                    }
                  }
                  if (pricesList.size() > 0) {
                    colorsSizesImprintMethods.prices = pricesList;
                    if (singleProduct.lstVariants[0].Description != null)
                      colorsSizesImprintMethods.PriceName = singleProduct.lstVariants[0]
                        .Description;
                  }
                }
              }
            }
            ////////////////////////////////
          }
        }
      }
      return colorsSizesImprintMethods;
    } catch (Exception Ex) {
      System.debug(
        'Exception in getting details for single prod -->>>>>>' +
        Ex.getMessage()
      );
      System.debug(
        'Exception  in getting details for single prod -->>>>>>' + Ex.getCause()
      );
      System.debug(
        'Exception in getting details for single prod  -->>>>>>' +
        Ex.getStackTraceString()
      );
      return null;
    }
  }

  public static void sendEmail(String subject, String body) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.toAddresses = new List<String>{ 'muhammad.arslan@rolustech.net' };
    message.optOutPolicy = 'FILTER';
    message.subject = subject;
    message.plainTextBody = body;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
  }

  @future(callout=true)
  public static void fetchImageAndStore(
    Set<String> setImageLink,
    Id OpportunityAttachmentLineItemId,
    Id productId
  ) {
    String imageUrl;
    Blob imageData;
    if (setImageLink.isEmpty() == false) {
      imageUrl = new List<String>(setImageLink)[0];
      imageData = getImageFromUrl(imageUrl);
      if (imageData != null) {
        ContentVersion ContVerFile = new ContentVersion();
        ContVerFile.VersionData = imageData;
        ContVerFile.Title = 'Preview Presentation';
        ContVerFile.ContentLocation = 's';
        ContVerFile.PathOnClient = 'title.jpg';
        insert ContVerFile;
        if (ContVerFile.Id != null) {
          Id conDoc = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :ContVerFile.Id
          ]
          .ContentDocumentId;
          ContentDocumentLink cDe = new ContentDocumentLink();
          cDe.ContentDocumentId = conDoc;
          cDe.LinkedEntityId = OpportunityAttachmentLineItemId;
          cDe.ShareType = 'I';
          cDe.Visibility = 'AllUsers';
          insert cDe;
          ContentDocumentLink cDe2 = new ContentDocumentLink();
          cDe2.ContentDocumentId = conDoc;
          cDe2.LinkedEntityId = productId;
          cDe2.ShareType = 'I';
          cDe2.Visibility = 'AllUsers';
          insert cDe2;
        }
      }
    }
    // for(String imageUrl:setImageLink){
    //     System.debug(imageUrl);
    //     Blob imageData = getImageFromUrl(imageUrl);
    //     if(imageData != null ){
    //         ContentVersion ContVerFile = new ContentVersion();
    //         ContVerFile.VersionData = imageData;
    //         ContVerFile.Title = 'Preview Presentation';
    //         ContVerFile.ContentLocation= 's';
    //         ContVerFile.PathOnClient='title.jpg';
    //         insert ContVerFile;
    //         if(ContVerFile.Id != null){
    //             Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:ContVerFile.Id].ContentDocumentId;
    //             ContentDocumentLink cDe = new ContentDocumentLink();
    //             cDe.ContentDocumentId = conDoc;
    //             cDe.LinkedEntityId = OpportunityAttachmentLineItemId;
    //             cDe.ShareType = 'I';
    //             cDe.Visibility = 'AllUsers';
    //             insert cDe;
    //             ContentDocumentLink cDe2 = new ContentDocumentLink();
    //             cDe2.ContentDocumentId = conDoc;
    //             cDe2.LinkedEntityId = productId;
    //             cDe2.ShareType = 'I';
    //             cDe2.Visibility = 'AllUsers';
    //             insert cDe2;
    //         }
    //     }
    // }
  }

  public static void fetchImagesAndStore(
    List<String> setImageLink,
    Id OpportunityAttachmentLineItemId,
    Id productId
  ) {
    String proId;
    String oppId;
    oppId = (String) OpportunityAttachmentLineItemId;
    proId = (String) productId;
    setImageLink.add(oppId);
    setImageLink.add(proId);
    if (setImageLink.size() > 2) {
      BatchForESPCallout batchObj = new BatchForESPCallout(setImageLink);
      Database.executeBatch(batchObj, 5);
    }
  }

  /*
    @future (callout= true)
    public static void fetchImagesAndStore(List<String> setImageLink, Id OpportunityAttachmentLineItemId,Id productId){
        List<ContentVersion> contentVerFiles = new List<ContentVersion>();
        List<Id> contVerFileIds = new List<Id>();
        List<ContentDocumentLink> contDocLink1 = new List<ContentDocumentLink>();
        List<ContentDocumentLink> contDocLink2 = new List<ContentDocumentLink>();

        for(String imageUrl:setImageLink){
            Blob imageData = getImageFromUrl(imageUrl);
            if(imageData != null ){
                ContentVersion ContVerFile = new ContentVersion();
                ContVerFile.VersionData = imageData;
                ContVerFile.Title = 'Preview Presentation'; 
                ContVerFile.ContentLocation= 's';
                ContVerFile.PathOnClient='title.jpg';
                contentVerFiles.add(ContVerFile); 
            }         
        }  
        insert contentVerFiles;

        for (ContentVersion contVerFile : contentVerFiles) {
            contVerFileIds.add(contVerFile.Id);
        }

        List<ContentVersion> conDocs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contVerFileIds];

        for (ContentVersion ContVerFile : contentVerFiles) {
            
            for (ContentVersion conDocId : conDocs) {
                if (ContVerFile.Id == conDocId.Id) {
                    ContentDocumentLink cDe = new ContentDocumentLink();
                    cDe.ContentDocumentId = conDocId.ContentDocumentId;
                    cDe.LinkedEntityId = OpportunityAttachmentLineItemId;
                    cDe.ShareType = 'I';
                    cDe.Visibility = 'AllUsers';
                    contDocLink1.add(cDe);

                    ContentDocumentLink cDe2 = new ContentDocumentLink();
                    cDe2.ContentDocumentId = conDocId.ContentDocumentId;
                    cDe2.LinkedEntityId = productId;
                    cDe2.ShareType = 'I';
                    cDe2.Visibility = 'AllUsers';
                    contDocLink2.add(cDe2);
                }
            }
        }
        insert contDocLink1;
        insert contDocLink2;
    }

    */

  private static string getImprintingMethods(ESPProduct.Imprinting imp) {
    List<String> retVal = new List<String>();
    if (
      imp != null &&
      imp.Methods != null &&
      imp.Methods.Values != null &&
      imp.Methods.Values.size() > 0
    ) {
      for (ESPProduct.Values val : imp.Methods.Values) {
        retVal.add(val.Name);
      }
    }
    return string.join(retVal, ', ');
  }

  public static ESPProducts getProductsFromESP(
    string term,
    String sortType,
    Integer pageToDisplay
  ) {
    String espEndPoint;
    String authorizationHeader;
    espEndPoint =
      System.Label.ESP_URL +
      'products/search.json?page=' +
      pageToDisplay +
      '&rpp=24&dl=category,color,size,material,shape,supplier,asi,price,theme,trade_name,supplier_state,imprint_method,line_name' +
      (sortType != null && sortType != '' ? '&sort=' + sortType : '') +
      '&q=' +
      term.replaceAll('\\+', '%20') +
      '&include_detail=1';
    authorizationHeader = 'AsiMemberAuth guid=' + getAuthorizationToken();
    HttpRequest req = new HttpRequest();
    req.setEndpoint(espEndPoint);
    req.setMethod('GET');
    req.setHeader('Authorization', authorizationHeader);
    Http http = new Http();
    HTTPResponse res;
    try {
      res = http.send(req);
    } catch (Exception ex) {
      res = null;
      System.debug(
        'Exception Occurs ' +
          ex.getMessage() +
          ' -----------' +
          ex.getStackTraceString()
      );
    }
    System.debug(
      '--------getProductsFromESP ------------------' + res.getBody()
    );
    ESPProducts espProducts = ESPProducts.parse(res.getBody());
    return espProducts;
  }

  @AuraEnabled
  public static ESPProduct getVariants(string productId) {
    Boolean result;
    String espEndPoint;
    String authorizationHeader;
    String responeJson;
    espEndPoint =
      System.Label.ESP_URL +
      'products/' +
      productId +
      '/configure.json';
    if (Test.isRunningTest() == true) {
      espEndPoint = 'http://api.asicentral.com/v1/products/';
    }
    authorizationHeader = System.Label.ESP_Key;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(espEndPoint);
    req.setMethod('GET');
    req.setHeader('Authorization', authorizationHeader);
    Http http = new Http();
    HTTPResponse res = http.send(req);
    responeJson = res.getBody();
    ESPProduct singleProduct = new ESPProduct();
    System.debug('------getVariants------' + responeJson);
    result = singleProduct.parse(responeJson, espEndPoint);
    if (singleProduct.lstVariants != null) {
      for (ESPProduct.Variants obj : singleProduct.lstVariants) {
        Integer discountCodeCount = 0;
        String discountCode = '';
        Map<String, Integer> pricesDiscountCodes = new Map<String, Integer>();
        for (ESPProduct.Prices pr : obj.Prices) {
          if (pr.DiscountCode != null) {
            if (pricesDiscountCodes.containsKey(pr.DiscountCode)) {
              pricesDiscountCodes.put(
                pr.DiscountCode,
                pricesDiscountCodes.get(pr.DiscountCode) + 1
              );
            } else {
              pricesDiscountCodes.put(pr.DiscountCode, 1);
            }
          }
        }
        System.debug(pricesDiscountCodes);
        if (pricesDiscountCodes != null) {
          if (pricesDiscountCodes.size() > 1) {
            obj.PriceDiscounts = '(';
            for (String key : pricesDiscountCodes.keySet()) {
              if (pricesDiscountCodes.get(key) > 1) {
                obj.PriceDiscounts =
                  obj.PriceDiscounts +
                  String.ValueOf(pricesDiscountCodes.get(key)) +
                  key;
              } else {
                obj.PriceDiscounts = obj.PriceDiscounts + key;
              }
            }
            obj.PriceDiscounts = obj.PriceDiscounts + ')';
          } else {
            for (String key : pricesDiscountCodes.keySet()) {
              discountCode = discountCode + key;
              discountCodeCount =
                discountCodeCount + pricesDiscountCodes.get(key);
            }
          }
          if (discountCodeCount > 1 && discountCode != '') {
            obj.PriceDiscounts = '(' + discountCodeCount + discountCode + ')';
          } else if (discountCodeCount == 1 && discountCode != '') {
            obj.PriceDiscounts = '(' + discountCode + ')';
          }
        }
      }
    }
    return singleProduct;
  }

  public static ESPProduct getVars(string prodId) {
    Boolean result;
    String espEndPoint;
    String authorizationHeader;
    String responeJson;
    espEndPoint =
      System.Label.ESP_URL +
      'products/' +
      prodId +
      '/configure.json';
    if (Test.isRunningTest() == true) {
      espEndPoint = 'http://api.asicentral.com/v1/products/';
    }
    authorizationHeader = System.Label.ESP_Key;
    HttpRequest req = new HttpRequest();
    req.setEndpoint(espEndPoint);
    req.setMethod('GET');
    req.setHeader('Authorization', authorizationHeader);
    Http http = new Http();
    HTTPResponse res = http.send(req);
    responeJson = res.getBody();
    ESPProduct singleProduct = new ESPProduct();
    System.debug('------getVariants------' + responeJson);
    result = singleProduct.parse(responeJson, espEndPoint);
    if (singleProduct.lstVariants != null) {
      for (ESPProduct.Variants obj : singleProduct.lstVariants) {
        Integer discountCodeCount = 0;
        String discountCode = '';
        Map<String, Integer> pricesDiscountCodes = new Map<String, Integer>();
        for (ESPProduct.Prices pr : obj.Prices) {
          if (pr.DiscountCode != null) {
            if (pricesDiscountCodes.containsKey(pr.DiscountCode)) {
              pricesDiscountCodes.put(
                pr.DiscountCode,
                pricesDiscountCodes.get(pr.DiscountCode) + 1
              );
            } else {
              pricesDiscountCodes.put(pr.DiscountCode, 1);
            }
          }
        }
        System.debug(pricesDiscountCodes);
        if (pricesDiscountCodes != null) {
          if (pricesDiscountCodes.size() > 1) {
            obj.PriceDiscounts = '(';
            for (String key : pricesDiscountCodes.keySet()) {
              if (pricesDiscountCodes.get(key) > 1) {
                obj.PriceDiscounts =
                  obj.PriceDiscounts +
                  String.ValueOf(pricesDiscountCodes.get(key)) +
                  key;
              } else {
                obj.PriceDiscounts = obj.PriceDiscounts + key;
              }
            }
            obj.PriceDiscounts = obj.PriceDiscounts + ')';
          } else {
            for (String key : pricesDiscountCodes.keySet()) {
              discountCode = discountCode + key;
              discountCodeCount =
                discountCodeCount + pricesDiscountCodes.get(key);
            }
          }
          if (discountCodeCount > 1 && discountCode != '') {
            obj.PriceDiscounts = '(' + discountCodeCount + discountCode + ')';
          } else if (discountCodeCount == 1 && discountCode != '') {
            obj.PriceDiscounts = '(' + discountCode + ')';
          }
        }
      }
    }
    return singleProduct;
  }

  public static Blob getImageFromUrl(string url) {
    Blob image;
    if (url.contains('api.asicentral.com') == false) {
      url = 'http://api.asicentral.com/v1/' + url;
    }
    HttpRequest req = new HttpRequest();
    req.setEndpoint(url + '?size=large');
    req.setMethod('GET');
    Http binding = new Http();
    HttpResponse res = binding.send(req);
    while (res.getStatusCode() == 302) {
      req.setEndpoint(res.getHeader('Location'));
      res = new Http().send(req);
    }
    image = res.getBodyAsBlob();
    return image;
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
  public class detailsForSingleProduct {
    @AuraEnabled
    public String sizes { get; set; }
    @AuraEnabled
    public String colors { get; set; }
    @AuraEnabled
    public String email { get; set; }
    @AuraEnabled
    public String website { get; set; }
    @AuraEnabled
    public String imprintMethods { get; set; }
    @AuraEnabled
    public List<Price> prices { get; set; }
    @AuraEnabled
    public String pricesIncludes { get; set; }
    @AuraEnabled
    public String priceName { get; set; }
    @AuraEnabled
    public Boolean isConfirmed { get; set; }
  }
  public class Price {
    @AuraEnabled
    public Integer quantity { get; set; }
    @AuraEnabled
    public Double price { get; set; }
    @AuraEnabled
    public Double cost { get; set; }
    @AuraEnabled
    public Double profit { get; set; }
  }
}
