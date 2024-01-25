({
  doInit: function (component, event, helper) {
    // will contain the updated data;
    window.recordData = {};

    if (component.get("v.salesOrderId") != null) {
      component.set("v.Spinner", false);
      component.set("v.RecordId", "v.salesOrderId");
      var action = component.get("c.getSalesOrderRelatedOpportunityLineItems");
      action.setParams({
        salesId: component.get("v.salesOrderId"),
        numOfrec: component.get("v.numOfRecords")
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          console.log("Return Value of opp line item is : ");
          console.log(response.getReturnValue());
          component.set(
            "v.SalesOrderRelatedOpportunityLineItems",
            response.getReturnValue()
          );
          component.set("v.Spinner", false);
        } else {
          alert("Error occured!");
        }
      });
      $A.enqueueAction(action);

      var action2 = component.get("c.getCountOfSalesOrderOppLineItems");
      action2.setParams({
        salesId: component.get("v.salesOrderId")
      });
      action2.setCallback(this, function (response) {
        component.set("v.Size", response.getReturnValue());
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action2);

      var action3 = component.get("c.getSalesOrderSyncStatus");
      action3.setParams({
        salesId: component.get("v.salesOrderId")
      });
      action3.setCallback(this, function (response) {
        component.set("v.SalesOrderSynced", response.getReturnValue());
      });
      $A.enqueueAction(action3);

      const empApi = component.find("empApi");
      const channel = component.get("v.channel");
      const replayId = -1;
      const callback = function (message) {
        if (
          message["data"].payload.SyncAlertMessage__c ===
          'Please synchronize the Sales Order with Quickbooks using "Sync Sales Order" in Actions'
        ) {
          component.set(
            "v.SalesOrderSynced",
            message["data"].payload.SyncAlertMessage__c
          );
        }
      };
      // Subscribe to the channel and save the returned subscription object.
      empApi.subscribe(channel, replayId, $A.getCallback(callback)).then(
        $A.getCallback(function (newSubscription) {
          component.set("v.subscription", newSubscription);
        })
      );
    }
  },
  openDropdown: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='salesOrderDropdown']");
    for (var i = 0; i < elms.length; i++) {
      if (elms[i].style.display == "block") elms[i].style.display = "none";
      else elms[i].style.display = "block";
    }
  },
  closeDropdownAction: function (component, event, helper) {
    var elms = document.querySelectorAll("[id='salesOrderDropdown']");
    for (var i = 0; i < elms.length; i++) {
      elms[i].style.display = "none";
    }
  },
  openPreviewSalesOrderPage: function (component, event, helper) {
    document.getElementById("salesOrderDropdown").style.display = "none";
    var action = component.get("c.getSalesOrderPreviewLink");
    action.setParams({
      recId: component.get("v.salesOrderId")
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
            message: "No product exist in sales order to preview!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  openDepositInvoicePopup: function (component, event, helper) {
    document.getElementById("salesOrderDropdown").style.display = "none";
    component.set("v.openDepositInvoice", true);
  },
  closeDepositInvoicePopup: function (component, event, helper) {
    component.set("v.openDepositInvoice", false);
  },
  editSalesOrderProductLineItem: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;

    var newEvent = $A.get("e.force:navigateToComponent");

    newEvent.setParams({
      componentDef: "c:EditOpportunityLineItemSalesorder",
      navigate: "true",
      componentAttributes: {
        recordId: id_str,
        opportunityId: component.get("v.opportunityId")
      }
    });
    newEvent.fire();
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
  deleteOpportunityLineItem: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.deleteOpportunityLineItemInDb");
    action.setParams({
      salesId: component.get("v.deleteId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      console.log(state);
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
            message: "Error in deleting Product"
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
  gotoRelatedList: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:SalesOrderOppLineItem",
      navigate: "true",
      componentAttributes: {
        salesOrderId: component.get("v.salesOrderId"),
        viewAll: "false",
        numOfRecords: "8"
      }
    });
    newEvent.fire();
  },
  getDepositComponent: function (component, event, helper) {
    var evt = $A.get("e.force:navigateToComponent");
    evt.setParams({
      componentDef: "c:OpportunitySalesOrderDepositInvoice",
      componentAttributes: {
        recordId: component.get("v.salesOrderId")
      }
    });
    evt.fire();
  },
  // to open add new product component
  newButton: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:AddProductMainComponentForWO",
      navigate: "true",
      componentAttributes: {
        workOrderId: component.get("v.salesOrderId"),
        //recordId : component.get('v.recordId'),
        recordFrom: "SalesOrder",
        opportunityId: component.get("v.opportunityId")
      }
    });
    var test = newEvent.fire();
    console.log("22222222222222222222222222222222222222222222222");
    console.log(test);
    /*var action = component.get("c.getSalesOrderSyncStatus");
        action.setParams({
            "salesId" : component.get("v.salesOrderId")
        });
        action.setCallback(this, function(response){
            component.set("v.SalesOrderSynced", response.getReturnValue());
        });
        $A.enqueueAction(action);
        console.log('333333333333333333333333333333333333333333333333333');
        */
  },

  /*
    This function will call on every focus out of lightning input
     and will prepare the JSON data for update.
   */

  inLineEditSaleOrder: function (component, event, helper) {
    var component_ids = event.getSource().getLocalId();
    var component_ids_arr = component_ids.split(",");
    var objectName = component_ids_arr[0];
    var fieldToUpdate = component_ids_arr[1];
    var record_id = event.getSource().get("v.name");
    var record_value = event.getSource().get("v.value");

    if (!record_value) {
      if (fieldToUpdate == "Description__c" || fieldToUpdate == "Title__c") {
        record_value = "";
      } else {
        record_value = "0";
      }
    }

    if (window.recordData[objectName] == undefined) {
      window.recordData[objectName] = {};
    }
    if (window.recordData[objectName][record_id] == undefined) {
      window.recordData[objectName][record_id] = {};
    }
    if (window.recordData[objectName][record_id][fieldToUpdate] == undefined) {
      window.recordData[objectName][record_id][fieldToUpdate] = {};
    }
    window.recordData[objectName][record_id][fieldToUpdate] = record_value;
  },

  /*
    This function will call aura enabled function 'updateSaleOrderInlineEdit'
    and will update the product and their pricing data.
   */

  UpdateSaleOrder: function (component, event, helper) {
    var data = component.get("v.SalesOrderRelatedOpportunityLineItems");
    for (let i = 0; i < data.length; i++) {
      window.recordData["workOrderId"] = data[i]["workOrderId"];
    }
    var action = component.get("c.updateSaleOrderInlineEdit");
    action.setParams({
      recordData: JSON.stringify(window.recordData)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        window.recordData = {};
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          type: "Success",
          message: "The record has been updated successfully."
        });
        toastEvent.fire();
        var reInit = component.get("c.doInit");
        $A.enqueueAction(reInit);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Failure!",
          type: "Failure",
          message: "Error while updating the record."
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },

  /*
   * This function will update the Bill related to the SalesOrder
   */
  syncSalesOrder: function (component, event, helper) {
    var action = component.get("c.syncSalesOrders");
    action.setParams({
      workOrderId: component.get("v.salesOrderId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        console.log("url: " + response.getReturnValue());
        if (response.getReturnValue() !== "false") {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Sales Order has been sent for sync!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
          var reInit = component.get("c.doInit");
          $A.enqueueAction(reInit);

          //Unsubscribe from  channel on success sync.
          const empApi = component.find("empApi");
          const channel = component.get("v.subscription").channel;
          const callback = function (message) {
            console.log("Unsubscribed from channel " + message.channel);
          };
          empApi.unsubscribe(
            component.get("v.channel"),
            $A.getCallback(callback)
          );
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Sales Order could not be synced!"
          });
          toastEvent.fire();
          $A.get("e.force:closeQuickAction").fire();
        }
      } else if (state === "ERROR") {
        var errors = response.getError();
        if (errors) {
          if (errors[0] && errors[0].message) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Error",
              message: errors[0].message
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
          }
        }
      }
    });
    $A.enqueueAction(action);
  }
});
