({
  selectedStageChanged: function (component, event, helper) {
    if (event.getSource().get("v.value") != "Closed Lost") {
      component.set("v.closeLostSelected", false);
    } else {
      component.set("v.closeLostSelected", true);
    }
  },
  changeStateOfOpportunity: function (component, event, helper) {
    var reason = null;
    var stage = component.find("StageList").get("v.value");
    if (component.get("v.closeLostSelected")) {
      reason = component.find("lossReasonSelect").get("v.value");
    }
    var idValue = component.get("v.recordId");
    var action = component.get("c.changeStateOfOpportunityInDb");
    action.setParams({
      recordId: component.get("v.recordId"),
      stage: stage,
      reason: reason
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Stage changed successfully"
        });
        toastEvent.fire();
        $A.get("e.force:refreshView").fire();
      } else {
        component.set("v.changeClosedPopup", false);
        var errors = action.getError();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "You encountered some errors when trying to save this record",
          message: errors[0].message
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  openChangeClosedStagePopup: function (component, event, helper) {
    component.set("v.changeClosedPopup", true);
  },
  markStageAsComplete: function (component, event, helper) {
    if (
      component.get("v.stage") == "Presentation" &&
      component.get("v.Selectedstage") != "null" &&
      component.get("v.Selectedstage") == "Estimate"
    ) {
      helper.fetchPickListVal(component, "AccountDropDown");
      component.set("v.markPrStageAsComplete", true);
    } else if (
      component.get("v.stage") == "Needs Analysis" &&
      component.get("v.Selectedstage") != "null" &&
      component.get("v.Selectedstage") == "Estimate"
    ) {
      helper.fetchPickListVal(component, "AccountDropDown");
      component.set("v.markStageAsComplete", true);
    } else if (
      component.get("v.stage") == "Presentation" &&
      component.get("v.Selectedstage") == "null"
    ) {
      helper.fetchPickListVal(component, "AccountDropDown");
      component.set("v.markPrStageAsComplete", true);
    } else {
      if (component.get("v.Selectedstage") == "null") {
        if (component.get("v.stage") == "Presentation") {
          component.set("v.Selectedstage", "Estimate");
        } else if (component.get("v.stage") == "Needs Analysis") {
          component.set("v.Selectedstage", "Presentation");
        } else if (component.get("v.stage") == "Estimate") {
          component.set("v.Selectedstage", "Sales");
        } else if (component.get("v.stage") == "Sales") {
          component.set("v.Selectedstage", "Closed Won");
        }
      }

      var idValue = component.get("v.recordId");
      var action = component.get("c.changeStateOfOpportunityInDb");
      action.setParams({
        recordId: component.get("v.recordId"),
        stage: component.get("v.Selectedstage"),
        reason: null
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Stage changed successfully"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          var errors = action.getError();
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title:
              "You encountered some errors when trying to save this record",
            message: errors[0].message
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  closeWarningPopup: function (component, event, helper) {
    var cmpDiv = component.find("popupclassId");
    $A.util.removeClass(cmpDiv, "popupclassUpdated");
    component.set("v.showWarningPopup", false);
  },
  CloseMarkStageAsComplete: function (component, event, helper) {
    var markstageAsComplete = component.get("v.markStageAsComplete");
    if (markstageAsComplete == true) {
      component.set("v.markStageAsComplete", false);
    } else {
      component.set("v.markPrStageAsComplete", false);
    }
  },
  closeChangeClosedStagePopup: function (component, event, helper) {
    component.set("v.changeClosedPopup", false);
  },
  makeEstimateWithoutProductsFromWarningPopup: function (
    component,
    event,
    helper
  ) {
    var idValue = component.get("v.recordId");
    var selectedValue = component.find("AccountDropDown").get("v.value");
    var action = component.get("c.createEstimateWithoutProductsInDb");
    var noOfAccounts = component.get("v.noOfAccounts");
    var listOfAccount = component.get("v.options");

    if (noOfAccounts < 1) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message:
          "Estimate cannot be created. Opportunity's account is not synced with Quickbooks"
      });
      toastEvent.fire();
    } else if (noOfAccounts > 1 && selectedValue == "") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Kindly select an account to sync estimate with"
      });
      toastEvent.fire();
    } else {
      action.setParams({
        recordId: component.get("v.recordId"),
        selectedValue: selectedValue
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.markStageAsComplete", false);
          component.set("v.showWarningPopup", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Stage changed successfully"
          });
          toastEvent.fire();

          $A.get("e.force:refreshView").fire();
        } else {
          var errors = action.getError();

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title:
              "You encountered some errors when trying to save this record",
            message: errors[0].message
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  makeEstimateWithoutProducts: function (component, event, helper) {
    var selectedValue = component.find("AccountDropDown").get("v.value");
    var noOfAccounts = component.get("v.noOfAccounts");
    var listOfAccount = component.get("v.options");

    if (noOfAccounts < 1) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message:
          "Estimate cannot be created. Opportunity's account is not synced with Quickbooks"
      });
      toastEvent.fire();
    } else if (noOfAccounts > 1 && selectedValue == "") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Kindly select an account to sync estimate with"
      });
      toastEvent.fire();
    } else if (noOfAccounts == 1 && selectedValue != "") {
      component.set("v.selectedAccount", selectedValue);
      var cmpDiv = component.find("popupclassId");
      $A.util.addClass(cmpDiv, "popupclassUpdated");

      component.set("v.showWarningPopup", true);
    } else {
      var idValue = component.get("v.recordId");
      var action = component.get("c.createEstimateWithoutProductsInDb");
      action.setParams({
        recordId: component.get("v.recordId"),
        selectedValue: selectedValue
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Stage changed successfully"
          });
          toastEvent.fire();
          component.set("v.markStageAsComplete", false);
          component.set("v.showWarningPopup", false);
          $A.get("e.force:refreshView").fire();
        } else {
          var errors = action.getError();

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title:
              "You encountered some errors when trying to save this record",
            message: errors[0].message
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  doInit: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getStage");
    action.setParams({ recordId: component.get("v.recordId") });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.stage", response.getReturnValue());
      }
    });
    $A.enqueueAction(action);
    //check estimate already exist or not
    console.log("id: " + component.get("v.recordId"));
    //component.set("v.Spinner",true);
    var action0 = component.get("c.checkEstimateExists");
    action0.setParams({
      recid: component.get("v.recordId")
    });
    action0.setCallback(this, function (response) {
      //  alert("response.getReturnValue() "+response.getReturnValue());
      component.set("v.estimateExist", response.getReturnValue());
    });
    $A.enqueueAction(action0);
    //Create head tag dynamically
    var head = document.getElementsByTagName("head")[0];

    //Create link or script tag dynamically
    var link = document.createElement("link");

    //Add appropriate attributes
    link.href = "/resource/CustomChevronCSS";
    link.rel = "stylesheet";

    head.appendChild(link);
  },
  handleSelect: function (component, event, helper) {
    var stepName = event.getParam("detail").value;
    component.set("v.Selectedstage", stepName);
  }
});
