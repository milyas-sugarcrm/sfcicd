@isTest
public class OrderTriggerHandlerForGoogleDrive_Test {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createTestAccount();
    testFactory.addAddressRelatedData();
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();

    Google_Auth__c auth = new Google_Auth__c(
      Token_Name__c = 'Latest',
      Access_Token__c = 'TestAccessToken'
    );
    insert auth;
  }

  @isTest
  public static void testHandleNewAccounts() {
    Order ord = [SELECT id, AccountId FROM Order LIMIT 1];
    Account acc = [
      SELECT id, Google_Drive_Folder_Id__c, Vector_Folder_ID__c
      FROM Account
      WHERE id = :ord.AccountId
    ];
    acc.Google_Drive_Folder_Id__c = 'TYVUBIANS7587';
    acc.Vector_Folder_ID__c = 'HVHJV546sd';
    update acc;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    ord.Status = '02_-_Send_Mock_Up_to_Client_for_Approval';
    update ord;
    //  OrderTriggerHandlerForGoogleDrive.moveFileToFolder( 'fileId',  'folderId',  'accessToken');

    Test.stopTest();
    //   delete ord;
  }
}
