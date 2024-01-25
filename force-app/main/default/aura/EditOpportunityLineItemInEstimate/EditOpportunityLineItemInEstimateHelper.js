({
  deleteBreakdownHelper: function (component, recordToDelete) {
    var action = component.get("c.deleteBreakdownInDb");
    action.setParams({
      recId: recordToDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
        component.set("v.message", "All changes are saved");
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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
        component.set("v.message", "All changes are saved");
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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

  deleteExtraChargesHelper: function (component, recordToDelete) {
    var action = component.get("c.deleteExtraChargesInDb");
    action.setParams({
      recId: recordToDelete
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
        component.set("v.message", "All changes are saved");
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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
          component.set("v.message", "All changes are saved");
        }
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });

    $A.enqueueAction(action);
  },
  calculateAndUpdatePricingRecord: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    var action = component.get("c.updatePricingInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != null) {
        var oppDetails = response.getReturnValue();
        component.set("v.opportunityLineItem", response.getReturnValue());
        component.set(
          "v.internationalCostExists",
          oppDetails.internationalCostExists
        );
        component.set("v.extraChargesExists", oppDetails.extraChargesExists);
        component.set(
          "v.pricingDetailsExists",
          oppDetails.pricingDetailsExists
        );
        component.set("v.breakDownCount", oppDetails.pricingDetails.length);
        component.set("v.totalPrice", oppDetails.total);
        component.set("v.subtotal", oppDetails.subtotal);
        component.set("v.marginPercentage", oppDetails.marginPercentage);
        component.set("v.marginAmount", oppDetails.marginAmount);
        component.set("v.message", "All changes are saved");
        var a = component.get("c.updateTimeOfLastChange");
        $A.enqueueAction(a);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });

    $A.enqueueAction(action);
    component.set("v.Spinner", false);
  },
  updateValuesOfDutyExtraChargesHelper: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    var action = component.get("c.updateValuesOfDutyExtraChargesInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() != null) {
          var oppDetails = response.getReturnValue();
          component.set("v.opportunityLineItem", response.getReturnValue());
          component.set(
            "v.internationalCostExists",
            oppDetails.internationalCostExists
          );
          component.set("v.extraChargesExists", oppDetails.extraChargesExists);
          component.set(
            "v.pricingDetailsExists",
            oppDetails.pricingDetailsExists
          );
          component.set("v.breakDownCount", oppDetails.pricingDetails.length);
          component.set("v.totalPrice", oppDetails.total);
          component.set("v.subtotal", oppDetails.subtotal);
          component.set("v.marginPercentage", oppDetails.marginPercentage);
          component.set("v.marginAmount", oppDetails.marginAmount);
          component.set("v.message", "All changes are saved");
          var a = component.get("c.updateTimeOfLastChange");
          $A.enqueueAction(a);
        }
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
  },
  updateValuesOfExtraChargesHelper: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    var action = component.get("c.updateValuesOfExtraChargesInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() != null) {
          var oppDetails = response.getReturnValue();
          component.set("v.opportunityLineItem", response.getReturnValue());
          component.set(
            "v.internationalCostExists",
            oppDetails.internationalCostExists
          );
          component.set("v.extraChargesExists", oppDetails.extraChargesExists);
          component.set(
            "v.pricingDetailsExists",
            oppDetails.pricingDetailsExists
          );
          component.set("v.breakDownCount", oppDetails.pricingDetails.length);
          component.set("v.totalPrice", oppDetails.total);
          component.set("v.subtotal", oppDetails.subtotal);
          component.set("v.marginPercentage", oppDetails.marginPercentage);
          component.set("v.marginAmount", oppDetails.marginAmount);
          component.set("v.message", "All changes are saved");
          var a = component.get("c.updateTimeOfLastChange");
          $A.enqueueAction(a);
        }
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var a = component.get("c.updateTimeOfLastChange");
        component.set("v.message", "All changes are saved");
        $A.enqueueAction(a);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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
  }
});
