({
  doInit: function (component, event, helper) {
    if (component.get("v.recordId") != null) {
      component.set("v.Spinner", false);
      var action = component.get("c.getEstimateRelatedOpportunityLineItems");
      action.setParams({
        estId: component.get("v.recordId"),
        numOfrec: component.get("v.numOfRecords")
      });
      action.setCallback(this, function (response) {
        component.set(
          "v.EstimateRelatedOpportunityLineItems",
          response.getReturnValue()
        );
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action);

      var action3 = component.get("c.getOpportunityStage");
      action3.setParams({
        recid: component.get("v.recordId")
      });
      action3.setCallback(this, function (response) {
        if (
          response.getReturnValue() !== "Presentation" &&
          response.getReturnValue() !== "Need Analysis" &&
          response.getReturnValue() !== "Estimate"
        ) {
          console.log("in false: " + response.getReturnValue());
          component.set("v.SalesStage", true);
        } else {
          console.log("in true:" + response.getReturnValue());
          component.set("v.SalesStage", false);
        }
      });
      $A.enqueueAction(action3);

      var action2 = component.get("c.getCountOfEstimateOppLineItems");
      action2.setParams({
        estId: component.get("v.recordId")
      });
      action2.setCallback(this, function (response) {
        component.set("v.Size", response.getReturnValue());
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action2);

      var action5 = component.get("c.getOpportunityId");
      action5.setParams({
        recId: component.get("v.recordId")
      });
      action5.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS" && response.getReturnValue() !== "false") {
          component.set("v.oppId", response.getReturnValue());
        }
      });
      $A.enqueueAction(action5);

      var action6 = component.get("c.getNotSyncedEstimate");
      action6.setParams({
        recId: component.get("v.recordId")
      });
      action6.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS" && response.getReturnValue() !== "false") {
          component.set("v.ErrorEstimate", response.getReturnValue());
        }
      });
      $A.enqueueAction(action6);
    } // heletRelatedContacts(component);
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
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  },
  openDropdown: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='estimateDropdown']");
    for (var i = 0; i < elms.length; i++) {
      if (elms[i].style.display == "block") elms[i].style.display = "none";
      else elms[i].style.display = "block";
    }
  },
  closeDropdownAction: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='estimateDropdown']");
    for (var i = 0; i < elms.length; i++) {
      elms[i].style.display = "none";
    }
  },
  newButton: function (component, event, helper) {
    document.getElementById("estimateDropdown").style.display = "none";
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:AddProductMainComponentTeamPhun",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        recordFrom: "Estimate",
        opportunityId: component.get("v.oppId")
      }
    });
    newEvent.fire();
  },
  openPreviewEstimatePage: function (component, event, helper) {
    document.getElementById("estimateDropdown").style.display = "none";
    var action = component.get("c.getEstimatePreviewLink");
    action.setParams({
      recId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("url: " + response.getReturnValue());
        if (response.getReturnValue() !== "false") {
          console.log("url: " + response.getReturnValue());

          var urlEvent = $A.get("e.force:navigateToURL");
          urlEvent.setParams({
            url: response.getReturnValue()
          });
          urlEvent.fire();
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "No product exist in estimate to preview!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  deleteEstimate: function (component, event, helper) {
    document.getElementById("estimateDropdown").style.display = "none";
    component.set("v.Spinner", true);
    var action = component.get("c.deleteEstimates");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        if (response.getReturnValue() === true) {
          console.log("in true");

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Estimate Deleted Successfully"
          });
          toastEvent.fire();
          var refreshEvent1 = $A.get("e.c:RefreshPresentationComponent");
          refreshEvent1.fire();
          var refreshTabs1 = $A.get("e.c:RefreshTabs");
          refreshTabs1.fire();
          var appEvent1 = $A.get("e.c:applicationEvents");
          appEvent1.fire();
          component.set("v.Spinner", false);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "There is an issue deleting estimate2"
          });
          toastEvent.fire();
        }
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "There is an issue deleting estimate"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  syncEstimate: function (component, event, helper) {
    document.getElementById("estimateDropdown").style.display = "none";
    component.set("v.Spinner", true);
    var action = component.get("c.syncEstimates");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        if (response.getReturnValue() === true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Syncing started successfully"
          });
          toastEvent.fire();
          var refreshEvent1 = $A.get("e.c:RefreshPresentationComponent");
          refreshEvent1.fire();
          var refreshTabs1 = $A.get("e.c:RefreshTabs");
          refreshTabs1.fire();
          var appEvent1 = $A.get("e.c:applicationEvents");
          appEvent1.fire();
          component.set("v.Spinner", false);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "There is an issue syncing the estimate"
          });
          toastEvent.fire();
        }
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "There is an issue syncing the estimate"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  openSalesOrderPopup: function (component, event, helper) {
    document.getElementById("estimateDropdown").style.display = "none";
    var action = component.get("c.getOpportunityId");
    action.setParams({
      recId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        if (response.getReturnValue() !== "false") {
          component.set("v.oppId", response.getReturnValue());
          component.set("v.openConvertToSalesOrder", true);
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
  closeSalesOrderPopup: function (component, event, helper) {
    component.set("v.openConvertToSalesOrder", false);
  },
  editEstimateProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;

    var newEvent = $A.get("e.force:navigateToComponent");

    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemInEstimate",
      navigate: "true",
      componentAttributes: {
        recordId: id_str,
        opportunityId: component.get("v.oppId")
      }
    });
    newEvent.fire();
  },
  /*  editOpportunityProductLineItem : function (component, event, helper) {
         var ctarget = event.currentTarget;
         var id_str = ctarget.dataset.value;
        var newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "c:EditOpportunityLineItemsMainComponent",
           // componentDef : "c:ShippingMainComponent",
              //componentDef : "c:ConvertToEstimateMainComponent",
            "navigate" : "true",
            componentAttributes: {
                recordId : id_str
            }
        });
        newEvent.fire();
    },
    editOpportunityProductLineItem:function (component, event, helper) 
    {
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.value;
        
        var newEvent = $A.get("e.force:navigateToComponent");
             
        newEvent.setParams({
            componentDef: "c:EditOpportunityLineItemInEstimate",
            "navigate" : "true",
            componentAttributes: {
                recordId : id_str
            }
        });
        newEvent.fire();
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
    var action = component.get("c.deleteOpportunityLineItemInDb");
    action.setParams({
      estId: component.get("v.deleteId")
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
  },
  addArtworkComponent: function (component, event, helper) {
    console.log("Edit button ");
    console.log(event.getSource().get("v.value"));
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
      componentDef: "c:EstimateOppLineItem",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        viewAll: "false",
        numOfRecords: "8"
      }
    });
    newEvent.fire();
  }
});
