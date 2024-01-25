public class TriggerOnPricingLineItemService {
  static Map<Id, Boolean> isAfterInsert = new Map<Id, Boolean>();
  public static Id changedByUser = [
    SELECT id
    FROM User
    WHERE id = :UserInfo.getUserId()
  ]
  .id;

  public static void updateDesignProjectsAfterUpdate(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      Set<Id> relatedOpportunityLineItems = new Set<Id>();
      for (PricingLineItem__c pricing : newValues) {
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
        for (PricingLineItem__c pricing : newValues) {
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
            Decimal retail_price = 0;

            if (
              pricing.Estimated_Quantity__c != null &&
              pricing.Net_Cost__c != null
            ) {
              if (pricing.Retail_Price__c == null) {
                retail_price = 0;
              }
              totalNewAmount = pricing.Estimated_Quantity__c * retail_price;
              if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                totalNewCredit =
                  (pricing.Estimated_Quantity__c * pricing.Net_Cost__c) -
                  (pricing.Estimated_Quantity__c * pricing.Retail_Price__c ==
                    null
                    ? 0
                    : pricing.Retail_Price__c);
              //totalNewCredit = totalNewAmount - oppLineItem.Product__r.Sales_Price_Rate__c;
              else
                totalNewCredit = 0;
            }
            if (
              oldValues.get(pricing.id).Estimated_Quantity__c != null &&
              oldValues.get(pricing.id).Net_Cost__c != null
            ) {
              if (oldValues.get(pricing.id).Retail_Price__c == null) {
                //oldValues.get(pricing.id).Retail_Price__c = 0;
              }
              totalOldAmount = oldValues.get(pricing.id).Estimated_Quantity__c *
                oldValues.get(pricing.id).Retail_Price__c == null
                ? 0
                : oldValues.get(pricing.id).Retail_Price__c;
              if (
                oldValues.get(pricing.id).Retail_Price__c <
                oldValues.get(pricing.id).Net_Cost__c
              )
                totalOldCredit =
                  (oldValues.get(pricing.id).Estimated_Quantity__c *
                  oldValues.get(pricing.id).Net_Cost__c) -
                  (oldValues.get(pricing.id).Estimated_Quantity__c *
                  oldValues.get(pricing.id).Retail_Price__c);
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
      update designProjectsToBeUpdated;
    } catch (Exception ex) {
      System.debug(
        'Exception ---->>>>' + ex.getStackTraceString() + ex.getMessage()
      );
    }
  }

  public static void updateDesignProjectsAfterInsert(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      Set<Id> relatedOpportunityLineItems = new Set<Id>();
      for (PricingLineItem__c pricing : newValues) {
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
        for (PricingLineItem__c pricing : newValues) {
          if (
            !(pricingIds.contains(pricing.id)) &&
            pricing.OpportunityLineItem__c == oppLineItem.id &&
            pricing.Display__c &&
            !pricing.Default__c
          ) {
            pricingIds.add(pricing.id);
            Decimal totalNewAmount = 0;
            Decimal updatedCredit = 0;
            if (
              pricing.Estimated_Quantity__c != null &&
              pricing.Net_Cost__c != null
            ) {
              if (pricing.Retail_Price__c != null) {
                totalNewAmount =
                  pricing.Estimated_Quantity__c * pricing.Retail_Price__c;
              } ///////
              if (pricing.Retail_Price__c != null) {
                if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                  updatedCredit =
                    (pricing.Estimated_Quantity__c * pricing.Net_Cost__c) -
                    totalNewAmount;
                else
                  updatedCredit = 0;
              } else {
                updatedCredit =
                  pricing.Estimated_Quantity__c * pricing.Net_Cost__c;
              }
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
                  designProj.Credits__c = designProj.Credits__c + updatedCredit;
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
    Map<Id, PricingLineItem__c> oldValues
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
            /*if(oldValues.get(key).Last_Valid_Credit__c != null 
&& oldValues.get(key).Last_Valid_Credit__c !=0)
{
updatedCredit = oldValues.get(key).Last_Valid_Credit__c - oppLineItem.Product__r.Sales_Price_Rate__c; 
}*/
            if (
              oldValues.get(key).Estimated_Quantity__c != null &&
              oldValues.get(key).Net_Cost__c != null
            ) {
              if (oldValues.get(key).Retail_Price__c != null)
                retailPrice = oldValues.get(key).Retail_Price__c;
              else
                retailPrice = 0;
              totalOldAmount =
                oldValues.get(key).Estimated_Quantity__c * retailPrice;
              if (retailPrice < oldValues.get(key).Net_Cost__c)
                updatedCredit =
                  (oldValues.get(key).Net_Cost__c *
                  oldValues.get(key).Estimated_Quantity__c) - totalOldAmount;
              else
                updatedCredit = 0;
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

  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (PricingLineItem__c pricing : newValues) {
      relatedOpportunityLineItems.add(pricing.OpportunityLineItem__c);
    }
    List<OpportunityLineItem__c> opportunityLineItem = [
      SELECT
        Id,
        Estimate__r.Opportunity__c,
        Work_Order__r.OpportunityId,
        Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Id IN :relatedOpportunityLineItems
    ];
    Map<Id, OpportunityLineItem__c> opportunityLineItemMap = new Map<Id, OpportunityLineItem__c>(
      [
        SELECT
          Id,
          Estimate__r.Opportunity__c,
          Work_Order__r.OpportunityId,
          Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ]
    );

    List<Id> opportunitiesToUpdate = new List<Id>();
    for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
      Id opportunityId = null;
      if (oppLineItem.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Opportunity__c);
      } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
        opportunitiesToUpdate.add(oppLineItem.Estimate__r.Opportunity__c);
      } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
        opportunitiesToUpdate.add(oppLineItem.Work_Order__r.OpportunityId);
      }
    }
    Map<Id, Opportunity> updatedOpportunity = new Map<Id, Opportunity>();
    if (opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :opportunitiesToUpdate
        ]
      );
      for (PricingLineItem__c pricingLineItem : newValues) {
        PricingLineItem__c relatedOldValue = oldValues.get(pricingLineItem.Id);
        if (
          relatedOldValue.Estimated_Quantity__c !=
          pricingLineItem.Estimated_Quantity__c ||
          relatedOldValue.Margin__c != pricingLineItem.Margin__c ||
          relatedOldValue.Net_Cost__c != pricingLineItem.Net_Cost__c ||
          relatedOldValue.Retail_Price__c != pricingLineItem.Retail_Price__c ||
          relatedOldValue.Show_To_Client__c !=
          pricingLineItem.Show_To_Client__c ||
          relatedOldValue.Color__c != pricingLineItem.Color__c ||
          relatedOldValue.Size__c != pricingLineItem.Size__c
        ) {
          OpportunityLineItem__c oppLineItem = opportunityLineItemMap.get(
            pricingLineItem.OpportunityLineItem__c
          );
          if (oppLineItem.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(oppLineItem.Opportunity__c);
            opp.isOutdated__c = true;
            updatedOpportunity.put(opp.Id, opp);
          } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Estimate__r.Opportunity__c
            );
            opp.isOutdated__c = true;
            updatedOpportunity.put(opp.Id, opp);
          } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Work_Order__r.OpportunityId
            );
            opp.isOutdated__c = true;
            updatedOpportunity.put(opp.Id, opp);
          }
        }
      }
      update updatedOpportunity.Values();
    }
  }

  public static void updateHistoryafterupdate(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (PricingLineItem__c pricing : newValues) {
        if (pricing.Estimate__c != null) {
          if (pricing.Color__c != oldValues.get(pricing.id).Color__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Color',
                pricing.Color__c,
                oldValues.get(pricing.id).Color__c
              )
            );
          }
          if (
            pricing.Estimated_Quantity__c !=
            oldValues.get(pricing.id).Estimated_Quantity__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Quantity',
                String.valueOf(pricing.Estimated_Quantity__c),
                String.valueOf(oldValues.get(pricing.id).Estimated_Quantity__c)
              )
            );
          }
          if (pricing.Margin__c != oldValues.get(pricing.id).Margin__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Margin',
                String.valueOf(pricing.Margin__c.setScale(2)),
                String.valueOf(oldValues.get(pricing.id).Margin__c.setScale(2))
              )
            );
          }
          if (pricing.Net_Cost__c != oldValues.get(pricing.id).Net_Cost__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Cost',
                String.valueOf(pricing.Net_Cost__c.setScale(2)),
                String.valueOf(
                  oldValues.get(pricing.id).Net_Cost__c.setScale(2)
                )
              )
            );
          }
          if (
            pricing.Price_Per_Unit__c !=
            oldValues.get(pricing.id).Price_Per_Unit__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Price Per Unit',
                String.valueOf(pricing.Price_Per_Unit__c.setScale(2)),
                String.valueOf(
                  oldValues.get(pricing.id).Price_Per_Unit__c.setScale(2)
                )
              )
            );
          }
          if (
            pricing.Retail_Price__c != oldValues.get(pricing.id).Retail_Price__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Retail Price',
                String.valueOf(pricing.Retail_Price__c.setScale(2)),
                String.valueOf(
                  oldValues.get(pricing.id).Retail_Price__c.setScale(2)
                )
              )
            );
          }
          if (pricing.Size__c != oldValues.get(pricing.id).Size__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Size',
                pricing.Size__c,
                oldValues.get(pricing.id).Size__c
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateHistoryafterupdate---->>>>' +
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

  public static void updateHistoryafterInsert(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (PricingLineItem__c pricing : newValues) {
        if (pricing.Estimate__c != null) {
          if (pricing.Color__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Color',
                pricing.Color__c,
                null
              )
            );
          }
          if (pricing.Estimated_Quantity__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Quantity',
                String.valueOf(pricing.Estimated_Quantity__c),
                null
              )
            );
          }
          if (pricing.Margin__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Margin',
                String.valueOf(pricing.Margin__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Net_Cost__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Cost',
                String.valueOf(pricing.Net_Cost__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Price_Per_Unit__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Price Per Unit',
                String.valueOf(pricing.Price_Per_Unit__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Retail_Price__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Retail Price',
                String.valueOf(pricing.Retail_Price__c.setScale(2)),
                null
              )
            );
          }
          if (pricing.Size__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                pricing.Estimate__c,
                pricing.OpportunityLineItem__c,
                'Pricing Size',
                pricing.Size__c,
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
        'Exception in pricing updateHistoryafterInsert---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
  public static void updateHistoryAfterDelete(
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (Id key : oldValues.keySet()) {
        if (oldValues.get(key).Estimate__c != null) {
          if (oldValues.get(key).Color__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Color',
                null,
                oldValues.get(key).Color__c
              )
            );
          }
          if (oldValues.get(key).Estimated_Quantity__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Quantity',
                null,
                String.valueOf(oldValues.get(key).Estimated_Quantity__c)
              )
            );
          }
          if (oldValues.get(key).Margin__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Margin',
                null,
                String.valueOf(oldValues.get(key).Margin__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Net_Cost__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Cost',
                null,
                String.valueOf(oldValues.get(key).Net_Cost__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Price_Per_Unit__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Price Per Unit',
                null,
                String.valueOf(oldValues.get(key).Price_Per_Unit__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Retail_Price__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Retail Price',
                null,
                String.valueOf(oldValues.get(key).Retail_Price__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Size__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                oldValues.get(key).Estimate__c,
                oldValues.get(key).OpportunityLineItem__c,
                'Pricing Size',
                null,
                oldValues.get(key).Size__c
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateHistoryafterupdate---->>>>' +
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
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (PricingLineItem__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }

      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];
      for (OpportunityLineItem__c workOrder : workOrders) {
        for (PricingLineItem__c pricing : newValues) {
          if (
            pricing.OpportunityLineItem__c != null &&
            pricing.OpportunityLineItem__c == workOrder.Id &&
            (pricing.Display__c == true &&
            pricing.Default__c == false)
          ) {
            if (pricing.Color__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Color',
                  pricing.Color__c,
                  null
                )
              );
            }
            if (pricing.Estimated_Quantity__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product QTY',
                  String.valueOf(pricing.Estimated_Quantity__c),
                  null
                )
              );
            }
            if (pricing.Margin__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Margin',
                  String.valueOf(pricing.Margin__c.setScale(2)),
                  null
                )
              );
            }
            if (pricing.Net_Cost__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Unit Cost',
                  String.valueOf(pricing.Net_Cost__c.setScale(2)),
                  null
                )
              );
            }
            if (pricing.Retail_Price__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Unit Price',
                  String.valueOf(pricing.Retail_Price__c.setScale(2)),
                  null
                )
              );
            }
            if (pricing.Size__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Size',
                  pricing.Size__c,
                  null
                )
              );
            }
          }
        }
      }

      if (SOHistoryList.size() > 0)
        insert SOHistoryList;
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
  public static void updateSOHistoryafterupdate(
    List<PricingLineItem__c> newValues,
    Map<Id, PricingLineItem__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (PricingLineItem__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];

      for (OpportunityLineItem__c workOrder : workOrders) {
        for (PricingLineItem__c pricing : newValues) {
          if (
            pricing.OpportunityLineItem__c != null &&
            pricing.OpportunityLineItem__c == workOrder.Id
          ) {
            if (pricing.Color__c != oldValues.get(pricing.id).Color__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Color',
                  pricing.Color__c,
                  oldValues.get(pricing.id).Color__c
                )
              );
            }
            if (
              pricing.Estimated_Quantity__c !=
              oldValues.get(pricing.id).Estimated_Quantity__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product QTY',
                  String.valueOf(pricing.Estimated_Quantity__c),
                  String.valueOf(
                    oldValues.get(pricing.id).Estimated_Quantity__c
                  )
                )
              );
            }
            if (pricing.Margin__c != oldValues.get(pricing.id).Margin__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Margin',
                  String.valueOf(pricing.Margin__c.setScale(2)),
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
                  'Product Unit Cost',
                  String.valueOf(pricing.Net_Cost__c.setScale(2)),
                  String.valueOf(
                    oldValues.get(pricing.id).Net_Cost__c.setScale(2)
                  )
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
                  'Product Unit Price',
                  String.valueOf(pricing.Retail_Price__c.setScale(2)),
                  String.valueOf(
                    oldValues.get(pricing.id).Retail_Price__c.setScale(2)
                  )
                )
              );
            }
            if (pricing.Size__c != oldValues.get(pricing.id).Size__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Product Size',
                  pricing.Size__c,
                  oldValues.get(pricing.id).Size__c
                )
              );
            }
          }
        }
      }

      if (SOHistoryList.size() > 0)
        insert SOHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateSOHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when SalesOrder is deleted from WorkOrder
   */
  public static void updateSOHistoryAfterDelete(
    Map<Id, PricingLineItem__c> oldValues
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
          if (oldValues.get(key).Color__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Product Color',
                null,
                oldValues.get(key).Color__c
              )
            );
          }
          if (oldValues.get(key).Estimated_Quantity__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Product QTY',
                null,
                String.valueOf(oldValues.get(key).Estimated_Quantity__c)
              )
            );
          }
          if (oldValues.get(key).Margin__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Product Margin',
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
                'Product Unit Cost',
                null,
                String.valueOf(oldValues.get(key).Net_Cost__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Retail_Price__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Product Unit Price',
                null,
                String.valueOf(oldValues.get(key).Retail_Price__c.setScale(2))
              )
            );
          }
          if (oldValues.get(key).Size__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Product Size',
                null,
                oldValues.get(key).Size__c
              )
            );
          }
        }
      }

      if (SOHistoryList.size() > 0)
        insert SOHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in pricing updateSOHistoryAfteDelete---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
}
