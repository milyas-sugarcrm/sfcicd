public class OpportunityDepositInvoiceController {
  private final Order order;
  public String ownerEmail { get; set; }
  public String ownerName { get; set; }
  private decimal SubTotal = 0;
  public OpportunityDepositInvoiceController(
    ApexPages.StandardController stdController
  ) {
    this.order = (Order) stdController.getRecord();
    this.getOpportunity();
  }
  public String getBillingAddress() {
    Order ord = [SELECT Id, OpportunityId FROM Order WHERE id = :order.id];
    Opportunity opportunity = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE id = :ord.OpportunityId
    ];
    Account account = [
      SELECT
        Id,
        Name,
        billingstreet,
        billingcity,
        billingstate,
        billingPostalCode,
        BillingCountry
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    String address;
    if (account.billingstreet != null) {
      address = account.billingstreet;
    }
    if (account.billingcity != null) {
      if (address != null) {
        address = address + '<br/>' + account.billingcity;
      } else
        address = account.billingcity;
    }
    if (account.billingstate != null) {
      if (address != null) {
        address =
          address +
          ', ' +
          account.billingstate +
          ' ' +
          account.billingPostalCode;
      } else
        address = account.billingstate + ' ' + account.billingPostalCode;
    }
    if (account.BillingCountry != null) {
      if (address != null) {
        address = address + '<br/>' + account.BillingCountry;
      } else
        address = account.BillingCountry;
    }
    return address;
  }
  public String getShippingAddress() {
    Order ord = [SELECT Id, OpportunityId FROM Order WHERE id = :order.id];
    Opportunity opportunity = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE id = :ord.OpportunityId
    ];
    Account account = [
      SELECT
        Id,
        shippingstreet,
        shippingcity,
        shippingstate,
        shippingPostalCode,
        shippingCountry
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    String address;
    if (account.shippingstreet != null) {
      address = account.shippingstreet;
    }
    if (account.shippingcity != null) {
      if (address != null) {
        address = address + '<br/>' + account.shippingcity;
      } else
        address = account.shippingcity;
    }
    if (account.shippingstate != null) {
      if (address != null) {
        address =
          address +
          ', ' +
          account.shippingstate +
          ' ' +
          account.shippingPostalCode;
      } else
        address = account.shippingstate + ' ' + account.shippingPostalCode;
    }
    if (account.shippingCountry != null) {
      if (address != null) {
        address = address + '<br/>' + account.shippingCountry;
      } else
        address = account.shippingCountry;
    }
    return address;
  }
  public Order getSalesOrderDetails() {
    Order order = [
      SELECT
        Id,
        OrderNumber,
        Invoice_Number__c,
        Invoice_Tax__c,
        Approved_Date__c,
        Approved_By__c,
        Sale_Order_Status__c,
        EffectiveDate,
        Invoice_Terms__c,
        PoNumber
      FROM Order
      WHERE id = :order.id
    ];
    return order;
  }
  public Deposit_Invoice__c getDepositDetails() {
    Order order = [
      SELECT Id, Deposit_Invoice__c
      FROM Order
      WHERE id = :order.id
    ];
    List<Deposit_Invoice__c> depositDetails = [
      SELECT id, Deposit_Percent__c, Deposit_Amount__c
      FROM Deposit_Invoice__c
      WHERE id = :order.Deposit_Invoice__c
    ];
    if (depositDetails != null && depositDetails.size() > 0) {
      return depositDetails[0];
    }
    return null;
  }
  public List<OpportunityDepositInvoice> getLineItemsList() {
    System.debug('In getLineItems');
    List<OpportunityDepositInvoice> LineItemsList = new List<OpportunityDepositInvoice>();
    List<OpportunityLineItem__c> lineItemDetails = [
      SELECT
        id,
        Name,
        Estimate__r.id,
        Quantity_Estimate__c,
        Description__c,
        Work_Order__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :order.id
    ];
    List<Id> ids = new List<String>();
    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      ids.add(lineItems.id);
    }
    List<PricingLineItem__c> pricing = [
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
        OpportunityLineItem__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :ids
        AND Display__c = TRUE
        AND Default__c = FALSE
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
      Integer count = 1;
      Map<Decimal, PricingLineItem__c> pricingMap = new Map<Decimal, PricingLineItem__c>();
      for (PricingLineItem__c pricingList : pricing) {
        if (pricingList.OpportunityLineItem__c == lineItems.id) {
          if (
            !pricingMap.containsKey(
              ((pricingList.Retail_Price__c == null)
                ? 0
                : pricingList.Retail_Price__c)
            )
          ) {
            pricingMap.put(
              ((pricingList.Retail_Price__c == null)
                ? 0
                : pricingList.Retail_Price__c),
              pricingList
            );
          } else {
            PricingLineItem__c price = pricingMap.get(
              pricingList.Retail_Price__c
            );
            price.Estimated_Quantity__c =
              ((price.Estimated_Quantity__c == null)
                ? 0
                : price.Estimated_Quantity__c) +
              ((pricingList.Estimated_Quantity__c == null)
                ? 0
                : pricingList.Estimated_Quantity__c);
            price.Total__c =
              ((price.Total__c == null) ? 0 : price.Total__c) +
              (((pricingList.Estimated_Quantity__c == null)
                ? 0
                : pricingList.Estimated_Quantity__c) *
              ((pricingList.Retail_Price__c == null)
                ? 0
                : pricingList.Retail_Price__c));
          }
        }
      }
      for (Decimal key : pricingMap.keySet()) {
        lItems.lineItemPricingAmount =
          lItems.lineItemPricingAmount +
          ((pricingMap.get(key).Total__c == null)
            ? 0
            : pricingMap.get(key).Total__c);
        if (count == 1) {
          pricingMap.get(key).Size__c = lineItems.Name;
          count++;
        } else {
          pricingMap.get(key).Size__c = '';
        }
        lItems.lineItemPricings.add(pricingMap.get(key));
      }

      SubTotal = SubTotal + lItems.lineItemPricingAmount;
      for (ExtraChargesEstimate__c chargesList : extraCharges) {
        if (chargesList.OpportunityLineItem__c == lineItems.id) {
          if (chargesList.Net_Cost__c == null) {
            chargesList.Net_Cost__c = 0;
          }
          if (chargesList.Total__c == null) {
            chargesList.Total__c =
              chargesList.Net_Cost__c * chargesList.Quantity__c;
          }
          SubTotal = SubTotal + chargesList.Total__c;
          lItems.lineItemExtraCharges.add(chargesList);
        }
      }
      LineItemsList.add(lItems);
    }
    System.debug('LineItemsList: ' + LineItemsList);
    return LineItemsList;
  }
  public String getOppLink() {
    Order ord = [SELECT Id, OpportunityId FROM Order WHERE id = :order.id];
    return URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/r/Opportunity/' +
      ord.OpportunityId +
      '/view';
  }
  public Opportunity getOpportunity() {
    Order ord = [SELECT Id, OpportunityId FROM Order WHERE id = :order.id];
    Opportunity opportunity = [
      SELECT Id, Name, Owner.Name, Owner.Email
      FROM Opportunity
      WHERE id = :ord.OpportunityId
    ];
    this.ownerEmail = opportunity.owner.Email;
    this.ownerName = opportunity.owner.Name;
    return opportunity;
  }
  public decimal getSubTotal() {
    return SubTotal;
  }

  public decimal getTotalPlusTax() {
    decimal tax = ((getSalesOrderDetails().Invoice_Tax__c) / 100) * SubTotal;
    return (SubTotal + tax).SetScale(2);
  }
}
