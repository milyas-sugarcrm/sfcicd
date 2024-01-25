({
  fetchPickListVal: function (component, elementId) {
    component.set("v.EstimateSpinner", true);
    var action = component.get("c.getAccountDropDown");
    action.setParams({
      recId: component.get("v.recordId")
    });
    var opts = [];
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var allValues = response.getReturnValue();
        if (allValues != undefined && allValues.length > 0) {
          if (allValues.length != 1) {
            opts.push({
              class: "optionClass",
              label: "--None--",
              value: ""
            });
          }
        }
        for (var i = 0; i < allValues.length; i++) {
          opts.push({
            class: "optionClass",
            label: allValues[i],
            value: allValues[i]
          });
        }
        var elem = component.find(elementId);
        if (elem != null) {
          elem.set("v.options", opts);
          if (allValues.length != 1) {
            component.set("v.noOfAccounts", opts.length - 1);
          } else {
            component.set("v.noOfAccounts", opts.length);
          }
          component.set("v.EstimateSpinner", false);
        }
      } else {
      }
    });
    $A.enqueueAction(action);
  },
  helperMethod: function () {}
});
