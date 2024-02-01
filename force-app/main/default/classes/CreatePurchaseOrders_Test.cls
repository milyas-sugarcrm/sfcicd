@isTest
public class CreatePurchaseOrders_Test {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.addAddressRelatedData();
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    Test.startTest();
    testFactory.createOppProductLineItems();
    testFactory.saveShippingInformation();
    testFactory.createPurchaseOrders();
    Test.stopTest();
  }

  @isTest
  public static void testGetProducts() {
    Test.startTest();
    Order orderRecord = [SELECT Id FROM Order LIMIT 1];
    List<OpportunityLineItem__c> oppLineItems = [
      SELECT Id, Opportunity__c
      FROM OpportunityLineItem__c
      LIMIT 1
    ];
    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    List<PODetails> objList = new List<PODetails>();
    if (oppLineItems != null && oppLineItems.Size() > 0) {
      PODetails obj = new PODetails();
      Boolean value = true;
      for (OpportunityLineItem__c oppLine : oppLineItems) {
        obj.prodId = oppLine.Id;
        obj.value = 'Create New PO';
      }
      objList.add(obj);
    }
    gen.writeFieldName('object');
    gen.writeObject(objList);
    String jsonString = gen.getAsString().Remove('"object" :');
    jsonString = jsonString.removeEnd('}');
    jsonString = jsonString.removeStart('{');
    CreatePurchaseOrders.getProducts(orderRecord.Id);
    CreatePurchaseOrders.createPurchaseOrders(orderRecord.Id, jsonString);
    Test.stopTest();
  }
  public class PODetails {
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String prodId;
  }
}
