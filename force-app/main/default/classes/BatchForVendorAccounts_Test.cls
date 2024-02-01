@isTest
public class BatchForVendorAccounts_Test {
  @testSetup
  public static void populateData() {
    Test.startTest();
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createProductLineItems();
    testFactory.createEstimate();
    testFactory.addAddressRelatedData();
    tEST.stopTest();
  }
  @isTest
  public static void testBatch() {
    Test.startTest();
    String oppLineItemIds = '';
    List<OpportunityLineItem__c> oppLineitems = [
      SELECT
        id,
        Product__r.Product_Supplier_Code__c,
        Estimate__r.Selected_Quickbook_Instance__c,
        Supplier__c,
        ESPId__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];

    for (OpportunityLineItem__c oppLineItem : oppLineitems) {
      if (!oppLineItemIds.contains(oppLineItem.id)) {
        oppLineItemIds = oppLineItemIds + '\'' + oppLineItem.id + '\'';
        if (oppLineItem.id != oppLineitems.get(oppLineitems.size() - 1).id)
          oppLineItemIds = oppLineItemIds + ',';
      }
    }
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Database.BatchableContext bc;
    BatchForVendorAccounts btch = new BatchForVendorAccounts(oppLineItemIds);
    btch.start(bc);
    btch.execute(bc, oppLineitems);
    btch.finish(bc);
    BatchForVendorAccountsScript.passTest();
    Test.stopTest();
  }
}
