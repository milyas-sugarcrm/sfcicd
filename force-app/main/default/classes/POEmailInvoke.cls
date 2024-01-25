public class POEmailInvoke {
  public static void sendEmail(
    String toEmail,
    String[] ccEmail,
    String body,
    String subject
  ) {
    try {
      List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();

      List<String> email = new List<String>();
      email.add(toEmail);
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

      mail.setToAddresses(email);
      if (ccEmail.size() > 0) {
        mail.setCcAddresses(ccEmail);
      }

      mail.setSubject(subject);
      mail.setHtmlBody(body);

      mails.add(mail);

      Messaging.sendEmail(mails);
    } catch (Exception ex) {
      System.debug(ex.getMessage() + '---->>>>>>' + ex.getStackTraceString());
    }
  }
}
