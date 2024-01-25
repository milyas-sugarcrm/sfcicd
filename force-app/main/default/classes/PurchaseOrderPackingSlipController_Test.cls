@isTest
public class PurchaseOrderPackingSlipController_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.addAddressRelatedData();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();
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
      WHERE PurchaseOrder_LineItem__c != NULL
    ];
    if (lstOpp.size() > 0) {
      for (OpportunityLineItem__c oppLineItem : lstOpp) {
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
  public static void testMethods() {
    Test.startTest();
    PurchaseOrder_LineItem__c poLineItem = [
      SELECT id
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    ApexPages.StandardController standardController = new ApexPages.StandardController(
      poLineItem
    );
    PurchaseOrderPackingSlipController ext = new PurchaseOrderPackingSlipController(
      standardController
    );
    Decimal quantity = ext.getQuantityValue();
    List<PackingSlipObject> listOfPurchaseOrder = ext.getListOfPurchaseOrderLineItem();
    String poNumber = ext.getPurchaseOrderNumber();
    String opportunityName = ext.getOpportunityName();
    String address = ext.getAddress();
    OpportunityLineItem__c oppLineItem = [
      SELECT Id, Name, Estimate__c, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];

    oppLineItem.Estimate__c = [
      SELECT Id
      FROM Estimate__c
      LIMIT 1
    ]
    .Id;
    oppLineItem.Opportunity__c = null;
    update oppLineItem;
    opportunityName = ext.getOpportunityName();
    oppLineItem = [
      SELECT Id, Name, Estimate__c, Opportunity__c
      FROM OpportunityLineItem__c
      WHERE PurchaseOrder_LineItem__c = :poLineItem.Id
      LIMIT 1
    ];
    oppLineItem.ESPId__c = null;
    oppLineItem.Work_Order__c = [SELECT Id FROM Order LIMIT 1].Id;
    update oppLineItem;
    Test.stopTest();
  }
}
