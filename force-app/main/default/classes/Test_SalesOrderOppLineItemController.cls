@istest
public class Test_SalesOrderOppLineItemController {
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
    List<RecordType> lstrecordType = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE SobjectType = 'Account' AND Name LIKE 'Vendor%'
    ];
    // test.stopTest();
    // Test.startTest();
    Account acc = new Account();
    acc.Name = 'Supplier account';
    acc.Billing_Email__c = 'testing12@gmail.com';
    acc.Art_Approval_Email__c = 'testing12@gmail.com';
    if (lstrecordType != null && lstrecordType.size() > 0)
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
    test.stopTest();
  }
  /*@isTest
    public static void saveShipToClientData(){
        Test.startTest();
        Account acc = [SELECT Id, Name 
                       FROM account 
                       WHERE Name = 'Supplier account'];
        Address__c addressObj  = [SELECT Id, Name
                                  FROM Address__c
                                  WHERE Name = 'AddressName'];
        List <OpportunityLineItem__c> lstOpp = [Select id, Name from OpportunityLineItem__c];
        if(lstOpp.size() > 0){
            OpportunityLineItem__c oppLineItem = lstOpp.get(0);
            Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(oppLineItem.Id);
            Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(shippingInformation.Id);
            shippingInformation.Ship_To__c = 'Client';
            shippingInformation.Supplier__c = acc.id;
            Account decoratorAccount =  getAccountRecord(shipping.Decorator__c);
            Account otherSupplierAccount =  getAccountRecord(shipping.Supplier__c);
            Address__c decoratorAddress = getAddressRecord(shipping.Decorator_Address__c);
            Address__c otherSupplierAddress = getAddressRecord(shipping.Supplier_Address__c);
            ShippingMainComponentController.saveData(shippingInformation, acc, shipping, decoratorAccount, decoratorAddress, otherSupplierAccount, otherSupplierAddress);
        }
        Test.stopTest();
    }*/

  @isTest
  public static void testDataManipulation() {
    Test.startTest();
    Order salesOrder = [SELECT id FROM Order LIMIT 1];
    SalesOrderOppLineItemController.getSalesOrderRelatedOpportunityLineItems(
      [SELECT id FROM Order LIMIT 1].id,
      6
    );

    // SalesOrderOppLineItemController.createPurchaseOrderInDb(salesOrder.Id);

    Order order = [SELECT id, OpportunityId FROM Order LIMIT 1];
    System.assertEquals(
      SalesOrderOppLineItemController.getSalesOrderPreviewLink(order.id),
      URL.getSalesforceBaseUrl().toExternalForm() +
        '/apex/OpportunitySalesOrderPreview?id=' +
        order.OpportunityId
    );
    OpportunityLineItem__c lineItem = [
      SELECT id
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    Boolean dataDeleted = SalesOrderOppLineItemController.deleteOpportunityLineItemInDb(
      lineItem.id
    );
    System.assert(dataDeleted);
    SalesOrderOppLineItemController.getCountOfSalesOrderOppLineItems(order.id);
    String inHandDate = SalesOrderOppLineItemController.getSalesOrderInHandDate(
      lineItem.id
    );
    dataDeleted = SalesOrderOppLineItemController.deleteOpportunityLineItemInDb(
      lineItem.Id
    );
    System.assert(dataDeleted == false);
    Test.stopTest();
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
      throw new AuraHandledException(e.getMessage());
    }
  }
  public static Account getAccountRecord(String finalId) {
    String sQuery = 'SELECT id, Name FROM Account WHERE Id = ' + finalId;
    try {
      List<Account> lstOfRecords = Database.query(sQuery);
      return lstOfRecords.get(0);
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
      return null;
    }
  }
  @isTest
  public static void updateSOInlineEditTest() {
    try {
      test.startTest();
      Map<String, Object> data = new Map<String, Object>();
      Map<String, Object> productData = new Map<String, Object>();
      Map<String, Object> pricingData = new Map<String, Object>();
      Map<String, Object> extraChargeData = new Map<String, Object>();
      Order ord = [SELECT Id FROM Order LIMIT 1];

      OpportunityLineItem__c updateProducts = [
        SELECT ID, name
        FROM OpportunityLineItem__c
        LIMIT 1
      ];
      PricingLineItem__c updatePricing = [
        SELECT ID, name
        FROM PricingLineItem__c
        WHERE OpportunityLineItem__c = :updateProducts.Id
        LIMIT 1
      ];
      ExtraChargesEstimate__c updateExtraCharge = [
        SELECT ID, name
        FROM ExtraChargesEstimate__c
        WHERE OpportunityLineItem__c = :updateProducts.Id
        LIMIT 1
      ];

      Map<String, Object> productJSON = new Map<String, Object>();
      productJSON.put('Description__c', '1234');
      productData.put(updateProducts.id, productJSON);

      Map<String, Object> pricingJSON = new Map<String, Object>();
      pricingJSON.put('Size__c', 'XL/Black');
      pricingJSON.put('Estimated_Quantity__c', '23');
      pricingJSON.put('Net_Cost__c', '120');
      pricingJSON.put('Retail_Price__c', '150');
      pricingData.put(updatePricing.id, pricingJSON);

      Map<String, Object> extraChargeJSON = new Map<String, Object>();
      extraChargeJSON.put('Title__c', 'Fixed');
      extraChargeJSON.put('Quantity__c', '14');
      extraChargeJSON.put('Net_Cost__c', '100');
      extraChargeJSON.put('Retail_Price__c', '120');
      extraChargeData.put(updateExtraCharge.id, extraChargeJSON);

      data.put('product', productData);
      data.put('pricingDetails', pricingData);
      data.put('extraCharge', extraChargeData);
      data.put('workOrderId', ord.Id);

      SalesOrderOppLineItemController.updateSaleOrderInlineEdit(
        JSON.serialize(data)
      );
      SalesOrderOppLineItemController.syncSalesOrders(ord.Id);
      SalesOrderOppLineItemController.getSalesOrderSyncStatus(ord.Id);
      test.stopTest();
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
    }
  }
}
