({
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

  UpdatePricing: function (component, updatedValue, updateKey, recordToUpdate) {
    if (updateKey != "sku" && isNaN(updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (
      updateKey != "sku" &&
      !(parseFloat(updatedValue) == updatedValue)
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (updateKey != "sku" && parseFloat(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateProductPricingInDb");
      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var toastEvent = $A.get("e.force:showToast");
        if (state === "SUCCESS") {
          if (response.getReturnValue() == true) {
            $A.enqueueAction(component.get("c.doInit"));
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
  updateExtraCharges: function (
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
    } else if (!(parseFloat(updatedValue) == updatedValue)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be Number"
      });
      toastEvent.fire();
    } else if (parseFloat(updatedValue) < 0) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Value must be positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.updateExtraChargesInDb");
      action.setParams({
        updatedValue: updatedValue,
        updateKey: updateKey,
        recordToUpdate: recordToUpdate
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var toastEvent = $A.get("e.force:showToast");
        if (state === "SUCCESS") {
          if (response.getReturnValue() == true) {
            $A.enqueueAction(component.get("c.doInit"));
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

  updateExtraChargeTitle: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    var action = component.get("c.updateExtraChargesInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      var toastEvent = $A.get("e.force:showToast");
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          $A.enqueueAction(component.get("c.doInit"));
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
  },

  fetchColorsValues: function (component, event, helper) {
    /*var plValues = [];
        plValues.push({
                        label: component.get("v.selectedColor"),
                        value:  component.get("v.selectedColor")
                    });
        component.set("v.selectedColorList", plValues);*/

    var idValue = component.get("v.recordId");
    var action = component.get("c.getValuesForColorPiklist");
    action.setParams({
      recId: idValue,
      priceId: component.get("v.selectedColorId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var plValues = [];

        for (var i = 0; i < result.length; i++) {
          plValues.push({
            label: result[i].color,
            value: result[i].color
          });
        }
        component.set("v.colorList", plValues);
        plValues = [];
        for (var i = 0; i < result.length; i++) {
          if (result[i].isSelected == true) {
            plValues.push(result[i].color);
          }
        }

        component.set("v.selectedColorList", plValues);
      }
    });
    $A.enqueueAction(action);
  },

  fetchSizeValues: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getValuesForSizePiklist");
    action.setParams({
      recId: idValue,
      sizeId: component.get("v.selectedColorId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var plValues = [];

        for (var i = 0; i < result.length; i++) {
          plValues.push({
            label: result[i].size,
            value: result[i].size
          });
        }
        component.set("v.sizeList", plValues);
        plValues = [];
        for (var i = 0; i < result.length; i++) {
          if (result[i].isSelected == true) {
            plValues.push(result[i].size);
          }
        }

        component.set("v.selectedSizeList", plValues);
      }
    });
    $A.enqueueAction(action);
  },

  deleteArtworkHelper: function (component, recordToDelete) {
    var action = component.get("c.deleteArtworkInDb");
    action.setParams({
      recId: recordToDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
        $A.get("e.force:refreshView").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Artwork Deleted Successfully"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Failed to Delete Extra Charge"
        });
      }
    });

    $A.enqueueAction(action);
  },

  deleteExtraChargesHelper: function (component, recordToDelete) {
    var action = component.get("c.deleteExtraChargesInDb");
    action.setParams({
      recId: recordToDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Extra Charge Deleted Successfully"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Failed to Delete Extra Charge"
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  }
});
