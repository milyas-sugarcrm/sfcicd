({
  doInit: function (component, event, helper) {
    var displayTabs = $A.get("$Label.c.Display_PO_So_Tabs");
    console.log(displayTabs);
    if (displayTabs != "False") {
      var action3 = component.get("c.getPurchaseOrderIdForWorkOrders");
      action3.setParams({
        workId: component.get("v.recordId")
      });

      action3.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() !== null) {
            component.set("v.EnablePurchaseOrder", true);
            component.find("tabs").set("v.selectedTabId", "three");
            component.set("v.purchaseOrderId", response.getReturnValue());
          } else {
            component.set("v.EnablePurchaseOrder", false);
          }
        } else {
          console.log("Failed with state: " + state);
        }
      });
      component.set("v.EnableSalesOrder", true);
      component.find("tabs").set("v.selectedTabId", "one");
      component.set("v.workOrderId", component.get("v.recordId"));
      component.set("v.shippingId", component.get("v.recordId"));
      component.set("v.Spinner", false);
    }
    $A.enqueueAction(action3);
  },
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  }
});
