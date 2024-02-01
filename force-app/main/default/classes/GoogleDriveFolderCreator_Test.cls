@IsTest
public class GoogleDriveFolderCreator_Test {
  @testSetup
  static void setupTestData() {
    Google_Auth__c auth = new Google_Auth__c(
      Token_Name__c = 'Latest',
      Access_Token__c = 'TestAccessToken'
    );
    insert auth;
  }

  @isTest
  public static void TestFolders2() {
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    GoogleDriveFolderCreator.createFoldersForCustomerAccount();
    GoogleDriveFolderCreator.createFoldersForVendorAccount();
    GoogleDriveFolderCreator.createSubFolders('ParentId', 'AccessToken');
    Test.stopTest();
  }
}
