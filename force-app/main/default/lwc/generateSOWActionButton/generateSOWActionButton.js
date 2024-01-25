import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import generateSowPdfHandler from "@salesforce/apex/GenerateSOW.generateSowPdfHandler";
import { CurrentPageReference } from "lightning/navigation";

export default class GenerateSowLWC extends NavigationMixin(LightningElement) {
  recordId;
  @track generatingSOW = true;

  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      this.recordId = currentPageReference.state.recordId;
    }
  }

  connectedCallback() {
    this.generateSowPdf();
  }

  generateSowPdf() {
    generateSowPdfHandler({ oppId: this.recordId })
      .then((result) => {
        if (result.success === "true") {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: result.msg,
              variant: "success"
            })
          );
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: result.msg,
              variant: "error"
            })
          );
        }
      })
      .catch((error) => {
        console.error("Error in calling generateSowPdfHandler:", error);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "An error occurred while generating the SOW PDF",
            variant: "error"
          })
        );
      })
      .finally(() => {
        this.generatingSOW = false;

        // Reload the current page
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: this.recordId,
            objectApiName: "Opportunity",
            actionName: "view"
          }
        });
      });
  }
}
