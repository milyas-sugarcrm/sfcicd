@IsTest
public class GoogleCallBackControllerTest {
  @IsTest
  static void testHandleCallback() {
    Test.setCurrentPage(Page.GoogleCallBackPage);

    ApexPages.currentPage().getParameters().put('code', 'testCode');

    HttpResponse mockResponse = new HttpResponse();
    mockResponse.setStatusCode(200);
    mockResponse.setBody(
      '{"access_token":"testAccessToken","refresh_token":"testRefreshToken","token_type":"Bearer"}'
    );
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator2(mockResponse)
    );

    GoogleCallBackController controller = new GoogleCallBackController();
    controller.handleCallback();
  }
}
