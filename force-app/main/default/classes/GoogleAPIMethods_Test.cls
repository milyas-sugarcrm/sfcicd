@isTest
public class GoogleAPIMethods_Test {
  @isTest
  public static void TestingAllMethods() {
    Google_Auth__c auth = new Google_Auth__c(
      Token_Name__c = 'Latest',
      Access_Token__c = 'TestAccessToken'
    );
    insert auth;
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    GoogleAPIMethods.getLatestAccessToken();
    GoogleAPIMethods.moveFileOrFolder('fileId', 'folderId', 'accessToken');
    GoogleAPIMethods.findFolder('folderName', 'accessToken');
    GoogleAPIMethods.findSubFolder('folderName', 'folderId', 'accessToken');
    GoogleAPIMethods.setAccessToPublicEdit('folderId', 'accessToken');
    GoogleAPIMethods.setAccessToDomainEdit('folderId', 'accessToken');
    GoogleAPIMethods.setAccessToPublicViewOnly('folderId', 'accessToken');
    GoogleAPIMethods.DeleteFileOrFolder('folderId', 'accessToken');
    GoogleAPIMethods.setAccessToDomainViewOnly('folderId', 'accessToken');
    GoogleAPIMethods.findFolderById('folderId', 'accessToken');
    GoogleAPIMethods.MakeFolder('ParentFolderID', 'FolderName', 'accessToken');
    GoogleAPIMethods.getGoogleDriveFileLink('fileId', 'accessToken');
    GoogleAPIMethods.renameFile('fileId', 'newFileName', 'accessToken');
    GoogleAPIMethods.createFolder(
      'folderName',
      'parentFolderId',
      'accessToken'
    );
    Test.stopTest();
  }
}
