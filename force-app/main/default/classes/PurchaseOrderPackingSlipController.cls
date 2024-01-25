public class PurchaseOrderPackingSlipController {
  private final PurchaseOrder_LineItem__c purchaseOrderLineItem;

  public PurchaseOrderPackingSlipController(
    ApexPages.StandardController stdController
  ) {
    this.purchaseOrderLineItem = (PurchaseOrder_LineItem__c) stdController.getRecord();
  }
  @AuraEnabled
  public Decimal getQuantityValue() {
    List<OpportunityLineItem__c> relatedOpportunityLineItem = new List<OpportunityLineItem__c>();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    relatedOpportunityLineItem = [
      SELECT
        Id,
        Name,
        Work_Order__r.OpportunityId,
        Opportunity__c,
        Estimate__r.Opportunity__c,
        PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
    ];

    List<PricingLineItem__c> pricingDetails = [
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
        OpportunityLineItem__c,
        Display__c,
        Default__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c = :relatedOpportunityLineItem
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    Decimal quantity = 0;
    for (PricingLineItem__c price : pricingDetails) {
      quantity += price.Estimated_Quantity__c;
    }
    return quantity;
  }
  @AuraEnabled
  public List<PackingSlipObject> getListOfPurchaseOrderLineItem() {
    List<OpportunityLineItem__c> relatedOpportunityLineItem = new List<OpportunityLineItem__c>();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    relatedOpportunityLineItem = [
      SELECT
        Id,
        Name,
        Work_Order__r.OpportunityId,
        Opportunity__c,
        Estimate__r.Opportunity__c,
        PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
    ];

    List<PricingLineItem__c> pricingDetails = [
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
        OpportunityLineItem__c,
        Display__c,
        Default__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c = :relatedOpportunityLineItem
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    List<PackingSlipObject> detailsToReturn = new List<PackingSlipObject>();
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItem) {
      PackingSlipObject detail = new PackingSlipObject();
      detail.productLineItemName = oppLineItem.Name;
      for (PricingLineItem__c price : pricingDetails) {
        if (price.OpportunityLineItem__c == oppLineItem.Id) {
          ProductDetailsForPackingSlip proDetails = new ProductDetailsForPackingSlip();
          proDetails.color = price.Color__c;
          proDetails.size = price.Size__c;
          proDetails.quantity = price.Estimated_Quantity__c;
          detail.productDetails.add(proDetails);
        }
      }
      detailsToReturn.add(detail);
    }
    system.debug(detailsToReturn);
    return detailsToReturn;
  }
  @AuraEnabled
  public String getPurchaseOrderNumber() {
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id, Name
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    return poLineItem.Name;
  }
  @AuraEnabled
  public String getOpportunityName() {
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    relatedOpportunityLineItem = [
      SELECT
        Id,
        Work_Order__r.OpportunityId,
        Opportunity__c,
        Estimate__r.Opportunity__c,
        PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];
    Id OpportunityId;
    if (relatedOpportunityLineItem.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Opportunity__c;
    } else if (relatedOpportunityLineItem.Estimate__r.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Estimate__r.Opportunity__c;
    } else if (relatedOpportunityLineItem.Work_Order__r.OpportunityId != null) {
      OpportunityId = relatedOpportunityLineItem.Work_Order__r.OpportunityId;
    }
    if (OpportunityId != null) {
      Opportunity opp = [
        SELECT Id, Name
        FROM Opportunity
        WHERE Id = :OpportunityId
      ];
      return opp.Name;
    }
    return null;
  }
  @AuraEnabled
  public String getAddress() {
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    relatedOpportunityLineItem = [
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
        PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];
    //details of each opportunityLine item
    EstimatePopupDetails details = new EstimatePopupDetails();
    details.oppLineItemId = relatedOpportunityLineItem.Id;
    Map<Id, Shipping_Information__c> shippinginfoMap = new Map<Id, Shipping_Information__c>();
    Map<Id, Shipping_Information__c> shippingInformation = new Map<Id, Shipping_Information__c>(
      [
        SELECT
          Id,
          Name,
          In_Hands_Date__c,
          Ship_To__c,
          Client_Shipping_Address__c,
          Other_Address__c,
          Client_Address__c,
          Shipping_Method__c,
          Company_Address__c
        FROM Shipping_Information__c
        WHERE Id = :relatedOpportunityLineItem.Shipping_Information__r.Id
      ]
    );
    for (Shipping_Information__c shipinfo : shippingInformation.values()) {
      if (relatedOpportunityLineItem.Shipping_Information__c == shipinfo.Id) {
        shippinginfoMap.put(relatedOpportunityLineItem.Id, shipinfo);
        break;
      }
    }
    List<Shipping__c> shippings = [
      SELECT
        Id,
        Name,
        In_Hands_Date__c,
        Ship_To__c,
        ShipInformation__c,
        Decorator_Shipping_Address__c,
        Other_Supplier_Address__c,
        Client_Shipping_Address__c,
        Client_Address__c,
        Shipping_Method__c,
        Company_Address__c,
        Decorator_Address__c,
        Supplier_Address__c
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
      shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Other Supplier'
    ) {
      details.shippingInfoAddress = shippingMap.get(
          shippinginfoMap.get(details.oppLineItemId).Id
        )
        .Other_Supplier_Address__c;
    } else if (
      shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Decorator'
    ) {
      details.shippingDetails = shippingMap.get(
        shippinginfoMap.get(details.oppLineItemId).Id
      );
      details.shippingInfoAddress = shippingMap.get(
          shippinginfoMap.get(details.oppLineItemId).Id
        )
        .Decorator_Shipping_Address__c;
    } else if (
      shippinginfoMap.get(details.oppLineItemId).Ship_To__c == 'Other'
    ) {
      details.shippingInfoAddress = shippinginfoMap.get(details.oppLineItemId)
        .Other_Address__c;
    }
    system.debug(details.shippingInfoAddress);
    return details.shippingInfoAddress;
  }
}
