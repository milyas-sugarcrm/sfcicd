@isTest
private class GoogleFormToLeadTest {
  @isTest
  static void testDoPost() {
    // Mock the REST request
    RestRequest req = new RestRequest();
    req.requestURI = '/services/apexrest/Lead/';
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{"json": "[{\\"email\\": \\"test@example.com\\", \\"What is your Name of Your Organization?\\": \\"Test Org1\\"}]"}'
    );
    RestContext.request = req;

    // Mock the Google Form response
    GoogleFromToLeadParser mockParser = new GoogleFromToLeadParser();
    mockParser.question = 'What is your Name of Your Organization?';
    mockParser.answer = 'Test Org';

    Test.startTest();
    Lead testLead = new Lead(
      Email = 'test@example.com',
      firstName = 'testName',
      lastName = 'testName',
      Company = 'testCompanyName'
    );
    insert testLead;
    Test.setMock(
      HttpCalloutMock.class,
      new MockLeadUpdateHttpResponseGenerator()
    );
    GoogleFormToLead.doPost();
    Test.stopTest();

    // Perform assertions
    List<Lead> leads = [
      SELECT Id, New_Client_Form_Status__c, Organization_Name_PFA__c
      FROM Lead
      WHERE Email = 'test@example.com'
    ];
    System.assertEquals(1, leads.size());
    System.assertEquals('Completed', leads[0].New_Client_Form_Status__c);
    System.assertEquals('Test Org1', leads[0].Organization_Name_PFA__c);
  }
}
