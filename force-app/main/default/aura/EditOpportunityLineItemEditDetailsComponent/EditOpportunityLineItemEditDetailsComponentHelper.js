({
  fetchPickListVal: function (component, elementId) {
    var action = component.get("c.getArtworksForPickList");
    action.setParams({
      recId: component.get("v.recordId")
    });
    var opts = [];
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var allValues = response.getReturnValue();

        if (allValues != undefined && allValues.length > 0) {
          opts.push({
            class: "optionClass",
            label: "--None--",
            value: ""
          });
        }
        for (var i = 0; i < allValues.length; i++) {
          opts.push({
            class: "optionClass",
            label: allValues[i],
            value: allValues[i]
          });
        }
        var elem = component.find(elementId);
        if (elem != null) elem.set("v.options", opts);
      } else {
      }
    });
    $A.enqueueAction(action);
  },

  getPricingRecordSize: function (component) {
    var action = component.get("c.getcountOfPricingRecords");
    var idValue = component.get("v.recordId");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != null) {
        component.set("v.pricingRecordsCount", response.getReturnValue());
      } else {
        console.log("Failed with state: " + state);
      }
    });

    $A.enqueueAction(action);
  },
  deleteWarningsHelper: function (component, recordToDelete) {
    var action = component.get("c.deleteWarningInDb");
    action.setParams({
      recId: recordToDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          $A.get("e.force:refreshView").fire();
        }
      } else {
        console.log("Failed with state: " + state);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Warning Cant be Deleted "
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },
  updateNotesValue: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    var action = component.get("c.updateNotesAndLabelInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Value Changed Successfully"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "Error Updating Fixed Charges.Kindly contact your administrator"
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },

  costChangedNew: function (component, event, helper) {
    for (var i = 1; i <= 5; i++) {
      var costValue = component.find("c.cost" + i);

      var updatedValue = component.find("margin" + i).get("v.value");
      if (isNaN(costValue)) {
        costValue = 0;
      }

      var inputsValues1 = component.find("dynamicIdsValues" + i); // return array if components with same 'aura:id' exist
      var finalCost = 0;
      if (!isNaN(costValue)) {
        finalCost = parseFloat(costValue);
      }

      if (inputsValues1 != null) {
        for (var i = 0; i < inputsValues1.length; i++) {
          var tempValue = inputsValues1[i].get("v.value");
          if (!isNaN(tempValue)) {
            finalCost += parseFloat(tempValue);
          }
        }
      }
      var finalPrice = (finalCost / (1 - updatedValue / 100)).toFixed(2);
      component.find("total" + i).set("v.value", finalPrice);
    }
  },

  updateFixedChargesValues: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    if (parseInt(updatedValue) < 0 && updateKey != "title") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else if (
      isNaN(updatedValue) &&
      updateKey != "title" &&
      updateKey != "delete"
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateFixedChargesInDb");
      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() != null) {
            if (updateKey != "delete") {
              component.set("v.recordToUpdateOfFixedCharges", recordToUpdate);
              component.set(
                "v.updatedValuesOfFixedCharges",
                response.getReturnValue()
              );
              var a = component.get("c.updateFixedChargesAfterResponse");
              $A.enqueueAction(a);
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Success",
                message: "Value Changed Successfully"
              });
              toastEvent.fire();
            } else {
              $A.get("e.force:refreshView").fire();
            }
          } else {
            $A.get("e.force:refreshView").fire();
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "Error Updating Fixed Charges.Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  },

  UpdateMargin: function (component, updatedValue, updateKey, recordToUpdate) {
    if (isNaN(updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (parseInt(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateMarginInDb");

      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() != null) {
            component.set("v.opportunityLineItem", null);
            component.set("v.opportunityLineItem", response.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Success",
              message: "Value changed successfully"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error Updating Margin Charges"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  },

  UpdateTotal: function (component, updatedValue, updateKey, recordToUpdate) {
    if (isNaN(updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (parseInt(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updatePricePerUnit");
      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });

      action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          if (response.getReturnValue() != null) {
            component.set("v.opportunityLineItem", null);
            component.set("v.opportunityLineItem", response.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Success",
              message: "Value changed successfully"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error Updating Total Charges"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  },

  UpdateCost: function (component, updatedValue, updateKey, recordToUpdate) {
    if (!updatedValue) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Field cannot be empty"
      });
      toastEvent.fire();
    } else if (isNaN(updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (parseInt(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateCostInDb");

      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          console.log(response.getReturnValue());
          if (response.getReturnValue() != null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Success",
              message: "Value changed successfully"
            });
            toastEvent.fire();
            component.set("v.opportunityLineItem", response.getReturnValue());
            component.set("v.options", returnValue.artworks);
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error Updating Cost"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  },

  UpdateQuantity: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    if (isNaN(updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (!(parseInt(updatedValue) == updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (parseInt(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateQuantityInDb");

      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          console.log(response.getReturnValue());
          if (response.getReturnValue() == true) {
            toastEvent.setParams({
              type: "Success",
              message: "Value changed successfully"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error Updating Value"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  },

  UpdateClientClickValue: function (
    component,
    recordToUpdate,
    checkboxValue,
    Number
  ) {
    var action = component.get("c.updateClientClickInDb");
    action.setParams({
      recordToUpdate: recordToUpdate,
      val: Number,
      checkboxValue: checkboxValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log(response.getReturnValue());
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Updated Successfully"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Error Updating Value"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  fetchPricingFromEsp: function (component, recordId) {
    var action = component.get("c.getProductPricingFromEsp");
    action.setParams({
      opportunityLineItemId: recordId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //  component.set("v.pricingFromEsp", response.getReturnValue());
        var pricesList = response.getReturnValue();
        component.set("v.pricesList", pricesList);
        component.set("v.SpinnerPrice", false);
      } else {
        console.log("Failed with state: " + state);
        component.set("v.SpinnerPrice", false);
      }
    });
    $A.enqueueAction(action);
  },

  calculateAndUpdateValues: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    if (
      !updatedValue &&
      updateKey != "runChargesTitle" &&
      updateKey != "delete"
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Field cannot be empty"
      });
      toastEvent.fire();
    } else if (
      isNaN(updatedValue) &&
      updateKey != "runChargesTitle" &&
      updateKey != "delete"
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (
      updateKey != "runChargesTitle" &&
      updateKey != "delete" &&
      parseInt(updatedValue) < 0
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateRunChargeValueinDB");
      console.log(action);

      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() != null) {
            if (updateKey != "delete") {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Success",
                message: "Value Changed Successfully"
              });
              toastEvent.fire();
              var returnValue = response.getReturnValue();
              component.set("v.opportunityLineItem", null);
              component.set("v.opportunityLineItem", response.getReturnValue());
              component.set("v.options", returnValue.artworks);
            } else {
              $A.get("e.force:refreshView").fire();
            }
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error Updating Run Charges"
          });
          toastEvent.fire();
        }
      });

      $A.enqueueAction(action);
    }
  }
});
