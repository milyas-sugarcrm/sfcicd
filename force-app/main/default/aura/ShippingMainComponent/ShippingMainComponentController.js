({
  doInit: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.getRelatedShipping_InformationItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      debugger;
      component.set("v.Shipping_InformationItems", response.getReturnValue());
      var objectShippingInformation = component.get(
        "v.Shipping_InformationItems"
      );
      var objectShipping = component.get("v.ShippingObject");
      if (response.getReturnValue() != null) {
        component.set(
          "v.SelectedOtherAddress",
          objectShippingInformation.Other_Address__c
        );
        component.set("v.Size", response.getReturnValue().length);
      } else {
        component.set("v.Size", "0");
      }
      var action1 = component.get("c.getRelatedShipping_Items");
      var shippingInformationId = component.get(
        "v.Shipping_InformationItems.Id"
      );
      action1.setParams({
        recid: shippingInformationId
      });
      action1.setCallback(this, function (response) {
        component.set("v.ShippingObject", response.getReturnValue());
        console.log("response.getReturnValue(): ");
        console.log(response.getReturnValue());
        var otherSupplierInitialize = component.find("supplierlookup2");
        otherSupplierInitialize.initalizeData();
        var decoratorInitialize = component.find("decoratorlookup");
        decoratorInitialize.initalizeData();
        helper.fetchShiptoPicklistVal(
          component,
          "Ship_To__c",
          "Shipping_Information",
          objectShippingInformation,
          component.get("v.recordId")
        );
        helper.fetchPickListVal(
          component,
          "Shipping_Method__c",
          "ShippingMethods",
          objectShippingInformation
        );
        helper.fetchCompanyPicklistValues(
          component,
          "ShippingMethodsAddress",
          objectShippingInformation
        );
        helper.fetchShiptoPicklistVal(
          component,
          "Ship_To__c",
          "DecorartorShipping_Information",
          objectShipping,
          component.get("v.recordId")
        );
        helper.fetchPickListVal(
          component,
          "Shipping_Method__c",
          "DecoratorShippingMethods",
          objectShipping
        );
        console.log(response.getReturnValue().Decorator_Shipping_Address__c);
        component.set(
          "v.SelectedDecoratorAddress",
          component.get("v.ShippingObject.Decorator_Shipping_Address__c")
        );
        component.set(
          "v.SelectedAccountAddress",
          component.get("v.ShippingObject.Other_Supplier_Address__c")
        );
        var supplierInitialize = component.find("supplierlookup");
        supplierInitialize.initalizeData();
        $A.enqueueAction(component.get("c.onChangeShippingTo"));
        $A.enqueueAction(component.get("c.onChangingDecoratorShippingTo"));
      });
      $A.enqueueAction(action1);
    });
    $A.enqueueAction(action);
  },
  promises: function (component, event, helper) {
    component.set("v.Spinner", true);
    var action = component.get("c.getRelatedShipping_InformationItems");
    action.setParams({
      recid: component.get("v.recordId")
    });
    AuraPromise.serverSideCall(action, component).then(
      function (shippingInformationObject) {
        component.set("v.Shipping_InformationItems", shippingInformationObject);
        var objectShippingInformation = component.get(
          "v.Shipping_InformationItems"
        );
        var objectShipping = component.get("v.ShippingObject");
        if (shippingInformationObject != null) {
          component.set("v.Size", response.getReturnValue().length);
        } else {
          component.set("v.Size", "0");
        }
      }
    );
  },
  handleComponentEvent: function (component, event, helper) {
    var selectedAccountGetFromEvent = event.getParam("selectedRecordByEvent");
    var otherSupplierInitialize = component.find(selectedAccountGetFromEvent);
    otherSupplierInitialize.clearData();
  },
  callSaveMethod: function (component, event, helper) {
    var shipTo = component.get("v.Shipping_InformationItems.Ship_To__c");
    var shippingMethod = component.get(
      "v.Shipping_InformationItems.Shipping_Method__c"
    );
    var requiredFieldsList = [];
    var error = false;
    var selectShipTo = false;
    var selectShippingMethod = false;
    try {
      if (
        component.get("v.Shipping_InformationItems.Supplier__c").Id == undefined
      ) {
        requiredFieldsList.push("Supplier");
      }
    } catch (e) {
      requiredFieldsList.push("Supplier");
    }
    if (shippingMethod === undefined || shippingMethod === "--none--") {
      selectShippingMethod = true;
      requiredFieldsList.push("Shipping Method");
    }
    if (shipTo == "--None--") {
      selectShipTo = true;
    } else if (shipTo == "Other Supplier") {
      try {
        if (component.get("v.ShippingObject.Supplier__c").Id == undefined) {
          requiredFieldsList.push("Supplier");
        }
      } catch (e) {
        requiredFieldsList.push("Supplier");
      }
      try {
        if (component.find("supplierAddresslookup").get("v.value") == "") {
          requiredFieldsList.push("Supplier Address");
        }
      } catch (e) {
        requiredFieldsList.push("Supplier Address");
      }
    } else if (shipTo == "Decorator") {
      try {
        if (component.get("v.ShippingObject.Decorator__c").Id == undefined) {
          requiredFieldsList.push("Decorator");
        }
      } catch (e) {
        requiredFieldsList.push("Decorator");
      }
      try {
        if (component.find("DecoratorAddresslookup").get("v.value") == "") {
          requiredFieldsList.push("Decorator Address");
        }
      } catch (e) {
        requiredFieldsList.push("Decorator Address");
      }
    } else if (shipTo.includes("Client")) {
      var addressClient = component.get("v.SelectedClientAddress");
      if (!addressClient) {
        requiredFieldsList.push("Address");
      }
    } else if (shipTo == "Other") {
      var otherAddress = component.find("otherAdd").get("v.value");
      if (!otherAddress) {
        requiredFieldsList.push("Address");
      }
    } else {
      var addressTeamPhun = component
        .find("ShippingMethodsAddress")
        .get("v.value", "");
      if (!addressTeamPhun) {
        requiredFieldsList.push("Address");
      }
    }

    if (
      requiredFieldsList.length != 0 ||
      selectShipTo == true ||
      selectShippingMethod == true
    ) {
      component.set(
        "v.Error",
        "These required fields must be completed: " +
          requiredFieldsList.toString()
      );
    } else {
      component.set("v.Error", null);
      helper.saveData(
        component,
        component.get("v.ShippingObject"),
        component.get("v.Shipping_InformationItems")
      );
    }
  },
  onChangingDecoratorShippingTo: function (component, event) {
    var tmp = component
      .find("DecorartorShipping_Information")
      .get("v.value", "");
    component.set("v.showDecoratorTeamPhun", false);
    component.set("v.showDecoratorClientRt", false);
    if (tmp.includes("Client")) {
      var action = component.get("c.getAccountAddress");
      action.setParams({
        Recid: component.get("v.recordId")
      });
      action.setCallback(this, function (response) {
        component.set("v.SelectedClientAddress", response.getReturnValue());
      });
      $A.enqueueAction(action);
      component.set("v.showDecoratorClientRt", true);
    } else {
      component.set("v.showDecoratorTeamPhun", true);
    }
  },
  onChangeShippingTo: function (component, event) {
    if (event != undefined) {
      component.set("v.showClientWarning", true);
    }
    var tmp = component.find("Shipping_Information").get("v.value", "");
    var cmpTarget = component.find("checkboxFirm");
    $A.util.removeClass(cmpTarget, "hideBlock");
    $A.util.addClass(cmpTarget, "showBlock");
    component.set("v.showTeamPhun", false);
    component.set("v.showClientRt", false);
    component.set("v.otherAddress", false);
    var cmpTarget = component.find("other_supplier");
    $A.util.removeClass(cmpTarget, "showBlock");
    $A.util.addClass(cmpTarget, "hideBlock");
    var cmpTarget = component.find("decorator_block");
    $A.util.removeClass(cmpTarget, "showBlock");
    $A.util.addClass(cmpTarget, "hideBlock");

    if (tmp == "Other Supplier") {
      var cmpTarget = component.find("other_supplier");
      $A.util.removeClass(cmpTarget, "hideBlock");
      $A.util.addClass(cmpTarget, "showBlock");
    } else if (tmp == "Other") {
      component.set("v.otherAddress", true);
    } else if (tmp == "Decorator") {
      var cmpTarget = component.find("checkboxFirm");
      $A.util.removeClass(cmpTarget, "showBlock");
      $A.util.addClass(cmpTarget, "hideBlock");
      var cmpTarget = component.find("decorator_block");
      $A.util.removeClass(cmpTarget, "hideBlock");
      $A.util.addClass(cmpTarget, "showBlock");
    } else if (tmp.includes("Client")) {
      component.set("v.Spinner", true);
      var action = component.get("c.getAccountAddress");
      action.setParams({
        Recid: component.get("v.recordId")
      });
      action.setCallback(this, function (response) {
        component.set("v.SelectedClientAddress", response.getReturnValue());
        component.set("v.Spinner", false);
      });
      $A.enqueueAction(action);
      component.set("v.showClientRt", true);
    } else if (tmp == "--None--") {
      component.set("v.showClientWarning", true);
      component.set("v.showTeamPhun", false);
      component.set("v.showClientRt", false);
    } else {
      component.set("v.showTeamPhun", true);
    }
  },
  onChangeCompanyAddress: function (component, event, helper) {
    var companyId = event.getSource().get("v.value");
    var lstShippingAddress = component.get("v.Shipping_CompanyAddresses");
    for (var key in lstShippingAddress) {
      if (lstShippingAddress[key].Id == companyId) {
        component.set(
          "v.Shipping_CompanyAddresses_Selected",
          lstShippingAddress[key]
        );
      }
    }
  },
  onChangeDecoratorCompanyAddress: function (component, event, helper) {
    var companyId = event.getSource().get("v.value");
    var test = component.get("v.Shipping_CompanyAddresses");
    for (var key in test) {
      if (test[key].Id == companyId) {
        component.set("v.DecoratorSelectedAddress", test[key]);
      }
    }
  },
  onChangeDecoratorAccountAddress: function (component, event, helper) {
    var companyId = event.getSource().get("v.value");
    var lstAccountAddresses = component.get("v.AccountAddresses");
    for (var key in lstAccountAddresses) {
      if (lstAccountAddresses[key].Id == companyId) {
        component.set(
          "v.SelectedDecoratorClientAddress",
          lstAccountAddresses[key]
        );
      }
    }
  },
  onChangeAccountAddress: function (component, event, helper) {
    var companyId = event.getSource().get("v.value");
    var lstAccountAddresses = component.get("v.AccountAddresses");
    for (var key in lstAccountAddresses) {
      if (lstAccountAddresses[key].Id == companyId) {
        component.set("v.SelectedClientAddress", lstAccountAddresses[key]);
      }
    }
  }
});
