public class TriggerOnExtraChargesEstimateService {
  static Map<Id, Boolean> isAfterInsert = new Map<Id, Boolean>();
  public static Id changedByUser = [
    SELECT id
    FROM User
    WHERE id = :UserInfo.getUserId()
  ]
  .id;

  public static void updateDesignProjectsBeforeUpdate(
    List<ExtraChargesEstimate__c> newValues,
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      Set<Id> relatedOpportunityLineItems = new Set<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        relatedOpportunityLineItems.add(pricing.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT
          Id,
          Name,
          Description__c,
          Estimate__c,
          Product__c,
          Product__r.Id,
          Product__r.Name,
          Product__r.Design_Project__c,
          Product__r.Sales_Price_Rate__c,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Tax__c
        FROM OpportunityLineItem__c
        WHERE
          Id IN :relatedOpportunityLineItems
          AND Estimate__c != NULL
          AND Product__r.Design_Project__c = TRUE
      ];
      List<id> oppLineItemIds = new List<id>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        oppLineItemIds.add(oppLineItem.Id);
      }
      List<Design_Project__c> designProjects = [
        SELECT Id, Active__c, Product__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :oppLineItemIds AND Active__c = TRUE
      ];
      List<Id> pricingIds = new List<Id>();
      List<Design_Project__c> designProjectsToBeUpdated = new List<Design_Project__c>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        for (ExtraChargesEstimate__c pricing : newValues) {
          //System.debug('Pricing outside1: '+pricing.Credit_Available__c + '  '+pricing.id);
          if (
            !(pricingIds.contains(pricing.id)) &&
            pricing.OpportunityLineItem__c == oppLineItem.id
          ) {
            pricingIds.add(pricing.id);
            Decimal totalNewAmount = 0;
            Decimal totalOldAmount = 0;
            Decimal totalNewCredit = 0;
            Decimal totalOldCredit = 0;
            Decimal updatedCredit = 0;
            if (pricing.Quantity__c != null && pricing.Net_Cost__c != null) {
              if (pricing.Retail_Price__c == null) {
                pricing.Retail_Price__c = 0;
              }
              totalNewAmount = pricing.Quantity__c * pricing.Retail_Price__c;
              if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                totalNewCredit =
                  (pricing.Quantity__c * pricing.Net_Cost__c) -
                  (totalNewAmount);
              // totalNewCredit = totalNewAmount - oppLineItem.Product__r.Sales_Price_Rate__c;
              else
                totalNewCredit = 0;
            }
            if (
              oldValues.get(pricing.id).Quantity__c != null &&
              oldValues.get(pricing.id).Net_Cost__c != null
            ) {
              if (oldValues.get(pricing.id).Retail_Price__c == null) {
                oldValues.get(pricing.id).Retail_Price__c = 0;
              }
              totalOldAmount =
                oldValues.get(pricing.id).Quantity__c *
                oldValues.get(pricing.id).Retail_Price__c;
              if (
                oldValues.get(pricing.id).Retail_Price__c <
                oldValues.get(pricing.id).Net_Cost__c
              )
                totalOldCredit =
                  (oldValues.get(pricing.id).Quantity__c *
                  oldValues.get(pricing.id).Net_Cost__c) - (totalOldAmount);
              //totalOldCredit = totalOldAmount - oppLineItem.Product__r.Sales_Price_Rate__c;
              else
                totalOldCredit = 0;
            }
            if ((totalOldAmount < totalNewAmount)) {
              updatedCredit = totalNewCredit - totalOldCredit;
            }
            if (totalOldAmount > totalNewAmount) {
              updatedCredit = (totalOldCredit - totalNewCredit) * (-1);
            }
            if (totalOldAmount == totalNewAmount) {
              updatedCredit = 0;
            }
            for (Design_Project__c designProj : designProjects) {
              if (
                designProj.Product__c != null &&
                designProj.Product__c == oppLineItem.id
              ) {
                if (
                  designProj.Credits__c != null &&
                  designProj.Credits__c != 0
                ) {
                  if (updatedCredit != 0) {
                    designProj.Credits__c =
                      designProj.Credits__c + updatedCredit;
                    if (!(designProjectsToBeUpdated.contains(designProj)))
                      designProjectsToBeUpdated.add(designProj);
                  }
                } else {
                  if (updatedCredit != 0) {
                    designProj.Credits__c = updatedCredit;
                    if (!(designProjectsToBeUpdated.contains(designProj)))
                      designProjectsToBeUpdated.add(designProj);
                  }
                }
              }
            }
          }
        }
      }
      System.debug('DPs: ' + designProjectsToBeUpdated.size());
      update designProjectsToBeUpdated;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }

  public static void updateDesignProjectsAfterInsert(
    List<ExtraChargesEstimate__c> newValues,
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      Set<Id> relatedOpportunityLineItems = new Set<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        relatedOpportunityLineItems.add(pricing.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT
          Id,
          Name,
          Description__c,
          Estimate__c,
          Product__c,
          Product__r.Id,
          Product__r.Name,
          Product__r.Design_Project__c,
          Product__r.Sales_Price_Rate__c,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Tax__c
        FROM OpportunityLineItem__c
        WHERE
          Id IN :relatedOpportunityLineItems
          AND Estimate__c != NULL
          AND Product__r.Design_Project__c = TRUE
      ];
      List<id> oppLineItemIds = new List<id>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        oppLineItemIds.add(oppLineItem.Id);
      }
      List<Design_Project__c> designProjects = [
        SELECT Id, Active__c, Product__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :oppLineItemIds AND Active__c = TRUE
      ];
      List<Id> pricingIds = new List<Id>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        for (ExtraChargesEstimate__c pricing : newValues) {
          if (
            !(pricingIds.contains(pricing.id)) &&
            pricing.OpportunityLineItem__c == oppLineItem.id
          ) {
            pricingIds.add(pricing.id);
            Decimal totalNewAmount = 0;
            Decimal updatedCredit = 0;
            if (pricing.Quantity__c != null && pricing.Net_Cost__c != null) {
              if (pricing.Retail_Price__c != null) {
                totalNewAmount = pricing.Quantity__c * pricing.Retail_Price__c;
              }
              //totalNewAmount = pricing.Quantity__c * pricing.Retail_Price__c;
              if (pricing.Retail_Price__c != null)
                if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                  updatedCredit =
                    (pricing.Quantity__c * pricing.Net_Cost__c) -
                    totalNewAmount;
                //updatedCredit = totalNewAmount - oppLineItem.Product__r.Sales_Price_Rate__c;
                else
                  updatedCredit = 0;
            }
            for (Design_Project__c designProj : designProjects) {
              if (
                designProj.Product__c != null &&
                designProj.Product__c == oppLineItem.id
              ) {
                if (
                  designProj.Credits__c != null &&
                  designProj.Credits__c != 0
                ) {
                  if (updatedCredit != 0) {
                    designProj.Credits__c =
                      designProj.Credits__c + updatedCredit;
                  }
                } else {
                  designProj.Credits__c = updatedCredit;
                }
              }
            }
          }
        }
      }
      update designProjects;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }

  public static void updateDesignProjectsBeforeDelete(
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (Id key : oldValues.keySet()) {
        relatedOpportunityLineItems.add(
          oldValues.get(key).OpportunityLineItem__c
        );
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT
          Id,
          Name,
          Description__c,
          Estimate__c,
          Product__c,
          Product__r.Id,
          Product__r.Name,
          Product__r.Design_Project__c,
          Product__r.Sales_Price_Rate__c,
          SKU__c,
          Supplier__c,
          CreatedDate,
          Tax__c
        FROM OpportunityLineItem__c
        WHERE
          Id IN :relatedOpportunityLineItems
          AND Estimate__c != NULL
          AND Product__r.Design_Project__c = TRUE
      ];
      List<id> oppLineItemIds = new List<id>();
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        oppLineItemIds.add(oppLineItem.Id);
      }
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Product__c IN :oppLineItemIds
      ];
      for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
        for (Id key : oldValues.keySet()) {
          if (oldValues.get(key).OpportunityLineItem__c == oppLineItem.id) {
            Decimal updatedCredit = 0;
            Decimal totalOldAmount = 0;
            Decimal retailPrice = 0;
            if (
              oldValues.get(key).Quantity__c != null &&
              oldValues.get(key).Net_Cost__c != null
            ) {
              if (oldValues.get(key).Retail_Price__c != null)
                retailPrice = oldValues.get(key).Retail_Price__c;
              else
                retailPrice = 0;
              totalOldAmount = oldValues.get(key).Quantity__c * retailPrice;
              if (retailPrice < oldValues.get(key).Net_Cost__c)
                updatedCredit =
                  (oldValues.get(key).Net_Cost__c *
                  oldValues.get(key).Quantity__c) - totalOldAmount;
              //updatedCredit = totalOldAmount - oppLineItem.Product__r.Sales_Price_Rate__c;
              else
                updatedCredit = 0;
              // System.debug('in if '+updatedCredit);
            }
            if (updatedCredit != 0) {
              for (Design_Project__c designProj : designProjects) {
                if (
                  designProj.Product__c != null &&
                  designProj.Product__c == oppLineItem.id
                ) {
                  if (
                    designProj.Credits__c != null &&
                    designProj.Credits__c != 0
                  ) {
                    designProj.Credits__c =
                      designProj.Credits__c - updatedCredit;
                  }
                }
              }
            }
          }
        }
      }
      update designProjects;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }
  public static void updateHistoryafterupdate(
    List<ExtraChargesEstimate__c> newValues,
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        relatedOpportunityLineItems.add(pricing.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (ExtraChargesEstimate__c extraCharge : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == extraCharge.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        if (estimateIds.get(pricing.OpportunityLineItem__c) != null) {
          String chargeType = '';
          if (pricing.Charge_Type__c == 'AdditionalCost_FixedCharge') {
            chargeType = 'Fixed Charge ';
          } else if (pricing.Charge_Type__c == 'AdditionalCost_RunCharge') {
            chargeType = 'Run Charge ';
          } else if (
            pricing.Charge_Type__c == 'InternationalCost_InboundFreight'
          ) {
            chargeType = 'Inbound Freight ';
          } else if (pricing.Charge_Type__c == 'InternationalCost_Brokerage') {
            chargeType = 'Brokerage ';
          } else if (pricing.Charge_Type__c == 'InternationalCost_Duty') {
            chargeType = 'Duty ';
          }
          if (
            pricing.Duty_Percentage__c !=
            oldValues.get(pricing.id).Duty_Percentage__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                'Duty Percentage',
                String.valueOf(pricing.Duty_Percentage__c),
                String.valueOf(oldValues.get(pricing.id).Duty_Percentage__c)
              )
            );
          }
          if (pricing.Title__c != oldValues.get(pricing.id).Title__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Title',
                pricing.Title__c,
                oldValues.get(pricing.id).Title__c
              )
            );
          }
          if (pricing.Margin__c != oldValues.get(pricing.id).Margin__c) {
            system.debug(
              'oldValues.get(pricing.id).Margin__c: ' +
              oldValues.get(pricing.id).Margin__c
            );
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Margin',
                String.valueOf(pricing.Margin__c),
                String.valueOf(oldValues.get(pricing.id).Margin__c.setScale(2))
              )
            );
          }
          if (pricing.Net_Cost__c != oldValues.get(pricing.id).Net_Cost__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Cost',
                String.valueOf(pricing.Net_Cost__c),
                String.valueOf(
                  oldValues.get(pricing.id).Net_Cost__c.setScale(2)
                )
              )
            );
          }
          if (pricing.Quantity__c != oldValues.get(pricing.id).Quantity__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Quantity',
                String.valueOf(pricing.Quantity__c),
                String.valueOf(oldValues.get(pricing.id).Quantity__c)
              )
            );
          }
          if (
            pricing.Retail_Price__c != oldValues.get(pricing.id).Retail_Price__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Retail Price',
                String.valueOf(pricing.Retail_Price__c),
                String.valueOf(
                  oldValues.get(pricing.id).Retail_Price__c.setScale(2)
                )
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in extra charge updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
  public static Estimate_History__c createHistoryRecord(
    String estId,
    String objId,
    String fieldName,
    String newValue,
    String previousValue
  ) {
    Estimate_History__c estHistory = new Estimate_History__c();
    estHistory.Estimate__c = estId;
    estHistory.Related_Object_Id__c = objId;
    estHistory.Changed_field__c = fieldName;
    estHistory.New_Value__c = newValue;
    estHistory.Previous_Value__c = previousValue;
    estHistory.Changed_By__c = changedByUser;
    return estHistory;
  }
  public static void updateHistoryAfterInsert(
    List<ExtraChargesEstimate__c> newValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        relatedOpportunityLineItems.add(pricing.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (ExtraChargesEstimate__c extraCharge : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == extraCharge.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        if (estimateIds.get(pricing.OpportunityLineItem__c) != null) {
          String chargeType = '';
          if (pricing.Charge_Type__c == 'AdditionalCost_FixedCharge') {
            chargeType = 'Fixed Charge ';
          } else if (pricing.Charge_Type__c == 'AdditionalCost_RunCharge') {
            chargeType = 'Run Charge ';
          } else if (
            pricing.Charge_Type__c == 'InternationalCost_InboundFreight'
          ) {
            chargeType = 'Inbound Freight ';
          } else if (pricing.Charge_Type__c == 'InternationalCost_Brokerage') {
            chargeType = 'Brokerage ';
          } else if (pricing.Charge_Type__c == 'InternationalCost_Duty') {
            chargeType = 'Duty ';
          }
          if (pricing.Duty_Percentage__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                'Duty Percentage',
                String.valueOf(pricing.Duty_Percentage__c),
                null
              )
            );
          }
          if (pricing.Title__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Title',
                pricing.Title__c,
                null
              )
            );
          }
          if (pricing.Margin__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Margin',
                String.valueOf(pricing.Margin__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Net_Cost__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Cost',
                String.valueOf(pricing.Net_Cost__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Quantity__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Quantity',
                String.valueOf(pricing.Quantity__c),
                null
              )
            );
          }
          if (pricing.Retail_Price__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(pricing.OpportunityLineItem__c),
                pricing.OpportunityLineItem__c,
                chargeType + 'Retail Price',
                String.valueOf(pricing.Retail_Price__c.setScale(2)),
                null
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in extra charge updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
  public static void updateHistoryBeforeDelete(
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (Id key : oldValues.keySet()) {
        relatedOpportunityLineItems.add(
          oldValues.get(key).OpportunityLineItem__c
        );
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (Id key : oldValues.keySet()) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == oldValues.get(key).OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (Id key : oldValues.keySet()) {
        if (
          estimateIds.get(oldValues.get(key).OpportunityLineItem__c) != null
        ) {
          String chargeType = '';
          if (
            oldValues.get(key).Charge_Type__c == 'AdditionalCost_FixedCharge'
          ) {
            chargeType = 'Fixed Charge ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'AdditionalCost_RunCharge'
          ) {
            chargeType = 'Run Charge ';
          } else if (
            oldValues.get(key).Charge_Type__c ==
            'InternationalCost_InboundFreight'
          ) {
            chargeType = 'Inbound Freight ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'InternationalCost_Brokerage'
          ) {
            chargeType = 'Brokerage ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'InternationalCost_Duty'
          ) {
            chargeType = 'Duty ';
          }
          if (oldValues.get(key).Duty_Percentage__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Duty Percentage',
                null,
                String.valueOf(oldValues.get(key).Duty_Percentage__c)
              )
            );
          }
          if (oldValues.get(key).Title__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                chargeType + 'Title',
                null,
                oldValues.get(key).Title__c
              )
            );
          }
          if (oldValues.get(key).Margin__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                chargeType + 'Margin',
                null,
                String.valueOf(oldValues.get(key).Margin__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Net_Cost__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                chargeType + 'Cost',
                null,
                String.valueOf(oldValues.get(key).Net_Cost__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Quantity__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                chargeType + 'Quantity',
                null,
                String.valueOf(oldValues.get(key).Quantity__c)
              )
            );
          }
          if (oldValues.get(key).Retail_Price__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                chargeType + 'Retail Price',
                null,
                String.valueOf(oldValues.get(key).Retail_Price__c.setScale(2))
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in extra charge updateHistoryafterDelete---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is returning the SalesOrder history record which is storing the basic field values
   */
  public static Sales_Order_History__c createSOHistoryRecord(
    Id WorkOrderId,
    String SalesOrderName,
    String fieldName,
    String newValue,
    String previousValue
  ) {
    Sales_Order_History__c SOHistory = new Sales_Order_History__c();
    SOHistory.Changed_field_text__c = fieldName;
    SOHistory.New_Value_Text__c = newValue;
    SOHistory.Old_Value_Text__c = previousValue;
    SOHistory.CreatedById = changedByUser;
    SOHistory.Work_Order__c = WorkOrderId;
    SOHistory.Sales_Order_LI_Name__c = SalesOrderName;
    return SOHistory;
  }

  /**
   * This function is saving the SalesOrder history when SalesOrder is inserted from WorkOrder
   */
  public static void updateSOHistoryafterInsert(
    List<ExtraChargesEstimate__c> newValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }

      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];
      for (OpportunityLineItem__c workOrder : workOrders) {
        for (ExtraChargesEstimate__c pricing : newValues) {
          if (
            pricing.OpportunityLineItem__c != null &&
            pricing.OpportunityLineItem__c == workOrder.Id
          ) {
            String chargeType = '';
            if (pricing.Charge_Type__c == 'AdditionalCost_FixedCharge') {
              chargeType = 'Fixed Charge ';
            } else if (pricing.Charge_Type__c == 'AdditionalCost_RunCharge') {
              chargeType = 'Run Charge ';
            } else if (
              pricing.Charge_Type__c == 'InternationalCost_InboundFreight'
            ) {
              chargeType = 'Inbound Freight ';
            } else if (
              pricing.Charge_Type__c == 'InternationalCost_Brokerage'
            ) {
              chargeType = 'Brokerage ';
            } else if (pricing.Charge_Type__c == 'InternationalCost_Duty') {
              chargeType = 'Duty ';
            }

            if (pricing.Duty_Percentage__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Duty Percentage',
                  String.valueOf(pricing.Duty_Percentage__c),
                  null
                )
              );
            }
            if (pricing.Title__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Title',
                  pricing.Title__c,
                  null
                )
              );
            }
            if (pricing.Margin__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Margin',
                  String.valueOf(pricing.Margin__c),
                  null
                )
              );
            }
            if (pricing.Net_Cost__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Cost',
                  String.valueOf(pricing.Net_Cost__c),
                  null
                )
              );
            }
            if (pricing.Quantity__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Quantity',
                  String.valueOf(pricing.Quantity__c),
                  null
                )
              );
            }
            if (pricing.Retail_Price__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Unit Price',
                  String.valueOf(pricing.Retail_Price__c),
                  null
                )
              );
            }
          }
        }
      }

      if (SOHistoryList.size() > 0) {
        insert SOHistoryList;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateSOHistoryafterInsert---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when SalesOrder is updated from WorkOrder
   */
  public static void updateSOHistoryafterUpdate(
    List<ExtraChargesEstimate__c> newValues,
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (ExtraChargesEstimate__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }

      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];

      for (OpportunityLineItem__c workOrder : workOrders) {
        for (ExtraChargesEstimate__c pricing : newValues) {
          if (
            pricing.OpportunityLineItem__c != null &&
            pricing.OpportunityLineItem__c == workOrder.Id
          ) {
            String chargeType = '';
            if (pricing.Charge_Type__c == 'AdditionalCost_FixedCharge') {
              chargeType = 'Fixed Charge ';
            } else if (pricing.Charge_Type__c == 'AdditionalCost_RunCharge') {
              chargeType = 'Run Charge ';
            } else if (
              pricing.Charge_Type__c == 'InternationalCost_InboundFreight'
            ) {
              chargeType = 'Inbound Freight ';
            } else if (
              pricing.Charge_Type__c == 'InternationalCost_Brokerage'
            ) {
              chargeType = 'Brokerage ';
            } else if (pricing.Charge_Type__c == 'InternationalCost_Duty') {
              chargeType = 'Duty ';
            }
            if (
              pricing.Duty_Percentage__c !=
              oldValues.get(pricing.id).Duty_Percentage__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Duty Percentage',
                  String.valueOf(pricing.Duty_Percentage__c),
                  String.valueOf(oldValues.get(pricing.id).Duty_Percentage__c)
                )
              );
            }
            if (pricing.Title__c != oldValues.get(pricing.id).Title__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Title',
                  pricing.Title__c,
                  oldValues.get(pricing.id).Title__c
                )
              );
            }
            if (pricing.Margin__c != oldValues.get(pricing.id).Margin__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Margin',
                  String.valueOf(pricing.Margin__c),
                  String.valueOf(
                    oldValues.get(pricing.id).Margin__c.setScale(2)
                  )
                )
              );
            }
            if (pricing.Net_Cost__c != oldValues.get(pricing.id).Net_Cost__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Unit Cost',
                  String.valueOf(pricing.Net_Cost__c),
                  String.valueOf(
                    oldValues.get(pricing.id).Net_Cost__c.setScale(2)
                  )
                )
              );
            }
            if (pricing.Quantity__c != oldValues.get(pricing.id).Quantity__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'QTY',
                  String.valueOf(pricing.Quantity__c),
                  String.valueOf(oldValues.get(pricing.id).Quantity__c)
                )
              );
            }
            if (
              pricing.Retail_Price__c !=
              oldValues.get(pricing.id).Retail_Price__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  chargeType + 'Unit Price',
                  String.valueOf(pricing.Retail_Price__c),
                  String.valueOf(oldValues.get(pricing.id).Retail_Price__c)
                )
              );
            }
          }
        }
      }

      if (SOHistoryList.size() > 0) {
        insert SOHistoryList;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateSOHistoryafterUpdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when SalesOrder is updated from WorkOrder
   */
  public static void updateSOHistoryafterDelete(
    Map<Id, ExtraChargesEstimate__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (Id key : oldValues.keySet()) {
        OPLIPricingIds.add(oldValues.get(key).OpportunityLineItem__c);
      }

      OpportunityLineItem__c workOrder = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ][0];

      for (Id key : oldValues.keySet()) {
        if (
          oldValues.get(key).OpportunityLineItem__c != null &&
          oldValues.get(key).OpportunityLineItem__c == workOrder.Id
        ) {
          String chargeType = '';
          if (
            oldValues.get(key).Charge_Type__c == 'AdditionalCost_FixedCharge'
          ) {
            chargeType = 'Fixed Charge ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'AdditionalCost_RunCharge'
          ) {
            chargeType = 'Run Charge ';
          } else if (
            oldValues.get(key).Charge_Type__c ==
            'InternationalCost_InboundFreight'
          ) {
            chargeType = 'Inbound Freight ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'InternationalCost_Brokerage'
          ) {
            chargeType = 'Brokerage ';
          } else if (
            oldValues.get(key).Charge_Type__c == 'InternationalCost_Duty'
          ) {
            chargeType = 'Duty ';
          }
          if (oldValues.get(key).Duty_Percentage__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'Duty Percentage',
                null,
                String.valueOf(oldValues.get(key).Duty_Percentage__c)
              )
            );
          }
          if (oldValues.get(key).Title__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'Title',
                null,
                oldValues.get(key).Title__c
              )
            );
          }
          if (oldValues.get(key).Margin__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'Margin',
                null,
                String.valueOf(oldValues.get(key).Margin__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Net_Cost__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'Unit Cost',
                null,
                String.valueOf(oldValues.get(key).Net_Cost__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Quantity__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'QTY',
                null,
                String.valueOf(oldValues.get(key).Quantity__c)
              )
            );
          }
          if (oldValues.get(key).Retail_Price__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                chargeType + 'Unit Price',
                null,
                String.valueOf(oldValues.get(key).Retail_Price__c)
              )
            );
          }
        }
      }

      if (SOHistoryList.size() > 0) {
        insert SOHistoryList;
      }
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateSOHistoryafterdelete---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
}
