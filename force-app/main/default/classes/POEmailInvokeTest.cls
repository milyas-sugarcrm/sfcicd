@isTest
public class POEmailInvokeTest {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory();
    testfactory.createOpportunities();

    List<Opportunity> opps = [SELECT StageName FROM Opportunity];
    for (Opportunity opp : Opps) {
      opp.StageName = 'Presentation';
    }
    update opps;
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    testfactory.createSalesOrder();
    testFactory.addAddressRelatedData();
    testFactory.saveShippingInformation();
    Test.startTest();
    testfactory.createPurchaseOrderAndPurchaseOrderLineItems();
    Test.stopTest();
  }

  @isTest
  public static void testInvokeEmail() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
        Carrier__c,
        Client_Picked_Up_or_Notified__c,
        Signed_by__c,
        Preferred_Carrier__c,
        Boxes_for_Pickup__c,
        Pickup_Location__c,
        Boxes_Received__c,
        PO_Completion_Date__c,
        Require_Carrier__c,
        Tracking_Number__c,
        PO_Confirmed_On__c,
        PO_Confirmed_By__c,
        PO_Estimated_Ship_Date__c,
        Date_and_Time_Sent__c
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    PO.Date_and_Time_Sent__c = System.now();
    PO.Production_Rep__c = 'Sean Burns';
    PO.PO_Estimated_Ship_Date__c = System.today();
    PO.PO_Completion_Date__c = System.today();
    //PO.Carrier__c = 'Test Carrier';
    update PO;

    List<Id> PoId = new List<Id>();
    PoId.add(PO.Id);
    POEmailInvokeOnSent.invokeEmail(PoId);
    POEmailInvokeOnQC.invokeEmail(PoId);
    POEmailInvokeOnIP.invokeEmail(PoId);
    POEmailInvokeOnReadyForTP.invokeEmail(PoId);
    POEmailInvokeReadyToShipSecond.invokeEmail(PoId);
    POEmailInvokeOnIPSecond.invokeEmail(PoId);
    POEmailInvokeReadyToShip.invokeEmail(PoId);
    POEmailInvokeShipped.invokeEmail(PoId);
    Test.stopTest();
  }
}
