public class OpportunityTriggerService {
  static final Id pfaOppRecordTypeId = CommonUtilitiesPfa.getRecordTypeIdByName(
    Constants.OPPORTUNITY_API_NAME,
    Constants.PFA_CUSTOMER_OPPORTUNITY
  );
  Boolean isRun = false;
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    for (Opportunity opp : newOpps) {
      if (opp.Name != oldOpps.get(opp.Id).Name) {
        opp.isOutdated__c = true;
      }
    }
  }
  public static void populatePresentationFields(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    for (Opportunity opp : newOpps) {
      if (
        opp.StageName == 'Presentation' &&
        oldOpps.get(opp.Id).StageName == 'Needs Analysis'
      ) {
        opp.Order_Date__c = system.today();
        opp.In_Hands_Date__c = system.today();
        opp.Currency__c = 'USD';
        opp.Presentation_Style__c = 'List';
      }
    }
  }

  public static void populatePresentationFieldsBeforeInsert(
    List<Opportunity> newOpps
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : newOpps) {
      accountIds.add(opp.AccountId);
    }

    List<Account> accounts = [
      SELECT id, OwnerId
      FROM Account
      WHERE id IN :accountIds
    ];
    Map<Id, Id> accountsMap = new Map<Id, Id>();

    for (Opportunity opp : newOpps) {
      for (Account acc : accounts) {
        if (acc.id == opp.AccountId) {
          accountsMap.put(acc.id, acc.OwnerId);
        }
      }
    }
    for (Opportunity opp : newOpps) {
      if (opp.AccountId != null)
        opp.OwnerId = accountsMap.get(opp.AccountId);
      if (opp.StageName == 'Presentation') {
        opp.Order_Date__c = system.today();
        opp.In_Hands_Date__c = system.today();
        opp.Currency__c = 'USD';
        opp.Presentation_Style__c = 'List';
      }
    }
  }
  public static void ChangeOwner(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (Opportunity opp : newOpps) {
      if (opp.AccountId != oldOpps.get(opp.id).AccountId)
        accountIds.add(opp.AccountId);
    }
    if (accountIds != null && accountIds.size() > 0) {
      List<Account> accounts = [
        SELECT id, OwnerId
        FROM Account
        WHERE id IN :accountIds
      ];
      Map<Id, Id> accountsMap = new Map<Id, Id>();
      for (Opportunity opp : newOpps) {
        for (Account acc : accounts) {
          if (acc.id == opp.AccountId) {
            accountsMap.put(acc.id, acc.OwnerId);
          }
        }
      }
      for (Opportunity opp : newOpps) {
        if (
          opp.AccountId != null &&
          opp.AccountId != oldOpps.get(opp.id).AccountId
        ) {
          opp.OwnerId = accountsMap.get(opp.AccountId);
        }
      }
    }
  }
  public static void restricStagesBeforeInsert(List<Opportunity> newOpps) {
    for (Opportunity opp : newOpps) {
      if (Opp.StageName != 'Needs Analysis') {
        opp.addError('Opportunity stage should be Needs Analysis');
      }
    }
  }
  public static void estimateStageChecks(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps,
    Map<Id, Account> linkedAccs
  ) {
    for (Opportunity opp : newOpps) {
      if (
        Opp.StageName == 'Estimate' &&
        (oldOpps == null ||
        (oldOpps != null &&
        oldOpps.get(opp.Id).StageName != 'Estimate')) &&
        linkedAccs.get(opp.AccountId).RecordTypeId !=
        Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Vendor Account')
          .getRecordTypeId()
      ) {
        if (linkedAccs.get(opp.AccountId).QBO_Accounts_Count__c == 0) {
          opp.addError(
            'Parent Account should be synced with Quickbooks to create Estimate.'
          );
        }
        if (opp.Estimated_Amount__c == null) {
          opp.addError(
            'Please provide Estimated Amount before moving to stage Estimate.'
          );
        }
      }
    }
  }
  public static void handleStageChangePresentationToEstimate(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    List<Estimate__c> estimates = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :newOpps
    ];
    Map<Id, Estimate__c> opportunityEstimateMap = new Map<Id, Estimate__c>();

    for (Estimate__c estimate : estimates) {
      opportunityEstimateMap.put(estimate.Opportunity__c, estimate);
    }

    for (Opportunity opp : newOpps) {
      if (
        Opp.StageName == 'Estimate' &&
        (oldOpps != null &&
        oldOpps.get(opp.Id).StageName != 'Estimate')
      ) {
        if (opportunityEstimateMap.get(opp.Id) == null) {
          //       opp.addError('You cannot change the stage directly. Kindly use Convert To Estimate button.');
        }
      }
    }
  }
  public static Map<Id, List<QBO_Details__c>> getMapOfSyncedQBORecordsAndOpportunity(
    Set<Id> opportunityIds
  ) {
    List<Opportunity> oppList = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :opportunityIds
    ];
    List<Id> accountIds = new List<Id>();
    for (Opportunity opp : oppList) {
      accountIds.add(opp.AccountId);
    }
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
      WHERE Account__c = :accountIds
    ];

    Map<Id, List<QBO_Details__c>> opportunityListOfQBDetailsMap = new Map<Id, List<QBO_Details__c>>();
    for (Opportunity opp : oppList) {
      List<QBO_Details__c> qbDetailsOfOpportunity = new List<QBO_Details__c>();
      for (QBO_Details__c qbDetails : qboDetailsList) {
        //                List<QBO_Details__c>
        if (opp.Id == qbDetails.Opportunity__c) {
          qbDetailsOfOpportunity.add(qbDetails);
        }
      }
      opportunityListOfQBDetailsMap.put(opp.Id, qbDetailsOfOpportunity);
    }

    return opportunityListOfQBDetailsMap;
  }
  public static Map<Id, List<QBO_Details__c>> getMapOfSyncedQBORecordsAndAccount(
    Set<Id> opportunityIds
  ) {
    List<Opportunity> oppList = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :opportunityIds
    ];
    List<Id> accountIds = new List<Id>();
    for (Opportunity opp : oppList) {
      accountIds.add(opp.AccountId);
    }
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
      WHERE Account__c = :accountIds
    ];
    Map<Id, List<QBO_Details__c>> accountListOfQBDetailsMap = new Map<Id, List<QBO_Details__c>>();
    for (Opportunity opp : oppList) {
      List<QBO_Details__c> qbDetailsOfOpportunity = new List<QBO_Details__c>();
      for (QBO_Details__c qbDetails : qboDetailsList) {
        if (opp.AccountId == qbDetails.Account__c) {
          qbDetailsOfOpportunity.add(qbDetails);
        }
      }
      accountListOfQBDetailsMap.put(opp.AccountId, qbDetailsOfOpportunity);
    }

    return accountListOfQBDetailsMap;
  }
  public static Map<Id, List<String>> getListRelatedAccounts(
    Set<Id> lstOpportunties
  ) {
    List<String> selectedAccounts = new List<String>();
    Map<Id, List<String>> mapSelectedAccount = new Map<Id, List<String>>();
    List<Estimate__c> lstEstmate = [
      SELECT Id, Selected_Quickbook_Instance__c, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c IN :lstOpportunties
    ];
    for (Estimate__c estimate : lstEstmate) {
      List<String> lstQBIDs = new List<String>();
      lstQBIDs.add(estimate.Selected_Quickbook_Instance__c);
      mapSelectedAccount.put(estimate.Opportunity__c, lstQBIDs);
    }
    return mapSelectedAccount;
  }

  public static void createEstimate(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps,
    Map<Id, Account> linkedAccs
  ) {
    Set<Id> oppIdsForCreate = new Set<Id>();
    Set<Id> oppIdsForUpdate = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    Boolean amountCheck = true;
    for (Opportunity opp : newOpps) {
      if (opp.Order_Amount__c != oldOpps.get(opp.id).Order_Amount__c)
        amountCheck = false;
      opportunityIds.add(opp.Id);
    }
    if (amountCheck) {
      List<Estimate__c> estimatesList = [
        SELECT
          Estimate_QB_Id__c,
          Opportunity__c,
          QB_Update__c,
          Estimate_Number__c,
          In_Hands_Date__c,
          Order_Date__c,
          Status__c,
          Name,
          Id
        FROM Estimate__c
        WHERE Opportunity__c = :opportunityIds
      ];
      Map<Id, Estimate__c> opportunityEstimateMap = new Map<Id, Estimate__c>();
      Set<String> estimateSyncTokenIds = new Set<String>();
      if (estimatesList != null && estimatesList.size() > 0) {
        for (Estimate__c est : estimatesList) {
          opportunityEstimateMap.put(est.Opportunity__c, est);
        }
        Map<Id, List<String>> oppRelatedQBAccountsMap = getListRelatedAccounts(
          opportunityIds
        );
        Map<Id, List<QBO_Details__c>> qboDetailsOpportunityMap = getMapOfSyncedQBORecordsAndOpportunity(
          opportunityIds
        );
        Map<String, Set<Id>> qboAccountOpportunityListToCreateEstimateMap = new Map<String, Set<Id>>();
        Map<String, Set<Id>> qboAccountOpportunityListToUpdateEstimateMap = new Map<String, Set<Id>>();

        for (Opportunity opp : newOpps) {
          Estimate__c est = opportunityEstimateMap.get(opp.Id);

          List<Map<String, String>> opportunitiesQboRecordsMapList = new List<Map<String, String>>();
          Boolean isExists = false;
          if (
            Opp.StageName == 'Estimate' &&
            linkedAccs.get(opp.AccountId).RecordType.Name != 'Vendor Account'
          ) {
            if (oppRelatedQBAccountsMap.containsKey(opp.Id)) {
              for (String qboAccount : oppRelatedQBAccountsMap.get(opp.Id)) {
                isExists = false;
                for (
                  QBO_Details__c qbDetails : qboDetailsOpportunityMap.get(
                    opp.Id
                  )
                ) {
                  if (
                    qbDetails.QBO_Account__c.equals(qboAccount) &&
                    qbDetails.Id_Type__c.equals('Estimate')
                  ) {
                    isExists = true;
                  }
                }
                if (isExists) {
                  if (
                    qboAccountOpportunityListToUpdateEstimateMap.containsKey(
                      qboAccount
                    )
                  ) {
                    qboAccountOpportunityListToUpdateEstimateMap.get(qboAccount)
                      .add(opp.Id);
                  } else {
                    Set<Id> oppIdsToAdd = new Set<Id>();
                    oppIdsToAdd.add(opp.Id);
                    qboAccountOpportunityListToUpdateEstimateMap.put(
                      qboAccount,
                      oppIdsToAdd
                    );
                  }
                } else {
                  if (
                    qboAccountOpportunityListToCreateEstimateMap.containsKey(
                      qboAccount
                    )
                  ) {
                    qboAccountOpportunityListToCreateEstimateMap.get(qboAccount)
                      .add(opp.Id);
                  } else {
                    Set<Id> oppIdsToAdd = new Set<Id>();
                    oppIdsToAdd.add(opp.Id);
                    qboAccountOpportunityListToCreateEstimateMap.put(
                      qboAccount,
                      oppIdsToAdd
                    );
                  }
                }
              }
            }
          }
        }

        Schema.sObjectField quickbooksAvailableAccounts = Account.QuickBooks_Accounts__c.getDescribe()
          .getSObjectField();
        List<PicklistEntry> picklistValues = quickbooksAvailableAccounts.getDescribe()
          .getPicklistValues();

        for (PicklistEntry accountName : picklistValues) {
          // stop estimates syncing for phun for all company
          if (accountName.getValue() != 'Phun for All') {
            Set<Id> opportunityIdsForCreationOfEstimate;
            Set<Id> opportunityIdsForUpdationOfEstimate;
            if (
              qboAccountOpportunityListToCreateEstimateMap.containskey(
                accountName.getValue()
              )
            ) {
              opportunityIdsForCreationOfEstimate = qboAccountOpportunityListToCreateEstimateMap.get(
                accountName.getValue()
              );
            }
            if (
              qboAccountOpportunityListToUpdateEstimateMap.containskey(
                accountName.getValue()
              )
            ) {
              opportunityIdsForUpdationOfEstimate = qboAccountOpportunityListToUpdateEstimateMap.get(
                accountName.getValue()
              );
            }
            if (
              opportunityIdsForCreationOfEstimate != null &&
              opportunityIdsForCreationOfEstimate.size() > 0
            ) {
              Set<Id> estimateIds = new Set<Id>();
              if (
                opportunityEstimateMap != null &&
                opportunityEstimateMap.size() > 0
              ) {
                for (Id oppId : opportunityIdsForCreationOfEstimate) {
                  if (opportunityEstimateMap.containsKey(oppId)) {
                    estimateIds.add(opportunityEstimateMap.get(oppId).Id);
                  }
                }
                recalculateTotalOfLineItem(estimateIds);
                QuickbookApiCrud.createEstimate(
                  opportunityIdsForCreationOfEstimate,
                  estimateIds,
                  accountName.getValue()
                );
              }
            }

            if (
              opportunityIdsForUpdationOfEstimate != null &&
              opportunityIdsForUpdationOfEstimate.size() > 0
            ) {
              Set<Id> estimateIds = new Set<Id>();
              Boolean allowQBUpdate = false;
              if (
                opportunityEstimateMap != null &&
                opportunityEstimateMap.size() > 0
              ) {
                for (Id oppId : opportunityIdsForUpdationOfEstimate) {
                  if (opportunityEstimateMap.containsKey(oppId)) {
                    Estimate__c est = opportunityEstimateMap.get(oppId);
                    if (est.QB_Update__c == true) {
                      allowQBUpdate = true;
                    }
                    estimateIds.add(est.Id);
                  }
                }
                recalculateTotalOfLineItem(estimateIds);
                if (allowQBUpdate) {
                  QuickbookApiCrud.updateEstimate(
                    opportunityIdsForUpdationOfEstimate,
                    estimateIds,
                    accountName.getValue()
                  );
                }
              }
            }
          }
        }
      }
    }
  }
  public static void recalculateTotalOfLineItem(Set<Id> estimateIds) {
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Name, CreatedDate, Total_QBO__c
      FROM OpportunityLineItem__c
      WHERE Estimate__c = :estimateIds
      ORDER BY CreatedDate DESC
    ];
    List<Id> oppLineItemIds = new List<Id>();
    if (oppLineItems != null && oppLineItems.size() > 0) {
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        oppLineItemIds.add(oppLine.Id);
      }

      List<ExtraChargesEstimate__c> extraCharges = [
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
          OpportunityLineItem__c,
          Default__c,
          Net_Cost__c
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :oppLineItemIds
        ORDER BY CreatedDate ASC
      ];
      List<PricingLineItem__c> pricing = [
        SELECT
          Id,
          Quantity__c,
          Net_Cost__c,
          OpportunityLineItem__c,
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
          OpportunityLineItem__c = :oppLineItemIds
          AND Display__c = TRUE
          AND Default__c = FALSE
        ORDER BY CreatedDate ASC
      ];
      Map<Id, List<ExtraChargesEstimate__c>> oppLineItemExtraChargesMap = new Map<Id, List<ExtraChargesEstimate__c>>();
      for (Id opplineItem : oppLineItemIds) {
        List<ExtraChargesEstimate__c> extraChargesList = new List<ExtraChargesEstimate__c>();
        for (ExtraChargesEstimate__c extCharge : extraCharges) {
          if (extCharge.OpportunityLineItem__c == opplineItem) {
            extraChargesList.add(extCharge);
          }
        }
        oppLineItemExtraChargesMap.put(opplineItem, extraChargesList);
      }
      Map<Id, List<PricingLineItem__c>> oppLineItemPricingMap = new Map<Id, List<PricingLineItem__c>>();
      for (Id opplineItem : oppLineItemIds) {
        List<PricingLineItem__c> pricingList = new List<PricingLineItem__c>();
        for (PricingLineItem__c pri : pricing) {
          if (pri.OpportunityLineItem__c == opplineItem) {
            pricingList.add(pri);
          }
        }
        oppLineItemPricingMap.put(opplineItem, pricingList);
      }
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        Decimal total = 0;
        Decimal marginPercentage = 0;
        Decimal marginAmount = 0;
        List<ExtraChargesEstimate__c> oppLineItemExtraChargesList = oppLineItemExtraChargesMap.get(
          oppLine.Id
        );
        if (
          oppLineItemExtraChargesList != null &&
          oppLineItemExtraChargesList.size() > 0
        ) {
          for (
            ExtraChargesEstimate__c extraCharge : oppLineItemExtraChargesList
          ) {
            total += (extraCharge.Total__c == null) ? 0 : extraCharge.Total__c;
          }
        }
        List<PricingLineItem__c> oppLineItemPricingList = oppLineItemPricingMap.get(
          oppLine.Id
        );
        if (
          oppLineItemPricingList != null &&
          oppLineItemPricingList.size() > 0
        ) {
          for (PricingLineItem__c rec : oppLineItemPricingList) {
            total += (rec.Total__c == null) ? 0 : rec.Total__c;
          }
        }
        oppLine.Total_QBO__c = total;
      }
      update oppLineItems;
    }
  }
  public static void deleteOppLineItemsRelatedToOpportunity(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    Set<Id> oppIds = oldOpps.keySet();

    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id
      FROM OpportunityLineItem__c
      WHERE Opportunity__c IN :oppIds
    ];
    List<Estimate__c> estimates = [
      SELECT Id, Opportunity__c
      FROM Estimate__c
      WHERE Opportunity__c = :oppIds
    ];

    List<Order> orders = [
      SELECT Id, OpportunityId
      FROM Order
      WHERE OpportunityId = :oppIds
    ];

    if (oppLineItems.size() > 0) {
      delete oppLineItems;
    }
    if (estimates.size() > 0) {
      delete estimates;
    }
    if (orders.size() > 0) {
      delete orders;
    }
    if (oppIds.size() > 0) {
      List<ContentDocumentLink> lstContentDocument = [
        SELECT id
        FROM ContentDocumentLink
        WHERE
          LinkedEntityId IN :oppIds
          AND ContentDocument.Title LIKE '%Preview Presentation%'
      ];
      delete lstContentDocument;
    }
  }

  public static void restrictStage(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    List<Id> OpportunityIds = new List<Id>();
    for (Opportunity opp : newOpps) {
      if (
        opp.StageName != oldOpps.get(opp.Id).StageName &&
        opp.recordTypeId != pfaOppRecordTypeId
      ) {
        OpportunityIds.add(opp.id);
      }
    }
    if (OpportunityIds != null && OpportunityIds.size() > 0) {
      List<Opportunity> oppToUpdate = new List<Opportunity>();
      List<Estimate__c> estimates = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c IN :OpportunityIds
      ];
      List<Order> orders = [
        SELECT id, OpportunityId
        FROM Order
        WHERE OpportunityId IN :OpportunityIds
      ];
      List<PurchaseOrder__c> purchaseOrders = [
        SELECT id, Opportunity__c
        FROM PurchaseOrder__c
        WHERE Opportunity__c IN :OpportunityIds
      ];
      List<Id> OppsWithoutEstimate = new List<Id>();
      for (Opportunity opp : newOpps) {
        // handle need analysis and closed
        if (opp.StageName == 'Needs Analysis') {
          if (oldOpps.get(opp.Id).StageName != 'Needs Analysis') {
            opp.addError(
              'You cannot jump from ' +
                oldOpps.get(opp.Id).StageName +
                ' to ' +
                opp.StageName
            );
          }
        }
        // handle presentation stage
        else if (opp.StageName == 'Presentation') {
          if (oldOpps.get(opp.Id).StageName != 'Presentation') {
            if (
              oldOpps.get(opp.Id).StageName == 'Estimate' ||
              oldOpps.get(opp.Id).StageName == 'Needs Analysis'
            ) {
              if (oldOpps.get(opp.Id).StageName == 'Estimate') {
                boolean exist = true;
                for (Estimate__c est : estimates) {
                  if (opp.id == est.Opportunity__c) {
                    exist = false;
                  }
                }
                if (exist == false) {
                  opp.addError(
                    'You cannot jump from ' +
                      oldOpps.get(opp.Id).StageName +
                      ' to ' +
                      opp.StageName
                  );
                }
              }
            } else {
              opp.addError(
                'You cannot jump from ' +
                  oldOpps.get(opp.Id).StageName +
                  ' to ' +
                  opp.StageName
              );
            }
          }
        }
        // handle estimate stage
        else if (opp.StageName == 'Estimate') {
          if (
            opp.Estimate_Change_Status__c != 'not changed from picklist' &&
            oldOpps.get(opp.Id).StageName != opp.StageName
          ) {
            opp.addError(
              'You can only create Estimate using "Mark Stage as Complete" button or "Actions" dropdown in Presentation'
            );
          } else if (oldOpps.get(opp.Id).StageName != 'Estimate') {
            opp.Estimate_Change_Status__c = '';
            boolean exist = false;
            if (
              oldOpps.get(opp.Id).StageName == 'Presentation' ||
              oldOpps.get(opp.Id).StageName == 'Needs Analysis'
            ) {
              for (Estimate__c est : estimates) {
                if (opp.id == est.Opportunity__c) {
                  exist = true;
                }
              }
              if (exist == false) {
                oppToUpdate.add(opp);
                OppsWithoutEstimate.add(opp.Id);
              }
            } else {
              opp.addError(
                'You cannot jump from ' +
                  oldOpps.get(opp.Id).StageName +
                  ' to ' +
                  opp.StageName
              );
            }
          }
          // ConvertToEstimateQuickActionController.convertToEstimateInDb(opp.Id,'');
        }
        // handle Sales stage
        else if (opp.StageName == 'Sales') {
          if (oldOpps.get(opp.Id).StageName != 'Sales') {
            boolean exist = false;
            for (Order order : orders) {
              if (
                opp.id == order.OpportunityId &&
                oldOpps.get(opp.Id).StageName == 'Estimate'
              ) {
                exist = true;
              }
            }
            if (exist == false) {
              opp.addError(
                'You cannot jump from ' +
                  oldOpps.get(opp.Id).StageName +
                  ' to ' +
                  opp.StageName
              );
            }
          }
        }
        // handle Closed stages
        else if (
          opp.StageName == 'Closed Won' ||
          opp.StageName == 'Closed Lost' ||
          opp.StageName == 'Closed'
        ) {
          if (opp.StageName == 'Closed Lost') {
            // allow to move
          } else if (
            oldOpps.get(opp.Id).StageName != 'Closed Won' &&
            oldOpps.get(opp.Id).StageName != 'Closed Lost' &&
            oldOpps.get(opp.Id).StageName != 'Closed'
          ) {
            boolean exist = false;
            if (oldOpps.get(opp.Id).StageName == 'Estimate') {
              exist = true;
            }
            for (Order order : orders) {
              if (
                opp.id == order.OpportunityId &&
                oldOpps.get(opp.Id).StageName == 'Estimate'
              ) {
                exist = true;
              }
            }
            for (PurchaseOrder__c order : purchaseOrders) {
              if (
                opp.id == order.Opportunity__c &&
                oldOpps.get(opp.Id).StageName == 'Sales'
              ) {
                exist = true;
              }
            }
            if (exist == false) {
              opp.addError(
                'You cannot jump from ' +
                  oldOpps.get(opp.Id).StageName +
                  ' to ' +
                  opp.StageName
              );
            }
          }
        }
      }
      if (oppsWithoutEstimate.size() > 0) {
        for (Opportunity opp : oppToUpdate) {
          opp.Order_Date__c = system.today();
          opp.In_Hands_Date__c = system.today();
          opp.Currency__c = 'USD';
          opp.Presentation_Style__c = 'List';
        }
        createAndSyncEstimate(oppsWithoutEstimate);
      }
    }
  }
  public static void createAndSyncEstimate(List<Id> oppIds) {
    List<Estimate__c> newEstimates = new List<Estimate__c>();
    for (Id oppId : oppIds) {
      Estimate__c estimate = new Estimate__c();
      estimate.Opportunity__c = oppId;
      estimate.Status__c = 'Converted';
      estimate.In_Hands_Date__c = system.today();
      estimate.Terms__c = 'Credit Card';
      newEstimates.add(estimate);
    }
    insert newEstimates;
  }

  public static void updateMargin(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    List<Id> oppIds = new List<Id>();
    for (Opportunity opp : newOpps) {
      if (
        opp.Margin__c != oldOpps.get(opp.Id).Margin__c &&
        opp.Margin__c != null
      )
        oppIds.add(opp.id);
    }
    if (oppIds != null && oppIds.size() > 0) {
      Map<Id, Estimate__c> ests = new Map<Id, Estimate__c>(
        [
          SELECT Id, Opportunity__c, Opportunity__r.Margin__c
          FROM Estimate__c
          WHERE Opportunity__c IN :oppIds
        ]
      );
      if (ests != null && ests.size() > 0) {
        Map<Id, OpportunityLineItem__c> oppLineItems = new Map<Id, OpportunityLineItem__c>(
          [
            SELECT Id, Estimate__c
            FROM OpportunityLineItem__c
            WHERE Estimate__c IN :ests.keySet()
          ]
        );

        Map<Id, Decimal> lineItemOppMap = new Map<Id, Decimal>();
        for (Id estKey : ests.keySet()) {
          for (Id key : oppLineItems.keySet()) {
            if (estKey == oppLineItems.get(key).Estimate__c) {
              lineItemOppMap.put(
                key,
                ests.get(estKey).Opportunity__r.Margin__c
              );
            }
          }
        }

        List<PricingLineItem__c> PricingRecords = [
          SELECT
            Id,
            OpportunityLineItem__c,
            OpportunityLineItem__r.Name,
            Quantity__c,
            index__c,
            Color__c,
            Size__c,
            Subtotal_Toggle__c,
            Estimated_Quantity__c,
            Display__c,
            Net_Cost__c,
            Retail_Price__c,
            Total__c,
            Margin__c,
            Default__c,
            Credit_Available__c,
            Show_To_Client__c,
            Estimate__c,
            Price_Per_Unit__c
          FROM PricingLineItem__c
          WHERE OpportunityLineItem__c = :oppLineItems.keyset()
        ];
        if (PricingRecords != null && PricingRecords.size() > 0) {
          for (PricingLineItem__c pricing : PricingRecords) {
            if (
              pricing.OpportunityLineItem__c != null &&
              pricing.Estimated_Quantity__c != null
            ) {
              pricing.Margin__c = lineItemOppMap.get(
                pricing.OpportunityLineItem__c
              );
              decimal marginCalculation = 1 - (pricing.Margin__c / 100);
              pricing.Retail_Price__c =
                pricing.Net_Cost__c /
                (marginCalculation != 0 ? marginCalculation : 1);
              pricing.Retail_Price__c = pricing.Retail_Price__c.setScale(2);
              Decimal total =
                pricing.Estimated_Quantity__c * pricing.Retail_Price__c;
              pricing.Total__c = total;
              pricing.Total__c = pricing.Total__c.setScale(2);
            }
            /*
else if (pricing.OpportunityLineItem__c!=null && pricing.Quantity__c != null && pricing.Estimated_Quantity__c == null){
pricing.Margin__c = lineItemOppMap.get(pricing.OpportunityLineItem__c);
decimal marginCalculation = 1-(pricing.Margin__c/100);
pricing.Retail_Price__c = pricing.Net_Cost__c/
(marginCalculation !=0? marginCalculation:1);
pricing.Retail_Price__c = pricing.Retail_Price__c.setScale(2);
Decimal total = pricing.Quantity__c * pricing.Retail_Price__c;
pricing.Total__c = total;
pricing.Total__c = pricing.Total__c.setScale(2);
}
*/
          }
          update PricingRecords;
        }
        List<ExtraChargesEstimate__c> runChargesOfOppLineItem = [
          SELECT
            Id,
            Margin__c,
            OpportunityLineItem__c,
            Net_Cost__c,
            Retail_Price__c,
            Quantity__c,
            Total__c
          FROM ExtraChargesEstimate__c
          WHERE OpportunityLineItem__c = :oppLineItems.keyset()
        ];
        if (
          runChargesOfOppLineItem != null &&
          runChargesOfOppLineItem.size() > 0
        ) {
          for (ExtraChargesEstimate__c runCharge : runChargesOfOppLineItem) {
            if (runCharge.OpportunityLineItem__c != null) {
              runCharge.Margin__c = lineItemOppMap.get(
                runCharge.OpportunityLineItem__c
              );
              decimal marginCalculation = 1 - (runCharge.Margin__c / 100);
              runCharge.Retail_Price__c =
                runCharge.Net_Cost__c /
                (marginCalculation != 0 ? marginCalculation : 1);
              runCharge.Retail_Price__c = runCharge.Retail_Price__c.setScale(2);
              runCharge.Total__c =
                runCharge.Quantity__c * runCharge.Retail_Price__c;
              runCharge.Total__c = runCharge.Total__c.setScale(2);
            }
          }
          update runChargesOfOppLineItem;
        }
      }
    }
  }

  public static void updateMarginAtPresentationStage(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    List<Id> oppIds = new List<Id>();
    for (Opportunity opp : newOpps) {
      if (
        opp.Margin__c != oldOpps.get(opp.Id).Margin__c &&
        opp.Margin__c != null &&
        opp.StageName == 'Presentation'
      )
        oppIds.add(opp.id);
    }

    if (oppIds != null && oppIds.size() > 0) {
      Map<Id, OpportunityLineItem__c> oppLineItems = new Map<Id, OpportunityLineItem__c>(
        [
          SELECT Id, Estimate__c, Opportunity__c, Opportunity__r.Margin__c
          FROM OpportunityLineItem__c
          WHERE Opportunity__c IN :oppIds
        ]
      );

      Map<Id, Decimal> lineItemOppMap = new Map<Id, Decimal>();
      for (Id key : oppLineItems.keySet()) {
        lineItemOppMap.put(key, oppLineItems.get(key).Opportunity__r.Margin__c);
      }
      List<PricingLineItem__c> PricingRecords = [
        SELECT
          Id,
          OpportunityLineItem__c,
          OpportunityLineItem__r.Name,
          Quantity__c,
          index__c,
          Color__c,
          Size__c,
          Subtotal_Toggle__c,
          Estimated_Quantity__c,
          Display__c,
          Net_Cost__c,
          Retail_Price__c,
          Total__c,
          Margin__c,
          Default__c,
          Credit_Available__c,
          Show_To_Client__c,
          Estimate__c,
          Price_Per_Unit__c
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :oppLineItems.keyset()
      ];
      if (PricingRecords != null && PricingRecords.size() > 0) {
        for (PricingLineItem__c pricing : PricingRecords) {
          if (
            pricing.OpportunityLineItem__c != null &&
            pricing.Estimated_Quantity__c != null
          ) {
            pricing.Margin__c = lineItemOppMap.get(
              pricing.OpportunityLineItem__c
            );
            decimal marginCalculation = 1 - (pricing.Margin__c / 100);
            pricing.Retail_Price__c =
              pricing.Net_Cost__c /
              (marginCalculation != 0 ? marginCalculation : 1);
            pricing.Retail_Price__c = pricing.Retail_Price__c.setScale(2);
            Decimal total =
              pricing.Estimated_Quantity__c * pricing.Retail_Price__c;
            pricing.Total__c = total;
            pricing.Total__c = pricing.Total__c.setScale(2);
          } else if (
            pricing.OpportunityLineItem__c != null &&
            pricing.Quantity__c != null &&
            pricing.Estimated_Quantity__c == null
          ) {
            pricing.Margin__c = lineItemOppMap.get(
              pricing.OpportunityLineItem__c
            );
            decimal marginCalculation = 1 - (pricing.Margin__c / 100);
            pricing.Retail_Price__c =
              pricing.Net_Cost__c /
              (marginCalculation != 0 ? marginCalculation : 1);
            pricing.Retail_Price__c = pricing.Retail_Price__c.setScale(2);
            Decimal total = pricing.Quantity__c * pricing.Retail_Price__c;
            pricing.Total__c = total;
            pricing.Total__c = pricing.Total__c.setScale(2);
          }
        }
        update PricingRecords;
      }
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfoppLineItems = [
        SELECT
          Id,
          Title__c,
          Cost__c,
          Margin__c,
          Retail_Price__c,
          OpportunityLineItem__c,
          Is_Associated_With_Artwork_c__c,
          OpportunityLineItem_ArtWork__c,
          EstimatedQuantity__c,
          Total__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE OpportunityLineItem__c = :oppLineItems.keyset()
      ];

      if (
        fixedChargesOfoppLineItems != null &&
        fixedChargesOfoppLineItems.size() > 0
      ) {
        for (
          OpportunityLineItem_Add_Fixed_Charge__c runCharge : fixedChargesOfoppLineItems
        ) {
          if (runCharge.OpportunityLineItem__c != null) {
            runCharge.Margin__c = lineItemOppMap.get(
              runCharge.OpportunityLineItem__c
            );
            decimal marginCalculation = 1 - (runCharge.Margin__c / 100);
            runCharge.Retail_Price__c =
              runCharge.Cost__c /
              (marginCalculation != 0 ? marginCalculation : 1);
            runCharge.Retail_Price__c = runCharge.Retail_Price__c.setScale(2);
          }
        }
        update fixedChargesOfoppLineItems;
      }
    }
  }

  public static void handleRecordType(List<Opportunity> newOpps) {
    Id pfaRecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();
    Id pfaRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('PFA Customer Lead')
      .getRecordTypeId();
    for (Opportunity opp : newOpps) {
      if (opp.Lead_Record_Id__c != null) {
        if (opp.Lead_Record_Id__c == pfaRecordTypeIdLead) {
          opp.RecordTypeId = pfaRecordTypeIdOpportunity;
        }
      }
    }
  }

  public static void deleteOpp(List<Opportunity> newOpps) {
    List<Id> newOppIds = new List<Id>();
    Id BARecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Brand Ambassador Lead')
      .getRecordTypeId();
    for (Opportunity opp : newOpps) {
      if (opp.Lead_Record_Id__c != null) {
        if (opp.Lead_Record_Id__c == BARecordTypeIdLead) {
          newOppIds.add(opp.Id);
        }
      }
    }
    if (!newOppIds.isEmpty()) {
      Datetime dt = System.now().addMinutes(1);
      String cronExp =
        '' +
        dt.second() +
        ' ' +
        dt.minute() +
        ' ' +
        dt.hour() +
        ' ' +
        dt.day() +
        ' ' +
        dt.month() +
        ' ? ' +
        dt.year();
      System.schedule(
        'Delete Opp: ' + cronExp,
        cronExp,
        new OpportunityDeleteScheduler(newOppIds)
      );
    }
  }

  public static void handleSowApprovalDate(
    List<Opportunity> newOpps,
    Map<Id, Opportunity> oldOpps
  ) {
    List<Opportunity> oppsToUpdate = new List<Opportunity>();
    for (Opportunity newOpp : newOpps) {
      if (newOpp.Approved_SOW__c != oldOpps.get(newOpp.Id).Approved_SOW__c) {
        if (newOpp.Approved_SOW__c == true) {
          newOpp.SOW_Approval_Date__c = Date.today();
        } else {
          newOpp.SOW_Approval_Date__c = null;
        }
      }
    }
  }

  public static void createCampaignOnOppClose(List<Opportunity> newOpps) {
    OpportunityTriggerHandler.firstRun1 = false;
    Id pfaCustomerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();
    List<PFA_Campaign__c> newCampaigns = new List<PFA_Campaign__c>();

    for (Opportunity opp : newOpps) {
      if (
        opp.StageName == 'Closed Won' &&
        opp.RecordTypeId == pfaCustomerRecordTypeId
      ) {
        PFA_Campaign__c CampaignNew = new PFA_Campaign__c();
        CampaignNew.OwnerId = opp.OwnerId;
        CampaignNew.PFA_Opportunity__c = opp.Id;
        CampaignNew.Name = opp.Name + ' Campaign';
        CampaignNew.Billing_Email__c = opp.Billing_Contact_Email_PFA__c;
        CampaignNew.Campaign_POC__c = opp.Campaign_POC__c;
        CampaignNew.Campaign_POC_Email__c = opp.Campaign_POC_Email__c;
        CampaignNew.Campaign_Start_Date__c = opp.Campaign_Start_Date__c;
        CampaignNew.Campaign_End_Date__c = opp.Campaign_End_Date__c;
        if (opp.AccountId != null) {
          CampaignNew.PFA_Client__c = opp.AccountId;
        } else if (opp.ContactId != null) {
          CampaignNew.PFA_Client__c = opp.ContactId;
        } else {
          CampaignNew.PFA_Client__c = opp.Lead_Record_Id__c;
        }

        if (
          opp.Estimated_Amount__c != null &&
          opp.Total_Miscellaneous_Cost__c != null
        ) {
          CampaignNew.Required_Initial_Deposit__c =
            ((opp.Estimated_Amount__c) * 0.50) +
            opp.Total_Miscellaneous_Cost__c;
        } else if (opp.Estimated_Amount__c == null) {
          CampaignNew.Required_Initial_Deposit__c = opp.Total_Miscellaneous_Cost__c;
        } else if (opp.Total_Miscellaneous_Cost__c == null) {
          CampaignNew.Required_Initial_Deposit__c = ((opp.Estimated_Amount__c) *
          0.50);
        }
        CampaignNew.Required_Initial_Deposit_50__c = ((CampaignNew.Required_Initial_Deposit__c) *
        0.50);

        if (CampaignNew.Required_Initial_Deposit_50__c != null) {
          CampaignNew.Initial_Deposit_calculated__c = true;
        }

        newCampaigns.add(CampaignNew);
      }
    }
    if (!newCampaigns.isEmpty()) {
      insert newCampaigns;
    }
  }

  public static void createInitialBillingForCampaign(
    List<Opportunity> newOpps
  ) {
    OpportunityTriggerHandler.firstRun1 = false;
    Id pfaCustomerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();

    Map<String, PFA_Campaign__c> oppIdvsCampaignRecMap = new Map<String, PFA_Campaign__c>();
    List<PFA_Campaign__c> campaignList = [
      SELECT Id, Name, PFA_Opportunity__c
      FROM PFA_Campaign__c
      WHERE PFA_Opportunity__c IN :newOpps
    ];
    for (PFA_Campaign__c campaign : campaignList) {
      oppIdvsCampaignRecMap.put(campaign.PFA_Opportunity__c, campaign);
    }
    List<PFA_Event_Billing__c> initialBillingList = new List<PFA_Event_Billing__c>();

    for (Opportunity opp : newOpps) {
      if (
        opp.StageName == 'Closed Won' &&
        opp.RecordTypeId == pfaCustomerRecordTypeId
      ) {
        PFA_Event_Billing__c initialBillingRec = new PFA_Event_Billing__c();
        initialBillingRec.OwnerId = opp.OwnerId;
        initialBillingRec.PFA_Campaign__c = oppIdvsCampaignRecMap.get(opp.Id)
          .Id;
        initialBillingRec.Name = opp.Name + ' Campaign Initial Bill';
        initialBillingRec.Account__c = opp.AccountId;
        if (
          opp.Total_Hourly_Cost__c != null &&
          opp.Total_Miscellaneous_Cost__c != null
        ) {
          initialBillingRec.Total_Amount__c =
            ((opp.Total_Hourly_Cost__c) * 0.50) +
            opp.Total_Miscellaneous_Cost__c;
        } else if (opp.Total_Hourly_Cost__c == null) {
          initialBillingRec.Total_Amount__c = opp.Total_Miscellaneous_Cost__c;
        } else if (opp.Total_Miscellaneous_Cost__c == null) {
          initialBillingRec.Total_Amount__c = ((opp.Total_Hourly_Cost__c) *
          0.50);
        }

        initialBillingRec.Is_Initial_Deposit_Billing__c = true;
        initialBillingRec.Balance_Due__c = initialBillingRec.Total_Amount__c;
        initialBillingList.add(initialBillingRec);
      }
    }
    if (!initialBillingList.isEmpty()) {
      insert initialBillingList;
    }
  }

  // Create Hourly_Estimate__c records against each PFA Customer Opp
  public static void createHourlyEstimates(List<Opportunity> newOpps) {
    List<Hourly_Estimate__c> hourlyEstimates = new List<Hourly_Estimate__c>();

    Schema.DescribeFieldResult fieldResult = Hourly_Estimate__c.Region__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

    for (Opportunity opp : newOpps) {
      if (opp.recordTypeId == pfaOppRecordTypeId) {
        // Create Hourly_Estimate__c records for each picklist value of Region__c
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
          Hourly_Estimate__c hourlyEstimate = new Hourly_Estimate__c(
            Region__c = picklistEntry.getValue(),
            Opportunity__c = opp.Id
          );
          hourlyEstimates.add(hourlyEstimate);
        }
      }
    }
    if (!hourlyEstimates.isEmpty()) {
      try {
        insert hourlyEstimates;
      } catch (Exception e) {
        System.debug(
          'Error creating Hourly_Estimate__c records: ' + e.getMessage()
        );
      }
    }
  }

  // Create Expenses_Miscellaneous__c records against each PFA Customer Opp
  public static void createExpensesMiscellaneous(List<Opportunity> newOpps) {
    List<Expenses_Miscellaneous__c> expensesMiscellaneousList = new List<Expenses_Miscellaneous__c>();

    Schema.DescribeFieldResult fieldResult = Expenses_Miscellaneous__c.Expense_Type__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

    for (Opportunity opp : newOpps) {
      // Create Expenses_Miscellaneous__c records for each picklist value
      for (Schema.PicklistEntry picklistEntry : picklistValues) {
        Expenses_Miscellaneous__c expenseMiscellaneous = new Expenses_Miscellaneous__c(
          Expense_Type__c = picklistEntry.getValue(),
          Opportunity__c = opp.Id
        );
        expensesMiscellaneousList.add(expenseMiscellaneous);
      }
    }
    if (!expensesMiscellaneousList.isEmpty()) {
      try {
        insert expensesMiscellaneousList;
      } catch (Exception e) {
        System.debug(
          'Error creating Expenses_Miscellaneous__c records: ' + e.getMessage()
        );
      }
    }
  }
}
