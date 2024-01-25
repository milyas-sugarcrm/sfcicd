({
  doInit: function (component, event, helper) {
    var action = component.get("c.getRelatedOpportunityLineItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.RelatedOpportunityLineItems", response.getReturnValue());
      component.set("v.Size", response.getReturnValue().length);
      var response = response.getReturnValue();
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  openDeletePopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    component.set("v.deleteId", id_str);
    component.set("v.deletePopup", true);
  },

  closeDeletePopup: function (component, event, helper) {
    component.set("v.deleteId", 0);
    component.set("v.deletePopup", false);
  },
  editOpportunityProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemsMainComponent",
      navigate: "true",
      componentAttributes: {
        recordId: id_str
      }
    });
    newEvent.fire();
  },
  newButton: function (component, event, helper) {
    console.log("hello");
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:AddProductMainComponentTeamPhun",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId")
      }
    });
    newEvent.fire();
  },
  editOpportunityLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;

    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemsMainComponent",
      navigate: "true",
      componentAttributes: {
        recordId: id_str
      }
    });
    newEvent.fire();
  },
  editButton: function (component, event, helper) {
    console.log("Edit button ");
    console.log(event.getSource().get("v.value"));
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemsMainComponent",
      navigate: "true",
      componentAttributes: {
        recordId: event.getSource().get("v.value")
      }
    });
    newEvent.fire();
  },
  handleColumnsChange: function (cmp, event, helper) {
    helper.initColumnsWithActions(cmp, event, helper);
  },

  deleteOpportunityLineItem: function (component, event, helper) {
    var action = component.get("c.deleteOpportunityLineItemInDb");
    action.setParams({
      recid: component.get("v.deleteId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "OpportunityLineItem Deleted Successfully"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
          component.set("v.Spinner", true);

          $A.enqueueAction(component.get("c.doInit"));

          component.set("v.Spinner", false);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error in deleting OpportunityLineItem"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  }
});
