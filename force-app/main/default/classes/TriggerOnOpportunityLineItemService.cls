public class TriggerOnOpportunityLineItemService {
  public static Id changedByUser = [
    SELECT id
    FROM User
    WHERE id = :UserInfo.getUserId()
  ]
  .id;

  public static void checkAndUpdateStatusOfOutdatedCheckboxAfterInsert(
    List<OpportunityLineItem__c> newValues
  ) {
    Set<Id> opportunitiesToUpdate = new Set<Id>();
    for (OpportunityLineItem__c oppLineItem : newValues) {
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
      for (OpportunityLineItem__c oppLineItem : newValues) {
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
  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<OpportunityLineItem__c> newValues,
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    List<OpportunityLineItem__c> opportunityLineItem = [
      SELECT
        Id,
        Estimate__r.Opportunity__c,
        Work_Order__r.OpportunityId,
        Opportunity__c
      FROM OpportunityLineItem__c
      WHERE Id IN :newValues
    ];
    Map<Id, OpportunityLineItem__c> opportunityLineItemMap = new Map<Id, OpportunityLineItem__c>(
      [
        SELECT
          Id,
          Estimate__r.Opportunity__c,
          Work_Order__r.OpportunityId,
          Opportunity__c
        FROM OpportunityLineItem__c
        WHERE Id IN :newValues
      ]
    );

    Set<Id> opportunitiesToUpdate = new Set<Id>();
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
    Set<Id> updatedOpportunity = new Set<Id>();
    if (opportunitiesToUpdate != null && opportunitiesToUpdate.size() > 0) {
      Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE Id = :opportunitiesToUpdate
        ]
      );
      for (OpportunityLineItem__c oppLineItem : newValues) {
        //SELECT Id, Imprint_Type__c, Proof_Required__c, logo_Name__c, Logo_Size__c, Logo_Color__c, Repeat_Logo__c, Supplier_Notes__c, Document_ID__c, Title__c
        OpportunityLineItem__c relatedOldValue = oldValues.get(oppLineItem.Id);

        if (
          relatedOldValue.Name != oppLineItem.Name ||
          relatedOldValue.Description__c != oppLineItem.Description__c ||
          relatedOldValue.Private_Notes__c != oppLineItem.Private_Notes__c
        ) {
          if (oppLineItem.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(oppLineItem.Opportunity__c);
            updatedOpportunity.add(opp.Id);
          } else if (oppLineItem.Estimate__r.Opportunity__c != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Estimate__r.Opportunity__c
            );
            updatedOpportunity.add(opp.Id);
          } else if (oppLineItem.Work_Order__r.OpportunityId != null) {
            Opportunity opp = opportunitiesMap.get(
              oppLineItem.Work_Order__r.OpportunityId
            );
            updatedOpportunity.add(opp.Id);
          }
        }
      }
      List<Opportunity> oppToUpdate = [
        SELECT Id, isOutdated__c
        FROM Opportunity
        WHERE Id = :updatedOpportunity
      ];
      for (Opportunity opp : oppToUpdate) {
        opp.isOutdated__c = true;
      }
      update oppToUpdate;
    }
  }
  /*public static void updateDesignProjects(List<OpportunityLineItem__c> newValues)
{
List<OpportunityLineItem__c> opportunityLineItem = [SELECT Id, Name, Description__c,Estimate__c, Product__c,Product__r.Id,
Product__r.Name,Product__r.Design_Project__c,Product__r.Sales_Price_Rate__c, SKU__c, Supplier__c ,CreatedDate,Tax__c 
FROM OpportunityLineItem__c 
where Id IN: newValues 
AND Estimate__c!=null
AND Product__r.Design_Project__c=true];
List <id> oppLineItemIds=new List<id>();
for(OpportunityLineItem__c oppLineItem :opportunityLineItem )
{
oppLineItemIds.add(oppLineItem.Id);
}
List<PricingLineItem__c> priceDetails = [SELECT Id, Quantity__c, Net_Cost__c, Retail_Price__c,
Total__c,  Estimate__c, Estimated_Quantity__c, 
Display__c, Default__c, OpportunityLineItem__c
FROM PricingLineItem__c
where OpportunityLineItem__c IN: oppLineItemIds 
AND Display__c = true 
AND Default__c = false ];
List<ExtraChargesEstimate__c> extraCharges = [SELECT Id, Title__c, Quantity__c,Subtotal_Toggle__c,
Charge_Type__c, Margin__c, Retail_Price__c, Total__c, 
Display__c, Duty_Percentage__c, 
Is_Associated_With_Artwork__c, 
OpportunityLineItem_ArtWork__r.Title__c,
OpportunityLineItem_ArtWork__r.Id,
OpportunityLineItem__c, Default__c, Net_Cost__c 
FROM ExtraChargesEstimate__c
WHERE  OpportunityLineItem__c IN: oppLineItemIds 
ORDER BY CreatedDate ASC];
List<Design_Project__c> designProjects = [SELECT Id, Product__c, Estimate__c,Credits__c FROM Design_Project__c 
WHERE Product__c IN: oppLineItemIds];
Decimal totalCredit = [Select Design_Bank__c From User Where Id = :UserInfo.getUserId()][0].Design_Bank__c;
User userInfo =  [Select id,Design_Bank__c From User Where Id = :UserInfo.getUserId()];
for(Design_Project__c designProj: designProjects)
{
designProj.Credits__c = 0;
}
for(OpportunityLineItem__c oppLineItem :opportunityLineItem )
{
for(PricingLineItem__c pricing: priceDetails)
{
if(pricing.OpportunityLineItem__c == oppLineItem.id)
{
Decimal totalPrice = 0;
if(pricing.Estimated_Quantity__c != null || pricing.Retail_Price__c != null)
{
totalPrice = pricing.Estimated_Quantity__c * pricing.Retail_Price__c;
}
if((totalPrice - oppLineItem.Product__r.Sales_Price_Rate__c) <= userInfo.Design_Bank__c)
{
for(Design_Project__c designProj: designProjects)
{
if(designProj.Product__c!=null && designProj.Product__c == oppLineItem.id)
{
if(designProj.Credits__c !=null && designProj.Credits__c !=0)
{
designProj.Credits__c = designProj.Credits__c + (totalPrice - oppLineItem.Product__r.Sales_Price_Rate__c);

userInfo.Design_Bank__c = userInfo.Design_Bank__c - (totalPrice - oppLineItem.Product__r.Sales_Price_Rate__c);
}
else
{
designProj.Credits__c = totalPrice - oppLineItem.Product__r.Sales_Price_Rate__c;
userInfo.Design_Bank__c = userInfo.Design_Bank__c - (totalPrice - oppLineItem.Product__r.Sales_Price_Rate__c);
}

}

}
}
}
}
}
update designProjects;
// update userInfo;
}*/
  public static void deleteRecordsRelatedToOppLineItems(
    List<OpportunityLineItem__c> newOppLineItem,
    Map<Id, OpportunityLineItem__c> oldOppLineItem
  ) {
    Set<Id> oppLineItemIds = oldOppLineItem.keySet();
    List<Comment__c> comments = [
      SELECT Id
      FROM Comment__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (comments.size() > 0) {
      delete comments;
    }
    List<ColorLineItem__c> colorLineItems = [
      SELECT Id
      FROM ColorLineItem__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (colorLineItems.size() > 0) {
      delete colorLineItems;
    }
    List<SizeLineItem__c> sizeLineItems = [
      SELECT Id
      FROM SizeLineItem__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (sizeLineItems.size() > 0) {
      delete sizeLineItems;
    }
    List<PricingLineItem__c> pricingLineItems = [
      SELECT Id
      FROM PricingLineItem__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (pricingLineItems.size() > 0) {
      delete pricingLineItems;
    }
    List<Line_Item_Pricing_RunCharge__c> lineItemPricingRunCharges = [
      SELECT Id
      FROM Line_Item_Pricing_RunCharge__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (lineItemPricingRunCharges.size() > 0) {
      delete lineItemPricingRunCharges;
    }
    List<OpportunityLineItem_Add_Fixed_Charge__c> oppLineItemAddFixedCharges = [
      SELECT Id
      FROM OpportunityLineItem_Add_Fixed_Charge__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (oppLineItemAddFixedCharges.size() > 0) {
      delete oppLineItemAddFixedCharges;
    }
    List<WarningsOpportunityLineItem__c> warningsOpportunityLineItems = [
      SELECT Id
      FROM WarningsOpportunityLineItem__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (warningsOpportunityLineItems.size() > 0) {
      delete warningsOpportunityLineItems;
    }
    List<OpportunityLineItem_ArtWork__c> opportunityLineItemArtWorks = [
      SELECT Id
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (opportunityLineItemArtWorks.size() > 0) {
      delete opportunityLineItemArtWorks;
    }
    List<OpportunityLineItemAttachment__c> opportunityLineItemAttachments = [
      SELECT Id
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (opportunityLineItemAttachments.size() > 0) {
      delete opportunityLineItemAttachments;
    }
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT Id, OpportunityLineItem__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
    ];
    if (extraCharges.size() > 0) {
      delete extraCharges;
    }
    List<Design_Project__c> designProjectRecords = [
      SELECT Id, Product__c
      FROM Design_Project__c
      WHERE Product__c IN :oppLineItemIds
    ];
    if (designProjectRecords.size() > 0) {
      delete designProjectRecords;
    }
  }
  public static void createDesignProjects(
    List<OpportunityLineItem__c> newValues
  ) {
    List<OpportunityLineItem__c> opportunityLineItem = [
      SELECT
        Id,
        Name,
        Description__c,
        Estimate__c,
        Product__c,
        Product__r.Id,
        Product__r.Name,
        Product__r.Sales_Price_Rate__c,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      WHERE
        Id IN :newValues
        AND Estimate__c != NULL
        AND Product__r.Design_Project__c = TRUE
    ];
    List<Design_Project__c> designProjectsToBeInserted = new List<Design_Project__c>();
    System.debug('---createDesignProjects---' + opportunityLineItem);
    for (OpportunityLineItem__c oppLineItem : opportunityLineItem) {
      if (
        oppLineItem.Product__c != null &&
        oppLineItem.Product__r.Design_Project__c == true
      ) {
        Design_Project__c designProject = new Design_Project__c();
        designProject.Estimate__c = oppLineItem.Estimate__c;
        designProject.Product__c = oppLineItem.id;
        designProject.Name = 'Design Product ( ' + oppLineItem.Name + ' )';
        designProjectsToBeInserted.add(designProject);
      }
    }
    if (designProjectsToBeInserted.size() > 0)
      insert designProjectsToBeInserted;
  }
  public static void updateHistoryAfterUpdate(
    List<OpportunityLineItem__c> newOppLineItem,
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    try {
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (OpportunityLineItem__c lineItem : newOppLineItem) {
        if (lineItem.Estimate__c != null) {
          if (
            lineItem.Private_Notes__c !=
            oldValues.get(lineItem.id).Private_Notes__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Private Notes',
                lineItem.Private_Notes__c,
                oldValues.get(lineItem.id).Private_Notes__c
              )
            );
          }
          if (
            lineItem.Description__c != oldValues.get(lineItem.id).Description__c
          ) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Description',
                lineItem.Description__c,
                oldValues.get(lineItem.id).Description__c
              )
            );
          }
          if (lineItem.Name != oldValues.get(lineItem.id).Name) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Name',
                lineItem.Name,
                oldValues.get(lineItem.id).Name
              )
            );
          }
        }
      }
      if (estimateHistoryList.size() > 0)
        insert estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in oppLineItems updateHistoryafterupdate---->>>>' +
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
    List<OpportunityLineItem__c> newOppLineItem
  ) {
    try {
      List<Estimate_History__c> estimateHistoryList = new List<Estimate_History__c>();
      for (OpportunityLineItem__c lineItem : newOppLineItem) {
        if (lineItem.Estimate__c != null) {
          if (lineItem.Name != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Name',
                lineItem.Name,
                null
              )
            );
          }
          if (lineItem.Private_Notes__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Private Notes',
                lineItem.Private_Notes__c,
                null
              )
            );
          }
          if (lineItem.Description__c != null) {
            estimateHistoryList.add(
              createHistoryRecord(
                lineItem.Estimate__c,
                lineItem.id,
                'Description',
                lineItem.Description__c,
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
        'Exception in oppLineItems updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  public static void updateHistoryBeforeDelete(
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    try {
      Set<Id> oppLineItemIds = new Set<Id>();
      for (Id key : oldValues.keySet()) {
        oppLineItemIds.add(key);
      }
      List<Estimate_History__c> estimateHistoryList = [
        SELECT
          id,
          Name,
          CreatedDate,
          Estimate__c,
          Changed_field__c,
          New_Value__c,
          Previous_Value__c,
          Related_Object_Id__c
        FROM Estimate_History__c
        WHERE Related_Object_Id__c IN :oppLineItemIds
      ];
      if (estimateHistoryList.size() > 0)
        delete estimateHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in oppLineItems updateHistoryafterupdate---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }
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
    List<OpportunityLineItem__c> newValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      for (OpportunityLineItem__c oppLst : newValues) {
        if (oppLst != null) {
          if (oppLst.Description__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                oppLst.Work_Order__c,
                oppLst.Name,
                'Product Description',
                oppLst.Description__c,
                null
              )
            );
          }
        }
      }

      if (SOHistoryList.size() > 0)
        insert SOHistoryList;
    } catch (Exception ex) {
      System.debug(
        'Exception in Product updateSOHistoryafterInsert---->>>>' +
          ex.getStackTraceString() +
          ex.getMessage()
      );
    }
  }

  /**
   * This function is saving the SalesOrder history when SalesOrder is updated from WorkOrder
   */
  public static void updateSOHistoryafterupdate(
    List<OpportunityLineItem__c> newValues,
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      for (OpportunityLineItem__c oppLst : newValues) {
        if (oppLst != null) {
          if (
            oppLst.Description__c != oldValues.get(oppLst.id).Description__c
          ) {
            SOHistoryList.add(
              createSOHistoryRecord(
                oppLst.Work_Order__c,
                oppLst.Name,
                'Product Description',
                oppLst.Description__c,
                oldValues.get(oppLst.id).Description__c
              )
            );
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
    Map<Id, OpportunityLineItem__c> oldValues
  ) {
    try {
      List<Sales_Order_History__c> SOHistoryList = new List<Sales_Order_History__c>();

      for (Id key : oldValues.keySet()) {
        if (oldValues.get(key) != null) {
          if (oldValues.get(key).Description__c != null) {
            SOHistoryList.add(
              createSOHistoryRecord(
                oldValues.get(key).Work_Order__c,
                oldValues.get(key).Name,
                'Product Description',
                null,
                oldValues.get(key).Description__c
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
