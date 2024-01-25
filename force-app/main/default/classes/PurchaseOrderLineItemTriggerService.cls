public class PurchaseOrderLineItemTriggerService {
  private static Boolean firstRun = true;
  private static Boolean firstRunAftertrigger = true;
  public static void changeStatusOfPO(
    List<PurchaseOrder_LineItem__c> newValues,
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    if (firstRun == true) {
      firstRun = false;
      for (PurchaseOrder_LineItem__c PO : newValues) {
        if (PO.WO_Status__c == oldValues.get(PO.Id).WO_Status__c) {
          if (
            PO.Master_Tracking_Number_to_Client__c != null &&
            PO.Client_Picked_Up_or_Notified__c != null
          ) {
            PO.WO_Status__c = 'Billed';
          } else if (
            PO.Preferred_Carrier__c != null &&
            PO.Boxes_for_Pickup__c != null &&
            PO.Pickup_Location__c != null
          ) {
            PO.WO_Status__c = 'Ready to Ship/Pickup';
          } else if (PO.Boxes_Received__c != null) {
            PO.WO_Status__c = 'Received at QC';
          } else if (PO.PO_Completion_Date__c != null) {
            if (
              PO.Require_Carrier__c != null &&
              PO.Tracking_Number__c != null &&
              PO.Boxes__c != null
            ) {
              PO.WO_Status__c = 'Shipped';
            } else {
              PO.WO_Status__c = 'Ready for TP Pickup';
            }
          } else if (
            PO.PO_Confirmed_On__c != null &&
            PO.PO_Confirmed_By__c != null &&
            PO.PO_Estimated_Ship_Date__c != null
          ) {
            PO.WO_Status__c = 'In Process';
          } else if (PO.Date_and_Time_Sent__c != null) {
            PO.WO_Status__c = 'Sent';
          }
        } else if (
          PO.WO_Status__c != oldValues.get(PO.Id).WO_Status__c &&
          oldValues.get(PO.Id).WO_Status__c == 'Billed'
        ) {
          PO.WO_Status__c = 'Billed';
        } else if (PO.WO_Status__c != oldValues.get(PO.Id).WO_Status__c) {
          if (PO.Production_Rep__c != UserInfo.getName()) {
            PO.WO_Status__c = oldValues.get(PO.Id).WO_Status__c;
            PO.addError('Only Production Rep can Change Status');
          }
        }
      }
    }
  }
  public static void updatePurchaseOrderinQBO(
    List<PurchaseOrder_LineItem__c> newValues,
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    Set<Id> purchaseOrdersToBeCreated = new Set<Id>();
    Set<Id> purchaseOrdersToBeUpdated = new Set<Id>();
    Map<Id, String> OrderAccountMap = new Map<Id, String>();
    Set<Id> orderIds = new Set<Id>();
    for (PurchaseOrder_LineItem__c poOrder : newValues) {
      orderIds.add(poOrder.Work_Order__c);
    }
    List<Order> orders = [
      SELECT id, OpportunityId
      FROM Order
      WHERE Id IN :orderIds
    ];
    Set<Id> oppIds = new Set<Id>();
    for (Order order : orders) {
      oppIds.add(order.OpportunityId);
    }
    List<Estimate__c> estimates = [
      SELECT id, Opportunity__c, Selected_Quickbook_Instance__c
      FROM Estimate__c
      WHERE Opportunity__c IN :oppIds
    ];

    for (PurchaseOrder_LineItem__c poOrder : newValues) {
      // Update the syncing stage from "Billed" to "In Process".
      if (
        poOrder.WO_Status__c != oldValues.get(poOrder.id).WO_Status__c &&
        poOrder.WO_Status__c == 'In Process' &&
        poOrder.QBO_Bill__c == null
      ) {
        purchaseOrdersToBeCreated.add(poOrder.id);
      }
      // Update the syncing stage from "Billed" to "In Process".
      else if (
        poOrder.WO_Status__c == 'In Process' &&
        poOrder.QBO_Bill__c == null &&
        poOrder.Delivery_Date_Time__c !=
        oldValues.get(poOrder.id).Delivery_Date_Time__c
      ) {
        purchaseOrdersToBeCreated.add(poOrder.id);
      }
      // Update the syncing stage from "Billed" to "In Process".
      else if (
        poOrder.WO_Status__c == 'In Process' &&
        poOrder.QBO_Bill__c != null &&
        poOrder.Delivery_Date_Time__c !=
        oldValues.get(poOrder.id).Delivery_Date_Time__c
      ) {
        purchaseOrdersToBeUpdated.add(poOrder.id);
      }
      for (Order order : orders) {
        if (order.id == poOrder.Work_Order__c) {
          for (Estimate__c est : estimates) {
            // Stop purchase order synicing for Phun for all company (est.Selected_Quickbook_Instance__c != 'Phun for All')
            if (
              order.OpportunityId == est.Opportunity__c &&
              est.Selected_Quickbook_Instance__c != 'Phun for All'
            ) {
              OrderAccountMap.put(
                poOrder.id,
                est.Selected_Quickbook_Instance__c
              );
            }
          }
        }
      }
    }

    if (!system.isBatch() && !System.isFuture() && !Test.isRunningTest()) {
      // (OrderAccountMap.size()>0) stop syncing for Phun for all
      if (purchaseOrdersToBeCreated.size() > 0 && OrderAccountMap.size() > 0)
        QuickbookApiCrud.createPurchaseOrder(
          purchaseOrdersToBeCreated,
          OrderAccountMap
        );
      // (OrderAccountMap.size()>0) stop syncing for Phun for all
      if (purchaseOrdersToBeUpdated.size() > 0 && OrderAccountMap.size() > 0)
        QuickbookApiCrud.updatePurchaseOrder(
          purchaseOrdersToBeUpdated,
          OrderAccountMap
        );
    }
  }

  //to calculate cost financials information in purchase order
  public static void calculateCostFinancials(
    List<PurchaseOrder_LineItem__c> newValues,
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    // reccalulate the cost financials at the follwing statuses/stages of purchase order
    Set<String> statusToCheck = new Set<String>{
      'In Process',
      'Ready for TP Pickup',
      'Shipped',
      'Received at QC',
      'Ready to Ship/Pickup',
      'Billed'
    };
    List<Order> updatedWO = new List<Order>();
    Boolean flag = false;
    for (PurchaseOrder_LineItem__c po : newValues) {
      //if PO status get changed
      if (po.WO_Status__c != oldValues.get(po.Id).WO_Status__c) {
        if (statusToCheck.contains(po.WO_Status__c)) {
          Map<String, Decimal> costFinancials = calculatePOTotal(po.id);
          po.Cost_of_Goods_Sold__c = costFinancials.get('costOfGoods');
          po.Setup_Cost__c = costFinancials.get('setupCost');
        }
        //if PO get completed then recalculate the work order cost financials
        if (po.WO_Status__c == 'Billed') {
          flag = true;
          updatedWO.add(
            calculateWOTotal(
              po.Work_Order__c,
              po.Cost_of_Goods_Sold__c,
              po.Setup_Cost__c
            )
          );
        }
      }
    }
    // if flag is true then we need to update the work order
    if (flag) {
      update updatedWO;
    }
  }

  public static Map<String, Decimal> calculatePOTotal(
    String purchaseOrderLineItemId
  ) {
    Decimal totalCostofGoods = 0;
    Decimal totalSetupCost = 0;
    List<OpportunityLineItem__c> relatedOpportunityLineItem = new List<OpportunityLineItem__c>();
    relatedOpportunityLineItem = [
      SELECT Id
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :purchaseOrderLineItemId
    ];
    List<PricingLineItem__c> pricingDetails = [
      SELECT
        Id,
        Net_Cost__c,
        Estimated_Quantity__c,
        OpportunityLineItem__c,
        Display__c,
        Default__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c = :relatedOpportunityLineItem
        AND Display__c = TRUE
        AND Default__c = FALSE
    ];
    List<ExtraChargesEstimate__c> extraPricingDetails = [
      SELECT
        Id,
        Name,
        Quantity__c,
        Charge_Type__c,
        Net_Cost__c,
        OpportunityLineItem__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :relatedOpportunityLineItem
    ];

    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItem) {
      // to loop the prices of the product and to add it in total
      for (PricingLineItem__c price : pricingDetails) {
        if (price.OpportunityLineItem__c == oppLineItem.Id) {
          totalCostofGoods +=
            (price.Net_Cost__c == null ? 0 : price.Net_Cost__c) *
            (price.Estimated_Quantity__c == null
              ? 0
              : price.Estimated_Quantity__c);
        }
      }
      // to add extra charges in total value
      for (ExtraChargesEstimate__c extraPrice : extraPricingDetails) {
        if (extraPrice.OpportunityLineItem__c == oppLineItem.Id) {
          if (extraPrice.Charge_Type__c == 'AdditionalCost_RunCharge') {
            totalCostofGoods +=
              (extraPrice.Net_Cost__c == null ? 0 : extraPrice.Net_Cost__c) *
              (extraPrice.Quantity__c == null ? 0 : extraPrice.Quantity__c);
          } else if (
            extraPrice.Charge_Type__c == 'AdditionalCost_FixedCharge'
          ) {
            totalSetupCost +=
              (extraPrice.Net_Cost__c == null ? 0 : extraPrice.Net_Cost__c) *
              (extraPrice.Quantity__c == null ? 0 : extraPrice.Quantity__c);
          }
        }
      }
    }
    Map<String, Decimal> costFinancials = new Map<String, Decimal>();
    costFinancials.put('costOfGoods', totalCostofGoods);
    costFinancials.put('setupCost', totalSetupCost);

    return costFinancials;
  }

  public static Order calculateWOTotal(
    String workOrderId,
    Decimal currentPOCostOfGoods,
    Decimal currentPOSetupCost
  ) {
    Decimal totalCostofGoods = 0;
    Decimal totalSetupCost = 0;
    //fetch all PO related to a work order
    List<PurchaseOrder_LineItem__c> poLineItems = [
      SELECT Id, Cost_of_Goods_Sold__c, WO_Status__c, Setup_Cost__c
      FROM PurchaseOrder_LineItem__c
      WHERE Work_Order__c = :workOrderId AND WO_Status__c = 'Billed'
    ];
    //sum up the Cost of goog sold of PO
    for (PurchaseOrder_LineItem__c po : poLineItems) {
      totalCostofGoods += po.Cost_of_Goods_Sold__c == null
        ? 0
        : po.Cost_of_Goods_Sold__c;
      totalSetupCost += po.Setup_Cost__c == null ? 0 : po.Setup_Cost__c;
    }
    Order order = [
      SELECT Id, Cost_of_Goods_Sold__c, Setup_Cost__c
      FROM Order
      WHERE Id = :workOrderId
    ];
    order.Cost_of_Goods_Sold__c = totalCostofGoods + currentPOCostOfGoods;
    order.Setup_Cost__c = totalSetupCost + currentPOSetupCost;
    return order;
  }

  //recalculate cost financials of work order upon po deletion
  public static void reCalculateWOCostFinancials(
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    Set<Id> relatedWorkOrderIds = new Set<Id>();
    for (Id key : oldValues.keySet()) {
      relatedWorkOrderIds.add(oldValues.get(key).Work_Order__c);
    }
    List<Order> updatedWO = new List<Order>();
    Boolean flag = false;
    for (Id woId : relatedWorkOrderIds) {
      flag = true;
      updatedWO.add(calculateWOTotal(woId, 0, 0));
    }
    // if flag is true then we need to update the work order
    if (flag) {
      update updatedWO;
    }
  }

  public static void linkCheckPBRunOnce(
    List<PurchaseOrder_LineItem__c> newValues
  ) {
    List<CheckPBRunOnce__c> checkPBROList = [
      SELECT Id
      FROM CheckPBRunOnce__c
      LIMIT 1
    ];
    if (checkPBROList.size() == 0) {
      CheckPBRunOnce__c cPBRO = new CheckPBRunOnce__c();
      insert cPBRO;
      checkPBROList.add(cPBRO);
    }

    for (PurchaseOrder_LineItem__c pOLIC : newValues) {
      if (pOLIC.CheckPOPB__c == null) {
        pOLIC.CheckPOPB__c = checkPBROList[0].Id;
      }
    }
  }
  /**
   * @description to preapre data for delete bill record in QBO once user delete
   * purchase Order from Work Order or from delete action in PO detail view
   * @param oldValues
   */
  public static void deleteBillfromQBO(
    Map<Id, PurchaseOrder_LineItem__c> oldValues
  ) {
    Set<Id> poIds = new Set<Id>();
    for (Id key : oldValues.keySet()) {
      poIds.add(key);
    }
    List<PurchaseOrder_LineItem__c> pos = [
      SELECT Id, QBO_Bill_Id__c, QBO_Bill__c, WOQBOInstance__c
      FROM PurchaseOrder_LineItem__c
      WHERE id IN :poIds AND QBO_Bill_Id__c != NULL
    ];
    //if the deleting PO was already synced with QBO then only we need to delete otherwise
    for (PurchaseOrder_LineItem__c po : pos) {
      Map<Id, String> poAccountMap = new Map<Id, String>();
      poAccountMap.put(po.Id, po.WOQBOInstance__c);
      if (!Test.isRunningTest()) {
        QuickbookApiCrud.deleteBillfromQBO(
          po.id,
          po.QBO_Bill_Id__c,
          po.QBO_Bill__c,
          poAccountMap
        );
      }
    }
  }

  /*
        This function will remove the associated PDF report with purchase order on deletion of purchase order.
    */

  public static void removePoPDF(
    List<PurchaseOrder_LineItem__c> newOrders,
    Map<Id, PurchaseOrder_LineItem__c> oldOrdersMap
  ) {
    try {
      Set<Id> poOrderIds = oldOrdersMap.keySet();
      Set<String> poName = new Set<String>();
      List<PurchaseOrder_LineItem__c> lstPO = [
        SELECT Id, Name
        FROM PurchaseOrder_LineItem__c
        WHERE Id IN :poOrderIds
      ];
      for (PurchaseOrder_LineItem__c po : lstPO) {
        String name = 'PurchaseOrder#' + (String) po.Name;
        poName.add(name);
      }
      List<ContentDocument> lstContentDoc = [
        SELECT Id, title
        FROM ContentDocument
        WHERE title IN :poName
      ];
      if (lstContentDoc.size() != 0) {
        delete lstContentDoc;
      }
    } catch (Exception e) {
      System.debug('Error while removing the PDFs' + e);
    }
  }
}
