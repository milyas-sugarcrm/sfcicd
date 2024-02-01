public class TriggerOnEmailMessageHandler {
  List<EmailMessage> triggerNew;

  public TriggerOnEmailMessageHandler(List<EmailMessage> triggerNew) {
    this.triggerNew = triggerNew;
  }

  public void afterInsert() {
    Boolean isValidateSend = TriggerOnEmailMessageService.validateEmailSendCriteria(
      triggerNew
    );
    TriggerOnEmailMessageService.updateWorkOrder(triggerNew, isValidateSend);
    TriggerOnEmailMessageService.checkPresentationAttachment(triggerNew);
  }
}
