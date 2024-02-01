({
  populateSizes: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getValuesForSizeTextBox");
    action.setParams({
      recId: idValue
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();

        var plValues = [];

        for (var i = 0; i < result.length; i++) {
          plValues.push(result[i]);
        }
        component.set("v.sizeListInText", plValues);
      }
    });
    $A.enqueueAction(action);
  },
  populateColors: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getValuesForColorTextBox");
    action.setParams({
      recId: idValue
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();

        var plValues = [];

        for (var i = 0; i < result.length; i++) {
          plValues.push(result[i]);
        }
        component.set("v.colorListInText", plValues);
      }
    });
    $A.enqueueAction(action);
  },
  fetchColorsValues: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getValuesForColorPiklist");
    action.setParams({
      recId: idValue
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
      recId: idValue
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
