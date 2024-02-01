({
  doInit: function (component, event, helper) {
    var action = component.get("c.getWorkOrderName");
    action.setParams({
      workOrderId: component.get("v.workOrderId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var workOrderName = response.getReturnValue();
        component.find("backButton").set("v.label", workOrderName);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  // to open Work Order detail view once back button is clicked
  backAction: function (component, event, helper) {
    var defaultUrl = $A.get("$Label.c.default_url");
    var salesOrderId = component.get("v.workOrderId");
    window.open(
      defaultUrl + "lightning/r/Order/" + salesOrderId + "/view",
      "_self"
    );
  }
});
