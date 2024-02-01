({
  doInit: function (component, event, helper) {
    var action = component.get("c.getNotesAttachmentData");

    action.setParams({
      purchaseOrderLineItemId: component.get("v.recordId")
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ab = response.getReturnValue();
        component.set("v.notesDataList", response.getReturnValue());
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
    var action1 = component.get("c.getUserPic");

    action1.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var ab = response.getReturnValue();
        component.set("v.imageURL", response.getReturnValue());
      } else {
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action1);
  },
  handleUploadFinished: function (component, event, helper) {
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
  addNote: function (component, event, helper) {
    var comment = component.find("noteTextArea").get("v.value");

    if (comment == "") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please add a note to post"
      });
      toastEvent.fire();
    } else {
      component.set("v.Spinner", true);
      var isFileUploaded = component.get("v.fileUploaded");
      var action = component.get("c.addCommentAndAttachment");

      var documentId = component.get("v.documentId");
      action.setParams({
        purchaseOrderId: component.get("v.recordId"),
        isFileUploaded: isFileUploaded,
        documentId: documentId,
        comment: comment
      });

      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state == "SUCCESS") {
          component.set("v.notesDataList", response.getReturnValue());
          component.set("v.fileUploaded", false);
          component.find("noteTextArea").set("v.value", "");
          component.set("v.Spinner", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Success",
            message: "Comment added successfully"
          });
          toastEvent.fire();
        } else {
          console.log("Failed with state: " + state);
          component.set("v.Spinner", false);
        }
      });
      $A.enqueueAction(action);
    }
  }
});
