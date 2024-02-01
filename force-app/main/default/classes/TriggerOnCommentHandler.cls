public class TriggerOnCommentHandler {
  List<Comment__c> newComments;
  Map<Id, Comment__c> oldComments;
  public TriggerOnCommentHandler(
    List<Comment__c> newValues,
    Map<Id, Comment__c> oldValues
  ) {
    this.newComments = newValues;
    this.oldComments = oldValues;
  }
  public void afterInsert() {
    TriggerOnCommentService.checkAndUpdateStatusOfOutdatedCheckbox(
      newComments,
      oldComments
    );
  }
}
