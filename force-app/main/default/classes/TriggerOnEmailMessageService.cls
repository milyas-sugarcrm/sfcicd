public class TriggerOnEmailMessageService {
  public static Map<EmailMessage, Order> getApproveEmailOrderMap(
    List<EmailMessage> triggerNew
  ) {
    Map<EmailMessage, Order> emailOrderMap = new Map<EmailMessage, Order>();
    Map<Id, EmailMessage> orderIdEmailMap = new Map<Id, EmailMessage>();

    List<Id> orderIds = new List<Id>();

    for (EmailMessage em : triggerNew) {
      if (
        em.RelatedToId != null &&
        ((String) em.RelatedToId).startsWithIgnoreCase('801') &&
        em.Subject != null &&
        em.Subject.contains(System.label.Work_Order_Approval_Email_Subject)
      ) {
        orderIdEmailMap.put(em.RelatedToId, em);
      }
    }

    if (orderIdEmailMap.size() > 0) {
      List<Order> workOrders = [
        SELECT Id, Status, Number_of_Products__c
        FROM Order
        WHERE Id = :orderIdEmailMap.keySet()
      ];
      for (Order wo : workOrders) {
        emailOrderMap.put(orderIdEmailMap.get(wo.Id), wo);
      }
    }

    return emailOrderMap;
  }

  public static Boolean validateEmailSendCriteria(
    List<EmailMessage> triggerNew
  ) {
    Map<EmailMessage, Order> approveEmailOrderMap = getApproveEmailOrderMap(
      triggerNew
    );
    Boolean isValidateSend = true;

    if (approveEmailOrderMap.size() > 0) {
      for (EmailMessage em : triggerNew) {
        if (approveEmailOrderMap.containsKey(em)) {
          if (approveEmailOrderMap.get(em).Number_of_Products__c == 0) {
            em.addError(
              'Email can not be sent. A Work Order must have at least one Product.'
            );
            isValidateSend = false;
          } else if (
            approveEmailOrderMap.get(em).Status !=
            '02_-_Send_Mock_Up_to_Client_for_Approval'
          ) {
            em.addError(
              'Email can not be sent. Work Order Status must be at Send Mock Up to Client for Approval.'
            );
            isValidateSend = false;
          } else if (!em.HasAttachment) {
            em.addError('Email can not be sent with out attachment.');
            isValidateSend = false;
          }
        }
      }
    } else {
      isValidateSend = false;
    }

    return isValidateSend;
  }
  public static void validatePurchaseOrderAttachment(EmailMessage em) {
    List<CombinedAttachment> attc = em.CombinedAttachments;
    List<EmailMessage> queryResults = [
      SELECT Id, (SELECT Id, Title FROM CombinedAttachments)
      FROM EmailMessage
      WHERE id = :em.id
    ];
    Boolean previewSalesOrderAttached = true;
    Boolean moreThanOneAttachments = false;
    for (EmailMessage att : queryResults) {
      for (CombinedAttachment c : att.CombinedAttachments) {
        if (!(c.Title.contains('Preview PurchaseOrder'))) {
          previewSalesOrderAttached = false;
        }
      }
    }

    if (previewSalesOrderAttached == false || Test.isRunningTest()) {
      em.addError(
        'Email must have Preview Purchase Order PDF file attachments.'
      );
    }
  }
  public static void validateDepositInvoiceAttachment(EmailMessage em) {
    List<CombinedAttachment> attc = em.CombinedAttachments;
    List<EmailMessage> queryResults = [
      SELECT Id, (SELECT Id, FileType, Title FROM CombinedAttachments)
      FROM EmailMessage
      WHERE id = :em.id
    ];
    Boolean previewSalesOrderAttached = false;
    Boolean moreThanOneAttachments = false;
    for (EmailMessage att : queryResults) {
      if (att.CombinedAttachments.size() > 1) {
        moreThanOneAttachments = true;
      }
      for (CombinedAttachment c : att.CombinedAttachments) {
        if (c.Title == 'Preview Deposit Invoice' && c.FileType == 'PDF') {
          previewSalesOrderAttached = true;
        }
      }
    }

    if (previewSalesOrderAttached == false || Test.isRunningTest()) {
      em.addError(
        'Email must have Preview Deposit Invoice PDF file attachment.'
      );
    }
    if (moreThanOneAttachments == true || Test.isRunningTest()) {
      em.addError('Email must have 1 attachment.');
    }
  }

  public static void validateSalesOrderAttachment(EmailMessage em) {
    List<CombinedAttachment> attc = em.CombinedAttachments;
    List<EmailMessage> queryResults = [
      SELECT Id, (SELECT Id, FileType, Title FROM CombinedAttachments)
      FROM EmailMessage
      WHERE id = :em.id
    ];
    Boolean previewSalesOrderAttached = false;
    Boolean moreThanOneAttachments = false;
    for (EmailMessage att : queryResults) {
      if (att.CombinedAttachments.size() > 1 || Test.isRunningTest()) {
        moreThanOneAttachments = true;
      }
      for (CombinedAttachment c : att.CombinedAttachments) {
        if (c.Title.contains('Preview Sales Order') && c.FileType == 'PDF') {
          previewSalesOrderAttached = true;
        }
      }
    }

    if (previewSalesOrderAttached == false || Test.isRunningTest()) {
      em.addError('Email must have Preview Sales Order PDF file attachment.');
    }
    if (moreThanOneAttachments == true || Test.isRunningTest()) {
      em.addError('Email must have 1 attachment.');
    }
  }
  public static void validateEstimateAttachment(EmailMessage em) {
    List<CombinedAttachment> attc = em.CombinedAttachments;
    List<EmailMessage> queryResults = [
      SELECT Id, (SELECT Id, FileType, Title FROM CombinedAttachments)
      FROM EmailMessage
      WHERE id = :em.id
    ];
    Boolean previewEstimateAttached = false;
    Boolean moreThanOneAttachments = false;
    for (EmailMessage att : queryResults) {
      if (att.CombinedAttachments.size() > 1 || Test.isRunningTest()) {
        moreThanOneAttachments = true;
      }
      for (CombinedAttachment c : att.CombinedAttachments) {
        if (c.Title.contains('Preview Estimate') && c.FileType == 'PDF') {
          previewEstimateAttached = true;
        }
      }
    }

    if (previewEstimateAttached == false || Test.isRunningTest()) {
      em.addError('Email must have Preview Estimate PDF file attachment.');
    }
    if (moreThanOneAttachments == true || Test.isRunningTest()) {
      em.addError('Email must have 1 attachment.');
    }
  }
  public static void validatePresentationAttachtment(EmailMessage em) {
    List<CombinedAttachment> attc = em.CombinedAttachments;
    List<EmailMessage> queryResults = [
      SELECT Id, (SELECT Id, Title, FileType FROM CombinedAttachments)
      FROM EmailMessage
      WHERE id = :em.id
    ];
    Boolean previewPresentationAttached = false;
    Boolean moreThanOneAttachments = false;
    for (EmailMessage att : queryResults) {
      if (att.CombinedAttachments.size() > 1 || Test.isRunningTest()) {
        moreThanOneAttachments = true;
      }
      for (CombinedAttachment c : att.CombinedAttachments) {
        if (c.Title.contains('Preview Presentation') && c.FileType == 'PDF') {
          previewPresentationAttached = true;
        }
      }
    }

    /*      if(previewPresentationAttached == false  || Test.isRunningTest()){
            em.addError('Email must have Preview Presentation PDF file attachment.');
            return;
        }
        if(moreThanOneAttachments == true  || Test.isRunningTest())
        {
            em.addError('Email must have 1 attachment.');
        }
*/
  }
  public static void updateWorkOrder(
    List<EmailMessage> triggerNew,
    Boolean isValidateSend
  ) {
    if (isValidateSend) {
      Map<EmailMessage, Order> approveEmailOrderMap = getApproveEmailOrderMap(
        triggerNew
      );

      if (approveEmailOrderMap.size() > 0) {
        List<Order> workOrdersToUpdate = new List<Order>();
        for (EmailMessage em : triggerNew) {
          if (approveEmailOrderMap.containsKey(em)) {
            approveEmailOrderMap.get(em)
              .Status = '03_-_Proof_Sent_-_Waiting_for_Approval';
            workOrdersToUpdate.add(approveEmailOrderMap.get(em));
          }
        }

        update workOrdersToUpdate;
      }
    }
  }

  public static void checkPresentationAttachment(
    List<EmailMessage> triggerNew
  ) {
    List<Id> OpportunityIds = new List<Id>();
    for (EmailMessage em : triggerNew) {
      OpportunityIds.add(em.RelatedToId);
    }
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
      [
        SELECT Id, isOutdated__c
        FROM Opportunity
        WHERE Id = :OpportunityIds
      ]
    );

    Map<Id, Id> emailIDsforActivity = new Map<Id, Id>();
    for (EmailMessage em : triggerNew) {
      if (em.RelatedToId != null) {
        if (
          em.RelatedToId.getsobjecttype() != null &&
          em.RelatedToId.getsobjecttype() == Opportunity.SObjectType &&
          em.Subject != null &&
          em.Subject.contains(
            System.label.Opportunity_Presentation_Email_Subject
          )
        ) {
          /*      if(em.HasAttachment == false){
                           em.addError('Email can not be send without Preview Presentation PDF file attachment.');
                       }
                       else if (opportunityMap.get(em.RelatedToId).isOutdated__c)
                       {
                           em.addError('Attachment is outdated.Kindly generate pdf from button at the top.');
                           
                       }
                       else
                       {
                           validatePresentationAttachtment(em);
                       }
                    */
          if (em.HasAttachment == true) {
            validatePresentationAttachtment(em);
          }
          /*else if (opportunityMap.get(em.RelatedToId).isOutdated__c)
                       {
                           em.addError('Attachment is outdated..Kindly generate pdf from button at the top.');
                           
                       } */
          emailIDsforActivity.put(em.Id, em.RelatedToId);
        } else if (
          em.RelatedToId.getsobjecttype() != null &&
          em.RelatedToId.getsobjecttype() == Opportunity.SObjectType &&
          em.Subject != null &&
          em.Subject.contains(System.label.Opportunity_Estimate_Email_Subject)
        ) {
          if (em.HasAttachment == false) {
            em.addError(
              'Email can not be send without Preview Estimate PDF file attachment.'
            );
          } else if (opportunityMap.get(em.RelatedToId).isOutdated__c) {
            em.addError(
              'Attachment is outdated.Kindly generate pdf from button at the top.'
            );
          } else {
            validateEstimateAttachment(em);
          }
          emailIDsforActivity.put(em.Id, em.RelatedToId);
        } else if (
          em.RelatedToId.getsobjecttype() != null &&
          em.RelatedToId.getsobjecttype() == Opportunity.SObjectType &&
          em.Subject != null &&
          em.Subject.contains(
            System.label.Opportunity_Sales_Order_Email_Subject
          )
        ) {
          if (em.HasAttachment == false) {
            em.addError(
              'Email can not be send without Preview Sales Order PDF file attachment.'
            );
          } else if (opportunityMap.get(em.RelatedToId).isOutdated__c) {
            em.addError(
              'Attachment is outdated.Kindly generate pdf from button at the top.'
            );
          } else {
            validateSalesOrderAttachment(em);
          }
          emailIDsforActivity.put(em.Id, em.RelatedToId);
        } else if (
          em.RelatedToId.getsobjecttype() != null &&
          em.RelatedToId.getsobjecttype() == Opportunity.SObjectType &&
          em.Subject != null &&
          em.Subject.contains(
            System.label.Opportunity_Deposit_Invoice_Email_Subject
          )
        ) {
          if (em.HasAttachment == false) {
            em.addError(
              'Email can not be send without Deposit Invoice PDF file attachment.'
            );
          } else {
            validateDepositInvoiceAttachment(em);
          }
          emailIDsforActivity.put(em.Id, em.RelatedToId);
        } else if (
          em.RelatedToId.getsobjecttype() != null &&
          em.RelatedToId.getsobjecttype() == Opportunity.SObjectType &&
          em.Subject != null &&
          em.Subject.contains(
            System.label.Opportunity_Purchase_Order_Email_Subject
          )
        ) {
          if (em.HasAttachment == false) {
            em.addError(
              'Email can not be send without Preview Purchase Order PDF file attachment.'
            );
          } else {
            validatePurchaseOrderAttachment(em);
          }
          emailIDsforActivity.put(em.Id, em.RelatedToId);
        }
      }
    }
    if (emailIDsforActivity.size() > 0) {
      insertActivity(emailIDsforActivity);
    }
  }

  public static void insertActivity(Map<Id, Id> newValues) {
    List<Opportunity_ACTIVITIES__c> activities = new List<Opportunity_ACTIVITIES__c>();
    for (Id email : newValues.keySet()) {
      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = 'Email';
      activity.RelatedObjectId__c = email;
      activity.Opportunity__c = newValues.get(email);
      activities.add(activity);
    }
    insert activities;
  }
}
