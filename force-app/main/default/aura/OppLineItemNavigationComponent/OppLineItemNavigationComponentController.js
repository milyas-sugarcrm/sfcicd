({
  doInit: function (component, event, helper) {
    var action = component.get("c.getOpportunityStage");
    action.setParams({
      oppId: component.get("v.recordId")
    });
    var displayTabs = $A.get("$Label.c.Display_PO_So_Tabs");
    console.log(displayTabs);
    if (displayTabs != "False") {
      var action3 = component.get("c.getPurchaseOrderId");
      action3.setParams({
        oppId: component.get("v.recordId")
      });

      action3.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() !== null) {
            component.set("v.EnablePurchaseOrder", true);
            component.find("tabs").set("v.selectedTabId", "five");
            component.set("v.purchaseOrderId", response.getReturnValue());
          }
        } else {
          console.log("Failed with state: " + state);
        }
      });

      var action2 = component.get("c.getWorkOrderOfOpportunity");
      action2.setParams({
        oppId: component.get("v.recordId")
      });
      action2.setCallback(this, function (response) {
        if (response.getState() === "SUCCESS") {
          if (response.getReturnValue() !== null) {
            component.set("v.EnableSalesOrder", true);
            component.find("tabs").set("v.selectedTabId", "three");
            component.set("v.workOrderId", response.getReturnValue());
            component.set("v.shippingId", response.getReturnValue());
            component.set("v.Spinner", false);
            $A.enqueueAction(action3);
          }
        }
      });
    } else {
      // component.find("tabs").set("v.selectedTabId", 'two');
    }
    var actionEstimate = component.get("c.getEstimateOfOpportunity");
    actionEstimate.setParams({
      oppId: component.get("v.recordId")
    });
    actionEstimate.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        console.log("response: " + response.getReturnValue());
        if (response.getReturnValue() !== null) {
          component.set("v.EnableEstimate", true);
          component.find("tabs").set("v.selectedTabId", "two");
          component.set("v.estimateId", response.getReturnValue());
          component.set("v.Spinner", false);
          //$A.enqueueAction(action2);
        } else {
          component.set("v.EnableEstimate", false);
        }
      } else {
        component.set("v.EnableEstimate", false);
      }
    });

    action.setCallback(this, function (response) {
      if (response.getState() === "SUCCESS") {
        if (
          response.getReturnValue() !== "Needs Analysis" &&
          response.getReturnValue() !== null
        ) {
          component.find("tabs").set("v.selectedTabId", "one");
          component.set("v.EnablePresentation", true);
          $A.enqueueAction(actionEstimate);
        }
      }
    });
    $A.enqueueAction(action);
  },
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  },
  hideEstimateTab: function (component, event, helper) {
    component.set("v.EnableEstimate", false);
  }
});
