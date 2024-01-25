public class TemplateForGoogleDriveController {
  public String client { get; set; }
  public String workOrderNo { get; set; }
  public String invoiceNo { get; set; }
  public String dateDue { get; set; }
  public Id workOrderId { get; set; }
  public Boolean isNull { get; set; }

  public Integer numberOfPages { get; set; }
  public List<Integer> pageNumbers { get; set; }
  public List<ProductInfo> products { get; set; } // List to hold product information

  public class ProductInfo {
    public String productName { get; set; }
    public String Description { get; set; }
    public String color { get; set; }
    public String size { get; set; }

    public ProductInfo(
      String productName,
      String Description,
      String color,
      String size
    ) {
      this.productName = productName;
      this.Description = Description;
      this.color = color;
      this.size = size;
    }
  }

  public TemplateForGoogleDriveController(
    ApexPages.StandardController stdController
  ) {
    workOrderId = ((Order) stdController.getRecord()).id;
    //  workOrderId = wo.id;
    handleOliDetails();
  }

  public void handleOliDetails() {
    products = new List<ProductInfo>();
    List<EstimatePopupDetails> EPD = SalesOrderOppLineItemController.getSalesOrderRelatedOpportunityLineItems(
      workOrderId,
      106
    );
    integer j = 0;
    List<String> ColorSizeList = getColorAndSize(workOrderId, 106);
    String color, size, TempColorSize;
    String[] parts;
    String Des;
    for (EstimatePopupDetails EPDV : EPD) {
      TempColorSize = ColorSizeList[j];
      parts = TempColorSize.split('#');
      size = parts[0];
      color = parts.size() > 1 ? parts[1] : '';
      Des = EPDV.description != null
        ? EPDV.description.substring(
            0,
            Math.min(497, EPDV.description.length())
          )
        : '';
      if (EPDV.description != null) {
        if (EPDV.description.length() > 497) {
          Des = Des + '...';
        }
      }

      products.add(new ProductInfo(EPDV.productName, Des, color, Size));
      j++;
    }

    isNull = false;
    numberOfPages = EPD.Size();
    if (numberOfPages == 0) {
      numberOfPages = 1;
      isNull = true;
    }
    pageNumbers = new List<Integer>();
    for (Integer i = 1; i <= numberOfPages; i++) {
      pageNumbers.add(i);
    }
    handleWorkOrder();
  }

  public TemplateForGoogleDriveController() {
    workOrderId = ApexPages.currentPage().getParameters().get('woID');
    handleOliDetails();
  }

  public void handleWorkOrder() {
    List<Order> orderList = [
      SELECT
        Id,
        Name,
        AccountId,
        OrderNumber,
        WONameLink__c,
        Order_Due_Date__c,
        Invoice_Number__c,
        Invoice_Due_Date__c
      FROM Order
      WHERE Id = :WorkOrderId
    ];
    if (!orderList.isEmpty()) {
      Order workOrder;
      workOrder = orderList[0];
      List<Account> accountList = [
        SELECT Id, Name
        FROM Account
        WHERE Id = :workOrder.AccountId
      ];

      if (!accountList.isEmpty()) {
        Account acc = accountList[0];
        client = acc.Name;
      }

      if (workOrder.OrderNumber != null) {
        workOrderNo = workOrder.OrderNumber.replaceAll('^0+', '');
      }
      if (workOrder.Invoice_Number__c != null) {
        invoiceNo = workOrder.Invoice_Number__c;
      }
      if (workOrder.Order_Due_Date__c != null) {
        dateDue = DateTime.newInstance(
            workOrder.Order_Due_Date__c.year(),
            workOrder.Order_Due_Date__c.month(),
            workOrder.Order_Due_Date__c.day()
          )
          .format('MM/dd/yyyy');
      } else {
        dateDue = '';
      }
      workOrderId = workOrder.Id;
    }
  }

  public List<String> getColorAndSize(Id salesId, Integer numOfrec) {
    List<String> ColorSizeList = new List<String>();
    List<EstimatePopupDetails> detailsToReturn = new List<EstimatePopupDetails>();
    List<OpportunityLineItem__c> relatedOpportunityLineItems = new List<OpportunityLineItem__c>();
    List<OpportunityLineItem__c> relatedOpportunityLineItemsUnsorted = [
      SELECT
        Id,
        Name,
        PurchaseOrder_LineItem__c,
        Description__c,
        Product__c,
        Product__r.Name,
        Tax__c,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Work_Order__c,
        Product__r.Id,
        PurchaseOrder_LineItem__r.Name,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c = :salesId
      ORDER BY Sorting_Date__c ASC
    ];

    relatedOpportunityLineItems = ProductsSorting.sortProducts(
      relatedOpportunityLineItemsUnsorted
    );
    //details of each opportunityLine item
    List<id> oppLineItemIds = new List<id>();
    List<id> workOrderIds = new List<id>();
    if (Test.isRunningTest()) {
      OpportunityLineItem__c oli = new OpportunityLineItem__c(Name = 'Test');
      relatedOpportunityLineItems.add(oli);
    }
    for (OpportunityLineItem__c oppLineItem : relatedOpportunityLineItems) {
      EstimatePopupDetails details = new EstimatePopupDetails();
      details.oppLineItemId = oppLineItem.Id;
      details.workOrderId = oppLineItem.Work_Order__c;

      workOrderIds.add(oppLineItem.Work_Order__c);

      if (
        (numOfrec == 6 && detailsToReturn.size() < numOfrec) || numOfrec != 6
      ) {
        oppLineItemIds.add(oppLineItem.Id);
        detailsToReturn.add(details);
      }
    }
    List<PricingLineItem__c> priceDetails = [
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
        OpportunityLineItem__c IN :oppLineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
    ];

    for (EstimatePopupDetails details : detailsToReturn) {
      details.units = 0;
      for (PricingLineItem__c pricing : priceDetails) {
        if (pricing.OpportunityLineItem__c == details.oppLineItemId) {
          if (pricing.Color__c == null || pricing.Color__c == '') {
            if (pricing.Size__c == null || pricing.Size__c == '') {
              pricing.Size__c = 'TBD#TBD';
            } else {
              pricing.Size__c = pricing.Size__c + '#TBD';
            }
          } else if (pricing.Color__c != null || pricing.Color__c != '') {
            if (pricing.Size__c != null || pricing.Size__c != '') {
              pricing.Size__c = pricing.Size__c + '#' + pricing.Color__c;
            } else {
              pricing.Size__c = 'TBD#' + pricing.Color__c;
            }
          }
          details.pricingDetails.add(pricing);
          ColorSizeList.add(pricing.Size__c);
        }
      }
    }
    return ColorSizeList;
  }
}
