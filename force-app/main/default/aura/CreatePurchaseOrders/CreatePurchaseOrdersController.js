({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.getProducts");
    action.setParams({
      orderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.Spinner", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() != null) {
          component.set(
            "v.SalesOrderRelatedOpportunityLineItems",
            response.getReturnValue()
          );
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error in getting products"
          });
          toastEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  covertToPurchaseOrders: function (component, event, helper) {
    component.set("v.Spinner", true);
    var allValues = [];
    var selectedPOs = component.find("poPicklist");
    if (selectedPOs.length == undefined) {
      var values = {
        value: selectedPOs.get("v.value"),
        prodId: selectedPOs.get("v.name")
      };
      allValues.push(values);
    }
    for (var i = 0; i < selectedPOs.length; i++) {
      var values = {
        value: selectedPOs[i].get("v.value"),
        prodId: selectedPOs[i].get("v.name")
      };
      allValues.push(values);
    }

    var poNumber = event.getSource().get("v.name");
    var picklistStatus = event.getSource().get("v.value");
    var action = component.get("c.createPurchaseOrders");
    action.setParams({
      orderId: component.get("v.recordId"),
      valuesAndIds: JSON.stringify(allValues)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      component.set("v.Spinner", false);
      if (state == "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Purchase Orders Created Successfully"
        });
        toastEvent.fire();
        var appEvent = $A.get("e.c:CloseCreatePurchaseOrder");
        appEvent.fire();
        var appEvent = $A.get("e.c:RefreshWorkOrderTabs");
        appEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "There is an error in creating purchase orders"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  closePopup: function (component, event, helper) {
    var appEvent = $A.get("e.c:CloseCreatePurchaseOrder");
    appEvent.fire();
  }
});
