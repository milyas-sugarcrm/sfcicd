({
  doInit: function (component, event, helper) {
    helper.fetchPickListVal(component, "AccountDropDown");
    // alert(component.get("v.options"));
    component.set("v.Spinner", true);

    var action = component.get("c.getRelatedOpportunityLineItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.RelatedOpportunityLineItems", response.getReturnValue());
      var values = response.getReturnValue();
    });
    $A.enqueueAction(action);
    component.set("v.Spinner", false);
  },
  showWarning: function (component, event, helper) {
    //  var appEvent = $A.get("e.c:applicationEvents");
    //  appEvent.fire();
    var noOfAccounts = component.get("v.noOfAccounts");
    if (noOfAccounts == 1) {
      var selectedValue = component.find("AccountDropDown").get("v.value");
      var appEvent = $A.get("e.c:openWarningPopup");
      appEvent.setParams({ selectedAccount: selectedValue });
      appEvent.fire();
    } else {
      var a = component.get("c.convertToEstimateJS");
      $A.enqueueAction(a);
    }
  },
  closeWarningPopup: function (component, event, helper) {
    component.set("v.showWarningPopup", false);
  },
  convertToEstimateJS: function (component, event, helper) {
    var selectedValue = component.find("AccountDropDown").get("v.value");

    var noOfAccounts = component.get("v.noOfAccounts");
    var listOfAccount = component.get("v.options");

    if (noOfAccounts < 1 || noOfAccounts == null) {
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
      component.set("v.Spinner", true);
      var allValues = [];
      var areValuesCorrect = true;
      var inputsValues1 = component.find("opportunityLineItemQuantity");
      var valuesExist = true;
      if (inputsValues1 != null) {
        if (inputsValues1.length == undefined) {
          var numberVaue = inputsValues1.get("v.value");

          if (numberVaue != "" && isNaN(parseInt(numberVaue))) {
            areValuesCorrect = false;
          } else if (numberVaue != "" && parseInt(numberVaue) < 0) {
            areValuesCorrect = false;
          } else if (
            numberVaue != "" &&
            !(parseInt(numberVaue) == numberVaue)
          ) {
            areValuesCorrect = false;
          } else if (numberVaue != "" && numberVaue % 1 != 0) {
            areValuesCorrect = false;
          } else {
            if (inputsValues1.get("v.value").length > 0) {
              valuesExist = true;
              console.log("values are : ");

              console.log(inputsValues1.get("v.name"));
              var values = {
                value: inputsValues1.get("v.value"),
                recordId: inputsValues1.get("v.name")
              };
              console.log(values);
              allValues.push(values);
            }
          }
        } else {
          for (var i = 0; i < inputsValues1.length; i++) {
            var numberVaue = inputsValues1[i].get("v.value");
            if (numberVaue % 1 != 0) {
              areValuesCorrect = false;
              break;
            }

            if (
              inputsValues1[i].get("v.value") != "" &&
              (isNaN(parseInt(inputsValues1[i].get("v.value"))) ||
                parseInt(inputsValues1[i].get("v.value")) < 0)
            ) {
              areValuesCorrect = false;
              break;
            } else {
              if (
                inputsValues1[i].get("v.value") != "" &&
                inputsValues1[i].get("v.value").length > 0
              ) {
                valuesExist = true;
                var values = {
                  value: inputsValues1[i].get("v.value"),
                  recordId: inputsValues1[i].get("v.name")
                };
                allValues.push(values);
              }
            }
          }
        }
      }
      if (valuesExist == true && areValuesCorrect == true) {
        var action = component.get("c.convertToEstimateInDb");
        action.setParams({
          recid: component.get("v.recordId"),
          valuesAndIds: JSON.stringify(allValues),
          selectedAccount: selectedValue
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            component.set("v.Spinner", false);
            if (response.getReturnValue() == true) {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Success",
                message: "Estimate created successfully"
              });
              toastEvent.fire();
              var refreshEvent = $A.get("e.c:RefreshPresentationComponent");
              refreshEvent.fire();
              var refreshTabsEvent = $A.get("e.c:RefreshTabs");
              refreshTabsEvent.fire();
              var appEvent = $A.get("e.c:applicationEvents");
              appEvent.fire();
            } else if (response.getReturnValue() == false) {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "Estimate already exist!"
              });
              toastEvent.fire();
              var appEvent = $A.get("e.c:applicationEvents");
              appEvent.fire();
            } else {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "There is an issue in creating estimate."
              });
              toastEvent.fire();
              var appEvent = $A.get("e.c:applicationEvents");
              appEvent.fire();
            }
          }
        });
        $A.enqueueAction(action);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "You must correct values for quantity!"
        });
        toastEvent.fire();
        component.set("v.Spinner", false);
      }
    }
  },
  closePopup: function (component, event, helper) {
    var appEvent = $A.get("e.c:applicationEvents");
    appEvent.fire();
  }
});
