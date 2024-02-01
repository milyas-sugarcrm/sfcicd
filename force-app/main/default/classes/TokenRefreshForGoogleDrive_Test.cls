@isTest
public class TokenRefreshForGoogleDrive_Test {
  // Test method for the refreshToken method
  @isTest
  public static void testRefreshToken() {
    // Create a test data setup for the Google_Auth__c record
    Google_Auth__c testAuthData = new Google_Auth__c();
    testAuthData.Token_Name__c = 'Latest';
    testAuthData.Refresh_Token__c = 'test-refresh-token';
    insert testAuthData;

    // Set up the HTTP mock response
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    // Call the method under test
    Test.startTest();
    TokenRefreshForGoogleDrive.refreshToken();
    Test.stopTest();
  }
}
