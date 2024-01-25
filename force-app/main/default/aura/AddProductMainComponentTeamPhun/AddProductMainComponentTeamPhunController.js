({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    console.log(recordId);
    var defaultUrl = $A.get("$Label.c.default_url");
    var opportunityId = component.get("v.opportunityId");
    var action = component.get("c.getOpportunityName");
    action.setParams({
      oppId: opportunityId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var productList = response.getReturnValue();
        component.find("backButton").set("v.label", productList);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },

  openActionWindow: function (component, event, helper) {
    var defaultUrl = $A.get("$Label.c.default_url");
    var opportunityId = component.get("v.opportunityId");
    window.open(defaultUrl + opportunityId, "_self");
  }
});
