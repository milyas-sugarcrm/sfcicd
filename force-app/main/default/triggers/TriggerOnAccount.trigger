trigger TriggerOnAccount on Account(
  before update,
  before insert,
  after insert,
  after update,
  before delete,
  after delete
) {
  if (System.Label.Triggers == 'True') {
    if (Trigger.isBefore) {
      if (Trigger.isUpdate) {
        AccountTriggerHandler.updateShippingInfo(
          Trigger.new,
          Trigger.oldMap,
          Trigger.newMap
        ); //replacement of process builder "Account Processes" calling in this function
        AccountTriggerHandler.checkDuplicateAccount(Trigger.new);
        AccountTriggerHandler.restrictQBOInstance(Trigger.new, Trigger.oldMap);
        AccountTriggerHandler.handleRecordTypeChange(
          Trigger.new,
          Trigger.oldMap
        );
        AccountTriggerHandler.handleWebiste(Trigger.new);
      } else if (Trigger.isInsert) {
        AccountTriggerHandler.updateShippingInfo(
          Trigger.new,
          Trigger.oldMap,
          Trigger.newMap
        ); //replacement of process builder "Account Processes"
        AccountTriggerHandler.handleRecordType(Trigger.new);
        AccountTriggerHandler.handleWebiste(Trigger.new);
        AccountTriggerHandler.checkDuplicateAccount(Trigger.new);
      }
    } else if (Trigger.isAfter) {
      if (Trigger.isUpdate) {
        AccountHandlerForGoogleDrive.updateDriveFolderNameWrapper(
          Trigger.new,
          Trigger.oldMap
        );
        AccountTriggerHandler.updateWorkOrderOwnerCheckbox(
          Trigger.new,
          Trigger.oldMap
        );
        AccountTriggerHandler.checkAndUpdateStatusOfOutdatedCheckbox(
          Trigger.new,
          Trigger.oldMap
        );
        AccountTriggerHandler.SetArtApprovalEmailBilling(
          Trigger.new,
          Trigger.oldMap
        ); //replacement of process builder "Set Art Approval Email/Billing Contact - Account"
        Boolean dataChanged = AccountTriggerHandler.checkFieldsChangedForSync(
          Trigger.new,
          Trigger.oldMap
        );
        if (dataChanged) {
          AccountTriggerHandler.syncToQBO(
            Trigger.new,
            Trigger.oldMap,
            'from Update'
          );
        }
      } else if (Trigger.isInsert) {
        AccountTriggerHandler.syncToQBO(
          Trigger.new,
          Trigger.oldMap,
          'From Insert'
        );
        AccountHandlerForGoogleDrive.handleNewAccounts(Trigger.new);
      }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
      AccountHandlerForGoogleDrive.handleAccountDeletion(Trigger.old);
    }
  }

}
