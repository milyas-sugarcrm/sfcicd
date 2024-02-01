global class InboundArtApprovalFeedback implements Messaging.InboundEmailHandler {
  global Messaging.InboundEmailResult handleInboundEmail(
    Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope
  ) {
    String body = email.plainTextBody;

    if (
      body != null &&
      email.subject != null &&
      email.subject.contains('Your Order is Waiting for Your Approval')
    ) {
      String workOrderId = (body.substringAfter('OrderActions?Id=') != null
        ? body.substringAfter('OrderActions?Id=').left(15)
        : null);
      if (workOrderId != null) {
        Task emailResponse = new Task();
        List<Order> workOrders = [
          SELECT Id, Status, Account.Name
          FROM Order
          WHERE
            Id = :workOrderId
            AND Status = '03_-_Proof_Sent_-_Waiting_for_Approval'
        ];
        if (workOrders.size() > 0) {
          workOrders[0].Status = '02_-_Send_Mock_Up_to_Client_for_Approval';

          //Store Email Response
          emailResponse.Subject = 'Email Reply - ' + email.subject;
          emailResponse.status = 'Completed';
          emailResponse.priority = 'Routine';
          emailResponse.WhatId = workOrders[0].Id;
          emailResponse.Description = body;
          emailResponse.ActivityDate = System.Today();
          emailResponse.Type = 'Drop In';
          emailResponse.TaskSubType = 'Email';

          //Process updates
          try {
            update workOrders;
            insert emailResponse;

            // Save attachments, if any
            List<Attachment> textAttachments = new List<Attachment>();
            List<Attachment> binaryAttachments = new List<Attachment>();
            if (email.textAttachments != null) {
              for (
                Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments
              ) {
                Attachment attachment = new Attachment();
                attachment.Name = tAttachment.fileName;
                attachment.Body = Blob.valueOf(tAttachment.body);
                attachment.ParentId = emailResponse.Id;
                textAttachments.add(attachment);
              }
            }
            if (email.binaryAttachments != null) {
              for (
                Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments
              ) {
                Attachment attachment = new Attachment();
                attachment.Name = bAttachment.fileName;
                attachment.Body = bAttachment.body;
                attachment.ParentId = emailResponse.Id;
                binaryAttachments.add(attachment);
              }
            }

            insert textAttachments;
            insert binaryAttachments;
          } catch (Exception e) {
            String subject =
              'Inbound Art Approval Feedback Exception : ' + e.getMessage();
            String emailBody = e.getStackTraceString();

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new List<String>{ UserInfo.getUserEmail() };
            mail.setToAddresses(toAddresses);
            mail.setSubject(subject);
            mail.setPlainTextBody(emailBody);
            mail.setUseSignature(false);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
          }
        }
      }
    }

    return null;
  }
}
