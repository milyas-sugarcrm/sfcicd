({
  deletePurchaseOrderLineItem: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "Success",
      message: "Bill has been sent for deletion"
    });
    toastEvent.fire();
    component.set("v.Spinner", true);
    var action = component.get("c.deletPurchaseOrderLineItems");
    action.setParams({
      recordToDelete: component.get("v.recordToDelete"),
      purchaseOrderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var nullRecords = false;
      var state = response.getState();
      if (state != "SUCCESS") {
        console.log("Failed with state: " + state);
      } else {
        component.set("v.purchaseOrderDetails", response.getReturnValue());
        if (response.getReturnValue() == null) {
          debugger;
          nullRecords = true;
          var appEvent = $A.get("e.c:RefreshWorkOrderTabs");
          appEvent.fire();
        }

        component.set("v.Spinner", false);
      }
    });
    $A.enqueueAction(action);
    component.set("v.recordToDelete", null);
    component.set("v.deletePopup", false);
  },
  closeDropdownAction: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='marksAsDropdown']");
    for (var i = 0; i < elms.length; i++) {
      elms[i].style.display = "none";
    }
  },

  openDeletePopup: function (component, event, helper) {
    component.set("v.recordToDelete", event.currentTarget.dataset.value);
    component.set("v.deletePopup", true);
  },
  closeDeletePopup: function (component, event, helper) {
    component.set("v.recordToDelete", null);
    component.set("v.deletePopup", false);
    component.set("v.Spinner", false);
  },
  markAsDropdown: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var poNumber = ctarget.dataset.value;
    var action = component.get("c.addCommentForMarkAsDropDown");
    action.setParams({
      poNumber: poNumber,
      key: ctarget.dataset.value2
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state != "SUCCESS") {
        console.log("Failed with state: " + state);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Status added in notes"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
    var closeDropdown = component.get("c.closeDropdownAction");
    $A.enqueueAction(closeDropdown);
  },
  statusChangedOfPurchaseOrderPicklist: function (component, event, helper) {
    var action = component.get("c.addCommentForPicklistChange");
    var poNumber = event.getSource().get("v.name");
    var picklistStatus = event.getSource().get("v.value");
    action.setParams({
      poNumber: poNumber,
      picklistStatus: picklistStatus
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state != "SUCCESS") {
        console.log("Failed with state: " + state);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Status changed and added in notes successfully"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },

  doInit: function (component, event, helper) {
    var action = component.get("c.getDetailsRelatedPurchaseOrder");
    action.setParams({
      purchaseOrderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getReturnValue != null) {
        component.set("v.purchaseOrderDetails", response.getReturnValue());
      }

      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
    ///////////////
    var action1 = component.get("c.getSystemUsers");
    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state != "SUCCESS") {
        console.log("Failed with state: " + state);
      } else {
        component.set("v.Users", response.getReturnValue());
      }
    });
    $A.enqueueAction(action1);

    ///////////////
  },
  updateDropdown: function (component, event, helper) {
    var action = component.get("c.getDetailsRelatedPurchaseOrder");
    action.setParams({
      purchaseOrderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getReturnValue != null) {
        component.set("v.purchaseOrderDetails", response.getReturnValue());
        console.log(response.getReturnValue());
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },

  onChange: function (component, event, helper) {
    var poNumber = event.getSource().get("v.name");
    var picklistStatus = event.getSource().get("v.value");
    console.log("poNumber: " + poNumber);
    console.log("picklistStatus: " + picklistStatus);
    var items = component.find("mySelect");
    var name = event.getSource().get("v.name");
    //if(name!=null && items[name]!=null && items[name].get("v.value")!=null)
    {
      //var value = items[name].get("v.value");

      //var orders = component.get("v.purchaseOrderDetails");
      //var lineitem_id = orders[name].poLineItemId;
      // console.log('lineitem_id: '+lineitem_id);

      var action = component.get("c.updatePurchaseOrders");
      action.setParams({
        lineitem_id: poNumber,
        production_rep: picklistStatus
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var boolval = response.getReturnValue();
        if (boolval == true) {
          if (state != "SUCCESS") {
            console.log("Failed with state: " + state);
          } else {
            console.log("Success");
          }
        }
      });
      $A.enqueueAction(action);
    }
    //////////////
  },

  openDropdown: function (component, event, helper) {
    var index = event.currentTarget.name;
    var orderDetails = component.get("v.purchaseOrderDetails");
    var idSelected = orderDetails[index].poLineItemId;
    if (document.getElementById(idSelected).style.display == "block")
      document.getElementById(idSelected).style.display = "none";
    else document.getElementById(idSelected).style.display = "block";
  },
  closeDropdownAction: function (component, event, helper) {
    var orderDetails = component.get("v.purchaseOrderDetails");
    var i;
    for (i = 0; i < orderDetails.length; i++) {
      var idSelected = orderDetails[i].poLineItemId;
      document.getElementById(idSelected).style.display = "none";
    }
  },
  openNotes: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var purchaseOrderId = ctarget.dataset.value;
    component.set("v.purchaseOrderId", purchaseOrderId);
    component.set("v.shippingPopup", true);
  },

  openEmailPopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var purchaseOrderId = ctarget.dataset.value;
    component.set("v.purchaseOrderId", purchaseOrderId);
    component.set("v.emailPopup", true);
  },
  closeEmailPopup: function (component, event, helper) {
    component.set("v.emailPopup", false);
  },
  closeShippingPopup: function (component, event, helper) {
    //component.set("v.shippingRecordId",0);
    component.set("v.shippingPopup", false);
  },
  openShippingPage: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var purchaseOrderId = ctarget.dataset.value;
    var siteUrl = location.href;
    var baseURL = siteUrl.substring(0, siteUrl.indexOf("/", 14));
    var url = baseURL + "/apex/PurchaseOrderShippingPage?Id=" + purchaseOrderId;
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: url
    });
    urlEvent.fire();
  },
  openPackingSlipPage: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var purchaseOrderId = ctarget.dataset.value;
    var siteUrl = location.href;
    var baseURL = siteUrl.substring(0, siteUrl.indexOf("/", 14));
    var url = baseURL + "/apex/PurchaseOrderPackingSlip?Id=" + purchaseOrderId;
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: url
    });
    urlEvent.fire();
  },
  purchaseOrderPreviewPage: function (component, event, helper) {
    var ctarget = event.currentTarget;
    console.log(ctarget);
    var purchaseOrderId = ctarget.dataset.value;
    var siteUrl = location.href;
    var baseURL = siteUrl.substring(0, siteUrl.indexOf("/", 14));
    var url = baseURL + "/apex/PurchaseOrderPreviewPdf?id=" + purchaseOrderId;
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: url
    });
    urlEvent.fire();
  },
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  }
});
