import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getEvents from "@salesforce/apex/PfaEventListView.getEvents";
import getClientAccountId from "@salesforce/apex/PfaEventListView.getClientAccountId";
import deleteEventRecord from "@salesforce/apex/PfaEventListView.deleteEventRecord";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

export default class PfaEventListView extends NavigationMixin(
  LightningElement
) {
  @api recordId; // Campaign Id

  REFRESH_LABEL = "Refresh";
  CREATE_NEW_EVENT_LABEL = "Create New Event";
  EVENTS_LABEL = "Events";
  NAME_LABEL = "Name";
  EVENT_START_DATE_LABEL = "Event Start Date";
  EVENT_END_DATE_LABEL = "Event End Date";
  CONTACT_LABEL = "Contact";
  SCHEDULE_CONFIRMATION_LABEL = "Schedule Confirmation";
  EVENT_STATUS_LABEL = "Event Status";
  EVENT_WORKFLOW_STATUS_LABEL = "Event Workflow Status";
  ACTION_LABEL = "Action";
  DELETE_LABEL = "Delete";
  NO_EVENT_MSG = "No Event to show";

  @track events = [];
  @track clientAccountId = "";
  @track eventsSpinner = false;
  @track selectedFilter = "Active";
  @track filterOptions = [
    { label: "All Events", value: "All Events" },
    { label: "Active", value: "Active" },
    { label: "Canceled", value: "Canceled" },
    { label: "Completed", value: "Completed" }
  ];

  get isEvents() {
    return this.events.length ? true : false;
  }

  async connectedCallback() {
    this.getEvents();
    this.getClientAccountId();
  }

  // set filter value and refresh events
  handleFilterChange(event) {
    this.selectedFilter = event?.detail?.value;
    this.getEvents();
  }

  // get relevent events according to the filter value
  getEvents() {
    this.eventsSpinner = true;
    getEvents({ campaignId: this.recordId, status: this.selectedFilter })
      .then((result) => {
        this.events = result;
      })
      .finally(() => {
        this.eventsSpinner = false;
      });
  }

  // get relevent events according to the filter value
  getClientAccountId() {
    this.eventsSpinner = true;
    getClientAccountId({ campaignId: this.recordId })
      .then((result) => {
        this.clientAccountId = result;
      })
      .finally(() => {
        this.eventsSpinner = false;
      });
  }

  // to create new event in new tab
  handleCreateNewEvent() {
    const defaultValues = encodeDefaultFieldValues({
      PFA_Campaign_Id__c: this.recordId,
      Account__c: this.clientAccountId
    });

    this[NavigationMixin.GenerateUrl]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "PFA_Event__c",
        actionName: "new"
      },
      state: {
        defaultFieldValues: defaultValues
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  handleDeleteAction(event) {
    const eventId = event?.currentTarget?.dataset?.eventid;
    if (eventId) {
      if (confirm("Are you sure you want to delete this event?")) {
        deleteEventRecord({ eventId: eventId });
        this.events = this.events.filter((item) => item.Id !== eventId);
      }
    }
  }

  // open the record detail page in new tab
  openRecordDetailView(event) {
    const recordId = event?.currentTarget?.dataset?.eventid;
    if (recordId) {
      this[NavigationMixin.GenerateUrl]({
        type: "standard__recordPage",
        attributes: {
          recordId: recordId,
          actionName: "view"
        }
      }).then((url) => {
        window.open(url, "_blank");
      });
    }
  }
}
