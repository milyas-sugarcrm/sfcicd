import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getPfaProductsofOpp from "@salesforce/apex/PfaProductListViewOpportunity.getPfaProductsofOpp";
import removeOppLineItem from "@salesforce/apex/PfaProductListViewOpportunity.removeOppLineItem";
import searchPfaProducts from "@salesforce/apex/PfaProductListViewOpportunity.searchPfaProducts";
import createOppLineItem from "@salesforce/apex/PfaProductListViewOpportunity.createOppLineItem";
import getPfaProductTypeId from "@salesforce/apex/PfaProductListViewOpportunity.getPfaProductTypeId";

export default class PfaProductListViewOpportunity extends NavigationMixin(
  LightningElement
) {
  @api recordId; // Opportunity Id

  @track showAddProductCard = false;
  @track addProductBtnLabel = "Add Product";
  @track searchResults = [];
  @track oppLineitems = [];
  @track searchString = "";
  @track searchSpinner = false;
  @track selectedProductsSpinner = false;
  @track createNewSpinner = false;

  removeItemId;
  pfaRecordTypeId = "";

  get isSearchItem() {
    return this.searchResults.length ? true : false;
  }

  get isSelectedItem() {
    return this.oppLineitems.length ? true : false;
  }

  async connectedCallback() {
    this.getLineItems();
    this.pfaRecordTypeId = await getPfaProductTypeId();
  }

  // get the line items to display
  getLineItems() {
    this.selectedProductsSpinner = true;
    getPfaProductsofOpp({ oppId: this.recordId })
      .then((result) => {
        this.oppLineitems = result;
        this.selectedProductsSpinner = false;
      })
      .catch((error) => {
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
    this.addItemId = event.currentTarget.dataset.itemid;
    createOppLineItem({ productId: this.addItemId, OppId: this.recordId }).then(
      (result) => {
        this.getLineItems();
      }
    );
    this.searchResults = this.searchResults.filter(
      (item) => item.Id !== this.addItemId
    );
  }

  // open a create PFA product popup
  async handleCreateNewProduct() {
    const objectApiName = "Product2";
    this[NavigationMixin.GenerateUrl]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: objectApiName,
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
    this.searchString = event?.target.value;
    this.searchProducts();
  }

  // fetch products by search string
  searchProducts() {
    if (this.searchString.length >= 2) {
      this.searchSpinner = true;
      searchPfaProducts({ searchString: this.searchString })
        .then((result) => {
          this.searchResults = result;
          this.oppLineitems.forEach((lineItem) => {
            this.searchResults = this.searchResults.filter(
              (item) => item.Id !== lineItem.Product_ID__c
            );
          });
          this.searchSpinner = false;
        })
        .catch((error) => {
          this.searchSpinner = false;
        });
    } else {
      this.searchResults = [];
    }
  }

  // remove Line Item
  handleRemoveAction(event) {
    this.removeItemId = event.currentTarget.dataset.itemid;
    removeOppLineItem({ oppLineItemId: this.removeItemId })
      .then((result) => {})
      .catch((error) => {});
    this.oppLineitems = this.oppLineitems.filter(
      (item) => item.Id !== this.removeItemId
    );
    this.searchProducts();
  }

  // open the record detail page in new tab
  openRecordDetailView(event) {
    const recordId = event.currentTarget.dataset.itemid;
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
