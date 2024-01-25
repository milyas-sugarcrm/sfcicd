public class CampaignTriggerService {
  // populates reletive campaign Ids on Parent Oppotunities
  public static void PopulateIdOnOpp(List<PFA_Campaign__c> newCamp) {
    try {
      if (!newCamp.isEmpty()) {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        Set<Id> opportunityIds = new Set<Id>();
        for (PFA_Campaign__c campaign : newCamp) {
          if (campaign.PFA_Opportunity__c != null) {
            opportunityIds.add(campaign.PFA_Opportunity__c);
          }
        }
        if (!opportunityIds.isEmpty()) {
          Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
            [SELECT Id FROM Opportunity WHERE Id IN :opportunityIds]
          );
          for (PFA_Campaign__c campaign : newCamp) {
            Opportunity opp = opportunityMap.get(campaign.PFA_Opportunity__c);
            if (opp != null) {
              opp.PFA_Campaign__c = campaign.Id;
              opportunitiesToUpdate.add(opp);
            }
          }
          if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
          }
        }
      }
    } catch (Exception e) {
      System.debug('An exception occurred: ' + e.getMessage());
    }
  }

  // create Line Items(PFA Products) for PFA Campaign that were created in Opportunity
  public static void populateOppProducts(List<PFA_Campaign__c> newCampList) {
    try {
      if (!newCampList.isEmpty()) {
        Set<Id> oppIds = new Set<Id>();
        for (PFA_Campaign__c campaign : newCampList) {
          if (campaign.PFA_Opportunity__c != null) {
            oppIds.add(campaign.PFA_Opportunity__c);
          }
        }
        if (!oppIds.isEmpty()) {
          Map<Id, List<PFA_Product_Line_Item__c>> oppLineItemsMap = new Map<Id, List<PFA_Product_Line_Item__c>>();
          List<PFA_Product_Line_Item__c> allOppLineItems = [
            SELECT Id, Product_Id__c, Opportunity_Id__c, PFA_Campaign_Id__c
            FROM PFA_Product_Line_Item__c
            WHERE Opportunity_Id__c IN :oppIds
          ];
          for (PFA_Product_Line_Item__c lineItem : allOppLineItems) {
            if (!oppLineItemsMap.containsKey(lineItem.Opportunity_Id__c)) {
              oppLineItemsMap.put(
                lineItem.Opportunity_Id__c,
                new List<PFA_Product_Line_Item__c>()
              );
            }
            oppLineItemsMap.get(lineItem.Opportunity_Id__c).add(lineItem);
          }
          List<PFA_Product_Line_Item__c> campaignItemList = new List<PFA_Product_Line_Item__c>();
          for (PFA_Campaign__c campaign : newCampList) {
            addUpdatedLineItemsInList(
              campaign,
              oppLineItemsMap,
              campaignItemList
            );
          }
          insert campaignItemList;
        }
      }
    } catch (Exception e) {
      System.debug('An exception occurred: ' + e.getMessage());
    }
  }

  // function to add relative line itmes in main lineItemList to insert after
  private static void addUpdatedLineItemsInList(
    PFA_Campaign__c campaign,
    Map<Id, List<PFA_Product_Line_Item__c>> oppLineItemsMap,
    List<PFA_Product_Line_Item__c> campaignItemList
  ) {
    List<PFA_Product_Line_Item__c> oppLineitems = oppLineItemsMap.get(
      campaign.PFA_Opportunity__c
    );
    if (!oppLineitems.isEmpty()) {
      for (PFA_Product_Line_Item__c oppLineItem : oppLineitems) {
        PFA_Product_Line_Item__c itemToInsert = new PFA_Product_Line_Item__c();
        itemToInsert.Product_Id__c = oppLineItem.Product_Id__c;
        itemToInsert.PFA_Campaign_Id__c = campaign.Id;
        campaignItemList.add(itemToInsert);
      }
    }
  }
}
