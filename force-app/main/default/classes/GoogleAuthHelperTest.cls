@isTest
private class GoogleAuthHelperTest {
  @isTest
  static void testSendRequest() {
    // Create a mock HTTP request
    HttpRequest mockRequest = new HttpRequest();
    mockRequest.setEndpoint('https://example.com');
    mockRequest.setMethod('GET');

    // Create a mock HTTP response
    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setStatusCode(200);
    mockResponse.setBody(
      '{"access_token":"dummy_token","refresh_token":"dummy_refresh_token"}'
    );

    // Set the mock callout class
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator2(mockResponse)
    );

    // Call the sendRequest method
    HttpResponse actualResponse = GoogleAuthHelper.sendRequest(mockRequest);
    GoogleAuthHelper.getGoogleAuthMetaData();

    // Verify the request
    HttpRequest preparedRequest = GoogleAuthHelper.prepareRequest(
      'https://example.com',
      'GET',
      new Map<String, String>(),
      ''
    );
  }
}
