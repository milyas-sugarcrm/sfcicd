({
  showWarningPopup: function (component, event, helper) {
    var cmpDiv = component.find("popupclassId");
    $A.util.addClass(cmpDiv, "popupclassUpdated");
    component.set("v.accountSelected", event.getParam("selectedAccount"));
    component.set("v.showWarningPopup", true);
  },
  convertToestimateInchild: function (component, event, helper) {
    component.set("v.showWarningPopup", false);
    var appEvent = $A.get("e.c:convertToEstimate");
    appEvent.fire();
  },
  closeWarningPopup: function (component, event, helper) {
    component.set("v.showWarningPopup", false);
    var a = component.get("c.openEstimatePopup");
    $A.enqueueAction(a);
    var cmpDiv = component.find("popupclassId");
    $A.util.removeClass(cmpDiv, "popupclassUpdated");
  },
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action0 = component.get("c.checkEstimateExists");
    action0.setParams({
      recid: component.get("v.recordId")
    });
    action0.setCallback(this, function (response) {
      //  alert("response.getReturnValue() "+response.getReturnValue());
      component.set("v.estimateExist", response.getReturnValue());
    });
    $A.enqueueAction(action0);

    var action3 = component.get("c.getOpportunityStage");
    action3.setParams({
      recId: component.get("v.recordId")
    });
    action3.setCallback(this, function (response) {
      if (
        response.getReturnValue() === "Needs Analysis" ||
        response.getReturnValue() === "Send SOW" ||
        response.getReturnValue() === "Closed Won" ||
        response.getReturnValue() === "Closed Lost"
      ) {
        var elms = document.querySelectorAll("[id='actionsButton']");
        for (var i = 0; i < elms.length; i++) {
          elms[i].disabled = true;
        }
      } else {
        var elms = document.querySelectorAll("[id='actionsButton']");
        for (var i = 0; i < elms.length; i++) {
          elms[i].disabled = false;
        }
      }
      if (response.getReturnValue() === "Prepare SOW") {
        var elms = document.querySelectorAll("[id='addProductOption']");
        for (var i = 0; i < elms.length; i++) {
          elms[i].style.display = "block";
        }
      } else {
        var elms = document.querySelectorAll("[id='addProductOption']");
        for (var i = 0; i < elms.length; i++) {
          elms[i].style.display = "none";
        }
      }
      if (
        response.getReturnValue() !== "Presentation" &&
        response.getReturnValue() !== "Needs Analysis"
      ) {
        component.set("v.estimateStage", true);
      } else {
        component.set("v.estimateStage", false);
      }
    });
    $A.enqueueAction(action3);
    var action = component.get("c.getRelatedOpportunityLineItemsPfa");
    action.setParams({
      recid: component.get("v.recordId"),
      numOfrec: component.get("v.numOfRecords")
    });
    action.setCallback(this, function (response) {
      component.set(
        "v.RelatedOpportunityLineItemsPfa",
        response.getReturnValue()
      );
    });
    $A.enqueueAction(action);

    var action2 = component.get("c.getCountOfOpportunityLineItemsPfa");
    action2.setParams({
      recid: component.get("v.recordId")
    });
    action2.setCallback(this, function (response) {
      component.set("v.Size", response.getReturnValue());
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action2);

    // helper.getRelatedContacts(component);
    var OrgId = component.get("v.recordId") + "";

    //Create head tag dynamically
    var head = document.getElementsByTagName("head")[0];

    //Create link or script tag dynamically
    var link = document.createElement("link");

    //Add appropriate attributes
    link.href = "/resource/CustomComponentExtensionArrow";
    link.rel = "stylesheet";

    head.appendChild(link);
  },
  openDropdown: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='dropdown']");
    for (var i = 0; i < elms.length; i++) {
      if (elms[i].style.display == "block") elms[i].style.display = "none";
      else elms[i].style.display = "block";
    }
  },
  closeDropdownAction: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='dropdown']");
    for (var i = 0; i < elms.length; i++) {
      elms[i].style.display = "none";
    }
  },
  newButton: function (component, event, helper) {
    document.getElementById("dropdown").style.display = "none";
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:AddProductMainComponentPfa",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        recordFrom: "Opportunity",
        opportunityId: component.get("v.recordId")
      }
    });
    newEvent.fire();
  },
  openEstimatePopup: function (component, event, helper) {
    document.getElementById("dropdown").style.display = "none";
    var action = component.get("c.getPresentationPreviewLink");
    action.setParams({
      recId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        component.set("v.openConvertToEstimate", true);
      }
    });
    $A.enqueueAction(action);
  },
  closeEstimatePopup: function (component, event, helper) {
    component.set("v.openConvertToEstimate", false);
  },
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  },
  openPreviewPresentationPage: function (component, event, helper) {
    document.getElementById("dropdown").style.display = "none";
    var action = component.get("c.getPresentationPreviewLink");
    action.setParams({
      recId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        if (response.getReturnValue() !== "false") {
          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url: response.getReturnValue()
          });
          urlEvent.fire();
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "No product exist!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      }
    });
    $A.enqueueAction(action);
  },

  callSave: function (component, event, helper) {
    var shippingComp = component.find("shippingMainComponent");
    shippingComp.callShippingSave();
  },

  editOpportunityLineItem: function (component, event, helper) {
    debugger;
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var newEvent = $A.get("e.force:navigateToComponent");

    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemsPfaMainComponent",
      navigate: "true",
      componentAttributes: {
        recordId: id_str,
        opportunityId: component.get("v.recordId")
      }
    });

    newEvent.fire();
  },
  editOpportunityProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemsMainComponent",

      navigate: "true",
      componentAttributes: {
        recordId: id_str,
        opportunityId: component.get("v.recordId")
      }
    });
    newEvent.fire();
  },
  /*    editOpportunityProductLineItem:function (component, event, helper) 
    {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        component.set("v.shippingRecordId",id_str);          
        component.set("v.shippingPopup",true);  
    },*/
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

  closeShippingPopup: function (component, event, helper) {
    component.set("v.shippingRecordId", 0);
    component.set("v.shippingPopup", false);
  },
  deleteOpportunityLineItem: function (component, event, helper) {
    component.set("v.DeleteSpinner", true);
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
            message: "Product Deleted Successfully"
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
            message: "Error in deleting product"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
        }
      } else {
      }
      component.set("v.DeleteSpinner", false);
    });
    $A.enqueueAction(action);
  },
  addArtworkComponent: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemArtWorkComponent",
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

  gotoRelatedList: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:OpportunityLineItemsPfa",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        viewAll: "false",
        numOfRecords: "8"
      }
    });
    newEvent.fire();
  },
  openClonePopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    component.set("v.cloneId", id_str);
    component.set("v.clonePopup", true);
  },
  closeClonePopup: function (component, event, helper) {
    component.set("v.cloneId", 0);
    component.set("v.clonePopup", false);
  },

  cloneOpportunityLineItem: function (component, event, helper) {
    component.set("v.cloneSpinner", true);
    var action = component.get("c.cloneOpportunityLineItemInDB");
    action.setParams({
      recId: component.get("v.cloneId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Product Cloned Successfully"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeClonePopup"));
          $A.enqueueAction(component.get("c.doInit"));
          component.set("v.cloneSpinner", false);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Error in cloning product"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeClonePopup"));
        }
      } else {
      }
      component.set("v.cloneSpinner", false);
    });
    $A.enqueueAction(action);
  }
});
