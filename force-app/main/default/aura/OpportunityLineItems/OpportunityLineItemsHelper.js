({
  getRelatedContacts: function (component) {
    var action = component.get("c.getRelatedOpportunityLineItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.RelatedOpportunityLineItems", response.getReturnValue());
      console.log(response.getReturnValue());
      console.log("response.getReturnValue()");
      if (response.getReturnValue() != null) {
        component.set("v.Size", response.getReturnValue().length);
      } else {
        component.set("v.Size", "0");
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  gotoRelatedList: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:RelatedContactsListView",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId")
      }
    });
    newEvent.fire();
  }
});
