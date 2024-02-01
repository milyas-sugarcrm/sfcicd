import { LightningElement, api } from "lwc";
import generateSowPdfHandler from "@salesforce/apex/GenerateSOW.generateSowPdfHandler";
export default class GenerateSOWButton extends LightningElement {
  @api recordId;
  isGenerating = false;

  handleGenerateSOWClick() {
    this.isGenerating = true;
    generateSowPdfHandler({
      oppId: this.recordId,
      showGenerateApprovedSOW: false
    })
      .then((result) => {
        location.reload();
      })
      .catch((error) => {
        location.reload();
      })
      .finally(() => {
        this.isGenerating = false;
      });
  }
}
