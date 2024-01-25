global class VendorAccountsScheduler implements schedulable {
  global void execute(SchedulableContext stx) {
    calculateMTDFields();
    calculateFMFields();
    calculateYTDFields();
    calculateFYFields();
    calculateQTDFields();
    calculateFQFields();
  }

  public static map<String, Decimal> getSum(List<Order> workOrders) {
    List<Id> workOrderIds = new List<Id>();
    List<Id> oppLineItemIds = new List<Id>();
    map<String, Decimal> totalPriceExtraCharge = new Map<String, Decimal>();
    map<String, Decimal> totalSum = new Map<String, Decimal>();

    for (Order workOrder : workOrders) {
      workOrderIds.add(workOrder.Id);
    }
    List<OpportunityLineItem__c> relatedOppLineItems = [
      SELECT Id, Work_Order__c, Product__c, Account__c, Total__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :workOrderIds
    ];

    for (OpportunityLineItem__c opp : relatedOppLineItems) {
      oppLineItemIds.add(opp.Id);
    }

    List<PricingLineItem__c> relatedPricingToOppLineItem = [
      SELECT
        OpportunityLineItem__c,
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
        Default__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :oppLineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
    ];

    List<ExtraChargesEstimate__c> relatedExtraChargeToOppLineItem = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem_ArtWork__r.Id,
        OpportunityLineItem_ArtWork__r.Title__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
      ORDER BY CreatedDate ASC
    ];
    for (PricingLineItem__c pricing : relatedPricingToOppLineItem) {
      if (totalPriceExtraCharge.get(pricing.OpportunityLineItem__c) != null) {
        totalPriceExtraCharge.put(
          pricing.OpportunityLineItem__c,
          (totalPriceExtraCharge.get(pricing.OpportunityLineItem__c) == null
            ? 0
            : totalPriceExtraCharge.get(pricing.OpportunityLineItem__c)) +
          (pricing.Total__c == null ? 0 : pricing.Total__c)
        );
      } else {
        totalPriceExtraCharge.put(pricing.OpportunityLineItem__c, 0);
        totalPriceExtraCharge.put(
          pricing.OpportunityLineItem__c,
          (totalPriceExtraCharge.get(pricing.OpportunityLineItem__c) == null
            ? 0
            : totalPriceExtraCharge.get(pricing.OpportunityLineItem__c)) +
          (pricing.Total__c == null ? 0 : pricing.Total__c)
        );
      }
    }

    for (
      ExtraChargesEstimate__c extraCharge : relatedExtraChargeToOppLineItem
    ) {
      if (
        totalPriceExtraCharge.get(extraCharge.OpportunityLineItem__c) != null
      ) {
        totalPriceExtraCharge.put(
          extraCharge.OpportunityLineItem__c,
          (totalPriceExtraCharge.get(extraCharge.OpportunityLineItem__c) == null
            ? 0
            : totalPriceExtraCharge.get(extraCharge.OpportunityLineItem__c)) +
          (extraCharge.Total__c == null ? 0 : extraCharge.Total__c)
        );
      } else {
        totalPriceExtraCharge.put(extraCharge.OpportunityLineItem__c, 0);
        totalPriceExtraCharge.put(
          extraCharge.OpportunityLineItem__c,
          (totalPriceExtraCharge.get(extraCharge.OpportunityLineItem__c) == null
            ? 0
            : totalPriceExtraCharge.get(extraCharge.OpportunityLineItem__c)) +
          (extraCharge.Total__c == null ? 0 : extraCharge.Total__c)
        );
      }
    }

    for (OpportunityLineItem__c opp : relatedOppLineItems) {
      if (opp.Account__c != null) {
        if (totalSum.get(opp.Account__c) != null) {
          Decimal exitingEntry = totalSum.get(opp.Account__c);
          totalSum.put(
            opp.Account__c,
            (exitingEntry == null ? 0 : exitingEntry) +
            (totalPriceExtraCharge.get(opp.Id) == null
              ? 0
              : totalPriceExtraCharge.get(opp.Id))
          );
        } else {
          totalSum.put(opp.Account__c, 0);
          totalSum.put(
            opp.Account__c,
            totalPriceExtraCharge.get(opp.Id) == null
              ? 0
              : totalPriceExtraCharge.get(opp.Id)
          );
        }
      }
    }
    return totalSum;
  }

  public static map<String, Decimal> getVariance(
    map<String, Decimal> totalSum,
    map<String, Decimal> totalSumVariance
  ) {
    Map<String, Decimal> variance = new Map<String, Decimal>();
    for (String key : totalSum.keySet()) {
      if (totalSumVariance.get(key) != null && totalSumVariance.get(key) != 0) {
        Decimal res = totalSum.get(key) == null
          ? 0
          : totalSum.get(key) / totalSumVariance.get(key);
        variance.put(key, res);
      }
    }
    return variance;
  }

  public static void calculateMTDFields() {
    try {
      Date currentDate = System.Date.today();
      Date startDate = currentDate.toStartOfMonth();
      Date previousYearCurrentDate = System.Date.today().addMonths(-12);
      Date previousYearStartDate = previousYearCurrentDate.toStartOfMonth();

      List<Order> orderListMTD = getOrders(startDate, currentDate);
      List<Order> orderListMTDVariance = getOrders(
        previousYearStartDate,
        previousYearCurrentDate
      );
      map<String, Decimal> totalSum = getSum(orderListMTD);
      map<String, Decimal> totalSumVariance = getSum(orderListMTDVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstMTD = [
        SELECT Id, MTD_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstMTD) {
        acc.MTD_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.MTD_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }

      update accountLstMTD;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateMTDFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static void calculateFMFields() {
    try {
      Date startDate = System.Date.today().toStartOfMonth();
      Date endDate = startDate.addMonths(1).addDays(-1);
      Date previousYearStartDate = startDate.addMonths(-12);
      Date previousYearEndDate = previousYearStartDate.addMonths(1).addDays(-1);

      List<Order> orderListFM = getOrders(startDate, endDate);
      List<Order> orderListFMVariance = getOrders(
        previousYearStartDate,
        previousYearEndDate
      );
      map<String, Decimal> totalSum = getSum(orderListFM);
      map<String, Decimal> totalSumVariance = getSum(orderListFMVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstFM = [
        SELECT Id, FM_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstFM) {
        acc.FM_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.FM_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }
      update accountLstFM;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateFMFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static void calculateYTDFields() {
    try {
      Date yearStartDate = Date.newInstance(System.date.today().Year(), 1, 1);
      Date yearCurrentDate = System.date.today();
      Date previousYearStartDate = Date.newInstance(
        System.date.today().Year() - 1,
        1,
        1
      );
      Date previousYearCurrentDate = System.date.today().addMonths(-12);

      List<Order> orderListYTD = getOrders(yearStartDate, yearCurrentDate);
      List<Order> orderListYTDVariance = getOrders(
        previousYearStartDate,
        previousYearCurrentDate
      );
      map<String, Decimal> totalSum = getSum(orderListYTD);
      map<String, Decimal> totalSumVariance = getSum(orderListYTDVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstYTD = [
        SELECT Id, YTD_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstYTD) {
        acc.YTD_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.YTD_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }

      update accountLstYTD;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateYTDFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static void calculateFYFields() {
    try {
      Date yearStartDate = Date.newInstance(System.date.today().Year(), 1, 1);
      Date yearEndDate = yearStartDate.addMonths(12).addDays(-1);
      Date previousYearStartDate = Date.newInstance(
        System.date.today().Year() - 1,
        1,
        1
      );
      Date previousYearEndDate = previousYearStartDate.addMonths(12)
        .addDays(-1);

      List<Order> orderListFY = getOrders(yearStartDate, yearEndDate);
      List<Order> orderListFYVariance = getOrders(
        previousYearStartDate,
        previousYearEndDate
      );
      map<String, Decimal> totalSum = getSum(orderListFY);
      map<String, Decimal> totalSumVariance = getSum(orderListFYVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstFY = [
        SELECT Id, FY_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstFY) {
        acc.FY_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.FY_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }

      update accountLstFY;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateFYFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static void calculateQTDFields() {
    try {
      Map<Integer, Integer> quarterMap = getQuraterMap();
      Integer curentQurater = getCurrentQurater();
      Date currentQuraterStartDate = getCurrentQuraterStartDate(
        curentQurater,
        quarterMap,
        false
      );
      Date quraterCurrentDate = System.date.today();
      Date previousYearQuraterStartDate = getCurrentQuraterStartDate(
        curentQurater,
        quarterMap,
        true
      );
      Date previousYearCurrentDate = System.date.today().addMonths(-12);

      List<Order> orderListQTD = getOrders(
        currentQuraterStartDate,
        quraterCurrentDate
      );
      List<Order> orderListQTDVariance = getOrders(
        previousYearQuraterStartDate,
        previousYearCurrentDate
      );
      map<String, Decimal> totalSum = getSum(orderListQTD);
      map<String, Decimal> totalSumVariance = getSum(orderListQTDVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstQTD = [
        SELECT Id, QTD_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstQTD) {
        acc.QTD_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.QTD_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }

      update accountLstQTD;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateQTDFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static void calculateFQFields() {
    try {
      Map<Integer, Integer> quarterMap = getQuraterMap();
      Integer curentQurater = getCurrentQurater();
      Date currentQuraterStartDate = getCurrentQuraterStartDate(
        curentQurater,
        quarterMap,
        false
      );
      Date currentQuraterEndDate = getCurrentQuraterEndDate(
        currentQuraterStartDate
      );
      Date previousYearQuraterStartDate = getCurrentQuraterStartDate(
        curentQurater,
        quarterMap,
        true
      );
      Date previousYearQuraterEndDate = currentQuraterEndDate.addMonths(-12);

      List<Order> orderListFQ = getOrders(
        currentQuraterStartDate,
        currentQuraterEndDate
      );
      List<Order> orderListFQVariance = getOrders(
        previousYearQuraterStartDate,
        previousYearQuraterEndDate
      );
      map<String, Decimal> totalSum = getSum(orderListFQ);
      map<String, Decimal> totalSumVariance = getSum(orderListFQVariance);
      Map<String, Decimal> variance = getVariance(totalSum, totalSumVariance);

      List<Account> accountLstFQ = [
        SELECT Id, FQ_Work_Order_Sum__c
        FROM Account
        WHERE Id IN :totalSum.keySet()
      ];

      for (Account acc : accountLstFQ) {
        acc.FQ_Work_Order_Sum__c = totalSum.get(acc.Id);
        acc.FQ_Work_Order_Sum_Variance__c = variance.get(acc.Id);
      }

      update accountLstFQ;
    } catch (Exception ex) {
      System.debug(
        'Error in calculateFQFields ---------' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }

  public static List<Order> getOrders(Date startDate, Date endDate) {
    return [
      SELECT Id, Name, AccountId, Invoice_Date__c, Invoice_Value__c, Status
      FROM Order
      WHERE Invoice_Date__c >= :startDate AND Invoice_Date__c <= :endDate
    ];
  }

  public static Map<Integer, Integer> getQuraterMap() {
    Map<Integer, Integer> quarterMap = new Map<Integer, Integer>();
    quarterMap.put(1, 1);
    quarterMap.put(2, 4);
    quarterMap.put(3, 7);
    quarterMap.put(4, 10);

    return quarterMap;
  }

  public static Integer getCurrentQurater() {
    Date currentDate = System.Date.today();
    Integer currentMonth = currentDate.Month();
    Integer currentQurater = ((currentMonth - 1) / 3) + 1;
    return currentQurater;
  }

  public static Date getCurrentQuraterStartDate(
    Integer currentQurater,
    Map<Integer, Integer> quarterMap,
    Boolean previousYear
  ) {
    Integer currentQuraterMonth = quarterMap.get(currentQurater);
    Integer year = previousYear == false
      ? System.date.today().Year()
      : System.date.today().Year() - 1;
    Date currentQuraterStartDate = Date.newInstance(
      year,
      currentQuraterMonth,
      1
    );
    return currentQuraterStartDate;
  }

  public static Date getCurrentQuraterEndDate(Date currentQuraterStartDate) {
    Date currentQuraterEndDate = currentQuraterStartDate.addMonths(3)
      .addDays(-1);
    return currentQuraterEndDate;
  }
}
