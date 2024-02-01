public class UpdateCreditsController {
  public Id recId;
  public Id estimateId;
  public String status;
  public Boolean ValueReturned { get; set; }
  public UpdateCreditsController(ApexPages.StandardController std) {
    recId = ApexPages.currentPage().getParameters().get('Id');
    estimateId = ApexPages.currentPage().getParameters().get('Estimate');
    status = ApexPages.currentPage().getParameters().get('status');
  }
  public void addCredits() {
    try {
      User userInfo = [
        SELECT id, Name, Email, Design_Bank__c
        FROM User
        WHERE Id = :recId
      ];
      Estimate__c estimate = [
        SELECT id, Opportunity__c, OwnerId, Update_Credit_Request_Status__c
        FROM Estimate__c
        WHERE id = :estimateId
      ];
      Opportunity opp = [
        SELECT id, Name
        FROM Opportunity
        WHERE id = :estimate.Opportunity__c
      ];
      List<Order> orders = [
        SELECT Id
        FROM Order
        WHERE OpportunityId = :estimate.Opportunity__c
      ];
      Set<Id> orderIds = new Set<Id>();
      for (Order order : orders) {
        orderIds.add(order.id);
      }
      List<Design_Project__c> designProjects = [
        SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
        FROM Design_Project__c
        WHERE Estimate__c = :estimateId
      ];
      List<Design_Project__c> orderDesignProjects = new List<Design_Project__c>();
      if (orders != null && orders.size() > 0) {
        orderDesignProjects = [
          SELECT Id, Product__c, Bank_Credits__c, Estimate__c, Credits__c
          FROM Design_Project__c
          WHERE Work_Order__c = :orderIds
        ];
      }
      Integer credits = Integer.valueOf(
        apexpages.currentPage().getParameters().get('updatedCredits')
      );
      if (credits > 0) {
        if (userInfo.Design_Bank__c != null)
          userInfo.Design_Bank__c = userInfo.Design_Bank__c + credits;
        else
          userInfo.Design_Bank__c = credits;
        estimate.Update_Credit_Request_Status__c = 'Approved';
        if (orders != null && orders.size() > 0) {
          Decimal usedCredits = 0;
          if (orderDesignProjects != null && orderDesignProjects.size() > 0) {
            for (Design_Project__c designProj : orderDesignProjects) {
              usedCredits = usedCredits + designProj.Credits__c;
            }
          }
          userInfo.Design_Bank__c = userInfo.Design_Bank__c - usedCredits;
          orders.get(0).Valid_Credits__c = true;
        }
        if (sendEmail(null, userInfo.Email, 'Approved', userInfo.Name, opp)) {
          update estimate;
          update userInfo;
          update orders;
          update designProjects; // update DPs to update the status from invalid to valid credits
          ValueReturned = true;
        } else
          ValueReturned = false;
      } else
        ValueReturned = false;
    } catch (Exception Ex) {
      System.debug(
        'Exception in adding credits---->' +
          Ex.getMessage() +
          '-->' +
          Ex.getStackTraceString()
      );
      ValueReturned = false;
    }
  }

  public String getPreviousRequestStatus() {
    Estimate__c estimate = [
      SELECT id, OwnerId, Update_Credit_Request_Status__c
      FROM Estimate__c
      WHERE id = :estimateId
    ];
    if (estimate != null && estimate.Update_Credit_Request_Status__c != null) {
      if (estimate.Update_Credit_Request_Status__c == 'Approved')
        return 'Approved';
      else if (estimate.Update_Credit_Request_Status__c == 'Rejected')
        return 'Rejected';
      else if (
        status == 'false' &&
        estimate.Update_Credit_Request_Status__c == 'Pending'
      ) {
        return 'toBeRejected';
      } else if (
        status == 'true' &&
        estimate.Update_Credit_Request_Status__c == 'Pending'
      ) {
        return 'toBeApproved';
      }
    }
    return null;
  }

  public void rejectRequest() {
    try {
      Estimate__c estimate = [
        SELECT id, OwnerId, Opportunity__c, Update_Credit_Request_Status__c
        FROM Estimate__c
        WHERE id = :estimateId
      ];
      Opportunity opp = [
        SELECT id, Name
        FROM Opportunity
        WHERE id = :estimate.Opportunity__c
      ];
      User userInfo = [
        SELECT id, Name, Email, Design_Bank__c
        FROM User
        WHERE Id = :recId
      ];
      estimate.Update_Credit_Request_Status__c = 'Rejected';
      if (sendEmail(null, userInfo.Email, 'Rejected', userInfo.Name, opp)) {
        update estimate;
        ValueReturned = true;
      } else {
        ValueReturned = false;
      }
    } catch (Exception Ex) {
      ValueReturned = false;
    }
  }
  public Boolean sendEmail(
    Decimal credits,
    String emailId,
    String status,
    String Name,
    Opportunity opp
  ) {
    try {
      Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
      message.setSubject('Request for Updating Credits is ' + status);
      String msg = 'Dear ' + Name + ', <br/>';
      if (status == 'Approved')
        msg +=
          'Your request for updating credits in bank against <a href="' +
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/lightning/r/Opportunity/' +
          opp.Id +
          '/view">' +
          opp.Name +
          '</a> opportunity has been approved.';
      else
        msg +=
          'Your request for updating credits in bank against <a href="' +
          URL.getSalesforceBaseUrl().toExternalForm() +
          '/lightning/r/Opportunity/' +
          opp.Id +
          '/view">' +
          opp.Name +
          '</a> opportunity has been rejected. Kindly adjust your credits at estimate stage to convert to sales order.';
      message.setHTMLBody(msg);
      message.toAddresses = new List<String>{ emailId };
      Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
        message
      };
      Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
      if (results[0].success) {
        System.debug('The email sent successfully.');
        return true;
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
        return false;
      }
    } catch (Exception Ex) {
      System.debug(
        'Exception in sending email---> ' +
          Ex.getMessage() +
          '====' +
          Ex.getStackTraceString()
      );
      return false;
    }
  }

  public User getUserDetails() {
    User userInfo = [
      SELECT id, FirstName, Email, Design_Bank__c
      FROM User
      WHERE Id = :recId
    ];
    return userInfo;
  }
  public Opportunity getOpportunityDetails() {
    Estimate__c estimate = [
      SELECT id, Opportunity__c
      FROM Estimate__c
      WHERE id = :estimateId
    ];
    Opportunity opp = [
      SELECT id, Name
      FROM Opportunity
      WHERE id = :estimate.Opportunity__c
    ];
    return opp;
  }

  public String getOppLink() {
    Estimate__c estimate = [
      SELECT id, Opportunity__c
      FROM Estimate__c
      WHERE id = :estimateId
    ];
    Opportunity opp = [
      SELECT id, Name
      FROM Opportunity
      WHERE id = :estimate.Opportunity__c
    ];
    return URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/r/Opportunity/' +
      opp.Id +
      '/view';
  }
}
