@istest
public class Test_OppLineItemNavController {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
    testFactory.addAddressRelatedData();
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();
    // testFactory.createPurchaseOrder();
    Test.startTest();
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createPurchaseOrderAndPurchaseOrderLineItems();

    Test.stopTest();
  }

  @isTest
  public static void testOppLineItemNavController() {
    Test.startTest();
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Order orderRecord = [SELECT id FROM Order LIMIT 1];
    OppLineItemNavController.getOpportunityName(opp.Id);
    OppLineItemNavController.getOpportunityStage(opp.Id);
    OppLineItemNavController.getEstimateOfOpportunity(opp.Id);
    OppLineItemNavController.getWorkOrderOfOpportunity(opp.Id);
    Test.stopTest();
  }
  @isTest
  public static void testgetPurchaseOrderIdForWorkOrders() {
    Test.startTest();
    Order orderRec = [SELECT Id FROM Order LIMIT 1];
    OppLineItemNavController.getPurchaseOrderIdForWorkOrders(orderRec.Id);
    Test.stopTest();
  }

  @istest
  public static void testFunctionsRelatedToOpportunityWorkOrderPurchaseOrder() {
    Test.startTest();
    List<Opportunity> opportunities = [SELECT Id, Name FROM Opportunity];
    PurchaseOrder_LineItem__c purchaseOrdeRLineItem = [
      SELECT Id, Name
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    Order orderRec = [SELECT Id FROM Order LIMIT 1];
    Id estimateId = OppLineItemNavController.getEstimateOfOpportunity(
      opportunities[0].Id
    );
    OppLineItemNavController.getWorkOrderOfOpportunity(opportunities[0].Id);
    OppLineItemNavController.getOpportunityStage(opportunities[0].Id);
    OppLineItemNavController.getPurchaseOrderId(opportunities[0].Id);
    OppLineItemNavController.getOpportunityName(opportunities[0].Id);
    OppLineItemNavController.addCommentAndAttachment(
      purchaseOrdeRLineItem.Id,
      false,
      null,
      'comment'
    );
    OppLineItemNavController.addCommentForPicklistChange(
      purchaseOrdeRLineItem.Name,
      'Change Requested'
    );
    OppLineItemNavController.generatePdfForPurchaseOrder(orderRec.Id);
    OppLineItemNavController.deletPurchaseOrderLineItems(
      purchaseOrdeRLineItem.Id,
      orderRec.Id
    );
    Test.stopTest();
    //   OppLineItemNavController.getDetailsRelatedPurchaseOrder(purchaseOrder.Id);
  }
  @isTest
  public static void testGetRelatedPurchaseOrderDataAndProof() {
    Test.startTest();
    Order orderRec = [SELECT Id FROM Order LIMIT 1];
    OppLineItemNavController.getDetailsRelatedPurchaseOrder(orderRec.Id);
    Test.stopTest();
  }
  /*@isTest 
    public static void testCreateNewProof()
    {
        Test.startTest();
        Proof__c proof = [SELECT Id 
                          FROM Proof__c LIMIT 1];
        PurchaseOrder__c po = [SELECT Id 
                               FROM PurchaseOrder__c 
                               LIMIT 1];
        PurchaseOrder_LineItem__c poLineItem = [SELECT Id
                                                FROM PurchaseOrder_LineItem__c
                                                LIMIT 1];
        //OppLineItemNavController.createNewProof (null,'fileName',poLineItem.Id,po.Id);
        Test.stopTest();
 
    }
    @isTest
    public static void testChangeStatusOfProofPicklist()
    { 
        Test.startTest();
        Proof__c proof = [SELECT Id 
                          FROM Proof__c LIMIT 1];
        PurchaseOrder__c po = [SELECT Id 
                               FROM PurchaseOrder__c 
                               LIMIT 1];
       // OppLineItemNavController.changeStatusOfProofPicklist(proof.Id,po.Id,'Change Requested');
       // OppLineItemNavController.changeStatusOfProofPicklist(proof.Id,po.Id,'Cient Approved'); 
        Test.stopTest();
    }*/
  @isTest
  public static void testAddNewCommentForProof() {
    Test.startTest();
    //Proof__c proof = [SELECT Id
    //                 FROM Proof__c LIMIT 1];
    PurchaseOrder_LineItem__c purchaseOrdeRLineItem = [
      SELECT Id, Name
      FROM PurchaseOrder_LineItem__c
      LIMIT 1
    ];
    //OppLineItemNavController.addCommentForProofInDB(proof.Id,po.Id,'comment');
    OppLineItemNavController.updatePurchaseOrders(
      purchaseOrdeRLineItem.id,
      'Test'
    );
    OppLineItemNavController.addCommentForMarkAsDropDown(
      purchaseOrdeRLineItem.Name,
      'fax'
    );
    OppLineItemNavController.addCommentForMarkAsDropDown(
      purchaseOrdeRLineItem.Name,
      'ftp'
    );
    OppLineItemNavController.addCommentForMarkAsDropDown(
      purchaseOrdeRLineItem.Name,
      'Supplier Site'
    );
    Test.stopTest();
  }
  @isTest
  public static void testGetPurchaseOpportunity() {
    Test.startTest();
    Opportunity opp = [
      SELECT Id, Name
      FROM Opportunity
      LIMIT 1
    ];
    OppLineItemNavController.getPurchaseOpportunity(opp.Id);
    Test.stopTest();
  }

  /* @isTest
    public static void testChangeAllProofsUploadedStatus()
    {
        Test.startTest();
        PurchaseOrder_LineItem__c purchaseOrderId = [SELECT Id,Name
                                                     FROM PurchaseOrder_LineItem__c 
                                                     LIMIT 1];
        //OppLineItemNavController.changeAllProofsUploadedStatus(purchaseOrderId.Id,true);
        OppLineItemNavController.getProofApprovalPageLink(purchaseOrderId.Id);
        Test.stopTest();
        
    } */
}
