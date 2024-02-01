({
  previewInvoice: function (component, event, helper) {
    if (component.find("deposit_percent").get("v.value") == "") {
      component.find("deposit_percent").set("v.value", 0);
    }
    if (component.find("allow_credit_card").get("v.value") == "") {
      component.find("allow_credit_card").set("v.value", 0);
    }
    if (component.find("confirmation").get("v.value") == "") {
      component.find("confirmation").set("v.value", 0);
    }
    if (component.find("amount_recieved").get("v.value") == "") {
      component.find("amount_recieved").set("v.value", 0);
    }
    /*if(component.find("date_recieved").get('v.value')=='')
        {
            component.find("date_recieved").set('v.value', ' ');
        }*/

    var valuesAndIds = {
      deposit_percent: component.find("deposit_percent").get("v.value"),
      allow_credit_card: component.find("allow_credit_card").get("v.checked"),
      amount_recieved: component.find("amount_recieved").get("v.value"),
      confirmation: component.find("confirmation").get("v.value"),
      date_recieved: "null"
    };
    var action = component.get("c.getTotal");
    action.setParams({
      recId: component.get("v.recordId"),
      valuesAndIds: JSON.stringify(valuesAndIds)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var depositPercent = component.find("deposit_percent").get("v.value");
        if (response.getReturnValue() !== null) {
          component
            .find("deposit_amount")
            .set(
              "v.value",
              (
                (depositPercent / 100) *
                response.getReturnValue().total
              ).toFixed(2)
            );
          var url =
            response.getReturnValue().depositInvoicePreview +
            "&deposit_amount=" +
            component.find("deposit_amount").get("v.value") +
            "&deposit_percent=" +
            depositPercent;
          console.log("url: " + url);

          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url: url
          });
          urlEvent.fire();
        } else {
          console.log(" null");
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Deposit invoice doesn't exist!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  onDepositPercentChange: function (component, event, helper) {
    if (component.find("deposit_percent").get("v.value") == "") {
      component.find("deposit_percent").set("v.value", 0);
    }
    if (component.find("allow_credit_card").get("v.value") == "") {
      component.find("allow_credit_card").set("v.value", 0);
    }
    if (component.find("confirmation").get("v.value") == "") {
      component.find("confirmation").set("v.value", 0);
    }
    if (component.find("amount_recieved").get("v.value") == "") {
      component.find("amount_recieved").set("v.value", 0);
    }
    var valuesAndIds = {
      deposit_percent: component.find("deposit_percent").get("v.value"),
      allow_credit_card: component.find("allow_credit_card").get("v.checked"),
      amount_recieved: component.find("amount_recieved").get("v.value"),
      confirmation: component.find("confirmation").get("v.value"),
      date_recieved: "null"
    };
    var action = component.get("c.getTotal");
    action.setParams({
      recId: component.get("v.recordId"),
      valuesAndIds: JSON.stringify(valuesAndIds)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var depositPercent = component.find("deposit_percent").get("v.value");
        if (response.getReturnValue() !== null) {
          component
            .find("deposit_amount")
            .set(
              "v.value",
              (
                (depositPercent / 100) *
                response.getReturnValue().total
              ).toFixed(2)
            );
        }
      }
    });
    $A.enqueueAction(action);
  }
});
