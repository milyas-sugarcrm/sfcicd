({
  openActionWindow: function (component, event, helper) {
    var defaultUrl = $A.get("$Label.c.default_url");
    var opportunityId = component.get("v.opportunityId");

    window.open(defaultUrl + opportunityId, "_self");
  },
  reCalculateCounter: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getOpportunityLineItemDetails");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ab = response.getReturnValue();
        component.set("v.opportunityLineItem", response.getReturnValue());
        component.set("v.options", ab.artworks);
        var a = component.get("c.costChangedNew");
        $A.enqueueAction(a);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  deleteWarning: function (component, event, helper) {
    var recordToDelete;
    var ctarget = event.currentTarget;
    recordToDelete = ctarget.dataset.value;
    helper.deleteWarningsHelper(component, recordToDelete);
  },
  doInit: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.getOpportunityLineItemDetails");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var returnValue = response.getReturnValue();
        component.set("v.opportunityLineItem", response.getReturnValue());
        if (returnValue != null && returnValue.artworks != null)
          component.set("v.options", returnValue.artworks);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);

    var action1 = component.get("c.getOpportunityStage");
    action1.setParams({
      recid: component.get("v.opportunityId")
    });

    action1.setCallback(this, function (response) {
      console.log(
        "OPppppppppppppp id is : " + component.get("v.opportunityId")
      );
      var state = response.getState();
      if (state === "SUCCESS") {
        if (
          response.getReturnValue() !== "Presentation" &&
          response.getReturnValue() !== "Needs Analysis" &&
          response.getReturnValue() !== "Estimate" &&
          response.getReturnValue() !== null
        ) {
          component.set("v.SalesStage", true);
        } else if (response.getReturnValue() !== null) {
          component.set("v.SalesStage", false);
        }
      }
    });
    $A.enqueueAction(action1);
  },
  loadDefaulParams: function (component, event, helper) {},
  addFixedChargesInDb: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var title = component.find("Popup_Title").get("v.value");
    var artwork = component.find("artworkDropdown").get("v.value");

    var action = component.get("c.addFixedCharges");
    action.setParams({
      recId: idValue,
      title: title,
      artwork: artwork
    });

    action.setCallback(this, function (response) {
      component.set("v.isOpen", false);
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var title = component.find("Popup_Title").set("v.value", "");
          component.set("v.isOpen", false);

          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Fixed Charges Added Successfully"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        }
      } else {
        console.log("Failed with state: " + state);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Error Adding Fixed Charges"
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },
  warningValueChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");
    var action = component.get("c.updateWarningValueInDb");
    action.setParams({
      updatedValue: updatedValue,
      updateKey: updateKey,
      recordToUpdate: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Value changed successfully"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Error in"
        });
        toastEvent.fire();
      }
    });

    $A.enqueueAction(action);
  },
  deleteRunCharge: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var action = component.get("c.deleteRunChargeinDB");
    action.setParams({
      recordToUpdate: ctarget.dataset.value,
      recId: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Run charge deleted successfully"
          });
          toastEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "There's an error while deleting run charges.Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "There's an error while deleting run charges.Kindly contact your administrator"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  valuesChanged: function (component, event, helper) {
    var recordToUpdate = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");
    var updateKey = event.getSource().getLocalId();
    helper.calculateAndUpdateValues(
      component,
      updatedValue,
      updateKey,
      recordToUpdate
    );
  },
  deleteFixedCharge: function (component, event, helper) {
    var recordToUpdate;
    var updatedValue;
    var updateKey;

    if (event.target.id == "delete") {
      updateKey = "delete";
      var ctarget = event.currentTarget;
      recordToUpdate = ctarget.dataset.value;
      helper.updateFixedChargesValues(
        component,
        updatedValue,
        updateKey,
        recordToUpdate
      );
    }
  },
  fixedChargesValuesChanged: function (component, event, helper) {
    var recordToUpdate;
    var updatedValue;
    var updateKey;

    if (event.getSource().getLocalId() == "fixedChargestitle") {
      updateKey = "title";
      var inputsValues1 = component.find("fixedChargestitle"); // return array if components with same 'aura:id' exist
    } else if (event.getSource().getLocalId() == "fixedChargesCost") {
      updateKey = "cost";
      var inputsValues1 = component.find("fixedChargesCost"); // return array if components with same 'aura:id' exist
    } else if (event.getSource().getLocalId() == "fixedChargesMargin") {
      updateKey = "margin";
      var inputsValues1 = component.find("fixedChargesMargin"); // return array if components with same 'aura:id' exist
    } else if (event.getSource().getLocalId() == "fixedChargesRetail") {
      updateKey = "retail";
      var inputsValues1 = component.find("fixedChargesRetail"); // return array if components with same 'aura:id' exist
    }

    if (inputsValues1 != null) {
      if (inputsValues1.length == undefined) {
        updatedValue = inputsValues1.get("v.value");
        if (updatedValue == null || updatedValue == "") {
          if (updateKey != "title") {
            updatedValue = 0;
          }
        }
        recordToUpdate = inputsValues1.get("v.name");

        helper.updateFixedChargesValues(
          component,
          updatedValue,
          updateKey,
          recordToUpdate
        );
      } else {
        for (var i = 0; i < inputsValues1.length; i++) {
          if (
            inputsValues1[i].get("v.name") == event.getSource().get("v.name")
          ) {
            updatedValue = inputsValues1[i].get("v.value");
            if (updatedValue == null || updatedValue == "") {
              if (updateKey != "title") {
                updatedValue = 0;
              }
            }
            recordToUpdate = inputsValues1[i].get("v.name");

            helper.updateFixedChargesValues(
              component,
              updatedValue,
              updateKey,
              recordToUpdate
            );
          }
        }
      }
    }
  },
  updateFixedChargesAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfFixedCharges");
    var recordToUpdateTitle = component.get("v.recordToUpdateOfFixedCharges");
    var costs = component.find("fixedChargesCost");
    var margins = component.find("fixedChargesMargin");
    var retails = component.find("fixedChargesRetail");

    if (costs != null) {
      if (costs.length == undefined) {
        costs.set("v.value", updatedValues[0].Cost__c);
      } else {
        for (var i = 0; i < costs.length; i++) {
          if (costs[i].get("v.name") == recordToUpdateTitle) {
            costs[i].set("v.value", updatedValues[0].Cost__c);
          }
        }
      }
    }
    if (margins != null) {
      if (margins.length == undefined) {
        margins.set("v.value", updatedValues[0].Margin__c);
      } else {
        for (var i = 0; i < margins.length; i++) {
          if (margins[i].get("v.name") == recordToUpdateTitle) {
            margins[i].set("v.value", updatedValues[0].Margin__c);
          }
        }
      }
    }
    if (retails != null) {
      if (retails.length == undefined) {
        retails.set("v.value", updatedValues[0].Retail_Price__c);
      } else {
        for (var i = 0; i < retails.length; i++) {
          if (retails[i].get("v.name") == recordToUpdateTitle) {
            retails[i].set("v.value", updatedValues[0].Retail_Price__c);
          }
        }
      }
    }
    //debugger;
  },
  marginChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var updatedValue = event.getSource().get("v.value");
    var idValue = event.getSource().get("v.name");

    helper.UpdateMargin(component, updatedValue, updateKey, idValue);
  },

  costChangedNew: function (component, event, helper) {
    var j;
    for (j = 1; j <= 5; j++) {
      var costValue = component.find("cost" + j).get("v.value");

      var updatedValue = component.find("margin" + j).get("v.value");

      if (isNaN(costValue)) {
        costValue = 0;
      }

      var inputsValues1 = component.find("dynamicIdsValues" + j); // return array if components with same 'aura:id' exist

      var finalCost = 0;
      if (!isNaN(costValue)) {
        finalCost = parseFloat(costValue);
      }

      if (inputsValues1 != null) {
        for (var i = 0; i < inputsValues1.length; i++) {
          var tempValue = inputsValues1[i].get("v.value");
          if (!isNaN(tempValue)) {
            finalCost += parseFloat(tempValue);
          }
        }
      }
      var finalPrice = (finalCost / (1 - updatedValue / 100)).toFixed(2);

      component.find("total" + j).set("v.value", finalPrice);
    }
  },
  pricePerUnitChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");

    helper.UpdateTotal(component, updatedValue, updateKey, idValue);
  },
  totalValueChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");

    helper.UpdateTotal(component, updatedValue, updateKey, idValue);
  },
  costChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();

    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");
    helper.UpdateCost(component, updatedValue, updateKey, idValue);
  },
  quantityChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = component.find(updateKey).get("v.name");
    var updatedValue = component.find(updateKey).get("v.value");
    helper.UpdateQuantity(component, updatedValue, updateKey, idValue);
  },
  addRunChargesInDb: function (component, event, helper) {
    var idValue = component.get("v.recordId");

    var title = component.find("runCharge_Title").get("v.value");
    var cost1 = null;
    var cost2 = null;
    var cost3 = null;
    var cost4 = null;
    var cost5 = null;
    var artwork = component.find("artworkDropdown1").get("v.value");

    var allValueInserted = true;
    var pricingRecordCount = component.get("v.pricingRecordsCount");
    if (pricingRecordCount >= 1) {
      cost1 = component.find("runCharge_Cost1").get("v.value");
      if (!cost1) {
        allValueInserted = false;
      }
    }
    if (pricingRecordCount >= 2) {
      cost2 = component.find("runCharge_Cost2").get("v.value");
      if (!cost2) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 3) {
      cost3 = component.find("runCharge_Cost3").get("v.value");
      if (!cost3) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 4) {
      cost4 = component.find("runCharge_Cost4").get("v.value");
      if (!cost4) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 5) {
      cost5 = component.find("runCharge_Cost5").get("v.value");
      if (!cost5) {
        allValueInserted = false;
      }
    }

    if (!title) {
      allValueInserted = false;
    }
    if (!allValueInserted) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please Enter All The Values"
      });
      toastEvent.fire();
    }
    allValueInserted = true;
    if (pricingRecordCount >= 1) {
      if (isNaN(cost1) || parseInt(cost1) < 0) {
        allValueInserted = false;
      }
    }
    if (pricingRecordCount >= 2) {
      if (isNaN(cost2) || parseInt(cost2) < 0) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 3) {
      if (isNaN(cost3) || parseInt(cost3) < 0) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 4) {
      if (isNaN(cost4) || parseInt(cost4) < 0) {
        allValueInserted = false;
      }
    }

    if (pricingRecordCount >= 5) {
      if (isNaN(cost5) || parseInt(cost5) < 0) {
        allValueInserted = false;
      }
    }
    if (!allValueInserted) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Values of cost must be number and positive"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.addRunCharges");

      action.setParams({
        recId: idValue,
        title: title,
        cost1: cost1,
        cost2: cost2,
        cost3: cost3,
        cost4: cost4,
        cost5: cost5,
        artwork: artwork
      });

      action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          if (response.getReturnValue() != null) {
            debugger;
            component.set("v.opportunityLineItem", response.getReturnValue());

            component.set("v.addRunCharge", false);
            $A.get("e.force:refreshView").fire();
          }
        } else {
          console.log("Failed with state: " + state);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "There's an error while adding run charges.Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  openPricingPopup: function (component, event, helper) {
    component.set("v.SpinnerPrice", true);
    var idValue = component.get("v.recordId");
    helper.fetchPricingFromEsp(component, idValue);
    component.set("v.checkPricing", true);
  },
  closePricingPopup: function (component, event, helper) {
    component.set("v.checkPricing", false);
  },
  updatePricingPopup: function (component, event, helper) {
    component.set("v.SpinnerPrice", true);
    var idValue = component.get("v.recordId");
    var action = component.get("c.setProductPricingFromEsp");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        //   $A.get('e.force:refreshView').fire();
        toastEvent.setParams({
          type: "Success",
          message: "Prices Updated"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Error while updating pricing"
        });
        toastEvent.fire();
        console.log("Error in Adding Warning " + state);
      }
      component.set("v.SpinnerPrice", false);
    });
    $A.enqueueAction(action);
  },
  openRunCharges: function (component, event, helper) {
    helper.fetchPickListVal(component, "artworkDropdown1");
    helper.getPricingRecordSize(component);
    component.set("v.addRunCharge", true);
  },
  closeRunCharges: function (component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle" ]

    component.set("v.addRunCharge", false);
  },

  openFixedChargesModel: function (component, event, helper) {
    // for Display Model,set the "isOpen" attribute to "true"
    //
    //
    helper.fetchPickListVal(component, "artworkDropdown");
    component.set("v.isOpen", true);
  },
  closeFixedChargesModel: function (component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
    component.set("v.isOpen", false);
  },
  updatePricingOfLineItem: function (component, event, helper) {},
  AddWarning: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addWarningInDB");
    action.setParams({
      recId: idValue
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          $A.get("e.force:refreshView").fire();
        }
      } else {
        console.log("Error in Adding Warning " + state);
      }
    });
    $A.enqueueAction(action);
  },
  labelNotesValueChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = component.get("v.recordId");
    var updatedValue = component.find(updateKey).get("v.value");

    helper.updateNotesValue(component, updatedValue, updateKey, idValue);
  },
  openCheckProductPopup: function (component, event, helper) {
    var productId = event.target.value;
    var defaultUrl = $A.get("$Label.c.default_url");
    if (productId != null && productId.length > 0) {
      window.open(defaultUrl + productId, "_blank");
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Associated product has been deleted"
      });
      toastEvent.fire();
    }
  },
  openDetailProductPage: function (component, event, helper) {
    var productId = event.target.value;
    var oppId = component.get("v.opportunityId");
    var url =
      location.origin +
      "/apex/ESPSearchDetailsPage?Id=" +
      oppId +
      "&ProductId=" +
      productId +
      "&recordFrom=Presentation&isEspProduct=true";
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: url
    });
    urlEvent.fire();
  },
  closeCheckProductPopup: function (component, event, helper) {
    component.set("v.checkProduct", false);
  },

  handleClientClick: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var recordToUpdate = event.getSource().get("v.name");
    var checkboxValue = event.getSource().get("v.value");
    //   console.log('Updted key is>>>>>>>>>>> ', updateKey);
    //   var Number = event.getSource().get("v.num");
    //   var Number = event.getSource().getLocalId();
    helper.UpdateClientClickValue(
      component,
      recordToUpdate,
      checkboxValue,
      updateKey
    );
  },
  addComment: function (component, event, helper) {
    component.set("v.Spinner", true);
    var idValue = component.get("v.recordId");
    var comment = component.find("commentBox").get("v.value");
    var username = component.find("username").get("v.value");
    if (username != "" && comment != null) {
      var action = component.get("c.addCommentsInDb");
      action.setParams({
        recId: idValue,
        comment: comment,
        username: username
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() == true) {
            component.set("v.Spinner", false);
            component.find("commentBox").set("v.value", "");
            component.find("username").set("v.value", "");
            var toastEvent = $A.get("e.force:showToast");
            $A.get("e.force:refreshView").fire();
            toastEvent.setParams({
              type: "Success",
              message: "Comment Successfully Posted"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
          component.set("v.Spinner", false);
        }
      });
      $A.enqueueAction(action);
    } else {
      var errorMessage = "";
      if (username == "" && comment == null) {
        errorMessage = "Username & comment description is required!";
      } else if (comment == null) {
        errorMessage = "Comment description is required!";
      } else if (username == "") {
        errorMessage = "Username is required!";
      }

      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: errorMessage
      });
      toastEvent.fire();
      component.set("v.Spinner", false);
    }
  }
});
