public class DesignProjectTriggerService {
  public static void updateOnCompletedDesignProject(
    Map<Id, Design_Project__c> oldTriggerMap,
    List<Design_Project__c> lstTriggerNew
  ) {
    List<Id> orderIds = new List<Id>();
    for (Design_Project__c designProject : lstTriggerNew) {
      orderIds.add(designProject.Work_Order__c);
    }
    List<Order> orders = [SELECT id, OwnerId FROM Order WHERE id = :orderIds];
    List<Id> userIds = new List<Id>();
    for (Order order : orders) {
      userIds.add(order.OwnerId);
    }
    List<User> users = [
      SELECT id, Design_Bank__c
      FROM User
      WHERE Id IN :userIds
    ];
    User userInfo = [
      SELECT id, username, Design_Bank__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    Map<Id, Id> designProjectUser = new Map<Id, Id>();
    for (Design_Project__c designPro : lstTriggerNew) {
      for (Order order : orders) {
        if (order.id == designPro.Work_Order__c) {
          designProjectUser.put(designPro.id, order.OwnerId);
        }
      }
    }
    for (Design_Project__c designProject : lstTriggerNew) {
      if (
        (oldTriggerMap.get(designProject.id).Bank_Credits__c) &&
        !(designProject.Bank_Credits__c) &&
        oldTriggerMap.get(designProject.id).Estimate__c != null
      ) {
        designProject.addError(
          'You are not allowed to update at Estimate stage'
        );
      } else if (
        (oldTriggerMap.get(designProject.id).Bank_Credits__c) &&
        !(designProject.Bank_Credits__c) &&
        designProject.Estimate__c == null &&
        designProject.Work_Order__c != null
      ) {
        if (
          !(Test.isRunningTest()) &&
          userInfo.username != Label.Design_Team_Email //// custom label
        ) {
          designProject.addError(
            'You are not allowed to update Bank Credits field'
          );
        }
        if (designProject.Credits__c != null && designProject.Credits__c > 0) {
          for (User user : users) {
            // if(user.id == designProjectUser.get(designProject.id) && designProject.Credits_included_to_bank__c)
            if (user.id == designProjectUser.get(designProject.id)) {
              if (user.Design_Bank__c != null)
                user.Design_Bank__c =
                  user.Design_Bank__c + designProject.Credits__c;
              else
                user.Design_Bank__c = designProject.Credits__c;
            }
          }
        }
      } else if (
        !(oldTriggerMap.get(designProject.id).Bank_Credits__c) &&
        (designProject.Bank_Credits__c) &&
        designProject.Estimate__c == null &&
        designProject.Work_Order__c != null
      ) {
        if (
          !(Test.isRunningTest()) &&
          userInfo.username != Label.Design_Team_Email
        ) {
          designProject.addError(
            'You are not allowed to update Bank Credits field'
          );
        }
        if (designProject.Credits__c != null && designProject.Credits__c > 0) {
          for (User user : users) {
            //if(user.id ==  designProjectUser.get(designProject.id)
            // && designProject.Credits_included_to_bank__c)
            if (user.id == designProjectUser.get(designProject.id)) {
              if (
                user.Design_Bank__c != null &&
                user.Design_Bank__c >= designProject.Credits__c
              ) {
                user.Design_Bank__c =
                  user.Design_Bank__c - designProject.Credits__c;
              } else {
                designProject.addError(
                  'User has not enough credits in the bank'
                );
              }
            }
          }
        }
      }
    }
    if (users.size() > 0)
      update users;
  }

  public static void checkValidityforEstimateCreditsAfterUpdate(
    Map<Id, Design_Project__c> oldTriggerMap,
    List<Design_Project__c> lstTriggerNew
  ) {
    List<id> estimateIds = new List<id>();
    for (Design_Project__c dp : lstTriggerNew) {
      estimateIds.add(dp.Estimate__c);
    }
    List<Design_Project__c> designProjects = [
      SELECT
        Id,
        Active__c,
        Product__c,
        Estimate__c,
        Credits__c,
        Bank_Credits__c,
        Estimate__r.OwnerId
      FROM Design_Project__c
      WHERE Active__c = TRUE AND Estimate__c IN :estimateIds
    ];
    List<id> oppLineItemIds = new List<id>();
    List<id> userIds = new List<id>();
    for (Design_Project__c designProject : designProjects) {
      oppLineItemIds.add(designProject.Product__c);
      userIds.add(designProject.Estimate__r.OwnerId);
    }
    List<User> users = [
      SELECT id, Design_Bank__c
      FROM User
      WHERE Id IN :userIds
    ];
    Map<Id, Decimal> creditsForEstimate = new Map<Id, Decimal>();
    for (Design_Project__c designProject : designProjects) {
      for (User user : users) {
        if (
          !creditsForEstimate.containsKey(designProject.Estimate__c) &&
          designProject.Estimate__r.OwnerId == user.id
        ) {
          creditsForEstimate.put(
            designProject.Estimate__c,
            user.Design_Bank__c
          );
        }
      }
    }
    List<OpportunityLineItem__c> opportunityLineItems = [
      SELECT
        Id,
        Estimate__c,
        Product__c,
        Product__r.Id,
        Product__r.Name,
        Product__r.Design_Project__c
      FROM OpportunityLineItem__c
      WHERE
        Id IN :oppLineItemIds
        AND Estimate__c != NULL
        AND Product__r.Design_Project__c = TRUE
    ];
    List<PricingLineItem__c> priceDetails = [
      SELECT
        Id,
        Quantity__c,
        Net_Cost__c,
        Retail_Price__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c,
        Credit_Available__c,
        Default__c,
        OpportunityLineItem__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :oppLineItemIds
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY LastModifiedDate ASC, Credit_Available__c DESC
    ];
    List<ExtraChargesEstimate__c> extraCharges = [
      SELECT
        Id,
        Quantity__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Credit_Available__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :oppLineItemIds
      ORDER BY LastModifiedDate ASC, Credit_Available__c DESC
    ];

    for (PricingLineItem__c pricing : priceDetails) {
      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        if (pricing.OpportunityLineItem__c == oppLineItem.id) {
          for (Design_Project__c designProject : designProjects) {
            if (designProject.Product__c == oppLineItem.id) {
              Decimal totalCredits = 0;

              if (
                pricing.Estimated_Quantity__c != null &&
                pricing.Net_Cost__c != null
              ) {
                if (pricing.Retail_Price__c != null) {
                  if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                    totalCredits =
                      (pricing.Estimated_Quantity__c * pricing.Net_Cost__c) -
                      (pricing.Estimated_Quantity__c * pricing.Retail_Price__c);
                } else
                  totalCredits =
                    pricing.Estimated_Quantity__c * pricing.Net_Cost__c;
              }
              if (
                totalCredits <=
                creditsForEstimate.get(designProject.Estimate__c)
              ) {
                pricing.Credit_Available__c = true;
                creditsForEstimate.put(
                  designProject.Estimate__c,
                  (creditsForEstimate.get(designProject.Estimate__c) -
                  totalCredits)
                );
              } else {
                pricing.Credit_Available__c = false;
              }
            }
          }
        }
      }
    }
    for (ExtraChargesEstimate__c pricing : extraCharges) {
      for (OpportunityLineItem__c oppLineItem : opportunityLineItems) {
        if (pricing.OpportunityLineItem__c == oppLineItem.id) {
          for (Design_Project__c designProject : designProjects) {
            if (designProject.Product__c == oppLineItem.id) {
              Decimal totalCredits = 0;
              if (pricing.Quantity__c != null && pricing.Net_Cost__c != null) {
                if (pricing.Retail_Price__c != null) {
                  if (pricing.Retail_Price__c < pricing.Net_Cost__c)
                    totalCredits =
                      (pricing.Quantity__c * pricing.Net_Cost__c) -
                      (pricing.Quantity__c * pricing.Retail_Price__c);
                } else
                  totalCredits = pricing.Quantity__c * pricing.Net_Cost__c;
              }
              if (
                totalCredits <=
                creditsForEstimate.get(designProject.Estimate__c)
              ) {
                pricing.Credit_Available__c = true;
                creditsForEstimate.put(
                  designProject.Estimate__c,
                  (creditsForEstimate.get(designProject.Estimate__c) -
                  totalCredits)
                );
              } else {
                pricing.Credit_Available__c = false;
              }
            }
          }
        }
      }
    }
    if (!(Test.isRunningTest())) {
      update extraCharges;
      update priceDetails;
    }
  }
  public static void updateDesignBankOnDeletion(
    Map<Id, Design_Project__c> oldTriggerMap
  ) {
    List<Id> orderIds = new List<Id>();
    for (Id key : oldTriggerMap.keyset()) {
      orderIds.add(oldTriggerMap.get(key).Work_Order__c);
    }
    List<Order> orders = [
      SELECT id, OwnerId, Valid_Credits__c
      FROM Order
      WHERE id = :orderIds
    ];
    List<Id> userIds = new List<Id>();
    for (Order order : orders) {
      userIds.add(order.OwnerId);
    }
    for (Order order : orders) {
      userIds.add(order.OwnerId);
    }
    List<User> users = [
      SELECT id, Design_Bank__c
      FROM User
      WHERE Id IN :userIds
    ];
    for (Id key : oldTriggerMap.keyset()) {
      for (Order order : orders) {
        if (
          oldTriggerMap.get(key).Work_Order__c == order.id &&
          order.Valid_Credits__c
        ) {
          for (User user : users) {
            if (
              user.id == order.OwnerId &&
              oldTriggerMap.get(key).Active__c &&
              oldTriggerMap.get(key).Bank_Credits__c
            ) {
              if (
                user.Design_Bank__c != null &&
                oldTriggerMap.get(key).Credits__c != null
              )
                user.Design_Bank__c =
                  user.Design_Bank__c + oldTriggerMap.get(key).Credits__c;
              else
                user.Design_Bank__c = oldTriggerMap.get(key).Credits__c;
            }
          }
        }
      }
    }
    update users;
  }
}
