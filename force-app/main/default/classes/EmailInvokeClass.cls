public class EmailInvokeClass {
  public static void sendEmail(
    User orderAccountOwner,
    List<User> jaredJesse,
    Order wo,
    String emailTemplateName
  ) {
    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
    message.setTargetObjectId(orderAccountOwner.id);
    message.setUseSignature(false);
    message.setBccSender(false);
    message.setSaveAsActivity(false);
    EmailTemplate emailTemplate = [
      SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
      FROM EmailTemplate
      WHERE name = :emailTemplateName
    ];
    message.setTemplateID(emailTemplate.Id);
    message.setSubject(
      'Work Order ' + wo.OrderNumber + ' - ' + emailTemplate.Subject
    );
    message.setHtmlBody(emailTemplate.HtmlValue);

    List<String> emailIds = new List<String>();
    if (jaredJesse != null && jaredJesse.size() > 0) {
      emailIds.add(jaredJesse[0].email);
    }
    message.toAddresses = emailIds;
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{
      message
    };
    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

    if (results[0].success) {
      System.debug('The email was sent successfully.');
      //Upon stage change all will turn false again so no need to apply specific check...
      wo.MockupClientApproval24HourEmailSent__c = true;
      wo.OrderBlankApprovedDeposit24HourEmailSent__c = true;
      wo.ProofSentWaitingApproval24HourEmailSent__c = true;
      update wo;
    } else {
      System.debug('The email failed to send: ' + results[0].errors[0].message);
    }
  }
}
