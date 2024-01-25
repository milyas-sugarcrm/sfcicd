({
  openActionWindow: function (component, event, helper) {
    var defaultUrl = $A.get("$Label.c.default_url");
    var opportunityId = component.get("v.opportunityId");
    var action = component.get("c.syncRecord");
    action.setParams({
      recId: opportunityId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
      }
    });
    $A.enqueueAction(action);
    window.open(defaultUrl + opportunityId, "_self");
  },

  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);

    var idValue = component.get("v.recordId");
    var action = component.get("c.getOpportunityLineItemDetails");
    var action1 = component.get("c.getOpportunityStage");
    action1.setParams({
      recid: component.get("v.opportunityId")
    });

    action1.setCallback(this, function (response) {
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

    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var oppDetails = response.getReturnValue();
        if (oppDetails != null) {
          component.set("v.opportunityLineItem", response.getReturnValue());
          component.set(
            "v.internationalCostExists",
            oppDetails.internationalCostExists
          );
          component.set("v.extraChargesExists", oppDetails.extraChargesExists);
          component.set(
            "v.pricingDetailsExists",
            oppDetails.pricingDetailsExists
          );
          component.set("v.breakDownCount", oppDetails.pricingDetails.length);
          component.set("v.totalPrice", oppDetails.total);
          component.set("v.subtotal", oppDetails.subtotal);
          component.set("v.marginPercentage", oppDetails.marginPercentage);
          component.set("v.marginAmount", oppDetails.marginAmount);
          component.set("v.message", "All changes are saved");
          var a = component.get("c.updateTimeOfLastChange");
          $A.enqueueAction(a);
        }
      } else {
        console.log("Failed with state: " + state);
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
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
  closeArtworkPopup: function (component, event, helper) {
    component.set("v.artworkPopup", false);
  },
  deleteBreakdown: function (component, event, helper) {
    var recordToDelete;
    var ctarget = event.currentTarget;
    recordToDelete = ctarget.dataset.value;
    helper.deleteBreakdownHelper(component, recordToDelete);
  },
  deleteArtwork: function (component, event, helper) {
    var recordToDelete;
    var ctarget = event.currentTarget;
    recordToDelete = ctarget.dataset.value;
    helper.deleteArtworkHelper(component, recordToDelete);
  },
  deleteExtraCharges: function (component, event, helper) {
    var recordToDelete;
    var ctarget = event.currentTarget;
    recordToDelete = ctarget.dataset.value;
    helper.deleteExtraChargesHelper(component, recordToDelete);
  },
  handleUploadFinished: function (component, event) {
    var fileName = "No File Selected..";
    var documentId;

    event.getParam("files")[0].name;
    if (event.getParam("files").length > 0) {
      fileName = event.getParam("files")[0].name;
      documentId = event.getParam("files")[0].documentId;
    }
    component.set("v.documentId", documentId);
    component.set("v.fileName", fileName);
    component.set("v.fileUploaded", true);
  },
  editArtwork: function (component, event, helper) {
    var imprintType = component.find("editImprintType").get("v.value", "");
    //var proofRequired=component.find("editProofRequired").get("v.value","");
    var logoName = component.find("editLogoName").get("v.value", "");
    var logoSize = component.find("editLogoSize").get("v.value", "");
    var logoColor = component.find("editLogoColor").get("v.value", "");
    var repeatLogo = component.find("editRepeatLogo").get("v.value", "");
    var supplierNotes = component.find("editSupplierNotes").get("v.value", "");
    var documentId = component.get("v.editfileId");
    var title = component.find("editTitle").get("v.value", "");
    if (
      !imprintType ||
      !logoName ||
      !logoSize ||
      !logoColor ||
      !repeatLogo ||
      !title
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please Fill Out the Required Fields"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.editArtworkInDatabases");
      action.setParams({
        recId: component.get("v.recordToEdit"),
        imprintType: imprintType,
        proofRequired: "",
        logoName: logoName,
        logoSize: logoSize,
        logoColor: logoColor,
        repeatLogo: repeatLogo,
        supplierNotes: supplierNotes,
        documentId: documentId,
        title: title,
        OpportunityLineItemId: component.get("v.recordId")
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS" && response.getReturnValue() == true) {
          component.set("v.editArtworkPopup", false);
          $A.get("e.force:refreshView").fire();
        } else {
          var a = component.get("c.updateErrorMessage");
          $A.enqueueAction(a);
        }
      });
      $A.enqueueAction(action);
    }
  },
  updateErrorMessage: function (component, event, helper) {
    component.set(
      "v.message",
      "Changes cannot be saved. Kindly contact your administrator"
    );
  },
  closeEditArtworkPopup: function (component, event, helper) {
    component.set("v.editArtworkPopup", false);
  },
  openEditArtworkPopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id = ctarget.dataset.value;
    component.set("v.recordToEdit", id);
    var action = component.get("c.getArtworkToEdit");
    action.setParams({
      recId: id
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ab = response.getReturnValue();
        component.set("v.artworkEdit", ab);
        component.set("v.editArtworkPopup", true);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
  },
  addNewDecorationLocation: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addArtworkLocationInEstimate");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        $A.get("e.force:refreshView").fire();
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
  },
  chargesStatusChanged: function (component, event, helper) {
    var recordToUpdate = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");
    var action = component.get("c.updateStatusOfExtraCharges");
    action.setParams({
      recId: component.get("v.recordId"),
      recordToUpdate: recordToUpdate,
      value: updatedValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue != null) {
        var ab = response.getReturnValue();
        component.set("v.opportunityLineItem", response.getReturnValue());
        component.set("v.internationalCostExists", ab.internationalCostExists);
        var a = component.get("c.updateTimeOfLastChange");
        $A.enqueueAction(a);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
  },
  openAdditionalCostPopup: function (component, event, helper) {
    component.set("v.additionalCostPopup", true);
  },
  closeAdditionCostPopup: function (component, event, helper) {
    component.set("v.additionalCostPopup", false);
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
    var color = component.find("colorAddField").get("v.value");
    if (!color) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please enter value"
      });
      toastEvent.fire();
    } else {
      var idValue = component.get("v.selectedColorId");
      var listValues = component.get("v.colorList");
      var lineItemId = component.get("v.recordId");
      var isExist = false;
      for (var i = 0; i < listValues.length; i++) {
        if (listValues[i].value.toUpperCase() == color.toUpperCase()) {
          isExist = true;
          break;
        }
      }
      if (isExist) {
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
          lineItemId: lineItemId
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
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
            console.log("Failed with state: " + state);
          }
        });
        $A.enqueueAction(action);
        component.find("colorAddField").set("v.value", "");
      }
    }
  },
  addSize: function (component, event, helper) {
    var size = component.find("sizeAddField").get("v.value");
    if (!size) {
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
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "Size already exists!"
        });
        toastEvent.fire();
      } else {
        var action = component.get("c.addSizeInDb");
        var lineItemId = component.get("v.recordId");
        action.setParams({
          recId: idValue,
          size: size,
          lineItemId: lineItemId
        });

        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
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
  openInternationalCost: function (component, event, helper) {
    component.set("v.internationalCost", true);
  },
  closeInternationalCost: function (component, event, helper) {
    component.set("v.internationalCost", false);
  },
  openCheckProductPopup: function (component, event, helper) {
    // component.set("v.checkProduct",true);
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
      "&recordFrom=Estimate&isEspProduct=true";
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: url
    });
    urlEvent.fire();
  },
  closeCheckProductPopup: function (component, event, helper) {
    component.set("v.checkProduct", false);
  },
  deleteWarning: function (component, event, helper) {
    var recordToDelete = event.getSource().get("v.alternativeText");
    helper.deleteWarningsHelper(component, recordToDelete);
  },
  AddWarning: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addWarningInDB");
    action.setParams({
      recId: idValue
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
      }
    });
    $A.enqueueAction(action);
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
  openPricingPopup: function (component, event, helper) {
    component.set("v.checkPricing", true);
    component.set("v.SpinnerPrice", true);
    var idValue = component.get("v.recordId");
    helper.fetchPricingFromEsp(component, idValue);
    component.set("v.checkPricing", true);
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
        $A.get("e.force:refreshView").fire();
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
  closePricingPopup: function (component, event, helper) {
    component.set("v.checkPricing", false);
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
        var a = component.get("c.updateTimeOfLastChange");
        $A.enqueueAction(a);
      } else {
        var a = component.get("c.updateErrorMessage");
        $A.enqueueAction(a);
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
  addDefaultRowAtTheEnd: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addDefaultPricingRow");
    action.setParams({
      recId: idValue
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
  addFixedChargesRowForArtwork: function (component, event, helper) {
    var artworkId = event.getSource().get("v.name");
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDBForArtwork");
    action.setParams({
      recId: idValue,
      chargeType: "fixedCharge",
      artworkId: artworkId
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
  addRunChargesRowForArtwork: function (component, event, helper) {
    var artworkId = event.getSource().get("v.name");
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDBForArtwork");
    action.setParams({
      recId: idValue,
      chargeType: "runCharge",
      artworkId: artworkId
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
  addRunChargesRow: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: "runCharge"
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
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
  addInboundFreight: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: "inboundFreight"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
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
  addDuty: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: "duty"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
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
  addBrokerage: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: "brokerage"
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
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
  addFixedChargesRow: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: "fixedCharge"
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
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
  dutyValuesChanged: function (component, event, helper) {
    var recordToUpdate;
    var updatedValue;
    var updateKey;

    if (event.getSource().getLocalId() == "dutyextraChargedelete") {
      updateKey = "delete";
      recordToUpdate = event.getSource().get("v.name");
    } else {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");

      if (event.getSource().getLocalId() == "dutyExtraChargesTitle") {
        updateKey = "title";
      } else if (event.getSource().getLocalId() == "dutyExtraChargesQuantity") {
        updateKey = "quantity";
      } else if (event.getSource().getLocalId() == "dutyExtraChargesNetCost") {
        updateKey = "netCost";
      } else if (event.getSource().getLocalId() == "dutyExtraChargesMargin") {
        updateKey = "margin";
      } else if (
        event.getSource().getLocalId() == "dutyExtraChargesRetailPrice"
      ) {
        updateKey = "retailPrice";
      } else if (event.getSource().getLocalId() == "dutyPercentage") {
        updateKey = "percentage";
      }
      if (
        updateKey != "title" &&
        updateKey != "delete" &&
        isNaN(updatedValue)
      ) {
        component.set("v.message", "Value must be a number");
      } else if (
        updateKey == "quantity" &&
        !(parseInt(updatedValue) == updatedValue)
      ) {
        component.set("v.message", "Value must be a number");
      } else if (updateKey == "quantity" && parseInt(updatedValue) < 0) {
        component.set("v.message", "Value must be a positive number");
      } else {
        helper.updateValuesOfDutyExtraChargesHelper(
          component,
          updatedValue,
          updateKey,
          recordToUpdate
        );
      }
    }
  },
  extraChargesValuesChanged: function (component, event, helper) {
    var recordToUpdate;
    var updatedValue;
    var updateKey;

    if (event.getSource().getLocalId() == "extraChargedelete") {
      updateKey = "delete";
      recordToUpdate = event.getSource().get("v.name");
    } else if (
      event.getSource().getLocalId() == "extraChargesTitle" ||
      event.getSource().getLocalId() == "intCostExtraChargesTitle"
    ) {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");
      debugger;
      if (event.getSource().getLocalId() == "intCostExtraChargesTitle") {
        component.set("v.isInternationalCostUpdated", true);
      }
      updateKey = "title";
    } else if (
      event.getSource().getLocalId() == "extraChargesQuantity" ||
      event.getSource().getLocalId() == "intCostExtraChargesQuantity"
    ) {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");
      if (event.getSource().getLocalId() == "intCostExtraChargesQuantity") {
        component.set("v.isInternationalCostUpdated", true);
      }
      updateKey = "quantity";
    } else if (
      event.getSource().getLocalId() == "extraChargesNetCost" ||
      event.getSource().getLocalId() == "intCostExtraChargesNetCost"
    ) {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");
      if (event.getSource().getLocalId() == "intCostExtraChargesNetCost") {
        component.set("v.isInternationalCostUpdated", true);
      }
      updateKey = "netCost";
    } else if (
      event.getSource().getLocalId() == "extraChargesMargin" ||
      event.getSource().getLocalId() == "intCostExtraChargesMargin"
    ) {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");
      if (event.getSource().getLocalId() == "intCostExtraChargesMargin") {
        component.set("v.isInternationalCostUpdated", true);
      }
      updateKey = "margin";
    } else if (
      event.getSource().getLocalId() == "extraChargesRetailPrice" ||
      event.getSource().getLocalId() == "intCostExtraChargesRetailPrice"
    ) {
      recordToUpdate = event.getSource().get("v.name");
      updatedValue = event.getSource().get("v.value");
      if (event.getSource().getLocalId() == "intCostExtraChargesRetailPrice") {
        component.set("v.isInternationalCostUpdated", true);
      }
      updateKey = "retailPrice";
    }

    if (updateKey != "title" && updateKey != "delete" && isNaN(updatedValue)) {
      component.set("v.message", "Value must be a number");
    } else if (
      updateKey != "title" &&
      updateKey != "delete" &&
      parseInt(updatedValue) < 0
    ) {
      component.set("v.message", "Value must be a positive number");
    } else if (
      updateKey == "quantity" &&
      !(parseInt(updatedValue) == updatedValue)
    ) {
      component.set("v.message", "Value must be a number");
    } else {
      helper.updateValuesOfExtraChargesHelper(
        component,
        updatedValue,
        updateKey,
        recordToUpdate
      );
    }
  },
  pricingvaluesChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var idValue = event.getSource().get("v.name");
    var updatedValue = event.getSource().get("v.value");
    if (updateKey != "title" && updateKey != "delete" && isNaN(updatedValue)) {
      component.set("v.message", "Value must be a number");
    } else if (
      updateKey != "title" &&
      updateKey != "delete" &&
      parseInt(updatedValue) < 0
    ) {
      component.set("v.message", "Value must be a positive number");
    } else if (
      updateKey == "quantity" &&
      !(parseInt(updatedValue) == updatedValue)
    ) {
      component.set("v.message", "Value must be a number");
    } else {
      helper.calculateAndUpdatePricingRecord(
        component,
        updatedValue,
        updateKey,
        idValue
      );
    }
  },
  updatePricingRecordAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfPricing");
    var recordToUpdate = component.get("v.recordToUpdateOfPricing");
    var quantity = component.find("quantity");
    var netCost = component.find("netCost");
    var margin = component.find("margin");
    var retailPrice = component.find("retailPrice");
    var clientPrice = component.find("clientPrice");
    var total = component.find("total");
    if (netCost != null) {
      if (netCost.length == undefined) {
        netCost.set("v.value", updatedValues[0].Net_Cost__c);
      } else {
        for (var i = 0; i < netCost.length; i++) {
          if (netCost[i].get("v.name") == recordToUpdate) {
            netCost[i].set("v.value", updatedValues[0].Net_Cost__c);
          }
        }
      }
    }
    if (margin != null) {
      if (margin.length == undefined) {
        margin.set("v.value", updatedValues[0].Margin__c);
      } else {
        for (var i = 0; i < margin.length; i++) {
          if (margin[i].get("v.name") == recordToUpdate) {
            margin[i].set("v.value", updatedValues[0].Margin__c);
          }
        }
      }
    }
    if (retailPrice != null) {
      if (retailPrice.length == undefined) {
        retailPrice.set("v.value", updatedValues[0].Retail_Price__c);
      } else {
        for (var i = 0; i < retailPrice.length; i++) {
          if (retailPrice[i].get("v.name") == recordToUpdate) {
            retailPrice[i].set("v.value", updatedValues[0].Retail_Price__c);
          }
        }
      }
    }
    if (total != null) {
      if (total.length == undefined) {
        total.set("v.value", updatedValues[0].Total__c);
      } else {
        for (var i = 0; i < total.length; i++) {
          if (total[i].get("v.name") == recordToUpdate) {
            total[i].set("v.value", updatedValues[0].Total__c);
          }
        }
      }
    }
  },
  updateDutyRecordAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfduty");
    var recordToUpdateTitle = component.get("v.recordToUpdateOfduty");
    var title = component.find("dutyExtraChargesTitle");
    var dutyPercentage = component.find("dutyPercentage");
    var netCost = component.find("dutyExtraChargesNetCost");
    var margin = component.find("dutyExtraChargesMargin");
    var retailPrice = component.find("dutyExtraChargesRetailPrice");
    var total = component.find("dutyExtraChargesTotal");

    if (dutyPercentage != null) {
      if (dutyPercentage.length == undefined) {
        dutyPercentage.set("v.value", updatedValues[0].Duty_Percentage__c);
      } else {
        for (var i = 0; i < dutyPercentage.length; i++) {
          if (dutyPercentage[i].get("v.name") == recordToUpdateTitle) {
            dutyPercentage[i].set(
              "v.value",
              updatedValues[0].Duty_Percentage__c
            );
          }
        }
      }
    }
    if (title != null) {
      if (title.length == undefined) {
        title.set("v.value", updatedValues[0].Title__c);
      } else {
        for (var i = 0; i < title.length; i++) {
          if (title[i].get("v.name") == recordToUpdateTitle) {
            title[i].set("v.value", updatedValues[0].Title__c);
          }
        }
      }
    }

    if (netCost != null) {
      if (netCost.length == undefined) {
        netCost.set("v.value", updatedValues[0].Net_Cost__c);
      } else {
        for (var i = 0; i < netCost.length; i++) {
          if (netCost[i].get("v.name") == recordToUpdateTitle) {
            netCost[i].set("v.value", updatedValues[0].Net_Cost__c);
          }
        }
      }
    }
    if (margin != null) {
      if (margin.length == undefined) {
        margin.set("v.value", updatedValues[0].Margin__c);
      } else {
        for (var i = 0; i < margin.length; i++) {
          if (margin[i].get("v.name") == recordToUpdateTitle) {
            margin[i].set("v.value", updatedValues[0].Margin__c);
          }
        }
      }
    }
    if (retailPrice != null) {
      if (retailPrice.length == undefined) {
        retailPrice.set("v.value", updatedValues[0].Retail_Price__c);
      } else {
        for (var i = 0; i < retailPrice.length; i++) {
          if (retailPrice[i].get("v.name") == recordToUpdateTitle) {
            retailPrice[i].set("v.value", updatedValues[0].Retail_Price__c);
          }
        }
      }
    }
    if (total != null) {
      if (total.length == undefined) {
        total.set("v.value", updatedValues[0].Total__c);
      } else {
        for (var i = 0; i < total.length; i++) {
          if (total[i].get("v.name") == recordToUpdateTitle) {
            total[i].set("v.value", updatedValues[0].Total__c);
          }
        }
      }
    }
  },
  updateInternationalChargeAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfextraCharge");
    var recordToUpdateTitle = component.get("v.recordToUpdateOfextraCharge");
    var title = component.find("intCostExtraChargesTitle");
    var quantity = component.find("intCostExtraChargesQuantity");
    var netCost = component.find("intCostExtraChargesNetCost");
    var margin = component.find("intCostExtraChargesMargin");
    var retailPrice = component.find("intCostExtraChargesRetailPrice");
    var total = component.find("intCostExtraChargesTotal");
    component.set("v.isInternationalCostUpdated", false);
    if (title != null) {
      if (title.length == undefined) {
        title.set("v.value", updatedValues[0].Title__c);
      } else {
        for (var i = 0; i < title.length; i++) {
          if (title[i].get("v.name") == recordToUpdateTitle) {
            title[i].set("v.value", updatedValues[0].Title__c);
          }
        }
      }
    }
    if (quantity != null) {
      if (quantity.length == undefined) {
        quantity.set("v.value", updatedValues[0].Quantity__c);
      } else {
        for (var i = 0; i < quantity.length; i++) {
          if (quantity[i].get("v.name") == recordToUpdateTitle) {
            quantity[i].set("v.value", updatedValues[0].Quantity__c);
          }
        }
      }
    }
    if (netCost != null) {
      if (netCost.length == undefined) {
        netCost.set("v.value", updatedValues[0].Net_Cost__c);
      } else {
        for (var i = 0; i < netCost.length; i++) {
          if (netCost[i].get("v.name") == recordToUpdateTitle) {
            netCost[i].set("v.value", updatedValues[0].Net_Cost__c);
          }
        }
      }
    }
    if (margin != null) {
      if (margin.length == undefined) {
        margin.set("v.value", updatedValues[0].Margin__c);
      } else {
        for (var i = 0; i < margin.length; i++) {
          if (margin[i].get("v.name") == recordToUpdateTitle) {
            margin[i].set("v.value", updatedValues[0].Margin__c);
          }
        }
      }
    }
    if (retailPrice != null) {
      if (retailPrice.length == undefined) {
        retailPrice.set("v.value", updatedValues[0].Retail_Price__c);
      } else {
        for (var i = 0; i < retailPrice.length; i++) {
          if (retailPrice[i].get("v.name") == recordToUpdateTitle) {
            retailPrice[i].set("v.value", updatedValues[0].Retail_Price__c);
          }
        }
      }
    }
    if (total != null) {
      if (total.length == undefined) {
        total.set("v.value", updatedValues[0].Total__c);
      } else {
        for (var i = 0; i < total.length; i++) {
          if (total[i].get("v.name") == recordToUpdateTitle) {
            total[i].set("v.value", updatedValues[0].Total__c);
          }
        }
      }
    }
  },
  updatExtraChargesAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfextraCharge");
    var recordToUpdateTitle = component.get("v.recordToUpdateOfextraCharge");
    var title = component.find("extraChargesTitle");
    var quantity = component.find("extraChargesQuantity");
    var netCost = component.find("extraChargesNetCost");
    var margin = component.find("extraChargesMargin");
    var retailPrice = component.find("extraChargesRetailPrice");
    var total = component.find("extraChargesTotal");
    if (title != null) {
      if (title.length == undefined) {
        title.set("v.value", updatedValues[0].Title__c);
      } else {
        for (var i = 0; i < title.length; i++) {
          if (title[i].get("v.name") == recordToUpdateTitle) {
            title[i].set("v.value", updatedValues[0].Title__c);
          }
        }
      }
    }
    if (quantity != null) {
      if (quantity.length == undefined) {
        quantity.set("v.value", updatedValues[0].Quantity__c);
      } else {
        for (var i = 0; i < quantity.length; i++) {
          if (quantity[i].get("v.name") == recordToUpdateTitle) {
            quantity[i].set("v.value", updatedValues[0].Quantity__c);
          }
        }
      }
    }
    if (netCost != null) {
      if (netCost.length == undefined) {
        netCost.set("v.value", updatedValues[0].Net_Cost__c);
      } else {
        for (var i = 0; i < netCost.length; i++) {
          if (netCost[i].get("v.name") == recordToUpdateTitle) {
            netCost[i].set("v.value", updatedValues[0].Net_Cost__c);
          }
        }
      }
    }
    if (margin != null) {
      if (margin.length == undefined) {
        margin.set("v.value", updatedValues[0].Margin__c);
      } else {
        for (var i = 0; i < margin.length; i++) {
          if (margin[i].get("v.name") == recordToUpdateTitle) {
            margin[i].set("v.value", updatedValues[0].Margin__c);
          }
        }
      }
    }
    if (retailPrice != null) {
      if (retailPrice.length == undefined) {
        retailPrice.set("v.value", updatedValues[0].Retail_Price__c);
      } else {
        for (var i = 0; i < retailPrice.length; i++) {
          if (retailPrice[i].get("v.name") == recordToUpdateTitle) {
            retailPrice[i].set("v.value", updatedValues[0].Retail_Price__c);
          }
        }
      }
    }
    if (total != null) {
      if (total.length == undefined) {
        total.set("v.value", updatedValues[0].Total__c);
      } else {
        for (var i = 0; i < total.length; i++) {
          if (total[i].get("v.name") == recordToUpdateTitle) {
            total[i].set("v.value", updatedValues[0].Total__c);
          }
        }
      }
    }
  },
  updateFixedChargesAfterResponse: function (component, event, helper) {
    var updatedValues = component.get("v.updatedValuesOfFixedChargePricing");
    var recordToUpdateTitle = component.get(
      "v.recordToUpdateOfFixedChargePricing"
    );
    var costs = component.find("netCost");
    var margins = component.find("margin");
    var retails = component.find("retailPrice");
    var total = component.find("total");
    if (total != null) {
      if (total.length == undefined) {
        total.set("v.value", updatedValues[0].Total__c);
      } else {
        for (var i = 0; i < total.length; i++) {
          if (total[i].get("v.name") == recordToUpdateTitle) {
            total[i].set("v.value", updatedValues[0].Total__c);
          }
        }
      }
    }
    if (costs != null) {
      if (costs.length == undefined) {
        costs.set("v.value", updatedValues[0].Net_Cost__c);
      } else {
        for (var i = 0; i < costs.length; i++) {
          if (costs[i].get("v.name") == recordToUpdateTitle) {
            costs[i].set("v.value", updatedValues[0].Net_Cost__c);
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
    var selectedValues = component.get("v.selectedSizeList");
    var action = component.get("c.addSizeInDb");
    var idValue = component.get("v.selectedColorId");
    action.setParams({
      recId: idValue,
      size: selectedValues
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Sizes list successfully updated"
          });
          toastEvent.fire();
          component.set("v.updateSizePopup", false);
          var recordToUpdate = component.get("v.selectedColorId");
          var colorRecord = component.find("sizeColor");
          if (colorRecord != null) {
            if (colorRecord.length == undefined) {
              var colorValue = colorRecord.get("v.value");
              colorRecord.set(
                "v.value",
                selectedValues + "/" + colorValue.split("/")[1]
              );
            } else {
              for (var i = 0; i < colorRecord.length; i++) {
                if (colorRecord[i].get("v.name") == recordToUpdate) {
                  var colorValue = colorRecord[i].get("v.value");
                  colorValue.split("/");
                  colorRecord[i].set(
                    "v.value",
                    selectedValues + "/" + colorValue.split("/")[1]
                  );
                }
              }
            }
          }
          $A.enqueueAction(component.get("c.doInit"));
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
    var selectedValues = component.get("v.selectedColorList");
    var action = component.get("c.addColorInDb");
    var idValue = component.get("v.selectedColorId");
    action.setParams({
      recId: idValue,
      color: selectedValues
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Color successfully updated"
          });
          toastEvent.fire();
          component.set("v.updateColorPopup", false);
          var recordToUpdate = component.get("v.selectedColorId");
          debugger;
          var colorRecord = component.find("sizeColor");
          if (colorRecord != null) {
            if (colorRecord.length == undefined) {
              var colorValue = colorRecord.get("v.value");
              colorRecord.set(
                "v.value",
                colorValue.split("/")[0] + "/" + selectedValues
              );
            } else {
              for (var i = 0; i < colorRecord.length; i++) {
                if (colorRecord[i].get("v.name") == recordToUpdate) {
                  var colorValue = colorRecord[i].get("v.value");
                  colorValue.split("/");
                  colorRecord[i].set(
                    "v.value",
                    colorValue.split("/")[0] + "/" + selectedValues
                  );
                }
              }
            }
            $A.enqueueAction(component.get("c.doInit"));
          }
          //helper.populateColors(component, event, helper);
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
  }
});
