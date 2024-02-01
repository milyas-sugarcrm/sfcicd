public class PurchaseOrderPreviewController {
  private final PurchaseOrder_LineItem__c purchaseOrderLineItem;
  public String teamPhunEmail { get; set; }
  public String ProductionRepName { get; set; }
  public Decimal pageTotal { get; set; }
  public Decimal pageQuantity { get; set; }
  public PurchaseOrderPreviewController(
    ApexPages.StandardController stdController
  ) {
    this.purchaseOrderLineItem = (PurchaseOrder_LineItem__c) stdController.getRecord();
    this.pageTotal = 0;
    this.pageQuantity = 0;
    this.calculateTotalAndQuantity();
    this.teamPhunEmail = '';
    this.ProductionRepName = '';
    this.getOppLink();
  }
  public String getOppLink() {
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id, Production_Rep__c
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
    //system.debug('poLineItem  '+poLineItem.Shipping_Information__r.Name);
    if (relatedOpportunityLineItem.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Opportunity__c;
    } else if (relatedOpportunityLineItem.Estimate__r.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Estimate__r.Opportunity__c;
    } else if (relatedOpportunityLineItem.Work_Order__r.OpportunityId != null) {
      OpportunityId = relatedOpportunityLineItem.Work_Order__r.OpportunityId;
    }
    if (OpportunityId != null) {
      Opportunity opp = [
        SELECT Id, Name, AccountId, Owner.Email, Owner.Name
        FROM Opportunity
        WHERE Id = :OpportunityId
      ];
      //this.ownerEmail = opp.Owner.Email;
      this.teamPhunEmail = 'Email: info@teamphun.com';
      this.ProductionRepName = poLineItem.Production_Rep__c;
      return URL.getSalesforceBaseUrl().toExternalForm() +
        '/lightning/r/Opportunity/' +
        opp.Id +
        '/view';
    }

    return null;
  }
  public String getChangeStatus() {
    if (System.currentPagereference().getParameters().get('chang') == 'true') {
      return 'checked';
    } else
      return '';
  }
  public void approveRejectOrder() {
    try {
      PurchaseOrder_LineItem__c poLineItem = [
        SELECT
          OpportunityLineItem__c,
          Id,
          Approved_By__c,
          Approved_Date__c,
          Purchase_Order_Notes__c,
          Purchase_Order_Status__c,
          WO_Status__c
        FROM PurchaseOrder_LineItem__c
        WHERE Id = :purchaseOrderLineItem.Id
      ];

      poLineItem.Approved_By__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_by');
      poLineItem.Purchase_Order_Notes__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_notes');
      poLineItem.WO_Status__c = Apexpages.currentPage()
        .getParameters()
        .get('myStatus');
      poLineItem.Approved_Date__c = system.today();
      update poLineItem;
    } catch (Exception ex) {
      System.debug('exception --->>>>>' + ex.getStackTraceString());
    }
  }
  public Pagereference setApprove() {
    PageReference pageRef = Page.PurchaseOrderApproveChange;
    pageRef.getParameters().put('approv', 'true');
    return PageRef;
  }
  public Pagereference setChange() {
    PageReference pageRef = Page.PurchaseOrderApproveChange;
    pageRef.getParameters().put('chang', 'true');
    return PageRef;
  }
  @AuraEnabled
  public List<PurchaseOrderPreviewObject> getListOfPurchaseOrderLineItem() {
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
        SKU__c,
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
    List<ExtraChargesEstimate__c> extraPricingDetails = [
      SELECT
        Id,
        Name,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Title__c,
        Margin__c,
        Total__c,
        OpportunityLineItem__c,
        Display__c,
        Default__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :relatedOpportunityLineItem
      ORDER BY CreatedDate ASC
    ];
    List<PurchaseOrderPreviewObject> detailsToReturn = new List<PurchaseOrderPreviewObject>();
    // Map<Id, List<ExtraChargesEstimate__c>> extraPriceMap = new Map<Id, List<ExtraChargesEstimate__c>>();
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItem) {
      PurchaseOrderPreviewObject detail = new PurchaseOrderPreviewObject();
      detail.productLineItemName = oppLineItem.Name;

      // List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
      for (ExtraChargesEstimate__c extraPrice : extraPricingDetails) {
        if (extraPrice.OpportunityLineItem__c == oppLineItem.Id) {
          // extraPriceList.add(extraPrice);
          ProductDetailsPurchaseOrderPreview proExtraChargeDetails = new ProductDetailsPurchaseOrderPreview();
          proExtraChargeDetails.extra = true;
          proExtraChargeDetails.color = '';
          proExtraChargeDetails.SKU = '';
          proExtraChargeDetails.size = '';
          proExtraChargeDetails.extraChargeName = extraPrice.Title__c;
          proExtraChargeDetails.quantity = (extraPrice.Quantity__c == null
            ? 0
            : extraPrice.Quantity__c);
          proExtraChargeDetails.unitCost = (extraPrice.Net_Cost__c == null
            ? 0
            : extraPrice.Net_Cost__c);
          proExtraChargeDetails.totalCost =
            (proExtraChargeDetails.unitCost == null
              ? 0
              : proExtraChargeDetails.unitCost) *
            (proExtraChargeDetails.quantity == null
              ? 0
              : proExtraChargeDetails.quantity);
          detail.total += proExtraChargeDetails.totalCost;
          detail.productExtraChargesDetails.add(proExtraChargeDetails);
        }
      }
      if (detail.productExtraChargesDetails.size() > 0) {
        detail.extra = true;
      }
      for (PricingLineItem__c price : pricingDetails) {
        if (price.OpportunityLineItem__c == oppLineItem.Id) {
          ProductDetailsPurchaseOrderPreview proDetails = new ProductDetailsPurchaseOrderPreview();
          proDetails.color = price.Color__c;
          proDetails.SKU = oppLineItem.SKU__c;
          proDetails.size = price.Size__c;
          proDetails.quantity = (price.Estimated_Quantity__c == null
            ? 0
            : price.Estimated_Quantity__c);
          proDetails.unitCost = (price.Net_Cost__c == null
            ? 0
            : price.Net_Cost__c);
          proDetails.extraChargeName = '';
          proDetails.totalCost = proDetails.unitCost * proDetails.quantity;
          detail.quantity += price.Quantity__c;
          detail.total += proDetails.totalCost;
          detail.productDetails.add(proDetails);
        }
      }

      detailsToReturn.add(detail);
    }
    return detailsToReturn;
  }
  public void calculateTotalAndQuantity() {
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
        SKU__c,
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
    List<ExtraChargesEstimate__c> extraPricingDetails = [
      SELECT
        Id,
        Name,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        OpportunityLineItem__c,
        Display__c,
        Default__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :relatedOpportunityLineItem
      ORDER BY CreatedDate ASC
    ];

    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItem) {
      PurchaseOrderPreviewObject detail = new PurchaseOrderPreviewObject();

      for (PricingLineItem__c price : pricingDetails) {
        if (price.OpportunityLineItem__c == oppLineItem.Id) {
          pageTotal +=
            (price.Net_Cost__c == null ? 0 : price.Net_Cost__c) *
            (price.Estimated_Quantity__c == null
              ? 0
              : price.Estimated_Quantity__c);
          pageQuantity += (price.Estimated_Quantity__c == null
            ? 0
            : price.Estimated_Quantity__c);
        }
      }
      for (ExtraChargesEstimate__c extraPrice : extraPricingDetails) {
        if (extraPrice.OpportunityLineItem__c == oppLineItem.Id) {
          pageTotal +=
            (extraPrice.Net_Cost__c == null ? 0 : extraPrice.Net_Cost__c) *
            (extraPrice.Quantity__c == null ? 0 : extraPrice.Quantity__c);
        }
      }
    }
  }
  @AuraEnabled
  public EstimatePopupDetails getShippingDetails() {
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
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
        Shipping_Information__r.Name,
        PurchaseOrder_LineItem__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];

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
          Firm__c,
          Client_Address__c,
          Shipping_Method__c,
          Company_Address__c,
          Client_Shipping_Address__c,
          Other_Address__c
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
      [
        SELECT Id, Name, Address__c
        FROM CompAddress__c
        WHERE id IN :compAdressIds
      ]
    );

    details.shippingInformationDetails = shippinginfoMap.get(
      details.oppLineItemId
    );
    //details.shippingInfoAddress = shippinginfoMap.get(details.oppLineItemId).Shipping_Information__r.Name;

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
    details.shippingName = shippinginfoMap.get(details.oppLineItemId).Name;
    details.shippingShipTo = shippinginfoMap.get(details.oppLineItemId)
      .Ship_To__c;
    if (
      compAddresses.get(
        shippinginfoMap.get(details.oppLineItemId).Company_Address__c
      ) != null
    ) {
      details.shippingCompany = compAddresses.get(
          shippinginfoMap.get(details.oppLineItemId).Company_Address__c
        )
        .Name;
    }

    return details;
  }

  @AuraEnabled
  public String getShippingFirm() {
    system.debug('I am in get shipping firm function: ');
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT OpportunityLineItem__c, Id
      FROM PurchaseOrder_LineItem__c
      WHERE Id = :purchaseOrderLineItem.Id
    ];
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    relatedOpportunityLineItem = [
      SELECT Id, Shipping_Information__r.Id
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];
    Shipping_Information__c shippingInformation = [
      SELECT Id, Name, In_Hands_Date__c, Ship_To__c, Firm__c
      FROM Shipping_Information__c
      WHERE Id = :relatedOpportunityLineItem.Shipping_Information__r.Id
    ];
    if (shippingInformation.Firm__c == true) {
      system.debug('RETUENNNNNNNNNNNNNNNNNNN YESSSSSSSSSSSSSSSSS');
      return 'Yes';
    } else {
      system.debug('RETUENNNNNNNNNNNNNNNNNNN NOOOOOOOOOOOOOOOOOOOOOOO');
      return 'No';
    }
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

  public Account getAccountDetails() {
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT
        OpportunityLineItem__c,
        Id,
        Work_Order__c,
        Work_Order__r.Account_Name__c
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
        SELECT Id, Name, AccountId
        FROM Opportunity
        WHERE Id = :OpportunityId
      ];
      Account accountDetailsToReturn = [
        SELECT
          Id,
          Name,
          AccountNumber,
          Phone,
          Team_Phun_Account_Number__c,
          OwnerId
        FROM Account
        WHERE Id = :opp.AccountId
      ];
      system.debug('Account detailssssssssssssssssssssss are : ');
      system.debug(accountDetailsToReturn);
      return accountDetailsToReturn;
    }
    return null;
  }
  public String getOpportunityName() {
    OpportunityLineItem__c relatedOpportunityLineItem = new OpportunityLineItem__c();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT
        OpportunityLineItem__c,
        Id,
        Work_Order__c,
        Work_Order__r.OrderNumber
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
    String workOrderNumber;
    Id OpportunityId;
    if (poLineItem.Work_Order__r.OrderNumber != null) {
      workOrderNumber = poLineItem.Work_Order__r.OrderNumber;
    }
    if (relatedOpportunityLineItem.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Opportunity__c;
    } else if (relatedOpportunityLineItem.Estimate__r.Opportunity__c != null) {
      OpportunityId = relatedOpportunityLineItem.Estimate__r.Opportunity__c;
    } else if (relatedOpportunityLineItem.Work_Order__r.OpportunityId != null) {
      OpportunityId = relatedOpportunityLineItem.Work_Order__r.OpportunityId;
    }

    /*
        if(OpportunityId != null)
        {
            Opportunity opp = [SELECT Id,Name,AccountId 
                               FROM Opportunity
                               WHERE Id =: OpportunityId];
            return opp.Name; 
        }
		*/
    return workOrderNumber;
  }
  public PurchaseOrder_LineItem__c getPODetail() {
    PurchaseOrder_LineItem__c purchaseOrderLineItem = [
      SELECT
        WO_Status__c,
        Approved_By__c,
        Approved_Date__c,
        PurchaseOrder__r.Purchase_Order_Date__c,
        Production_Rep__c,
        Purchase_Order_Status__c,
        CreatedDate,
        PurchaseOrder__r.Project__c,
        OpportunityLineItem__c,
        Id
      FROM PurchaseOrder_LineItem__c
      WHERE id = :purchaseOrderLineItem.id
    ];
    if (purchaseOrderLineItem.Approved_Date__c != null) {
      purchaseOrderLineItem.Production_Rep__c = purchaseOrderLineItem.Approved_Date__c.format(
        'dd-MM-yyyy'
      );
    }
    return purchaseOrderLineItem;
  }
  public String getSupplierName() {
    try {
      PurchaseOrder_LineItem__c POLineItem = [
        SELECT
          Shipping_Information__c,
          Shipping_Information__r.Supplier__c,
          Shipping_Information__r.Supplier__r.Name,
          Shipping_Information__r.Supplier__r.BillingAddress
        FROM PurchaseOrder_LineItem__c
        WHERE Id = :purchaseOrderLineItem.Id
      ];

      string supplierName = POLineItem.Shipping_Information__r.Supplier__r.Name;
      return supplierName;
    } catch (Exception ex) {
      System.debug('Exception----->>>>>>>>>' + ex.getStackTraceString());
      return null;
    }
  }

  public String getSupplierAddress() {
    try {
      PurchaseOrder_LineItem__c POLineItem = [
        SELECT
          Shipping_Information__c,
          Shipping_Information__r.Supplier__c,
          Shipping_Information__r.Supplier__r.Name,
          Shipping_Information__r.Supplier__r.BillingAddress
        FROM PurchaseOrder_LineItem__c
        WHERE Id = :purchaseOrderLineItem.Id
      ];

      string vendorDetails =
        POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getStreet() +
        ',' +
        POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getCity() +
        ', ' +
        POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getState() +
        ', ' +
        POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getPostalCode() +
        ', ';
      if (
        (POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getCountryCode()) !=
        null
      ) {
        vendorDetails =
          vendorDetails +
          POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getCountryCode() +
          ', ';
      }
      vendorDetails =
        vendorDetails +
        POLineItem.Shipping_Information__r.Supplier__r.BillingAddress.getCountry();
      return vendorDetails;
    } catch (Exception ex) {
      System.debug('Exception----->>>>>>>>>' + ex.getStackTraceString());
      return null;
    }
  }
}
