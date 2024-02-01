({
  handleUploadFinished: function (component, event) {
    var fileName = "No File Selected..";
    var documentId;
    console.log(event.getParam("files"));

    event.getParam("files")[0].name;
    if (event.getParam("files").length > 0) {
      fileName = event.getParam("files")[0].name;
      documentId = event.getParam("files")[0].documentId;
    }
    component.set("v.documentId", documentId);
    component.set("v.fileName", fileName);
    component.set("v.fileUploaded", true);
  },
  handleColorChange: function (component, event, helper) {
    //Get the Selected values
    var selectedValues = event.getParam("value");

    //Update the Selected Values
    component.set("v.selectedColorList", selectedValues);
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
    var action = component.get("c.UpdateSizesList");
    var idValue = component.get("v.recordId");
    action.setParams({
      recId: idValue,
      selectedSizes: selectedValues
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
          helper.populateSizes(component, event, helper);
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
    var action = component.get("c.UpdateColorsList");
    var idValue = component.get("v.recordId");
    action.setParams({
      recId: idValue,
      selectedColors: selectedValues
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Colors list successfully updated"
          });
          toastEvent.fire();
          component.set("v.updateColorPopup", false);
          helper.populateColors(component, event, helper);
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
  openArtworkPopup: function (component, event, helper) {
    component.set("v.artworkPopup", true);
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
      component.find("colorAddField").set("v.value", null);
      var idValue = component.get("v.recordId");
      var listValues = component.get("v.colorList");
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
          color: color
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
        component.find("colorAddfield").set("v.value", "");
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
      var idValue = component.get("v.recordId");
      var listValues = component.get("v.sizeList");
      var isExist = false;
      debugger;
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

        action.setParams({
          recId: idValue,
          size: size
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
  openEditArtworkPopup: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var artworkId = ctarget.dataset.value;
    component.set("v.editArtworkPopup", true);
    component.set("v.recordToEdit", artworkId);
    var action = component.get("c.getArtworkToEdit");
    component.set("V.Spinner", true);
    action.setParams({
      recId: artworkId
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ab = response.getReturnValue();
        debugger;
        //component.find("editTitle").set("v.value",ab.Title__c);
        component.set("v.artworkEdit", ab);
        console.log(component.get("v.artworkEdit"));

        component.set("V.Spinner", false);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  closeEditArtworkPopup: function (component, event, helper) {
    component.set("v.recordToEdit", 0);
    component.set("v.editArtworkPopup", false);
  },
  openUpdateSizePopup: function (component, event, helper) {
    helper.fetchSizeValues(component, event, helper);
    component.set("v.updateSizePopup", true);
  },
  closeUpdateSizePopup: function (component, event, helper) {
    component.set("v.updateSizePopup", false);
  },
  openUpdateColorPopup: function (component, event, helper) {
    helper.fetchColorsValues(component, event, helper);
    component.set("v.updateColorPopup", true);
  },
  closeUpdateColorPopup: function (component, event, helper) {
    component.set("v.updateColorPopup", false);
  },
  closeArtworkPopup: function (component, event, helper) {
    component.set("v.artworkPopup", false);
  },

  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var idValue = component.get("v.recordId");
    var opportunityId = component.get("v.opportunityId");
    var action = component.get("c.getArtworks");

    action.setParams({
      recId: idValue
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        console.log("Response is ");
        var ab = response.getReturnValue();
        component.set("v.artworkList", ab);

        component.set("v.Spinner", false);
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
    helper.populateColors(component, event, helper);
    helper.populateSizes(component, event, helper);

    var action1 = component.get("c.getOpportunityStage1");
    action1.setParams({
      recid: opportunityId
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
  },
  deleteArtWork: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var recordToDelete = ctarget.dataset.value;

    var idValue = component.get("v.recordId");
    var action = component.get("c.deleteArtworkInDb");

    action.setParams({
      recId: recordToDelete,
      oppLineItem: idValue
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Artwork Succesfully Deleted"
          });
          toastEvent.fire();
          var creatUpdatePricingEvent = $A.get("event.c:teamPhunEventHandler");
          creatUpdatePricingEvent.fire();
          $A.get("e.force:refreshView").fire();
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "There is an Error Deleting Artwork"
          });
          toastEvent.fire();
        }
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
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
        if (state === "SUCCESS") {
          if (response.getReturnValue() == true) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Success",
              message: "Artwork succesfully edited"
            });
            toastEvent.fire();
            component.set("v.editArtworkPopup", false);
            $A.get("e.force:refreshView").fire();
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Error",
              message: "There is an error in editing artwork"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
        }
      });

      $A.enqueueAction(action);
    }
  },
  addArtwork: function (component, event, helper) {
    var idValue = component.get("v.recordId");
    var imprintType = component.find("imprintType").get("v.value", "");
    //var proofRequired=component.find("proofRequired").get("v.value","");
    var logoName = component.find("logoName").get("v.value", "");
    var logoSize = component.find("logoSize").get("v.value", "");
    var logoColor = component.find("logoColor").get("v.value", "");
    var repeatLogo = component.find("repeatLogo").get("v.value", "");
    var supplierNotes = component.find("supplierNotes").get("v.value", "");
    var documentId = component.get("v.documentId");
    var title = component.find("title").get("v.value", "");

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
    } else if (!documentId) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Attachment is required!"
      });
      toastEvent.fire();
    } else {
      var action = component.get("c.saveArtworkInDatabases");
      action.setParams({
        recId: idValue,
        imprintType: imprintType,
        proofRequired: "",
        logoName: logoName,
        logoSize: logoSize,
        logoColor: logoColor,
        repeatLogo: repeatLogo,
        supplierNotes: supplierNotes,
        documentId: documentId,
        title: title
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          if (response.getReturnValue() == true) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Success",
              message: "Artwork Succesfully Added"
            });
            toastEvent.fire();
            var creatUpdatePricingEvent = $A.get(
              "event.c:teamPhunEventHandler"
            );
            creatUpdatePricingEvent.fire();
            component.set("v.artworkPopup", false);
            $A.get("e.force:refreshView").fire();
          } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Error",
              message: "There is an Error adding Artwork"
            });
            toastEvent.fire();
          }
        } else {
          console.log("Failed with state: " + state);
        }
      });

      $A.enqueueAction(action);
    }
  }
});
