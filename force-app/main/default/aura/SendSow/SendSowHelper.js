({
  /*
   * Call sendSowProcess after some pre-requisites
   * check and show respective toast messages
   */
  processSendSow: function (component) {
    var stageName = component.get("v.stageName");
    var pandaDocId = component.get("v.pandaDocId");

    if (!pandaDocId) {
      this.showToast(
        component,
        "error",
        "No SOW Document found, Please generate SOW document first."
      );
      this.redirectToDetailPage(component);
      return;
    }

    if (pandaDocId && stageName === "Closed Won") {
      this.showToast(component, "error", "Opportunity is Closed Won.");
      this.redirectToDetailPage(component);
      return;
    }

    var action = component.get("c.sendSowProcess");
    action.setParams({
      pandaDocId: pandaDocId,
      oppId: component.get("v.recordId"),
      awsFileName: component.get("v.awsFileName")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        this.showToast(component, "success", "SOW sent successfully!");
      } else {
        this.showToast(component, "error", "Failed to send SOW!");
      }
      this.redirectToDetailPage(component);
    });
    $A.enqueueAction(action);
  },

  /*
   * Show toast messages for aura
   * component
   */
  showToast: function (component, variant, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Send SOW",
      message: message,
      type: variant
    });
    toastEvent.fire();
  },

  /*
   * Navigate to Record view of Opportunity
   */
  redirectToDetailPage: function (component) {
    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId"),
      slideDevName: "detail"
    });
    navEvt.fire();
  }
});
