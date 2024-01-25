@isTest
public class NewClientFormAPI_Test {
  @isTest
  static void testValidPostRequest() {
    // Create a JSON payload for your POST request
    String requestBody = '{"email": "test@example.com", "organizationName": "Test Org", "organizationAddress": "123 Test St", "signorName": "John Doe", "signorTitle": "CEO", "legalCompanyName": "Legal Co", "legalBillingAddress": "456 Legal St", "billingContactName": "Billing Contact", "billingContactEmail": "billing@example.com", "billingContactPhone": "1234567890", "paymentMethod": ["Credit Card"], "productsOrBrands": "Product 1", "eventLocations": "Location 1", "campaignPOC": "Campaign POC", "campaignPOCEmail": "campaign@example.com", "campaignStartDate": "2023-01-01", "campaignEndDate": "2023-01-10", "productDescription": "Product Description", "schedulingResponsible": "Scheduling Responsible", "baAttireRequest": "Attire Request", "needPOS": "Yes", "materialSummary": "Material Summary"}';

    // Create a REST request
    RestRequest request = new RestRequest();
    RestResponse response = new RestResponse();
    request.requestURI = '/services/apexrest/NewClientFormAPI';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');
    request.requestBody = Blob.valueOf(requestBody);

    // Set up the REST context
    RestContext.request = request;
    RestContext.response = response;

    // Create a test Lead record with the same email address to simulate an existing Lead
    Lead testLead = new Lead(
      FirstName = 'Test Class for Lead Record',
      LastName = 'Testing',
      Email = 'test@example.com',
      Company = 'Test Org',
      Webform_URL__c = 'Phun_for_all',
      LeadSource = 'Webform',
      New_Client_Form_Status__c = 'Sent',
      RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
        .getRecordTypeId()
    );
    insert testLead;

    // Call the REST service
    Test.startTest();
    NewClientFormAPI.doPost();
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
    request.requestURI = '/services/apexrest/NewClientFormAPI';
    request.httpMethod = 'POST';
    request.addHeader('Content-Type', 'application/json');
    request.requestBody = Blob.valueOf(requestBody);

    // Set up the REST context
    RestContext.request = request;
    RestContext.response = response;

    // Create a test Lead record with the same email address to simulate an existing Lead
    Lead testLead = new Lead(
      FirstName = 'Test Class for Lead Record',
      LastName = 'Testing',
      Email = 'test@example.com',
      Company = 'Test Org',
      Webform_URL__c = 'Phun_for_all',
      LeadSource = 'Webform',
      New_Client_Form_Status__c = 'Sent',
      RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
        .getRecordTypeId()
    );
    insert testLead;

    // Call the REST service
    Test.startTest();
    NewClientFormAPI.doPost();
    Test.stopTest();

    // Verify the response
    response = RestContext.response;
    System.assertEquals(400, response.statusCode);
    System.assertEquals('4003', response.responseBody.toString()); // Expected validation error code
  }
}
