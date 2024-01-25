public class EditOpportunityLineItemController {
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
  public static Integer getcountOfPricingRecords(String recId) {
    return [
        SELECT
          Id,
          OpportunityLineItem__c,
          Color__c,
          Size__c,
          Quantity__c,
          Net_Cost__c,
          Price_Per_Unit__c,
          Retail_Price__c,
          Margin__c,
          Show_To_Client__c,
          Total__c,
          CreatedDate
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ]
      .size();
  }

  @AuraEnabled
  public static OpportunityLineItemDetails getOpportunityLineItemDetails(
    String recId
  ) {
    OpportunityLineItemDetails details = new OpportunityLineItemDetails();
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
          Product__r.CommonSku_Id__c,
          Imprint_Information__c,
          Description__c,
          SystemModstamp,
          Name,
          Id,
          Additional_Colors__c,
          Additional_Locations__c
        FROM OpportunityLineItem__c
        WHERE Id = :recId
      ];
      details.supplier = opportunitLineItemData.Supplier__c;
      if (opportunitLineItemData.Product__r.CommonSku_Id__c != null) {
        details.ESPProductId = opportunitLineItemData.Product__r.CommonSku_Id__c;
      }
      details.description = opportunitLineItemData.Description__c;
      details.imprintMethods = opportunitLineItemData.Imprint_Methods__c;
      details.imprintingInfo = opportunitLineItemData.Imprint_Information__c;
      details.priceLabel = opportunitLineItemData.Price_Label__c;
      details.privateNotes = opportunitLineItemData.Private_Notes__c;
      details.name = opportunitLineItemData.Name;
      details.ProductID = opportunitLineItemData.Product__c;
      details.sku = opportunitLineItemData.SKU__c;
      details.additionalColors = opportunitLineItemData.Additional_Colors__c;
      details.additionalLocations = opportunitLineItemData.Additional_Locations__c;
      details.comments = [
        SELECT
          Date__c,
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
          OpportunityLineItem__c,
          Color__c,
          Size__c,
          Quantity__c,
          Net_Cost__c,
          Price_Per_Unit__c,
          Retail_Price__c,
          Margin__c,
          Show_To_Client__c,
          Total__c,
          CreatedDate
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      for (PricingLineItem__c price : details.pricingDetails) {
        if (price.Net_Cost__c != null) {
          price.Net_Cost__c = price.Net_Cost__c.setScale(3);
        }
        if (price.Total__c != null) {
          price.Total__c = price.Total__c.setScale(3);
        }
      }
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

      Decimal runChargeTotal1 = 0;
      Decimal runChargeTotal2 = 0;
      Decimal runChargeTotal3 = 0;
      Decimal runChargeTotal4 = 0;
      Decimal runChargeTotal5 = 0;
      for (Line_Item_Pricing_RunCharge__c runCharge : details.runCharges) {
        if (runCharge.Value1__c != null) {
          runChargeTotal1 += runCharge.Value1__c;
        }
        if (runCharge.Value2__c != null) {
          runChargeTotal2 += runCharge.Value2__c;
        }
        if (runCharge.Value3__c != null) {
          runChargeTotal3 += runCharge.Value3__c;
        }
        if (runCharge.Value4__c != null) {
          runChargeTotal4 += runCharge.Value4__c;
        }
        if (runCharge.Value5__c != null) {
          runChargeTotal5 += runCharge.Value5__c;
        }
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
      details.extraChargesExists = details.fixedCharges.size() > 0;
      List<Decimal> pricePerUnit = new List<Decimal>();
      Integer count = 1;
      List<PricingLineItem__c> pricingListToUpdate = new List<PricingLineItem__c>();
      for (PricingLineItem__c pricing : details.pricingDetails) {
        if (pricing.Total__c == null) {
          pricing.Total__c = 0;
        }
        if (pricing.Margin__c == null) {
          pricing.Margin__c = 0;
        }
        if (pricing.Price_Per_Unit__c == null) {
          pricing.Price_Per_Unit__c = 0;
        }
        if (count == 1) {
          Decimal cost = (pricing.Net_Cost__c + runChargeTotal1);
          decimal marginCalculation = 1 - (pricing.Margin__c / 100);
          pricing.Price_Per_Unit__c = cost / marginCalculation;
          pricing.Price_Per_Unit__c = pricing.Price_Per_Unit__c.setScale(3);
        } else if (count == 2) {
          Decimal cost = (pricing.Net_Cost__c + runChargeTotal2);
          decimal marginCalculation = 1 - (pricing.Margin__c / 100);
          pricing.Price_Per_Unit__c = cost / marginCalculation;
          pricing.Price_Per_Unit__c = pricing.Price_Per_Unit__c.setScale(3);
        } else if (count == 3) {
          Decimal cost = (pricing.Net_Cost__c + runChargeTotal3);
          decimal marginCalculation = 1 - (pricing.Margin__c / 100);
          pricing.Price_Per_Unit__c = cost / marginCalculation;
          pricing.Price_Per_Unit__c = pricing.Price_Per_Unit__c.setScale(3);
        } else if (count == 4) {
          Decimal cost = (pricing.Net_Cost__c + runChargeTotal4);
          decimal marginCalculation = 1 - (pricing.Margin__c / 100);
          pricing.Price_Per_Unit__c = cost / marginCalculation;
          pricing.Price_Per_Unit__c = pricing.Price_Per_Unit__c.setScale(3);
        } else if (count == 5) {
          Decimal cost = (pricing.Net_Cost__c + runChargeTotal5);
          decimal marginCalculation = 1 - (pricing.Margin__c / 100);
          pricing.Price_Per_Unit__c = cost / marginCalculation;
          pricing.Price_Per_Unit__c = pricing.Price_Per_Unit__c.setScale(3);
        }
        pricingListToUpdate.add(pricing);
        count++;
      }
      update pricingListToUpdate;
      details.pricingDetails = null;
      details.pricingDetails = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Color__c,
          Size__c,
          Quantity__c,
          Net_Cost__c,
          Price_Per_Unit__c,
          Retail_Price__c,
          Margin__c,
          Show_To_Client__c,
          Total__c,
          CreatedDate
        FROM PricingLineItem__c
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
      return details;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM getOpportunityLineItemDetails FUNCTION ->>' +
        ex.getMessage()
      );
      return details;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updatePricePerUnit(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      PricingLineItem__c pricePerUnitToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];

      List<Line_Item_Pricing_RunCharge__c> runCharges = [
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
        WHERE
          OpportunityLineItem__c = :pricePerUnitToUpdate.OpportunityLineItem__c
        ORDER BY CreatedDate ASC
      ];

      Decimal runChargeTotal1 = 0;
      Decimal runChargeTotal2 = 0;
      Decimal runChargeTotal3 = 0;
      Decimal runChargeTotal4 = 0;
      Decimal runChargeTotal5 = 0;
      for (Line_Item_Pricing_RunCharge__c runCharge : runCharges) {
        if (runCharge.Value1__c != null) {
          runChargeTotal1 += runCharge.Value1__c;
        }
        if (runCharge.Value2__c != null) {
          runChargeTotal2 += runCharge.Value2__c;
        }
        if (runCharge.Value3__c != null) {
          runChargeTotal3 += runCharge.Value3__c;
        }
        if (runCharge.Value4__c != null) {
          runChargeTotal4 += runCharge.Value4__c;
        }
        if (runCharge.Value5__c != null) {
          runChargeTotal5 += runCharge.Value5__c;
        }
      }
      decimal cost = pricePerUnitToUpdate.Net_Cost__c;
      if (updateKey == 'total1') {
        cost += runChargeTotal1;
      } else if (updateKey == 'total2') {
        cost += runChargeTotal2;
      } else if (updateKey == 'total3') {
        cost += runChargeTotal3;
      } else if (updateKey == 'total4') {
        cost += runChargeTotal4;
      } else {
        cost += runChargeTotal5;
      }

      pricePerUnitToUpdate.Total__c = decimal.valueOf(updatedValue);
      decimal priceCostCalculation = pricePerUnitToUpdate.Total__c - cost;
      pricePerUnitToUpdate.Margin__c =
        (priceCostCalculation / pricePerUnitToUpdate.Total__c) * 100;
      pricePerUnitToUpdate.Margin__c = pricePerUnitToUpdate.Margin__c.setScale(
        3
      );

      update pricePerUnitToUpdate;
      return getOpportunityLineItemDetails(
        pricePerUnitToUpdate.OpportunityLineItem__c
      );
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM ->>' + ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static List<String> getArtworksForPickList(String recId) {
    List<OpportunityLineItem_ArtWork__c> artworks = [
      SELECT Id, Title__c, OpportunityLineItem__c
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c = :recId
    ];
    List<String> picklistValues = new List<String>();

    for (OpportunityLineItem_ArtWork__c art : artworks) {
      if (art.Title__c != '') {
        picklistValues.add(art.Title__c);
      }
    }
    return picklistValues;
  }
  @AuraEnabled
  public static boolean addCommentsInDb(
    String recId,
    String comment,
    String username
  ) {
    try {
      Comment__c comm = new Comment__c();
      comm.Date__c = System.now().format('MM-dd-yyyy');
      comm.Comment__c = comment;
      comm.User__c = username;
      comm.OpportunityLineItem__c = recId;
      insert comm;
      return true;
    } catch (Exception ex) {
      return false;
    }
  }
  @AuraEnabled
  public static boolean addFixedCharges(
    String recId,
    String title,
    String artwork
  ) {
    try {
      OpportunityLineItem_Add_Fixed_Charge__c fixedCharges = new OpportunityLineItem_Add_Fixed_Charge__c();
      fixedCharges.OpportunityLineItem__c = recId;
      fixedCharges.Cost__c = 0.0;
      fixedCharges.Margin__c = 0.0;
      fixedCharges.Title__c = title;
      fixedCharges.Retail_Price__c = 0.0;
      if (artwork != '') {
        List<OpportunityLineItem_ArtWork__c> fetchedArtwork = [
          SELECT Id, Title__c
          FROM OpportunityLineItem_ArtWork__c
          WHERE Title__c = :artwork AND OpportunityLineItem__c = :recId
        ];
        fixedCharges.OpportunityLineItem_ArtWork__c = fetchedArtwork[0].id;
        fixedCharges.Is_Associated_With_Artwork_c__c = true;
      }

      insert fixedCharges;

      return true;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM,ADD FIXED CHARGES FUNCTION ->>' +
        ex.getMessage()
      );
      return false;
    }
  }
  @AuraEnabled
  public static boolean addWarningInDB(String recId) {
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
  public static OpportunityLineItemDetails addRunCharges(
    String recId,
    String title,
    String cost1,
    String cost2,
    String cost3,
    String cost4,
    String cost5,
    String artwork
  ) {
    OpportunityLineItemDetails pricingDetails = getOpportunityLineItemDetails(
      recId
    );

    try {
      Line_Item_Pricing_RunCharge__c runCharges = new Line_Item_Pricing_RunCharge__c();
      runCharges.OpportunityLineItem__c = recId;

      runCharges.Title__c = title;
      if (cost1 != null) {
        runCharges.Value1__c = Decimal.valueOf(cost1) == null
          ? 0.00
          : Decimal.valueOf(cost1).setScale(3);
        if (pricingDetails.pricingDetails[0].Show_To_Client__c == true) {
          runCharges.Value_1_show__c = true;
        } else {
          runCharges.Value_1_show__c = false;
        }
      }
      if (cost2 != null) {
        runCharges.Value2__c = Decimal.valueOf(cost2) == null
          ? 0.00
          : Decimal.valueOf(cost2).setScale(3);
        if (pricingDetails.pricingDetails[1].Show_To_Client__c == true) {
          runCharges.Value_2_show__c = true;
        } else {
          runCharges.Value_2_show__c = false;
        }
      }
      if (cost3 != null) {
        runCharges.Value3__c = Decimal.valueOf(cost3) == null
          ? 0.00
          : Decimal.valueOf(cost3).setScale(3);
        if (pricingDetails.pricingDetails[2].Show_To_Client__c == true) {
          runCharges.Value_3_show__c = true;
        } else {
          runCharges.Value_3_show__c = false;
        }
      }
      if (cost4 != null) {
        runCharges.Value4__c = Decimal.valueOf(cost4) == null
          ? 0.00
          : Decimal.valueOf(cost4).setScale(3);
        if (pricingDetails.pricingDetails[3].Show_To_Client__c == true) {
          runCharges.Value_4_show__c = true;
        } else {
          runCharges.Value_4_show__c = false;
        }
      }
      if (cost5 != null) {
        runCharges.Value5__c = Decimal.valueOf(cost5) == null
          ? 0.00
          : Decimal.valueOf(cost5).setScale(3);
        if (pricingDetails.pricingDetails[4].Show_To_Client__c == true) {
          runCharges.Value_5_show__c = true;
        } else {
          runCharges.Value_5_show__c = false;
        }
      }

      if (artwork != '') {
        List<OpportunityLineItem_ArtWork__c> fetchedArtwork = [
          SELECT Id, Title__c
          FROM OpportunityLineItem_ArtWork__c
          WHERE Title__c = :artwork AND OpportunityLineItem__c = :recId
        ];
        runCharges.OpportunityLineItem_ArtWork__c = fetchedArtwork[0].id;
        runCharges.Is_Associated_With_Artwork__c = true;
      }

      insert runCharges;
      List<PricingLineItem__c> pricings = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Price_Per_Unit__c,
          Margin__c,
          Total__c,
          CreatedDate
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      Integer count = 1;
      for (PricingLineItem__c pricing : pricings) {
        if (pricing.Total__c == null) {
          pricing.Total__c = 0;
        }
        if (pricing.Margin__c == null) {
          pricing.Margin__c = 0;
        }
        if (count == 1 && (cost1 != null)) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) + runCharges.Value1__c) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 2 && cost2 != null) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) + runCharges.Value2__c) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 3 && cost3 != null) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) + runCharges.Value3__c) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 4 && cost4 != null) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) + runCharges.Value4__c) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 5 && cost5 != null) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) + runCharges.Value5__c) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        }
        count++;
      }

      update pricings;
      return getOpportunityLineItemDetails(recId);
    } catch (Exception ex) {
      System.debug(
        'ERROR IN EDIT OPPORTUNITY LINE ITEM,ADD RUN CHARGES FUNCTION ->>' +
        ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updateMarginInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate,
    String updatedValueTotal
  ) {
    try {
      PricingLineItem__c marginToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      marginToUpdate.Margin__c = decimal.valueOf(updatedValue);
      update marginToUpdate;
      return getOpportunityLineItemDetails(
        marginToUpdate.OpportunityLineItem__c
      );
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Margin ->>' + ex.getMessage());
      return null;
    }
  }

  @AuraEnabled
  public static boolean updateTotalInDb(
    String recordToUpdate,
    String updatedValueTotal
  ) {
    try {
      PricingLineItem__c marginToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      marginToUpdate.Total__c = decimal.valueOf(updatedValueTotal);

      update marginToUpdate;
      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Margin ->>' + ex.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static boolean updateClientClickInDb(
    String recordToUpdate,
    String checkboxValue,
    String val
  ) {
    try {
      PricingLineItem__c marginToUpdate = [
        SELECT Id, Show_To_Client__c, OpportunityLineItem__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      marginToUpdate.Show_To_Client__c = Boolean.valueOf(checkboxValue);
      update marginToUpdate;
      List<Line_Item_Pricing_RunCharge__c> runcharges = [
        SELECT
          Id,
          Name,
          OpportunityLineItem__c,
          Value_1_show__c,
          Value_2_show__c,
          Value_3_show__c,
          Value_4_show__c,
          Value_5_show__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE OpportunityLineItem__c = :marginToUpdate.OpportunityLineItem__c
      ];
      for (Line_Item_Pricing_RunCharge__c runcharge : runcharges) {
        if (val == 'showToClient0') {
          runcharge.Value_1_show__c = Boolean.valueOf(checkboxValue);
        } else if (val == 'showToClient1') {
          runcharge.Value_2_show__c = Boolean.valueOf(checkboxValue);
        } else if (val == 'showToClient2') {
          runcharge.Value_3_show__c = Boolean.valueOf(checkboxValue);
        } else if (val == 'showToClient3') {
          runcharge.Value_4_show__c = Boolean.valueOf(checkboxValue);
        } else if (val == 'showToClient4') {
          runcharge.Value_5_show__c = Boolean.valueOf(checkboxValue);
        }
      }

      update runcharges;
      return true;
    } catch (Exception ex) {
      System.debug(
        'ERROR IN Updating Margin ->>' +
          ex.getMessage() +
          ex.getStackTraceString()
      );
      return false;
    }
  }

  @AuraEnabled
  public static boolean updateQuantityInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      PricingLineItem__c quantityToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      quantityToUpdate.Quantity__c = decimal.valueOf(updatedValue);
      update quantityToUpdate;
      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Cost ->>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updateCostInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      PricingLineItem__c costToUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Quantity__c,
          Net_Cost__c,
          Retail_Price__c,
          Margin__c,
          Total__c
        FROM PricingLineItem__c
        WHERE Id = :recordToUpdate
      ];
      costToUpdate.Net_Cost__c = decimal.valueOf(updatedValue);
      update costToUpdate;
      return getOpportunityLineItemDetails(costToUpdate.OpportunityLineItem__c);
    } catch (Exception ex) {
      System.debug('ERROR IN Updating Cost ->>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static boolean deleteRunChargeinDB(
    String recordToUpdate,
    String recId
  ) {
    try {
      Line_Item_Pricing_RunCharge__c runCharges = [
        SELECT Value1__c, Value2__c, Value3__c, Value4__c, Value5__c, Id
        FROM Line_Item_Pricing_RunCharge__c
        WHERE Id = :recordToUpdate
      ];
      List<PricingLineItem__c> pricings = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Price_Per_Unit__c,
          Margin__c,
          Total__c,
          CreatedDate
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      Integer count = 1;
      for (PricingLineItem__c pricing : pricings) {
        if (pricing.Total__c == null) {
          pricing.Total__c = 0;
        }
        if (pricing.Margin__c == null) {
          pricing.Margin__c = 0;
        }
        if (pricing.Price_Per_Unit__c == null) {
          pricing.Price_Per_Unit__c = 0;
        }
        if (count == 1) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) -
            (runCharges.Value1__c == null ? 0.00 : runCharges.Value1__c)) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 2) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) -
            (runCharges.Value2__c == null ? 0.00 : runCharges.Value2__c)) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 3) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) -
            (runCharges.Value3__c == null ? 0.00 : runCharges.Value3__c)) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 4) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) -
            (runCharges.Value4__c == null ? 0.00 : runCharges.Value4__c)) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        } else if (count == 5) {
          pricing.Price_Per_Unit__c = ((((pricing.Total__c *
            (1 - (pricing.Margin__c / 100))) -
            (runCharges.Value5__c == null ? 0.00 : runCharges.Value5__c)) /
            (1 - (pricing.Margin__c / 100))))
            .setScale(3);
        }
        count++;
      }

      update pricings;
      delete runCharges;
      return true;
    } catch (Exception ex) {
      System.debug('Exception ->>>>>>>>>' + Ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static OpportunityLineItemDetails updateRunChargeValueinDB(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      Line_Item_Pricing_RunCharge__c itemToUpdate = [
        SELECT
          Value1__c,
          Value2__c,
          Value3__c,
          Value4__c,
          Value5__c,
          Is_Associated_With_Artwork__c,
          OpportunityLineItem__c,
          Title__c,
          Id
        FROM Line_Item_Pricing_RunCharge__c
        WHERE Id = :recordToUpdate
      ];
      if (updateKey != 'delete') {
        if (updateKey == 'dynamicIdsValues1') {
          itemToUpdate.Value1__c = decimal.valueOf(updatedValue).setScale(3);
        } else if (updateKey == 'dynamicIdsValues2') {
          itemToUpdate.Value2__c = decimal.valueOf(updatedValue).setScale(3);
        } else if (updateKey == 'dynamicIdsValues3') {
          itemToUpdate.Value3__c = decimal.valueOf(updatedValue).setScale(3);
        } else if (updateKey == 'dynamicIdsValues4') {
          itemToUpdate.Value4__c = decimal.valueOf(updatedValue).setScale(3);
        } else if (updateKey == 'dynamicIdsValues5') {
          itemToUpdate.Value5__c = decimal.valueOf(updatedValue).setScale(3);
        } else if (updateKey == 'runChargesTitle') {
          itemToUpdate.Title__c = updatedValue;
        }
        update itemToUpdate;
        return getOpportunityLineItemDetails(
          itemToUpdate.OpportunityLineItem__c
        );
      } else {
        delete itemToUpdate;
        return getOpportunityLineItemDetails(
          itemToUpdate.OpportunityLineItem__c
        );
      }
    } catch (Exception ex) {
      System.debug('Exception ->>>>>>>>>' + Ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static boolean deleteWarningInDb(String recId) {
    try {
      WarningsOpportunityLineItem__c warningToDelete = [
        SELECT Id, Warning__c
        FROM WarningsOpportunityLineItem__c
        WHERE Id = :recId
      ];
      delete warningToDelete;
      return true;
    } catch (Exception ex) {
      System.debug('Exception in deleting Warning->>>>>>>>>' + Ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static OpportunityLineItem_Add_Fixed_Charge__c updateFixedChargesInDb(
    String updatedValue,
    String updateKey,
    String recordToUpdate
  ) {
    try {
      OpportunityLineItem_Add_Fixed_Charge__c itemToUpdate = [
        SELECT Id, Title__c, Cost__c, Margin__c, Retail_Price__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE Id = :recordToUpdate
      ];
      if (updateKey != 'delete') {
        if (updateKey == 'title') {
          itemToUpdate.Title__c = updatedValue;
        } else if (updateKey == 'cost') {
          itemToUpdate.Cost__c = decimal.valueOf(updatedValue).setScale(3);
          decimal marginCalculation = 1 - (itemToUpdate.Margin__c / 100);
          itemToUpdate.Retail_Price__c =
            itemToUpdate.Cost__c / marginCalculation;
          itemToUpdate.Retail_Price__c = itemToUpdate.Retail_Price__c.setScale(
            3
          );
        } else if (updateKey == 'margin') {
          itemToUpdate.Margin__c = decimal.valueOf(updatedValue);
          decimal marginCalculation = 1 - (itemToUpdate.Margin__c / 100);
          itemToUpdate.Retail_Price__c =
            itemToUpdate.Cost__c / marginCalculation;
          itemToUpdate.Retail_Price__c = itemToUpdate.Retail_Price__c.setScale(
            3
          );
        } else if (updateKey == 'retail') {
          itemToUpdate.Retail_Price__c = decimal.valueOf(updatedValue)
            .setScale(3);
          decimal priceCostCalculation =
            itemToUpdate.Retail_Price__c - itemToUpdate.Cost__c;
          itemToUpdate.Margin__c =
            (priceCostCalculation / itemToUpdate.Retail_Price__c) * 100;
          itemToUpdate.Margin__c = itemToUpdate.Margin__c.setScale(3);
        }

        update itemToUpdate;
        //  CalculateAndUpdateTotal(recId,'runCharges');
        return itemToUpdate;
      } else {
        delete itemToUpdate;
        return null;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception ->>>>>>>>>' + Ex.getMessage() + ex.getStackTraceString()
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
      if (productId != null) {
        List<Pricing_Product__c> lstProductPrices = [
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
        if (lstProductPrices.size() > 0) {
          update lstProductPrices;
        }
      }
      if (lstPrices.size() > 0) {
        if (lstESPPrices != null) {
          Integer counter = 0;
          for (PricingLineItem__c priceObj : lstPrices) {
            if (counter < lstESPPrices.size()) {
              priceObj.Net_Cost__c = lstESPPrices.get(counter).Cost;
              priceObj.Total__c =
                priceObj.Net_Cost__c / (1 - (priceObj.Margin__c / 100));
              counter++;
            }
          }
        }
        update lstPrices;
      }
    }
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
  public static boolean updateNotesAndLabelInDb(
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
          Additional_Colors__c,
          Additional_Locations__c
        FROM OpportunityLineItem__c
        WHERE Id = :recordToUpdate
      ];

      if (updateKey == 'privateNotes') {
        opportunitLineItemData.Private_Notes__c = updatedValue;
      } else if (updateKey == 'priceLabel') {
        opportunitLineItemData.Price_Label__c = updatedValue;
      } else if (updateKey == 'description') {
        opportunitLineItemData.Description__c = updatedValue;
      } else if (updateKey == 'productName') {
        opportunitLineItemData.Name = updatedValue;
      }
      update opportunitLineItemData;

      return true;
    } catch (Exception Ex) {
      System.debug('Exception ->>>>>>>>>' + Ex.getMessage());
      return false;
    }
  }
}
