({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.getEstimateOfOpportunity");
    action.setParams({
      oppId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.estimateId", response.getReturnValue());
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);

    var action1 = component.get("c.getOpportunityName");
    action1.setParams({
      oppId: component.get("v.recordId")
    });
    action1.setCallback(this, function (response) {
      var ab = response.getReturnValue();
      component.set("v.opportunityName", response.getReturnValue());
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action1);
  },
  closeDropdownAction: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='dropdown']");
    for (var i = 0; i < elms.length; i++) {
      elms[i].style.display = "none";
    }
  },
  generatePdfs: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.generatePdfForPurchaseOrder");
    action.setParams({
      orderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getReturnValue()) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "PDF Created"
        });
        toastEvent.fire();
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  openDropdown: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='dropdown']");
    for (var i = 0; i < elms.length; i++) {
      if (elms[i].style.display == "block") elms[i].style.display = "none";
      else elms[i].style.display = "block";
    }
  },
  regeneratePo: function (component, event, helper) {
    component.set("v.Spinner", true);

    var action = component.get("c.regeneratePurchaseOrder");
    action.setParams({
      purchaseOrder: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Purchase Order regenerated"
        });
        toastEvent.fire();

        component.set("v.Spinner", false);
        $A.get("e.force:refreshView").fire();
        $A.get("e.c:RefreshPurchaseOrderProofs").fire();
        $A.get("e.c:RefreshPurchaseOrderProducts").fire();
      }
    });
    $A.enqueueAction(action);
    $A.enqueueAction(component.get("c.doInit"));
  },

  closeRegeneratePopup: function (component, event, helper) {
    component.set("v.regeneratePopup", false);
  },
  previewProofApprovalPage: function (component, event, helper) {
    var action = component.get("c.getProofApprovalPageLink");
    action.setParams({
      purchaseOrder: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getReturnValue() !== null) {
        var url = response.getReturnValue() + component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: url
        });
        urlEvent.fire();
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  }
});
