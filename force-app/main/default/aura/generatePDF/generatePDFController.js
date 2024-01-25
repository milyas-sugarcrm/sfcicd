({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var idValue = component.get("v.recordId");
    var action = component.get("c.generatePdfPrsentation");
    action.setParams({
      oppId: idValue,
      fileName: ""
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "PDF generated successfully"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else if (state === "SUCCESS" && response.getReturnValue() == null) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "There are no products to add in PDF!"
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);

    var action2 = component.get("c.generatePdfEstimate");
    action2.setParams({
      oppId: idValue,
      fileName: ""
    });
    action2.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "PDF generated successfully"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      }
    });

    $A.enqueueAction(action2);

    var action3 = component.get("c.generatePdfSalesorder");
    action3.setParams({
      oppId: idValue,
      fileName: ""
    });
    action3.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "PDF generated successfully"
        });
        toastEvent.fire();
      }
      component.set("v.Spinner", false);
      $A.get("e.force:closeQuickAction").fire();
      $A.get("e.force:refreshView").fire();
    });

    $A.enqueueAction(action3);
    var a = component.get("c.closePopup");
    $A.enqueueAction(a);
  },
  closePopup: function (component, event, helper) {}
});
