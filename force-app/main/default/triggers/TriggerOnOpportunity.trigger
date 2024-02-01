trigger TriggerOnOpportunity on Opportunity(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  if (System.Label.Triggers == 'True') {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler(
      Trigger.new,
      Trigger.oldMap
    );

    if (Trigger.isBefore) {
      if (Trigger.isUpdate) {
        handler.beforeUpdate();
      } else if (Trigger.isInsert) {
        handler.beforeInsert();
      } else if (Trigger.isDelete) {
        handler.beforeDelete();
      }
    } else if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        handler.afterUpdate();
      } else if (Trigger.isInsert) {
        handler.afterInsert();
      }
    }
  }

}
