({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var idValue = component.get("v.recordId");
    var action = component.get("c.generateResalePDF");
    action.setParams({
      accountID: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Resale Certificate PDF generated successfully"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else if (state === "ERROR") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Error in generating Resale Certificate PDF."
        });
        toastEvent.fire();
      }
      component.set("v.Spinner", false);
      $A.get("e.force:closeQuickAction").fire();
      $A.get("e.force:refreshView").fire();
    });

    $A.enqueueAction(action);
  }
});
