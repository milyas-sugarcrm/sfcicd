@isTest
public class ShippingMainComponentController_Test {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    testFactory.createProductLineItems();
    Test.startTest();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
    testFactory.createExtraCharges();
    List<RecordType> lstrecordType = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE SobjectType = 'Account' AND Name LIKE 'Vendor%'
    ];
    Account acc = new Account();
    acc.Name = 'Supplier account';
    acc.Billing_Email__c = 'testing12@gmail.com';
    acc.Art_Approval_Email__c = 'testing12@gmail.com';
    acc.RecordTypeId = lstrecordType.get(0).id;
    acc.BillingStreet = '5';
    acc.Billingcity = 'LHR';
    acc.Billingstate = 'Punjab';
    acc.BillingCountry = 'PAK';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    insert acc;
    Address__c addressObj = new Address__c();
    addressObj.Account__c = acc.id;
    addressObj.Name = 'AddressName';
    insert addressObj;
    Test.stopTest();
  }

  @isTest
  public static void saveShipToClientData() {
    Test.startTest();
    Account acc = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Address__c addressObj = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name = 'AddressName'
    ];
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name
      FROM OpportunityLineItem__c
    ];
    if (lstOpp.size() > 0) {
      OpportunityLineItem__c oppLineItem = lstOpp.get(0);
      Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(
        oppLineItem.Id
      );
      Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(
        shippingInformation.Id
      );
      shippingInformation.Ship_To__c = 'Client';
      shippingInformation.Supplier__c = acc.id;
      Account decoratorAccount = getAccountRecord(shipping.Decorator__c);
      Account otherSupplierAccount = getAccountRecord(shipping.Supplier__c);
      Address__c decoratorAddress = getAddressRecord(
        shipping.Decorator_Address__c
      );
      Address__c otherSupplierAddress = getAddressRecord(
        shipping.Supplier_Address__c
      );
      String clientAddress = 'Test';
      String otherAddress = 'Test';
      String otherSupplierAddressStr = 'Test';
      String decoratorAddressStr = 'Test';
      String decoratorClientAddress = 'Test';
      ShippingMainComponentController.saveData(
        shippingInformation,
        acc,
        shipping,
        decoratorAccount,
        decoratorAddress,
        otherSupplierAccount,
        otherSupplierAddress,
        clientAddress,
        otherAddress,
        otherSupplierAddressStr,
        decoratorAddressStr,
        decoratorClientAddress
      );
    }
    Test.stopTest();
  }

  @isTest
  public static void saveShipToOtherSupplierData() {
    Test.startTest();
    Account acc = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Address__c addressObj = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name = 'AddressName'
    ];
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name
      FROM OpportunityLineItem__c
    ];
    if (lstOpp.size() > 0) {
      OpportunityLineItem__c oppLineItem = lstOpp.get(0);
      Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(
        oppLineItem.Id
      );
      Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(
        shippingInformation.Id
      );
      shippingInformation.Ship_To__c = 'Other Supplier';
      shippingInformation.Supplier__c = acc.id;
      Account decoratorAccount = getAccountRecord(shipping.Decorator__c);
      Account otherSupplierAccount = getAccountRecord(shipping.Supplier__c);
      Address__c decoratorAddress = getAddressRecord(
        shipping.Decorator_Address__c
      );
      Address__c otherSupplierAddress = getAddressRecord(
        shipping.Supplier_Address__c
      );
      String clientAddress = 'Test';
      String otherAddress = 'Test';
      String otherSupplierAddressStr = 'Test';
      String decoratorAddressStr = 'Test';
      String decoratorClientAddress = 'Test';
      ShippingMainComponentController.saveData(
        shippingInformation,
        acc,
        shipping,
        decoratorAccount,
        decoratorAddress,
        acc,
        addressObj,
        clientAddress,
        otherAddress,
        otherSupplierAddressStr,
        decoratorAddressStr,
        decoratorClientAddress
      );
    }
    Test.stopTest();
  }

  @isTest
  public static void saveShipTDecoratorData() {
    Test.startTest();
    Account acc = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Address__c addressObj = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name = 'AddressName'
    ];
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    if (lstOpp.size() > 0) {
      OpportunityLineItem__c oppLineItem = lstOpp.get(0);
      Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(
        oppLineItem.Id
      );
      Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(
        shippingInformation.Id
      );
      shippingInformation.Ship_To__c = 'Decorator';
      shippingInformation.Supplier__c = acc.id;
      shipping.Ship_To__c = 'Client';
      Account decoratorAccount = getAccountRecord(shipping.Decorator__c);
      Account otherSupplierAccount = getAccountRecord(shipping.Supplier__c);
      Address__c decoratorAddress = getAddressRecord(
        shipping.Decorator_Address__c
      );
      Address__c otherSupplierAddress = getAddressRecord(
        shipping.Supplier_Address__c
      );
      String clientAddress = 'Test';
      String otherAddress = 'Test';
      String otherSupplierAddressStr = 'Test';
      String decoratorAddressStr = 'Test';
      String decoratorClientAddress = 'Test';
      ShippingMainComponentController.saveData(
        shippingInformation,
        acc,
        shipping,
        acc,
        addressObj,
        otherSupplierAccount,
        otherSupplierAddress,
        clientAddress,
        otherAddress,
        otherSupplierAddressStr,
        decoratorAddressStr,
        decoratorClientAddress
      );
    }
    Test.stopTest();
  }

  /*@isTest
public static void saveShipTeamPhunData(){
Account acc = [SELECT Id, Name 
FROM account 
WHERE Name = 'Supplier account'];
Address__c addressObj  = [SELECT Id, Name
FROM Address__c
WHERE Name = 'AddressName'];
List <OpportunityLineItem__c> lstOpp = [Select id, Name from OpportunityLineItem__c];
if(lstOpp.size() > 0){
OpportunityLineItem__c oppLineItem = lstOpp.get(0);
ShippingMainComponentController.getCompanyAddresses();
Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(oppLineItem.Id);
Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(shippingInformation.Id);
shippingInformation.Ship_To__c = 'Team Phun';
shippingInformation.Supplier__c = acc.id; 
shipping.Ship_To__c = 'Client';
Account decoratorAccount =  getAccountRecord(shipping.Decorator__c);
Account otherSupplierAccount =  getAccountRecord(shipping.Supplier__c);
Address__c decoratorAddress = getAddressRecord(shipping.Decorator_Address__c);
Address__c otherSupplierAddress = getAddressRecord(shipping.Supplier_Address__c);
ShippingMainComponentController.saveData(shippingInformation, acc, shipping, acc, addressObj, otherSupplierAccount, otherSupplierAddress);
}
} */

  public static Account getAccountRecord(String finalId) {
    String sQuery = 'SELECT id, Name FROM Account WHERE Id = ' + finalId;
    try {
      List<Account> lstOfRecords = Database.query(sQuery);
      for (Account obj : lstOfRecords) {
        return obj;
      }
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
    }
    return null;
  }

  public static Address__c getAddressRecord(String finalId) {
    String sQuery = 'SELECT id, Name FROM Address__c WHERE Id = ' + finalId;
    try {
      List<Address__c> lstOfRecords = Database.query(sQuery);
      for (Address__c obj : lstOfRecords) {
        return obj;
      }
      return null;
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }

  @isTest
  public static void getPicklistValues() {
    Test.startTest();
    ShippingMainComponentController.getCompanyAddresses();
    Shipping_Information__c shippingInformationObject = new Shipping_Information__c();
    ShippingMainComponentController.getPicklistValues(
      shippingInformationObject,
      'Ship_To__c'
    );
    Test.stopTest();
  }

  @isTest
  public static void getAccountPicklistValues() {
    Test.startTest();
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name
      FROM OpportunityLineItem__c
    ];
    if (lstOpp.size() > 0) {
      OpportunityLineItem__c oppLineItem = lstOpp.get(0);
      ShippingMainComponentController.getAccountAddress(oppLineItem.id);
    }
    Test.stopTest();
  }

  @isTest
  public static void getPicklistModifiedValues() {
    Test.startTest();
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name
      FROM OpportunityLineItem__c
    ];
    if (lstOpp.size() > 0) {
      Shipping_Information__c shippingInformation = new Shipping_Information__c();
      ShippingMainComponentController.getPicklistModifiedValues(
        shippingInformation,
        'Ship_To__c',
        lstOpp.get(0).id
      );
    }
    Test.stopTest();
  }

  @isTest
  public static void testSaveData() {
    Test.startTest();
    List<OpportunityLineItem__c> lstOpp = [
      SELECT id, Name, Shipping_Information__c
      FROM OpportunityLineItem__c
    ];
    if (lstOpp.size() > 0) {
      OpportunityLineItem__c oppLineItem = lstOpp.get(0);
    }
    Test.stopTest();
  }
}
