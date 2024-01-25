({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var idValue = component.get("v.recordId");
    var action = component.get("c.getHistory");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      component.set("v.Spinner", false);
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != null) {
        var historyRecords = response.getReturnValue();

        for (var i = historyRecords.length - 1, j = 0; i >= 0; i--, j++) {
          historyRecords[j].count = i + 1;
          if (
            historyRecords[j].Changed_field__c == "Run Charge Cost" ||
            historyRecords[j].Changed_field__c == "Run Charge Retail Price" ||
            historyRecords[j].Changed_field__c == "Duty Cost" ||
            historyRecords[j].Changed_field__c == "Duty Retail Price" ||
            historyRecords[j].Changed_field__c ==
              "Inbound Freight Retail Price" ||
            historyRecords[j].Changed_field__c == "Inbound Freight Cost" ||
            historyRecords[j].Changed_field__c == "Fixed Charge Cost" ||
            historyRecords[j].Changed_field__c == "Fixed Charge Retail Price" ||
            historyRecords[j].Changed_field__c == "Pricing Retail Price" ||
            historyRecords[j].Changed_field__c == "Pricing Cost" ||
            historyRecords[j].Changed_field__c == "Pricing Quantity" ||
            historyRecords[j].Changed_field__c == "Fixed Charge Quantity" ||
            historyRecords[j].Changed_field__c == "Duty Quantity" ||
            historyRecords[j].Changed_field__c == "Run Charge Quantity" ||
            historyRecords[j].Changed_field__c == "Inbound Freight Quantity" ||
            historyRecords[j].Changed_field__c == "Run Charge Margin" ||
            historyRecords[j].Changed_field__c == "Fixed Charge Margin" ||
            historyRecords[j].Changed_field__c == "Inbound Freight Margin" ||
            historyRecords[j].Changed_field__c == "Duty Margin" ||
            historyRecords[j].Changed_field__c == "Pricing Margin"
          ) {
            historyRecords[j].isCurrency = true;
          } else {
            historyRecords[j].isCurrency = false;
          }
        }
        component.set("v.historyRecords", historyRecords);
      } else if (state === "SUCCESS" && response.getReturnValue() == null) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "No changes have been made yet!"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  openProduct: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemInEstimate",
      navigate: "true",
      componentAttributes: {
        recordId: id_str
      }
    });
    newEvent.fire();
  },
  openImage: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    window.open(
      location.origin + "/lightning/r/ContentDocument/" + id_str + "/view"
    );
  }
});
