({
  doInit: function (component, event, helper) {
    if (component.get("v.recordId") != null) {
      component.set("v.Spinner", false);
      var action = component.get("c.getSalesOrderRelatedOpportunityLineItems");
      action.setParams({
        salesId: component.get("v.recordId"),
        numOfrec: component.get("v.numOfRecords")
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set(
            "v.SalesOrderRelatedOpportunityLineItems",
            response.getReturnValue()
          );
          component.set("v.Spinner", false);
        }
      });
      $A.enqueueAction(action);

      var action2 = component.get("c.getCountOfSalesOrderOppLineItems");
      action2.setParams({
        salesId: component.get("v.recordId")
      });
      action2.setCallback(this, function (response) {
        component.set("v.Size", response.getReturnValue());
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action2);
    }
  },
  createPurchaseOrder: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action2 = component.get("c.createPurchaseOrderInDb");
    action2.setParams({
      salesId: component.get("v.recordId")
    });
    action2.setCallback(this, function (response) {
      //return 1 if true
      //return 0 if PO exists
      //return 2 if shipping information missing

      if (response.getState() === "SUCCESS" && response.getReturnValue() == 1) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "PurchaseOrder succesfully created"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else if (response.getReturnValue() == 2) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "Kindly fill out the shipping information for all the products"
        });
        toastEvent.fire();
      } else if (response.getReturnValue() == 0) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Purchase order already exists"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "There's an issue in creating purchase order. Kindly contact your administrator"
        });
        toastEvent.fire();
      }

      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action2);
  },
  openCreatePurchaseOrder: function (component, event, helper) {
    var action = component.get("c.getProductsWithShippingInfo");
    action.setParams({
      salesId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.Spinner", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          component.set("v.openCreatePurchaseOrders", true);
        } else if (
          response.getReturnValue() == false ||
          response.getReturnValue() == null
        ) {
          var message;
          if (response.getReturnValue() == false)
            message = "Purchase orders already exist for all products";
          else
            message = "Kindly fill out the Shipping information for Product(s)";
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: message
          });
          toastEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  CloseCreatePurchaseOrder: function (component, event, helper) {
    component.set("v.openCreatePurchaseOrders", false);
    $A.enqueueAction(component.get("c.doInit"));
  },
  editSalesOrderProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;

    var newEvent = $A.get("e.force:navigateToComponent");

    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemInEstimate",
      navigate: "true",
      componentAttributes: {
        recordId: id_str
      }
    });
    newEvent.fire();
  },
  callSave: function (component, event, helper) {
    var shippingComp = component.find("shippingMainComponent");
    shippingComp.callShippingSave();
    $A.enqueueAction(component.get("c.doInit"));
  },
  editShippingProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var action = component.get("c.getSalesOrderInHandDate");
    action.setParams({
      oppLineId: id_str
    });
    action.setCallback(this, function (response) {
      component.set("v.effectiveDate", response.getReturnValue());
      component.set("v.shippingRecordId", id_str);
      component.set("v.shippingPopup", true);
    });
    $A.enqueueAction(action);
  },
  openDeletePopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    component.set("v.deleteId", id_str);
    component.set("v.deletePopup", true);
  },
  closeDeletePopup: function (component, event, helper) {
    component.set("v.deleteId", 0);
    component.set("v.deletePopup", false);
  },

  closeShippingPopup: function (component, event, helper) {
    component.set("v.shippingRecordId", 0);
    component.set("v.shippingPopup", false);
  },
  deleteOpportunityLineItem: function (component, event, helper) {
    var action = component.get("c.deleteOpportunityLineItemInDb");
    action.setParams({
      salesId: component.get("v.deleteId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "OpportunityLineItem Deleted Successfully"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
          component.set("v.Spinner", true);

          $A.enqueueAction(component.get("c.doInit"));

          component.set("v.Spinner", false);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error in deleting OpportunityLineItem"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  addArtworkComponent: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemArtWorkComponent",
      navigate: "true",
      componentAttributes: {
        recordId: event.getSource().get("v.value")
      }
    });
    newEvent.fire();
  },

  handleColumnsChange: function (cmp, event, helper) {
    helper.initColumnsWithActions(cmp, event, helper);
  },
  gotoRelatedList: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:ShippingOppLineItem",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        viewAll: "false",
        numOfRecords: "8"
      }
    });
    newEvent.fire();
  }
});
