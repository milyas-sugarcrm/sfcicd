@isTest
public class PurchaseOrderLineItemTriggerService_Test {
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
  public static void testChangeTheStageOfPurchaseOrder() {
    /*Test.startTest();
        PurchaseOrder_LineItem__c PO = [SELECT Id, Boxes__c, WO_Status__c, Master_Tracking_Number_to_Client__c, Client_Picked_Up_or_Notified__c, 
                                        Signed_by__c, Preferred_Carrier__c, Boxes_for_Pickup__c, Pickup_Location__c, Boxes_Received__c, PO_Completion_Date__c,
                                        Require_Carrier__c, Tracking_Number__c, PO_Confirmed_On__c, PO_Confirmed_By__c, PO_Estimated_Ship_Date__c, Date_and_Time_Sent__c                  
                                        FROM PurchaseOrder_LineItem__c LIMIT 1];
   
        PO.PO_Completion_Date__c = System.today();
        update PO;
        
        // Change the status from 'Billed' with 'In Process'.
        PO.WO_Status__c = 'In Process';
        PO.Delivery_Date_Time__c = System.today().addDays(3);
        update PO;
        Test.stopTest();*/
  }
  @isTest
  public static void testChangeTheStageOfPurchaseOrder2() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    PO.PO_Confirmed_On__c = System.today();
    PO.PO_Confirmed_By__c = 'Test User';
    PO.PO_Estimated_Ship_Date__c = System.today();
    update PO;

    // Change the status from 'Billed' with 'In Process'.
    PO.WO_Status__c = 'In Process';
    PO.Delivery_Date_Time__c = System.today();
    PO.QBO_Bill__c = '24234';
    update PO;
    Test.stopTest();
  }

  @isTest
  public static void testChangeTheStageOfPurchaseOrder3s() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    PO.Require_Carrier__c = 'Yes';
    PO.Tracking_Number__c = 'asn123123wdajn';
    PO.Boxes__c = '5';
    update PO;

    // Change the status from 'Billed' with 'In Process'.
    PO.WO_Status__c = 'In Process';
    PO.Delivery_Date_Time__c = System.today().addDays(3);
    update PO;
    Test.stopTest();
  }

  @isTest
  public static void testChangeTheStageOfPurchaseOrder4() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    update PO;
    Test.stopTest();
  }
  @isTest
  public static void testChangeTheStageOfPurchaseOrder5() {
    /*Test.startTest();
        PurchaseOrder_LineItem__c PO = [SELECT Id, Boxes__c, WO_Status__c, Master_Tracking_Number_to_Client__c, Client_Picked_Up_or_Notified__c, 
                                        Signed_by__c, Preferred_Carrier__c, Boxes_for_Pickup__c, Pickup_Location__c, Boxes_Received__c, PO_Completion_Date__c,
                                        Require_Carrier__c, Tracking_Number__c, PO_Confirmed_On__c, PO_Confirmed_By__c, PO_Estimated_Ship_Date__c, Date_and_Time_Sent__c                  
                                        FROM PurchaseOrder_LineItem__c LIMIT 1];
   
        PO.Boxes_Received__c = 5;
        update PO;
        
 
        
        // Change the status from 'Billed' with 'In Process'.
        PO.WO_Status__c = 'In Process';
        PO.Delivery_Date_Time__c = System.today().addDays(3);
        update PO;
        Test.stopTest();*/
  }
  @isTest
  public static void testChangeTheStageOfPurchaseOrder6() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    PO.Master_Tracking_Number_to_Client__c = 'ascnasjnc12398123';
    PO.Client_Picked_Up_or_Notified__c = System.now();
    PO.Signed_by__c = 'MZ';
    update PO;
    Test.stopTest();
  }
  @isTest
  public static void testChangeTheStageOfPurchaseOrder7() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    PO.Preferred_Carrier__c = 'FedEx';
    PO.Boxes_for_Pickup__c = 5;
    PO.Pickup_Location__c = 'Team Phun West, 5026 Cass St., Ste. B, San Diego, CA 92109';
    update PO;

    Test.stopTest();
  }

  @isTest
  public static void testCosfinancialsCalculations() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT
        Id,
        Boxes__c,
        WO_Status__c,
        Master_Tracking_Number_to_Client__c,
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
    PO.Production_Rep__c = 'Sean Burns';
    update PO;
    PO.WO_Status__c = 'Billed';
    update PO;
    delete PO;
    Test.stopTest();
  }

  @isTest
  public static void testRemovePoPDF() {
    Test.startTest();
    PurchaseOrder_LineItem__c PO = [
      SELECT ID
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    List<PurchaseOrder_LineItem__c> lstPO = new List<PurchaseOrder_LineItem__c>();
    lstPO.add(PO);
    Map<ID, PurchaseOrder_LineItem__c> mapPO = new Map<Id, PurchaseOrder_LineItem__c>();
    mapPO.put(PO.id, PO);
    PurchaseOrderLineItemTriggerService.removePoPDF(lstPO, mapPO);
    Test.stopTest();
  }
}
