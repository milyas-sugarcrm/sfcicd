public class ContentVersionTriggerHandler {
  List<ContentVersion> triggerNew;

  public ContentVersionTriggerHandler(List<ContentVersion> triggerNew) {
    this.triggerNew = triggerNew;
  }

  public void afterInsert() {
    ContentVersionTriggerService.createPublicLinks(triggerNew);
  }
}
