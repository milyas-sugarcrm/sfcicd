({
  openActionWindow: function (component, event, helper) {
    var defaultUrl = $A.get("$Label.c.default_url");
    var opportunityId = component.get("v.opportunityId");

    window.open(defaultUrl + opportunityId, "_self");
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
        var ab = response.getReturnValue();
        if (response.getReturnValue() != null) {
          component.set("v.opportunityLineItem", response.getReturnValue());
          component.set(
            "v.internationalCostExists",
            ab.internationalCostExists
          );
          component.set("v.extraChargesExists", ab.extraChargesExists);
          component.set("v.pricingDetailsExists", ab.pricingDetailsExists);
          component.set("v.breakDownCount", ab.pricingDetails.length);
          component.set("v.totalPrice", ab.total);
          component.set("v.subtotal", ab.subtotal);
          component.set("v.marginPercentage", ab.marginPercentage);
          component.set("v.marginAmount", ab.marginAmount);
        }
      } else {
        console.log("Failed with state: " + state);
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
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
    var proofRequired = component.find("editProofRequired").get("v.value", "");
    var logoName = component.find("editLogoName").get("v.value", "");
    var logoSize = component.find("editLogoSize").get("v.value", "");
    var logoColor = component.find("editLogoColor").get("v.value", "");
    var repeatLogo = component.find("editRepeatLogo").get("v.value", "");
    var supplierNotes = component.find("editSupplierNotes").get("v.value", "");
    var documentId = component.get("v.editfileId");
    var title = component.find("editTitle").get("v.value", "");
    if (
      !imprintType ||
      !proofRequired ||
      !logoName ||
      !logoSize ||
      !logoColor ||
      !repeatLogo ||
      !title
    ) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please fill out the required fields"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.editArtworkInDatabases");
      action.setParams({
        recId: component.get("v.recordToEdit"),
        imprintType: imprintType,
        proofRequired: proofRequired,
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
  closeCheckProductPopup: function (component, event, helper) {
    component.set("v.checkProduct", false);
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
  pricingvaluesChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var updatedValue = event.getSource().get("v.value");
    var idValue = event.getSource().get("v.name");
    helper.UpdatePricing(component, updatedValue, updateKey, idValue);
  },

  extraChargesValuesChanged: function (component, event, helper) {
    var updateKey = event.getSource().getLocalId();
    var updatedValue = event.getSource().get("v.value");
    var idValue = event.getSource().get("v.name");
    if (
      updateKey === "extraChargesQuantityFixed" ||
      updateKey === "extraChargesQuantityRun" ||
      updateKey === "intCostExtraChargesQuantity" ||
      updateKey === "extraChargesQuantity"
    ) {
      updateKey = "quantity";
      helper.updateExtraCharges(component, updatedValue, updateKey, idValue);
    } else if (
      updateKey === "extraChargesNetCostFixed" ||
      updateKey === "extraChargesNetCostRun" ||
      updateKey === "intCostExtraChargesNetCost" ||
      updateKey === "extraChargesNetCost"
    ) {
      updateKey = "netCost";
      helper.updateExtraCharges(component, updatedValue, updateKey, idValue);
    } else if (
      updateKey === "extraChargesMarginFixed" ||
      updateKey === "intCostExtraChargesMargin" ||
      updateKey === "dutyExtraChargesMargin" ||
      updateKey === "extraChargesMargin"
    ) {
      updateKey = "margin";
      helper.updateExtraCharges(component, updatedValue, updateKey, idValue);
    } else if (
      updateKey === "extraChargesTitle" ||
      updateKey === "intCostExtraChargesTitle" ||
      updateKey === "dutyExtraChargesTitle"
    ) {
      updateKey = "title";
      helper.updateExtraChargeTitle(
        component,
        updatedValue,
        updateKey,
        idValue
      );
    } else {
      helper.updateExtraCharges(component, updatedValue, updateKey, idValue);
    }
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

  openAdditionalCostPopup: function (component, event, helper) {
    component.set("v.additionalCostPopup", true);
  },
  closeAdditionCostPopup: function (component, event, helper) {
    component.set("v.additionalCostPopup", false);
  },
  openInternationalCost: function (component, event, helper) {
    component.set("v.internationalCost", true);
  },
  closeInternationalCost: function (component, event, helper) {
    component.set("v.internationalCost", false);
  },

  addAdditionalChargesRow: function (component, event, helper) {
    var chargeType = event.getSource().getLocalId();
    var idValue = component.get("v.recordId");
    var action = component.get("c.addExtraChargesInDB");
    action.setParams({
      recId: idValue,
      chargeType: chargeType
    });

    component.set("v.internationalCost", false);
    component.set("v.additionalCostPopup", false);

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() == true) {
        $A.get("e.force:refreshView").fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Extra Charge Record Added Successfully"
        });
        toastEvent.fire();
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: "There is an Error While Adding Extra Charge Record"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
});
