@isTest
public class NewCampaignFormAPI_Test {
  // Create a mock class that implements the HttpCalloutMock interface
  public class MockHttpResponse implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
      // Create a mock response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody('{"status":"success"}');
      res.setStatusCode(201);
      return res;
    }
  }

  @isTest
  static void testValidPostRequest() {
    // Set up a mock callout response
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

    // Create an Account
    Account testAccount = new Account(
      Name = 'Test Account',
      QuickBooks_Accounts__c = 'Team Phun',
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get('PFA Customer Account')
        .getRecordTypeId()
    );
    insert testAccount;

    // Create a JSON payload for your POST request
    String requestBody = '{"email": "test@example.com", "organizationName": "Test Org", "organizationAddress": "123 Test St", "signorName": "John Doe", "signorTitle": "CEO", "legalCompanyName": "Legal Co", "legalBillingAddress": "456 Legal St", "billingContactName": "Billing Contact", "billingContactEmail": "billing@example.com", "billingContactPhone": "1234567890", "paymentMethod": ["Credit Card"], "productsOrBrands": "Product 1", "eventLocations": "Location 1", "campaignPOC": "Campaign POC", "campaignPOCEmail": "campaign@example.com", "campaignStartDate": "2023-01-01", "campaignEndDate": "2023-01-10", "productDescription": "Product Description", "schedulingResponsible": "Scheduling Responsible", "baAttireRequest": "Attire Request", "needPOS": "Yes", "materialSummary": "Material Summary"}';

    // Create a REST request
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();
    request.requestURI = '/services/apexrest/NewCampaignFormAPI';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');
    request.requestBody = Blob.valueOf(requestBody);

    // Set up the REST context
    RestContext.request = request;
    RestContext.response = response;

    // Create a test Contact record with the same email address and associate it with the created Account
    Contact testContact = new Contact(
      FirstName = 'Test Class for Contact Record',
      LastName = 'Testing',
      Email = 'test@example.com',
      AccountId = testAccount.Id // Associate with the created Account
    );
    insert testContact;

    // Call the REST service
    Test.startTest();
    NewCampaignFormAPI.doPost();
    Test.stopTest();

    // Verify the response
    response = RestContext.response;
    System.assertEquals(201, response.statusCode);
  }

  @isTest
  static void testInvalidPostRequest() {
    // Create an invalid JSON payload (missing required fields)
    String requestBody = '{}';

    // Create a REST request
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();
    request.requestURI = '/services/apexrest/NewCampaignFormAPI';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');
    request.requestBody = Blob.valueOf(requestBody);

    // Set up the REST context
    RestContext.request = request;
    RestContext.response = response;

    // Call the REST service
    Test.startTest();
    NewCampaignFormAPI.doPost();
    Test.stopTest();

    // Verify the response
    response = RestContext.response;
    System.assertEquals(400, response.statusCode);
    System.assertEquals('4003', response.responseBody.toString()); // Expected validation error code
  }
}
