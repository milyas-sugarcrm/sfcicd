public class ShippingMainComponentController {
  @AuraEnabled
  public static Shipping_Information__c getRelatedShipping_InformationItems(
    Id recid
  ) {
    try {
      List<OpportunityLineItem__c> lstOpportunity_LineItems = [
        SELECT Id, Shipping_Information__r.id, Account__c
        FROM OpportunityLineItem__c
        WHERE Id = :recid
        ORDER BY CreatedDate DESC
      ];
      if (lstOpportunity_LineItems.size() > 0) {
        OpportunityLineItem__c opportunityLineItem = lstOpportunity_LineItems.get(
          0
        );
        List<Shipping_Information__c> lstShippingInformation = [
          SELECT
            Id,
            Ship_To__c,
            Shipping_Method_Details__c,
            Name,
            Shipping_Method_Others__c,
            Supplier_Notes__c,
            Shipping_Method__c,
            Firm__c,
            In_Hands_Date__c,
            Supplier__c,
            Company_Address__c,
            Client_Address__c,
            Other_Address__c
          FROM Shipping_Information__c
          WHERE Id = :opportunityLineItem.Shipping_Information__r.id
          ORDER BY CreatedDate DESC
          LIMIT 1
        ];
        for (
          Shipping_Information__c shippingInformation : lstShippingInformation
        ) {
          if (shippingInformation.In_Hands_Date__c == null) {
            shippingInformation.In_Hands_Date__c = DateTime.now().date();
          }
          if (shippingInformation.Supplier__c == null) {
            shippingInformation.Supplier__c = opportunityLineItem.Account__c;
          }
          //
          System.debug(shippingInformation.Supplier__c);
        }
        if (lstShippingInformation.size() > 0) {
          Shipping_Information__c shippingInformationObj = lstShippingInformation.get(
            0
          );
          System.debug('ship to: ' + shippingInformationObj.Ship_To__c);
          return shippingInformationObj;
        } else {
          Shipping_Information__c shippingInformationObj = new Shipping_Information__c();
          shippingInformationObj.Supplier__c = opportunityLineItem.Account__c;
          System.debug(shippingInformationObj.Supplier__c);
          insert shippingInformationObj;
          opportunityLineItem.Shipping_Information__c = shippingInformationObj.id;
          update opportunityLineItem;
          return shippingInformationObj;
        }
      }
    } catch (Exception ex) {
      System.debug('Exception :-- ' + ex.getMessage());
    }
    return null;
  }

  @AuraEnabled
  public static Shipping__c getRelatedShipping_Items(Id recid) {
    Shipping__c shipping_Rec = new Shipping__c();
    try {
      List<Shipping__c> lstShipping = [
        SELECT
          Id,
          Name,
          In_Hands_Date__c,
          Firm__c,
          Decorator_Notes__c,
          Shipping_Method_Others__c,
          Shipping_Method_Details__c,
          Decorator__c,
          Decorator__r.Name,
          Decorator_Address__c,
          Ship_To__c,
          ShipInformation__c,
          Shipping_Method__c,
          Supplier__c,
          Supplier_Address__c,
          Client_Address__c,
          Company_Address__c,
          Decorator_Shipping_Address__c,
          Other_Supplier_Address__c
        FROM Shipping__c
        WHERE ShipInformation__c = :recid
      ];
      for (Shipping__c shipping : lstShipping) {
        if (shipping.In_Hands_Date__c == null) {
          shipping.In_Hands_Date__c = DateTime.now().date();
        }
      }
      if (lstShipping.size() > 0) {
        shipping_Rec = lstShipping.get(0);
        System.debug('Shipping Record Updated::=> ' + shipping_Rec.id);
      } else {
        shipping_Rec.ShipInformation__c = recid;
        insert shipping_Rec;
        System.debug('Shipping Record Inserted ::=> ' + shipping_Rec.id);
      }
    } catch (Exception ex) {
      System.debug('Exception :-- ' + ex.getMessage());
    }
    return shipping_Rec;
  }

  @AuraEnabled
  public static List<String> getPicklistValues(
    sObject objectType,
    string field
  ) {
    List<String> allOpts = new List<String>();
    Schema.sObjectType objType = objectType.getSObjectType();
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    List<Schema.PicklistEntry> values = fieldMap.get(field)
      .getDescribe()
      .getPickListValues();
    for (Schema.PicklistEntry a : values) {
      allOpts.add(a.getValue());
    }
    return allOpts;
  }

  @AuraEnabled
  public static List<String> getPicklistModifiedValues(
    sObject objectType,
    string field,
    Id recid
  ) {
    String clientName = '';
    List<OpportunityLineItem__c> lstOppLineItem = [
      SELECT Id, Name, Opportunity__r.Name, Work_Order__r.OpportunityId
      FROM OpportunityLineItem__c
      WHERE Id = :recid
    ];
    if (lstOppLineItem.size() > 0) {
      List<Opportunity> lstOpp = [
        SELECT Id, Name
        FROM Opportunity
        WHERE Id = :lstOppLineItem.get(0).Work_Order__r.OpportunityId
      ];
      if (lstOpp.size() > 0) {
        {
          //  clientName = ' (';
          //  clientName += lstOpp.get(0).Name;
          // clientName += ')';
        }
      }
    }
    List<String> allOpts = new List<String>();
    Schema.sObjectType objType = objectType.getSObjectType();
    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
    List<Schema.PicklistEntry> values = fieldMap.get(field)
      .getDescribe()
      .getPickListValues();

    for (Schema.PicklistEntry a : values) {
      if (a.getValue().contains('Client')) {
        allOpts.add(a.getValue() + clientName);
      } else {
        allOpts.add(a.getValue());
      }
    }
    return allOpts;
  }

  @AuraEnabled
  public static List<CompAddress__c> getCompanyAddresses() {
    List<CompAddress__c> lstCompanyAddresses = new List<CompAddress__c>();
    for (CompAddress__c comp : [
      SELECT id, Name, Address__c
      FROM CompAddress__c
    ]) {
      lstCompanyAddresses.add(comp);
    }
    return lstCompanyAddresses;
  }

  @AuraEnabled
  public static String getAccountAddress(Id Recid) {
    List<OpportunityLineItem__c> opplineItem = [
      SELECT
        Id,
        Work_Order__r.ShippingStreet,
        Work_Order__r.ShippingCity,
        Work_Order__r.ShippingState,
        Work_Order__r.ShippingPostalCode,
        Work_Order__r.ShippingCountry
      FROM OpportunityLineItem__c
      WHERE Id = :Recid
    ];
    if (!opplineItem.isEmpty()) {
      return getAddress(opplineItem[0]);
    }
    return null;
  }

  @AuraEnabled
  public static String getAccountShippingAddress(Id Recid) {
    Account acc = [SELECT id, Name FROM Account WHERE Id = :Recid];
    System.debug(acc);
    return 'Account Address';
  }

  public static String getAddress(OpportunityLineItem__c opplineItem) {
    String address = '';
    if (opplineItem.Work_Order__r.ShippingStreet != null)
      address = opplineItem.Work_Order__r.ShippingStreet;
    if (opplineItem.Work_Order__r.ShippingCity != null)
      address = address + ' ' + opplineItem.Work_Order__r.ShippingCity;
    if (opplineItem.Work_Order__r.ShippingState != null)
      address = address + ', ' + opplineItem.Work_Order__r.ShippingState;
    if (opplineItem.Work_Order__r.ShippingPostalCode != null)
      address = address + ' ' + opplineItem.Work_Order__r.ShippingPostalCode;
    if (opplineItem.Work_Order__r.ShippingCountry != null)
      address = address + ' ' + opplineItem.Work_Order__r.ShippingCountry;
    return address;
  }
  @AuraEnabled
  public static Boolean saveData(
    Shipping_Information__c shippingInformation,
    Account supplierAccount,
    Shipping__c shipping_Rec,
    Account decorator,
    Address__c decorator_address,
    Account decorator_supplier,
    Address__c decorator_supplier_address,
    String clientAddress,
    String otherAddress,
    String otherSupplierAddress,
    String decoratorAddress,
    String decoratorClientAddress
  ) {
    if (supplierAccount != null) {
      shippingInformation.Supplier__c = supplierAccount.id;
    }
    System.debug(shippingInformation.Id);
    System.debug(otherSupplierAddress);
    if (shippingInformation.Ship_To__c.equalsIgnoreCase('Other Supplier')) {
      shipping_Rec.Decorator__c = null;
      shipping_Rec.Decorator_Address__c = null;
      shipping_Rec.Supplier__c = decorator_supplier.id;
      shipping_Rec.Other_Supplier_Address__c = otherSupplierAddress;
    } else if (shippingInformation.Ship_To__c.equalsIgnoreCase('Decorator')) {
      shipping_Rec.Supplier__c = null;
      shipping_Rec.Supplier_Address__c = null;
      shipping_Rec.Decorator__c = decorator.id;
      shipping_Rec.Decorator_Shipping_Address__c = decoratorAddress;
      shipping_Rec.Client_Shipping_Address__c = decoratorClientAddress;
    } else if (shippingInformation.Ship_To__c.containsIgnoreCase('Client')) {
      shipping_Rec.Decorator__c = null;
      shipping_Rec.Decorator_Address__c = null;
      shipping_Rec.Supplier__c = null;
      shipping_Rec.Supplier_Address__c = null;
      shippingInformation.Ship_To__c = 'Client';
      shippingInformation.Client_Shipping_Address__c = clientAddress;
    } else if (shippingInformation.Ship_To__c.containsIgnoreCase('Other')) {
      shipping_Rec.Decorator__c = null;
      shipping_Rec.Decorator_Address__c = null;
      shipping_Rec.Supplier__c = null;
      shipping_Rec.Supplier_Address__c = null;
      shippingInformation.Ship_To__c = 'Other';
      shippingInformation.Other_Address__c = otherAddress;
    } else {
      shipping_Rec.Decorator__c = null;
      shipping_Rec.Decorator_Address__c = null;
      shipping_Rec.Supplier__c = null;
      shipping_Rec.Supplier_Address__c = null;
    }
    if (!shippingInformation.Ship_To__c.equalsIgnoreCase('Decorator')) {
      shipping_Rec.Decorator_Notes__c = null;
      shipping_Rec.Firm__c = false;
      shipping_Rec.In_Hands_Date__c = null;
      shipping_Rec.Shipping_Method_Details__c = null;
      shipping_Rec.Shipping_Method_Others__c = null;
      shipping_Rec.Shipping_Method__c = null;
      shipping_Rec.Ship_To__c = 'Team Phun';
    }
    update shippingInformation;
    System.debug(shipping_Rec.Ship_To__c);
    if (shipping_Rec.Ship_To__c == null) {
      shipping_Rec.Ship_To__c = 'Client';
    }
    if (shipping_Rec.Ship_To__c.containsIgnoreCase('Client')) {
      shipping_Rec.Ship_To__c = 'Client';
    }
    System.debug('Shipping Information ' + shippingInformation.id);
    shipping_Rec.ShipInformation__c = shippingInformation.id;
    if (shippingInformation.id != null) {
      List<Shipping__c> lstShipping = [
        SELECT
          Id,
          Name,
          In_Hands_Date__c,
          Firm__c,
          Decorator_Notes__c,
          Shipping_Method_Others__c,
          Shipping_Method_Details__c,
          Decorator__c,
          Decorator_Address__c,
          Ship_To__c,
          ShipInformation__c,
          Shipping_Method__c,
          Supplier__c,
          Supplier_Address__c
        FROM Shipping__c
        WHERE ShipInformation__c = :shippingInformation.id
      ];
      if (lstShipping.size() > 0) {
        shipping_Rec.Id = lstShipping.get(0).Id;
        System.debug('Shipping Record Updated ' + shipping_Rec.id);
        update shipping_Rec;
      } else {
        insert shipping_Rec;
        System.debug('Shipping Record Inserted ' + shipping_Rec.id);
      }
      return true;
    }
    return false;
  }
}
