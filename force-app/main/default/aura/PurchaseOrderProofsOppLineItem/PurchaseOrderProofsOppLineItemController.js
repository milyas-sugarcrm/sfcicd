({
  hideUploadFileOption: function (component, event, helper) {
    var componentToHide = event.getSource().get("v.name");
    var divs = component.find("fileUploadLightning");
    console.log(divs);
    if (event.getSource().get("v.checked")) {
      if (divs != null) {
        if (divs.length == undefined) {
          $A.util.removeClass(divs, "showDetails");
          $A.util.addClass(divs, "hideCom");
        } else {
          for (var i = 0; i < divs.length; i++) {
            console.log(divs[i]);
            if (divs[i].get("v.name") == componentToHide) {
              $A.util.removeClass(divs[i], "showDetails");
              $A.util.addClass(divs[i], "hideCom");
            }
          }
        }
      }
    } else {
      if (divs != null) {
        if (divs.length == undefined) {
          $A.util.addClass(divs, "showDetails");
          $A.util.removeClass(divs, "hideCom");
        } else {
          for (var i = 0; i < divs.length; i++) {
            if (divs[i].get("v.name") == componentToHide) {
              $A.util.addClass(divs[i], "showDetails");
              $A.util.removeClass(divs[i], "hideCom");
            }
          }
        }
      }
    }
    var action = component.get("c.changeAllProofsUploadedStatus");
    action.setParams({
      purchaseOrderId: event.getSource().get("v.name"),
      changedStatus: event.getSource().get("v.checked")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS" && response.getReturnValue() != null) {
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "Error while updating status. Kindly contact your administrator"
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.getDetailsRelatedPurchaseOrderProofs");
    action.setParams({
      purchaseOrderId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      var ab = response.getReturnValue();
      component.set("v.purchaseOrderProofsDetails", response.getReturnValue());
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  handleUploadFinished: function (component, event) {
    var documentId;
    var fileName;
    if (event.getParam("files").length > 0) {
      fileName = event.getParam("files")[0].name;
      documentId = event.getParam("files")[0].documentId;
    }
    component.set("v.documentId", documentId);
    component.set("v.fileName", fileName);
    if (documentId != null && fileName != null) {
      var action = component.get("c.createNewProof");
      action.setParams({
        documentId: documentId,
        fileName: fileName,
        purchaseOrderLineItemId: event.getSource().get("v.name"),
        purchaseOrderId: component.get("v.recordId")
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS" && response.getReturnValue() != null) {
          var ab = response.getReturnValue();
          component.set(
            "v.purchaseOrderProofsDetails",
            response.getReturnValue()
          );
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "Error while adding comment to proof. Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  proofPicklistStatusChange: function (component, event, helper) {
    var proofId = event.getSource().get("v.name");
    var changedStatus = event.getSource().get("v.value");
    if (proofId != null && changedStatus != null) {
      var action = component.get("c.changeStatusOfProofPicklist");
      action.setParams({
        proofId: proofId,
        purchaseOrderId: component.get("v.recordId"),
        changedStatus: changedStatus
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS" && response.getReturnValue() != null) {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Status changed successfully"
          });
          toastEvent.fire();
          var ab = response.getReturnValue();
          component.set(
            "v.purchaseOrderProofsDetails",
            response.getReturnValue()
          );
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "Error while adding comment to proof. Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  addCommentForProof: function (component, event, helper) {
    var textArea = component.find("commentTextarea");
    var proofId = event.getSource().get("v.name");
    var valueToSave;
    if (textArea != null) {
      if (textArea.length == undefined) {
        valueToSave = textArea.get("v.value");
        textArea.set("v.value", "");
      } else {
        for (var i = 0; i < textArea.length; i++) {
          if (textArea[i].get("v.name") == proofId) {
            valueToSave = textArea[i].get("v.value");
            textArea[i].set("v.value", "");
          }
        }
      }
    }
    if (valueToSave != null && valueToSave.length > 0) {
      var action = component.get("c.addCommentForProofInDB");
      action.setParams({
        proofId: event.getSource().get("v.name"),
        purchaseOrderId: component.get("v.recordId"),
        comment: valueToSave
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS" && response.getReturnValue() != null) {
          var ab = response.getReturnValue();
          component.set(
            "v.purchaseOrderProofsDetails",
            response.getReturnValue()
          );
        } else {
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message:
              "Error while adding comment to proof. Kindly contact your administrator"
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    }
  },
  refresh: function (component, event, helper) {
    $A.get("e.force:refreshView").fire();
  }
});
