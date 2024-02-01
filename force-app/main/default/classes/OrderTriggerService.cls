public class OrderTriggerService {
  private static Boolean firstRun = true;
  public static void checkFunctionalOrder(List<Order> triggerNew) {
    for (Order order : triggerNew) {
      if (!order.Valid_Credits__c) {
        //order.addError('You can not edit order without adjusting credits to be used');
      }
    }
  }

  // Converted Process builder Order Process into this function
  public static void OrderProcess(List<Order> triggerNew, Boolean isNew) {
    Set<Id> opportunityIds = new Set<Id>();

    for (Order singleOrder : triggerNew) {
      if (isNew && singleOrder.OpportunityId != null) {
        opportunityIds.add(singleOrder.OpportunityId);
      }
    }

    Map<Id, Opportunity> opportunityMap;
    if (!opportunityIds.isEmpty()) {
      opportunityMap = new Map<Id, Opportunity>(
        [
          SELECT Id, Estimate_Number__c, Estimated_Amount__c
          FROM Opportunity
          WHERE Id IN :opportunityIds
        ]
      );
    }
    for (Order singleOrder : triggerNew) {
      if (isNew && singleOrder.OpportunityId != null) {
        Opportunity relatedOpportunity = opportunityMap.get(
          singleOrder.OpportunityId
        );
        singleOrder.Estimate_Number__c = relatedOpportunity.Estimate_Number__c;
        singleOrder.Estimated_Amount__c = relatedOpportunity.Estimated_Amount__c;
      }
      if (singleOrder.Invoice_Terms__c != null) {
        if (singleOrder.Invoice_Terms__c.contains('Net')) {
          if (singleOrder.Status == '01_-_Waiting_for_Client_Payment') {
            singleOrder.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
            continue;
          }
        }
      }

      if (singleOrder.Invoice_Terms__c != null) {
        if (
          singleOrder.Invoice_Terms__c.contains('50% Down') &&
          singleOrder.Amount_Received__c > 0
        ) {
          if (singleOrder.Status == '01_-_Waiting_for_Client_Payment') {
            singleOrder.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
            continue;
          }
        }
      }
    }
  }

  public static void deleteQboRecords(
    List<Order> triggerNew,
    Map<Id, Order> oldOrderMap
  ) {
    Set<Id> oppIds = new Set<Id>();
    Set<Id> orderIds = oldOrderMap.keySet();
    for (Id key : oldOrderMap.keySet()) {
      oppIds.add(oldOrderMap.get(key).OpportunityId);
    }
    List<Qbo_Details__c> qboRecords = [
      SELECT
        Id,
        Account__c,
        Id_Type__c,
        Opportunity__c,
        Salesforce_Record_Id__c,
        Work_order__c
      FROM QBO_Details__c
      WHERE
        Opportunity__c = :oppIds
        AND Work_order__c = :orderIds
        AND Id_Type__c = 'Workorder'
    ];
    delete qboRecords;
  }
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Order> newValues,
    Map<Id, Order> oldValues
  ) {
    List<Id> relatedOpportunities = new List<Id>();
    for (Order ord : newValues) {
      relatedOpportunities.add(ord.OpportunityId);
    }
    List<Opportunity> updatedOpportunity = new List<Opportunity>();
    if (relatedOpportunities != null && relatedOpportunities.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :relatedOpportunities
        ]
      );
      for (Order ord : newValues) {
        Order relatedOldValue = oldValues.get(ord.Id);
        if (
          relatedOldValue.PoDate != ord.PoDate ||
          relatedOldValue.PoNumber != ord.PoNumber ||
          relatedOldValue.EffectiveDate != ord.EffectiveDate ||
          relatedOldValue.Invoice_Terms__c != ord.Invoice_Terms__c ||
          relatedOldValue.OrderNumber != ord.OrderNumber ||
          relatedOldValue.Approved_Date__c != ord.Approved_Date__c ||
          relatedOldValue.Approved_By__c != ord.Approved_By__c
        ) {
          if (opportunitiesMap.containsKey(ord.OpportunityId)) {
            Opportunity opp = opportunitiesMap.get(ord.OpportunityId);
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          }
        }
      }
      update updatedOpportunity;
    }
  }
  public static void setQBOInstanceDetails(List<Order> newOrders) {
    for (Order ord : newOrders) {
      ord.QBO_Invoice_Detail__c =
        ord.Quickbooks_Instance__c +
        ' (' +
        ord.Invoice_Number__c +
        ')';
    }
  }

  public static void setPriceBook(List<Order> newOrders) {
    for (Order ord : newOrders) {
      ord.Pricebook2Id = '01sf40000087iazAAA';
    }
  }

  public static void orderStatusChanged(
    List<Order> newOrders,
    Map<Id, Order> oldOrders
  ) {
    //replacement of process builder "stage time limit alerts"
    for (Order order : newOrders) {
      if (oldOrders != null) {
        if (order.Status != oldOrders.get(order.id).Status) {
          order.MockupClientApproval24HourEmailSent__c = false;
          order.OrderBlankApprovedDeposit24HourEmailSent__c = false;
          order.ProofSentWaitingApproval24HourEmailSent__c = false;
        }
      }
    }
  }

  public static void OrderFillArtApproval(List<Order> newOrders) {
    //replacement of process builder "Set Art Approval Email/Billing Contact - WO"
    Set<Id> accountIds = new Set<Id>();
    for (Order ord : newOrders) {
      if (ord.Art_Approval_Email__c == null || ord.Billing_Contact__c == null) {
        accountIds.add(ord.AccountId);
      }
    }

    Map<Id, Account> accountMap = new Map<Id, Account>(
      [
        SELECT Id, Billing_Contact__c, Art_Approval_Email__c
        FROM Account
        WHERE Id IN :accountIds
      ]
    );
    for (Order ord : newOrders) {
      if (
        ord.Billing_Contact__c == null && accountMap.containsKey(ord.AccountId)
      ) {
        ord.Billing_Contact__c = accountMap.get(ord.AccountId)
          .Billing_Contact__c;
      }
      if (
        ord.Art_Approval_Email__c == null &&
        accountMap.containsKey(ord.AccountId)
      ) {
        ord.Art_Approval_Email__c = accountMap.get(ord.AccountId)
          .Art_Approval_Email__c;
      }
    }
  }

  public static void UpdateOrderOwner(List<Order> newOrders) {
    //replacement of process builder "Set Work Order Owner"
    Set<Id> accountIds = new Set<Id>();
    for (Order ord : newOrders) {
      if (ord.AccountId != null) {
        accountIds.add(ord.AccountId);
      }
    }
    Map<Id, Account> accountMap = new Map<Id, Account>(
      [SELECT Id, OwnerId FROM Account WHERE Id IN :accountIds]
    );
    for (Order ord : newOrders) {
      if (ord.AccountId != null && accountMap.containsKey(ord.AccountId)) {
        ord.OwnerId = accountMap.get(ord.AccountId).OwnerId;
      }
    }
  }

  public static void setOrderStage(
    List<Order> newOrders,
    Map<Id, Order> oldOrders
  ) {
    for (Order order : newOrders) {
      if (firstRun == true) {
        if (
          oldOrders == null ||
          order.Status == oldOrders.get(order.id).Status
        ) {
          if (
            order.Invoice_Terms__c != null &&
            order.Status != null &&
            order.Invoice_Terms__c.contains('Net') &&
            (oldOrders == null ||
            oldOrders.get(order.id).Status == '01_-_Waiting_for_Client_Payment')
          ) {
            order.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
          } else if (
            order.Invoice_Terms__c != null &&
            order.Status != null &&
            order.Amount_Received__c != null &&
            order.Invoice_Terms__c.contains('50% Down') &&
            order.Amount_Received__c > 0 &&
            (oldOrders == null ||
            oldOrders.get(order.id).Status == '01_-_Waiting_for_Client_Payment')
          ) {
            order.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
          }
          /*
                    else if(order.Invoice_Terms__c!=null && order.Status!=null
                            && order.Invoice_Terms__c.contains('50% Down'))
                    {
                        order.Status = '01_-_Waiting_for_Client_Payment';
                    }
					*/
        }
      }
    }
    firstRun = false;
  }

  //if all related purchase orders is not in billed state then restrict the user to change the WO stage to 8.

  public static void restrictToChangeStageofWorkOrder(
    List<Order> orders,
    Map<Id, Order> oldValues
  ) {
    Schema.sObjectField quickbooksAvailableAccounts = Order.status.getDescribe()
      .getSObjectField();
    List<PicklistEntry> picklistValues = quickbooksAvailableAccounts.getDescribe()
      .getPicklistValues();
    Map<String, String> MapValueLabel = new Map<String, String>();
    Boolean checkPOStatus = true;

    for (Order order : orders) {
      if (
        order.status != oldValues.get(order.Id).status &&
        (order.status == '08.1_-_On_Shelf_for_Local_Delivery/Pickup' ||
        order.Status == '08.2 - On Shelf to Ship to Client' ||
        order.status == '09_-_Complete')
      ) {
        List<PurchaseOrder_LineItem__c> queriedPOList = [
          SELECT Id, WO_Status__c
          FROM PurchaseOrder_LineItem__c
          WHERE Work_Order__c = :order.id
        ];

        for (PurchaseOrder_LineItem__c Pos : queriedPOList) {
          if (Pos.WO_Status__c != 'Billed') {
            checkPOStatus = false;
            break;
          }
        }
      }
      if (!checkPOStatus) {
        for (PicklistEntry pick : picklistValues) {
          MapValueLabel.put(pick.getValue(), pick.getLabel());
        }
        String errorString =
          'You cant move to ' +
          MapValueLabel.get(order.status) +
          ' stage due to incomplete purchase orders!';
        order.addError(errorString);
      }
    }
  }

  public static void addProducts(List<Order> newOrders) {
    List<OrderItem> newItems = new List<OrderItem>();
    Id pricebookId;
    System.debug('In AddProduct Function');

    /* if(Test.isRunningTest())
{
pricebookId = [Select id from PriceBookEntry limit 1].id;
// pricebookId = '01u0H00000zdlWwQAI';            // For Dev1 

//pricebookId = '01uP000000768O0IAI';    // for qa2 deployment
}
else
{
pricebookId = [Select id from PriceBookEntry limit 1].id;
}*/
    pricebookId = [SELECT id FROM PriceBookEntry LIMIT 1].id;
    for (Order ord : newOrders) {
      if (ord.Pricebook2Id != null && ord.Number_of_Products__c == 0) {
        OrderItem item = new OrderItem();
        item.OrderId = ord.Id;
        item.PricebookEntryId = pricebookId;
        item.Quantity = 1;
        item.UnitPrice = 0;
        item.Description = 'SEE QUICKBOOKS / WEB JAGUAR';
        newItems.add(item);
      }
    }

    insert newItems;
  }

  public static void sendWorkOrderEmailNotifications(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    List<Messaging.SingleEmailMessage> orderEmailsToSend = new List<Messaging.SingleEmailMessage>();

    List<EmailTemplate> emailTemplates = [SELECT Id, Name FROM EmailTemplate];
    Map<String, EmailTemplate> emailTemplateMap = new Map<String, EmailTemplate>();
    for (EmailTemplate et : emailTemplates) {
      emailTemplateMap.put(et.Name, et);
    }

    Map<Id, Order> orderMap = new Map<Id, Order>(
      [
        SELECT
          Id,
          Invoice_Email__c,
          Primary_Contact__c,
          Primary_Contact__r.Email,
          Owner.Email
        FROM Order
        WHERE Id = :newOrders
      ]
    );

    List<Id> postProductionOrders = new List<Id>();
    List<Id> onShelfForLocalPickUpOrders = new List<Id>();
    List<Id> onShelfForShipClientOrders = new List<Id>();
    List<Id> completedOrders = new List<Id>();

    for (Order order : newOrders) {
      Order oldOrder = oldOrderMap.get(order.Id);

      if (
        order.Status == '07 - Post Production' &&
        oldOrder.Status == '06_-_In_Process-OTHER'
      ) {
        postProductionOrders.add(order.Id);
      }

      if (
        order.Status == '08.1_-_On_Shelf_for_Local_Delivery/Pickup' &&
        oldOrder.Status == '07 - Post Production'
      ) {
        onShelfForLocalPickUpOrders.add(order.Id);
      }

      if (
        order.Status == '08.2 - On Shelf to Ship to Client' &&
        oldOrder.Status == '07 - Post Production'
      ) {
        onShelfForShipClientOrders.add(order.Id);
      }

      if (
        order.Status == '09_-_Complete' &&
        oldOrder.Status == '08.2 - On Shelf to Ship to Client'
      ) {
        completedOrders.add(order.Id);
      }
    }

    for (Id orderId : postProductionOrders) {
      List<String> toAddresses = new List<String>{
        orderMap.get(orderId).Owner.Email
      };
      List<String> ccAddresses = new List<String>{ System.label.PickupManager };

      Messaging.SingleEmailMessage mail = setupOrderEmail(
        emailTemplateMap,
        '07 - Post Production Email',
        orderId,
        null,
        toAddresses,
        ccAddresses
      );
      if (mail != null) {
        orderEmailsToSend.add(mail);
      }
    }

    for (Id orderId : onShelfForLocalPickUpOrders) {
      List<String> toAddresses = new List<String>{
        orderMap.get(orderId).Primary_Contact__r.Email
      };

      List<String> ccAddresses = new List<String>{
        orderMap.get(orderId).Owner.Email,
        System.Label.Email_for_Order_Stages
      };
      Messaging.SingleEmailMessage mail = setupOrderEmail(
        emailTemplateMap,
        '08.1 On shelf for Local Delivery/Pickup Email',
        orderId,
        orderMap.get(orderId).Primary_Contact__c,
        toAddresses,
        ccAddresses
      );

      if (mail != null) {
        orderEmailsToSend.add(mail);
      }
    }

    for (Id orderId : onShelfForShipClientOrders) {
      List<String> toAddresses = System.Label.OnShelfForShipClientManagers.split(
        ';'
      );
      List<String> ccAddresses = new List<String>{
        orderMap.get(orderId).Owner.Email
      };

      Messaging.SingleEmailMessage mail = setupOrderEmail(
        emailTemplateMap,
        '08.2 On Shelf to Ship to Client',
        orderId,
        null,
        toAddresses,
        ccAddresses
      );
      if (mail != null) {
        orderEmailsToSend.add(mail);
      }
    }

    for (Id orderId : completedOrders) {
      List<String> toAddresses = new List<String>{
        orderMap.get(orderId).Primary_Contact__r.Email
      };
      List<String> ccAddresses = new List<String>{
        orderMap.get(orderId).Owner.Email,
        System.Label.Email_for_Order_Stages
      };

      Messaging.SingleEmailMessage mail = setupOrderEmail(
        emailTemplateMap,
        '09 - Invoice Shipped',
        orderId,
        orderMap.get(orderId).Primary_Contact__c,
        toAddresses,
        ccAddresses
      );
      if (mail != null) {
        orderEmailsToSend.add(mail);
      }
    }
    if (orderEmailsToSend.size() > 0) {
      try {
        Messaging.SendEmailResult[] results = Messaging.sendEmail(
          orderEmailsToSend
        );
        if (!results[0].success) {
          System.debug(
            'Work Order Emails failed to send: ' + results[0].errors[0].message
          );
        }
      } catch (Exception e) {
        System.debug(
          'Exception: ' + e.getMessage() + '-' + e.getStackTraceString()
        );
      }
    }
  }

  public static Messaging.SingleEmailMessage setupOrderEmail(
    Map<String, EmailTemplate> emailTemplateMap,
    String templateName,
    Id orderId,
    Id primaryContactId,
    List<String> toAddresses,
    List<String> ccAddresses
  ) {
    if (emailTemplateMap.containsKey(templateName)) {
      String templateId = emailTemplateMap.get(templateName).Id;
      String whoId = (primaryContactId != null
        ? primaryContactId
        : UserInfo.getUserId());
      String whatId = orderId;
      Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(
        templateId,
        whoId,
        whatId
      );

      mail.setTemplateId(templateId);
      mail.setToAddresses(toAddresses);

      if (ccAddresses.size() > 0) {
        mail.setCCAddresses(ccAddresses);
      }

      mail.setSubject(mail.getSubject());
      mail.setPlainTextBody(mail.getPlainTextBody());
      mail.setHtmlBody(mail.getHtmlBody());
      mail.setTreatTargetObjectAsRecipient(primaryContactId != null);

      return mail;
    }
    return null;
  }

  public static void deleteOppLineItemsRelatedToWorkOrder(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    Set<Id> workOrderIds = oldOrderMap.keySet();

    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :workOrderIds
    ];
    List<Design_Project__c> designProjectRecords = [
      SELECT Id, Name, Work_Order__c
      FROM Design_Project__c
      WHERE Work_Order__c IN :workOrderIds
    ];
    if (designProjectRecords.size() > 0) {
      delete designProjectRecords;
    }
    if (oppLineItems.size() > 0) {
      delete oppLineItems;
    }
  }

  public static void retainOldOwnerOfWorkOrder(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    //// for design pprojects
    List<Id> orderIds = new List<Id>();
    List<Id> userIds = new List<Id>();
    List<User> usersToBeUpdated = new List<User>();
    /////////////

    for (Order ord : newOrders) {
      if (ord.OwnerId != oldOrderMap.get(ord.id).OwnerId) {
        orderIds.add(ord.id);
        if (!userIds.contains(ord.OwnerId))
          userIds.add(ord.OwnerId);
        if (!userIds.contains(oldOrderMap.get(ord.id).OwnerId))
          userIds.add(oldOrderMap.get(ord.id).OwnerId);
      }
    }

    /// for design project
    if (orderIds.size() > 0) {
      List<User> users = [
        SELECT id, Design_Bank__c
        FROM User
        WHERE Id IN :userIds
        LIMIT 1
      ];
      System.debug(users);
      List<Design_Project__c> designProjects = [
        SELECT
          Id,
          Product__c,
          Estimate__c,
          Credits__c,
          Bank_Credits__c,
          Work_Order__c
        FROM Design_Project__c
        WHERE
          Estimate__c = NULL
          AND Work_Order__c IN :orderIds
          AND Bank_Credits__c = TRUE
      ];
      if (designProjects != null && designProjects.size() > 0) {
        for (Order order : newOrders) {
          Decimal totalCredits = 0;
          for (Design_Project__c designProject : designProjects) {
            if (
              orderIds.contains(order.id) &&
              designProject.Work_Order__c == order.id
            ) {
              totalCredits = totalCredits + designProject.Credits__c;
            }
          }
          for (User user : users) {
            if (orderIds.contains(order.id) && user.id == order.OwnerId) {
              if (
                user.Design_Bank__c != null &&
                user.Design_Bank__c > totalCredits
              ) {
                user.Design_Bank__c = user.Design_Bank__c - totalCredits;
                if (!usersToBeUpdated.contains(user))
                  usersToBeUpdated.add(user);
              } else
                order.addError('New user have not enough credits');
            }
            if (user.id == oldOrderMap.get(order.id).OwnerId) {
              if (user.Design_Bank__c != null && user.Design_Bank__c != 0)
                user.Design_Bank__c = user.Design_Bank__c + totalCredits;
              else
                user.Design_Bank__c = totalCredits;
              if (!usersToBeUpdated.contains(user))
                usersToBeUpdated.add(user);
            }
          }
        }
        update usersToBeUpdated;
      }
    }
    //////////////////////////
  }

  public static void generatePDF(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    for (Order ord : newOrders) {
      if (
        oldOrderMap.get(ord.id).Deposit_Invoice__c == null &&
        ord.Deposit_Invoice__c != null
      ) {
        generateDepositPDF(ord.id, ord.OpportunityId);
      }
    }
  }
  @future(callout=true)
  public static void generateDepositPDF(Id orderId, Id OppId) {
    PageReference pdf = Page.OpportunitySalesOrderDepositInvoicePDF;
    pdf.getParameters().put('id', orderId);

    Blob body;
    if (Test.isRunningTest()) {
      body = blob.valueOf('Unit.Test');
    } else {
      body = pdf.getContentAsPDF();
    }

    ContentVersion conVer = new ContentVersion();
    conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
    conVer.PathOnClient = 'Preview Deposit Invoice.pdf'; // The files name, extension is very important here which will help the file in preview.
    conVer.Title = 'Preview Deposit Invoice'; // Display name of the files
    conVer.VersionData = body;
    insert conVer;
    Id conDoc = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :conVer.Id
    ]
    .ContentDocumentId;

    delete [
      SELECT id
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :OppId
        AND ContentDocument.Title = 'Preview Deposit Invoice'
    ];
    //Create ContentDocumentLink
    ContentDocumentLink cDe = new ContentDocumentLink();
    cDe.ContentDocumentId = conDoc;
    cDe.LinkedEntityId = OppId;
    cDe.ShareType = 'V';
    insert cDe;
  }

  public static void deletePDF(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    List<Id> oppIds = new List<Id>();
    for (Id key : oldOrderMap.keySet()) {
      oppIds.add(oldOrderMap.get(key).OpportunityId);
    }
    if (oppIds.size() > 0) {
      List<ContentDocumentLink> lstContentDocument = [
        SELECT id
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId IN :oppIds
          AND (ContentDocument.Title LIKE '%Preview Deposit Invoice%'
          OR ContentDocument.Title LIKE '%Preview Sales Order%')
      ];
      delete lstContentDocument;
    }
  }

  public static void changeTheStageOfOpportunity(
    List<Order> newOrder,
    Map<Id, Order> oldValues
  ) {
    List<Id> OpportunitiesToUpdate = new List<Id>();

    for (Order ord : newOrder) {
      OpportunitiesToUpdate.add(ord.OpportunityId);
    }
    List<Opportunity> queriedOppList = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :OpportunitiesToUpdate
    ];

    for (Opportunity opp : queriedOppList) {
      if (
        opp.StageName != 'Presentation' &&
        opp.StageName != 'Sales' &&
        opp.StageName != 'Closed Won'
      ) {
        opp.StageName = 'Closed Won';
      }
    }
    update queriedOppList;
  }

  public static void UpdateInvoiceInQBO(
    List<Order> triggerNew,
    Map<Id, Order> oldOrderMap
  ) {
    Set<Id> orderIdsToBeUpdated = new Set<Id>();
    Set<Id> orderIdsforInvCreation = new Set<Id>();
    Map<Id, String> OrderAccountMap = new Map<Id, String>();
    Set<Id> OpportunityIds = new Set<Id>();
    for (Order order : triggerNew) {
      OpportunityIds.add(order.OpportunityId);
    }
    List<Estimate__c> estimates = [
      SELECT id, Opportunity__c, Selected_Quickbook_Instance__c
      FROM Estimate__c
      WHERE Opportunity__c IN :OpportunityIds
    ];

    for (Order order : triggerNew) {
      Boolean updatedRec = false;
      if (order.OpportunityId != oldOrderMap.get(order.id).OpportunityId) {
        updatedRec = true;
      }
      if (order.AccountId != oldOrderMap.get(order.id).AccountId) {
        updatedRec = true;
      }
      if (
        order.Invoice_Value__c != oldOrderMap.get(order.id).Invoice_Value__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Discount__c !=
        oldOrderMap.get(order.id).Invoice_Discount__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Total__c != oldOrderMap.get(order.id).Invoice_Total__c
      ) {
        updatedRec = true;
      }
      if (order.Invoice_Tax__c != oldOrderMap.get(order.id).Invoice_Tax__c) {
        updatedRec = true;
      }
      if (
        order.Invoice_Email__c != oldOrderMap.get(order.id).Invoice_Email__c
      ) {
        updatedRec = true;
      }
      if (order.Invoice_Date__c != oldOrderMap.get(order.id).Invoice_Date__c) {
        updatedRec = true;
      }
      if (
        order.Invoice_Due_Date__c !=
        oldOrderMap.get(order.id).Invoice_Due_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Terms__c != oldOrderMap.get(order.id).Invoice_Terms__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Due_Date__c !=
        oldOrderMap.get(order.id).Invoice_Due_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Ship_Date__c !=
        oldOrderMap.get(order.id).Invoice_Ship_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Ship_Via__c !=
        oldOrderMap.get(order.id).Invoice_Ship_Via__c
      ) {
        updatedRec = true;
      }
      // Stop Invoice syncing for Phun for all company.
      system.debug('Company Name: ' + order.Quickbooks_Instance__c);
      if (updatedRec && order.Quickbooks_Instance__c != 'Phun for All') {
        if (order.QbId__c != null) {
          orderIdsToBeUpdated.add(order.id);
        } else {
          orderIdsforInvCreation.add(order.id);
        }
        for (Estimate__c est : estimates) {
          if (order.OpportunityId == est.Opportunity__c) {
            OrderAccountMap.put(order.id, est.Selected_Quickbook_Instance__c);
          }
        }
      }
    }
    if (!system.isBatch() && !System.isFuture()) {
      if (orderIdsToBeUpdated != null && orderIdsToBeUpdated.size() > 0)
        //QuickbookApiCrud.updateInvoice(orderIdsToBeUpdated, OrderAccountMap);
        if (orderIdsforInvCreation != null && orderIdsforInvCreation.size() > 0)
          QuickbookApiCrud.createInvoiceUpdated(
            orderIdsforInvCreation,
            OrderAccountMap
          );
    }
  }

  /**
   * Any change in invoice of word order will update the sync alert message for syncing.
   */

  public static void updateWOSyncStatusOnInvoiceChange(
    List<Order> triggerNew,
    Map<Id, Order> oldOrderMap
  ) {
    Set<ID> updatedOrdersIDs = new Set<ID>();
    for (Order order : triggerNew) {
      Boolean updatedRec = false;
      if (order.OpportunityId != oldOrderMap.get(order.id).OpportunityId) {
        updatedRec = true;
      }
      if (order.AccountId != oldOrderMap.get(order.id).AccountId) {
        updatedRec = true;
      }
      if (
        order.Invoice_Value__c != oldOrderMap.get(order.id).Invoice_Value__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Discount__c !=
        oldOrderMap.get(order.id).Invoice_Discount__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Total__c != oldOrderMap.get(order.id).Invoice_Total__c
      ) {
        updatedRec = true;
      }
      if (order.Invoice_Tax__c != oldOrderMap.get(order.id).Invoice_Tax__c) {
        updatedRec = true;
      }
      if (
        order.Invoice_Email__c != oldOrderMap.get(order.id).Invoice_Email__c
      ) {
        updatedRec = true;
      }
      if (order.Invoice_Date__c != oldOrderMap.get(order.id).Invoice_Date__c) {
        updatedRec = true;
      }
      if (
        order.Invoice_Due_Date__c !=
        oldOrderMap.get(order.id).Invoice_Due_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Terms__c != oldOrderMap.get(order.id).Invoice_Terms__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Due_Date__c !=
        oldOrderMap.get(order.id).Invoice_Due_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Ship_Date__c !=
        oldOrderMap.get(order.id).Invoice_Ship_Date__c
      ) {
        updatedRec = true;
      }
      if (
        order.Invoice_Ship_Via__c !=
        oldOrderMap.get(order.id).Invoice_Ship_Via__c
      ) {
        updatedRec = true;
      }
      if (updatedRec) {
        updatedOrdersIDs.add(order.id);
      }
    }
    List<OrderSyncStatus__c> oSSList = [
      SELECT Id, isSynced__c
      FROM OrderSyncStatus__c
      WHERE Work_Order__c IN :updatedOrdersIDs
    ];
    for (OrderSyncStatus__c oSS : oSSList) {
      oSS.isSynced__c = false;
    }

    update oSSList;

    //Publish event to SalesOrderOppLineItem aura component to update the sync alert message

    syncMessageOnWOUpdate__e event = new syncMessageOnWOUpdate__e(
      SyncAlertMessage__c = 'Please synchronize the Sales Order with Quickbooks using "Sync Sales Order" in Actions'
    );

    Database.SaveResult result = EventBus.publish(event);
    if (!result.isSuccess()) {
      for (Database.Error error : result.getErrors()) {
        System.debug(
          'Error returned: ' +
            error.getStatusCode() +
            ' - ' +
            error.getMessage()
        );
      }
    }
  }

  public static void syncInvoiceAmount(
    List<Order> newValues,
    Map<Id, Order> oldValuesMap
  ) {
    Set<Id> opportunityIdsToBeUpdated = new Set<Id>();
    Map<Id, Decimal> invoiceAmountMap = new Map<Id, Decimal>();

    for (Order newOrder : newValues) {
      Order oldOrder = oldValuesMap.get(newOrder.id);
      if (
        newOrder.id == oldOrder.id &&
        newOrder.Invoice_Value__c != oldOrder.Invoice_Value__c
      ) {
        opportunityIdsToBeUpdated.add(newOrder.OpportunityId);
      }
    }

    List<Opportunity> opportunities = [
      SELECT Id, Order_Amount__c
      FROM Opportunity
      WHERE Id IN :opportunityIdsToBeUpdated
    ];

    List<Opportunity> newOpportunities = new List<Opportunity>();
    for (Order newOrder : newValues) {
      for (Opportunity opp : opportunities) {
        if (opp.Id == newOrder.OpportunityId) {
          opp.Order_Amount__c = newOrder.Invoice_Value__c;
          if (!newOpportunities.contains(opp))
            newOpportunities.add(opp);
        }
      }
    }
    update newOpportunities;
  }

  public static void syncInvoiceAmount(List<Order> newValues) {
    Set<Id> opportunityIdsToBeUpdated = new Set<Id>();
    Map<Id, Decimal> invoiceAmountMap = new Map<Id, Decimal>();

    for (Order newOrder : newValues) {
      opportunityIdsToBeUpdated.add(newOrder.OpportunityId);
    }

    List<Opportunity> opportunities = [
      SELECT Id, Order_Amount__c
      FROM Opportunity
      WHERE Id IN :opportunityIdsToBeUpdated
    ];

    List<Opportunity> newOpportunities = new List<Opportunity>();

    for (Order newOrder : newValues) {
      for (Opportunity opp : opportunities) {
        if (opp.Id == newOrder.OpportunityId) {
          opp.Order_Amount__c = newOrder.Invoice_Value__c;
          if (!newOpportunities.contains(opp))
            newOpportunities.add(opp);
        }
      }
    }
    update newOpportunities;
  }
  public static void setBalanceDue(List<Order> newValues) {
    for (Order newOrder : newValues) {
      if (
        newOrder.Invoice_Total__c != null &&
        newOrder.Amount_Received__c != null
      )
        newOrder.Balance_Due__c =
          newOrder.Invoice_Total__c - newOrder.Amount_Received__c;
    }
  }

  public static void markInvoicesPaid(List<Order> newValues) {
    List<Id> orderIds = new List<Id>();
    Set<Id> ordersToUpdate = new Set<Id>();
    Map<Id, String> orderToAccountMap = new Map<Id, String>();
    Map<Id, String> orderToQbIdMap = new Map<Id, String>();

    for (Order workOrder : newValues) {
      orderIds.add(workOrder.Id);
      orderToQbIdMap.put(workOrder.Id, workOrder.QbId__c);
    }
    List<OpportunityLineItem__c> lineItems = [
      SELECT Id, Work_Order__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :orderIds
    ];
    Map<Id, List<OpportunityLineItem__c>> orderToLineItemsMap = new Map<Id, List<OpportunityLineItem__c>>();
    for (Order workOrder : newValues) {
      for (OpportunityLineItem__c lineItem : lineItems) {
        if (workOrder.Id == lineItem.Work_Order__c) {
          if (orderToLineItemsMap.containsKey(workOrder.Id)) {
            orderToLineItemsMap.get(workOrder.Id).add(lineItem);
          } else {
            orderToLineItemsMap.put(
              workOrder.Id,
              new List<OpportunityLineItem__c>()
            );
            orderToLineItemsMap.get(workOrder.Id).add(lineItem);
          }
        }
      }
    }

    List<Design_Project__c> designPrjects = [
      SELECT Id, Work_Order__c
      FROM Design_Project__c
      WHERE Work_Order__c IN :orderIds
    ];
    Map<Id, List<Design_Project__c>> orderToDPMap = new Map<Id, List<Design_Project__c>>();
    for (Order workOrder : newValues) {
      for (Design_Project__c designProject : designPrjects) {
        if (workOrder.Id == designProject.Work_Order__c) {
          if (orderToDPMap.containsKey(workOrder.Id)) {
            orderToDPMap.get(workOrder.Id).add(designProject);
          } else {
            orderToDPMap.put(workOrder.Id, new List<Design_Project__c>());
            orderToDPMap.get(workOrder.Id).add(designProject);
          }
        }
      }
    }

    for (Order workOrder : newValues) {
      if (
        orderToLineItemsMap.containsKey(workOrder.Id) &&
        orderToDPMap.containsKey(workOrder.Id)
      ) {
        if (
          orderToLineItemsMap.get(workOrder.Id).size() ==
          orderToDPMap.get(workOrder.Id).size() &&
          workOrder.QBId__c != null &&
          workOrder.Balance_Due_Formula__c != 0
        ) {
          ordersToUpdate.add(workOrder.Id);
          orderToAccountMap.put(workOrder.Id, workOrder.Quickbooks_Instance__c);
        }
      }
    }
    QuickbookApiCrud.makePayment(
      ordersToUpdate,
      orderToAccountMap,
      orderToQbIdMap
    );
  }
  public static void updateShippingDetails(
    List<Order> newOrderRecs,
    Map<Id, Order> oldMap,
    Map<Id, Order> newMap
  ) {
    List<Id> woToupdateIds = new List<Id>();
    for (Order wo : newOrderRecs) {
      if (
        wo.ShippingStreet != oldMap.get(wo.Id).ShippingStreet ||
        wo.ShippingCity != oldMap.get(wo.Id).ShippingCity ||
        wo.ShippingState != oldMap.get(wo.Id).ShippingState ||
        wo.ShippingPostalCode != oldMap.get(wo.Id).ShippingPostalCode ||
        wo.ShippingCountry != oldMap.get(wo.Id).ShippingCountry
      ) {
        woToupdateIds.add(wo.Id);
      }
    }
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Shipping_Information__c, Work_Order__c
      FROM OpportunityLineItem__c
      WHERE Work_Order__c IN :woToupdateIds
    ];
    List<Id> ShippingInfoIds = new List<Id>();
    for (OpportunityLineItem__c lineItem : oppLineItems) {
      ShippingInfoIds.add(lineItem.Shipping_Information__c);
    }

    List<Shipping_Information__c> shippingInfo = [
      SELECT Id, Client_Shipping_Address__c
      FROM Shipping_Information__c
      WHERE Id IN :ShippingInfoIds
    ];

    Map<Id, OpportunityLineItem__c> shippingToLineItemMap = new Map<Id, OpportunityLineItem__c>();
    for (OpportunityLineItem__c lineItem : oppLineItems) {
      shippingToLineItemMap.put(lineItem.Shipping_Information__c, lineItem);
    }

    for (Shipping_Information__c shipInfo : shippingInfo) {
      Order wo = newMap.get(
        shippingToLineItemMap.get(shipInfo.Id).Work_Order__c
      );
      System.debug(wo);
      String address = '';
      if (wo.ShippingStreet != null)
        address = wo.ShippingStreet;
      if (wo.ShippingCity != null)
        address = address + ' ' + wo.ShippingCity;
      if (wo.ShippingState != null)
        address = address + ',' + wo.ShippingState;
      if (wo.ShippingPostalCode != null)
        address = address + ' ' + wo.ShippingPostalCode;
      if (wo.ShippingCountry != null)
        address = address + ' ' + wo.ShippingCountry;
      shipInfo.Client_Shipping_Address__c = address;
    }
    update shippingInfo;
  }

  public static void updateWONotesAndPriority(List<Order> newValues) {
    try {
      List<Id> oppIdList = new List<Id>();

      for (Order ord : newValues) {
        oppIdList.add(ord.OpportunityId);
      }

      List<Opportunity> opplst = [
        SELECT Id, Priority__c, Opportunity_Notes__c
        FROM Opportunity
        WHERE Id IN :oppIdList
      ];

      for (Order ord : newValues) {
        for (Opportunity opp : opplst) {
          if (ord.OpportunityId == opp.Id) {
            ord.Priority__c = opp.Priority__c;
            ord.Work_Order_Notes__c = opp.Opportunity_Notes__c;
          }
        }
      }
    } catch (Exception ex) {
      System.debug(
        'Error in updateWONotesAndPriority -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
    }
  }
}
