({
  handleResetClick: function (component, event, helper) {
    component.find("NetMin").set("v.value", "");
    component.find("NetMax").set("v.value", "");
    component.find("Supplier").set("v.value", "");
    component.find("searchName").set("v.value", "");
  },

  keyCheck: function (component, event, helper) {
    if (event.which == 13) {
      $A.enqueueAction(component.get("c.handleSearchClick"));
    }
  },

  //to check validation on search criteria and call apex method to get search result
  handleSearchClick: function (component, event, helper) {
    component.set("v.SpinnerTeamPhun", true);
    var isValid = "true";
    var netMin = component.find("NetMin").get("v.value");
    var netMax = component.find("NetMax").get("v.value");
    var supplier = component.find("Supplier").get("v.value");
    var searchName = component.find("searchName").get("v.value");
    var isFilter = component.get("v.isFilter");
    if (isFilter == false) {
      component.set("v.isFilter", true);
    } else {
      component.set("v.currentPage", 1);
      component.set("v.currentPageNumber", 1);
    }
    //search field validation
    if (Number(netMin) > Number(netMax) && netMax != "") {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Net Max value must be greater than Net Min"
      });
      toastEvent.fire();
      isValid = "false";
    }
    if (isNaN(netMin) || isNaN(netMax)) {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        type: "Error",
        message: "Net Min or Net Max value must be numeric"
      });
      toastEvent.fire();
      isValid = "false";
    }
    component.set("v.SpinnerTeamPhun", true);
    if (isValid == "true") {
      var tabName = component.get("v.tabname");
      var offset = component.get("v.currentPage");
      var action = component.get("c.getSearchResults");
      action.setParams({
        netMin: netMin,
        netMax: netMax,
        supplier: supplier,
        searchName: searchName,
        offset: offset,
        tabName: tabName
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var productList = response.getReturnValue();
          component.set("v.SpinnerTeamPhun", false);
          console.log("-----setCallback--SUCCESS--productList---");
          console.log(productList);
          if (productList === null) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Error",
              message: "No Products Found"
            });
            toastEvent.fire();
          } else {
            component.set("v.productList", productList);
            var totalProductsSize = productList[0].totalProducts;
            component.set("v.totalProducts", totalProductsSize);
          }
        } else {
          component.set("v.SpinnerTeamPhun", false);
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            type: "Error",
            message: "Failed with state: " + state
          });
          toastEvent.fire();
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.SpinnerTeamPhun", false);
    }
  },

  nextPage: function (component, event, helper) {
    var currentPageNumber = component.get("v.currentPageNumber");
    var nextPageNumber = currentPageNumber + 1;
    component.set("v.currentPageNumber", nextPageNumber);

    component.set("v.isFilter", false);
    var currentPage = component.get("v.currentPage");
    var nextPage = currentPage + 24;
    component.set("v.currentPage", nextPage);
    $A.enqueueAction(component.get("c.handleSearchClick"));
  },
  previousPage: function (component, event, helper) {
    var currentPageNumber = component.get("v.currentPageNumber");
    var previousPageNumber = currentPageNumber - 1;
    component.set("v.currentPageNumber", previousPageNumber);

    component.set("v.isFilter", false);
    var currentPage = component.get("v.currentPage");
    var previousPage = currentPage - 24;
    component.set("v.currentPage", previousPage);
    $A.enqueueAction(component.get("c.handleSearchClick"));
  },

  handleAddProduct: function (component, event, helper) {
    console.log("--handleAddProduct--");
  },
  openPopupSearchView: function (component, event, helper) {
    console.log("--openPopupSearchView--");
  }
});
