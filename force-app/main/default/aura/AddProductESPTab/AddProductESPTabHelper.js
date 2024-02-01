({
  helperMethod: function () {},
  calculateValues: function (component, filterValue, attributeName) {
    var tmpValue = component.get(attributeName);

    if (tmpValue != undefined) {
      if (filterValue != undefined) {
        if (!filterValue.includes("--")) {
          /*if(tmpValue.length >0){
                        filterValue = tmpValue+","+filterValue;                            
                    }*/
          component.set(attributeName, filterValue);
        }
      }
    } else {
      component.set(attributeName, filterValue);
    }
  },
  calculateValuesOLD: function (component, filterValue, attributeName) {
    var tmpValue = component.get(attributeName);
    var lastIndex = tmpValue.lastIndexOf(",");
    var lastString = tmpValue.substring(lastIndex + 1);
    if (tmpValue != undefined) {
      if (filterValue != undefined) {
        if (filterValue != lastString && !filterValue.includes("--")) {
          /*if(tmpValue.length >0){
                        filterValue = tmpValue+","+filterValue;                            
                    }*/
          component.set(attributeName, filterValue);
        }
      }
    } else {
      component.set(attributeName, filterValue);
    }
  },
  calculateValuesAll: function (component, filterValue, attributeName) {
    var tmpValue = component.get(attributeName);
    if (tmpValue != undefined) {
      if (filterValue != undefined) {
        component.set(attributeName, filterValue);
      }
    } else {
      component.set(attributeName, filterValue);
    }
  },
  createComponent: function (
    component,
    componentType,
    componentAttributes,
    targetElement
  ) {
    $A.getCallback(function () {
      $A.createComponent(
        "c:wrapper",
        {
          componentType: componentType,
          componentAttributes: componentAttributes,
          targetElement: targetElement
        },
        function (wrapperComponent, status, errorMessage) {
          if (status === "INCOMPLETE") {
            return;
          } else if (status === "ERROR") {
            return;
          }

          var renderBox = component.find("ratingStatus");
          var body = renderBox.get("v.body") || [];
          body.push(wrapperComponent);
          renderBox.set("v.body", body);
        }
      );
    })();
  }
});
