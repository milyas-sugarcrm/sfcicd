public class ShippingOppLineItemController {
  @AuraEnabled
  public static Boolean getProductsWithShippingInfo(Id salesId) {
    List<OpportunityLineItem__c> opportunityLineItems = [
      SELECT
        Id,
        Name,
        PurchaseOrder_LineItem__c,
        Description__c,
        Product__c,
        Product__r.Name,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Work_Order__c,
        Shipping_Information__r.supplier__c
      FROM OpportunityLineItem__c
      WHERE
        Work_Order__c = :salesId
        AND Shipping_Information__c != NULL
        AND Shipping_Information__r.supplier__c != NULL
    ];
    if (opportunityLineItems != null && opportunityLineItems.size() > 0) {
      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        if (oppLineItem.PurchaseOrder_LineItem__c == null) {
          return true;
        }
      }
      return false;
    } else
      return null;
  }

  @AuraEnabled
  public static List<EstimatePopupDetails> getSalesOrderRelatedOpportunityLineItems(
    Id salesId,
    Integer numOfrec
  ) {
    List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
    List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
      SELECT
        Id,
        Name,
        Description__c,
        Product__c,
        Product__r.Name,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Work_Order__c,
        Shipping_Information__r.Id,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :salesId
      ORDER BY Sorting_Date__c ASC
    ];

    //Sorting Logic
    List<OpportunityLineItem__c> relatedOpportunityLineItems = ProductsSorting.sortProducts(
      relatedOpportunityLineItemsUnsorted
    );
    //details of each opportunityLine item
    Set<id> shippinginfoIds = new Set<id>();
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
      EstimatePopupDetails details = new EstimatePopupDetails();
      details.oppLineItemId = oppLineItem.Id;
      details.productId = oppLineItem.Product__r.Id;
      details.productName = oppLineItem.name;
      shippinginfoIds.add(oppLineItem.Shipping_Information__c);
      if ((numOfrec == 6 && detailsToReturn.size() < numOfrec) || numOfrec != 6)
        detailsToReturn.add(details);
    }
    Map<Id, Shipping_Information__c> shippinginfoMap = new Map<Id, Shipping_Information__c>();
    Map<Id, Shipping_Information__c> shippingInformation = new Map<Id, Shipping_Information__c>(
      [
        SELECT
          Id,
          Name,
          In_Hands_Date__c,
          Ship_To__c,
          Client_Address__c,
          Shipping_Method__c,
          Company_Address__c,
          Client_Shipping_Address__c,
          Other_Address__c
        FROM Shipping_Information__c
        WHERE id IN :shippinginfoIds
      ]
    );
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
      for (Shipping_Information__c shipinfo : shippingInformation.values()) {
        if (oppLineItem.Shipping_Information__c == shipinfo.Id) {
          shippinginfoMap.put(oppLineItem.Id, shipinfo);
        }
      }
    }
    List<Shipping__c> shippings = [
      SELECT
        Id,
        Name,
        In_Hands_Date__c,
        Ship_To__c,
        ShipInformation__c,
        Client_Address__c,
        Shipping_Method__c,
        Company_Address__c,
        Decorator_Address__c,
        Supplier_Address__c,
        Other_Supplier_Address__c,
        Decorator_Shipping_Address__c
      FROM Shipping__c
      WHERE ShipInformation__c IN :shippingInformation.keySet()
    ];
    Map<Id, Shipping__c> shippingMap = new Map<Id, Shipping__c>();
    Set<Id> AddressIds = new Set<Id>();
    Set<Id> compAdressIds = new Set<Id>();
    for (Shipping_Information__c shipinfo : shippingInformation.values()) {
      AddressIds.add(shipinfo.Client_Address__c);
      compAdressIds.add(shipinfo.Company_Address__c);
    }
    for (Shipping__c ship : shippings) {
      AddressIds.add(ship.Client_Address__c);
      AddressIds.add(ship.Decorator_Address__c);
      AddressIds.add(ship.Supplier_Address__c);
      compAdressIds.add(ship.Company_Address__c);
      shippingMap.put(ship.ShipInformation__c, ship);
    }
    Map<Id, Address__c> addresses = new Map<Id, Address__c>(
      [SELECT Id, DisplayAddress__c FROM Address__c WHERE id IN :AddressIds]
    );
    Map<Id, CompAddress__c> compAddresses = new Map<Id, CompAddress__c>(
      [SELECT Id, Address__c FROM CompAddress__c WHERE id IN :compAdressIds]
    );

    for (EstimatePopupDetails details : detailsToReturn) {
      details.shippingInformationDetails = shippinginfoMap.get(
        details.oppLineItemId
      );
      System.debug(
        'Clientt add: ' +
        addresses.get(
          shippinginfoMap.get(details.oppLineItemId).Client_Address__c
        )
      );
      if (shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Client') {
        details.shippingInfoAddress = shippinginfoMap.get(details.oppLineItemId)
          .Client_Shipping_Address__c;
      } else if (
        shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Team Phun' &&
        compAddresses.get(
          shippinginfoMap.get(details.oppLineItemId).Company_Address__c
        ) != null
      ) {
        details.shippingInfoAddress = compAddresses.get(
            shippinginfoMap.get(details.oppLineItemId).Company_Address__c
          )
          .Address__c;
        details.shippingInfoAddress = details.shippingInfoAddress.replaceAll(
          '<br/>',
          ' '
        );
      } else if (
        shippinginfoMap.get(details.oppLineItemId).Ship_To__c ==
        'Other Supplier'
      ) {
        details.shippingInfoAddress = shippingMap.get(
            shippinginfoMap.get(details.oppLineItemId).Id
          )
          .Other_Supplier_Address__c;
      } else if (
        shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Decorator' &&
        shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id) != null
      ) {
        details.shippingDetails = shippingMap.get(
          shippinginfoMap.get(details.oppLineItemId).Id
        );
        details.shippingInfoAddress = shippingMap.get(
            shippinginfoMap.get(details.oppLineItemId).Id
          )
          .Decorator_Shipping_Address__c;
        if (
          shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
            .Ship_To__c == 'Client' &&
          addresses.get(
            shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
              .Client_Address__c
          ) != null
        ) {
          details.shippingAddress = addresses.get(
              shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
                .Client_Address__c
            )
            .DisplayAddress__c;
          details.shippingAddress = details.shippingAddress.replaceAll(
            '<br/>',
            ' '
          );
        } else if (
          shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
            .Ship_To__c == 'Team Phun' &&
          compAddresses.get(
            shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
              .Company_Address__c
          ) != null
        ) {
          details.shippingAddress = compAddresses.get(
              shippingMap.get(shippinginfoMap.get(details.oppLineItemId).Id)
                .Company_Address__c
            )
            .Address__c;
          details.shippingAddress = details.shippingAddress.replaceAll(
            '<br/>',
            ' '
          );
        }
      } else if (
        shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Other'
      ) {
        details.shippingInfoAddress = shippinginfoMap.get(details.oppLineItemId)
          .Other_Address__c;
      }
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
        SELECT Id, Name
        FROM OpportunityLineItem__c
        WHERE Id = :salesId
      ];
      delete opportunityLine;
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
}
