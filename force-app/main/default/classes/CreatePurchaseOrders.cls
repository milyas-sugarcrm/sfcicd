public class CreatePurchaseOrders {
  @AuraEnabled
  public static List<oppLineItemDetails> getProducts(Id orderId) {
    try {
      List<OpportunityLineItem__c> opportunityLineItems = [
        SELECT
          Id,
          Name,
          Shipping_Information__c,
          Shipping_Information__r.Ship_To__c,
          Shipping_Information__r.Company_Address__r.Address__c,
          Shipping_Information__r.Client_Address__c,
          Description__c,
          Shipping_Information__r.In_Hands_Date__c,
          Product__c,
          Product__r.Name,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Work_Order__c,
          Shipping_Information__r.supplier__c,
          Shipping_Information__r.Client_Shipping_Address__c,
          Shipping_Information__r.Other_Address__c
        FROM OpportunityLineItem__c
        WHERE
          Work_Order__c = :orderId
          AND PurchaseOrder_LineItem__c = NULL
          AND Shipping_Information__c != NULL
          AND Shipping_Information__r.supplier__c != NULL
        ORDER BY CreatedDate DESC
      ];
      List<Id> shippingInfoIdsForLineItems = new List<Id>();
      for (OpportunityLineItem__c lineItem : opportunityLineItems) {
        shippingInfoIdsForLineItems.add(lineItem.Shipping_Information__c);
      }
      List<Shipping__c> shippingRecordsForLineItems = [
        SELECT
          Decorator_Address__c,
          Decorator_Address__r.DisplayAddress__c,
          Supplier_Address__c,
          Supplier_Address__r.DisplayAddress__c,
          ShipInformation__c,
          Client_Shipping_Address__c,
          Client_Address__c,
          Company_Address__c,
          Ship_To__c,
          Other_Supplier_Address__c,
          Decorator_Shipping_Address__c
        FROM Shipping__c
        WHERE ShipInformation__c IN :shippingInfoIdsForLineItems
      ];
      Map<Id, Shipping__c> lineItemToShippingMap = new Map<Id, Shipping__c>();
      for (OpportunityLineItem__c lineItems : opportunityLineItems) {
        for (
          Shipping__c shippingRecordForLineItem : shippingRecordsForLineItems
        ) {
          if (
            lineItems.Shipping_Information__c ==
            shippingRecordForLineItem.ShipInformation__c
          ) {
            lineItemToShippingMap.put(lineItems.Id, shippingRecordForLineItem);
          }
        }
      }
      System.debug(lineItemToShippingMap);
      List<PurchaseOrder_LineItem__c> purchaseOrdersList = [
        SELECT
          id,
          Shipping_Information__c,
          Shipping_Information__r.Company_Address__r.Address__c,
          Shipping_Information__r.Client_Address__c,
          Name,
          Shipping_Information__r.Ship_To__c,
          WO_Status__c,
          Shipping_Information__r.In_Hands_Date__c,
          Shipping_Information__r.supplier__c,
          Shipping_Information__r.Client_Shipping_Address__c,
          Shipping_Information__r.Other_Address__c
        FROM PurchaseOrder_LineItem__c
        WHERE WO_Status__c = 'Open'
      ];
      List<Id> shippingInfoIds = new List<Id>();
      for (PurchaseOrder_LineItem__c PO : purchaseOrdersList) {
        shippingInfoIds.add(PO.Shipping_Information__c);
      }
      List<Shipping__c> shippingRecords = [
        SELECT
          Decorator_Address__c,
          Decorator_Address__r.DisplayAddress__c,
          Supplier_Address__c,
          Supplier_Address__r.DisplayAddress__c,
          ShipInformation__c,
          Client_Address__c,
          Company_Address__c,
          Ship_To__c,
          Other_Supplier_Address__c,
          Decorator_Shipping_Address__c,
          Client_Shipping_Address__c
        FROM Shipping__c
        WHERE ShipInformation__c IN :shippingInfoIds
      ];

      Map<Id, Shipping__c> poToShippingMap = new Map<Id, Shipping__c>();

      for (PurchaseOrder_LineItem__c PO : purchaseOrdersList) {
        for (Shipping__c shippingRecord : shippingRecords) {
          if (PO.Shipping_Information__c == shippingRecord.ShipInformation__c) {
            poToShippingMap.put(PO.Id, shippingRecord);
          }
        }
      }
      System.debug(poToShippingMap);
      Map<Id, List<PurchaseOrder_LineItem__c>> oppLineItemPOsMap = new Map<Id, List<PurchaseOrder_LineItem__c>>();

      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        List<PurchaseOrder_LineItem__c> listOfPOs = new List<PurchaseOrder_LineItem__c>();
        for (PurchaseOrder_LineItem__c purchaseOrders : purchaseOrdersList) {
          if (
            purchaseOrders.Shipping_Information__r.Supplier__c ==
            oppLineItem.Shipping_Information__r.Supplier__c &&
            purchaseOrders.Shipping_Information__r.Ship_To__c ==
            oppLineItem.Shipping_Information__r.Ship_To__c &&
            purchaseOrders.Shipping_Information__r.In_Hands_Date__c ==
            oppLineItem.Shipping_Information__r.In_Hands_Date__c
          ) {
            if (
              oppLineItem.Shipping_Information__r.Ship_To__c == 'Client' &&
              purchaseOrders.Shipping_Information__r.Client_Shipping_Address__c ==
              oppLineItem.Shipping_Information__r.Client_Shipping_Address__c
            ) {
              listOfPOs.add(purchaseOrders);
            } else if (
              oppLineItem.Shipping_Information__r.Ship_To__c == 'Team Phun' &&
              purchaseOrders.Shipping_Information__r.Company_Address__r.Address__c ==
              oppLineItem.Shipping_Information__r.Company_Address__r.Address__c
            ) {
              listOfPOs.add(purchaseOrders);
            } else if (
              oppLineItem.Shipping_Information__r.Ship_To__c == 'Decorator' &&
              lineItemToShippingMap.get(oppLineItem.Id).Ship_To__c ==
              poToShippingMap.get(purchaseOrders.Id).Ship_To__c &&
              (poToShippingMap.get(purchaseOrders.Id)
                .Decorator_Shipping_Address__c ==
              lineItemToShippingMap.get(oppLineItem.Id)
                .Decorator_Shipping_Address__c) &&
              ((poToShippingMap.get(purchaseOrders.Id).Company_Address__c ==
              lineItemToShippingMap.get(oppLineItem.Id).Company_Address__c) ||
              (poToShippingMap.get(purchaseOrders.Id)
                .Client_Shipping_Address__c ==
              lineItemToShippingMap.get(oppLineItem.Id)
                .Client_Shipping_Address__c))
            ) {
              listOfPOs.add(purchaseOrders);
            } else if (
              oppLineItem.Shipping_Information__r.Ship_To__c ==
              'Other Supplier' &&
              (poToShippingMap.get(purchaseOrders.Id)
                .Other_Supplier_Address__c ==
              lineItemToShippingMap.get(oppLineItem.Id)
                .Other_Supplier_Address__c)
            ) {
              listOfPOs.add(purchaseOrders);
            } else if (
              oppLineItem.Shipping_Information__r.Ship_To__c == 'Other' &&
              purchaseOrders.Shipping_Information__r.Other_Address__c ==
              oppLineItem.Shipping_Information__r.Other_Address__c
            ) {
              listOfPOs.add(purchaseOrders);
            }
          }
        }
        oppLineItemPOsMap.put(oppLineItem.id, listOfPOs);
      }

      ///////////////
      List<oppLineItemDetails> oppLineItemsDetails = new List<oppLineItemDetails>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        oppLineItemDetails oppDetails = new oppLineItemDetails();
        oppDetails.oppLineItem = oppLineItem;
        oppDetails.existingPOs = oppLineItemPOsMap.get(oppLineItem.id);
        oppLineItemsDetails.add(oppDetails);
      }
      if (oppLineItemsDetails != null && oppLineItemsDetails.size() > 0) {
        return oppLineItemsDetails;
      } else
        return null;
    } catch (Exception ex) {
      System.debug(
        'Exception in getting products---> ' +
          ex.getMessage() +
          '------' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static Boolean createPurchaseOrders(Id orderId, String valuesAndIds) {
    try {
      List<PODetails> POsDetails = (List<PODetails>) System.JSON.deserializeStrict(
        valuesAndIds,
        List<PODetails>.class
      );
      List<Id> listOfIds = new List<Id>();
      for (PODetails obj : POsDetails) {
        listOfIds.add(obj.prodId);
      }
      List<OpportunityLineItem__c> opportunityLineItems = [
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
          Shipping_Information__r.supplier__c,
          Shipping_Information__r.In_Hands_Date__c
        FROM OpportunityLineItem__c
        WHERE
          Id IN :listOfIds
          AND Shipping_Information__c != NULL
          AND Shipping_Information__r.supplier__c != NULL
        ORDER BY CreatedDate DESC
      ];
      List<PurchaseOrder_LineItem__c> purchaseOrderLineItem = new List<PurchaseOrder_LineItem__c>();
      List<OpportunityLineItem__c> listToUpdate = new List<OpportunityLineItem__c>();
      Map<Id, PurchaseOrder_LineItem__c> oppLineItemPOMap = new Map<Id, PurchaseOrder_LineItem__c>();
      for (PODetails pos : POsDetails) {
        for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
          if (pos.prodId == oppLineItem.id && pos.value == 'Create New PO') {
            PurchaseOrder_LineItem__c po = new PurchaseOrder_LineItem__c();
            po.WO_Status__c = 'Open';
            po.In_Hands_Date__c = oppLineItem.Shipping_Information__r.In_Hands_Date__c;
            po.Shipping_Information__c = oppLineItem.Shipping_Information__c;
            po.Supplier__c = oppLineItem.Shipping_Information__r.supplier__c;
            po.Work_Order__c = orderId;
            po.OpportunityLineItem__c = oppLineItem.Id;
            purchaseOrderLineItem.add(po);
            oppLineItemPOMap.put(oppLineItem.id, po);
          } else if (
            pos.prodId == oppLineItem.id &&
            pos.value != null &&
            pos.value != 'Create New PO'
          ) {
            oppLineItem.PurchaseOrder_LineItem__c = pos.value;
            listToUpdate.add(oppLineItem);
          }
        }
      }
      insert purchaseOrderLineItem;
      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        if (
          oppLineItemPOMap.get(oppLineItem.id) != null &&
          oppLineItemPOMap.get(oppLineItem.id).id != null
        ) {
          oppLineItem.PurchaseOrder_LineItem__c = oppLineItemPOMap.get(
              oppLineItem.id
            )
            .id;
          listToUpdate.add(oppLineItem);
        }
      }
      update listToUpdate;
      return true;
    } catch (Exception ex) {
      System.debug(
        'Error in creating Purchase Orders---> ' +
          ex.getMessage() +
          '-----' +
          ex.getStackTraceString()
      );
      return false;
    }
  }
  public class oppLineItemDetails {
    @AuraEnabled
    public OpportunityLineItem__c oppLineItem { get; set; }
    @AuraEnabled
    public List<PurchaseOrder_LineItem__c> existingPOs { get; set; }
    public oppLineItemDetails() {
      oppLineItem = new OpportunityLineItem__c();
      existingPOs = new List<PurchaseOrder_LineItem__c>();
    }
  }
  public class PODetails {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String prodId;
  }
}
