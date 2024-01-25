import { LightningElement, wire, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getEventBillingRecords from "@salesforce/apex/BillingReportController.getEventBillingRecords";
import createRecords from "@salesforce/apex/BillingReportController.createRecords";
export default class BillingReport extends NavigationMixin(LightningElement) {
  @track error;
  @api recordId;
  @track billingReportRecords;
  @track eventStartDate = null;
  @track eventEndDate = null;
  @track filteredQuery = "";
  @track selectedPaymentStatus = "";
  @track selectAll = false;

  //will be maped to proper field after discussion with client
  paymentStatusOptions = [
    { label: "Paid", value: "paid" },
    { label: "Unpaid", value: "unpaid" }
  ];

  @track isLoading = false;

  @wire(getEventBillingRecords, { filterString: "$filteredQuery" })
  wiredCustomObjectRecords({ error, data }) {
    if (data) {
      this.selectAll = false;
      this.billingReportRecords = data;
      if (this.filteredQuery != "") {
        this.billingReportRecords = this.billingReportRecords.map((item) => ({
          ...item,
          isChecked: true
        }));
        this.selectAll = true;
      }
      this.filteredQuery = "";
      this.error = undefined;
      this.isLoading = false;
    } else if (error) {
      console.error(error);
      this.error = error;
      this.isLoading = false;
      this.billingReportRecords = undefined;
    }
  }

  handlePaymentStatusChange(event) {
    this.selectedPaymentStatus = event.detail.value;
  }

  handleEventStartDateChange(event) {
    this.eventStartDate = event.target.value;
  }

  handleEventEndDateChange(event) {
    this.eventEndDate = event.target.value;
  }

  handleGenerateClick(event) {
    let eventRecordIds = this.checkedItems();

    if (this.eventStartDate == null) {
      this.displayError("Error", "Kindly select Event Start Date");
    } else if (this.eventEndDate == null) {
      this.displayError("Error", "Kindly select Event End Date");
    } else if (
      eventRecordIds == null ||
      Object.keys(eventRecordIds).length == 0
    ) {
      this.displayError("Error", "Kindly select Records");
    } else {
      this.isLoading = true;
      createRecords({
        recordIds: eventRecordIds,
        eventStartDate: this.eventStartDate,
        eventEndDate: this.eventEndDate
      })
        .then((result) => {
          let completeUrl = window.location.origin + "/" + result;

          const event = new ShowToastEvent({
            title: "Success",
            message: "{0} Record has been created. Click {1} to open it!",
            messageData: [
              "Event Billing Report",
              {
                url: completeUrl,
                label: "here"
              }
            ],
            variant: "success",
            mode: "sticky"
          });

          this.dispatchEvent(event);
          this.filteredQuery = "";
          this.billingReportRecords = undefined;
          this.eventEndDate = null;
          this.eventStartDate = null;
          this.isLoading = false;
        })
        .catch((error) => {
          console.error(error);
          this.isLoading = false;
        });
    }
  }

  handleSearchClick() {
    if (this.eventStartDate == null) {
      this.displayError("Error", "Kindly select Event Start Date");
    } else if (this.eventEndDate == null) {
      this.displayError("Error", "Kindly select Event End Date");
    } else {
      this.isLoading = true;
      this.filteredQuery =
        " AND Event_End_Date__c >= " +
        this.eventStartDate +
        " AND Event_End_Date__c <= " +
        this.eventEndDate;
    }
  }

  displayError(title, message) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: "error",
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }

  handleNavigate(event) {
    this.recId = event.target.dataset.item;
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.recId,
        actionName: "view"
      }
    });
  }

  handleCheckboxChange(event) {
    const recordId = event.target.value;
    const checked = event.target.checked;

    if (checked == false) {
      this.selectAll = false;
    }
    this.billingReportRecords = this.billingReportRecords.map((item) => ({
      ...item,
      isChecked: item.Id === recordId ? checked : item.isChecked
    }));
  }

  handleCheckAll(event) {
    const checked = event.target.checked;
    this.selectAll = checked;
    this.billingReportRecords = this.billingReportRecords.map((item) => ({
      ...item,
      isChecked: checked
    }));
  }

  checkedItems() {
    if (this.billingReportRecords != undefined) {
      return this.billingReportRecords
        .filter((item) => item.isChecked)
        .map((item) => item.Id);
    } else {
      return null;
    }
  }
}
