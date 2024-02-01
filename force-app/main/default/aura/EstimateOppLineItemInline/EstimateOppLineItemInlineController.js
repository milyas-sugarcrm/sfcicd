({
  dragOppLineItem: function (component, event, helper) {
    document.getElementById(
      event.currentTarget.dataset.value + "-draggable"
    ).style.backgroundColor = "#D3D3D3";
    event.dataTransfer.setData("text", event.target.id);
    component.set("v.index", event.target.name);
  },

  dropOppLineItem: function (component, event, helper) {
    var data = event.dataTransfer.getData("text");
    var index = component.get("v.index");
    // Find the record ID by crawling up the DOM hierarchy
    var tar = event.target.closest("[id]");
    var estLineItems = component.get("v.EstimateRelatedOpportunityLineItems");
    var breakdown = estLineItems[index].estimateInlineList;
    var index1, index2, temp;
    // Find the index of each item to move
    breakdown.forEach((v, i) => {
      if (v.Id === data) index1 = i;
      if (v.Id === tar.id) index2 = i;
    });
    if (index1 < index2) {
      // Lower index to higher index; we move the lower index first, then remove it.
      breakdown.splice(index2 + 1, 0, breakdown[index1]);
      breakdown.splice(index1, 1);
    } else {
      // Higher index to lower index; we remove the higher index, then add it to the lower index.
      temp = breakdown.splice(index1, 1)[0];
      breakdown.splice(index2, 0, temp);
    }
    // Trigger aura:valueChange, component will rerender
    estLineItems[index].estimateInlineList = breakdown;
    for (var i = 0; i < estLineItems[index].estimateInlineList.length; i++) {
      estLineItems[index].estimateInlineList[i].index = i;
    }
    component.set("v.EstimateRelatedOpportunityLineItems", estLineItems);

    $A.enqueueAction(component.get("c.saveIndexValues"));

    event.preventDefault();
  },
  saveIndexValues: function (component, event, helper) {
    component.set("v.Spinner", true);
    var estLineItems = component.get("v.EstimateRelatedOpportunityLineItems");
    var index = component.get("v.index");

    var action = component.get("c.updateTheIndexOfRecords");
    action.setParams({
      recordsObjectList: JSON.stringify(estLineItems[index].estimateInlineList),
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        component.set(
          "v.EstimateRelatedOpportunityLineItems",
          response.getReturnValue()
        );
        console.log(
          "Credit valuesssssssssssssss: " + response.getReturnValue()
        );
        component.set("v.Spinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  checkValidCredits: function (component, event, helper) {
    //  debugger;
    if (component.get("v.recordId") != null) {
      var action1 = component.get("c.getEstimateRelatedOpportunityLineItems");
      action1.setParams({
        estId: component.get("v.recordId"),
        numOfrec: component.get("v.numOfRecords")
      });

      action1.setCallback(this, function (response) {
        var values = response.getReturnValue();
        component.set("v.validCredits", true);
        if (values != null) {
          for (var i = 0; i < values.length; i++) {
            if (values[i] != null) {
              for (var j = 0; j < values[i].estimateInlineList.length; j++) {
                if (
                  values[i].estimateInlineList[j].isCreditAvailable == false
                ) {
                  component.set("v.validCredits", false);
                  break;
                }
              }
            }
          }
        }
      });
      $A.enqueueAction(action1);
    }
  },

  doInit: function (component, event, helper) {
    window.recordData = {};
    if (component.get("v.recordId") != null) {
      component.set("v.Spinner", true);
      var action1 = component.get("c.getEstimateRelatedOpportunityLineItems");
      action1.setParams({
        estId: component.get("v.recordId"),
        numOfrec: component.get("v.numOfRecords")
      });
      action1.setCallback(this, function (response) {
        component.set(
          "v.EstimateRelatedOpportunityLineItems",
          response.getReturnValue()
        );
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action1);

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
          component.set("v.SalesStage", true);
        } else {
          component.set("v.SalesStage", false);
        }
      });
      $A.enqueueAction(action3);

      ///////////////////////////////////////////////////////

      var getSyncedAccountNameAction = component.get("c.getSyncedAccountName");
      getSyncedAccountNameAction.setParams({
        estId: component.get("v.recordId")
      });
      getSyncedAccountNameAction.setCallback(this, function (response) {
        component.set("v.selectedQBOInstance", response.getReturnValue());
      });
      $A.enqueueAction(getSyncedAccountNameAction);

      ///////////////////////////////////////////////////////
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

      var action7 = component.get("c.getEstimateStatus");
      action7.setParams({
        recId: component.get("v.recordId")
      });
      action7.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS" && response.getReturnValue() !== null) {
          component.set("v.EstimateStatus", response.getReturnValue()[1]);
          component.set("v.EstimateLink", response.getReturnValue()[0]);
        }
      });
      $A.enqueueAction(action7);
      $A.enqueueAction(component.get("c.checkValidCredits"));
    }
  },
  disableInputs: function (component, event, helper) {
    if (component.get("v.SalesStage") === "true") {
      var elms = document.querySelectorAll("[class='disable']");
      for (var i = 0; i < elms.length; i++) {
        elms[i].disabled = true;
      }
    }
  },
  doView: function (component, event, helper) {
    var editRecordEvent = $A.get("e.force:navigateToSObject");
    editRecordEvent.setParams({
      recordId: event.target.id
    });
    editRecordEvent.fire();
  },
  allowDrop: function (component, event, helper) {
    event.preventDefault();
  },
  breakDownValueChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var keysArray = updateKey.split(",");
    var objectName = keysArray[0];
    var fieldToUpdate = keysArray[1];
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");

    if (!updatedValue) {
      if (fieldToUpdate != "name") {
        updatedValue = "0";
      } else {
        updatedValue = "";
      }
    }
    if (window.recordData[objectName] == undefined) {
      window.recordData[objectName] = {};
    }
    if (window.recordData[objectName][idValue] == undefined) {
      window.recordData[objectName][idValue] = {};
    }
    if (window.recordData[objectName][idValue][fieldToUpdate] == undefined) {
      window.recordData[objectName][idValue][fieldToUpdate] = {};
    }
    window.recordData[objectName][idValue][fieldToUpdate] = updatedValue;
  },
  updateEstimateOppLineItemInline: function (component, event, helper) {
    var action = component.get("c.updateEstimatesOppLineItemInline");
    action.setParams({
      recordData: JSON.stringify(window.recordData)
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          type: "Success",
          message: "The record has been updated successfully."
        });
        toastEvent.fire();
        var a = component.get("c.updateTotalAmount");
        $A.enqueueAction(a);
        var b = component.get("c.updateErrorMeesage");
        $A.enqueueAction(b);
        var reInit = component.get("c.doInit");
        $A.enqueueAction(reInit);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Failure!",
          type: "Error",
          message: "Error while updating the record."
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  updateTotalAmount: function (component, event, helper) {
    var action = component.get("c.getOpportunityAmountValue");
    action.setParams({
      estId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.AmountTotal", response.getReturnValue());
    });
    $A.enqueueAction(action);
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
    console.log("dsfsdfs");
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
          component.set("v.deleteEstimatePopup", false);
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
            message: "Estimate synced started successfully"
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
    if (component.get("v.EstimateStatus") != "Estimate is Approved. ") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Estimate is not approved by client"
      });
      toastEvent.fire();
      $A.get("e.force:closeQuickAction").fire();
    } else {
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
    }
  },

  invalidCreditsToast: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "Error",
      message: "Credits are not valid!"
    });
    toastEvent.fire();
  },
  /*
    closeCreditsPopup: function (component, event, helper)
    {
        console.log('valid credit popup is false '  );
        component.set("v.validCreditsPopup",false); 
    },
    */

  closeSalesOrderPopup: function (component, event, helper) {
    component.set("v.openConvertToSalesOrder", false);
  },
  pricingvaluesChanged: function (component, event, helper) {
    component.set("v.Spinner", true);
    var updateKey = event.getSource().getLocalId();
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");

    helper.calculateAndUpdatePricingRecord(
      component,
      updatedValue,
      updateKey,
      idValue
    );
  },
  ////////////////////////////
  openDeleteEstimatePopup: function (component, event, helper) {
    component.set("v.deleteEstimatePopup", true);
  },
  closeDeleteEstimatePopup: function (component, event, helper) {
    component.set("v.Spinner", false);
    component.set("v.deleteEstimatePopup", false);
  },
  ////////////////////////////
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
  addSubtotal: function (component, event, helper) {
    component.set("v.Spinner", true);
    var id_str = event.getSource().get("v.name");
    if (event.getSource().get("v.checked")) {
      var elements = document.getElementsByClassName(id_str);
      elements[0].style.display = "none";
      var x = document.getElementsByClassName(id_str);
      var i;
      for (i = 0; i < x.length; i++) {
        x[i].style.display = "block";
      }
    } else {
      var elements = document.getElementsByClassName(id_str);
      elements[0].style.display = "block";
      var x = document.getElementsByClassName(id_str);
      var i;
      for (i = 0; i < x.length; i++) {
        x[i].style.display = "none";
      }
    }

    var action5 = component.get("c.saveToggleState");

    action5.setParams({
      recId: event.getSource().get("v.name"),
      objectName: event.getSource().get("v.value"),
      state: event.getSource().get("v.checked")
    });
    action5.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS" && response.getReturnValue() !== "false") {
        $A.enqueueAction(component.get("c.doInit"));
      } else {
        component.set("v.Spinner", false);
      }
    });
    $A.enqueueAction(action5);

    //Subtotal_Toggle__c
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

  closeShippingPopup: function (component, event, helper) {
    component.set("v.shippingRecordId", 0);
    component.set("v.shippingPopup", false);
  },
  deleteOpportunityLineItem: function (component, event, helper) {
    component.set("v.DeleteSpinner", true);
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
            message: "Product deleted successfully"
          });
          toastEvent.fire();
          $A.enqueueAction(component.get("c.closeDeletePopup"));
          var b = component.get("c.updateErrorMeesage");
          $A.enqueueAction(b);

          $A.enqueueAction(component.get("c.doInit"));
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

  updateTimeOfLastChange: function (component, event, helper) {
    var currentdate = new Date();
    var datetime =
      currentdate.getMonth() +
      1 +
      "/" +
      currentdate.getDate() +
      "/" +
      currentdate.getFullYear() +
      " @ " +
      currentdate.getHours() +
      ":" +
      currentdate.getMinutes() +
      ":" +
      currentdate.getSeconds();
    component.set("v.lastModifiedDate", datetime);
  },
  addDefaultRowAtTheEnd: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var action = component.get("c.addDefaultPricingRow");
    action.setParams({
      recId: id_str
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != null) {
        $A.get("e.force:refreshView").fire();
        var a = component.get("c.updateTimeOfLastChange");
        $A.enqueueAction(a);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
  },

  updateErrorMessage: function (component, event, helper) {
    component.set(
      "v.message",
      "Changes cannot be saved. Kindly contact your administrator"
    );
  },

  handleColumnsChange: function (cmp, event, helper) {
    helper.initColumnsWithActions(cmp, event, helper);
  },
  openAddSizeColorPopup: function (component, event, helper) {
    component.set("v.selectedColor", event.getSource().get("v.value"));
    component.set("v.selectedColorId", event.getSource().get("v.name"));
    component.set("v.addSizeColorPopup", true);
  },
  closeAddSizeColorPopup: function (component, event, helper) {
    component.set("v.addSizeColorPopup", false);
  },
  addColor: function (component, event, helper) {
    component.set("v.Spinner", true);

    var color = component.find("colorAddField").get("v.value");
    if (!color) {
      component.set("v.Spinner", false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please enter value"
      });
      toastEvent.fire();
    } else {
      component.find("colorAddField").set("v.value", null);
      var idValue = component.get("v.selectedColorId");
      var listValues = component.get("v.colorList");
      var isExist = false;
      for (var i = 0; i < listValues.length; i++) {
        if (listValues[i].value.toUpperCase() == color.toUpperCase()) {
          isExist = true;
          break;
        }
      }
      if (isExist) {
        component.set("v.Spinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Color already exists!"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.addColorInDb");

        action.setParams({
          recId: idValue,
          color: color,
          estimateId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            component.set("v.Spinner", false);
            if (response.getReturnValue() == true) {
              helper.fetchColorsValues(component, event, helper);
            } else {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "There is an error adding new color"
              });
              toastEvent.fire();
              $A.get("e.force:refreshView").fire();
            }
          } else {
            component.set("v.Spinner", false);
            console.log("Failed with state: " + state);
          }
        });
        $A.enqueueAction(action);
        component.find("colorAddfield").set("v.value", "");
      }
    }
  },
  openUpdateSizePopup: function (component, event, helper) {
    component.set("v.addSizeColorPopup", false);
    helper.fetchSizeValues(component, event, helper);
    component.set("v.updateSizePopup", true);
  },
  closeUpdateSizePopup: function (component, event, helper) {
    component.set("v.updateSizePopup", false);
  },
  openUpdateColorPopup: function (component, event, helper) {
    component.set("v.addSizeColorPopup", false);
    helper.fetchColorsValues(component, event, helper);
    component.set("v.updateColorPopup", true);
  },
  closeUpdateColorPopup: function (component, event, helper) {
    component.set("v.updateColorPopup", false);
  },
  addSize: function (component, event, helper) {
    component.set("v.Spinner", true);
    var size = component.find("sizeAddField").get("v.value");
    if (!size) {
      component.set("v.Spinner", false);
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please enter value"
      });
      toastEvent.fire();
    } else {
      var idValue = component.get("v.selectedColorId");
      var listValues = component.get("v.sizeList");
      var isExist = false;
      for (var i = 0; i < listValues.length; i++) {
        if (listValues[i].value.toUpperCase() == size.toUpperCase()) {
          isExist = true;
          break;
        }
      }
      if (isExist) {
        component.set("v.Spinner", false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Size already exists!"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.addSizeInDb");

        action.setParams({
          recId: idValue,
          size: size
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          component.set("v.Spinner", false);
          if (state === "SUCCESS") {
            component.set("v.Spinner", false);
            if (response.getReturnValue() == true) {
              helper.fetchSizeValues(component, event, helper);
            } else {
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                type: "Error",
                message: "There is an error adding new size"
              });
              toastEvent.fire();
              $A.get("e.force:refreshView").fire();
            }
          } else {
            console.log("Failed with state: " + state);
          }
        });
        $A.enqueueAction(action);
        component.find("sizeAddField").set("v.value", "");
      }
    }
  },
  handleColorChange: function (component, event, helper) {
    //Get the Selected values
    var selectedValues = event.getParam("value");

    //Update the Selected Values

    var selectedColor = component.get("v.selectedColorList");
    if (selectedColor != null) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Move " + selectedColor + "back to available list first!"
      });
      toastEvent.fire();
    } else {
      component.set("v.selectedColorList", selectedValues);
    }
  },
  handleSizeChange: function (component, event, helper) {
    //Get the Selected values
    var selectedValues = event.getParam("value");

    //Update the Selected Values
    component.set("v.selectedSizeList", selectedValues);
  },
  saveSelectedSize: function (component, event, helper) {
    //Get selected Genre List on button click
    component.set("v.Spinner", true);
    var selectedValues = component.get("v.selectedSizeList");
    var action = component.get("c.updateSize");
    var idValue = component.get("v.selectedColorId");
    action.setParams({
      recId: idValue,
      size: selectedValues,
      estimateId: component.get("v.recordId"),
      numOfrec: component.get("v.numOfRecords")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      component.set("v.Spinner", false);
      if (state === "SUCCESS") {
        if (response.getReturnValue() != null) {
          component.set("v.updateSizePopup", false);
          var recordToUpdate = component.get("v.selectedColorId");
          component.set(
            "v.EstimateRelatedOpportunityLineItems",
            response.getReturnValue()
          );

          var b = component.get("c.updateErrorMeesage");
          $A.enqueueAction(b);
          //helper.populateSizes(component, event, helper);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "There is an error saving Size"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },

  saveSelectedColor: function (component, event, helper) {
    //Get selected Genre List on button click
    component.set("v.Spinner", true);
    var selectedValues = component.get("v.selectedColorList");
    var action = component.get("c.updateColor");
    var idValue = component.get("v.selectedColorId");
    action.setParams({
      recId: idValue,
      color: selectedValues,
      estimateId: component.get("v.recordId"),
      numOfrec: component.get("v.numOfRecords")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.Spinner", false);
        if (response.getReturnValue() != null) {
          component.set("v.updateColorPopup", false);
          var recordToUpdate = component.get("v.selectedColorId");
          component.set(
            "v.EstimateRelatedOpportunityLineItems",
            response.getReturnValue()
          );
          var b = component.get("c.updateErrorMeesage");
          $A.enqueueAction(b);
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "There is an error saving color"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  updateErrorMeesage: function (component, event, helper) {
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
  },

  gotoRelatedList: function (component, event, helper) {
    var newEvent = $A.get("e.force:navigateToComponent");
    newEvent.setParams({
      componentDef: "c:EstimateOppLineItemInline",
      navigate: "true",
      componentAttributes: {
        recordId: component.get("v.recordId"),
        viewAll: "false",
        numOfRecords: "8"
      }
    });
    newEvent.fire();
  },
  openHistoryPopup: function (component, event, helper) {
    component.set("v.changeHistoryPopup", true);
  },
  closeHistoryPopup: function (component, event, helper) {
    component.set("v.changeHistoryPopup", false);
  },
  openClonePopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    console.log("id_str>>>>>>>>>>", id_str);
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
        console.log("Failed with state: " + state);
      }
      component.set("v.cloneSpinner", false);
    });
    $A.enqueueAction(action);
  }
});
