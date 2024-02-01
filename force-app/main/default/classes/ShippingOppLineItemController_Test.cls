@istest
public class ShippingOppLineItemController_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
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
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = 'LHR';
    acc.Billingstate = 'Punjab';
    acc.BillingCountry = 'PAK';
    insert acc;
    Address__c addressObj = new Address__c();
    addressObj.Account__c = acc.id;
    addressObj.Name = 'AddressName';
    insert addressObj;
    // ShippingMainComponentController_Test.saveShipToClientData();
    Test.stopTest();
  }
  @isTest
  public static void testCreatePurchaseOrder() {
    Order workOrder = [
      SELECT OpportunityId, Id
      FROM Order
      LIMIT 1
    ];
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
  public static void testDataManipulation() {
    Order salesOrder = [SELECT id FROM Order LIMIT 1];
    ShippingOppLineItemController.getSalesOrderRelatedOpportunityLineItems(
      [SELECT id FROM Order LIMIT 1].id,
      6
    );
    ShippingOppLineItemController.getSalesOrderRelatedOpportunityLineItems(
      [SELECT id FROM Order LIMIT 1].id,
      7
    );

    //ShippingOppLineItemController.createPurchaseOrderInDb(salesOrder.Id,null,null);

    Order order = [SELECT id, OpportunityId FROM Order LIMIT 1];
    System.assertEquals(
      ShippingOppLineItemController.getSalesOrderPreviewLink(order.id),
      URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/OpportunitySalesOrderPreview?id=' +
        order.OpportunityId
    );
    Test.startTest();
    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    ShippingOppLineItemController.getSalesOrderInHandDate(lineItem.Id);
    ShippingOppLineItemController.getCountOfSalesOrderOppLineItems(order.Id);
    ShippingOppLineItemController.deleteOpportunityLineItemInDb(order.Id);
    ShippingOppLineItemController.getProductsWithShippingInfo(order.Id);
    Test.stopTest();
    //Boolean dataDeleted = ShippingOppLineItemController.deleteOpportunityLineItemInDb(lineItem.id);
    //System.assert(dataDeleted);
    //String inHandDate = ShippingOppLineItemController.getSalesOrderInHandDate(lineItem.id);
    //dataDeleted = ShippingOppLineItemController.deleteOpportunityLineItemInDb(lineItem.Id);
    //System.assert(dataDeleted == false);
  }
}
