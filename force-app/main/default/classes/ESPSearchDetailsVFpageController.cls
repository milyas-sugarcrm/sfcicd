public class ESPSearchDetailsVFpageController {
  //private final Opportunity opp;
  String oppId = null;
  String adId { get; set; }
  String adPosition { get; set; }
  String workOrderId = null;
  Boolean addProductType { get; set; }
  public Boolean ValueReturned { get; set; }

  //public String finalQuery = '';
  ESPSearchResults searchResult = new ESPSearchResults();
  public ESPSearchDetailsVFpageController() {
    //ApexPages.StandardController stdController) {
    //this.opp = (Opportunity)stdController.getRecord();

    String recId = Apexpages.currentPage().getParameters().get('id');
    String recordFrom = apexpages.currentpage()
      .getparameters()
      .get('recordFrom');
    System.debug('-ESPSearchDetailsVFpageController--record id---' + recId);
    if (recordFrom == 'SalesOrder') {
      this.workOrderId = recId;
    } else {
      this.oppId = recId;
    }
    String finalQuery = apexpages.currentpage()
      .getparameters()
      .get('ProductId');
    adId = apexpages.currentpage().getparameters().get('adId');
    adPosition = apexpages.currentpage().getparameters().get('adPosition');
    if (apexpages.currentpage().getparameters().get('isEspProduct') != null) {
      addProductType = Boolean.valueOf(
        apexpages.currentpage().getparameters().get('isEspProduct')
      );
    }

    getProductsFromESP(finalQuery);
  }

  public Void getProductsFromESP(String finalQuery) {
    if (Test.isRunningTest()) {
      //searchResult.Id = finalQuery;//552674284;
    }
    String espEndPoint2 =
      System.Label.ESP_URL +
      'products/' +
      finalQuery +
      '/configure.json';
    String authorizationHeader2 = System.Label.ESP_Key;
    List<Id> lstEstimateIds = new List<Id>();
    List<Id> lstOpportunityIds = new List<Id>();
    HttpRequest req2 = new HttpRequest();
    req2.setEndpoint(espEndPoint2);
    req2.setMethod('GET');
    req2.setHeader('Authorization', authorizationHeader2);
    Http http2 = new Http();
    HTTPResponse res2 = http2.send(req2);
    String responeJson = res2.getBody();
    ESPProduct singleProduct = new ESPProduct();
    singleProduct.parse(responeJson, espEndPoint2);
    List<ESPProduct.Values> lstValues = singleProduct.getAllSizes();
    searchResult.addProdType = addProductType;
    if (lstValues != null) {
      for (ESPProduct.Values obj : lstValues) {
        if (obj.Name != null) {
          searchResult.Sizes = searchResult.Sizes + obj.Name + ',';
          searchResult.sizeExist = true;
        }
      }
    }
    /*else
        {
        searchResult.sizeExist = false;
        }*/
    if (singleProduct != null && singleProduct.Description != null) {
      searchResult.Description = singleProduct.Description;
      searchResult.descriptionExist = true;
    }
    if (singleProduct != null && singleProduct.ShortDescription != null) {
      searchResult.ShortDescription = singleProduct.ShortDescription;
      searchResult.shortDescriptionExist = true;
    }

    if (singleProduct != null && singleProduct.ImageUrl != null) {
      searchResult.ImageUrl = singleProduct.ImageUrl + '?size=large';
      searchResult.imageExits = true;
    }

    if (singleProduct != null && singleProduct.Id != null) {
      searchResult.Id = singleProduct.Id;
      searchResult.idExist = true;
    }
    if (singleProduct != null && singleProduct.NumberValue != null) {
      searchResult.Number_Z = singleProduct.NumberValue;
      searchResult.cpnExist = true;
    }
    if (singleProduct != null && singleProduct.TradeNames != null) {
      List<String> tradeNamesList = new List<String>();
      for (String tradeVal : singleProduct.TradeNames) {
        tradeNamesList.add(tradeVal);
      }
      if (tradeNamesList.size() > 0) {
        searchResult.tradeNamesExist = true;
        searchResult.tradeNames = string.join(tradeNamesList, ', ');
      }
    }
    if (
      singleProduct != null &&
      singleProduct.SupplierObj != null &&
      singleProduct.SupplierObj.Name != null
    ) {
      searchResult.SupplierName = singleProduct.SupplierObj.Name;
      searchResult.supplierNameExist = true;
    }

    ///////
    //
    //
    if (singleProduct != null && singleProduct.SupplierObj.AsiNumber != null) {
      searchResult.AsiNumber = singleProduct.SupplierObj.AsiNumber;
      searchResult.supplierCodeExist = true;
    }
    if (singleProduct != null && singleProduct.SupplierObj.Rating != null) {
      searchResult.Rating = singleProduct.SupplierObj.Rating;
      searchResult.RatingExist = true;
    }
    if (
      singleProduct != null &&
      singleProduct.SupplierObj.RatingCount != null
    ) {
      searchResult.RatingCount = singleProduct.SupplierObj.RatingCount;
      searchResult.RatingCountExist = true;
    }
    if (singleProduct != null && singleProduct.Name != null) {
      searchResult.Name = singleProduct.Name;
    }
    if (singleProduct != null && singleProduct.SupplierObj.Phone != null) {
      searchResult.Work = singleProduct.SupplierObj.Phone;
      searchResult.phoneExist = true;
    }
    /////
    searchResult.Sizes = searchResult.Sizes.removeEnd(',');
    List<ESPProduct.Values> colorValues = singleProduct.getAllColors();
    if (colorValues != null) {
      for (ESPProduct.Values obj : colorValues) {
        if (obj.Name != null) {
          searchResult.Colors = searchResult.Colors + obj.Name + ',';
          searchResult.colorsExist = true;
        }
      }
    }
    /* else
        {
        searchResult.colorsExist  = false;
        }*/
    searchResult.Colors = searchResult.Colors.removeEnd(',');
    if (getImprintingMethods(singleProduct.ImprintingObj) != null) {
      searchResult.ImprintMethod = getImprintingMethods(
        singleProduct.ImprintingObj
      );
      searchResult.imprintMethodsExist = true;
    }
    /*else
        {
        searchResult.imprintMethodsExist  = false;
        }*/

    if (singleProduct.LastUpdateDate != null) {
      String data = singleProduct.LastUpdateDate;
      Datetime dt = (DateTime) JSON.deserialize(
        '"' + data + '"',
        DateTime.class
      );
      searchResult.updateDate = dt.format('d/M/y');
      searchResult.lastDateExist = true;
    }
    /*else
        {
        searchResult.lastDateExist =false;
        }*/
    if (singleProduct.isConfirmed != null) {
      searchResult.IsConfirmed = singleProduct.isConfirmed;
    }
    if (
      singleProduct.productionTime != null &&
      singleProduct.productionTime.size() > 0
    ) {
      for (ESPProduct.Values obj : singleProduct.productionTime) {
        if (obj.Name != null) {
          searchResult.productionTime =
            searchResult.productionTime +
            obj.Name +
            ',';
          searchResult.prodTimeExist = true;
        }
      }
      searchResult.productionTime = searchResult.productionTime.removeEnd(',');
    } else {
      searchResult.prodTimeExist = false;
    }

    if (singleProduct.SupplierObj.Websites != null) {
      searchResult.Website = singleProduct.SupplierObj.Websites;
      searchResult.websiteExist = true;
    }
    /*else
        {
        searchResult.websiteExist  = false;
        }*/
    if (singleProduct.SupplierObj.email != null) {
      searchResult.Email = singleProduct.SupplierObj.email;
      searchResult.emailExist = true;
    }
    /*else
        {
        searchResult.emailExist  = false;
        }*/
    List<Values> productOptions = new List<Values>();
    if (singleProduct.Options != null) {
      for (ESPProduct.Options obj : singleProduct.Options) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = '';
        if (obj.Groups != null) {
          for (ESPProduct.Groups obj2 : obj.Groups) {
            tmpProduct.description =
              tmpProduct.description +
              obj2.Name +
              '<br/>';
          }
        }
        if (tmpProduct.description != '') {
          productOptions.add(tmpProduct);
        }
      }
      searchResult.productOptions = productOptions;
    }
    List<Values> productSamples = new List<Values>();
    if (singleProduct.Samples != null) {
      for (ESPProduct.Values obj : singleProduct.Samples) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = obj.Description;
        productSamples.add(tmpProduct);
        searchResult.prodSamplesExist = true;
      }
      searchResult.Samples = productSamples;
    } else {
      searchResult.prodSamplesExist = false;
    }
    if (
      singleProduct.ImprintingObj != null &&
      singleProduct.ImprintingObj.Sizes != null &&
      singleProduct.ImprintingObj.Sizes.Values != null
    ) {
      for (ESPProduct.Values obj : singleProduct.ImprintingObj.Sizes.Values) {
        if (obj.Name != null)
          searchResult.imprintSizes =
            searchResult.imprintSizes +
            obj.Name +
            ',';
        searchResult.imprintSizeExist = true;
      }
    } else {
      searchResult.imprintSizeExist = false;
    }
    searchResult.imprintSizes = searchResult.imprintSizes.removeEnd(',');
    if (
      singleProduct.ImprintingObj != null &&
      singleProduct.ImprintingObj.Colors != null &&
      singleProduct.ImprintingObj.Colors.Values != null
    ) {
      for (ESPProduct.Values obj : singleProduct.ImprintingObj.Colors.Values) {
        searchResult.imprintColors =
          searchResult.imprintColors +
          obj.Name +
          ',';
        searchResult.imprintColorExist = true;
      }
    } else {
      searchResult.imprintColorExist = false;
    }
    searchResult.imprintColors = searchResult.imprintColors.removeEnd(',');
    if (singleProduct.ImprintingObj != null) {
      if (singleProduct.ImprintingObj.FullColorProcess != null)
        searchResult.fullColorProcess = singleProduct.ImprintingObj.FullColorProcess;
      if (singleProduct.ImprintingObj.Personalization != null)
        searchResult.personalization = singleProduct.ImprintingObj.Personalization;
      if (singleProduct.ImprintingObj.SoldUnimprinted != null)
        searchResult.soldUnImprinted = singleProduct.ImprintingObj.SoldUnimprinted;
    }
    if (singleProduct.certifications != null) {
      searchResult.certifications = singleProduct.certifications;
      searchResult.certificatesExist = true;
    } else {
      searchResult.certificatesExist = false;
    }

    searchResult.hasRushService = singleProduct.rushService;
    if (singleProduct.countryOfOrigin != null) {
      for (String obj : singleProduct.countryOfOrigin) {
        if (obj != null) {
          if (obj == 'U.S.A.') {
            searchResult.madeInUSA = true;
          }
          searchResult.countryOfOrigin =
            searchResult.countryOfOrigin +
            obj +
            ',';
          searchResult.countryOfOriginExist = true;
        }
      }
    }
    /*else
        {searchResult.countryOfOriginExist  = false;
        }*/
    if (
      singleProduct.Shipping != null &&
      singleProduct.Shipping.FOBPoints != null
    ) {
      for (ESPProduct.Values obj : singleProduct.Shipping.FOBPoints) {
        searchResult.fobPoints = searchResult.fobPoints + obj.Name + ',';
        searchResult.fobShippingPointExist = true;
      }
    } else {
      searchResult.fobShippingPointExist = false;
    }
    searchResult.fobPoints = searchResult.fobPoints.removeEnd(',');
    searchResult.countryOfOrigin = searchResult.countryOfOrigin.removeEnd(',');
    if (
      singleProduct.Shipping != null &&
      singleProduct.Shipping.weights != null
    ) {
      for (ESPProduct.Values obj : singleProduct.Shipping.weights) {
        searchResult.shippingWeight =
          searchResult.shippingWeight +
          obj.Name +
          ',';
        searchResult.shippingWeightExist = true;
      }
    } else {
      searchResult.shippingWeightExist = false;
    }
    searchResult.shippingWeight = searchResult.shippingWeight.removeEnd(',');
    List<Values> shippingOptions = new List<Values>();
    if (
      singleProduct.Shipping != null &&
      singleProduct.Shipping.Options != null
    ) {
      for (ESPProduct.Values obj : singleProduct.Shipping.Options) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = obj.Description;
        shippingOptions.add(tmpProduct);
        searchResult.shippingOptionsExist = true;
      }
      searchResult.shippingOptions = shippingOptions;
    } else {
      searchResult.shippingOptionsExist = false;
    }
    if (singleProduct.Shipping != null) {
      if (singleProduct.Shipping.ItemsPerPackage != null) {
        searchResult.ItemsPerPackage = singleProduct.Shipping.ItemsPerPackage;
        searchResult.shipingEstimateExist = true;
      }
    } else {
      searchResult.shipingEstimateExist = false;
    }
    if (singleProduct.Shipping != null) {
      if (singleProduct.Shipping.Dimensions != null) {
        searchResult.Dimensions = singleProduct.Shipping.Dimensions;
        searchResult.shippingDimensions = true;
      }
    } else {
      searchResult.shippingDimensions = false;
    }

    if (singleProduct.Shipping != null) {
      if (singleProduct.Shipping.PackageInPlainBox != null) {
        searchResult.PackageInPlainBox = singleProduct.Shipping.PackageInPlainBox;
      }
    }
    if (singleProduct.DistributorComments != null) {
      searchResult.DistributorComments = singleProduct.DistributorComments;
      searchResult.distributorCommentsExist = true;
    } else {
      searchResult.distributorCommentsExist = false;
    }

    List<Values> rushTimes = new List<Values>();
    if (singleProduct.rushTime != null) {
      for (ESPProduct.Values obj : singleProduct.rushTime) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = obj.Description;
        rushTimes.add(tmpProduct);
        searchResult.rushTimeExist = true;
      }

      searchResult.rushTime = rushTimes;
    } else {
      searchResult.rushTimeExist = false;
    }
    List<Values> productionTime = new List<Values>();
    if (singleProduct.productionTime != null) {
      for (ESPProduct.Values obj : singleProduct.productionTime) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = obj.Description;
        productionTime.add(tmpProduct);
      }

      searchResult.prodTime = productionTime;
    }
    //searchResult.SupplierFax = singleProduct.SupplierObj.FaxNumber;
    searchResult.warnings = singleProduct.warnings;
    if (searchResult.warnings.size() > 0) {
      searchResult.warningExist = true;
    }
    if (singleProduct.additionalInformation != null) {
      searchResult.additionalInformation = singleProduct.additionalInformation;
      searchResult.additionalInformationExist = true;
    }
    List<Price> pricesList = new List<Price>();
    if (singleProduct != null && singleProduct.LstPrices != null) {
      List<ESPProduct.Prices> lstPrices = singleProduct.LstPrices;
      if (lstPrices != null) {
        Integer discountCodeCount = 0;
        String discountCode = '';
        for (ESPProduct.Prices obj : lstPrices) {
          if (
            obj != null &&
            obj.Quantity != null &&
            obj.Price != null &&
            obj.cost != null
          ) {
            searchResult.pricingExist = true;
            Price tmpProduct = new Price();
            tmpProduct.quantity = obj.Quantity.From_Z;
            tmpProduct.cost = obj.Cost;
            tmpProduct.price = obj.Price;
            tmpProduct.profit = tmpProduct.price - tmpProduct.cost;

            if (obj.DiscountCode != null) {
              discountCode = obj.DiscountCode;
              discountCodeCount++;
            }
            pricesList.add(tmpProduct);

            if (searchResult.highestPrice < obj.Price) {
              searchResult.highestPrice = obj.Price;
            }
            if (searchResult.lowestPrice > obj.Price) {
              searchResult.lowestPrice = obj.Price;
            }
          }
        }
        if (discountCodeCount > 1 && discountCode != '') {
          searchResult.priceDiscountCode =
            '(' +
            discountCodeCount +
            discountCode +
            ')';
          searchResult.priceDiscountCodeExist = true;
        } else if (discountCodeCount == 1 && discountCode != '') {
          searchResult.priceDiscountCode = '(' + discountCode + ')';
          searchResult.priceDiscountCodeExist = true;
        }
      }
    }
    if (searchResult.highestPrice != 0 && searchResult.lowestPrice != 100000) {
      searchResult.priceExist = true;
    }
    searchResult.prices = pricesList;
    List<Values> artworkProofs = new List<Values>();
    if (
      singleProduct.ImprintingObj.Services != null &&
      singleProduct.ImprintingObj.Services.Values != null
    ) {
      for (
        ESPProduct.Values obj : singleProduct.ImprintingObj.Services.Values
      ) {
        Values tmpProduct = new Values();
        tmpProduct.name = obj.Name;
        tmpProduct.description = obj.Description;
        artworkProofs.add(tmpProduct);
        searchResult.artworkProofsExist = true;
      }
      searchResult.artworkProofs = artworkProofs;
    } else {
      searchResult.artworkProofsExist = false;
    }

    if (singleProduct.catalogs != null) {
      for (ESPProduct.Values obj : singleProduct.catalogs) {
        if (obj.Name != null) {
          searchResult.catalogs = searchResult.catalogs + obj.Name + ',';
          searchResult.catalogExist = true;
        }
      }
      searchResult.catalogs = searchResult.catalogs.removeEnd(',');
    }
    if (singleProduct.catagories != null) {
      for (ESPProduct.Values obj : singleProduct.catagories) {
        if (obj.Name != null) {
          searchResult.catagories = searchResult.catagories + obj.Name + ',';
          searchResult.catagoriesExist = true;
        }
      }
      searchResult.catagories = searchResult.catagories.removeEnd(',');
    }
    List<ESPProduct.Values> materialsValues = singleProduct.getAllMaterials();
    if (materialsValues != null) {
      for (ESPProduct.Values obj : materialsValues) {
        if (obj.Name != null) {
          searchResult.materials = searchResult.materials + obj.Name + ',';
          searchResult.materialExist = true;
        }
      }
    }
    searchResult.materials = searchResult.materials.removeEnd(',');
    searchResult.imprintDetails = getImprintingMethodsWithDetails(
      singleProduct.ImprintingObj
    );
    searchResult.imprintLocations = getImprintingLocations(
      singleProduct.ImprintingObj
    );
    if (searchResult.imprintLocations.size() > 0) {
      searchResult.locationsExist = true;
    }
    if (
      singleProduct.ImprintingObj != null &&
      singleProduct.ImprintingObj.additionalInformation != null
    ) {
      searchResult.additionalInfoExist = true;
      searchResult.additionalInfo = singleProduct.ImprintingObj.additionalInformation;
    }
    if (singleProduct.weight != null && singleProduct.weight.size() > 0) {
      List<String> weightVals = new List<String>();
      for (String val : singleProduct.weight) {
        weightVals.add(val);
        searchResult.productWeightExist = true;
      }
      searchResult.productWeight = string.join(weightVals, ', ');
    }

    if (
      singleProduct.SupplierObj != null &&
      singleProduct.SupplierObj.FaxNumber != null
    ) {
      searchResult.supplierFax = singleProduct.SupplierObj.FaxNumber;
      searchResult.supplierFaxExist = true;
    }
    if (singleProduct.packaging != null) {
      for (ESPProduct.Values val : singleProduct.packaging) {
        searchResult.packaging.add(val.Name);
        searchResult.packagingExist = true;
      }
    }
    if (
      singleProduct.ImprintingObj != null &&
      singleProduct.ImprintingObj.imprintOptions != null
    ) {
      for (
        ESPProduct.OptionsForImprinting val : singleProduct.ImprintingObj.imprintOptions
      ) {
        OptionsForImprinting tempOption = new OptionsForImprinting();
        if (val.Name != null)
          tempOption.Name = val.Name;
        if (val.Values != null)
          tempOption.Values = val.Values;
        if (tempOption != null)
          searchResult.imprintOptions.add(tempOption);
      }
      if (
        singleProduct.ImprintingObj != null &&
        singleProduct.ImprintingObj.Options != null
      ) {
        for (ESPProduct.Options val : singleProduct.ImprintingObj.Options) {
          OptionsForImprinting tempOption = new OptionsForImprinting();
          if (val.Name != null)
            tempOption.Name = val.Name;
          if (val.Groups != null) {
            for (ESPProduct.Groups groupValue : val.Groups) {
              tempOption.Values.add(groupValue.Name);
            }
          }
          searchResult.imprintOptionGroups.add(tempOption);
        }
      }
    }
    List<String> variantImages = new List<String>();
    if (singleProduct.lstVariants != null) {
      for (ESPProduct.Variants obj : singleProduct.lstVariants) {
        variantInfromation tempInfo = new variantInfromation();
        if (obj.Id != null) {
          tempInfo.Id = obj.Id;
        }
        if (obj.Name != null) {
          tempInfo.Name = obj.Name;
        }
        if (obj.Description != null) {
          tempInfo.Description = obj.Description;
        }
        if (obj.PriceIncludes != null) {
          tempInfo.PriceIncludes = obj.PriceIncludes;
          tempInfo.PriceIncludesExist = true;
        }
        Integer discountCodeCount = 0;
        String discountCode = '';
        Map<String, Integer> pricesDiscountCodes = new Map<String, Integer>();
        if (obj.Prices != null) {
          List<Price> priceList = new List<Price>();
          for (ESPProduct.Prices pr : obj.Prices) {
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
              priceList.add(tempPr);
              if (searchResult.highestPrice < pr.Price) {
                searchResult.highestPrice = pr.Price;
              }
              if (searchResult.lowestPrice > pr.Price) {
                searchResult.lowestPrice = pr.Price;
              }
            }
          }
          if (pricesDiscountCodes != null) {
            if (pricesDiscountCodes.size() > 1) {
              tempInfo.multiplePriceDiscounts = '(';
              for (String key : pricesDiscountCodes.keySet()) {
                if (pricesDiscountCodes.get(key) > 1) {
                  tempInfo.multiplePriceDiscounts =
                    tempInfo.multiplePriceDiscounts +
                    String.ValueOf(pricesDiscountCodes.get(key)) +
                    key;
                } else {
                  tempInfo.multiplePriceDiscounts =
                    tempInfo.multiplePriceDiscounts + key;
                }
                tempInfo.multiplePriceDiscountsExist = true;
              }
              tempInfo.multiplePriceDiscounts =
                tempInfo.multiplePriceDiscounts + ')';
            } else {
              for (String key : pricesDiscountCodes.keySet()) {
                discountCode = discountCode + key;
                discountCodeCount =
                  discountCodeCount + pricesDiscountCodes.get(key);
              }
            }
          }
          if (discountCodeCount > 1 && discountCode != '') {
            tempInfo.priceDiscountCode =
              '(' +
              discountCodeCount +
              discountCode +
              ')';
            tempInfo.priceDiscountCodeExist = true;
          } else if (discountCodeCount == 1 && discountCode != '') {
            tempInfo.priceDiscountCode = '(' + discountCode + ')';
            tempInfo.priceDiscountCodeExist = true;
          }
          if (priceList.size() > 0) {
            tempInfo.Prices = priceList;
            tempInfo.variantPrices = true;
          }
          if (tempInfo != null) {
            searchResult.variantInfo.add(tempInfo);
          }
        }
        if (obj.ImageUrl != null) {
          searchResult.variantImages.add(
            System.Label.ESP_URL + obj.ImageUrl + '?size=large'
          );
        }
      }
      if (searchResult.variantInfo.size() > 0) {
        searchResult.variantInfoExist = true;
      } else {
        searchResult.variantInfoExist = false;
      }
      if (searchResult.variantImages.size() > 0) {
        searchResult.variantImages.add(searchResult.ImageUrl);
      }
    }
    if (searchResult.highestPrice != 0 && searchResult.lowestPrice != 100000) {
      searchResult.priceExist = true;
    }
    if (singleProduct.isAssembeled != null) {
      searchResult.isAssembeled = singleProduct.isAssembeled;
    }
    if (singleProduct.PriceIncludes != null) {
      searchResult.PriceIncludes = singleProduct.PriceIncludes;
      searchResult.PriceIncludesExist = true;
    }
  }
  private static List<String> getImprintingLocations(
    ESPProduct.Imprinting imp
  ) {
    List<String> retVal = new List<String>();
    if (
      imp != null &&
      imp.Locations != null &&
      imp.Locations.Values != null &&
      imp.Locations.Values.size() > 0
    ) {
      for (String val : imp.Locations.Values) {
        retVal.add(val);
      }
    }
    return retVal;
  }
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

  private static List<ImprintDetails> getImprintingMethodsWithDetails(
    ESPProduct.Imprinting imp
  ) {
    List<ImprintDetails> retVal = new List<ImprintDetails>();
    ImprintDetails temImp = new ImprintDetails();
    Values tempVal = new Values();
    variantInfromation tempInfo = new variantInfromation();
    OptionsForImprinting tempOption = new OptionsForImprinting();
    if (
      imp != null &&
      imp.Methods != null &&
      imp.Methods.Values != null &&
      imp.Methods.Values.size() > 0
    ) {
      for (ESPProduct.Values val : imp.Methods.Values) {
        ImprintDetails temp = new ImprintDetails();
        temp.name = val.Name;
        if (val.Charges != null) {
          for (ESPProduct.Charges ch : val.Charges) {
            temp.description = ch.Description;
            temp.imprintType = ch.Type_Z;
            temp.usageLevel = ch.UsageLevel;

            for (ESPProduct.Prices pr : ch.Prices) {
              temp.DiscountCode = pr.DiscountCode;
              temp.cost = pr.Cost;
              temp.price = pr.Price;
              temp.quantity = pr.Quantity.From_Z;
            }
          }
          retVal.add(temp);
        }
      }
    }
    return retVal;
  }
  public ESPSearchResults getSearch() {
    return searchResult;
  }
  public void addProduct() {
    System.debug(
      '---recordFrom:--- ' +
      Apexpages.currentPage().getParameters().get('recordFrom')
    );
    String variantId = Apexpages.currentPage().getParameters().get('recId');
    String productId = apexpages.currentpage().getparameters().get('ProductId');
    String recordFrom = apexpages.currentpage()
      .getparameters()
      .get('recordFrom');
    System.debug('----productId----' + productId);
    String estimateId = null;
    Estimate__c estimate = new Estimate__c();
    if (recordFrom == 'Estimate') {
      estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :oppId
      ];
    }
    if (estimate.id != null)
      estimateId = estimate.id;

    Boolean response = AddProductESPTabController.createOpportunityLineItemEsp(
      productId,
      oppId,
      variantId,
      estimateId,
      adId,
      adPosition,
      recordFrom,
      this.workOrderId,
      null,
      null
    );
    if (response == false) {
      System.debug('Error in adding product');
      ValueReturned = false;
    } else
      ValueReturned = true;
  }
  public void addSingleProduct() {
    System.debug(
      'recordFrom: ' + Apexpages.currentPage().getParameters().get('recordFrom')
    );
    //String variantId = Apexpages.currentPage().getParameters().get('recId');
    String productId = apexpages.currentpage().getparameters().get('ProductId');
    String recordFrom = apexpages.currentpage()
      .getparameters()
      .get('recordFrom');
    String estimateId = null;
    Estimate__c estimate = new Estimate__c();
    if (recordFrom == 'Estimate') {
      estimate = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :oppId
      ];
    }
    if (estimate.id != null)
      estimateId = estimate.id;

    Boolean response = AddProductESPTabController.createOpportunityLineItemEsp(
      productId,
      oppId,
      null,
      estimateId,
      adId,
      adPosition,
      recordFrom,
      this.workOrderId,
      null,
      null
    );
    if (response == false) {
      System.debug('Error in adding product');
      ValueReturned = false;
    } else
      ValueReturned = true;
  }
  public class ESPSearchResults {
    @AuraEnabled
    public Integer Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public Boolean addProdType { get; set; }
    @AuraEnabled
    public String DistributorComments { get; set; }
    @AuraEnabled
    public String ShortDescription { get; set; }
    @AuraEnabled
    public String Number_Z { get; set; }
    @AuraEnabled
    public String ImageUrl { get; set; }
    @AuraEnabled
    public List<String> variantImages { get; set; }
    @AuraEnabled
    public String ConfigId { get; set; }
    @AuraEnabled
    public Boolean IsNew { get; set; }
    @AuraEnabled
    public Boolean IsConfirmed { get; set; }
    @AuraEnabled
    public List<String> packaging { get; set; }

    @AuraEnabled
    public Boolean HasVirtualSample { get; set; }
    @AuraEnabled
    public Double Cost { get; set; }
    @AuraEnabled
    public Double Price { get; set; }
    @AuraEnabled
    public String SupplierName { get; set; }
    @AuraEnabled
    public String AsiNumber { get; set; }
    @AuraEnabled
    public String Work { get; set; }
    @AuraEnabled
    public String SupplierFax { get; set; }
    @AuraEnabled
    public String Sizes { get; set; }
    @AuraEnabled
    public String ImprintMethod { get; set; }
    @AuraEnabled
    public String updateDate { get; set; }
    @AuraEnabled
    public String Website { get; set; }
    @AuraEnabled
    public Integer Rating { get; set; }
    @AuraEnabled
    public Boolean RatingExist { get; set; }
    @AuraEnabled
    public Integer RatingCount { get; set; }
    @AuraEnabled
    public Boolean RatingCountExist { get; set; }
    @AuraEnabled
    public String Email { get; set; }
    @AuraEnabled
    public List<Price> prices { get; set; }
    @AuraEnabled
    public String Colors { get; set; }
    @AuraEnabled
    public Double highestPrice { get; set; }
    @AuraEnabled
    public Double lowestPrice { get; set; }
    @AuraEnabled
    public String productionTime { get; set; }
    @AuraEnabled
    public String countryOfOrigin { get; set; }
    @AuraEnabled
    public String PriceIncludes { get; set; }
    @AuraEnabled
    public Boolean PriceIncludesExist { get; set; }
    @AuraEnabled
    public Boolean tradeNamesExist { get; set; }
    @AuraEnabled
    public String tradeNames { get; set; }

    @AuraEnabled
    public String imprintSizes { get; set; }
    @AuraEnabled
    public String imprintColors { get; set; }
    @AuraEnabled
    public Boolean fullColorProcess { get; set; }
    @AuraEnabled
    public Boolean personalization { get; set; }
    @AuraEnabled
    public Boolean soldUnImprinted { get; set; }

    @AuraEnabled
    public List<String> certifications { get; set; }
    @AuraEnabled
    public List<String> warnings { get; set; }
    @AuraEnabled
    public List<Values> artworkProofs { get; set; }
    @AuraEnabled
    public List<Values> rushTime { get; set; }
    @AuraEnabled
    public List<Values> prodTime { get; set; }
    @AuraEnabled
    public String catalogs { get; set; }
    @AuraEnabled
    public Boolean catalogExist { get; set; }
    @AuraEnabled
    public String catagories { get; set; }
    @AuraEnabled
    public Boolean catagoriesExist { get; set; }
    @AuraEnabled
    public Boolean hasRushService { get; set; }
    @AuraEnabled
    public List<Values> productOptions { get; set; }
    @AuraEnabled
    public List<Values> Samples { get; set; }

    @AuraEnabled
    public String fobPoints { get; set; }
    @AuraEnabled
    public String shippingWeight { get; set; }
    @AuraEnabled
    public String Dimensions { get; set; }
    @AuraEnabled
    public Integer ItemsPerPackage { get; set; }
    @AuraEnabled
    public List<Values> shippingOptions { get; set; }
    @AuraEnabled
    public List<ImprintDetails> imprintDetails { get; set; }
    @AuraEnabled
    public Boolean PackageInPlainBox { get; set; }

    @AuraEnabled
    public Boolean warningExist { get; set; }
    @AuraEnabled
    public Boolean sizeExist { get; set; }
    @AuraEnabled
    public Boolean descriptionExist { get; set; }
    @AuraEnabled
    public Boolean idExist { get; set; }
    @AuraEnabled
    public Boolean cpnExist { get; set; }
    @AuraEnabled
    public Boolean lastDateExist { get; set; }
    @AuraEnabled
    public Boolean priceExist { get; set; }
    @AuraEnabled
    public Boolean colorsExist { get; set; }
    @AuraEnabled
    public Boolean imprintMethodsExist { get; set; }
    @AuraEnabled
    public Boolean prodTimeExist { get; set; }
    @AuraEnabled
    public Boolean supplierNameExist { get; set; }
    @AuraEnabled
    public Boolean supplierCodeExist { get; set; }
    @AuraEnabled
    public Boolean phoneExist { get; set; }
    @AuraEnabled
    public Boolean emailExist { get; set; }
    @AuraEnabled
    public Boolean websiteExist { get; set; }
    @AuraEnabled
    public Boolean pricingExist { get; set; }
    @AuraEnabled
    public Boolean imprintSizeExist { get; set; }
    @AuraEnabled
    public Boolean imprintColorExist { get; set; }
    @AuraEnabled
    public Boolean artworkProofsExist { get; set; }
    @AuraEnabled
    public Boolean distributorCommentsExist { get; set; }
    @AuraEnabled
    public Boolean prodOptionsExist { get; set; }
    @AuraEnabled
    public Boolean prodSamplesExist { get; set; }
    @AuraEnabled
    public Boolean certificatesExist { get; set; }
    @AuraEnabled
    public Boolean rushTimeExist { get; set; }
    @AuraEnabled
    public Boolean countryOfOriginExist { get; set; }
    @AuraEnabled
    public Boolean fobShippingPointExist { get; set; }
    @AuraEnabled
    public Boolean shippingWeightExist { get; set; }
    @AuraEnabled
    public Boolean shipingEstimateExist { get; set; }
    @AuraEnabled
    public Boolean shippingOptionsExist { get; set; }
    @AuraEnabled
    public Boolean shippingDimensions { get; set; }
    @AuraEnabled
    public Boolean imageExits { get; set; }
    @AuraEnabled
    public String materials { get; set; }
    @AuraEnabled
    public Boolean materialExist { get; set; }
    @AuraEnabled
    public Boolean shortDescriptionExist { get; set; }
    @AuraEnabled
    public Boolean locationsExist { get; set; }
    @AuraEnabled
    public List<String> imprintLocations { get; set; }
    @AuraEnabled
    public String additionalInfo { get; set; }
    @AuraEnabled
    public Boolean additionalInfoExist { get; set; }
    @AuraEnabled
    public String productWeight { get; set; }
    @AuraEnabled
    public Boolean productWeightExist { get; set; }
    @AuraEnabled
    public Boolean supplierFaxExist { get; set; }
    @AuraEnabled
    public Boolean packagingExist { get; set; }
    @AuraEnabled
    public Boolean madeInUSA { get; set; }
    @AuraEnabled
    public List<OptionsForImprinting> imprintOptions { get; set; }
    @AuraEnabled
    public List<OptionsForImprinting> imprintOptionGroups { get; set; }
    @AuraEnabled
    public String additionalInformation { get; set; }
    @AuraEnabled
    public Boolean additionalInformationExist { get; set; }
    @AuraEnabled
    public List<variantInfromation> variantInfo { get; set; }
    @AuraEnabled
    public Boolean variantInfoExist { get; set; }
    @AuraEnabled
    public Boolean isAssembeled { get; set; }
    @AuraEnabled
    public String priceDiscountCode { get; set; }
    @AuraEnabled
    public Boolean priceDiscountCodeExist { get; set; }
    public ESPSearchResults() {
      Sizes = '';
      priceDiscountCode = '';
      priceDiscountCodeExist = false;
      certifications = new List<String>();
      warnings = new List<String>();
      artworkProofs = new List<Values>();
      rushTime = new List<Values>();
      prodTime = new List<Values>();
      catalogs = '';
      tradeNames = '';
      tradeNamesExist = false;
      Sizes = '';
      isAssembeled = false;
      variantInfo = new List<variantInfromation>();
      additionalInformation = '';
      additionalInformationExist = false;
      variantInfoExist = false;
      imprintOptionGroups = new List<OptionsForImprinting>();
      imprintOptions = new List<OptionsForImprinting>();
      madeInUSA = false;
      RatingExist = false;
      RatingCountExist = false;
      packaging = new List<String>();
      packagingExist = false;
      rushTime = new List<Values>();
      additionalInfo = '';
      PriceIncludes = '';
      PriceIncludesExist = false;
      locationsExist = false;
      productWeightExist = false;
      supplierFax = '';
      Sizes = '';
      supplierFaxExist = false;
      productWeight = '';
      additionalInfoExist = false;
      shortDescriptionExist = false;
      catagories = '';
      materials = '';
      materialExist = false;
      catagoriesExist = false;
      catalogExist = false;
      catalogs = '';
      fobPoints = '';
      DistributorComments = '';
      PackageInPlainBox = false;
      ItemsPerPackage = 0;
      shippingWeight = '';
      Rating = 0;
      Dimensions = '';
      highestPrice = 0;
      lowestPrice = 100000;
      Colors = '';
      productionTime = '';
      SupplierFax = '';
      isConfirmed = false;
      hasRushService = false;
      warningExist = false;
      ImprintMethod = '';
      imprintSizes = '';
      imprintColors = '';
      countryOfOrigin = '';
      sizeExist = false;
      Sizes = '';
      fullColorProcess = false;
      personalization = false;
      soldUnImprinted = false;
      imprintLocations = new List<String>();
      prices = new List<Price>();
      artworkProofs = new List<Values>();
      prodTime = new List<Values>();
      Samples = new List<Values>();
      shippingOptions = new List<Values>();
      productOptions = new List<Values>();
      certifications = new List<String>();
      imprintDetails = new List<ImprintDetails>();
      warnings = new List<String>();
      variantImages = new List<String>();
      descriptionExist = false;
      idExist = false;
      imageExits = false;
      cpnExist = false;
      lastDateExist = false;
      priceExist = false;
      colorsExist = false;
      imprintMethodsExist = false;
      prodTimeExist = false;
      supplierNameExist = false;
      supplierCodeExist = false;
      phoneExist = false;
      emailExist = false;
      websiteExist = false;
      pricingExist = false;
      imprintSizeExist = false;
      imprintColorExist = false;
      artworkProofsExist = false;
      productionTime = '';
      SupplierFax = '';
      isConfirmed = false;
      hasRushService = false;
      warningExist = false;
      ImprintMethod = '';
      imprintSizes = '';
      imprintColors = '';
      countryOfOrigin = '';
      sizeExist = false;
      sizeExist = false;
      Sizes = '';
      fullColorProcess = false;
      personalization = false;
      soldUnImprinted = false;
      imprintLocations = new List<String>();
      prices = new List<Price>();
      distributorCommentsExist = false;
      prodOptionsExist = false;
      prodSamplesExist = false;
      Name = '';
      Description = '';
      ShortDescription = '';
      Number_Z = '';
      ImageUrl = '';
      Sizes = '';
      ConfigId = '';
      IsNew = false;
      certificatesExist = false;
      rushTimeExist = false;
      countryOfOriginExist = false;
      fobShippingPointExist = false;
      Sizes = '';
      shippingWeightExist = false;
      shipingEstimateExist = false;
      shippingOptionsExist = false;
      shippingDimensions = false;
      HasVirtualSample = false;
      isAssembeled = false;
      variantInfo = new List<variantInfromation>();
      additionalInformation = '';
      additionalInformationExist = false;
      variantInfoExist = false;
      imprintOptionGroups = new List<OptionsForImprinting>();
      imprintOptions = new List<OptionsForImprinting>();
      madeInUSA = false;
      Cost = 0;
      Price = 0;
      SupplierName = '';
      AsiNumber = '';
      Work = '';
      Name = '';
      Description = '';
      ShortDescription = '';
      Number_Z = '';
      ImageUrl = '';
      Sizes = '';
      ConfigId = '';
      IsNew = false;
      priceDiscountCode = '';
      priceDiscountCodeExist = false;
      certifications = new List<String>();
      warnings = new List<String>();
      artworkProofs = new List<Values>();
      rushTime = new List<Values>();
      prodTime = new List<Values>();
      supplierFaxExist = false;
      productWeight = '';
      additionalInfoExist = false;
      shortDescriptionExist = false;
      catagories = '';
      materials = '';
      materialExist = false;
      catagoriesExist = false;
      catalogExist = false;
      catalogs = '';
      tradeNames = '';
      tradeNamesExist = false;
      Sizes = '';
      isAssembeled = false;
      variantInfo = new List<variantInfromation>();
      additionalInformation = '';
      additionalInformationExist = false;
      variantInfoExist = false;
      imprintOptionGroups = new List<OptionsForImprinting>();
      imprintOptions = new List<OptionsForImprinting>();
      madeInUSA = false;
      packaging = new List<String>();
      packagingExist = false;
      rushTime = new List<Values>();
      additionalInfo = '';
      PriceIncludes = '';
      PriceIncludesExist = false;
      locationsExist = false;
      productWeightExist = false;
      variantImages = new List<String>();
      descriptionExist = false;
      idExist = false;
      imageExits = false;
      cpnExist = false;
      lastDateExist = false;
      priceExist = false;
      colorsExist = false;
      imprintMethodsExist = false;
      prodTimeExist = false;
      supplierNameExist = false;
      supplierCodeExist = false;
    }
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
    @AuraEnabled
    public String priceDiscount { get; set; }
    @AuraEnabled
    public Boolean priceExist { get; set; }
    public Price() {
      priceExist = false;
      quantity = 0;
      price = 0;
      cost = 0;
      profit = 0;
      priceDiscount = '';
    }
  }
  public class ImprintDetails {
    @AuraEnabled
    public Integer quantity { get; set; }
    @AuraEnabled
    public Double price { get; set; }
    @AuraEnabled
    public Double cost { get; set; }
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    public String DiscountCode { get; set; }
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String imprintType { get; set; }
    @AuraEnabled
    public String usageLevel { get; set; }
    public ImprintDetails() {
      quantity = 0;
      price = 0;
      cost = 0;
      name = '';
      description = '';
      DiscountCode = '';
      imprintType = '';
      usageLevel = '';
    }
  }
  public class Values {
    @AuraEnabled
    public String name { get; set; }
    @AuraEnabled
    public String description { get; set; }
    public Values() {
      name = '';
      description = '';
    }
  }
  public class OptionsForImprinting {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public List<String> Values { get; set; }
    public OptionsForImprinting() {
      Name = '';
      Values = new List<String>();
    }
  }
  public class variantInfromation {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public List<Price> Prices { get; set; }
    @AuraEnabled
    public String PriceIncludes { get; set; }
    @AuraEnabled
    public Boolean PriceIncludesExist { get; set; }
    @AuraEnabled
    public String priceDiscountCode { get; set; }
    @AuraEnabled
    public Boolean priceDiscountCodeExist { get; set; }
    @AuraEnabled
    public Boolean variantPrices { get; set; }
    @AuraEnabled
    public String multiplePriceDiscounts { get; set; }
    @AuraEnabled
    public Boolean multiplePriceDiscountsExist { get; set; }
    public variantInfromation() {
      Name = '';
      Id = '';
      multiplePriceDiscounts = '';
      multiplePriceDiscountsExist = false;
      variantPrices = false;
      Description = '';
      PriceIncludes = '';
      priceDiscountCode = '';
      priceDiscountCodeExist = false;
      PriceIncludesExist = false;
      Prices = new List<Price>();
    }
  }
}
