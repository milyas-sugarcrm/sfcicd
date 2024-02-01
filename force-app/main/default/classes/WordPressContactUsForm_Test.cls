@isTest
public class WordPressContactUsForm_Test {
  @testSetup
  static void generateTestAccounts() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account(
      Name = 'Phun For All',
      Billing_Email__c = 'Test@Test.com',
      Art_Approval_Email__c = 'Test@Test.com',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country',
      RecordTypeId = '0128M0000000FbgQAE'
    );
    insert acc;

    Contact con = new Contact(
      FirstName = 'Test',
      LastName = 'Last',
      AccountId = acc.id,
      Email = 'Test@Test.com'
    );
    insert con;

    Contact con2 = new Contact(
      FirstName = 'Testing',
      LastName = 'Last',
      AccountId = acc.id,
      Email = 'Testad@Test.com'
    );
    insert con2;

    Opportunity newOpportunity = new Opportunity();
    newOpportunity.Name = 'firstName' + ' ' + 'lastName' + ' Opportunity';
    newOpportunity.Email__c = 'Test@Test.com';
    newOpportunity.Phone__c = '654651651';
    newOpportunity.Company__c = 'company';
    newOpportunity.Title__c = 'title';
    newOpportunity.Industry_Number__c = 'ASI';
    newOpportunity.Billing_Address__c = 'address';
    //  newOpportunity.Event_Name__c = String.join(Events, ';');
    newOpportunity.AccountId = acc.Id;
    newOpportunity.Contact__c = con.Id;
    newOpportunity.StageName = 'Needs Analysis';
    newOpportunity.CloseDate = System.today() + 7;
    insert newOpportunity;
  }

  @isTest
  static void test1() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/ContactUs'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "John",  "lastName": "Doe",  "email": "john.doe@example.com",  "company": "ABC Corp",  "venues": "Event Venue XYZ",  "phone": "123-456-7890",  "message": "I am interested in your services.",  "flag": "About Us",  "howDidYouHear": "Social Media",  "interestedIn": ["Brand Ambassador", "In Store Demos"]}'
    );

    RestContext.request = req;
    RestContext.response = res;
    WordPressContactUsForm.doPost();
    ////////////////
    RestRequest req2 = new RestRequest();
    RestResponse res2 = new RestResponse();

    req2.requestURI = '/services/apexrest/ContactUs'; //Request URL
    req2.httpMethod = 'POST';
    req2.addHeader('Content-Type', 'application/json');
    req2.requestBody = Blob.valueOf(
      '{  "firstName": "Johnny",  "lastName": "Doe",  "email": "john.doe@example.com",  "company": "ABC Corp",   "venues": "Event Venue XYZ",  "phone": "123-456-7890",  "message": "I am interested in your services.",  "flag": "About Us",  "howDidYouHear": "Social Media",  "interestedIn": ["Brand Ambassador", "In Store Demos"]}'
    );

    RestContext.request = req2;
    RestContext.response = res2;
    WordPressContactUsForm.doPost();

    Test.stopTest();
  }

  @isTest
  static void test2() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/ContactUs'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "John",  "lastName": "Doe",  "email": "john.doe@example.com",  "company": "ABC Corp",   "venues": "Event Venue XYZ",  "phone": "123-456-7890",  "message": "I am interested in your services.",  "flag": "About Us",  "howDidYouHear": "Social Media",  "interestedIn": ["Brand Ambassador", "In Store Demos"]}'
    );

    RestContext.request = req;
    RestContext.response = res;
    WordPressContactUsForm.doPost();
    ////////////
    RestRequest req2 = new RestRequest();
    RestResponse res2 = new RestResponse();

    req2.requestURI = '/services/apexrest/ContactUs'; //Request URL
    req2.httpMethod = 'POST';
    req2.addHeader('Content-Type', 'application/json');
    req2.requestBody = Blob.valueOf(
      '{  "firstName": "Johnny",  "lastName": "Doe",  "email": "john.doe@example.com",  "company": "ABC Corp",  "venues": "Event Venue XYZ",  "phone": "123-456-7890",  "message": "I am interested in your services.",  "flag": "About Us",  "howDidYouHear": "Social Media",  "interestedIn": ["Brand Ambassador", "In Store Demos"]}'
    );

    RestContext.request = req2;
    RestContext.response = res2;
    WordPressContactUsForm.doPost();

    Test.stopTest();
  }
}
