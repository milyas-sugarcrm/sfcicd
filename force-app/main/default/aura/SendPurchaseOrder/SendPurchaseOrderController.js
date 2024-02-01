({
  doInit: function (component, event, helper) {
    var action = component.get("c.emailTemplatePO");
    action.setParams({
      recordId: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      component.set("v.body", response.getReturnValue());
    });
    var action1 = component.get("c.getPOPdf");
    action1.setParams({
      recordId: component.get("v.recordId")
    });
    action1.setCallback(this, function (response) {
      var attachmentList = response.getReturnValue();
      var mailAttachment = component.get("v.attachments");
      var tempData = {};
      tempData["name"] = attachmentList[0];
      tempData["documentId"] = attachmentList[1];
      tempData["contentVersionId"] = attachmentList[2];
      tempData["icon"] = attachmentList[0].split(".").pop().toLowerCase();
      mailAttachment.push(tempData);
      component.set("v.attachments", mailAttachment);
      component.set("v.attachment", attachmentList[0]);
    });
    var action2 = component.get("c.getOrgWideEmail");
    action2.setCallback(this, function (response) {
      component.set("v.fromEmails", response.getReturnValue());
      component
        .find("fromEmail")
        .set("v.value", response.getReturnValue()[0].Address);
    });
    var action3 = component.get("c.getToAddress");
    action3.setParams({
      recordId: component.get("v.recordId")
    });
    action3.setCallback(this, function (response) {
      component.set("v.toEmail", response.getReturnValue());
    });
    var action4 = component.get("c.getSubject");
    action4.setParams({
      recordId: component.get("v.recordId")
    });
    action4.setCallback(this, function (response) {
      component.set("v.subject", response.getReturnValue());
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
    $A.enqueueAction(action1);
    $A.enqueueAction(action2);
    $A.enqueueAction(action3);
    $A.enqueueAction(action4);
  },
  sendMail: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var fromEmail = component.find("fromEmail").get("v.value");
    var toEmail = component.get("v.toEmail");
    var ccEmails = component.get("v.ccEmail");
    var getSubject = component.get("v.subject");
    var getbody = component.get("v.body");
    var attachmentsData = component.get("v.attachments");

    let cvIds = new Array();

    for (var i = 0; i < attachmentsData.length; i++) {
      cvIds.push(attachmentsData[i].contentVersionId);
    }

    let arr = new Array();

    for (var i = 0; i < ccEmails.length; i++) {
      arr.push(ccEmails[i].Email);
    }
    if (toEmail === "" || $A.util.isEmpty(toEmail) || !toEmail.includes("@")) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Please Enter a Valid Vendor Email Address to Send PO"
      });
      toastEvent.fire();
      $A.get("e.force:closeQuickAction").fire();
    } else {
      helper.sendHelper(
        component,
        recordId,
        fromEmail,
        toEmail,
        arr,
        getSubject,
        getbody,
        cvIds
      );
      component.set("v.Spinner", true);
    }
  },
  closeEmailPopup: function (component, event, helper) {
    component.set("v.emailPopup", false);
  },
  handleUploadFinished: function (component, event, helper) {
    var uploadedFiles = event.getParam("files");
    var mailAttachments = component.get("v.attachments");
    for (var i = 0; i < uploadedFiles.length; i++) {
      var tempData = {};
      tempData["name"] = uploadedFiles[i].name;
      tempData["documentId"] = uploadedFiles[i].documentId;
      tempData["contentVersionId"] = uploadedFiles[i].contentVersionId;
      var extension = uploadedFiles[i].name.split(".").pop().toLowerCase();
      if (["jpeg", "jpg", "png", "gif"].includes(extension)) {
        tempData["icon"] = "image";
      } else if (
        [
          "ai",
          "csv",
          "excel",
          "pdf",
          "psd",
          "txt",
          "word",
          "xml",
          "zip"
        ].includes(extension)
      ) {
        tempData["icon"] = extension;
      } else {
        tempData["icon"] = "attachment";
      }
      mailAttachments.push(tempData);
    }
    component.set("v.attachments", mailAttachments);
  },
  previewFile: function (c, e, h) {
    var selectedPillId = e.getSource().get("v.name");
    $A.get("e.lightning:openFiles").fire({
      recordIds: [selectedPillId]
    });
  },
  handleRemove: function (component, event, helper) {
    event.preventDefault();
    var selectedPillId = event.getSource().get("v.name");
    var attachmentList = component.get("v.attachments");
    for (var i = 0; i < attachmentList.length; i++) {
      if (attachmentList[i].documentId === selectedPillId) {
        attachmentList.splice(i, 1);
      }
    }
    component.set("v.attachments", attachmentList);
  }
});
