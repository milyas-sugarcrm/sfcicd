({
  postRender: function (component) {
    console.log("Reached");
  },
  handleResetClick: function (component, event, helper) {
    component.set("v.Spinner", true);
    component.set("v.productList", null);
    component.set("v.RatingSet", false);
    component.set("v.SpecificRatingSet", false);
    component.find("NetMin").set("v.value", "");
    component.find("NetMax").set("v.value", "");
    component.find("searchName").set("v.value", "");
    component.find("Market").set("v.value", "");
    component.find("Sort").set("v.value", "");
    component.find("ProdTime").set("v.value", "");
    component.find("MinQuantity").set("v.value", "");

    var dynamicFilter = component.find("FilterCategories");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("checkboxFullColorProcess");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("checkboxCanadianFriendly");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("checkboxNew");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("checkboxCanadianPriced");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("checkboxMadeInUsa1");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("checkboxMadeInUsa");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", false);
    }
    dynamicFilter = component.find("Preferred");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "All");
    }
    dynamicFilter = component.find("FilterColors");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterImprintingMethods");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterLineNames");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterPrices");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterSizes");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterSuppliers");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterMaterials");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterStates");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterAsiNumbers");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterThemes");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterTradeNames");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("FilterShapes");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "--");
    }
    dynamicFilter = component.find("Rating");
    if (dynamicFilter != null) {
      dynamicFilter.set("v.value", "");
    }
    component.find("v.Rating", "--");
    component.set("v.FilterCategoriesValues", "");
    component.set("v.FilterColorsValues", "");
    component.set("v.FilterImprintingMethodsValues", "");
    component.set("v.FilterLineNameValues", "");
    component.set("v.FilterPricesValues", "");
    component.set("v.FilterSizesValues", "");
    component.set("v.FilterSuppliersValues", "");
    component.set("v.FilterMaterialsValues", "");
    component.set("v.FilterStatesValues", "");
    component.set("v.FilterAsiNumbersValues", "");
    component.set("v.FilterThemesValues", "");
    component.set("v.FilterTradeNamesValues", "");
    component.set("v.FilterShapesValues", "");
    component.set("v.FilterPreferredValues", "");
    component.set("v.Spinner", false);
  },
  nextPage: function (component, event, helper) {
    component.set("v.isFilter", false);
    var currentPage = component.get("v.currentPage");
    var nextPage = currentPage + 1;
    component.set("v.currentPage", nextPage);
    if (component.get("v.Spinner") != true) {
      $A.enqueueAction(component.get("c.handleSearchClick"));
    }
  },
  previousPage: function (component, event, helper) {
    component.set("v.isFilter", false);
    var currentPage = component.get("v.currentPage");
    var nextPage = currentPage - 1;
    component.set("v.currentPage", nextPage);
    if (component.get("v.Spinner") != true) {
      $A.enqueueAction(component.get("c.handleSearchClick"));
    }
  },
  disableButtons: function (component, event, helper) {
    var currentPage = component.get("v.currentPage");
  },
  keyCheck: function (component, event, helper) {
    if (event.which == 13) {
      $A.enqueueAction(component.get("c.handleSearchClick"));
    }
  },
  handleSearchClick: function (component, event, helper) {
    var isFilter = component.get("v.isFilter");

    if (isFilter == false) {
      component.set("v.isFilter", true);
    } else {
      component.set("v.currentPage", 1);
    }
    var currentPage = component.get("v.currentPage");
    var netMin = component.find("NetMin").get("v.value", "");
    var netMax = component.find("NetMax").get("v.value", "");
    var searchName = component.find("searchName").get("v.value", "");
    var market = component.find("Market").get("v.value", "");
    var FilterCategories;
    var FilterColors;
    var FilterImprintingMethods;
    var FilterLineNames;
    var FilterPrices;
    var FilterSizes;
    var FilterSuppliers;
    var FilterMaterials;
    var FilterStates;
    var FilterAsiNumbers;
    var FilterMinQuantity;
    var FilterThemes;
    var FilterTradeNames;
    var FilterProdTime;
    var FilterShapes;
    var FilterPreferred;
    component.find("unhide").set("v.value", 1);
    var dynamicFilter = component.find("FilterCategories");
    if (dynamicFilter != null) {
      FilterCategories = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterColors");
    if (dynamicFilter != null) {
      FilterColors = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterImprintingMethods");
    if (dynamicFilter != null) {
      FilterImprintingMethods = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterLineNames");
    if (dynamicFilter != null) {
      FilterLineNames = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterPrices");
    if (dynamicFilter != null) {
      FilterPrices = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterSizes");
    if (dynamicFilter != null) {
      FilterSizes = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterSuppliers");
    if (dynamicFilter != null) {
      FilterSuppliers = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterMaterials");
    if (dynamicFilter != null) {
      FilterMaterials = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("MinQuantity");
    if (dynamicFilter != null) {
      FilterMinQuantity = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("ProdTime");
    if (dynamicFilter != null) {
      FilterProdTime = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("MinQuantity");
    if (dynamicFilter != null) {
      FilterMinQuantity = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterStates");
    if (dynamicFilter != null) {
      FilterStates = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterAsiNumbers");
    if (dynamicFilter != null) {
      FilterAsiNumbers = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterThemes");
    if (dynamicFilter != null) {
      FilterThemes = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterTradeNames");
    if (dynamicFilter != null) {
      FilterTradeNames = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("Preferred");
    if (dynamicFilter != null) {
      FilterPreferred = dynamicFilter.get("v.value", "");
    }
    dynamicFilter = component.find("FilterShapes");
    if (dynamicFilter != null) {
      FilterShapes = dynamicFilter.get("v.value", "");
    }
    var sort = component.find("Sort").get("v.value", "");
    var rating = component.find("Rating").get("v.value", "");
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
        message: "Net Min or Net Max value must be Numeric"
      });
      toastEvent.fire();
      isValid = "false";
    }
    var cmpTarget = component.find("checkboxNew1");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("checkboxFullColorProcess1");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("checkboxMadeInUsa1");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("prodTime");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("minQuantity");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("preferred");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterCategoriesColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterColorsColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterFilterLineNamesColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterMoreOptionsColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterSizesColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterSuppliersColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("filterMaterialsColumn");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var cmpTarget = component.find("rating");
    $A.util.removeClass(cmpTarget, "show_details");
    $A.util.addClass(cmpTarget, "more_options");
    var currentButton = component.find("unhide");
    currentButton.set("v.iconName", "utility:chevrondown");
    component.set("v.Spinner", true);
    var checkCmp = component.find("checkboxNew");
    var newCheckbox = checkCmp.get("v.value");
    var checkCanadianPriced = component.find("checkboxCanadianPriced");
    var canadianPricedValue = checkCanadianPriced.get("v.value");
    var checkFullColorProcess = component.find("checkboxFullColorProcess");
    var fullColorProcessdValue = checkFullColorProcess.get("v.value");
    var checkCanadianFriendly = component.find("checkboxCanadianFriendly");
    var canadianFriendlyValue = checkCanadianFriendly.get("v.value");
    var checkMadeInUsa = component.find("checkboxMadeInUsa");
    var madeInUsaValue = checkMadeInUsa.get("v.value");
    if (searchName != undefined) {
      var tmpValue = component.get("v.FilterSearchValues");
      if (tmpValue != undefined && tmpValue == searchName) {
      } else {
        FilterCategories = "";
        FilterColors = "";
        FilterImprintingMethods = "";
        FilterLineNames = "";
        FilterPrices = "";
        FilterSizes = "";
        FilterSuppliers = "";
        FilterMaterials = "";
        FilterStates = "";
        FilterAsiNumbers = "";
        FilterAsiNumbers = "";
        FilterThemes = "";
        FilterTradeNames = "";
        FilterShapes = "";
        FilterPreferred = "";
        var dynamicFilterRating = component.find("Rating");
        if (dynamicFilterRating != null) {
          dynamicFilterRating.set("v.value", "");
        }
        component.find("ProdTime").set("v.value", "");
        component.find("MinQuantity").set("v.value", "");
        component.set("v.FilterCategoriesValues", "");
        component.set("v.FilterColorsValues", "");
        component.set("v.FilterImprintingMethodsValues", "");
        component.set("v.FilterLineNameValues", "");
        component.set("v.FilterPricesValues", "");
        component.set("v.FilterSizesValues", "");
        component.set("v.FilterSuppliersValues", "");
        component.set("v.FilterMaterialsValues", "");
        component.set("v.FilterStatesValues", "");
        component.set("v.FilterAsiNumbersValues", "");
        component.set("v.FilterThemesValues", "");
        component.set("v.FilterTradeNamesValues", "");
        component.set("v.FilterShapesValues", "");
        component.set("v.FilterPreferredValues", "");
        var dynamicFilter = component.find("checkboxFullColorProcess");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
        dynamicFilter = component.find("checkboxCanadianFriendly");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
        dynamicFilter = component.find("checkboxNew");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
        dynamicFilter = component.find("checkboxCanadianPriced");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
        dynamicFilter = component.find("checkboxMadeInUsa1");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
        dynamicFilter = component.find("checkboxMadeInUsa");
        if (dynamicFilter != null) {
          dynamicFilter.set("v.value", false);
        }
      }
      component.set("v.FilterSearchValues", searchName);
    }
    var attributeName = "v.FilterCategoriesValues";
    helper.calculateValues(component, FilterCategories, attributeName);
    FilterCategories = component.get(attributeName);
    var attributeName = "v.FilterColorsValues";
    helper.calculateValues(component, FilterColors, attributeName);
    FilterColors = component.get(attributeName);
    var attributeName = "v.FilterImprintingMethodsValues";
    helper.calculateValues(component, FilterImprintingMethods, attributeName);
    FilterImprintingMethods = component.get(attributeName);
    var attributeName = "v.FilterLineNameValues";
    helper.calculateValues(component, FilterLineNames, attributeName);
    FilterLineNames = component.get(attributeName);
    var attributeName = "v.FilterPricesValues";
    helper.calculateValues(component, FilterPrices, attributeName);
    FilterPrices = component.get(attributeName);
    var attributeName = "v.FilterSizesValues";
    helper.calculateValues(component, FilterSizes, attributeName);
    FilterSizes = component.get(attributeName);
    var attributeName = "v.FilterSuppliersValues";
    helper.calculateValues(component, FilterSuppliers, attributeName);
    FilterSuppliers = component.get(attributeName);
    var attributeName = "v.FilterMaterialsValues";
    helper.calculateValues(component, FilterMaterials, attributeName);
    FilterMaterials = component.get(attributeName);
    var attributeName = "v.FilterStatesValues";
    helper.calculateValues(component, FilterStates, attributeName);
    FilterStates = component.get(attributeName);
    var attributeName = "v.FilterAsiNumbersValues";
    helper.calculateValues(component, FilterAsiNumbers, attributeName);
    FilterAsiNumbers = component.get(attributeName);
    var attributeName = "v.FilterThemesValues";
    helper.calculateValues(component, FilterThemes, attributeName);
    FilterThemes = component.get(attributeName);
    var attributeName = "v.FilterTradeNamesValues";
    helper.calculateValues(component, FilterTradeNames, attributeName);
    FilterTradeNames = component.get(attributeName);
    var attributeName = "v.FilterShapesValues";
    helper.calculateValues(component, FilterShapes, attributeName);
    FilterShapes = component.get(attributeName);
    var attributeName = "v.FilterPreferredValues";
    helper.calculateValues(component, FilterPreferred, attributeName);
    FilterPreferred = component.get(attributeName);
    console.log("sort name: " + sort);
    var action = component.get("c.getSearchResultsFromESP");
    action.setParams({
      netMin: netMin,
      netMax: netMax,
      supplier: "",
      searchName: searchName,
      market: market,
      FilterCategories: FilterCategories,
      FilterColors: FilterColors,
      FilterImprintingMethods: FilterImprintingMethods,
      FilterLineNames: FilterLineNames,
      FilterPrices: FilterPrices,
      FilterSizes: FilterSizes,
      FilterSuppliers: FilterSuppliers,
      FilterMaterials: FilterMaterials,
      FilterStates: FilterStates,
      FilterAsiNumbers: FilterAsiNumbers,
      FilterThemes: FilterThemes,
      FilterTradeNames: FilterTradeNames,
      FilterShapes: FilterShapes,
      sortType: sort,
      newFilter: newCheckbox,
      fullColorProcessFilter: fullColorProcessdValue,
      madeInUSAFilter: madeInUsaValue,
      canadianFriendFilter: canadianFriendlyValue,
      canadianPricedFilter: canadianPricedValue,
      minQuantity: FilterMinQuantity,
      FilterProdTime: FilterProdTime,
      FilterPreferred: FilterPreferred,
      pageToDisplay: currentPage,
      rating: rating
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var productList = response.getReturnValue();
        component.set("v.Spinner", false);
        if (productList != null) {
          var totalProductsSize = productList.ResultsTotal;
          if (totalProductsSize != undefined) {
            var finalSize = totalProductsSize.replace(/[()]/g, "");
            component.set("v.totalProducts", finalSize);
          }
          console.log(productList);
          component.set("v.productList", productList);

          if (productList.Results.length == 0) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "Error",
              message: "No Products Found"
            });
            toastEvent.fire();
          }
        }
      } else {
        component.set("v.Spinner", false);
        var errors = response.getError();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message:
            "Error!! Server is not responding. Please try again or contact developer support"
        });
        toastEvent.fire();
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  onRender: function (cmp, event, helper) {
    //console.log('IN RATING FUNCTION');

    var productDetails = cmp.get("v.productList.Results");
    var ratingSet = cmp.get("v.RatingSet");
    if (productDetails != null && productDetails.length > 0) {
      cmp.set("v.RatingSet", true);
      for (var i = 0; i < productDetails.length; i++) {
        document.getElementById(
          "ratingStatus" + productDetails[i].Id
        ).innerHTML = "";

        if (
          productDetails[i] != null &&
          productDetails[i].Supplier != null &&
          productDetails[i].Supplier.Rating != null &&
          productDetails[i].Supplier.Rating.Rating != null
        ) {
          var count = productDetails[i].Supplier.Rating.Rating;
          if (count == 1) {
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.halfStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 4; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 2) {
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 4; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 3) {
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.halfStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 3; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 4) {
            for (var j = 0; j < 2; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 3; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 5) {
            for (var j = 0; j < 2; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.halfStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 2; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 6) {
            for (var j = 0; j < 3; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 2; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 7) {
            for (var j = 0; j < 3; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.halfStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 8) {
            document.getElementById(
              "ratingStatus" + productDetails[i].Id
            ).innerHtml = "";
            for (var j = 0; j < 4; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.grayStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 9) {
            document.getElementById(
              "ratingStatus" + productDetails[i].Id
            ).innerHtml = "";
            for (var j = 0; j < 4; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
            for (var j = 0; j < 1; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.halfStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          } else if (count == 10) {
            document.getElementById(
              "ratingStatus" + productDetails[i].Id
            ).innerHtml = "";
            for (var j = 0; j < 5; j++) {
              var img = document.createElement("img");
              img.src = $A.get("$Resource.fillStar");
              img.style.width = "25px";
              document
                .getElementById("ratingStatus" + productDetails[i].Id)
                .appendChild(img);
            }
          }
        } else if (
          productDetails[i] != null &&
          productDetails[i].Supplier != null &&
          productDetails[i].Supplier.Rating == null
        ) {
          var ratingLabel = document.createElement("label");
          ratingLabel.innerText = "Not Rated";
          ratingLabel.style = "font-size:14px";
          document
            .getElementById("ratingStatus" + productDetails[i].Id)
            .appendChild(ratingLabel);
        }
      }
    }

    var specificRatingSet = cmp.get("v.SpecificRatingSet");
    //var specificProductRating =cmp.get("v.SearchDetails.Supplier.Rating.Rating");
    //var specificProductRatingCompanies =cmp.get("v.SearchDetails.Supplier.Rating.Companies");
    if (
      cmp.get("v.SearchDetails.Supplier.Rating.Rating") != null &&
      document.getElementById("RatingForSpecificProduct") != null &&
      specificRatingSet == false
    ) {
      cmp.set("v.SpecificRatingSet", true);
      var count = cmp.get("v.SearchDetails.Supplier.Rating.Rating");
      if (count == 1) {
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.halfStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 4; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 2) {
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 4; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 3) {
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.halfStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 3; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 4) {
        for (var j = 0; j < 2; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 3; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 5) {
        for (var j = 0; j < 2; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.halfStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 2; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 6) {
        for (var j = 0; j < 3; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 2; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 7) {
        for (var j = 0; j < 3; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.halfStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 8) {
        for (var j = 0; j < 4; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.grayStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 9) {
        for (var j = 0; j < 4; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
        for (var j = 0; j < 1; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.halfStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else if (count == 10) {
        for (var j = 0; j < 5; j++) {
          var img = document.createElement("img");
          img.src = $A.get("$Resource.fillStar");
          img.style.width = "25px";
          document.getElementById("RatingForSpecificProduct").appendChild(img);
        }
      } else {
        var ratingLabel = document.createElement("label");
        ratingLabel.innerText = "Not Rated";
        ratingLabel.style = "font-size:14px";
        document
          .getElementById("RatingForSpecificProduct")
          .appendChild(ratingLabel);
      }
      if (cmp.get("v.SearchDetails.Supplier.Rating.Companies") != null) {
        var specificProductRatingCompanies = cmp.get(
          "v.SearchDetails.Supplier.Rating.Companies"
        );
        var ratingLabel = document.createElement("label");
        ratingLabel.innerText = " (" + specificProductRatingCompanies + ")";
        ratingLabel.style = "vertical-align:text-top;font-size:18px";
        document
          .getElementById("RatingForSpecificProduct")
          .appendChild(ratingLabel);
      }
    } else if (
      cmp.get("v.SearchDetails.Supplier.Rating.Rating") == null &&
      document.getElementById("RatingForSpecificProduct") != null
    ) {
      var ratingLabel = document.createElement("label");
      ratingLabel.innerText = "Not Rated";
      ratingLabel.style = "font-size:14px";
      document
        .getElementById("RatingForSpecificProduct")
        .appendChild(ratingLabel);
    }
  },
  openMoreOptions: function (cmp, event) {
    var buttonValue = cmp.find("unhide").get("v.value");
    var currentButton = event.getSource();
    if (buttonValue == 1) {
      cmp.find("unhide").set("v.value", 2);
      var cmpTarget = cmp.find("checkboxNew1");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("checkboxFullColorProcess1");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("checkboxMadeInUsa1");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("prodTime");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("minQuantity");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("preferred");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("rating");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterCategoriesColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterColorsColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterFilterLineNamesColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterMoreOptionsColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterSizesColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterSuppliersColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      var cmpTarget = cmp.find("filterMaterialsColumn");
      $A.util.removeClass(cmpTarget, "more_options");
      $A.util.addClass(cmpTarget, "show_details");
      currentButton.set("v.iconName", "utility:chevronup");
    } else {
      cmp.find("unhide").set("v.value", 1);
      var cmpTarget = cmp.find("checkboxNew1");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("checkboxFullColorProcess1");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("checkboxMadeInUsa1");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("rating");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("prodTime");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("minQuantity");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("preferred");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterCategoriesColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterColorsColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterFilterLineNamesColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterMoreOptionsColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterSizesColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterSuppliersColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      var cmpTarget = cmp.find("filterMaterialsColumn");
      $A.util.removeClass(cmpTarget, "show_details");
      $A.util.addClass(cmpTarget, "more_options");
      currentButton.set("v.iconName", "utility:chevrondown");
    }
  },
  handleAddProduct: function (component, event, helper) {
    component.set("v.SpinnerVariant", true);
    component.set("v.Spinner", true);
    var productId = component.get("v.selectedProductId");
    var variantId;
    var opportunityId = null;
    var estimateId = null;
    var workOrderId = null;
    var variantColor = null;
    var variantSize = null;
    if (component.get("v.recordFrom") == "Opportunity") {
      opportunityId = component.get("v.recordId");
    } else if (component.get("v.recordFrom") == "Estimate") {
      estimateId = component.get("v.recordId");
    } else if (component.get("v.recordFrom") == "SalesOrder") {
      workOrderId = component.get("v.recordId");
    }
    console.log("---handleAddProduct----");
    console.log(event);
    if (event != undefined) {
      var ctarget = event.currentTarget;
      variantId = ctarget.dataset.record;
    }
    var productDetails = component.get("v.productList.Results");
    for (var a = 0; a < productDetails.length; a++) {
      if (productDetails[a].Id == productId) {
        component.set("v.SearchDetails", productDetails[a]);
        break;
      }
    }

    var adId = null;
    var adPosition = null;
    if (
      component.get("v.SearchDetails") != null &&
      component.get("v.SearchDetails").ad != null
    ) {
      if (component.get("v.SearchDetails").ad.Id != null)
        adId = component.get("v.SearchDetails").ad.Id;
      if (component.get("v.SearchDetails").ad.Position != null)
        adPosition = component.get("v.SearchDetails").ad.Position;
    }
    if (component.get("v.selectedColorValue") != null) {
      variantColor = component.get("v.selectedColorValue");
    }
    if (component.get("v.selectedSizeValue") != null) {
      variantSize = component.get("v.selectedSizeValue");
    }
    var action = component.get("c.createOpportunityLineItemEsp");
    action.setParams({
      productId: productId,
      opportunityId: opportunityId,
      variantId: variantId,
      estimateId: estimateId,
      adId: adId,
      adPosition: adPosition,
      recordFrom: component.get("v.recordFrom"),
      workOrderId: workOrderId,
      variantColor: variantColor,
      variantSize: variantSize
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() == true) {
          $A.enqueueAction(component.get("c.showToast"));
        } else {
          $A.enqueueAction(component.get("c.showToastError"));
          console.log("Status: " + response.getReturnValue());
        }
      } else {
        $A.enqueueAction(component.get("c.showToastError"));
        console.log("Failed with state: " + state);
      }
      component.set("v.SpinnerVariant", false);
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  openVariantPopup: function (component, event, helper) {
    component.set("v.openSearchDetailsPopoup", false);
    component.set("v.SpecificRatingSet", false);
    component.set("v.Spinner", true);
    component.set("v.SpinnerVariant", true);
    var ctarget = event.currentTarget;
    var productId = ctarget.dataset.value;
    var opportunityId = component.get("v.recordId");
    var action = component.get("c.getVariants");
    var productDetails = component.get("v.productList.Results");
    var prodID = event.currentTarget.dataset.value;
    for (var a = 0; a < productDetails.length; a++) {
      if (productDetails[a].Id == prodID) {
        component.set("v.SearchDetails", productDetails[a]);
        break;
      }
    }

    component.set("v.selectedProductId", productId);
    action.setParams({
      productId: productId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var variantList = response.getReturnValue();
        component.set("v.variantList", variantList);
        console.log(variantList);
        if (variantList.lstVariants.length == 0) {
          $A.enqueueAction(component.get("c.handleAddProduct"));
        } else {
          component.set("v.variantPopup", true);
          component.set("v.Spinner", false);
          component.set("v.SpinnerVariant", false);
        }
      } else {
        $A.enqueueAction(component.get("c.showToastError"));
        component.set("v.Spinner", false);
        component.set("v.SpinnerVariant", false);
        console.log("Failed with state: " + state);
      }
    });
    $A.enqueueAction(action);
  },
  showToast: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "Success",
      message: "The Product has been added successfully."
    });
    toastEvent.fire();
  },
  showToastError: function (component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: "Error",
      message: "Some parsing error occured while adding the product."
    });
    toastEvent.fire();
  },
  closeModal: function (component, event, helper) {
    component.set("v.variantPopup", false);
  },
  openPopupSearchView: function (component, event, helper) {
    component.set("v.Spinner", true);
    var productDetails = component.get("v.productList.Results");
    var prodID = event.currentTarget.dataset.value;
    for (var a = 0; a < productDetails.length; a++) {
      if (productDetails[a].Id == prodID) {
        component.set("v.SearchDetails", productDetails[a]);
        break;
      }
    }
    console.log(prodID);
    var action = component.get("c.getSpecificProductDetails");
    action.setParams({
      productId: prodID
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      {
        var prodValues = response.getReturnValue();
        console.log(prodValues);
        component.set("v.SearchDetailsSingleProduct", prodValues);
        component.set("v.Spinner", false);
        component.set("v.openSearchDetailsPopoup", true);
      }
    });
    $A.enqueueAction(action);
  },
  closeSearchDetaislPopoup: function (component, event, helper) {
    component.set("v.openSearchDetailsPopoup", false);
    component.set("v.SpecificRatingSet", false);
  },
  viewSearchDetailsPage: function (component, event, helper) {
    var url = location.href;
    var ratingValue = 0;
    if (component.get("v.SearchDetails.Supplier.Rating.Rating") != null) {
      ratingValue = component.get("v.SearchDetails.Supplier.Rating.Rating");
    }
    var ratingCount = 0;
    if (component.get("v.SearchDetails.Supplier.Rating.Companies") != null) {
      ratingCount = component.get("v.SearchDetails.Supplier.Rating.Companies");
    }
    var adPosition = null;
    var adId = null;
    if (
      component.get("v.SearchDetails") != null &&
      component.get("v.SearchDetails").ad != null
    ) {
      if (component.get("v.SearchDetails").ad.Id != null)
        adId = component.get("v.SearchDetails").ad.Id;
      if (component.get("v.SearchDetails").ad.Position != null)
        adPosition = component.get("v.SearchDetails").ad.Position;
    }
    var baseURL = url.substring(0, url.indexOf("/", 14));
    var prodId = event.currentTarget.dataset.value;
    var recordType = component.get("v.recordFrom");
    var action = component.get("c.getOpportunityId");
    var id = component.get("v.recordId");
    action.setParams({
      recId: id
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      {
        var prodValues = response.getReturnValue();
        console.log("----viewSearchDetailsPage---" + prodValues);
        var url2 =
          baseURL +
          "/apex/ESPSearchDetailsPage?Id=" +
          prodValues +
          "&ProductId=" +
          prodId +
          "&recordFrom=" +
          recordType +
          "&adId=" +
          adId +
          "&adPosition=" +
          adPosition +
          "&isEspProduct=false";
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: url2
        });
        urlEvent.fire();
      }
    });
    $A.enqueueAction(action);
  },
  displayListView: function (component, event, helper) {
    component.set("v.listview", true);
    component.set("v.galleryview", false);
  },
  displayGalleryView: function (component, event, helper) {
    component.set("v.galleryview", true);
    component.set("v.listview", false);
  }
});
