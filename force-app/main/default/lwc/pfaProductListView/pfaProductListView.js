import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getPfaProductLineItems from "@salesforce/apex/PfaProductListView.getPfaProductLineItems";
import removeLineItem from "@salesforce/apex/PfaProductListView.removeLineItem";
import searchPfaProducts from "@salesforce/apex/PfaProductListView.searchPfaProducts";
import createLineItem from "@salesforce/apex/PfaProductListView.createLineItem";
import getPfaProductTypeId from "@salesforce/apex/PfaProductListView.getPfaProductTypeId";

export default class PfaProductListView extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  @api objectApiName;

  oppId = null;
  campaignId = null;
  eventId = null;

  SEARCH_PFA_PRODUCT_LABEL = "Search PFA Product";
  ADD_PRODUCT_LABEL = "Add Product";
  CREATE_NEW_PRODUCT_LABEL = "Create New Product";
  PRODUCT_NAME_LABEL = "Product Name";
  PRODUCT_CATEGORY_LABEL = "Product Category";
  PRODUCT_BARCODE_LABEL = "Product Barcode";
  PRODUCT_MSRP_LABEL = "Product MSRP";
  ACTION_LABEL = "Action";
  NO_ITEM_MSG = "No Item Selected Yet";
  ADD_LABEL = "Add";
  REMOVE_LABEL = "Remove";

  @track showAddProductCard = false;
  @track addProductBtnLabel = "Add Product";
  @track searchResults = [];
  @track lineitems = [];
  @track searchString = "";
  @track searchSpinner = false;
  @track selectedProductsSpinner = false;
  @track createNewSpinner = false;

  pfaRecordTypeId = "";

  get isSearchItem() {
    return this.searchResults?.length ? true : false;
  }

  get isSelectedItem() {
    return this.lineitems?.length ? true : false;
  }

  async connectedCallback() {
    this.setIds();
    this.getLineItems();
    this.pfaRecordTypeId = await getPfaProductTypeId();
  }

  // sets Ids w.r.t. Object Record Detail page
  setIds() {
    if (this.objectApiName === "Opportunity") {
      this.oppId = this.recordId;
    }
    if (this.objectApiName === "PFA_Campaign__c") {
      this.campaignId = this.recordId;
    }
    if (this.objectApiName === "PFA_Event__c") {
      this.eventId = this.recordId;
    }
  }

  // get the line items to display
  getLineItems() {
    this.selectedProductsSpinner = true;
    getPfaProductLineItems({
      oppId: this.oppId,
      campaignId: this.campaignId,
      eventId: this.eventId
    })
      .then((result) => {
        this.lineitems = result ? result : [];
      })
      .finally(() => {
        this.selectedProductsSpinner = false;
      });
  }

  // open and close the view of Adding product
  handleAddProductView() {
    if (this.showAddProductCard === false) {
      this.showAddProductCard = true;
      this.addProductBtnLabel = "Done Adding";
      this.searchString = "";
      this.searchResults = [];
    } else if (this.showAddProductCard === true) {
      this.showAddProductCard = false;
      this.addProductBtnLabel = "Add Product";
    }
  }

  // add the clicked product id to line items
  handleAddproduct(event) {
    const addItemId = event?.currentTarget?.dataset?.itemid;
    if (addItemId) {
      createLineItem({
        productId: addItemId,
        campaignId: this.campaignId,
        oppId: this.oppId,
        eventId: this.eventId
      }).then((result) => {
        this.getLineItems();
      });
      this.searchResults = this.searchResults.filter(
        (item) => item.Id !== addItemId
      );
    }
  }

  // open a create PFA product popup
  async handleCreateNewProduct() {
    this[NavigationMixin.GenerateUrl]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Product2",
        actionName: "new"
      },
      state: {
        recordTypeId: this.pfaRecordTypeId
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  // set search string value
  handleSearchChange(event) {
    this.searchString = event?.target?.value;
    this.searchProducts();
  }

  // fetch products by search string
  searchProducts() {
    if (this.searchString?.length >= 2) {
      this.searchSpinner = true;
      searchPfaProducts({ searchString: this.searchString })
        .then((result) => {
          this.searchResults = result;
          this.lineitems.forEach((lineItem) => {
            this.searchResults = this.searchResults.filter(
              (item) => item.Id !== lineItem.Product_ID__c
            );
          });
        })
        .finally(() => {
          this.searchSpinner = false;
        });
    } else {
      this.searchResults = [];
    }
  }

  // remove Line Item
  handleRemoveAction(event) {
    const removeItemId = event?.currentTarget?.dataset?.itemid;
    if (removeItemId) {
      removeLineItem({ lineItemId: removeItemId }).then((result) => {
        this.searchProducts();
      });
      this.lineitems = this.lineitems.filter(
        (item) => item.Id !== removeItemId
      );
    }
  }

  // open the record detail page in new tab
  openRecordDetailView(event) {
    const recordId = event?.currentTarget?.dataset?.itemid;
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
