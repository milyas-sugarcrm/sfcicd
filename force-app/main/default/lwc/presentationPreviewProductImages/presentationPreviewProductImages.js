import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getAttachedImagesToProduct from "@salesforce/apex/PresentationPreviewProductImagesCon.getAttachedImagesToProduct";
import setAttachedImagesToProduct from "@salesforce/apex/PresentationPreviewProductImagesCon.setAttachedImagesToProduct";
import getOpportunityStage from "@salesforce/apex/PresentationPreviewProductImagesCon.getOpportunityStage";

export default class PresentationPreviewProductImages extends LightningElement {
  @api recordId;
  @api opportunityId;
  @track contentDocs = [];
  @track contentDocId;
  @track opportunityStage;
  wiredMarketData = [];

  // This method will call an apex method to get all related images to a product.
  @wire(getAttachedImagesToProduct, { oppLineItemId: "$recordId" })
  contentDocs(response, error) {
    if (response) {
      this.wiredMarketData = response;
      var conts = response.data;
      for (var key in conts) {
        this.contentDocs.push({
          key: "/sfc/servlet.shepherd/document/download/" + String(key),
          value: conts[key]
        });
      }
    } else {
      console.log("Error in getAttachedImagesToProduct -> " + error);
    }
  }

  @wire(getOpportunityStage, { opportunityId: "$opportunityId" })
  opportunityStage(response, error) {
    if (response) {
      this.opportunityStage = response.data;
    } else {
      console.log("Error in getOpportunityStage -> " + error);
    }
  }

  get stage() {
    if (
      this.opportunityStage != "Presentation" &&
      this.opportunityStage != "Needs Analysis" &&
      this.opportunityStage != "Estimate" &&
      this.opportunityStage != null
    ) {
      return false;
    } else {
      return true;
    }
  }
  // This method will contain the ContentDocument ID for the opportunitylineitem.
  imageSelectionHandler(event) {
    var conts = event.currentTarget.dataset.id;
    this.contentDocId = conts.split("/").pop();
  }

  async refresh() {
    await refreshApex(this.wiredMarketData);
  }

  // This method will update the ContentDocument ID in the opportunitylineitem via apex code.
  updateImageHandler(event) {
    if (this.contentDocId != null) {
      setAttachedImagesToProduct({
        oppLineItemId: this.recordId,
        contentDocId: this.contentDocId
      }).then((response) => {
        if (response == true) {
          const messgae = new ShowToastEvent({
            message: "Image Updated Successfully",
            variant: "success",
            mode: "dismissable"
          });
          this.dispatchEvent(messgae);
          this.contentDocs = [];
          this.contentDocId = null;
          return this.refresh();
        } else {
          const messgae = new ShowToastEvent({
            message: "Error in image selection",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(messgae);
        }
      });
    } else {
      const messgae = new ShowToastEvent({
        message: "Please select image first!",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(messgae);
    }
  }
}
