({
  handleResetClick: function (component, event, helper) {
    console.log("Reset Clicked");
    component.find("NetMin").set("v.value", "");
    component.find("NetMax").set("v.value", "");
    component.find("Supplier").set("v.value", "");
    component.find("searchName").set("v.value", "");
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
  keyCheck: function (component, event, helper) {
    if (event.which == 13) {
      $A.enqueueAction(component.get("c.handleSearchClick"));
    }
  },
  changeSlide: function (component, event, helper) {
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var elements = component.find(id_str);

    $A.util.addClass(component.find(id_str), "testing");
  },

  handleSearchClick: function (component, event, helper) {
    console.log("heyeyeyeyyee: " + component.get("v.temVar"));
    component.set("v.SpinnerTeamPhun", true);
    var isValid = "true";
    var netMin = component.find("NetMin").get("v.value", "");
    var netMax = component.find("NetMax").get("v.value", "");
    var supplier = component.find("Supplier").get("v.value", "");
    var searchName = component.find("searchName").get("v.value", "");
    var isFilter = component.get("v.isFilter");
    if (isFilter == false) {
      component.set("v.isFilter", true);
    } else {
      component.set("v.currentPage", 1);
      component.set("v.currentPageNumber", 1);
    }

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
      console.log("tab name is " + tabName);
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
  handleAddProduct: function (component, event, helper) {
    component.set("v.openSearchDetailsPopoup", false);
    component.set("v.SpinnerTeamPhun", true);
    var ctarget = event.currentTarget;
    var productId = ctarget.dataset.value;
    var opportunityId = null;
    var estimateId = null;
    var workOrderId = null;
    if (component.get("v.recordFrom") == "Opportunity") {
      opportunityId = component.get("v.recordId");
    } else if (component.get("v.recordFrom") == "Estimate") {
      estimateId = component.get("v.recordId");
    }
    //to get work order id if products is being added from the Sales order tab
    else if (component.get("v.recordFrom") == "SalesOrder") {
      workOrderId = component.get("v.recordId");
    }
    console.log("--recordId---" + component.get("v.recordId"));
    var action = component.get("c.createOpportunityLineItem");
    action.setParams({
      productId: productId,
      opportunityId: opportunityId,
      recordFrom: component.get("v.recordFrom"),
      estimateId: estimateId,
      workOrderId: workOrderId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      component.set("v.SpinnerTeamPhun", false);
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          $A.enqueueAction(component.get("c.showToast"));
        } else {
          console.log("Status: " + response.getReturnValue());
        }
        component.set("v.SpinnerTeamPhun", false);
        //                $A.enqueueAction(component.get('c.showToast'));
        //               console.log("Succsfully Added");
      } else {
        console.log("Failed with state: " + state);
        component.set("v.SpinnerTeamPhun", false);
      }
    });
    $A.enqueueAction(action);
  },

  showToast: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "Success",
      message: "The Product has been Added successfully."
    });
    toastEvent.fire();
  },
  openPopupSearchView: function (component, event, helper) {
    var productDetails = component.get("v.productList");
    var prodID = event.currentTarget.dataset.value;
    for (var a = 0; a < productDetails.length; a++) {
      if (productDetails[a].id == prodID) {
        component.set("v.SearchDetails", productDetails[a]);
        break;
      }
    }
    component.set("v.openSearchDetailsPopoup", true);
  },
  closeSearchDetaislPopoup: function (component, event, helper) {
    component.set("v.openSearchDetailsPopoup", false);
  },
  viewSearchDetailsPage: function (component, event, helper) {
    var url = location.href;
    var baseURL = url.substring(0, url.indexOf("/", 14));
    var prodId = event.currentTarget.dataset.value;
    var action = component.get("c.getOpportunityId");
    var id = component.get("v.recordId");
    action.setParams({
      recId: id
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      {
        var prodValues = response.getReturnValue();
        console.log(
          baseURL +
            "/apex/TeamPhunSearchDetailspage?Id=" +
            prodValues +
            "&ProductId=" +
            prodId
        );
        var url =
          baseURL +
          "/apex/TeamPhunSearchDetailspage?Id=" +
          prodValues +
          "&ProductId=" +
          prodId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: url
        });
        urlEvent.fire();
        //window.open(baseURL+"/apex/TeamPhunSearchDetailspage?Id="+prodValues+"&ProductId="+prodId, '_blank');
      }
    });
    $A.enqueueAction(action);
  }
});
