global class WorkOrderEmailScheduler implements schedulable {
  global void execute(SchedulableContext stx) {
    sendEmailWoDueDate();
  }

  public static void sendEmailWoDueDate() {
    List<Order> orderList = [
      SELECT
        Id,
        Order_Due_Date__c,
        OwnerId,
        Owner.Email,
        Business_Day__c,
        WONameLink__c,
        WOAccountLink__c
      FROM Order
    ];
    EmailTemplate template = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE name = '5 Days until Work Order Due Date'
    ];
    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

    for (Order ord : orderList) {
      if (ord.Order_Due_Date__c > date.today() && ord.Business_Day__c == 5) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String htmlBody = template.HtmlValue;
        htmlBody = htmlBody.replace(
          '{!Order.WONameLink__c}',
          ord.WONameLink__c
        );
        htmlBody = htmlBody.replace(
          '{!Order.WOAccountLink__c}',
          ord.WOAccountLink__c
        );
        List<String> toAddress = new List<String>{ ord.Owner.Email };
        string[] ccAddress = new List<string>{ 'info@teamphun.com' };
        email.setTemplateId(template.id);
        email.setToAddresses(toAddress);
        email.setCCAddresses(ccAddress);
        email.setTargetObjectId(ord.OwnerId);
        email.setSubject(template.Subject);
        email.setHtmlBody(htmlBody);
        email.saveAsActivity = false;
        emailList.add(email);
      }
    }
    Messaging.sendEmail(emailList);
  }
}
