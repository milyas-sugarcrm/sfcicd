({
  helperMethod: function () {},

  fetchPickListVal: function (component, fieldName, elementId, object) {
    component.set("v.Spinner", true);
    var action = component.get("c.getPicklistValues");
    action.setParams({
      objectType: object,
      field: fieldName
    });
    var opts = [];
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var allValues = response.getReturnValue();
        for (var i = 0; i < allValues.length; i++) {
          opts.push({
            class: "optionClass",
            label: allValues[i],
            value: allValues[i]
          });
        }
        var elem = component.find(elementId);
        if (elem != null) {
          elem.set("v.options", opts);
        }
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },

  fetchShiptoPicklistVal: function (
    component,
    fieldName,
    elementId,
    object,
    recId
  ) {
    component.set("v.Spinner", true);
    var action = component.get("c.getPicklistModifiedValues");
    action.setParams({
      objectType: object,
      field: fieldName,
      recid: recId
    });
    var opts = [];
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        var allValues = response.getReturnValue();
        for (var i = 0; i < allValues.length; i++) {
          opts.push({
            class: "optionClass",
            label: allValues[i],
            value: allValues[i]
          });
        }
        var elem = component.find(elementId);
        if (elem != null) {
          elem.set("v.options", opts);
        }
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  fetchCompanyPicklistValues: function (component, elementId) {
    component.set("v.Spinner", true);
    var action = component.get("c.getCompanyAddresses");
    var opts = [];
    action.setCallback(this, function (response) {
      var responseLstObject = response.getReturnValue();
      component.set("v.Shipping_CompanyAddresses", response.getReturnValue());
      component.set(
        "v.Decorator_Shipping_CompanyAddresses",
        response.getReturnValue()
      );
      if (responseLstObject.length > 0) {
        var lstCompanyAddress = component.get("v.Shipping_CompanyAddresses");
        var companyId = component.get(
          "v.Shipping_InformationItems.Company_Address__c"
        );
        if (companyId != null && companyId.length > 0) {
          for (var key in lstCompanyAddress) {
            if (lstCompanyAddress[key].Id == companyId) {
              component.set(
                "v.Shipping_CompanyAddresses_Selected",
                lstCompanyAddress[key]
              );
            }
          }
        } else {
          component.set(
            "v.Shipping_CompanyAddresses_Selected",
            responseLstObject[0]
          );
        }
        var decoratorCompanyId = component.get(
          "v.ShippingObject.Company_Address__c"
        );
        if (decoratorCompanyId != null && decoratorCompanyId.length > 0) {
          for (var key in lstCompanyAddress) {
            if (lstCompanyAddress[key].Id == decoratorCompanyId) {
              component.set(
                "v.DecoratorSelectedAddress",
                lstCompanyAddress[key]
              );
            }
          }
        } else {
          component.set("v.DecoratorSelectedAddress", responseLstObject[0]);
        }
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },

  saveData: function (component, shippingRecord, shippingInformation) {
    component.set("v.Spinner", true);
    var shipTo = shippingInformation.Ship_To__c;
    var decoratorShippingInfo;
    var decoratorShippingAddressInfo;
    var supplierShippingInfo;
    var supplierShippingAddressInfo;
    var supplierShippingAddress;
    var clientAdd;
    var otherAdd;
    var decoratorAdd;
    var decoratorClientAddr;
    if (shipTo == "Other Supplier") {
      supplierShippingInfo = shippingRecord.Supplier__c;
      supplierShippingAddressInfo = shippingRecord.Supplier_Address__c;
      supplierShippingAddress = component
        .find("supplierAddresslookup")
        .get("v.value");
      console.log(supplierShippingAddress);
    } else if (shipTo == "Decorator") {
      decoratorShippingInfo = shippingRecord.Decorator__c;
      decoratorShippingAddressInfo = shippingRecord.Decorator_Address__c;
      decoratorAdd = component.find("DecoratorAddresslookup").get("v.value");
      if (shippingRecord.Ship_To__c == "Client") {
        var test = component.find("decorator_ShippingAccountMethodsAddress");
        if (test != undefined && test.length == undefined) {
          decoratorClientAddr = test.get("v.value");
        } else {
          decoratorClientAddr = test[0].get("v.value");
        }
      }
    } else if (shipTo == "Client") {
      clientAdd = component.find("selectedClientAdd").get("v.value");
    } else if (shipTo == "Other") {
      otherAdd = component.find("otherAdd").get("v.value");
    }
    var action = component.get("c.saveData");
    action.setParams({
      shippingInformation: shippingInformation,
      supplierAccount: shippingInformation.Supplier__c,
      shipping_Rec: shippingRecord,
      decorator: decoratorShippingInfo,
      decorator_address: decoratorShippingAddressInfo,
      decorator_supplier: supplierShippingInfo,
      decorator_supplier_address: supplierShippingAddressInfo,
      clientAddress: clientAdd,
      otherAddress: otherAdd,
      otherSupplierAddress: supplierShippingAddress,
      decoratorAddress: decoratorAdd,
      decoratorClientAddress: decoratorClientAddr
    });
    var opts = [];
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "ERROR") {
        var errors = response.getError();
        var toastEvent = $A.get("e.force:showToast");
        var errorMessage = "Unknown Error";
        if (errors) {
          if (errors[0] && errors[0].message) {
            errorMessage = errors[0].message;
          }
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Error",
          message: errorMessage
        });
        toastEvent.fire();
      }
      if (state === "SUCCESS") {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          type: "Success",
          message: "Shipping Information Updated"
        });
        toastEvent.fire();
      }
      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  }
});
