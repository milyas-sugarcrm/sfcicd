// Mock class to simulate HTTP callout
@isTest
public class MockLeadUpdateHttpResponseGenerator implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HTTPResponse res = new HTTPResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setBody(
      '{"json": "[{\\"email\\": \\"test@example.com\\", \\"What is your Name of Your Organization?\\": \\"Test Org1\\"}]""}'
    );
    res.setStatusCode(200);
    return res;
  }
}
