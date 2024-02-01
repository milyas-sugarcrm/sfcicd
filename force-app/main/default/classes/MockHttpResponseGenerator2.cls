public class MockHttpResponseGenerator2 implements HttpCalloutMock {
  private HttpResponse response;

  public MockHttpResponseGenerator2(HttpResponse response) {
    this.response = response;
  }

  public HttpResponse respond(HttpRequest request) {
    return response;
  }
}
