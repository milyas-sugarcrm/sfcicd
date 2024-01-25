({
  fetchColorsValues: function (component, event, helper) {
    var action = component.get("c.getValuesForColorPiklist");
    action.setParams({
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
    var action = component.get("c.getValuesForSizePiklist");
    action.setParams({
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
  calculateAndUpdatePricingRecord: function (
    component,
    updatedValue,
    updateKey,
    recordToUpdate
  ) {
    component.set("v.Spinner", true);
    var action = component.get("c.updatePricingInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: recordToUpdate
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
    });

    $A.enqueueAction(action);
  }
});
