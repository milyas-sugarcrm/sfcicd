({
  doInit: function (component, event, helper) {
    // Log oppId to the console
    const opportunityId = component.get("v.recordId");
    component.set("v.opportunityId", opportunityId);
    console.log("Opportunity Id:", opportunityId);

    // Call the server-side action to send the SOW
    const action = component.get("c.generateSowPdfHandler");
    action.setParams({ oppId: opportunityId });

    action.setCallback(this, (response) => {
      const state = response.getState();
      if (state === "SUCCESS") {
        const result = response.getReturnValue();
        this.showToast(component, "success", "SOW Generated successfully!");

        // Perform any additional actions based on the response
        if (result.success) {
          helper.navigateToOpportunity(component);
        }
        this.redirectToDetailPage(component);
      } else if (state === "ERROR") {
        // Handle errors
        this.handleErrors(response);
      }
    });

    $A.enqueueAction(action);
  },

  // Show toast messages for Aura component
  showToast: function (component, variant, message) {
    const toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: "Generate SOW",
      message: message,
      type: variant
    });
    toastEvent.fire();
  },

  // Handle errors and display error messages
  handleErrors: function (response) {
    this.showToast(component, "error", "Failed to send SOW!");
    const errors = response.getError();
    if (errors) {
      errors.forEach((error) =>
        console.error("Error message: " + error.message)
      );
    }
  },

  // Navigate to Record view of Opportunity
  redirectToDetailPage: function (component) {
    const navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId"),
      slideDevName: "detail"
    });
    navEvt.fire();
  }
});
