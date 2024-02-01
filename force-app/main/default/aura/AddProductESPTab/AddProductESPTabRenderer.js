({
  afterRender: function (component, helper) {
    this.superAfterRender();
    var didScroll = false;

    window.onscroll = function () {
      didScroll = true;
    };

    var idOfSetInterval = window.setInterval(
      $A.getCallback(function () {
        // Since setInterval happens outside the component's lifecycle
        // We need to check if component exist, only then logic needs to be processed
        var previousProducts;
        if (component.get("v.productList") != null)
          previousProducts = component.get("v.productList");
        if (
          didScroll &&
          component.isValid() &&
          previousProducts != null &&
          previousProducts.Results != null &&
          previousProducts.Results.length < component.get("v.totalProducts")
        ) {
          didScroll = false;
          if (
            component.get("v.RenderOnce") &&
            window["innerHeight"] + document.documentElement.scrollTop >=
              document.getElementById("allProds").scrollHeight
          ) {
            component.set("v.RenderOnce", false);
            var isFilter = component.get("v.isFilter");
            if (isFilter == false) {
              component.set("v.isFilter", true);
            } else {
              var currentPage = component.get("v.currentPage");
              var nextPage = currentPage + 1;
              component.set("v.currentPage", nextPage);
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
            var checkFullColorProcess = component.find(
              "checkboxFullColorProcess"
            );
            var fullColorProcessdValue = checkFullColorProcess.get("v.value");
            var checkCanadianFriendly = component.find(
              "checkboxCanadianFriendly"
            );
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
            helper.calculateValues(
              component,
              FilterImprintingMethods,
              attributeName
            );
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
                component.set("v.RenderOnce", true);
                component.set("v.Spinner", false);
                var productList = response.getReturnValue();
                if (productList.Results != null) {
                  for (var i = 0; i < productList.Results.length; i++) {
                    previousProducts.Results.push(productList.Results[i]);
                  }
                }
                component.set("v.productList", previousProducts);
                if (productList.Results.length == 0) {
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                    type: "Error",
                    message: "No Products Found"
                  });
                  toastEvent.fire();
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
          }
        }
      }),
      1000
    );
    // Save the id.We need to use in unrender to remove the setInterval()
    // component.set( "v.setIntervalId", idOfSetInterval );
  }
});
