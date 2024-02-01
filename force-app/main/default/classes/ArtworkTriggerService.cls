public class ArtworkTriggerService {
  public static Id changedByUser = [
    SELECT id
    FROM User
    WHERE id = :UserInfo.getUserId()
  ]
  .id;

  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<OpportunityLineItem_ArtWork__c> newValues,
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
  ) {
    List<Id> relatedOpportunityLineItems = new List<Id>();
    for (OpportunityLineItem_ArtWork__c artworks : newValues) {
      relatedOpportunityLineItems.add(artworks.OpportunityLineItem__c);
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
    List<Opportunity> updatedOpportunity = new List<Opportunity>();
    if (opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :opportunitiesToUpdate
        ]
      );
      for (OpportunityLineItem_ArtWork__c artworks : newValues) {
        //SELECT Id, Imprint_Type__c, Proof_Required__c, logo_Name__c, Logo_Size__c, Logo_Color__c, Repeat_Logo__c, Supplier_Notes__c, Document_ID__c, Title__c
        OpportunityLineItem_ArtWork__c relatedOldValue = oldValues.get(
          artworks.Id
        );

        if (
          relatedOldValue.Title__c != artworks.Title__c ||
          relatedOldValue.Document_ID__c != artworks.Document_ID__c ||
          relatedOldValue.Supplier_Notes__c != artworks.Supplier_Notes__c ||
          relatedOldValue.Repeat_Logo__c != artworks.Repeat_Logo__c ||
          relatedOldValue.Logo_Color__c != artworks.Logo_Color__c ||
          relatedOldValue.Logo_Size__c != artworks.Logo_Size__c ||
          relatedOldValue.logo_Name__c != artworks.logo_Name__c ||
          relatedOldValue.Proof_Required__c != artworks.Proof_Required__c ||
          relatedOldValue.Imprint_Type__c != artworks.Imprint_Type__c
        ) {
          OpportunityLineItem__c oppLineItem = opportunityLineItemMap.get(
            artworks.OpportunityLineItem__c
          );
          if (oppLineItem.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(oppLineItem.Opportunity__c);
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Estimate__r.Opportunity__c
            );
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Work_Order__r.OpportunityId
            );
            opp.isOutdated__c = true;
            updatedOpportunity.add(opp);
          }
        }
      }
      update updatedOpportunity;
    }
  }
  public static void updateHistoryafterupdate(
    List<OpportunityLineItem_ArtWork__c> newValues,
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        relatedOpportunityLineItems.add(artwork.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == artwork.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        if (estimateIds.get(artwork.OpportunityLineItem__c) != null) {
          if (artwork.Title__c != oldValues.get(artwork.id).Title__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Title',
                artwork.Title__c,
                oldValues.get(artwork.id).Title__c
              )
            );
          }
          if (
            artwork.Imprint_Type__c != oldValues.get(artwork.id).Imprint_Type__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Imprint Type',
                artwork.Imprint_Type__c,
                oldValues.get(artwork.id).Imprint_Type__c
              )
            );
          }
          if (
            artwork.Proof_Required__c !=
            oldValues.get(artwork.id).Proof_Required__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Proof Required',
                artwork.Proof_Required__c,
                oldValues.get(artwork.id).Proof_Required__c
              )
            );
          }
          if (artwork.logo_Name__c != oldValues.get(artwork.id).logo_Name__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Name',
                artwork.logo_Name__c,
                oldValues.get(artwork.id).logo_Name__c
              )
            );
          }
          if (artwork.Logo_Size__c != oldValues.get(artwork.id).Logo_Size__c) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Size',
                artwork.Logo_Size__c,
                oldValues.get(artwork.id).Logo_Size__c
              )
            );
          }
          if (
            artwork.Logo_Color__c != oldValues.get(artwork.id).Logo_Color__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Color',
                artwork.Logo_Color__c,
                oldValues.get(artwork.id).Logo_Color__c
              )
            );
          }
          if (
            artwork.Repeat_Logo__c != oldValues.get(artwork.id).Repeat_Logo__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Repeat Logo',
                artwork.Repeat_Logo__c,
                oldValues.get(artwork.id).Repeat_Logo__c
              )
            );
          }
          if (
            artwork.Supplier_Notes__c !=
            oldValues.get(artwork.id).Supplier_Notes__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Supplier Notes',
                artwork.Supplier_Notes__c,
                oldValues.get(artwork.id).Supplier_Notes__c
              )
            );
          }
          if (
            artwork.Document_ID__c != oldValues.get(artwork.id).Document_ID__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Image',
                artwork.Document_ID__c,
                oldValues.get(artwork.id).Document_ID__c
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in artwork updateHistoryafterupdate---->>>>' +
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
    List<OpportunityLineItem_ArtWork__c> newValues
  ) {
    try {
      List<Id> relatedOpportunityLineItems = new List<Id>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        relatedOpportunityLineItems.add(artwork.OpportunityLineItem__c);
      }
      List<OpportunityLineItem__c> opportunityLineItem = [
        SELECT Id, Estimate__c
        FROM OpportunityLineItem__c
        WHERE Id IN :relatedOpportunityLineItems
      ];
      Map<Id, Id> estimateIds = new Map<Id, Id>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        for (OpportunityLineItem__c lineItem : opportunityLineItem) {
          if (lineItem.id == artwork.OpportunityLineItem__c) {
            estimateIds.put(lineItem.id, lineItem.Estimate__c);
          }
        }
      }
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (OpportunityLineItem_ArtWork__c artwork : newValues) {
        if (estimateIds.get(artwork.OpportunityLineItem__c) != null) {
          if (artwork.Title__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Title',
                artwork.Title__c,
                null
              )
            );
          }
          if (artwork.Imprint_Type__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Imprint Type',
                artwork.Imprint_Type__c,
                null
              )
            );
          }
          if (artwork.Proof_Required__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Proof Required',
                artwork.Proof_Required__c,
                null
              )
            );
          }
          if (artwork.logo_Name__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Name',
                artwork.logo_Name__c,
                null
              )
            );
          }
          if (artwork.Logo_Size__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Size',
                artwork.Logo_Size__c,
                null
              )
            );
          }
          if (artwork.Logo_Color__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Logo Color',
                artwork.Logo_Color__c,
                null
              )
            );
          }
          if (artwork.Repeat_Logo__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Repeat Logo',
                artwork.Repeat_Logo__c,
                null
              )
            );
          }
          if (artwork.Supplier_Notes__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Supplier Notes',
                artwork.Supplier_Notes__c,
                null
              )
            );
          }
          if (artwork.Document_ID__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(artwork.OpportunityLineItem__c),
                artwork.OpportunityLineItem__c,
                'Artwork Image',
                artwork.Document_ID__c,
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
        'Exception in artwork updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  public static void updateHistoryBeforeDelete(
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
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
          if (oldValues.get(key).Title__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Title',
                null,
                oldValues.get(key).Title__c
              )
            );
          }
          if (oldValues.get(key).Imprint_Type__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Imprint Type',
                null,
                oldValues.get(key).Imprint_Type__c
              )
            );
          }
          if (oldValues.get(key).Proof_Required__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Proof Required',
                null,
                oldValues.get(key).Proof_Required__c
              )
            );
          }
          if (oldValues.get(key).logo_Name__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Logo Name',
                null,
                oldValues.get(key).logo_Name__c
              )
            );
          }
          if (oldValues.get(key).Logo_Size__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Logo Size',
                null,
                oldValues.get(key).Logo_Size__c
              )
            );
          }
          if (oldValues.get(key).Logo_Color__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Logo Color',
                null,
                oldValues.get(key).Logo_Color__c
              )
            );
          }
          if (oldValues.get(key).Repeat_Logo__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Repeat Logo',
                null,
                oldValues.get(key).Repeat_Logo__c
              )
            );
          }
          if (oldValues.get(key).Supplier_Notes__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Supplier Notes',
                null,
                oldValues.get(key).Supplier_Notes__c
              )
            );
          }
          if (oldValues.get(key).Document_ID__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                estimateIds.get(oldValues.get(key).OpportunityLineItem__c),
                oldValues.get(key).OpportunityLineItem__c,
                'Artwork Image',
                null,
                oldValues.get(key).Document_ID__c
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in artwork updateHistoryafterupdate---->>>>' +
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
   * This function is saving the SalesOrder history when Artwork is inserted from WorkOrder
   */
  public static void updateSOHistoryafterInsert(
    List<OpportunityLineItem_ArtWork__c> newValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (OpportunityLineItem_ArtWork__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }

      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];

      for (OpportunityLineItem__c workOrder : workOrders) {
        for (OpportunityLineItem_ArtWork__c artwork : newValues) {
          if (
            artwork.OpportunityLineItem__c != null &&
            artwork.OpportunityLineItem__c == workOrder.Id
          ) {
            if (artwork.Title__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Title',
                  artwork.Title__c,
                  null
                )
              );
            }
            if (artwork.Imprint_Type__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Imprint Type',
                  artwork.Imprint_Type__c,
                  null
                )
              );
            }
            if (artwork.Proof_Required__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Proof Required',
                  artwork.Proof_Required__c,
                  null
                )
              );
            }
            if (artwork.logo_Name__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Name',
                  artwork.logo_Name__c,
                  null
                )
              );
            }
            if (artwork.Logo_Size__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Size',
                  artwork.Logo_Size__c,
                  null
                )
              );
            }
            if (artwork.Logo_Color__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Color',
                  artwork.Logo_Color__c,
                  null
                )
              );
            }
            if (artwork.Repeat_Logo__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Repeat Logo',
                  artwork.Repeat_Logo__c,
                  null
                )
              );
            }
            if (artwork.Supplier_Notes__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Supplier Notes',
                  artwork.Supplier_Notes__c,
                  null
                )
              );
            }
            if (artwork.Document_ID__c != null) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Image',
                  artwork.Document_ID__c,
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
        'Exception in artwork updateSOHistoryAfterInsert---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when Artwork is updated from WorkOrder
   */
  public static void updateSOHistoryAfterUpdate(
    List<OpportunityLineItem_ArtWork__c> newValues,
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      List<Id> OPLIPricingIds = new List<Id>();
      for (OpportunityLineItem_ArtWork__c pricing : newValues) {
        OPLIPricingIds.add(pricing.OpportunityLineItem__c);
      }

      List<OpportunityLineItem__c> workOrders = [
        SELECT Id, Work_Order__c, Name
        FROM OpportunityLineItem__c
        WHERE Id IN :OPLIPricingIds
      ];

      for (OpportunityLineItem__c workOrder : workOrders) {
        for (OpportunityLineItem_ArtWork__c artwork : newValues) {
          if (
            artwork.OpportunityLineItem__c != null &&
            artwork.OpportunityLineItem__c == workOrder.id
          ) {
            if (artwork.Title__c != oldValues.get(artwork.id).Title__c) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Title',
                  artwork.Title__c,
                  oldValues.get(artwork.id).Title__c
                )
              );
            }
            if (
              artwork.Imprint_Type__c !=
              oldValues.get(artwork.id).Imprint_Type__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Imprint Type',
                  artwork.Imprint_Type__c,
                  oldValues.get(artwork.id).Imprint_Type__c
                )
              );
            }
            if (
              artwork.Proof_Required__c !=
              oldValues.get(artwork.id).Proof_Required__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Proof Required',
                  artwork.Proof_Required__c,
                  oldValues.get(artwork.id).Proof_Required__c
                )
              );
            }
            if (
              artwork.logo_Name__c != oldValues.get(artwork.id).logo_Name__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Name',
                  artwork.logo_Name__c,
                  oldValues.get(artwork.id).logo_Name__c
                )
              );
            }
            if (
              artwork.Logo_Size__c != oldValues.get(artwork.id).Logo_Size__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Size',
                  artwork.Logo_Size__c,
                  oldValues.get(artwork.id).Logo_Size__c
                )
              );
            }
            if (
              artwork.Logo_Color__c != oldValues.get(artwork.id).Logo_Color__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Logo Color',
                  artwork.Logo_Color__c,
                  oldValues.get(artwork.id).Logo_Color__c
                )
              );
            }
            if (
              artwork.Repeat_Logo__c != oldValues.get(artwork.id).Repeat_Logo__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Repeat Logo',
                  artwork.Repeat_Logo__c,
                  oldValues.get(artwork.id).Repeat_Logo__c
                )
              );
            }
            if (
              artwork.Supplier_Notes__c !=
              oldValues.get(artwork.id).Supplier_Notes__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Supplier Notes',
                  artwork.Supplier_Notes__c,
                  oldValues.get(artwork.id).Supplier_Notes__c
                )
              );
            }
            if (
              artwork.Document_ID__c != oldValues.get(artwork.id).Document_ID__c
            ) {
              SOHistoryList.add(
                createSOHistoryRecord(
                  workOrder.Work_Order__c,
                  workOrder.Name,
                  'Artwork Image',
                  artwork.Document_ID__c,
                  oldValues.get(artwork.id).Document_ID__c
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
        'Exception in artwork updateSOHistoryAfterUpdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when Artwork is deleted from WorkOrder
   */
  public static void updateSOHistoryAfterDelete(
    Map<Id, OpportunityLineItem_ArtWork__c> oldValues
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
          oldValues.get(key).OpportunityLineItem__c == workOrder.id
        ) {
          if (oldValues.get(key).Title__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Title',
                null,
                oldValues.get(key).Title__c
              )
            );
          }
          if (oldValues.get(key).Imprint_Type__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Imprint Type',
                null,
                oldValues.get(key).Imprint_Type__c
              )
            );
          }
          if (oldValues.get(key).Proof_Required__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Proof Required',
                null,
                oldValues.get(key).Proof_Required__c
              )
            );
          }
          if (oldValues.get(key).logo_Name__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Logo Name',
                null,
                oldValues.get(key).logo_Name__c
              )
            );
          }
          if (oldValues.get(key).Logo_Size__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Logo Size',
                null,
                oldValues.get(key).Logo_Size__c
              )
            );
          }
          if (oldValues.get(key).Logo_Color__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Logo Color',
                null,
                oldValues.get(key).Logo_Color__c
              )
            );
          }
          if (oldValues.get(key).Repeat_Logo__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Repeat Logo',
                null,
                oldValues.get(key).Repeat_Logo__c
              )
            );
          }
          if (oldValues.get(key).Supplier_Notes__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Supplier Notes',
                null,
                oldValues.get(key).Supplier_Notes__c
              )
            );
          }
          if (oldValues.get(key).Document_ID__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                workOrder.Work_Order__c,
                workOrder.Name,
                'Artwork Image',
                null,
                oldValues.get(key).Document_ID__c
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
        'Exception in artwork updateSOHistoryAfterDelete---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
}
