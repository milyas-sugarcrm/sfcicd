public with sharing class OppDepositInvoiceActionController {
  @AuraEnabled
  public static DepositInvoiceObject getTotal(
    String recId,
    String valuesAndIds
  ) {
    try {
      DepositInvoiceObject depositInvoice = (DepositInvoiceObject) System.JSON.deserializeStrict(
        valuesAndIds,
        DepositInvoiceObject.class
      );
      decimal total = getTotalPlusTax(recId);
      saveDepositInfo(
        recId,
        depositInvoice.deposit_percent,
        total,
        depositInvoice.Allow_credit_card,
        depositInvoice.amount_recieved,
        depositInvoice.confirmation,
        depositInvoice.date_recieved
      );
      depositInvoice.depositInvoicePreview =
        URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/OpportunitySalesOrderDepositInvoice?id=' +
        recId;
      depositInvoice.total = total;
      return depositInvoice;
    } catch (Exception ex) {
      System.debug(
        'Error in deposit nvoice -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
  @AuraEnabled
  public static void saveDepositInfo(
    String recId,
    decimal depositPercent,
    decimal total,
    Boolean creditCardAllowed,
    decimal amountRecieved,
    String confirmation,
    String DateReceived
  ) {
    List<Order> orders = [
      SELECT id, Deposit_Invoice__c, OpportunityId
      FROM Order
      WHERE id = :recId AND Deposit_Invoice__c != NULL
    ];
    if (orders.size() > 0) {
      for (Order order : orders) {
        Deposit_Invoice__c depositInfo = [
          SELECT
            id,
            Allow_credit_card__c,
            Amount_Received__c,
            Confirmation__c,
            Date_Received__c,
            Deposit_Amount__c,
            Deposit_Percent__c
          FROM Deposit_Invoice__c
          WHERE id = :order.Deposit_Invoice__c
        ];

        depositInfo.Allow_credit_card__c = creditCardAllowed;
        depositInfo.Amount_Received__c = amountRecieved;
        depositInfo.Confirmation__c = confirmation;
        depositInfo.Deposit_Percent__c = depositPercent;
        depositInfo.Deposit_Amount__c = ((depositPercent / 100) * total);
        depositInfo.Date_Received__c = DateReceived;
        update depositInfo;
        break;
      }
    } else {
      Order order = [
        SELECT id, Deposit_Invoice__c, OpportunityId
        FROM Order
        WHERE id = :recId
      ];
      Deposit_Invoice__c depositInfo = new Deposit_Invoice__c();

      depositInfo.Allow_credit_card__c = creditCardAllowed;
      depositInfo.Amount_Received__c = amountRecieved;
      depositInfo.Confirmation__c = confirmation;
      depositInfo.Deposit_Percent__c = depositPercent;
      depositInfo.Deposit_Amount__c = ((depositPercent / 100) * total);
      depositInfo.Date_Received__c = DateReceived;

      insert depositInfo;
      order.Deposit_Invoice__c = depositInfo.id;
      update order;
    }
  }
  public static decimal getTotalPlusTax(String recId) {
    decimal subTotal = getLineItemsList(recId);
    decimal tax =
      ((getSalesOrderDetails(recId).Invoice_Tax__c) / 100) * subTotal;
    return (subTotal + tax);
  }
  public static Order getSalesOrderDetails(String recId) {
    Order order = [
      SELECT
        Id,
        Invoice_Number__c,
        Invoice_Tax__c,
        Approved_Date__c,
        Approved_By__c,
        Sale_Order_Status__c,
        EffectiveDate,
        Invoice_Terms__c,
        PoNumber
      FROM Order
      WHERE id = :recId
    ];
    return order;
  }
  public static decimal getLineItemsList(String orderId) {
    decimal SubTotal = 0;
    System.debug('In getLineItems');
    List<OpportunityDepositInvoice> LineItemsList = new List<OpportunityDepositInvoice>();
    List<OpportunityLineItem__c> lineItemDetails = [
      SELECT id, Name, Estimate__r.id, Quantity_Estimate__c, Work_Order__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :orderId
    ];
    List<Id> ids = new List<String>();
    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      ids.add(lineItems.id);
    }
    List<PricingLineItem__c> pricing = [
      SELECT
        OpportunityLineItem__c,
        Margin__c,
        Quantity__c,
        Net_Cost__c,
        Show_To_Client__c
      FROM PricingLineItem__c
      WHERE OpportunityLineItem__c IN :ids AND Show_To_Client__c = TRUE
    ];

    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Name,
        Title__c,
        Default__c,
        Charge_Type__c,
        Net_Cost__c,
        Quantity__c,
        OpportunityLineItem__c,
        Total__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      OpportunityDepositInvoice lItems = new OpportunityDepositInvoice();
      lItems.name = lineItems.Name;
      Double previousPriceQauntity = 0;
      Double previousNetCost = 0;
      Double previousMargin = 0;
      Double priceMargin = 0;
      for (PricingLineItem__c pricingList : pricing) {
        if (pricingList.OpportunityLineItem__c == lineItems.id) {
          if (pricingList.Quantity__c == lineItems.Quantity_Estimate__c) {
            priceMargin = pricingList.Margin__c;
            lItems.lineItemQuantity = pricingList.Quantity__c;
            lItems.lineItemPricing = pricingList.Net_Cost__c;
            lItems.lineItemPricingAmount =
              pricingList.Quantity__c * pricingList.Net_Cost__c;
            break;
          } else if (
            (previousPriceQauntity != 0 && previousNetCost != 0) &&
            (lineItems.Quantity_Estimate__c > previousPriceQauntity &&
            lineItems.Quantity_Estimate__c < pricingList.Quantity__c)
          ) {
            priceMargin = previousMargin;
            lItems.lineItemQuantity = previousPriceQauntity;
            lItems.lineItemPricing = previousNetCost;
            lItems.lineItemPricingAmount =
              lItems.lineItemQuantity * lItems.lineItemPricing;
            break;
          }
          previousMargin = pricingList.Margin__c;
          previousPriceQauntity = pricingList.Quantity__c;
          previousNetCost = pricingList.Net_Cost__c;
        }
      }
      if (lItems.lineItemQuantity == null) {
        priceMargin = previousMargin;
        lItems.lineItemQuantity = previousPriceQauntity;
        lItems.lineItemPricing = previousNetCost;
        lItems.lineItemPricingAmount =
          lItems.lineItemQuantity * lItems.lineItemPricing;
      }
      SubTotal = SubTotal + lItems.lineItemPricingAmount;
      for (ExtraChargesEstimate__c chargesList : extraCharges) {
        if (chargesList.OpportunityLineItem__c == lineItems.id) {
          if (chargesList.Total__c == null) {
            chargesList.Total__c =
              chargesList.Net_Cost__c * chargesList.Quantity__c;
          }
          SubTotal = SubTotal + chargesList.Total__c;
        }
      }
    }
    return SubTotal;
  }
}
