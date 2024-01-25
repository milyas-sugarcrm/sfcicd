global class QuickbookScheduler implements schedulable {
  public static String err = '';
  global void execute(SchedulableContext stx) {
    List<Quickbooks_Accounts_Configurations__c> listOfConfigurations = [
      SELECT Quickbooks_Account_Tittle__c, Id
      FROM Quickbooks_Accounts_Configurations__c
    ];
    for (Quickbooks_Accounts_Configurations__c obj : listOfConfigurations) {
      refreshQBToken(obj.Quickbooks_Account_Tittle__c);
      // we will not sync any chnages from QB to Salesforce if Company is Phun for All
      if (obj.Quickbooks_Account_Tittle__c != 'Phun for All') {
        syncQBChanges(obj.Quickbooks_Account_Tittle__c);
      }
      if (obj.Quickbooks_Account_Tittle__c == 'Phun for All') {
        syncPFA_QBOInvoice_Changes(obj.Quickbooks_Account_Tittle__c);
      }
    }
  }

  @future(callout=true)
  public static void refreshQBToken(String accountTitle) {
    List<QB_Credentials__c> qbcList = [
      SELECT Id, Access_token__c, Refresh_token__c, realmid__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c = :accountTitle
    ];
    Boolean status = false;
    if (qbcList.size() > 0) {
      Map<String, Object> refreshResults = refreshToken(
        qbcList[0].Refresh_token__c,
        accountTitle
      );
      if (refreshResults != null) {
        qbcList[0].Access_token__c = (String) refreshResults.get(
          'access_token'
        );
        qbcList[0].Refresh_token__c = (String) refreshResults.get(
          'refresh_token'
        );
        update qbcList;
      }
    }
  }
  @future(callout=true)
  public static void syncQBChanges(String accountTitle) {
    SchedulerLastRun__c sr = [
      SELECT LastExecution__c, Last_Sent_Email_Time__c, LastEmailSendToClient__c
      FROM SchedulerLastRun__c
      WHERE accountTitle__c = :accountTitle
      LIMIT 1
    ];

    Datetime lastExecution = sr.LastExecution__c;
    Datetime lastSentEmailTime = sr.Last_Sent_Email_Time__c;
    Datetime LastEmailSendToClient = sr.LastEmailSendToClient__c;
    if (LastEmailSendToClient != null) {
      LastEmailSendToClient = lastSentEmailTime;
    }
    //Code is not syncing with GIT yet so not removing this line
    //Datetime currentNow = System.now().addMinutes(-1*Integer.valueOf(System.label.Scheduler_Interval)).addSeconds(-1*Integer.valueOf(System.label.Threshold));
    String lastExecutionTime = lastExecution.format(
      'yyyy-MM-dd',
      UserInfo.getTimeZone().getID()
    );

    List<QBOSync_Errors__c> errorList = new List<QBOSync_Errors__c>();

    List<QB_Credentials__c> qbcList = [
      SELECT Id, Access_token__c, Refresh_token__c, realmid__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c = :accountTitle
    ];

    if (qbcList.size() > 0) {
      List<String> authorizationCredentials = new List<String>();
      authorizationCredentials.add(qbcList[0].Access_token__c);
      authorizationCredentials.add(qbcList[0].Refresh_token__c);
      authorizationCredentials.add(qbcList[0].realmid__c);
      //MetaData.LastUpdatedTime < '2020-11-10T23:39:33'
      String query =
        'Select * from Invoice where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      //String query = 'Select * from Invoice where MetaData.LastUpdatedTime > \'2021-05-03\'';
      String invoices = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      query =
        'Select * from Estimate where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      String estimates = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      query =
        'Select * from TaxCode where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      String taxCodes = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      query =
        'Select * from PaymentMethod where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      String paymentMethods = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      query =
        'Select * from Term where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      String salesTerm = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      query =
        'Select * from Class where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      String classes = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );
      boolean issueOccurred = false;
      System.debug('Invoices Response ' + invoices);
      if (invoices != null) {
        try {
          System.debug(invoices);
          System.debug(accountTitle);
          processInvoiceRecords(invoices, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Invoice Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Invoice', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Invoice: ' + err);
        errorList.add(addQBError('Invoice', err));
      }
      if (estimates != null) {
        try {
          processEstimateRecords(estimates, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Estimate Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Estimates', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Estimates: ' + err);
        errorList.add(addQBError('Estimates', err));
      }
      if (taxCodes != null) {
        try {
          processTaxCodes(taxCodes, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Tax Code Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Tax Code', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Tax Code: ' + err);
        errorList.add(addQBError('Tax Code', err));
      }
      if (paymentMethods != null) {
        try {
          processPaymentMethods(paymentMethods, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Payment Methods Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Payment Methods', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Payment Methods: ' + err);
        errorList.add(addQBError('Payment Methods', err));
      }
      if (salesTerm != null) {
        try {
          processSalesTerm(salesTerm, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Sales Terms Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Sales Terms', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Sales Terms: ' + err);
        errorList.add(addQBError('Sales Terms', err));
      }
      if (classes != null) {
        try {
          processClasses(classes, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Classes Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Classes', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Classes: ' + err);
        errorList.add(addQBError('Classes', err));
      }

      if (issueOccurred == false) {
        updateLastScheduleTime(accountTitle);
      }

      upsert errorList;

      /*Integer threshold = Integer.valueOf(System.Label.SchedulerIssueThreshold);
if(System.now().getTime() - lastExecution.addMinutes(threshold).getTime() > (threshold * 60000)){
SendEmail('ALERT: Issue in scheduler from last '+ ((System.now().getTime() - lastExecution.addMinutes(threshold).getTime())/60000) +' minutes', 'Subject says it all!');                        
}*/
      if (
        ((System.now().getTime() - lastSentEmailTime.getTime()) / 60000) >= 60
      ) {
        if (getData() != '') {
          SendEmail('Errors list for last 1 hour', getData());
          sr.Last_Sent_Email_Time__c = System.now();

          try {
            Integer thresholdValue = Integer.valueOf(
              Label.Threshold_QBO_Authentication_Error_Emails
            );
            if (
              ((System.now().getTime() - LastEmailSendToClient.getTime()) /
              60000) >= thresholdValue
            ) {
              Datetime dateThreshold = System.Now();
              dateThreshold = dateThreshold.addMinutes((thresholdValue * -1));
              if (getDataClient(dateThreshold) != '') {
                String subjectEmail =
                  'IMPORTANT | QBO (' +
                  accountTitle +
                  ')  Authentication Required ';
                String body =
                  '<h2>Authentication Required </h2><br/>' +
                  '<br/><br/>Click to authenticate <a href="' +
                  Label.default_url +
                  'lightning/n/Quickbook_Authentication">Authenticate Now.</a>' +
                  '<br/><br/>';
                QuickbookApiCrud.sendEmailAuthenticationClient(
                  subjectEmail,
                  body
                );
                sr.LastEmailSendToClient__c = System.now();
              }
            }
          } catch (Exception ex) {
          }
          update sr;
        }
      }
    }
  }

  public static Map<Id, Id> getOpportunityAccountMap(
    List<String> lstCustQBOIds,
    String accountTitle
  ) {
    Map<Id, Id> mapToReturn = new Map<Id, Id>();

    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        QB_Id__c = :lstCustQBOIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountTitle
    ];

    Set<Id> accountIds = new Set<Id>();
    for (QBO_Details__c qboRecord : qboDetailsList) {
      accountIds.add(qboRecord.Account__c);
    }

    List<Opportunity> opportunities = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE accountId = :accountIds
    ];

    for (Opportunity opp : opportunities) {
      mapToReturn.put(opp.Id, opp.AccountId);
    }
    return mapToReturn;
  }
  public static Map<String, Id> getAccountQBDetailOIdMap(
    List<String> lstCustQBOIds,
    String accountTitle
  ) {
    Map<String, Id> mapToReturn = new Map<String, Id>();

    List<QBO_Details__c> qboDetailsList = [
      SELECT
        Id,
        QB_Id__c,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        QBO_Account__c,
        Salesforce_Record_Id__c
      FROM QBO_Details__c
      WHERE
        QB_Id__c = :lstCustQBOIds
        AND id_Type__c = :'Account'
        AND QBO_Account__c = :accountTitle
    ];

    for (QBO_Details__c qboRecord : qboDetailsList) {
      mapToReturn.put(qboRecord.QB_Id__c, qboRecord.Account__c);
    }
    return mapToReturn;
  }
  public static void processInvoiceRecords(
    String responseData,
    String accountTitle
  ) {
    QuickbookApiCrud.InvoiceResponse results = (QuickbookApiCrud.InvoiceResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.InvoiceResponse.class
    );
    if (results.QueryResponse != null) {
      Map<String, Id> customerRefMap = new Map<String, Id>();
      Map<Id, Id> opportunityIdAccountMap = new Map<Id, Id>();
      List<QuickbookApiCrud.Invoice> invoices = results.QueryResponse.Invoice;
      if (invoices != null) {
        Map<String, String> classRefs = new Map<String, String>();
        system.debug(
          [
            SELECT Id, Name, Fully_Qualified_Name__c, QBO_Account__c, Id__c
            FROM Class__c
            WHERE QBO_Account__c = :accountTitle
          ]
        );
        for (Class__c classR : [
          SELECT Id, Name, Fully_Qualified_Name__c, QBO_Account__c, Id__c
          FROM Class__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          classRefs.put(classR.Id__c, classR.Fully_Qualified_Name__c);
        }
        Map<String, String> termRefs = new Map<String, String>();
        for (Sales_Term__c term : [
          SELECT Id, Id__c, Name, QBO_Account__c
          FROM Sales_Term__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          termRefs.put(term.Id__c, term.Name);
        }
        List<QBO_Details__c> qboDetailsToAdd = new List<QBO_Details__c>();
        Map<String, Order> mapQbIdOrder = new Map<String, Order>();
        Map<Order, QBO_Details__c> mapOrderQbId = new Map<Order, QBO_Details__c>();
        List<String> lstCustRefIds = new List<String>();
        //================
        for (QuickbookApiCrud.Invoice inv : invoices) {
          if (inv.CustomerRef != null) {
            lstCustRefIds.add(inv.CustomerRef.value);
          }
        }
        customerRefMap = getAccountQBDetailOIdMap(lstCustRefIds, accountTitle);
        opportunityIdAccountMap = getOpportunityAccountMap(
          lstCustRefIds,
          accountTitle
        );
        //===================
        for (QuickbookApiCrud.Invoice inv : invoices) {
          Order orderObj = new Order();
          orderObj.AccountId = inv.CustomerRef != null
            ? customerRefMap.get(inv.CustomerRef.value)
            : null;
          if (orderObj.AccountId == null) {
            continue;
          }
          if (Test.IsRunningTest()) {
            orderObj.OpportunityId = [SELECT id FROM opportunity LIMIT 1].id;
          }
          orderObj.QbId__c = inv.Id;
          System.debug('orderObj.QbId__c: ' + inv.Id);
          orderObj.Invoice_Number__c = inv.DocNumber;
          System.debug('orderObj.DocNumber: ' + inv.DocNumber);
          orderObj.Quickbooks_Instance__c = accountTitle;
          orderObj.QBO_Invoice_Detail__c =
            accountTitle +
            ' (' +
            inv.DocNumber +
            ')';
          orderObj.Status = '01_-_Waiting_for_Client_Payment';
          orderObj.Order_Amount__c = inv.TotalAmt;
          orderObj.Invoice_Total__c = inv.TotalAmt;
          orderObj.Balance_Due__c = inv.Balance;
          orderObj.Amount_Received__c =
            orderObj.Order_Amount__c - orderObj.Balance_Due__c;
          orderObj.Invoice_Email__c = inv.BillEmail != null
            ? inv.BillEmail.Address
            : null;
          if (
            orderObj.Invoice_Email__c != null &&
            orderObj.Invoice_Email__c.contains(',')
          ) {
            orderObj.Invoice_Email__c = orderObj.Invoice_Email__c.split(',')[0];
          }

          orderObj.Invoice_Ship_Via__c = inv.ShipMethodRef != null
            ? inv.ShipMethodRef.value
            : null;
          orderObj.Invoice_Tax__c = inv.TxnTaxDetail != null
            ? inv.TxnTaxDetail.TotalTax
            : null;

          orderObj.Invoice_Date__c = inv.TxnDate != null
            ? getDateFromString(inv.TxnDate)
            : null;
          orderObj.EffectiveDate = inv.TxnDate != null
            ? getDateFromString(inv.TxnDate)
            : null;
          orderObj.Invoice_Due_Date__c = inv.DueDate != null
            ? getDateFromString(inv.DueDate)
            : null;
          orderObj.Invoice_Ship_Date__c = inv.ShipDate;
          orderObj.Invoice_Terms__c = inv.SalesTermRef != null
            ? termRefs.get(inv.SalesTermRef.value)
            : '';
          List<QuickbookApiCrud.Line> lineItems = inv.Line;
          for (QuickbookApiCrud.Line line : lineItems) {
            if (line.DetailType == 'SubTotalLineDetail') {
              orderObj.Invoice_Value__c = line.Amount;
            } else if (line.DetailType == 'DiscountLineDetail') {
              orderObj.Invoice_Discount__c = line.Amount;
            }
          }
          if (inv.CustomField.size() > 0) {
            System.debug(inv.CustomField);
            for (QuickbookApiCrud.CustomField cField : inv.CustomField) {
              if (cField.Name == 'Client Due Date') {
                orderObj.Client_Due_Date__c = cField.StringValue;
              } else if (cField.Name == 'Est. Ship Date') {
                orderObj.Invoice_Estimated_Ship_Date__c = cField.StringValue;
              } else if (cField.Name == 'SF Opportunity') {
                System.debug('orderObj.OpportunityId: ' + cField.StringValue);
                if (
                  cField.StringValue != null &&
                  cField.StringValue.substring(0, 3) == '006' &&
                  cField.StringValue.length() == 18
                )
                  orderObj.OpportunityId = cField.StringValue != null
                    ? ((Id) cField.StringValue)
                    : null;
                if (
                  orderObj.OpportunityId != null &&
                  opportunityIdAccountMap.containsKey(orderObj.OpportunityId)
                ) {
                  System.debug('Setting Account Id');
                  orderObj.AccountId = opportunityIdAccountMap.get(
                    orderObj.OpportunityId
                  );
                  //    orderQboDetail.Opportunity__c = cField.StringValue !=null ? ((Id) cField.StringValue) :null;
                }
              }
            }
          }

          if (inv.BillAddr != null) {
            orderObj.BillingStreet = inv.BillAddr.Line1;
            orderObj.BillingCity = inv.BillAddr.City;
            orderObj.BillingState = inv.BillAddr.CountrySubDivisionCode;
            orderObj.BillingPostalCode = inv.BillAddr.PostalCode;
            orderObj.BillingCountry = inv.BillAddr.Country;
          }
          if (inv.ShipAddr != null) {
            orderObj.ShippingStreet = inv.ShipAddr.Line1;
            orderObj.ShippingCity = inv.ShipAddr.City;
            orderObj.ShippingState = inv.ShipAddr.CountrySubDivisionCode;
            orderObj.ShippingPostalCode = inv.ShipAddr.PostalCode;
            orderObj.ShippingCountry = inv.ShipAddr.Country;
          }
          mapQbIdOrder.put(orderObj.QbId__c, orderObj);
        }
        List<String> qboInstanceDetails = new List<String>();
        /*for(Order ordObj: [Select id,QbId__c,Status,EffectiveDate,Valid_Credits__c,QBO_Invoice_Detail__c
                                   from Order 
                                   where QbId__c=null OR QBO_Invoice_Detail__c!=null])
                {
                    for(String key: mapQbIdOrder.keyset())
                    {
                        if(ordObj.QBO_Invoice_Detail__c == mapQbIdOrder.get(key).QBO_Invoice_Detail__c)
                        {
                            Order newOrder= mapQbIdOrder.get(key);
                            if(newOrder != null)
                            {
                                newOrder.Id = ordObj.Id;
                                newOrder.Status = ordObj.Status;
                                newOrder.Valid_Credits__c = ordObj.Valid_Credits__c;
                                if ( !('01_-_Waiting_for_Client_Payment' ==  newOrder.Status || '02_-_Send_Mock_Up_to_Client_for_Approval' == newOrder.Status ))
                                {
                                    newOrder.EffectiveDate = ordObj.EffectiveDate;
                                }
                                mapQbIdOrder.put(key,newOrder);
                            }
                        }
                    }
                }*/
        for (Order ordObj : [
          SELECT id, QbId__c, Status, EffectiveDate, Valid_Credits__c
          FROM Order
          WHERE QbId__c IN :mapQbIdOrder.keySet()
        ]) {
          Order newOrder = mapQbIdOrder.get(ordObj.QbId__c);
          if (newOrder != null) {
            newOrder.Id = ordObj.Id;
            newOrder.Status = ordObj.Status;
            newOrder.Valid_Credits__c = ordObj.Valid_Credits__c;
            if (
              !('01_-_Waiting_for_Client_Payment' == newOrder.Status ||
              '02_-_Send_Mock_Up_to_Client_for_Approval' == newOrder.Status)
            ) {
              newOrder.EffectiveDate = ordObj.EffectiveDate;
            }
            mapQbIdOrder.put(ordObj.QbId__c, newOrder);
          }
        }
        system.debug(mapQbIdOrder.values());
        List<Order> ordersToBeInserted = new List<Order>();
        List<Order> ordersToBeUpdated = new List<Order>();
        for (String key : mapQbIdOrder.keySet()) {
          if (mapQbIdOrder.get(key).Id != null) {
            if (mapQbIdOrder.get(key).OpportunityId != null)
              ordersToBeUpdated.add(mapQbIdOrder.get(key));
          } else {
            System.debug('INSERT: ' + mapQbIdOrder.get(key));
            System.debug(
              'INSERT Opp ID: ' + mapQbIdOrder.get(key).OpportunityId
            );
            if (mapQbIdOrder.get(key).OpportunityId != null)
              ordersToBeInserted.add(mapQbIdOrder.get(key));
          }
        }
        if (ordersToBeUpdated != null && ordersToBeUpdated.size() > 0)
          update ordersToBeUpdated;
        if (ordersToBeInserted != null && ordersToBeInserted.size() > 0) {
          List<String> QBOInvoiceDetails = new List<String>();
          for (Order order : ordersToBeInserted) {
            QBOInvoiceDetails.add(order.QBO_Invoice_Detail__c);
          }
          List<Order> ordersToBeInsertedFinal = new List<Order>();
          List<String> QBOInvoiceDetailsList = new List<String>();
          for (Order ordObj : [
            SELECT id, QBO_Invoice_Detail__c
            FROM Order
            WHERE QBO_Invoice_Detail__c IN :QBOInvoiceDetails
          ]) {
            QBOInvoiceDetailsList.add(ordObj.QBO_Invoice_Detail__c);
          }
          for (Order order : ordersToBeInserted) {
            if (!QBOInvoiceDetailsList.contains(order.QBO_Invoice_Detail__c))
              ordersToBeInsertedFinal.add(order);
          }
          checkValidityAndInsertOrders(ordersToBeInsertedFinal);
        }
      }
    }
  }
  public static void checkValidityAndInsertOrders(
    List<Order> listOfOrdersToBeInserted
  ) {
    System.debug('CHECK NEW INSERTED: ' + listOfOrdersToBeInserted);
    List<Id> OpportunityIds = new List<Id>();
    for (Order order : listOfOrdersToBeInserted) {
      OpportunityIds.add(order.OpportunityId);
    }
    List<Opportunity> oppToBeUpdated = [
      SELECT Id, Name, WorkOrder_Number_For_Template__c
      FROM Opportunity
      WHERE Id = :OpportunityIds
    ];
    List<Estimate__c> estimates = [
      SELECT
        id,
        OwnerId,
        Opportunity__c,
        Update_Credit_Request_Status__c,
        Selected_Quickbook_Instance__c
      FROM Estimate__c
      WHERE Opportunity__c = :OpportunityIds
    ];
    Map<Id, Estimate__c> orderEstimateMap = new Map<Id, Estimate__c>();
    Map<Id, String> OrderAccountMap = new Map<Id, String>();
    Map<Id, Opportunity> orderOpportunityMap = new Map<Id, Opportunity>();
    for (Order order : listOfOrdersToBeInserted) {
      for (Opportunity opp : oppToBeUpdated) {
        if (order.OpportunityId == opp.Id)
          orderOpportunityMap.put(order.OpportunityId, opp);
      }
      for (Estimate__c est : estimates) {
        if (order.OpportunityId == est.Opportunity__c) {
          orderEstimateMap.put(order.OpportunityId, est);
        }
      }
    }
    List<Order> listOfOrders = new List<Order>();
    List<Order> listOfDisableOrders = new List<Order>();
    for (Order order : listOfOrdersToBeInserted) {
      //// use mapp instead of iterations
      for (Opportunity opp : oppToBeUpdated) {
        if (opp.id == order.OpportunityId) {
          if (!listOfOrders.contains(order))
            listOfOrders.add(order);
        }
      }
    }
    List<Id> estimateIds = new List<Id>();
    Set<Id> estimateOwnerIds = new Set<Id>();
    if (estimates != null && estimates.size() > 0) {
      for (Estimate__c est : estimates) {
        estimateIds.add(est.Id);
        estimateOwnerIds.add(est.OwnerId);
      }
    }
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT
        Id,
        Name,
        SKU__c,
        Imprint_Methods__c,
        Quantity_Estimate__c,
        Account__c,
        Product__r.Design_Project__c,
        Description__c,
        Private_Notes__c,
        Product__r.Sales_Price_Rate__c,
        Estimate__c
      FROM OpportunityLineItem__c
      WHERE Estimate__c IN :estimateIds
    ];
    Set<Id> lineItemIds = new Set<Id>();
    if (oppLineItems != null && oppLineItems.size() > 0) {
      for (OpportunityLineItem__c oppLineItem : oppLineItems) {
        lineItemIds.add(oppLineItem.id);
      }
    }
    List<OpportunityLineItem_ArtWork__c> opportunityLineItemArtworkList = [
      SELECT
        Id,
        OpportunityLineItem__c,
        ArtWorkNumber__c,
        Imprint_Type__c,
        Proof_Required__c,
        logo_Name__c,
        Logo_Size__c,
        Logo_Color__c,
        Repeat_Logo__c,
        Supplier_Notes__c,
        Document_ID__c,
        Counter__c,
        Title__c,
        Estimate__c
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c = :lineItemIds
    ];
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Title__c,
        index__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        OpportunityLineItem_ArtWork__c,
        Total__c,
        Display__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c,
        Valid_Quantity__c,
        Valid_Net_Cost__c,
        Valid_Retail_Price__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c = :lineItemIds
    ];

    List<PricingLineItem__c> pricingList = [
      SELECT
        Id,
        Quantity__c,
        OpportunityLineItem__c,
        Display__c,
        Retail_Price__c,
        Total__c,
        Estimated_Quantity__c,
        Default__c,
        Margin__c,
        Valid_Quantity__c,
        Net_Cost__c,
        Valid_Net_Cost__c,
        Valid_Retail_Price__c,
        Color__c,
        Size__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :lineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
    ];
    List<ColorLineItem__c> colorsList = [
      SELECT
        Id,
        Name,
        Color__c,
        OpportunityLineItem__c,
        isFromProduct__c,
        isSelected__c,
        Estimate__c
      FROM ColorLineItem__c
      WHERE OpportunityLineItem__c = :lineItemIds
    ];
    List<SizeLineItem__c> sizesList = [
      SELECT
        Id,
        OpportunityLineItem__c,
        Size__c,
        isSelected__c,
        isFromProduct__c,
        Estimate__c,
        Name
      FROM SizeLineItem__c
      WHERE OpportunityLineItem__c = :lineItemIds
    ];
    List<OpportunityLineItemAttachment__c> AttachmentsList = [
      SELECT Id, Name, Estimate__c, OpportunityLineItem__c
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c = :lineItemIds
    ];
    List<Design_Project__c> designProjects = [
      SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
      FROM Design_Project__c
      WHERE Product__c IN :lineItemIds
    ];
    Map<Id, List<OpportunityLineItem__c>> oppLineItemMap = new Map<Id, List<OpportunityLineItem__c>>();
    Map<Id, List<PricingLineItem__c>> pricingMap = new Map<Id, List<PricingLineItem__c>>();
    Map<Id, List<ColorLineItem__c>> colorsMap = new Map<Id, List<ColorLineItem__c>>();
    Map<Id, List<SizeLineItem__c>> sizesMap = new Map<Id, List<SizeLineItem__c>>();
    Map<Id, List<OpportunityLineItemAttachment__c>> attachmentsMap = new Map<Id, List<OpportunityLineItemAttachment__c>>();
    Map<id, List<ExtraChargesEstimate__c>> extraChargesMap = new Map<id, List<ExtraChargesEstimate__c>>();
    Map<id, List<OpportunityLineItem_ArtWork__c>> artworkMap = new Map<id, List<OpportunityLineItem_ArtWork__c>>();
    List<User> users = [
      SELECT id, Name, Design_Bank__c
      FROM User
      WHERE Id IN :estimateOwnerIds
    ];
    Map<id, User> oppUserMap = new Map<id, User>();
    for (Estimate__c est : estimates) {
      List<OpportunityLineItem__c> oppLineItemsList = new List<OpportunityLineItem__c>();
      for (OpportunityLineItem__c lineItem : oppLineItems) {
        if (est.id == lineItem.Estimate__c) {
          oppLineItemsList.add(lineItem);
        }
      }
      if (oppLineItemsList.size() > 0) {
        oppLineItemMap.put(est.Opportunity__c, oppLineItemsList);
      }
      for (User user : users) {
        if (user.id == est.OwnerId) {
          oppUserMap.put(est.Opportunity__c, user);
        }
      }
    }
    for (OpportunityLineItem__c lineItem : oppLineItems) {
      List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
      List<PricingLineItem__c> pricings = new List<PricingLineItem__c>();
      List<ColorLineItem__c> colors = new List<ColorLineItem__c>();
      List<SizeLineItem__c> sizes = new List<SizeLineItem__c>();
      List<OpportunityLineItemAttachment__c> attachments = new List<OpportunityLineItemAttachment__c>();
      List<OpportunityLineItem_ArtWork__c> artworks = new List<OpportunityLineItem_ArtWork__c>();
      if (pricingList != null && pricingList.size() > 0) {
        for (PricingLineItem__c pricing : pricingList) {
          if (pricing.OpportunityLineItem__c == lineItem.Id) {
            pricings.add(pricing);
          }
        }
        if (pricings.size() > 0) {
          pricingMap.put(lineItem.Id, pricings);
        }
      }
      if (extraCharges != null && extraCharges.size() > 0) {
        for (ExtraChargesEstimate__c extraCharge : extraCharges) {
          if (extraCharge.OpportunityLineItem__c == lineItem.Id) {
            extraChargesList.add(extraCharge);
          }
        }
        if (extraChargesList.size() > 0) {
          extraChargesMap.put(lineItem.Id, extraChargesList);
        }
      }
      if (
        opportunityLineItemArtworkList != null &&
        opportunityLineItemArtworkList.size() > 0
      ) {
        for (
          OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
        ) {
          if (artwork.OpportunityLineItem__c == lineItem.Id) {
            artworks.add(artwork);
          }
        }
        if (artworks.size() > 0) {
          artworkMap.put(lineItem.Id, artworks);
        }
      }
      if (colorsList != null && colorsList.size() > 0) {
        for (ColorLineItem__c color : colorsList) {
          if (color.OpportunityLineItem__c == lineItem.Id) {
            colors.add(color);
          }
        }
        if (colors.size() > 0) {
          colorsMap.put(lineItem.Id, colors);
        }
      }
      if (sizesList != null && sizesList.size() > 0) {
        for (SizeLineItem__c size : sizesList) {
          if (size.OpportunityLineItem__c == lineItem.Id) {
            sizes.add(size);
          }
        }
        if (sizes.size() > 0) {
          sizesMap.put(lineItem.Id, sizes);
        }
      }
      if (AttachmentsList != null && AttachmentsList.size() > 0) {
        for (OpportunityLineItemAttachment__c attachment : AttachmentsList) {
          if (attachment.OpportunityLineItem__c == lineItem.Id) {
            attachments.add(attachment);
          }
        }
        if (attachments.size() > 0) {
          attachmentsMap.put(lineItem.Id, attachments);
        }
      }
    }

    List<Id> OrderIdswithOnlyDPs = new List<Id>();
    Map<Id, Boolean> OrderValidityMap = new Map<Id, Boolean>();
    Map<Id, Decimal> orderCreditsMap = new Map<Id, Decimal>();
    for (Order order : listOfOrders) {
      order.Created_From_QBO__c = true;
      Decimal validCredits = 0;
      Boolean orderWithDPs = true;
      List<OpportunityLineItem__c> lineOpps = oppLineItemMap.get(
        order.OpportunityId
      );
      Integer designProjectCount = 0;
      if (lineOpps != null) {
        for (OpportunityLineItem__c oppLineItem : lineOpps) {
          if (designProjects != null && designProjects.size() > 0) {
            for (Design_Project__c designProject : designProjects) {
              //// lineitem mapppp
              if (designProject.Product__c == oppLineItem.id) {
                designProjectCount++;
                List<PricingLineItem__c> pricings = pricingMap.get(
                  oppLineItem.Id
                );
                Decimal usedCredits = 0;
                if (pricings != null) {
                  for (PricingLineItem__c price : pricings) {
                    if (
                      price.Valid_Net_Cost__c != null &&
                      price.Valid_Retail_Price__c != null &&
                      price.Valid_Net_Cost__c > price.Valid_Retail_Price__c
                    ) {
                      usedCredits =
                        usedCredits +
                        (((price.Valid_Quantity__c != null
                          ? price.Valid_Quantity__c
                          : 0) *
                        (price.Valid_Net_Cost__c != null
                          ? price.Valid_Net_Cost__c
                          : 0)) -
                        ((price.Valid_Quantity__c != null
                          ? price.Valid_Quantity__c
                          : 0) *
                        (price.Valid_Retail_Price__c != null
                          ? price.Valid_Retail_Price__c
                          : 0)));
                    }
                  }
                }
                List<ExtraChargesEstimate__c> extraChargesList = extraChargesMap.get(
                  oppLineItem.Id
                );
                if (extraChargesList != null) {
                  for (ExtraChargesEstimate__c extraCharge : extraChargesList) {
                    if (
                      extraCharge.Valid_Net_Cost__c != null &&
                      extraCharge.Valid_Retail_Price__c != null &&
                      extraCharge.Valid_Net_Cost__c >
                      extraCharge.Valid_Retail_Price__c
                    ) {
                      usedCredits =
                        usedCredits +
                        (((extraCharge.Valid_Quantity__c != null
                          ? extraCharge.Valid_Quantity__c
                          : 0) *
                        (extraCharge.Valid_Net_Cost__c != null
                          ? extraCharge.Valid_Net_Cost__c
                          : 0)) -
                        ((extraCharge.Valid_Quantity__c != null
                          ? extraCharge.Valid_Quantity__c
                          : 0) *
                        (extraCharge.Valid_Retail_Price__c != null
                          ? extraCharge.Valid_Retail_Price__c
                          : 0)));
                    }
                  }
                }
                validCredits = validCredits + usedCredits;
                designProject.Credits__c = usedCredits;
              }
            }
          }
        }
      }
      order.Valid_Credits__c = true;
      //System.debug('oppLineItemMap.size(): '+lineOpps.size());
      System.debug('DESIGN PROJECTS: ' + designProjectCount);
      if (lineOpps != null && designProjectCount == lineOpps.size()) {
        OrderIdswithOnlyDPs.add(order.OpportunityId);
        System.debug('OrderIdswithOnlyDPs: ' + OrderIdswithOnlyDPs);
      }
      if (
        oppUserMap != null &&
        oppUserMap.size() > 0 &&
        oppUserMap.get(order.OpportunityId) != null &&
        validCredits <= oppUserMap.get(order.OpportunityId).Design_Bank__c
      ) {
        order.Valid_Credits__c = true;
        OrderValidityMap.put(order.OpportunityId, true); /////////////////
      } else if (
        oppUserMap != null &&
        oppUserMap.size() > 0 &&
        oppUserMap.get(order.OpportunityId) != null &&
        validCredits >= oppUserMap.get(order.OpportunityId).Design_Bank__c
      ) {
        order.Valid_Credits__c = false;
        OrderValidityMap.put(order.OpportunityId, false); ////////removeeeeeee
        listOfDisableOrders.add(order);
      }
      orderCreditsMap.put(order.OpportunityId, validCredits);
    }

    update designProjects;

    Database.Insert(listOfOrders);
    List<OpportunityLineItem__c> opportunityLineItemToBeInserted = new List<OpportunityLineItem__c>();
    Map<Id, OpportunityLineItem__c> newOppLineItemsMap = new Map<Id, OpportunityLineItem__c>();
    Set<Id> orderIdsforMakePayment = new Set<Id>();
    for (Order order : listOfOrders) {
      for (Estimate__c est : estimates) {
        if (order.OpportunityId == est.Opportunity__c) {
          OrderAccountMap.put(order.id, est.Selected_Quickbook_Instance__c);
        }
      }
      for (Id oppId : OrderIdswithOnlyDPs) {
        if (oppId == order.OpportunityId) {
          orderIdsforMakePayment.add(order.id);
        }
      }
      if (oppToBeUpdated != null && oppToBeUpdated.size() > 0) {
        for (Opportunity opp : oppToBeUpdated) {
          if (opp.id == order.OpportunityId) {
            opp.WorkOrder_Number_For_Template__c = order.Name;
          }
        }
      }
      List<OpportunityLineItem__c> lineOpps = oppLineItemMap.get(
        order.OpportunityId
      );
      if (lineOpps != null) {
        for (OpportunityLineItem__c oppLineItem : lineOpps) {
          OpportunityLineItem__c newOpp = new OpportunityLineItem__c();
          newOpp = oppLineItem.clone();
          newOpp.Name = oppLineItem.Name;
          newOpp.Account__c = oppLineItem.Account__c;
          newOpp.Private_Notes__c = oppLineItem.Private_Notes__c;
          newOpp.Description__c = oppLineItem.Description__c;
          newOpp.Quantity_Estimate__c = oppLineItem.Quantity_Estimate__c;
          newOpp.Estimate__c = null;
          newOpp.SKU__c = oppLineItem.SKU__c;
          newOpp.Imprint_Methods__c = oppLineItem.Imprint_Methods__c;
          newOpp.Work_Order__c = order.Id;
          opportunityLineItemToBeInserted.add(newOpp);
          newOppLineItemsMap.put(oppLineItem.Id, newOpp);
        }
      }
      if (order.Valid_Credits__c) {
        if (
          oppUserMap.get(order.OpportunityId).Design_Bank__c != null &&
          oppUserMap.get(order.OpportunityId).Design_Bank__c >
          orderCreditsMap.get(order.OpportunityId)
        ) {
          oppUserMap.get(order.OpportunityId).Design_Bank__c =
            oppUserMap.get(order.OpportunityId).Design_Bank__c -
            orderCreditsMap.get(order.OpportunityId);
        }
      }
    }
    List<User> userss = new List<User>();
    for (User user : oppUserMap.values()) {
      if (!userss.contains(user))
        userss.add(user);
    }
    update userss;
    /////////////// update listOfOrders;
    if (
      opportunityLineItemToBeInserted != null &&
      opportunityLineItemToBeInserted.size() > 0
    )
      insert opportunityLineItemToBeInserted;
    if (oppToBeUpdated != null && oppToBeUpdated.size() > 0)
      update oppToBeUpdated;
    List<PricingLineItem__c> pricingsToBeInserted = new List<PricingLineItem__c>();
    List<ColorLineItem__c> colorsListToBeInserted = new List<ColorLineItem__c>();
    List<SizeLineItem__c> sizesListToBeInserted = new List<SizeLineItem__c>();
    Map<Id, OpportunityLineItemAttachment__c> attachmentsListToBeInserted = new Map<Id, OpportunityLineItemAttachment__c>();
    List<Id> attachmentsListIds = new List<Id>();
    Map<id, OpportunityLineItem_ArtWork__c> newAndOldArtwoksMap = new Map<id, OpportunityLineItem_ArtWork__c>();
    for (Order order : listOfOrders) {
      List<OpportunityLineItem__c> lineOpps = oppLineItemMap.get(
        order.OpportunityId
      );
      if (lineOpps != null) {
        for (OpportunityLineItem__c oppLineItem : lineOpps) {
          if (
            designProjects != null &&
            designProjects.size() > 0 //////  use mapss
          ) {
            for (Design_Project__c designProject : designProjects) {
              if (designProject.Product__c == oppLineItem.id) {
                designProject.Product__c = newOppLineItemsMap.get(
                    designProject.Product__c
                  )
                  .id;
                designProject.Work_Order__c = order.id;
                designProject.Estimate__c = null;
              }
            }
          }
          List<PricingLineItem__c> pricings = pricingMap.get(oppLineItem.Id);
          if (pricings != null && pricings.Size() > 0) {
            for (PricingLineItem__c pricing : pricings) {
              //// net costtt
              PricingLineItem__c clonedPricing = pricing.clone();
              clonedPricing.Display__c = pricing.Display__c;
              clonedPricing.Default__c = pricing.Default__c;
              clonedPricing.Color__c = pricing.Color__c;
              clonedPricing.Size__c = pricing.Size__c;
              clonedPricing.Net_Cost__c = pricing.Net_Cost__c;
              clonedPricing.OpportunityLineItem__c = newOppLineItemsMap.get(
                  oppLineItem.Id
                )
                .Id;
              clonedPricing.Estimate__c = newOppLineItemsMap.get(oppLineItem.Id)
                .Estimate__c; ////   set null
              pricingsToBeInserted.add(clonedPricing);
            }
          }
          List<OpportunityLineItem_ArtWork__c> artworksListTemp = artworkMap.get(
            oppLineItem.Id
          );
          if (artworksListTemp != null && artworksListTemp.Size() > 0) {
            for (OpportunityLineItem_ArtWork__c artwork : artworksListTemp) {
              OpportunityLineItem_ArtWork__c clonedArtwork = artwork.clone();
              clonedArtwork.OpportunityLineItem__c = newOppLineItemsMap.get(
                  artwork.OpportunityLineItem__c
                )
                .id;
              ////////// estmate update
              newAndOldArtwoksMap.put(artwork.id, clonedArtwork);
            }
          }
          List<ColorLineItem__c> colorsListTemp = colorsMap.get(oppLineItem.Id);
          if (colorsListTemp != null && colorsListTemp.Size() > 0) {
            for (ColorLineItem__c color : colorsListTemp) {
              ColorLineItem__c clonedColor = color.clone();
              clonedColor.Estimate__c = null;
              clonedColor.OpportunityLineItem__c = newOppLineItemsMap.get(
                  color.OpportunityLineItem__c
                )
                .id;
              colorsListToBeInserted.add(clonedColor);
            }
          }
          List<SizeLineItem__c> sizesListTemp = sizesMap.get(oppLineItem.Id);
          if (sizesListTemp != null && sizesListTemp.Size() > 0) {
            for (SizeLineItem__c size : sizesListTemp) {
              SizeLineItem__c clonedSize = size.clone();
              clonedSize.Estimate__c = null;
              clonedSize.OpportunityLineItem__c = newOppLineItemsMap.get(
                  size.OpportunityLineItem__c
                )
                .id;
              sizesListToBeInserted.add(clonedSize);
            }
          }
          List<OpportunityLineItemAttachment__c> attachmentListTemp = attachmentsMap.get(
            oppLineItem.Id
          );
          if (attachmentListTemp != null && attachmentListTemp.Size() > 0) {
            for (
              OpportunityLineItemAttachment__c attachment : attachmentListTemp
            ) {
              OpportunityLineItemAttachment__c clonedAttachment = attachment.clone();
              clonedAttachment.Estimate__c = null;
              clonedAttachment.OpportunityLineItem__c = newOppLineItemsMap.get(
                  attachment.OpportunityLineItem__c
                )
                .id;
              attachmentsListToBeInserted.put(attachment.id, clonedAttachment);
              if (!attachmentsListIds.contains(attachment.id))
                attachmentsListIds.add(attachment.id);
            }
          }
        }
      }
    }
    if (designProjects != null && designProjects.size() > 0)
      update designProjects;
    if (pricingsToBeInserted != null && pricingsToBeInserted.size() > 0)
      insert pricingsToBeInserted;
    if (colorsListToBeInserted != null && colorsListToBeInserted.size() > 0)
      insert colorsListToBeInserted;
    if (sizesListToBeInserted != null && sizesListToBeInserted.size() > 0)
      insert sizesListToBeInserted;
    insert attachmentsListToBeInserted.values();
    insert newAndOldArtwoksMap.values();
    if (AttachmentsList != null && AttachmentsList.size() > 0) {
      Map<Id, List<ContentDocumentLink>> oldAttachmentRecordId_images_map = new Map<Id, List<ContentDocumentLink>>();
      List<ContentDocumentLink> imagesToBeInserted = new List<ContentDocumentLink>();
      List<ContentDocumentLink> allDocumentIds = new List<ContentDocumentLink>();

      if (attachmentsListIds != null && attachmentsListIds.Size() > 0) {
        allDocumentIds = [
          SELECT ContentDocumentId, LinkedEntityId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :attachmentsListIds
          ORDER BY ContentDocument.CreatedDate DESC
        ];
      }
      for (OpportunityLineItemAttachment__c attachment : AttachmentsList) {
        List<ContentDocumentLink> contentDocumentList = new List<ContentDocumentLink>();
        for (ContentDocumentLink document : allDocumentIds) {
          if (document.LinkedEntityId == attachment.Id) {
            contentDocumentList.add(document);
          }
        }
        oldAttachmentRecordId_images_map.put(
          attachment.Id,
          contentDocumentList
        );
      }
      if (allDocumentIds != null && allDocumentIds.Size() > 0) {
        for (ContentDocumentLink image : allDocumentIds) {
          ContentDocumentLink clonedImage = image.Clone();
          clonedImage.LinkedEntityId = attachmentsListToBeInserted.get(
              image.LinkedEntityId
            )
            .Id;
          clonedImage.ShareType = 'V';
          imagesToBeInserted.add(clonedImage);
        }
      }
      insert imagesToBeInserted;
    }
    ///////////////
    List<ExtraChargesEstimate__c> newExtraChargesWithArtWork = new List<ExtraChargesEstimate__c>();
    List<ExtraChargesEstimate__c> newExtraChargesList = new List<ExtraChargesEstimate__c>();
    /////
    for (Order order : listOfOrders) {
      List<OpportunityLineItem__c> lineOpps = oppLineItemMap.get(
        order.OpportunityId
      );
      if (lineOpps != null) {
        for (OpportunityLineItem__c oppLineItem : lineOpps) {
          List<ExtraChargesEstimate__c> extraChargesWithArtWorkList = new List<ExtraChargesEstimate__c>();
          List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
          List<ExtraChargesEstimate__c> extraChargesListTemp = extraChargesMap.get(
            oppLineItem.Id
          );
          if (extraChargesListTemp != null && extraChargesListTemp.size() > 0) {
            for (ExtraChargesEstimate__c charges : extraChargesListTemp) {
              if (!charges.Is_Associated_With_Artwork__c)
                extraChargesList.add(charges);
              else
                extraChargesWithArtWorkList.add(charges);
            }
          }
          if (extraChargesList != null && extraChargesList.Size() > 0) {
            for (ExtraChargesEstimate__c charges : extraChargesList) {
              ExtraChargesEstimate__c clonedCharges = charges.clone();
              clonedCharges.Net_Cost__c = charges.Net_Cost__c;
              clonedCharges.OpportunityLineItem__c = newOppLineItemsMap.get(
                  oppLineItem.Id
                )
                .Id;
              clonedCharges.OpportunityLineItem_ArtWork__c = null;
              newExtraChargesList.add(clonedCharges);
            }
          }
          if (
            extraChargesWithArtWorkList != null &&
            extraChargesWithArtWorkList.Size() > 0
          ) {
            for (
              ExtraChargesEstimate__c charges : extraChargesWithArtWorkList
            ) {
              ExtraChargesEstimate__c clonedCharges = charges.clone();
              clonedCharges.Net_Cost__c = charges.Net_Cost__c;
              clonedCharges.OpportunityLineItem__c = newOppLineItemsMap.get(
                  oppLineItem.Id
                )
                .Id;
              if (
                newAndOldArtwoksMap.get(
                  charges.OpportunityLineItem_ArtWork__c
                ) != null &&
                newAndOldArtwoksMap.get(charges.OpportunityLineItem_ArtWork__c)
                  .Id != null
              )
                clonedCharges.OpportunityLineItem_ArtWork__c = newAndOldArtwoksMap.get(
                    charges.OpportunityLineItem_ArtWork__c
                  )
                  .Id;
              newExtraChargesWithArtWork.add(clonedCharges);
            }
          }
        }
      }
    }
    if (
      newExtraChargesWithArtWork != null &&
      newExtraChargesWithArtWork.size() > 0
    )
      insert newExtraChargesWithArtWork;
    if (newExtraChargesList != null && newExtraChargesList.size() > 0)
      insert newExtraChargesList;
    ////// SHIPPING INFO
    List<OpportunityLineItem__c> updateOpportunityLineItem = new List<OpportunityLineItem__c>();
    List<Shipping_Information__c> shippingObjectList = new List<Shipping_Information__c>();
    if (opportunityLineItemToBeInserted != null) {
      for (
        OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemToBeInserted
      ) {
        Shipping_Information__c shippingInformationObj = new Shipping_Information__c();
        shippingObjectList.add(shippingInformationObj);
      }
    }
    if (shippingObjectList != null && shippingObjectList.size() > 0)
      insert shippingObjectList;

    integer index = 0;
    if (
      opportunityLineItemToBeInserted != null &&
      opportunityLineItemToBeInserted.size() > 0
    ) {
      for (
        OpportunityLineItem__c clonedOpportunityLineItem : opportunityLineItemToBeInserted
      ) {
        clonedOpportunityLineItem.Shipping_Information__c = shippingObjectList.get(
            index++
          )
          .id;
        updateOpportunityLineItem.add(clonedOpportunityLineItem);
      }
      update updateOpportunityLineItem;
    }
    ////Artworks attachments to be copied
    //
    List<Id> artworkIds = new List<Id>();
    if (
      opportunityLineItemArtworkList != null &&
      opportunityLineItemArtworkList.Size() > 0
    ) {
      for (
        OpportunityLineItem_ArtWork__c artwork : opportunityLineItemArtworkList
      ) {
        artworkIds.add(artwork.Id);
      }
    }
    if (artworkIds != null && artworkIds.Size() > 0) {
      List<ContentDocumentLink> allAttachmentRelatedToArtworks = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :artworkIds
      ];

      List<ContentDocumentLink> clonedAttachmentList = new List<ContentDocumentLink>();
      if (
        allAttachmentRelatedToArtworks != null &&
        allAttachmentRelatedToArtworks.Size() > 0
      ) {
        for (ContentDocumentLink attachment : allAttachmentRelatedToArtworks) {
          //  artworkAttachmentMap.put(attachment.LinkedEntityId,attachment);
          if (newAndOldArtwoksMap.get(attachment.LinkedEntityId) != null) {
            ContentDocumentLink attach = new ContentDocumentLink();
            attach = attachment.Clone();
            attach.LinkedEntityId = newAndOldArtwoksMap.get(
                attachment.LinkedEntityId
              )
              .id;
            attach.ShareType = 'V';
            clonedAttachmentList.add(attach);
          }
        }
      }
      insert clonedAttachmentList;
    }

    EmailTemplate emailTemplate = [
      SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE name = 'Credits Approval Email'
    ];
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    for (Order order : listOfDisableOrders) {
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      //message.setTargetObjectId(userId);
      message.setSaveAsActivity(false);
      message.setTemplateID(emailTemplate.Id);
      message.setSubject('Request for Updating Credits');
      String htmlBody = emailTemplate.HtmlValue;
      if (
        orderEstimateMap != null &&
        order.OpportunityId != null &&
        orderEstimateMap.get(order.OpportunityId).Id != null
      ) {
        htmlBody = htmlBody.replace(
          '{!Estimate__c.Id}',
          orderEstimateMap.get(order.OpportunityId).Id
        );
        htmlBody = htmlBody.replace('{!Opportunity.Id}', order.OpportunityId);
        htmlBody = htmlBody.replace(
          '{!Opportunity.Name}',
          orderOpportunityMap.get(order.OpportunityId).Name
        );
        htmlBody = htmlBody.replace(
          '{!User.Id}',
          oppUserMap.get(order.OpportunityId).Id
        );
        htmlBody = htmlBody.replace(
          '{!baseurl}',
          URL.getSalesforceBaseUrl().toExternalForm()
        );
        htmlBody = htmlBody.replace(
          '{usingCredits}',
          String.valueOf(orderCreditsMap.get(order.OpportunityId))
        );
        htmlBody = htmlBody.replace(
          '{!User.Name}',
          oppUserMap.get(order.OpportunityId).Name
        );
        if (
          oppUserMap != null &&
          oppUserMap.get(order.OpportunityId) != null &&
          oppUserMap.get(order.OpportunityId).Design_Bank__c != null
        ) {
          htmlBody = htmlBody.replace(
            '{!User.Design_Bank__c}',
            String.valueOf(oppUserMap.get(order.OpportunityId).Design_Bank__c)
          );
        } else if (
          oppUserMap != null &&
          oppUserMap.get(order.OpportunityId) != null &&
          oppUserMap.get(order.OpportunityId).Design_Bank__c == null
        ) {
          htmlBody = htmlBody.replace('{!User.Design_Bank__c}', '0');
        }
      }
      message.setHtmlBody(htmlBody);
      message.toAddresses = new List<String>{ Label.Design_Team_Email };
      messages.add(message);
      orderEstimateMap.get(order.OpportunityId)
        .Update_Credit_Request_Status__c = 'Pending';
    }
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    update orderEstimateMap.values();
    //// Make invoice paid at QBO Side
    // QuickbookApiCrud.makePayment(orderIdsforMakePayment, OrderAccountMap);
  }
  public static void processEstimateRecords(
    String responseData,
    String accountTitle
  ) {
    Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
      responseData
    );
    Map<String, Object> queryresp = (Map<String, Object>) results.get(
      'QueryResponse'
    );

    if (queryresp.size() > 0) {
      List<Opportunity> toUpdateOpps = new List<Opportunity>();
      List<QBO_Details__c> qboDetailsToUpdate = new List<QBO_Details__c>();
      List<Object> responseList = (List<Object>) queryresp.get('Estimate');
      List<Map<String, Object>> listofMaps = new List<Map<String, Object>>();
      for (Object instance : responseList) {
        listofMaps.add((Map<String, Object>) instance);
      }
      List<String> qbIds = new List<String>();
      for (Map<String, Object> mp : listofMaps) {
        qbIds.add(String.valueOf(mp.get('Id')));
      }
      List<QBO_Details__c> qboDetails = [
        SELECT
          Id,
          QB_Id__c,
          Account__c,
          Id_Type__c,
          Opportunity__c,
          QBO_Account__c,
          Salesforce_Record_Id__c,
          QB_Estimate_Number__c
        FROM QBO_Details__c
        WHERE
          QB_Id__c IN :qbIds
          AND Id_Type__c = 'Estimate'
          AND QBO_Account__c = :accountTitle
      ];

      Set<Id> opportunityIds = new Set<Id>();
      Map<String, Id> mapQbIdOppId = new Map<String, Id>();
      Map<String, Opportunity> qbIdOpportunityMap = new Map<String, Opportunity>();
      Map<Id, QBO_Details__c> opportunityQBODetailsMap = new Map<Id, QBO_Details__c>();
      for (QBO_Details__c qbdetail : qboDetails) {
        mapQbIdOppId.put(qbdetail.QB_Id__c, qbdetail.Opportunity__c);
        opportunityQBODetailsMap.put(qbdetail.Opportunity__c, qbdetail);
        opportunityIds.add(qbdetail.Opportunity__c);
      }

      for (Opportunity opp : [
        SELECT Id, Estimated_Amount__c, Estimate_Number__c, Estimate_QB_Id__c
        FROM Opportunity
        WHERE Id IN :opportunityIds
      ]) {
        QBO_Details__c dbDetails = opportunityQBODetailsMap.get(opp.Id);
        qbIdOpportunityMap.put(dbDetails.QB_Id__c, opp);
      }
      List<Opportunity> oppsToUpdate = new List<Opportunity>();
      for (Map<String, Object> mp : listofMaps) {
        if (qbIdOpportunityMap.get(String.valueOf(mp.get('Id'))) != null) {
          Opportunity opp = qbIdOpportunityMap.get(
            String.valueOf(mp.get('Id'))
          );
          QBO_Details__c dbDetails = opportunityQBODetailsMap.get(opp.Id);
          opp.Amount = Integer.valueOf(mp.get('TotalAmt'));
          dbDetails.QB_Estimate_Number__c = String.valueOf(mp.get('DocNumber'));
          toUpdateOpps.add(opp);
          qboDetailsToUpdate.add(dbDetails);
        }
      }
      update toUpdateOpps;
      update qboDetailsToUpdate;
    }
  }

  public static void processTaxCodes(String responseData, String accountTitle) {
    QuickbookApiCrud.TaxCodeResponse results = (QuickbookApiCrud.TaxCodeResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.TaxCodeResponse.class
    );

    if (results.QueryResponse != null) {
      List<QuickbookApiCrud.TaxCode> taxes = results.QueryResponse.TaxCode;
      List<Tax_Code__c> code = new List<Tax_Code__c>();
      if (taxes != null) {
        Map<String, Id> existingTaxes = new Map<String, Id>();
        for (Tax_Code__c eTax : [
          SELECT Id, Id__c, QBO_Account__c
          FROM Tax_Code__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          existingTaxes.put(eTax.Id__c, eTax.Id);
        }
        for (QuickbookApiCrud.TaxCode tax : taxes) {
          Tax_Code__c c = new Tax_Code__c();
          c.Name = tax.Name != null ? tax.Name : '';
          c.Description__c = tax.Description != null ? tax.Description : '';
          c.Active__c = tax.Active != null ? tax.Active : false;
          c.Hidden__c = tax.Hidden != null ? tax.Hidden : false;
          c.sparse__c = tax.sparse != null ? tax.sparse : false;
          c.Id__c = tax.Id != null ? tax.Id : '';
          c.SyncToken__c = tax.SyncToken != null ? tax.SyncToken : '';
          c.Taxable__c = tax.Taxable != null ? tax.Taxable : false;
          c.Id = existingTaxes.get(c.Id__c);
          code.add(c);
        }
        upsert code;
      }
    }
  }

  /*  public static void processCustomers(String responseData ,String accountTitle)
    {
        QuickbookApiCrud.TaxCodeResponse results= (QuickbookApiCrud.TaxCodeResponse) JSON.deserialize(responseData, QuickbookApiCrud.TaxCodeResponse.class);
        
        if(results.QueryResponse != null){
            List<QuickbookApiCrud.TaxCode> taxes = results.QueryResponse.TaxCode;
            List<Tax_Code__c> code = new List<Tax_Code__c>();
            if(taxes != null){
                Map<String,Id> existingTaxes = new Map<String,Id>();
                for(Tax_Code__c eTax : [Select Id , Id__c,QBO_Account__c
                                        FROM Tax_Code__c
                                        WHERE QBO_Account__c =: accountTitle])
                {
                    existingTaxes.put(eTax.Id__c,eTax.Id);
                }
                for(QuickbookApiCrud.TaxCode tax : taxes){
                    Tax_Code__c c = new Tax_Code__c();
                    c.Name = tax.Name != null ? tax.Name : '' ;
                    c.Description__c = tax.Description != null ? tax.Description : '' ;
                    c.Active__c = tax.Active != null ? tax.Active : false ;
                    c.Hidden__c = tax.Hidden != null ? tax.Hidden : false ;
                    c.sparse__c = tax.sparse != null ? tax.sparse : false ;
                    c.Id__c = tax.Id != null ? tax.Id : '' ;
                    c.SyncToken__c = tax.SyncToken != null ? tax.SyncToken : '' ;
                    c.Taxable__c = tax.Taxable != null ? tax.Taxable : false ;
                    c.Id = existingTaxes.get(c.Id__c);
                    code.add(c);
                }
                upsert code;
            }
        }
    }*/
  public static void processPaymentMethods(
    String responseData,
    String accountTitle
  ) {
    QuickbookApiCrud.PaymentMethodResponse results = (QuickbookApiCrud.PaymentMethodResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.PaymentMethodResponse.class
    );

    if (results.QueryResponse != null) {
      List<QuickbookApiCrud.PaymentMethod> paymentMethods = results.QueryResponse.PaymentMethod;
      List<Payment_Method__c> sfMethods = new List<Payment_Method__c>();
      if (paymentMethods != null) {
        Map<String, Id> existingMethods = new Map<String, Id>();
        for (Payment_Method__c eMethod : [
          SELECT Id, Id__c, QBO_Account__c
          FROM Payment_Method__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          existingMethods.put(eMethod.Id__c, eMethod.Id);
        }
        for (QuickbookApiCrud.PaymentMethod method : paymentMethods) {
          Payment_Method__c c = new Payment_Method__c();
          c.Name = method.Name != null ? method.Name : '';
          c.Type__c = method.Type != null ? method.Type : '';
          c.Active__c = method.Active != null ? method.Active : false;
          c.sparse__c = method.sparse != null ? method.sparse : false;
          c.Id__c = method.Id != null ? method.Id : '';
          c.SyncToken__c = method.SyncToken != null ? method.SyncToken : '';
          c.Id = existingMethods.get(c.Id__c);
          sfMethods.add(c);
        }
        upsert sfMethods;
      }
    }
  }
  public static void processSalesTerm(
    String responseData,
    String accountTitle
  ) {
    QuickbookApiCrud.SalesTermResponse results = (QuickbookApiCrud.SalesTermResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.SalesTermResponse.class
    );

    if (results.QueryResponse != null) {
      List<QuickbookApiCrud.Term> terms = results.QueryResponse.Term;
      List<Sales_Term__c> sfTerms = new List<Sales_Term__c>();
      if (terms != null) {
        Map<String, Id> existingTerms = new Map<String, Id>();
        for (Sales_Term__c eTerm : [
          SELECT Id, Id__c, QBO_Account__c
          FROM Sales_Term__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          existingTerms.put(eTerm.Id__c, eTerm.Id);
        }
        for (QuickbookApiCrud.Term term : terms) {
          Sales_Term__c c = new Sales_Term__c();
          c.Name = term.Name != null ? term.Name : '';
          c.Type__c = term.Type != null ? term.Type : '';
          c.Active__c = term.Active != null ? term.Active : false;
          c.sparse__c = term.sparse != null ? term.sparse : false;
          c.Id__c = term.Id != null ? term.Id : '';
          c.SyncToken__c = term.SyncToken != null ? term.SyncToken : '';
          c.DueDays__c = term.DueDays != null ? term.DueDays : 0;
          c.DiscountDays__c = term.DiscountDays != null ? term.DiscountDays : 0;
          c.Id = existingTerms.get(c.Id__c);
          sfTerms.add(c);
        }
        upsert sfTerms;
      }
    }
  }
  public static void processClasses(String responseData, String accountTitle) {
    responseData = responseData.replaceFirst('Class', 'Clas');
    QuickbookApiCrud.ClassValueResponse results = (QuickbookApiCrud.ClassValueResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.ClassValueResponse.class
    );

    if (results.QueryResponse != null) {
      List<QuickbookApiCrud.Classr> classes = results.QueryResponse.Clas;
      List<Class__c> sfClass = new List<Class__c>();
      if (classes != null) {
        Map<String, Id> existingClasses = new Map<String, Id>();
        for (Class__c eClass : [
          SELECT Id, Id__c, QBO_Account__c
          FROM Class__c
          WHERE QBO_Account__c = :accountTitle
        ]) {
          existingClasses.put(eClass.Id__c, eClass.Id);
        }
        for (QuickbookApiCrud.Classr sClass : classes) {
          Class__c c = new Class__c();
          c.Name = sClass.Name != null ? sClass.Name : '';
          c.Fully_Qualified_Name__c = sClass.FullyQualifiedName != null
            ? sClass.FullyQualifiedName
            : '';
          c.SubClass__c = sClass.SubClass != null ? sClass.SubClass : false;
          c.Active__c = sClass.Active != null ? sClass.Active : false;
          c.sparse__c = sClass.sparse != null ? sClass.sparse : false;
          c.Id__c = sClass.Id != null ? sClass.Id : '';
          c.SyncToken__c = sClass.SyncToken != null ? sClass.SyncToken : '';
          c.Id = existingClasses.get(c.Id__c);
          sfClass.add(c);
        }
        upsert sfClass;
      }
    }
  }

  public static Date getDateFromString(String input) {
    String[] arrDate = input.split('-');
    if (arrDate != null) {
      Date datetmp = Date.newInstance(
        Integer.valueOf(arrDate[0]),
        Integer.valueOf(arrDate[1]),
        Integer.valueOf(arrDate[2])
      );
      return datetmp;
    }
    return null;
  }

  public static String QuickBookRecordGetter(
    String query,
    List<String> authorizationCredentials,
    String accountTitle
  ) {
    try {
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      Http http = new Http();
      request.setMethod('GET');
      request.setTimeout(120000); // 2 minutes
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
        SELECT
          Id,
          QBO_Custom_Field_1__c,
          QBO_Custom_Field_1_Id__c,
          QB_Access_token_End_Point__c,
          QB_API_End_Point__c,
          QB_Authorization_End_Point__c,
          QB_Authorization_Scope__c,
          QB_Client_Id__c,
          QB_Client_Secret__c,
          QB_ID__c,
          QB_Redirect_URI__c,
          QB_Timezone__c,
          Quickbooks_Account_Tittle__c,
          Service_Id_Breakdown__c,
          Service_Id_Brokerage__c,
          Service_Id_Duty__c,
          Service_Id_FixedCharges__c,
          Service_Id_InboundFreight__c,
          Service_Id_RunCharges__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :accountTitle
      ];

      if (Test.isRunningTest()) {
        if (query.contains('Customer')) {
          request.setEndPoint('http://test.com/test/getCustomer');
        } else if (query.contains('Invoice')) {
          request.setEndPoint('http://test.com/test/getInvoice');
        } else if (query.contains('Vendor')) {
          request.setEndPoint('http://test.com/test/getVendor');
        } else if (query.contains('Estimate')) {
          request.setEndPoint('http://test.com/test/getEstimate');
        } else if (query.contains('TaxCode')) {
          request.setEndPoint('http://test.com/test/getTaxCode');
        } else if (query.contains('PaymentMethod')) {
          request.setEndPoint('http://test.com/test/getPaymentMethod');
        } else if (query.contains('Term')) {
          request.setEndPoint('http://test.com/test/getTerm');
        } else if (query.contains('Class')) {
          request.setEndPoint('http://test.com/test/getClass');
        } else if (query.contains('syncToken')) {
          request.setEndpoint('http://test.com/test/getSyncToken');
        }
      } else {
        if (accountConfiguration.size() > 0)
          request.setEndPoint(
            accountConfiguration[0].QB_API_End_Point__c +
              '/v3/company/' +
              authorizationCredentials[2] +
              '/query?query=' +
              EncodingUtil.URLENCODE(query, 'UTF-8')
          );
      }
      System.debug('query' + query);
      request.setHeader('Accept', 'application/json');
      request.setHeader('Content-Type', 'application/json;charset=UTF-8');

      if (authorizationCredentials[1] != null) {
        request.setHeader(
          'Authorization',
          'Bearer ' + authorizationCredentials[0]
        );
        if (!Test.isRunningTest()) {
          response = http.send(request);
        } else {
          response = new HttpResponse();
          response.setHeader('Content-Type', 'Application/json');
          if (query.contains('Invoice')) {
            List<Opportunity> opps = [SELECT id FROM Opportunity LIMIT 1];
            Id oppId;
            if (opps != null && opps.size() > 0) {
              oppId = opps.get(0).id;
            }
            response.setBody(
              '{' +
                '"QueryResponse":{' +
                '"startPosition":1,' +
                '"totalCount":1,' +
                '"maxResults":1,' +
                '"Invoice":[' +
                '{' +
                '"DocNumber":"1070",' +
                '"SyncToken":"0",' +
                '"domain":"QBO",' +
                '"Balance":150.0,' +
                '"BillAddr":{' +
                '"City":"Bayshore",' +
                '"Line1":"4581FinchSt.",' +
                '"PostalCode":"94326",' +
                '"Lat":"INVALID",' +
                '"Long":"INVALID",' +
                '"CountrySubDivisionCode":"CA",' +
                '"Id":"2"' +
                '},' +
                '"TxnDate":"2015-07-24",' +
                '"TotalAmt":150.0,' +
                '"CustomerRef":{' +
                '"name":"Amy\'sBirdSanctuary",' +
                '"value":"123"' +
                '},' +
                '"ShipAddr":{' +
                '"City":"Bayshore",' +
                '"Line1":"4581FinchSt.",' +
                '"PostalCode":"94326",' +
                '"Lat":"INVALID",' +
                '"Long":"INVALID",' +
                '"CountrySubDivisionCode":"CA",' +
                '"Id":"109"' +
                '},' +
                '"LinkedTxn":[],' +
                '"DueDate":"2015-08-23",' +
                '"PrintStatus":"NeedToPrint",' +
                '"Deposit":0,' +
                '"sparse":false,' +
                '"EmailStatus":"NotSet",' +
                '"Line":[' +
                '{' +
                '"LineNum":1,' +
                '"Amount":150.0,' +
                '"SalesItemLineDetail":{' +
                '"TaxCodeRef":{' +
                '"value":"NON"' +
                '},' +
                '"ItemRef":{' +
                '"name":"Services",' +
                '"value":"1"' +
                '}' +
                '},' +
                '"Id":"1",' +
                '"DetailType":"SalesItemLineDetail"' +
                '},' +
                '{' +
                '"DetailType":"SubTotalLineDetail",' +
                '"Amount":150.0,' +
                '"SubTotalLineDetail":{}' +
                '}' +
                '],' +
                '"ApplyTaxAfterDiscount":false,' +
                '"CustomField":[' +
                '{' +
                '"DefinitionId":"1",' +
                '"Type":"StringType",' +
                '"Name":"Crew#"' +
                '}' +
                '],' +
                '"Id":"239",' +
                '"TxnTaxDetail":{' +
                '"TotalTax":0' +
                '},' +
                '"MetaData":{' +
                '"CreateTime":"2015-07-24T10:35:08-07:00",' +
                '"LastUpdatedTime":"2015-07-24T10:35:08-07:00"' +
                '}' +
                '}' +
                ']' +
                '},' +
                '"time":"2015-07-24T10:38:50.01-07:00"' +
                '}'
            );
          } else if (query.contains('Estimate')) {
            response.setBody(
              '{' +
                '"QueryResponse":{' +
                '"startPosition":1,' +
                '"totalCount":1,' +
                '"maxResults":1,' +
                '"Estimate":[' +
                '{' +
                '"DocNumber":"1070",' +
                '"SyncToken":"0",' +
                '"domain":"QBO",' +
                '"Balance":150.0,' +
                '"BillAddr":{' +
                '"City":"Bayshore",' +
                '"Line1":"4581FinchSt.",' +
                '"PostalCode":"94326",' +
                '"Lat":"INVALID",' +
                '"Long":"INVALID",' +
                '"CountrySubDivisionCode":"CA",' +
                '"Id":"2"' +
                '},' +
                '"TxnDate":"2015-07-24",' +
                '"TotalAmt":150.0,' +
                '"CustomerRef":{' +
                '"name":"Amy\'sBirdSanctuary",' +
                '"value":"1"' +
                '},' +
                '"ShipAddr":{' +
                '"City":"Bayshore",' +
                '"Line1":"4581FinchSt.",' +
                '"PostalCode":"94326",' +
                '"Lat":"INVALID",' +
                '"Long":"INVALID",' +
                '"CountrySubDivisionCode":"CA",' +
                '"Id":"109"' +
                '},' +
                '"LinkedTxn":[],' +
                '"DueDate":"2015-08-23",' +
                '"PrintStatus":"NeedToPrint",' +
                '"Deposit":0,' +
                '"sparse":false,' +
                '"EmailStatus":"NotSet",' +
                '"Line":[' +
                '{' +
                '"LineNum":1,' +
                '"Amount":150.0,' +
                '"SalesItemLineDetail":{' +
                '"TaxCodeRef":{' +
                '"value":"NON"' +
                '},' +
                '"ItemRef":{' +
                '"name":"Services",' +
                '"value":"1"' +
                '}' +
                '},' +
                '"Id":"1",' +
                '"DetailType":"SalesItemLineDetail"' +
                '},' +
                '{' +
                '"DetailType":"SubTotalLineDetail",' +
                '"Amount":150.0,' +
                '"SubTotalLineDetail":{}' +
                '}' +
                '],' +
                '"ApplyTaxAfterDiscount":false,' +
                '"CustomField":[' +
                '{' +
                '"DefinitionId":"1",' +
                '"Type":"StringType",' +
                '"Name":"Crew#"' +
                '}' +
                '],' +
                '"Id":"239",' +
                '"TxnTaxDetail":{' +
                '"TotalTax":0' +
                '},' +
                '"MetaData":{' +
                '"CreateTime":"2015-07-24T10:35:08-07:00",' +
                '"LastUpdatedTime":"2015-07-24T10:35:08-07:00"' +
                '}' +
                '}' +
                ']' +
                '},' +
                '"time":"2015-07-24T10:38:50.01-07:00"' +
                '}'
            );
          } else if (query.contains('TaxCode')) {
            response.setBody(
              '   {  ' +
                '    "QueryResponse": {  ' +
                '     "TaxCode": [  ' +
                '      {  ' +
                '       "Name": "TAX",  ' +
                '       "Description": "TAX",  ' +
                '       "Taxable": true,  ' +
                '       "TaxGroup": false,  ' +
                '       "Id": "TAX",  ' +
                '       "MetaData": {  ' +
                '        "CreateTime": "2019-08-04T01:03:00-07:00",  ' +
                '        "LastUpdatedTime": "2019-08-04T01:03:00-07:00"  ' +
                '       }  ' +
                '      }  ' +
                '   ],  ' +
                '     "startPosition": 1,  ' +
                '     "maxResults": 1,  ' +
                '     "totalCount": 1  ' +
                '    },  ' +
                '    "time": "2019-08-28T01:56:56.105-07:00"  ' +
                '  }  '
            );
          } else if (query.contains('PaymentMethod')) {
            response.setBody(
              '   {  ' +
                '    "QueryResponse": {  ' +
                '     "PaymentMethod": [  ' +
                '      {  ' +
                '       "Name": "American Express",  ' +
                '       "Active": true,  ' +
                '       "Type": "CREDIT_CARD",  ' +
                '       "domain": "QBO",  ' +
                '       "sparse": false,  ' +
                '       "Id": "6",  ' +
                '       "SyncToken": "0",  ' +
                '       "MetaData": {  ' +
                '        "CreateTime": "2019-07-18T14:42:05-07:00",  ' +
                '        "LastUpdatedTime": "2019-07-18T14:42:05-07:00"  ' +
                '       }  ' +
                '      }  ' +
                '   ],  ' +
                '     "startPosition": 1,  ' +
                '     "maxResults": 1  ' +
                '    },  ' +
                '    "time": "2019-08-28T01:59:32.631-07:00"  ' +
                '  }  '
            );
          } else if (query.contains('Term')) {
            response.setBody(
              '   {  ' +
                '    "QueryResponse": {  ' +
                '     "Term": [  ' +
                '      {  ' +
                '       "Name": "Due on receipt",  ' +
                '       "Active": true,  ' +
                '       "Type": "STANDARD",  ' +
                '       "DueDays": 0,  ' +
                '       "DiscountDays": 0,  ' +
                '       "domain": "QBO",  ' +
                '       "sparse": false,  ' +
                '       "Id": "1",  ' +
                '       "SyncToken": "0",  ' +
                '       "MetaData": {  ' +
                '        "CreateTime": "2019-07-18T14:41:49-07:00",  ' +
                '        "LastUpdatedTime": "2019-07-18T14:41:49-07:00"  ' +
                '       }  ' +
                '      }  ' +
                '     ],  ' +
                '     "startPosition": 1,  ' +
                '     "maxResults": 1  ' +
                '    },  ' +
                '    "time": "2019-08-28T02:01:18.525-07:00"  ' +
                '  }  '
            );
          } else if (query.contains('Class')) {
            response.setBody(
              '   {  ' +
                '    "QueryResponse": {  ' +
                '     "Class": [  ' +
                '      {  ' +
                '       "Name": "Ali Imran",  ' +
                '       "SubClass": false,  ' +
                '       "FullyQualifiedName": "Ali Imran",  ' +
                '       "Active": true,  ' +
                '       "domain": "QBO",  ' +
                '       "sparse": false,  ' +
                '       "Id": "5000000000000130536",  ' +
                '       "SyncToken": "6",  ' +
                '       "MetaData": {  ' +
                '        "CreateTime": "2019-08-27T09:37:28-07:00",  ' +
                '        "LastUpdatedTime": "2019-08-27T23:36:28-07:00"  ' +
                '       }  ' +
                '      }  ' +
                '     ],  ' +
                '     "startPosition": 1,  ' +
                '     "maxResults": 1,  ' +
                '     "totalCount": 1  ' +
                '    },  ' +
                '    "time": "2019-08-28T02:02:07.649-07:00"  ' +
                '  }  '
            );
          } else if (query.contains('syncToken')) {
            response.setBody(
              '{' +
                '"QueryResponse": {' +
                '"Estimate": [' +
                '{' +
                '"sparse": true,' +
                '"Id": "1",' +
                '"SyncToken": "0",' +
                '"Line": [],' +
                '"BillAddr": {' +
                '"Id": "8789"' +
                '},' +
                '"ShipFromAddr": {' +
                '"Id": "8790"' +
                '}' +
                '},' +
                '{' +
                '"sparse": true,' +
                '"Id": "43603",' +
                '"SyncToken": "2",' +
                '"Line": [],' +
                '"BillAddr": {' +
                '"Id": "8773"' +
                '}' +
                '},' +
                '{' +
                '"sparse": true,' +
                '"Id": "43600",' +
                '"SyncToken": "1",' +
                '"Line": [],' +
                '"BillAddr": {' +
                '"Id": "8069"' +
                '}' +
                '},' +
                '{' +
                '"sparse": true,' +
                '"Id": "43601",' +
                '"SyncToken": "1",' +
                '"Line": [],' +
                '"BillAddr": {' +
                '"Id": "8046"' +
                '}' +
                '},' +
                '{' +
                '"sparse": true,' +
                '"Id": "43605",' +
                '"SyncToken": "1",' +
                '"Line": [],' +
                '"BillAddr": {' +
                '"Id": "5024"' +
                '}' +
                '}' +
                '],' +
                '"startPosition": 1,' +
                '"maxResults": 5' +
                '},' +
                ' "time": "2020-03-05T20:41:30.779-08:00"' +
                '}'
            );
          }

          response.setStatusCode(200);
        }
        System.debug('response: ' + response.getBody());
        if (response.getStatusCode() == 200) {
          String resp = response.getBody();
          return resp;
        } else
          err = response.getBody();
      }
      err = 'Authentication Failed';
    } catch (Exception e) {
      system.debug(e.getMessage());
      system.debug(e.getStackTraceString());
    }
    return null;
  }
  public static Map<String, Object> refreshToken(
    String refreshToken,
    String accountTitle
  ) {
    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c = :accountTitle
    ];
    if (accountConfiguration != null && accountConfiguration.size() > 0) {
      String encodedString = EncodingUtil.base64Encode(
        Blob.valueOf(
          accountConfiguration[0].QB_Client_Id__c +
            ':' +
            accountConfiguration[0].QB_Client_Secret__c
        )
      );
      String endPoint;
      if (Test.isRunningTest()) {
        endPoint = 'http://test.com/test/refreshtoken';
      } else {
        endPoint = accountConfiguration[0].QB_Access_token_End_Point__c;
      }
      String requestBody =
        'grant_type=refresh_token&refresh_token=' + refreshToken;
      HttpRequest httpReq = new HttpRequest();
      HttpResponse httpRes = new HttpResponse();
      Http http = new Http();
      httpReq.setMethod('POST');
      httpReq.setEndPoint(endPoint);
      httpReq.setHeader('Host', 'oauth.platform.intuit.com');
      httpReq.setHeader('Accept', 'application/json');
      httpReq.setHeader('Authorization', 'Basic ' + encodedString);
      httpReq.setHeader('Cache-Control', 'no-cache');
      httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
      httpReq.setBody(requestBody);
      if (!Test.isRunningTest()) {
        httpRes = http.send(httpReq);
      }
      if (httpRes.getStatusCode() == 200) {
        return (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
      }
    }
    return null;
  }
  public static void updateLastScheduleTime(String accountTitle) {
    SchedulerLastRun__c sr = [
      SELECT LastExecution__c
      FROM SchedulerLastRun__c
      WHERE accountTitle__c = :accountTitle
      LIMIT 1
    ];
    sr.LastExecution__c = System.now();
    update sr;
  }
  public static void SendEmail(string subject, string body) {
    List<string> recepients = System.Label.ErrorEmailRecepients.split(';');
    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    email.setToAddresses(recepients);
    email.setSubject(subject);
    email.setHtmlBody(body);
    Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
  }

  public static QBOSync_Errors__c addQBError(
    string objectName,
    string qbError
  ) {
    Boolean isNewError = true;
    QBOSync_Errors__c errorRecord = new QBOSync_Errors__c();
    List<QBOSync_Errors__c> errorList = [
      SELECT Id, Name, count__c, Error_Message__c
      FROM QBOSync_Errors__c
      WHERE Name = :objectName AND resolved__c = FALSE
    ];
    System.debug('errorList ' + errorList.size() + ' objectName ' + objectName);
    if (errorList.size() > 0) {
      for (QBOSync_Errors__c existingError : errorList) {
        if (
          existingError.Error_Message__c != null &&
          existingError.Error_Message__c.equals(qbError)
        ) {
          errorRecord.Id = existingError.Id;
          errorRecord.count__c = existingError.count__c + 1;
          isNewError = false;
          break;
        }
      }
    }

    if (isNewError) {
      errorRecord.Name = objectName;
      errorRecord.count__c = 1;
      errorRecord.Error_Message__c = qbError;
    }

    return errorRecord;
  }

  public static String getDataClient(Datetime timeThreashold) {
    System.debug('timeThreashold ' + timeThreashold);
    List<QBOSync_Errors__c> errorList = [
      SELECT Name, Count__c, Error_Message__c
      FROM QBOSync_Errors__c
      WHERE resolved__c = :false AND LastModifiedDate > :timeThreashold
      ORDER BY LastModifiedDate, Count__c DESC
      LIMIT 10
    ];
    String errors = '';
    for (QBOSync_Errors__c error : errorList) {
      if (error.Error_Message__c.containsIgnoreCase('Authentication Failed')) {
        errors = error.Error_Message__c + '\n';
      }
    }
    return errors;
  }

  public static String getData() {
    List<QBOSync_Errors__c> errorList = [
      SELECT Name, Count__c, Error_Message__c
      FROM QBOSync_Errors__c
      WHERE resolved__c = :false
      ORDER BY LastModifiedDate, Count__c DESC
      LIMIT 10
    ];
    String errors = '';
    for (QBOSync_Errors__c error : errorList) {
      errors = error.Error_Message__c + '\n';
    }
    return errors;
  }

  @future(callout=true)
  public static void syncPFA_QBOInvoice_Changes(String accountTitle) {
    SchedulerLastRun__c sr = [
      SELECT LastExecution__c, Last_Sent_Email_Time__c, LastEmailSendToClient__c
      FROM SchedulerLastRun__c
      WHERE accountTitle__c = :accountTitle
      LIMIT 1
    ];

    Datetime lastExecution = sr.LastExecution__c;
    Datetime lastSentEmailTime = sr.Last_Sent_Email_Time__c;
    Datetime LastEmailSendToClient = sr.LastEmailSendToClient__c;
    if (LastEmailSendToClient != null) {
      LastEmailSendToClient = lastSentEmailTime;
    }

    String lastExecutionTime = lastExecution.format(
      'yyyy-MM-dd',
      UserInfo.getTimeZone().getID()
    );
    System.debug(
      'lastExecutionTime ==> ' +
      lastExecution.format('yyyy-MM-dd', UserInfo.getTimeZone().getID())
    );

    List<QBOSync_Errors__c> errorList = new List<QBOSync_Errors__c>();

    List<QB_Credentials__c> qbcList = [
      SELECT Id, Access_token__c, Refresh_token__c, realmid__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c = :accountTitle
    ];

    if (qbcList.size() > 0) {
      List<String> authorizationCredentials = new List<String>();
      authorizationCredentials.add(qbcList[0].Access_token__c);
      authorizationCredentials.add(qbcList[0].Refresh_token__c);
      authorizationCredentials.add(qbcList[0].realmid__c);
      //MetaData.LastUpdatedTime < '2020-11-10T23:39:33'
      String query =
        'Select * from Invoice where MetaData.LastUpdatedTime > \'' +
        lastExecutionTime +
        '\'';
      //String query = 'Select * from Invoice where MetaData.LastUpdatedTime > \'2021-05-03\'';
      String invoices = QuickBookRecordGetter(
        query,
        authorizationCredentials,
        accountTitle
      );

      // query = 'Select * from Class where MetaData.LastUpdatedTime > \''+lastExecutionTime+'\'';
      // String classes = QuickBookRecordGetter(query, authorizationCredentials,accountTitle);
      boolean issueOccurred = false;
      System.debug('Invoices Response ' + invoices);
      if (invoices != null) {
        try {
          processPFAInvoiceRecords(invoices, accountTitle);
        } catch (Exception e) {
          issueOccurred = true;
          String error =
            'Exception Occurred in Invoice Processing : ' +
            e.getMessage() +
            e.getStackTraceString();
          System.debug(error);
          errorList.add(addQBError('Invoice', error));
        }
      } else {
        issueOccurred = true;
        System.debug('Invoice: ' + err);
        errorList.add(addQBError('Invoice', err));
      }

      if (issueOccurred == false) {
        updateLastScheduleTime(accountTitle);
      }

      upsert errorList;

      if (
        ((System.now().getTime() - lastSentEmailTime.getTime()) / 60000) >= 60
      ) {
        if (getData() != '') {
          SendEmail('Errors list for last 1 hour', getData());
          sr.Last_Sent_Email_Time__c = System.now();

          try {
            Integer thresholdValue = Integer.valueOf(
              Label.Threshold_QBO_Authentication_Error_Emails
            );
            if (
              ((System.now().getTime() - LastEmailSendToClient.getTime()) /
              60000) >= thresholdValue
            ) {
              Datetime dateThreshold = System.Now();
              dateThreshold = dateThreshold.addMinutes((thresholdValue * -1));
              if (getDataClient(dateThreshold) != '') {
                String subjectEmail =
                  'IMPORTANT | QBO (' +
                  accountTitle +
                  ')  Authentication Required ';
                String body =
                  '<h2>Authentication Required </h2><br/>' +
                  '<br/><br/>Click to authenticate <a href="' +
                  Label.default_url +
                  'lightning/n/Quickbook_Authentication">Authenticate Now.</a>' +
                  '<br/><br/>';
                QuickbookApiCrud.sendEmailAuthenticationClient(
                  subjectEmail,
                  body
                );
                sr.LastEmailSendToClient__c = System.now();
              }
            }
          } catch (Exception ex) {
          }
          update sr;
        }
      }
    }
  }

  public static void processPFAInvoiceRecords(
    String responseData,
    String accountTitle
  ) {
    QuickbookApiCrud.InvoiceResponse results = (QuickbookApiCrud.InvoiceResponse) JSON.deserialize(
      responseData,
      QuickbookApiCrud.InvoiceResponse.class
    );
    if (results.QueryResponse != null) {
      Map<String, Id> customerRefMap = new Map<String, Id>();
      Map<Id, Id> opportunityIdAccountMap = new Map<Id, Id>();
      Set<String> QBOInvoiceIds = new Set<String>();
      Map<String, QuickbookApiCrud.Invoice> qbInvoiceIdvsInvoiceMap = new Map<String, QuickbookApiCrud.Invoice>();
      List<QuickbookApiCrud.Invoice> invoices = results.QueryResponse.Invoice;
      if (invoices != null) {
        for (QuickbookApiCrud.Invoice inv : invoices) {
          QBOInvoiceIds.add(inv.Id);
          qbInvoiceIdvsInvoiceMap.put(inv.Id, inv);
        }

        List<PFA_Event_Billing__c> pfaEventBillingList = [
          SELECT
            Id,
            Name,
            Account__c,
            PFA_Event__c,
            PFA_Campaign__c,
            QBO_Invoice_Number__c,
            Bill_Date__c,
            QBO_Invoice_Detail__c,
            QBO_Invoice_Id__c,
            Bill_Due_Date__c,
            Payment_Link__c,
            Total_Amount__c,
            Quickbooks_Instance__c
          FROM PFA_Event_Billing__c
          WHERE QBO_Invoice_Id__c IN :QBOInvoiceIds
        ];

        for (PFA_Event_Billing__C eventBillingRec : pfaEventBillingList) {
          QuickbookApiCrud.Invoice qboInvoice = qbInvoiceIdvsInvoiceMap.get(
            eventBillingRec.QBO_Invoice_Id__c
          );
          if (qboInvoice.Balance == 0) {
            eventBillingRec.Invoice_Status__c = 'Paid';
          }
          eventBillingRec.Total_Amount__c = qboInvoice.TotalAmt;
          eventBillingRec.Balance_Due__c = qboInvoice.Balance;
          eventBillingRec.Bill_Due_Date__c = qboInvoice.DueDate != null
            ? getDateFromString(qboInvoice.DueDate)
            : null;
          eventBillingRec.Updated_From_QBO_Scheduler__c = true;
        }
        update pfaEventBillingList;
      }
    }
  }
}
