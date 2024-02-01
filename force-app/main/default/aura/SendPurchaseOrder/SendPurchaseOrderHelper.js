({
  sendHelper: function (
    component,
    recordId,
    fromEmail,
    toEmail,
    ccEmail,
    subject,
    body,
    cvIds
  ) {
    var action = component.get("c.sendMail1");
    action.setParams({
      recordId: recordId,
      fromEmail: fromEmail,
      toEmail: toEmail,
      ccEmail: ccEmail,
      subject: subject,
      body: body,
      cvIds: cvIds
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var storeResponse = response.getReturnValue();
        if (storeResponse === true) {
          component.set("v.emailPopup", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Purchase Order Successfully Sent to Vendor"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        } else {
          component.set("v.emailPopup", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Failed to Send Email"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      }
    });
    $A.enqueueAction(action);
  }
});
