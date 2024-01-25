public class QuoteRequestTriggerHandler {
  public static String generateQuoteRequestLink(Id quoteRequestId) {
    String quoteRequestLink =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      quoteRequestId;
    return quoteRequestLink;
  }

  public static void handleAfterInsert(List<Quote_Request__c> newRecords) {
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

    // Collect Opportunity IDs from new records
    Set<Id> opportunityIds = new Set<Id>();
    for (Quote_Request__c quoteRequest : newRecords) {
      opportunityIds.add(quoteRequest.Opportunity_Name__c);
    }

    // Query for related Opportunity data
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(
      [
        SELECT Id, Name, Contact__c, AccountId
        FROM Opportunity
        WHERE Id IN :opportunityIds
      ]
    );

    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'Quote Request Template'
    ];

    for (Quote_Request__c quoteRequest : newRecords) {
      // Check if the Opportunity exists in the map
      if (opportunityMap.containsKey(quoteRequest.Opportunity_Name__c)) {
        Opportunity opportunity = opportunityMap.get(
          quoteRequest.Opportunity_Name__c
        );
        try {
          Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
          String htmlBody = et.HtmlValue;
          String opportunityLink =
            '<a href="' +
            generateQuoteRequestLink(opportunity.id) +
            '">' +
            opportunity.Name +
            '</a>';

          htmlBody = htmlBody.replace(
            '{!Quote_Request__c.Name}',
            quoteRequest.Name
          );
          htmlBody = htmlBody.replace(
            '{!Quote_Request__c.Opportunity_Name__c.Name}',
            opportunityLink
          );
          htmlBody = htmlBody.replace(
            '{!Quote_Request__c.Quote_Request_Link__c}',
            generateQuoteRequestLink(quoteRequest.Id)
          );

          email.setHtmlBody(htmlBody);
          email.setSubject(et.Subject);
          String EmailAddress = System.Label.Email_id_for_the_Quote_Request_Recipient;
          String[] toAddress = new List<String>{ EmailAddress };

          email.setTemplateId(et.Id);
          email.setTargetObjectId(opportunity.Contact__c);
          email.setSaveAsActivity(false);
          email.setToAddresses(toAddress);

          Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
        } catch (Exception e) {
          System.debug(
            'Exception upon sending email: ' +
              e.getMessage() +
              '\n' +
              e.getStackTraceString()
          );
        }
      }
    }
  }
}
