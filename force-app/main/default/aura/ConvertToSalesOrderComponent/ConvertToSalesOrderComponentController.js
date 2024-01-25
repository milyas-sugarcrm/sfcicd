({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    /* var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('='); //Split by & so that you get the key value pairs separately in a list
        var sParameterName = sURLVariables[1];
        console.log('Param name: '+sParameterName);
         component.set("v.recordId", sParameterName);*/
    var action = component.get("c.getRelatedOpportunityLineItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.RelatedOpportunityLineItems", response.getReturnValue());
      var values = response.getReturnValue();
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  convertToEstimateJS: function (component, event, helper) {
    component.set("v.Spinner", true);
    var allValues = [];
    var checkedValues = false;
    var inputsValues1 = component.find("opportunityLineItemQuantity");
    if (inputsValues1 != null) {
      if (inputsValues1.length == undefined) {
        if (inputsValues1.get("v.checked") != false) {
          var values = {
            value: inputsValues1.get("v.checked"),
            recordId: inputsValues1.get("v.name")
          };
          allValues.push(values);
          checkedValues = true;
        }
      } else {
        for (var i = 0; i < inputsValues1.length; i++) {
          if (inputsValues1[i].get("v.checked") != false) {
            var values = {
              value: inputsValues1[i].get("v.checked"),
              recordId: inputsValues1[i].get("v.name")
            };
            allValues.push(values);
            checkedValues = true;
          }
        }
      }
      if (checkedValues === true) {
        var action = component.get("c.convertToEstimateInDb");
        action.setParams({
          recid: component.get("v.recordId"),
          valuesAndIds: JSON.stringify(allValues)
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            if (response.getReturnValue() == "true") {
              component.set("v.Spinner", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Success",
                message: "Sales Order created successfully"
              });
              toastEvent.fire();
              var RefreshEstimate = $A.get("e.c:RefreshEstimate");
              RefreshEstimate.fire();
              var refreshTabs = $A.get("e.c:RefreshTabs");
              refreshTabs.fire();
              var appEvent = $A.get("e.c:CloseSalesOrderPopup");
              appEvent.fire();
            } else if (response.getReturnValue() == "false") {
              component.set("v.Spinner", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "Sales order already exist!"
              });
              toastEvent.fire();
              var appEvent = $A.get("e.c:CloseSalesOrderPopup");
              appEvent.fire();
            } else if (response.getReturnValue() == null) {
              component.set("v.Spinner", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "There is an issue in creating sales order."
              });
              toastEvent.fire();
              var appEvent = $A.get("e.c:CloseSalesOrderPopup");
              appEvent.fire();
            } else {
              component.set("v.Spinner", false);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: response.getReturnValue()
              });
              toastEvent.fire();
              var appEvent = $A.get("e.c:CloseSalesOrderPopup");
              appEvent.fire();
            }
          }
        });
        $A.enqueueAction(action);
      } else {
        component.set("v.Spinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Please select a product first!."
        });
        toastEvent.fire();
      }
    } else {
      component.set("v.Spinner", false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "There are no Items in Estimate!"
      });
      toastEvent.fire();
      $A.get("e.force:closeQuickAction").fire();
    }
  },
  checkAll: function (component, event, helper) {
    if (component.find("checkall").get("v.checked") == true) {
      var inputsValues1 = component.find("opportunityLineItemQuantity");
      if (inputsValues1 != null) {
        if (inputsValues1.length == undefined) {
          inputsValues1.set("v.checked", true);
        } else {
          for (var i = 0; i < inputsValues1.length; i++) {
            inputsValues1[i].set("v.checked", true);
          }
        }
      }
    } else {
      var inputsValues1 = component.find("opportunityLineItemQuantity");
      if (inputsValues1 != null) {
        if (inputsValues1.length == undefined) {
          inputsValues1.set("v.checked", false);
        } else {
          for (var i = 0; i < inputsValues1.length; i++) {
            inputsValues1[i].set("v.checked", false);
          }
        }
      }
    }
  },
  closePopup: function (component, event, helper) {
    var appEvent = $A.get("e.c:CloseSalesOrderPopup");
    appEvent.fire();
  }
});
