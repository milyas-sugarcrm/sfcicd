({
  onfocus: function (component, event, helper) {
    var forOpen = component.find("searchRes");
    $A.util.addClass(forOpen, "slds-is-open");
    $A.util.removeClass(forOpen, "slds-is-close");
    // Get Default 5 Records order by createdDate DESC
    var getInputkeyWord = "";
    helper.searchHelper(component, event, getInputkeyWord);
  },
  keyPressController: function (component, event, helper) {
    var getInputkeyWord = component.get("v.SearchKeyWord");
    if (getInputkeyWord.length > 0) {
      var forOpen = component.find("searchRes");
      $A.util.addClass(forOpen, "slds-is-open");
      $A.util.removeClass(forOpen, "slds-is-close");
      helper.searchHelper(component, event, getInputkeyWord);
    } else {
      component.set("v.listOfSearchRecords", null);
      var forclose = component.find("searchRes");
      $A.util.addClass(forclose, "slds-is-close");
      $A.util.removeClass(forclose, "slds-is-open");
    }
  },
  onblur: function (component, event, helper) {
    component.set("v.SearchKeyWord", null);
    component.set("v.listOfSearchRecords", null);
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
  },
  doAction: function (component, event) {
    var params = event.getParam("arguments");
    if (params) {
      var caction = component.get("c.getObjectRecord");
      caction.setParams({ objectname: params.Name, recid: params.RecId });
      caction.setCallback(this, function (resp) {
        var cstate = resp.getState();
        if (cstate === "SUCCESS") {
          component.set("v.selectedRecord", resp.getReturnValue());
          var forclose = component.find("lookup-pill");
          $A.util.addClass(forclose, "slds-show");
          $A.util.removeClass(forclose, "slds-hide");
          var forclose = component.find("searchRes");
          $A.util.addClass(forclose, "slds-is-close");
          $A.util.removeClass(forclose, "slds-is-open");
          var lookUpTarget = component.find("lookupField");
          $A.util.addClass(lookUpTarget, "slds-hide");
          $A.util.removeClass(lookUpTarget, "slds-show");
        }
      });
      $A.enqueueAction(caction);
    }
  },
  // function for clear the Record Selaction
  clear: function (component, event, heplper) {
    var pillTarget = component.find("lookup-pill");
    var lookUpTarget = component.find("lookupField");
    $A.util.addClass(pillTarget, "slds-hide");
    $A.util.removeClass(pillTarget, "slds-show");
    $A.util.addClass(lookUpTarget, "slds-show");
    $A.util.removeClass(lookUpTarget, "slds-hide");
    component.set("v.SearchKeyWord", null);
    component.set("v.supplierAdd", null);
    component.set("v.listOfSearchRecords", null);
    component.set("v.selectedRecord", {});
    component.set("v.searchIcon", true);
    // set the Selected sObject Record to the event attribute.
    try {
      var deletedRecord = component.get("v.dependentComponentId");
      var compEvent = component.getEvent("selectedRecordEvent");
      compEvent.setParams({ selectedRecordByEvent: deletedRecord });
      compEvent.fire();
    } catch (e) {}
  },

  // This function call when the end User Select any record from the result list.
  handleComponentEvent: function (component, event, helper) {
    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
    component.set("v.selectedRecord", selectedAccountGetFromEvent);
    var action = component.get("c.getAccountAddress");
    action.setParams({
      Recid: component.get("v.selectedRecord.Id")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      component.set("v.SelectedDecoratorAddress", response.getReturnValue());
      component.set("v.supplierAdd", response.getReturnValue());
    });
    $A.enqueueAction(action);

    var forclose = component.find("lookup-pill");
    $A.util.addClass(forclose, "slds-show");
    $A.util.removeClass(forclose, "slds-hide");
    var forclose = component.find("searchRes");
    $A.util.addClass(forclose, "slds-is-close");
    $A.util.removeClass(forclose, "slds-is-open");
    var lookUpTarget = component.find("lookupField");
    $A.util.addClass(lookUpTarget, "slds-hide");
    $A.util.removeClass(lookUpTarget, "slds-show");
    component.set("v.searchIcon", false);
    component.set("v.selectedDone", true);
  },
  hideSearchPanel: function (component, event, helper) {
    var forclose = component.find("searchRes");
  },
  hideSpinner: function (component, event, helper) {
    //var spinner = component.find('spinner');
    //var evt = spinner.get("e.toggle");
    //evt.setParams({ isVisible : false });
    //evt.fire();
  },
  // automatically call when the component is waiting for a response to a server request.
  showSpinner: function (component, event, helper) {
    //var spinner = component.find('spinner');
    //var evt = spinner.get("e.toggle");
    //evt.setParams({ isVisible : true });
    //evt.fire();
  },
  customClearData: function (component, event, helper) {
    var pillTarget = component.find("lookup-pill");
    var lookUpTarget = component.find("lookupField");
    $A.util.addClass(pillTarget, "slds-hide");
    $A.util.removeClass(pillTarget, "slds-show");
    $A.util.addClass(lookUpTarget, "slds-show");
    $A.util.removeClass(lookUpTarget, "slds-hide");
    component.set("v.SearchKeyWord", null);
    component.set("v.listOfSearchRecords", null);
    component.set("v.selectedRecord", {});
    component.set("v.searchIcon", true);
  },
  initalizeData: function (component, event, helper) {
    try {
      var recordId = component.get("v.selectedRecord");
      var objectName = component.get("v.objectAPIName");
      var caction = component.get("c.getObjectRecord");
      caction.setParams({ objectname: objectName, recid: recordId });
      caction.setCallback(this, function (resp) {
        var cstate = resp.getState();
        if (cstate === "SUCCESS") {
          component.set("v.selectedRecord", resp.getReturnValue());
          var forclose = component.find("lookup-pill");
          $A.util.addClass(forclose, "slds-show");
          $A.util.removeClass(forclose, "slds-hide");
          var forclose = component.find("searchRes");
          $A.util.addClass(forclose, "slds-is-close");
          $A.util.removeClass(forclose, "slds-is-open");
          var lookUpTarget = component.find("lookupField");
          $A.util.addClass(lookUpTarget, "slds-hide");
          $A.util.removeClass(lookUpTarget, "slds-show");
          component.set("v.searchIcon", false);
        }
      });
      $A.enqueueAction(caction);
    } catch (e) {}
  },
  doInit: function (component, event, helper) {
    $A.enqueueAction(action);
    var head = document.getElementsByTagName("head")[0];
    var link = document.createElement("link");
    link.href = "/resource/CustomComponentExtension";
    link.rel = "stylesheet";
    head.appendChild(link);
  }
});
