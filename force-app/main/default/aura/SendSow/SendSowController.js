({
  /*
   * On init;
   * 1. get the Opportunity details
   * 2. set the data in variables
   * 3. call the send sow helper with all arguments
   *
   * getOpportunityDetails: Apex function defined in
   * SowPandaDocHandler controller
   */
  doInit: function (component, event, helper) {
    var action = component.get("c.getOpportunityDetails");
    action.setParams({ oppId: component.get("v.recordId") });

    action.setCallback(this, function (response) {
      var state = response.getState();
      var opportunity = response.getReturnValue();
      if (
        state === "SUCCESS" &&
        opportunity.Id !== "" &&
        opportunity.Id !== null
      ) {
        component.set("v.stageName", opportunity.StageName);
        component.set("v.pandaDocId", opportunity.Panda_Doc_Id__c);
        component.set("v.awsFileName", opportunity.Aws_File_Name__c);
        helper.processSendSow(component);
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          console.error("Error fetching Opportunity details:", errors);
        }
        helper.showToast("error", "Error fetching Opportunity details.");
      }
    });
    $A.enqueueAction(action);
  }
});
