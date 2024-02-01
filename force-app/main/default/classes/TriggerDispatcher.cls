/*
 * Description: This is an interface for trigger framework dispatcher
 * Author: Imran
 * Created Date: 24th July 2023
 * Version:1.0.0 - Imran - 24th July 2023 - Created the interface
 */
public class TriggerDispatcher {
  //Use this variable to disable all triggers from transaction
  public static Boolean AllTriggerDisabled = false;
  /*
@Author : Imran
@CreatedDate : 24th July 2023
@Description : It will invoke the appropriate methods on the handler depending on the trigger context.
@Parameters : ITriggerHandler handler
*/
  public static void run(ITriggerHandler handler) {
    //Check if the all triggers are disabled from the transaction
    if (AllTriggerDisabled) {
      return;
    }
    //Check if the trigger is disabled
    if (handler.IsDisabled()) {
      return;
    }

    SObjectType triggersObjectType = Trigger.isDelete
      ? Trigger.old.getSObjectType()
      : Trigger.new.getSObjectType();
    ByPassTrigger__c bypassTrigger = ByPassTrigger__c.getInstance(
      UserInfo.getProfileId()
    );

    if (bypassTrigger != null) {
      if (bypassTrigger.Disable_Triggers__c) {
        return;
      }
    }

    //Check trigger context from trigger operation type
    switch on Trigger.operationType {
      when BEFORE_INSERT {
        //Invoke before insert trigger handler
        handler.beforeInsert(Trigger.new);
      }
      when AFTER_INSERT {
        //Invoke after insert trigger handler
        handler.afterInsert(Trigger.new, Trigger.newMap);
      }
      when BEFORE_UPDATE {
        //Invoke before update trigger handler
        handler.beforeUpdate(
          Trigger.new,
          Trigger.newMap,
          Trigger.old,
          Trigger.oldMap
        );
      }
      when AFTER_UPDATE {
        //Invoke after update trigger handler
        handler.afterUpdate(
          Trigger.new,
          Trigger.newMap,
          Trigger.old,
          Trigger.oldMap
        );
      }
      when BEFORE_DELETE {
        //Invoke before delete trigger handler
        handler.beforeDelete(Trigger.old, Trigger.oldMap);
      }
      when AFTER_DELETE {
        //Invoke after delete trigger handler
        handler.afterDelete(Trigger.old, Trigger.oldMap);
      }
      when AFTER_UNDELETE {
        //Invoke after undelete trigger handler
        handler.afterUnDelete(Trigger.new, Trigger.newMap);
      }
    }
  }
}
