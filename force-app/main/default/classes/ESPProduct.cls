public class ESPProduct {
  @AuraEnabled
  public Integer Id { get; set; }
  @AuraEnabled
  public String Name { get; set; }
  @AuraEnabled
  public String PriceIncludes { get; set; }
  @AuraEnabled
  public String Description { get; set; }
  @AuraEnabled
  public String ShortDescription { get; set; }
  @AuraEnabled
  public String NumberValue { get; set; }
  @AuraEnabled
  public List<Options> Options { get; set; }
  @AuraEnabled
  public Attributes Attribute { get; set; }
  @AuraEnabled
  public String ImageUrl { get; set; }
  @AuraEnabled
  public Supplier SupplierObj { get; set; }
  @AuraEnabled
  public Imprinting ImprintingObj { get; set; }
  @AuraEnabled
  public String ImprintingInfo { get; set; }
  @AuraEnabled
  public List<Variants> lstVariants { get; set; }
  @AuraEnabled
  public List<String> LstImages { get; set; }
  @AuraEnabled
  public List<Prices> LstPrices { get; set; }
  @AuraEnabled
  public Prices HighestPrice { get; set; }
  @AuraEnabled
  public String DisplayString { get; set; }
  @AuraEnabled
  public String SKU { get; set; }
  @AuraEnabled
  public String LastUpdateDate { get; set; }
  @AuraEnabled
  public Boolean isConfirmed { get; set; }
  @AuraEnabled
  public List<String> certifications { get; set; }
  @AuraEnabled
  public List<String> warnings { get; set; }
  @AuraEnabled
  public Boolean rushService { get; set; }
  @AuraEnabled
  public List<Values> rushTime { get; set; }
  @AuraEnabled
  public List<Values> productionTime { get; set; }
  @AuraEnabled
  public List<Values> Samples { get; set; }
  @AuraEnabled
  public List<String> countryOfOrigin { get; set; }
  @AuraEnabled
  public Shipping Shipping { get; set; }
  @AuraEnabled
  public String DistributorComments { get; set; }
  @AuraEnabled
  public List<Values> catalogs { get; set; }
  @AuraEnabled
  public List<Values> catagories { get; set; }
  @AuraEnabled
  public List<Values> packaging { get; set; }
  @AuraEnabled
  public List<String> weight { get; set; }
  @AuraEnabled
  public List<String> TradeNames { get; set; }
  @AuraEnabled
  public String additionalInformation { get; set; }
  @AuraEnabled
  public Boolean isAssembeled { get; set; }

  public ESPProduct() {
    lstVariants = new List<Variants>();
    LstPrices = new List<Prices>();
    LstImages = new List<String>();
  }
  public String getsku(String variantId) {
    String skuData = SKU;
    if (variantId != null) {
      for (Variants variantsObj : lstVariants) {
        if (variantsObj.Id == variantId) {
          if (variantsObj.NumberVariant != null) {
            skuData = variantsObj.NumberVariant;
          }
        }
      }
    }
    return skuData;
  }

  public Boolean parse(String response, String espEndPoint) {
    try {
      System.debug('In bool parse function : ');
      System.debug('Response1 ' + response.length());
      System.debug('Response2 ' + response);

      // System.debug('Response3 '+response.substring(response.length()-240,response.length()-1));
      lstVariants = new List<Variants>();
      LstPrices = new List<Prices>();
      LstImages = new List<String>();
      // String response = parser;
      System.debug(response);
      Map<String, Object> metadata_Map = (Map<String, Object>) JSON.deserializeUntyped(
        response
      );
      Id = parseInteger(metadata_Map.get('Id'));
      if (metadata_Map.containsKey('ImageUrl')) {
        ImageUrl = parseString(
          System.Label.ESP_URL + metadata_Map.get('ImageUrl')
        );
      }
      if (metadata_Map.containsKey('Images')) {
        LstImages = parseImages(metadata_Map.get('Images'));
      } //tradeNames
      if (metadata_Map.containsKey('TradeNames')) {
        TradeNames = parseTradeNames(metadata_Map.get('TradeNames'));
      }
      if (metadata_Map.containsKey('Options')) {
        Options = arrayOfOptions(metadata_Map.get('Options'));
      }
      if (metadata_Map.containsKey('Samples')) {
        String methodsJson = JSON.serialize(metadata_Map.get('Samples'));
        Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
          methodsJson
        );
        for (String key1 : mapMethods.keySet()) {
          if (key1 == 'Values') {
            Samples = arrayOfValues(mapMethods.get(key1));
          } else {
            System.debug(
              LoggingLevel.WARN,
              'Options consuming unrecognized property: ' + key1
            );
          }
        }
      }
      if (metadata_Map.containsKey('Packaging')) {
        String prices_list_string = JSON.serialize(
          metadata_Map.get('Packaging')
        );
        List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
          prices_list_string
        );
        for (Object objprice : variantPricesList) {
          String PricesObjString = JSON.serialize(objprice);
          Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
            PricesObjString
          );
          for (String key1 : mapPrice.keySet()) {
            if (key1 == 'Values') {
              packaging = arrayOfValues(mapPrice.get(key1));
            } else {
              System.debug(
                LoggingLevel.WARN,
                'packaging consuming unrecognized property: ' + key1
              );
            }
          }
        }
      }
      if (metadata_Map.containsKey('Weight')) {
        String methodsJson = JSON.serialize(metadata_Map.get('Weight'));
        Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
          methodsJson
        );
        for (String key1 : mapMethods.keySet()) {
          if (key1 == 'Values') {
            weight = arrayOfLocations(mapMethods.get(key1));
          } else {
            System.debug(
              LoggingLevel.WARN,
              'Options consuming unrecognized property: ' + key1
            );
          }
        }
      }
      if (metadata_Map.containsKey('Name')) {
        Name = parseString(metadata_Map.get('Name'));
      }
      if (metadata_Map.containsKey('PriceIncludes')) {
        PriceIncludes = parseString(metadata_Map.get('PriceIncludes'));
      }
      if (metadata_Map.containsKey('AdditionalInfo')) {
        additionalInformation = parseString(metadata_Map.get('AdditionalInfo'));
      }
      if (metadata_Map.containsKey('Description')) {
        Description = parseString(metadata_Map.get('Description'));
      }
      if (metadata_Map.containsKey('DistributorComments')) {
        DistributorComments = parseString(
          metadata_Map.get('DistributorComments')
        );
      }
      if (metadata_Map.containsKey('UpdateDate')) {
        LastUpdateDate = parseString(metadata_Map.get('UpdateDate'));
      }
      if (metadata_Map.containsKey('IsConfirmed')) {
        isConfirmed = parseBoolean(metadata_Map.get('IsConfirmed'));
      }
      if (metadata_Map.containsKey('ProductionTime')) {
        productionTime = getRushTime(metadata_Map.get('ProductionTime'));
      }
      if (metadata_Map.containsKey('Origin')) {
        countryOfOrigin = arrayOfOrigins(metadata_Map.get('Origin'));
      }
      if (metadata_Map.containsKey('Certifications')) {
        certifications = getCertifications(metadata_Map.get('Certifications'));
      }
      if (metadata_Map.containsKey('Warnings')) {
        warnings = getWarnings(metadata_Map.get('Warnings'));
      }
      if (metadata_Map.containsKey('Catalogs')) {
        catalogs = getRushTime(metadata_Map.get('Catalogs'));
      }
      if (metadata_Map.containsKey('Categories')) {
        catagories = getRushTime(metadata_Map.get('Categories'));
      }
      if (metadata_Map.containsKey('RushTime')) {
        rushTime = getRushTime(metadata_Map.get('RushTime'));
      }
      if (metadata_Map.containsKey('HasRushService')) {
        rushService = parseBoolean(metadata_Map.get('HasRushService'));
      }
      if (metadata_Map.containsKey('IsAssembled')) {
        isAssembeled = parseBoolean(metadata_Map.get('IsAssembled'));
      }
      if (metadata_Map.containsKey('Shipping')) {
        String shippingObjJson = JSON.serialize(metadata_Map.get('Shipping'));
        Map<String, Object> mapShipping = (Map<String, Object>) JSON.deserializeUntyped(
          shippingObjJson
        );
        Shipping = new Shipping(mapShipping);
      }
      if (metadata_Map.containsKey('ShortDescription')) {
        ShortDescription = parseString(metadata_Map.get('ShortDescription'));
      }
      if (metadata_Map.containsKey('Number')) {
        NumberValue = parseString(metadata_Map.get('Number'));
      }
      if (metadata_Map.containsKey('Supplier')) {
        String supplierJson = JSON.serialize(metadata_Map.get('Supplier'));
        Map<String, Object> mapSupplier = (Map<String, Object>) JSON.deserializeUntyped(
          supplierJson
        );
        SupplierObj = new Supplier(mapSupplier);
      }
      system.debug('Line 180 in ESP Product: ');
      if (metadata_Map.containsKey('Imprinting')) {
        String imprintingJson = JSON.serialize(metadata_Map.get('Imprinting'));
        system.debug('Just before Imprinting Info: ');
        if (imprintingJson != null) {
          ImprintingInfo = imprintingJson;
          system.debug('Imprinting Info in ESP PRODUCT is : ');
          system.debug(ImprintingInfo);
        }
        Map<String, Object> mapImprinting = (Map<String, Object>) JSON.deserializeUntyped(
          imprintingJson
        );
        ImprintingObj = new Imprinting(mapImprinting);
      }
      if (metadata_Map.containsKey('Attributes')) {
        String attributesJson = JSON.serialize(metadata_Map.get('Attributes'));
        Map<String, Object> mapAttributes = (Map<String, Object>) JSON.deserializeUntyped(
          attributesJson
        );
        Attribute = new Attributes(mapAttributes);
      }
      if (metadata_Map.containsKey('Prices')) {
        LstPrices = arrayOfPrices(metadata_Map.get('Prices'));
      }
      if (metadata_Map.containsKey('SKU')) {
        system.debug('for the SKU key');
        SKU = parseSKU(metadata_Map.get('SKU'));
      } else if (metadata_Map.containsKey('Number')) {
        system.debug('for the Number key');
        SKU = parseString(metadata_Map.get('Number'));
        system.debug(SKU);
      }
      Object tmpObject = metadata_Map.get('Variants');
      String result = JSON.serialize(tmpObject);
      List<Object> lst_varients = (List<Object>) JSON.deserializeUntyped(
        result
      );
      List<Object> variantPricesList = new List<Object>();
      System.debug('=============================' + tmpObject);
      if (lst_varients != null) {
        for (Object obj : lst_varients) {
          String variantJson = JSON.serialize(obj);
          Map<String, Object> variant_Map = (Map<String, Object>) JSON.deserializeUntyped(
            variantJson
          );
          Variants variantObj = new Variants(variant_Map);
          lstVariants.add(variantObj);
        }
      }
      for (Variants variantsObj : lstVariants) {
        Integer index = 0;
        Integer numberOfWords = 15;
        List<String> filterNameSplittedbySpace = Name.split(' ');
        List<String> filterDescriptionSplittedbySpace = variantsObj.Description.split(
          ' '
        );
        List<String> dataString = new List<String>();
        dataString.addAll(filterDescriptionSplittedbySpace);
        if (variantsObj.PriceIncludes != null) {
          if (variantsObj.PriceIncludes != null) {
            List<String> filterPriceIncludesSplittedbySpace = (variantsObj.PriceIncludes.split(
              ' '
            ));
            dataString.addAll(filterPriceIncludesSplittedbySpace);
            storeInLine(variantsObj, filterNameSplittedbySpace, dataString);
          }
        }
      }
      return true;
    } catch (Exception ex) {
      System.debug('Exception => ' + ex.getStackTraceString());
      sendEmail(
        'Exception occured while adding product ' + Id,
        ex.getStackTraceString()
      );
      CalloutException e = new CalloutException();
      e.setMessage(ex.getStackTraceString());
      throw e;
    }
    //  return false;
  }

  public string parseSKU(Object sku) {
    List<String> lstSKU = new List<String>();
    String skuValue = '';
    if (sku != null) {
      String lstSkuJson = JSON.serialize(sku);
      try {
        List<Object> lstSkuObject = (List<Object>) JSON.deserializeUntyped(
          lstSkuJson
        );
        for (Object objSku : lstSkuObject) {
          String SkuObjString = JSON.serialize(objSku);
          Map<String, Object> mapSku = (Map<String, Object>) JSON.deserializeUntyped(
            SkuObjString
          );
          if (mapSku.containsKey('SKU')) {
            skuValue = parseString(mapSku.get('SKU'));
          }
        }
      } catch (Exception ex) {
        System.debug('Exception :==> ' + ex.getStackTraceString());
      }
    }
    return skuValue;
  }

  public static void sendEmail(String subject, String body) {
    try {
      System.debug('In Send Email');
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.toAddresses = new List<String>{ 'rttest199gmail.com' };
      message.optOutPolicy = 'FILTER';
      message.subject = subject;
      message.plainTextBody = body;
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    } catch (Exception ex) {
      System.debug('Send Email Exception ' + ex.getStackTraceString());
    }
  }

  public string getCustomDescription(String VariantId) {
    String description = Description;
    if (VariantId != null) {
      for (Variants variantsObj : lstVariants) {
        if (variantsObj.Id == VariantId) {
          description += variantsObj.Description;
          description += variantsObj.PriceIncludes;
        }
      }
    }
    return description;
  }

  public List<Prices> getPricesOfSpecificProduct(String VariantId) {
    if (VariantId != null) {
      for (Variants variantsObj : lstVariants) {
        if (variantsObj.Id == VariantId) {
          return variantsObj.Prices;
        }
      }
    } else {
      return LstPrices;
    }
    return null;
  }

  public Attributes getAttributesOfSpecificProduct(String VariantId) {
    if (VariantId != null) {
      System.debug(VariantId + ' -- ');
      System.debug(' -lstVariants- ' + lstVariants.size());
      for (Variants variantsObj : lstVariants) {
        System.debug(VariantId + ' -- ' + variantsObj.Id);
        if (variantsObj.Id == VariantId) {
          if (variantsObj.Attribute != null) {
            return variantsObj.Attribute;
          } else {
            return Attribute;
          }
        }
      }
    } else {
      return Attribute;
    }
    return null;
  }

  public Attributes getAttributesOfProduct() {
    if (Attribute != null) {
      return Attribute;
    } else {
      return null;
    }
  }

  public Set<String> getImagesOfSpecificProduct(String VariantId) {
    Set<String> setImages = new Set<String>();
    if (VariantId != null) {
      for (Variants variantsObj : lstVariants) {
        if (variantsObj.Id == VariantId) {
          if (variantsObj.ImageUrl != null) {
            //setImages.add(Label.EspMediaLink+variantsObj.ImageUrl);
            setImages.add(variantsObj.ImageUrl);
            //                      setImages.add(Label.EspMediaLink+variantsObj.ImageUrl);
          } else {
            //
            //setImages.add(Label.EspMediaLink+ImageUrl);
            setImages.add(ImageUrl);
          }
        }
      }
    } else {
      //setImages.add(Label.EspMediaLink+ImageUrl);
      setImages.add(ImageUrl);
    }
    for (String key : setImages) {
      System.debug('key:- ' + key);
    }
    return setImages;
  }

  public List<Values> getSpecificProductColorDetails(String variantId) {
    List<Values> colorValues = null;
    Attributes productAttribute = getAttributesOfProduct();
    if (productAttribute != null) {
      if (productAttribute.Colors != null) {
        colorValues = productAttribute.Colors.Values;
      }
    }
    Attributes attribute = getAttributesOfSpecificProduct(variantId);
    if (attribute != null) {
      System.debug('attribute.C ' + attribute.Colors);
      if (attribute.Colors != null) {
        System.debug('attribute.Colors ' + attribute.Colors.Values);
        colorValues = attribute.Colors.Values;
        return attribute.Colors.Values;
      } else {
        return colorValues;
      }
    } else {
      return colorValues;
    }
  }

  public List<Values> getAllColors() {
    List<Values> colorValues = null;
    Attributes productAttribute = getAttributesOfProduct();
    if (productAttribute != null) {
      if (productAttribute.Colors != null) {
        colorValues = productAttribute.Colors.Values;
      }
    }
    return colorValues;
  }
  public List<Values> getAllMaterials() {
    List<Values> MaterialsValues = null;
    Attributes productAttribute = getAttributesOfProduct();
    if (productAttribute != null) {
      if (productAttribute.Materials != null) {
        MaterialsValues = productAttribute.Materials.Values;
      }
    }
    return MaterialsValues;
  }
  public List<Values> getSpecificProductSizeDetails(String variantId) {
    List<Values> sizeValues = null;
    Attributes productAttribute = getAttributesOfProduct();
    if (productAttribute != null) {
      if (productAttribute.Sizes != null) {
        sizeValues = productAttribute.Sizes.Values;
      }
    }
    Attributes attribute = getAttributesOfSpecificProduct(variantId);
    if (attribute != null) {
      if (attribute.Sizes != null) {
        sizeValues = attribute.Sizes.Values;
      }
    }
    return sizeValues;
  }
  public List<Values> getAllSizes() {
    List<Values> sizeValues = null;
    Attributes productAttribute = getAttributesOfProduct();
    if (productAttribute != null) {
      if (productAttribute.Sizes != null) {
        sizeValues = productAttribute.Sizes.Values;
      }
    }
    return sizeValues;
  }

  private List<String> parseImages(Object imagesObject) {
    List<String> lstImages = new List<String>();
    if (imagesObject != null) {
      String lstImagesJson = JSON.serialize(imagesObject);
      List<Object> lstImagesObject = (List<Object>) JSON.deserializeUntyped(
        lstImagesJson
      );
      for (Object objImage : lstImagesObject) {
        lstImages.add(System.Label.ESP_URL + objImage);
      }
    }
    return lstImages;
  }
  private List<String> parseTradeNames(Object imagesObject) {
    List<String> lstTradeNames = new List<String>();
    if (imagesObject != null) {
      String lstImagesJson = JSON.serialize(imagesObject);
      List<Object> lstTradeNameObject = (List<Object>) JSON.deserializeUntyped(
        lstImagesJson
      );
      for (Object objImage : lstTradeNameObject) {
        lstTradeNames.add(objImage + '');
      }
    }
    return lstTradeNames;
  }

  private void storeInLine(
    Variants variantsObj,
    List<String> dataName,
    List<String> dataDescription
  ) {
    Integer difference = 3;
    Integer lastLine = 1;
    for (Integer i = 0; i < dataName.size(); i++) {
      if (i < (difference)) {
        variantsObj.Line1 += dataName[i] + ' ';
        variantsObj.Line1 = variantsObj.Line1.toUpperCase();
        lastLine = 1;
      } else if (i < (difference * 2)) {
        variantsObj.Line2 += dataName[i] + ' ';
        variantsObj.Line2 = variantsObj.Line2.toUpperCase();
        lastLine = 2;
      } else if (i < (difference * 3)) {
        variantsObj.Line3 += dataName[i] + ' ';
        variantsObj.Line3 = variantsObj.Line3.toUpperCase();
        lastLine = 3;
      } else if (i < (difference * 4)) {
        variantsObj.Line4 += dataName[i] + ' ';
        variantsObj.Line4 = variantsObj.Line4.toUpperCase();
        lastLine = 4;
      } else if (i < (difference * 5)) {
        variantsObj.Line5 += dataName[i] + ' ';
        variantsObj.Line5 = variantsObj.Line5.toUpperCase();
        lastLine = 5;
      } else if (i < (difference * 6)) {
        variantsObj.Line6 += dataName[i] + ' ';
        variantsObj.Line6 = variantsObj.Line6.toUpperCase();
        lastLine = 6;
      }
    }

    Integer count = lastLine * difference;
    for (Integer i = 0; i < dataDescription.size(); i++) {
      if (count < (difference)) {
        LineData(variantsObj, dataDescription[i], 1);
      } else if (count < (difference * 2)) {
        LineData(variantsObj, dataDescription[i], 2);
      } else if (count < (difference * 3)) {
        LineData(variantsObj, dataDescription[i], 3);
      } else if (count < (difference * 4)) {
        LineData(variantsObj, dataDescription[i], 4);
      } else if (count < (difference * 5)) {
        LineData(variantsObj, dataDescription[i], 5);
      } else if (count < (difference * 6)) {
        LineData(variantsObj, dataDescription[i], 6);
      }
      count++;
    }
  }

  public void LineData(Variants variantsObj, String data, Integer lineNumber) {
    if (lineNumber == 1) {
      variantsObj.Line1 += data + ' ';
      variantsObj.Line1 = variantsObj.Line1.toUpperCase();
    } else if (lineNumber == 2) {
      variantsObj.Line2 += data + ' ';
      variantsObj.Line2 = variantsObj.Line2.toUpperCase();
    } else if (lineNumber == 3) {
      variantsObj.Line3 += data + ' ';
      variantsObj.Line3 = variantsObj.Line3.toUpperCase();
    } else if (lineNumber == 4) {
      variantsObj.Line4 += data + ' ';
      variantsObj.Line4 = variantsObj.Line4.toUpperCase();
    } else if (lineNumber == 5) {
      variantsObj.Line5 += data + ' ';
      variantsObj.Line5 = variantsObj.Line5.toUpperCase();
    } else if (lineNumber == 6) {
      variantsObj.Line6 += data + ' ';
      variantsObj.Line6 = variantsObj.Line6.toUpperCase();
    }
  }
  private static List<Values> getRushTime(Object productionTime) {
    List<Values> lstValues = new List<Values>();
    if (productionTime != null) {
      String prices_list_string = JSON.serialize(productionTime);
      List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (Object objprice : variantPricesList) {
        String PricesObjString = JSON.serialize(objprice);
        Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
          PricesObjString
        );
        Values priceObj = new Values(mapPrice);
        lstValues.add(priceObj);
      }
    }
    return lstValues;
  }
  private static List<String> getWarnings(Object productionTime) {
    List<String> lstValues = new List<String>();
    if (productionTime != null) {
      String prices_list_string = JSON.serialize(productionTime);
      List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (Object objprice : variantPricesList) {
        String PricesObjString = JSON.serialize(objprice);
        Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
          PricesObjString
        );
        for (String key : mapPrice.keySet()) {
          if (key == 'Description') {
            lstValues.add(parseString(mapPrice.get(key)));
          }
        }
      }
    }
    return lstValues;
  }
  private static List<String> getCertifications(Object productionTime) {
    List<String> lstValues = new List<String>();
    if (productionTime != null) {
      String prices_list_string = JSON.serialize(productionTime);
      List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (Object objprice : variantPricesList) {
        String PricesObjString = JSON.serialize(objprice);
        Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
          PricesObjString
        );
        for (String key : mapPrice.keySet()) {
          if (key == 'Name') {
            lstValues.add(parseString(mapPrice.get(key)));
          }
        }
      }
    }
    return lstValues;
  }
  private static Integer getRating(Object rating) {
    List<Integer> lstValues = new List<Integer>();
    if (rating != null) {
      String prices_list_string = JSON.serialize(rating);
      Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (String key : mapPrice.keySet()) {
        if (key == 'Rating') {
          return parseInteger(mapPrice.get(key));
        }
      }
    }
    return null;
  }
  private static Integer getRatingCount(Object rating) {
    List<Integer> lstValues = new List<Integer>();
    if (rating != null) {
      String prices_list_string = JSON.serialize(rating);
      Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (String key : mapPrice.keySet()) {
        if (key == 'Companies') {
          return parseInteger(mapPrice.get(key));
        }
      }
    }
    return null;
  }
  private static String getFaxNumber(Object productionTime) {
    List<String> lstValues = new List<String>();
    if (productionTime != null) {
      String prices_list_string = JSON.serialize(productionTime);
      Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (String key : mapPrice.keySet()) {
        if (key == 'Work') {
          lstValues.add(parseString(mapPrice.get(key)));
        } else if (key == 'TollFree') {
          lstValues.add(parseString(mapPrice.get(key)));
        } else if (key == 'Primary') {
          lstValues.add(parseString(mapPrice.get(key)));
        }
      }
      if (lstValues.size() > 0)
        return lstValues.get(0);
    }
    return '';
  }
  private static String getProductionTime(Object productionTime) {
    List<String> lstValues = new List<String>();
    if (productionTime != null) {
      String prices_list_string = JSON.serialize(productionTime);
      List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (Object objprice : variantPricesList) {
        String PricesObjString = JSON.serialize(objprice);
        Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
          PricesObjString
        );
        for (String key : mapPrice.keySet()) {
          if (key == 'Name') {
            lstValues.add(parseString(mapPrice.get(key)));
          }
        }
      }
      if (lstValues.size() > 0)
        return lstValues.get(0);
    }
    return '';
  }
  private static List<Prices> arrayOfPrices(Object prices) {
    List<Prices> lstPrices = new List<Prices>();
    if (prices != null) {
      String prices_list_string = JSON.serialize(prices);
      List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
        prices_list_string
      );
      for (Object objprice : variantPricesList) {
        String PricesObjString = JSON.serialize(objprice);
        Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
          PricesObjString
        );
        Prices priceObj = new Prices(mapPrice);
        lstPrices.add(priceObj);
      }
    }
    return lstPrices;
  }

  public static Integer parseInteger(Object objectValue) {
    Integer value = 0;
    try {
      value = Integer.valueOf(objectValue);
      return value;
    } catch (Exception ex) {
      return 0;
    }
  }

  public static ID parseId(Object objectValue) {
    ID value = null;
    try {
      String str = String.valueOf(objectValue);
      value = ID.valueOf(str);
      return value;
    } catch (Exception ex) {
      return value;
    }
  }

  public static Boolean parseBoolean(Object objectValue) {
    Boolean value = false;
    try {
      value = Boolean.valueOf(objectValue);
      return value;
    } catch (Exception ex) {
      return null;
    }
  }

  public static Decimal parseDecimal(Object objectValue) {
    Decimal value = 0;
    try {
      String str = String.valueOf(objectValue);
      value = Decimal.valueOf(str);
      return value;
    } catch (Exception ex) {
      return 0;
    }
  }

  public static String parseString(Object objectValue) {
    try {
      String str = String.valueOf(objectValue);
      return str;
    } catch (Exception ex) {
      return '';
    }
  }
  public static String parseVariantImageString(Object objectValue) {
    try {
      String str = String.valueOf(objectValue);
      return str;
    } catch (Exception ex) {
      return '';
    }
  }
  private static List<String> arrayOfWebsites(Object values) {
    List<String> lstValues = new List<String>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        lstValues.add(objValues.toString());
      }
      if (lstValues.size() > 0)
        return lstValues;
    }
    return null;
  }
  private static String arrayOfString(Object values) {
    List<String> lstValues = new List<String>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        lstValues.add(objValues.toString());
      }
      if (lstValues.size() > 0)
        return lstValues.get(0);
      else
        return '';
    }
    return '';
  }
  private static List<String> arrayOfOptionValues(Object values) {
    List<String> lstValues = new List<String>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        lstValues.add(objValues.toString());
      }
      if (lstValues.size() > 0)
        return lstValues;
      else
        return null;
    }
    return null;
  }
  private static List<String> arrayOfOrigins(Object values) {
    List<String> lstValues = new List<String>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        lstValues.add(objValues.toString());
      }
    }
    return lstValues;
  }
  private static List<String> arrayOfLocations(Object values) {
    List<String> lstValues = new List<String>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        String valuesObjString = JSON.serialize(objValues);

        try {
          Map<String, Object> mapValues = (Map<String, Object>) JSON.deserializeUntyped(
            valuesObjString
          );
          for (String key1 : mapValues.keySet()) {
            if (key1 == 'Name') {
              lstValues.add(parseString(mapValues.get(key1)));
            }
          }
        } catch (Exception ex) {
          lstValues.add(objValues.toString());
        }
      }
    }
    return lstValues;
  }
  private static List<Values> arrayOfValues(Object values) {
    List<Values> lstValues = new List<Values>();
    if (values != null) {
      String valuesListJson = JSON.serialize(values);
      List<Object> variantValuesList = (List<Object>) JSON.deserializeUntyped(
        valuesListJson
      );
      for (Object objValues : variantValuesList) {
        String valuesObjString = JSON.serialize(objValues);
        try {
          Map<String, Object> mapValues = (Map<String, Object>) JSON.deserializeUntyped(
            valuesObjString
          );
          Values valuesObj = new Values(mapValues);
          lstValues.add(valuesObj);
        } catch (Exception ex) {
          Values valuesObj = new Values(objValues);
        }
      }
    }
    return lstValues;
  }

  private static List<Groups> arrayOfGroups(Object groups) {
    List<Groups> lstGroups = new List<Groups>();
    if (groups != null) {
      String groupsListJson = JSON.serialize(groups);
      List<Object> groupsValuesList = (List<Object>) JSON.deserializeUntyped(
        groupsListJson
      );
      for (Object objGroups : groupsValuesList) {
        String groupsObjString = JSON.serialize(objGroups);
        Map<String, Object> mapGroups = (Map<String, Object>) JSON.deserializeUntyped(
          groupsObjString
        );
        Groups groupsObj = new Groups(mapGroups);
        lstGroups.add(groupsObj);
      }
    }
    return lstGroups;
  }

  private static List<Charges> arrayOfCharges(Object charges) {
    List<Charges> lstCharges = new List<Charges>();
    if (charges != null) {
      String chargesListJson = JSON.serialize(charges);
      List<Object> chargesValuesList = (List<Object>) JSON.deserializeUntyped(
        chargesListJson
      );
      for (Object objValues : chargesValuesList) {
        String chargesObjString = JSON.serialize(objValues);
        Map<String, Object> mapCharges = (Map<String, Object>) JSON.deserializeUntyped(
          chargesObjString
        );
        Charges chargesObj = new Charges(mapCharges);
        lstCharges.add(chargesObj);
      }
    }
    return lstCharges;
  }

  private static List<Options> arrayOfOptions(Object options) {
    List<Options> lstoptions = new List<Options>();
    if (options != null) {
      String optionsListJson = JSON.serialize(options);
      List<Object> optionsValuesList = (List<Object>) JSON.deserializeUntyped(
        optionsListJson
      );
      for (Object objOptions : optionsValuesList) {
        String optionsJson = JSON.serialize(objOptions);
        Map<String, Object> mapOptions = (Map<String, Object>) JSON.deserializeUntyped(
          optionsJson
        );
        Options optionsObj = new Options(mapOptions);
        lstoptions.add(optionsObj);
      }
    }
    return lstoptions;
  }
  private static List<Options> arrayOfOptionsForImprinting(Object options) {
    List<Options> lstoptions = new List<Options>();
    if (options != null) {
      String optionsListJson = JSON.serialize(options);
      List<Object> optionsValuesList = (List<Object>) JSON.deserializeUntyped(
        optionsListJson
      );
      for (Object objOptions : optionsValuesList) {
        String optionsJson = JSON.serialize(objOptions);
        Map<String, Object> mapOptions = (Map<String, Object>) JSON.deserializeUntyped(
          optionsJson
        );
        Options optionsObj = new Options(mapOptions);
        lstoptions.add(optionsObj);
      }
    }
    return lstoptions;
  }

  public class Variants {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String NumberVariant { get; set; }
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public String ImageUrl { get; set; }
    @AuraEnabled
    public Shipping Shipping { get; set; }
    @AuraEnabled
    public List<Prices> Prices { get; set; }
    @AuraEnabled
    public String PriceIncludes { get; set; }
    @AuraEnabled
    public String PriceDiscounts { get; set; }
    @AuraEnabled
    public Attributes Attribute { get; set; }
    @AuraEnabled
    public String DisplayName { get; set; }
    @AuraEnabled
    public String Line1 { get; set; }
    @AuraEnabled
    public String Line2 { get; set; }
    @AuraEnabled
    public String Line3 { get; set; }
    @AuraEnabled
    public String Line4 { get; set; }
    @AuraEnabled
    public String Line5 { get; set; }
    @AuraEnabled
    public String Line6 { get; set; }
    public Variants(Map<String, Object> variantMap) {
      Line1 = '';
      Line2 = '';
      Line3 = '';
      Line4 = '';
      Line5 = '';
      Line6 = '';
      for (String key : variantMap.keySet()) {
        if (key == 'Id') {
          Id = parseString(variantMap.get(key));
        } else if (key == 'Name') {
          Name = parseString(variantMap.get(key));
        } else if (key == 'Description') {
          Description = parseString(variantMap.get(key));
        } else if (key == 'Number') {
          NumberVariant = parseString(variantMap.get(key));
        } else if (key == 'ImageUrl') {
          ImageUrl = parseVariantImageString(variantMap.get(key));
        } else if (key == 'Shipping') {
          String shippingObjJson = JSON.serialize(variantMap.get(key));
          Map<String, Object> mapShipping = (Map<String, Object>) JSON.deserializeUntyped(
            shippingObjJson
          );
          Shipping = new Shipping(mapShipping);
        } else if (key == 'Prices') {
          Prices = arrayOfPrices(variantMap.get(key));
        } else if (key == 'PriceIncludes') {
          PriceIncludes = parseString(variantMap.get(key));
        } else if (key == 'Attributes') {
          String attributesJson = JSON.serialize(variantMap.get(key));
          Map<String, Object> mapAttributes = (Map<String, Object>) JSON.deserializeUntyped(
            attributesJson
          );
          Attribute = new Attributes(mapAttributes);
        } else if (key == 'Number') {
          //   Number_Z = parser.getText();
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Variants consuming unrecognized property: ' + key
          );
          //     System.debug(LoggingLevel.WARN, 'ParserTest: '+parser.getText());
          //   consumeObject(parser);
        }
      }
    }
  }

  public class Prices {
    @AuraEnabled
    public Quantity Quantity { get; set; }
    @AuraEnabled
    public Decimal Price { get; set; }
    @AuraEnabled
    public Decimal Cost { get; set; }
    @AuraEnabled
    public Decimal Profit { get; set; }
    @AuraEnabled
    public String DiscountCode { get; set; }
    @AuraEnabled
    public String CurrencyCode { get; set; }
    @AuraEnabled
    public Boolean IsQUR { get; set; }
    public Prices(Map<String, Object> Prices_Map_Obj) {
      for (String key : Prices_Map_Obj.keySet()) {
        if (key == 'Quantity') {
          String quantityObjString = JSON.serialize(Prices_Map_Obj.get(key));
          Map<String, Object> mapQuantity = (Map<String, Object>) JSON.deserializeUntyped(
            quantityObjString
          );
          Quantity = new Quantity(mapQuantity);
        } else if (key == 'Price') {
          Price = parseDecimal(Prices_Map_Obj.get(key));
        } else if (key == 'Cost') {
          Cost = parseDecimal(Prices_Map_Obj.get(key));
        } else if (key == 'DiscountCode') {
          DiscountCode = parseString(Prices_Map_Obj.get(key));
        } else if (key == 'CurrencyCode') {
          CurrencyCode = parseString(Prices_Map_Obj.get(key));
        } else if (key == 'IsQUR') {
          IsQUR = parseBoolean(Prices_Map_Obj.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Prices consuming unrecognized property: ' + key
          );
        }
        if (Price != null && Cost != null) {
          Profit = Price - Cost;
        }
      }
    }
  }

  public class Quantity {
    @AuraEnabled
    public Integer From_Z { get; set; } // in json: From
    @AuraEnabled
    public Integer To { get; set; }
    @AuraEnabled
    public Integer index { get; set; }
    public Quantity(Map<String, Object> quantityMapObject) {
      for (String key : quantityMapObject.keySet()) {
        if (key == 'From') {
          From_Z = parseInteger(quantityMapObject.get(key));
        } else if (key == 'To') {
          To = parseInteger(quantityMapObject.get(key));
        } else if (key == '$index') {
          index = parseInteger(quantityMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Quantity consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Methods {
    @AuraEnabled
    public List<Values> Values { get; set; }
    public Methods(Map<String, Object> methodsMapObject) {
      for (String key : methodsMapObject.keySet()) {
        if (key == 'Values') {
          Values = arrayOfValues(methodsMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Colors consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Services {
    @AuraEnabled
    public List<Values> Values { get; set; }
    public Services(Map<String, Object> servicesMapObject) {
      for (String key : servicesMapObject.keySet()) {
        if (key == 'Values') {
          Values = arrayOfValues(servicesMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Colors consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Locations {
    @AuraEnabled
    public List<String> Values { get; set; }
    public Locations(Map<String, Object> locationsMapObject) {
      for (String key : locationsMapObject.keySet()) {
        if (key == 'Values') {
          Values = arrayOfLocations(locationsMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Colors consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Imprinting {
    @AuraEnabled
    public Methods Methods { get; set; }
    @AuraEnabled
    public Services Services { get; set; }
    @AuraEnabled
    public Sizes Sizes { get; set; }
    @AuraEnabled
    public Colors Colors { get; set; }
    @AuraEnabled
    public Locations Locations { get; set; }
    @AuraEnabled
    public List<Options> Options { get; set; }
    @AuraEnabled
    public List<OptionsForImprinting> imprintOptions { get; set; }
    @AuraEnabled
    public Boolean FullColorProcess { get; set; }
    @AuraEnabled
    public Boolean Personalization { get; set; }
    @AuraEnabled
    public Boolean SoldUnimprinted { get; set; }
    @AuraEnabled
    public String additionalInformation { get; set; }
    public Imprinting(Map<String, Object> imprintingMapObject) {
      for (String key : imprintingMapObject.keySet()) {
        if (key == 'Methods') {
          String methodsJson = JSON.serialize(imprintingMapObject.get(key));
          Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
            methodsJson
          );
          Methods = new Methods(mapMethods);
        } else if (key == 'Services') {
          String servicesJson = JSON.serialize(imprintingMapObject.get(key));
          Map<String, Object> mapServices = (Map<String, Object>) JSON.deserializeUntyped(
            servicesJson
          );
          Services = new Services(mapServices);
        } else if (key == 'Sizes') {
          String sizesJson = JSON.serialize(imprintingMapObject.get(key));
          Map<String, Object> mapSizes = (Map<String, Object>) JSON.deserializeUntyped(
            sizesJson
          );
          Sizes = new Sizes(mapSizes);
        } else if (key == 'Colors') {
          String colorsJson = JSON.serialize(imprintingMapObject.get(key));
          Map<String, Object> mapColors = (Map<String, Object>) JSON.deserializeUntyped(
            colorsJson
          );
          Colors = new Colors(mapColors);
        } else if (key == 'Locations') {
          String locationsJson = JSON.serialize(imprintingMapObject.get(key));
          Map<String, Object> mapLocation = (Map<String, Object>) JSON.deserializeUntyped(
            locationsJson
          );
          Locations = new Locations(mapLocation);
        } else if (key == 'Options') {
          String methodsJson = JSON.serialize(imprintingMapObject.get(key));
          List<Object> variantPricesList = (List<Object>) JSON.deserializeUntyped(
            methodsJson
          );
          imprintOptions = new List<OptionsForImprinting>();
          for (Object objprice : variantPricesList) {
            OptionsForImprinting temp = new OptionsForImprinting();
            String PricesObjString = JSON.serialize(objprice);
            Map<String, Object> mapPrice = (Map<String, Object>) JSON.deserializeUntyped(
              PricesObjString
            );
            for (String key1 : mapPrice.keySet()) {
              if (key1 == 'Type') {
                temp.Name = parseString(mapPrice.get(key1));
              } else if (key1 == 'Values') {
                temp.Values = arrayOfOptionValues(mapPrice.get(key1));
              } else {
                System.debug(
                  LoggingLevel.WARN,
                  'packaging consuming unrecognized property: ' + key1
                );
              }
            }
            imprintOptions.add(temp);
          }
          Options = arrayOfOptions(imprintingMapObject.get(key));
          // System.debug('OPTIONSSSS: '+Options);
        } else if (key == 'FullColorProcess') {
          FullColorProcess = parseBoolean(imprintingMapObject.get(key));
        } else if (key == 'Personalization') {
          Personalization = parseBoolean(imprintingMapObject.get(key));
        } else if (key == 'SoldUnimprinted') {
          SoldUnimprinted = parseBoolean(imprintingMapObject.get(key));
        } else if (key == 'AdditionalInfo') {
          additionalInformation = parseString(imprintingMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Quantity consuming unrecognized property: ' + key
          );
        }
      }
    }
  }
  public class Phone {
    @AuraEnabled
    public String Work { get; set; }
    @AuraEnabled
    public String Primary { get; set; }

    public Phone(Map<String, Object> attributesMapObject) {
      for (String key : attributesMapObject.keySet()) {
        if (key == 'Work') {
          Work = parseString(attributesMapObject.get(key));
        } else if (key == 'Primary') {
          Primary = parseString(attributesMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Quantity consuming unrecognized property: ' + key
          );
        }
      }
    }
  }
  public class Attributes {
    @AuraEnabled
    public Colors Colors { get; set; }
    @AuraEnabled
    public Sizes Sizes { get; set; }
    @AuraEnabled
    public Colors Materials { get; set; }
    public Attributes(Map<String, Object> attributesMapObject) {
      for (String key : attributesMapObject.keySet()) {
        if (key == 'Colors') {
          String colorsJson = JSON.serialize(attributesMapObject.get(key));
          Map<String, Object> mapColors = (Map<String, Object>) JSON.deserializeUntyped(
            colorsJson
          );
          Colors = new Colors(mapColors);
        } else if (key == 'Sizes') {
          String sizesJson = JSON.serialize(attributesMapObject.get(key));
          Map<String, Object> mapSizes = (Map<String, Object>) JSON.deserializeUntyped(
            sizesJson
          );
          Sizes = new Sizes(mapSizes);
        } else if (key == 'Materials') {
          String colorsJson = JSON.serialize(attributesMapObject.get(key));
          Map<String, Object> mapColors = (Map<String, Object>) JSON.deserializeUntyped(
            colorsJson
          );
          Materials = new Colors(mapColors);
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Quantity consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Sizes {
    @AuraEnabled
    public List<Values> Values { get; set; }
    public Sizes(Map<String, Object> sizesMapObject) {
      for (String key : sizesMapObject.keySet()) {
        if (key == 'Values') {
          Values = arrayOfValues(sizesMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Sizes consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Colors {
    @AuraEnabled
    public List<Values> Values { get; set; }
    public Colors(Map<String, Object> colorsMapObject) {
      for (String key : colorsMapObject.keySet()) {
        if (key == 'Values') {
          Values = arrayOfValues(colorsMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Colors consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Values {
    @AuraEnabled
    public String Code { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String ImageUrl { get; set; }
    @AuraEnabled
    public String VendorCode { get; set; }
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public String SKU { get; set; }
    @AuraEnabled
    public Integer index { get; set; }
    @AuraEnabled
    public List<Options> LstOptions { get; set; }
    @AuraEnabled
    public List<Charges> Charges { get; set; }
    public Values(Map<String, Object> valuesMapObject) {
      for (String key : valuesMapObject.keySet()) {
        if (key == 'Code') {
          Code = parseString(valuesMapObject.get(key));
        } else if (key == 'Charges') {
          //Charges = arrayOfCharges(valuesMapObject.get(key));
        } else if (key == 'Name') {
          Name = parseString(valuesMapObject.get(key));
        } else if (key == 'ImageUrl') {
          ImageUrl = parseString(valuesMapObject.get(key));
        } else if (key == 'VendorCode') {
          VendorCode = parseString(valuesMapObject.get(key));
        } else if (key == 'SKU') {
          SKU = parseString(valuesMapObject.get(key));
        } else if (key == 'Options') {
          LstOptions = arrayOfOptions(valuesMapObject.get(key));
        } else if (key == 'Description') {
          Description = parseString(valuesMapObject.get(key));
        } else if (key == '$index') {
          index = parseInteger(valuesMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Values consuming unrecognized property: ' + key
          );
        }
      }
    }
    public Values(Object value) {
      Name = parseString(value);
    }
  }

  public class Options {
    @AuraEnabled
    public String Type { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public List<Values> Values { get; set; }
    @AuraEnabled
    public List<String> StringValues { get; set; }
    @AuraEnabled
    public List<Groups> Groups { get; set; }

    public Options(Map<String, Object> optionsMapObject) {
      for (String key : optionsMapObject.keySet()) {
        if (key == 'Type') {
          Type = parseString(optionsMapObject.get(key));
        } else if (key == 'Name') {
          Name = parseString(optionsMapObject.get(key));
        } else if (key == 'Values') {
          /*if(Type == 'Additional Colors' || Type == 'Additional Location' )
                    {
                        StringValues = arrayOfLocations(optionsMapObject.get(key));
                    }
                    else
                    {*/
          Values = arrayOfValues(optionsMapObject.get(key));
          //}
        } else if (key == 'Groups') {
          Groups = arrayOfGroups(optionsMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Options consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Groups {
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public List<Charges> Charges { get; set; }
    public Groups(Map<String, Object> optionsMapObject) {
      for (String key : optionsMapObject.keySet()) {
        if (key == 'Name') {
          Name = parseString(optionsMapObject.get(key));
        } else if (key == 'Charges') {
          Charges = arrayOfCharges(optionsMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Options consuming unrecognized property: ' + key
          );
        }
      }
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

  public class Charges {
    @AuraEnabled
    public String TypeCode { get; set; }
    @AuraEnabled
    public String Type_Z { get; set; } // in json: Type
    @AuraEnabled
    public String Description { get; set; }
    @AuraEnabled
    public List<Prices> Prices { get; set; }
    @AuraEnabled
    public String UsageLevelCode { get; set; }
    @AuraEnabled
    public String UsageLevel { get; set; }
    @AuraEnabled
    public Boolean IsRequired { get; set; }

    public Charges(Map<String, Object> chargesMapObject) {
      for (String key : chargesMapObject.keySet()) {
        if (key == 'TypeCode') {
          TypeCode = parseString(chargesMapObject.get(key));
        } else if (key == 'Type') {
          Type_Z = parseString(chargesMapObject.get(key));
        } else if (key == 'Description') {
          Description = parseString(chargesMapObject.get(key));
        } else if (key == 'Prices') {
          Prices = arrayOfPrices(chargesMapObject.get(key));
        } else if (key == 'UsageLevelCode') {
          UsageLevelCode = parseString(chargesMapObject.get(key));
        } else if (key == 'UsageLevel') {
          UsageLevel = parseString(chargesMapObject.get(key));
        } else if (key == 'IsRequired') {
          IsRequired = parseBoolean(chargesMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Charges consuming unrecognized property: ' + key
          );
        }
      }
    }
  }

  public class Supplier {
    @AuraEnabled
    public String Id { get; set; }
    @AuraEnabled
    public String Name { get; set; }
    @AuraEnabled
    public String AsiNumber { get; set; }
    //@AuraEnabled   public Phone Fax {get;set;}
    @AuraEnabled
    public String FaxNumber { get; set; }
    @AuraEnabled
    public String Phone { get; set; }
    @AuraEnabled
    public String Email { get; set; }
    @AuraEnabled
    public String Websites { get; set; }
    @AuraEnabled
    public String MarketingPolicy { get; set; }
    @AuraEnabled
    public Boolean IsMinorityOwned { get; set; }
    @AuraEnabled
    public Boolean HasNotes { get; set; }
    @AuraEnabled
    public Boolean IsQcaCertified { get; set; }
    @AuraEnabled
    public Boolean IsUnionAvailable { get; set; }
    @AuraEnabled
    public List<String> WebsitesList { get; set; }
    @AuraEnabled
    public Integer Rating { get; set; }
    @AuraEnabled
    public Integer RatingCount { get; set; }

    public Supplier(Map<String, Object> supplierMapObject) {
      for (String key : supplierMapObject.keySet()) {
        if (key == 'Id') {
          Id = parseString(supplierMapObject.get(key));
        } else if (key == 'Name') {
          Name = parseString(supplierMapObject.get(key));
        } else if (key == 'AsiNumber') {
          AsiNumber = parseString(supplierMapObject.get(key));
        } else if (key == 'Phone') {
          Phone = getFaxNumber(supplierMapObject.get(key));
        } else if (key == 'Fax') {
          //Fax = new Phone(supplierMapObject.get(key));
          FaxNumber = getFaxNumber(supplierMapObject.get(key));
        } else if (key == 'Rating') {
          Rating = getRating(supplierMapObject.get(key));
          RatingCount = getRatingCount(supplierMapObject.get(key));
        } else if (key == 'Email') {
          Email = parseString(supplierMapObject.get(key));
        } else if (key == 'Websites') {
          Websites = arrayOfString(supplierMapObject.get(key));
          WebsitesList = arrayOfWebsites(supplierMapObject.get(key));
        } else if (key == 'MarketingPolicy') {
          MarketingPolicy = parseString(supplierMapObject.get(key));
        } else if (key == 'IsMinorityOwned') {
          IsMinorityOwned = parseBoolean(supplierMapObject.get(key));
        } else if (key == 'HasNotes') {
          HasNotes = parseBoolean(supplierMapObject.get(key));
        } else if (key == 'IsQcaCertified') {
          IsQcaCertified = parseBoolean(supplierMapObject.get(key));
        } else if (key == 'IsUnionAvailable') {
          IsUnionAvailable = parseBoolean(supplierMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Supplier consuming unrecognized property: ' + key
          );
        }
      }
    }
  }
  public class Shipping {
    @AuraEnabled
    public List<Values> Options { get; set; }
    @AuraEnabled
    public String WeightUnit { get; set; }
    @AuraEnabled
    public String PackageUnit { get; set; }
    @AuraEnabled
    public Integer ItemsPerPackage { get; set; }
    @AuraEnabled
    public Boolean BillsByWeight { get; set; }
    @AuraEnabled
    public Boolean BillsBySize { get; set; }
    @AuraEnabled
    public String Dimensions { get; set; }
    @AuraEnabled
    public Boolean PackageInPlainBox { get; set; }
    @AuraEnabled
    public List<Values> FOBPoints { get; set; }
    @AuraEnabled
    public List<Values> weights { get; set; }
    //parseBoolean(supplierMapObject.get(key));
    public Shipping(Map<String, Object> shippingMapObject) {
      for (String key : shippingMapObject.keySet()) {
        if (key == 'Options') {
          String methodsJson = JSON.serialize(shippingMapObject.get(key));
          Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
            methodsJson
          );
          for (String key1 : mapMethods.keySet()) {
            if (key1 == 'Values') {
              Options = arrayOfValues(mapMethods.get(key1));
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Options consuming unrecognized property: ' + key1
              );
            }
          }
        } else if (key == 'FOBPoints') {
          String methodsJson = JSON.serialize(shippingMapObject.get(key));

          Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
            methodsJson
          );
          for (String key1 : mapMethods.keySet()) {
            if (key1 == 'Values') {
              FOBPoints = arrayOfValues(mapMethods.get(key1));
            } else {
              System.debug(
                LoggingLevel.WARN,
                'FOBPoints consuming unrecognized property: ' + key1
              );
            }
          }
        } else if (key == 'Weight') {
          String methodsJson = JSON.serialize(shippingMapObject.get(key));

          Map<String, Object> mapMethods = (Map<String, Object>) JSON.deserializeUntyped(
            methodsJson
          );
          for (String key1 : mapMethods.keySet()) {
            if (key1 == 'Values') {
              weights = arrayOfValues(mapMethods.get(key1));
            } else {
              System.debug(
                LoggingLevel.WARN,
                'Weight consuming unrecognized property: ' + key1
              );
            }
          }
        } else if (key == 'PackageUnit') {
          PackageUnit = parseString(shippingMapObject.get(key));
        } else if (key == 'WeightUnit') {
          WeightUnit = parseString(shippingMapObject.get(key));
        } else if (key == 'ItemsPerPackage') {
          ItemsPerPackage = parseInteger(shippingMapObject.get(key));
        } else if (key == 'Dimensions') {
          String attributesJson = JSON.serialize(
            shippingMapObject.get('Dimensions')
          );
          System.debug(shippingMapObject.get('Dimensions'));

          Map<String, Object> mapAttributes = (Map<String, Object>) JSON.deserializeUntyped(
            attributesJson
          );

          Dimensions = parseString(mapAttributes.get('Description'));
        } else if (key == 'BillsByWeight') {
          BillsByWeight = parseBoolean(shippingMapObject.get(key));
        } else if (key == 'BillsBySize') {
          BillsBySize = parseBoolean(shippingMapObject.get(key));
        } else if (key == 'PackageInPlainBox') {
          PackageInPlainBox = parseBoolean(shippingMapObject.get(key));
        } else {
          System.debug(
            LoggingLevel.WARN,
            'Options consuming unrecognized property: ' + key
          );
        }
      }
    }
  }
}
