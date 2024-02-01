@isTest
public class CreateRecordFromWordPress_Test {
  @testSetup
  static void generateTestAccounts() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    integer i = 1;
    Account acc = new Account(
      Name = 'Test Account ' + i,
      Google_Drive_Folder_Id__c = 'adasdasd' + i + 'adasd' + i + 3,
      Billing_Email__c = 'Test@Test.com',
      Art_Approval_Email__c = 'Test@Test.com',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country'
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

    req.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",   "Test": "This is TEst",   "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345", "Country": "US",  "flag": "Supplier",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req;
    RestContext.response = res;
    CreateRecordFromWordPress.createRecord();
    Test.stopTest();
  }
  @isTest
  static void test2() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",   "Test": "This is TEst",   "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345", "Country": "US",  "flag": "Distributor",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req;
    RestContext.response = res;
    CreateRecordFromWordPress.createRecord();
    Test.stopTest();
  }

  @isTest
  static void test3() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",   "Test": "This is TEst",   "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345", "Country": "US", "flag": "Supplier",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req;
    RestContext.response = res;
    CreateRecordFromWordPress.createRecord();
    //////////////////
    RestRequest req2 = new RestRequest();
    RestResponse res2 = new RestResponse();

    req2.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req2.httpMethod = 'POST';
    req2.addHeader('Content-Type', 'application/json');
    req2.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson2@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",   "Test": "This is TEst",   "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345","Country": "US",  "flag": "Supplier",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req2;
    RestContext.response = res2;
    CreateRecordFromWordPress.createRecord();
    Test.stopTest();
  }

  @isTest
  static void test4() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",      "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345","Country": "US",  "flag": "Supplier",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req;
    RestContext.response = res;
    CreateRecordFromWordPress.createRecord();

    RestRequest req2 = new RestRequest();
    RestResponse res2 = new RestResponse();

    req2.requestURI = '/services/apexrest/RecordCreate'; //Request URL
    req2.httpMethod = 'POST';
    req2.addHeader('Content-Type', 'application/json');
    req2.requestBody = Blob.valueOf(
      '{  "firstName": "Alex",  "lastName": "Johnson",  "email": "alexjohnson@example.com",  "company": "Tech Innovators",  "title": "Product Manager",   "ASI": "543210",     "phone": "777-888-9999",  "Street": "789 Elm Street",  "City": "Techville",  "State": "NY",  "ZipCode": "12345","Country": "US",  "flag": "Supplier",  "Events": [    "EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT"  ],  "HowDidYouHear": "Social Media"}'
    );

    RestContext.request = req2;
    RestContext.response = res2;
    CreateRecordFromWordPress.createRecord();
    Test.stopTest();
  }
  @isTest
  public static void test5() {
    List<Contact> existingContacts = [
      SELECT id, AccountId
      FROM Contact
      LIMIT 1
    ];
    List<Contact> existingContacts2 = [
      SELECT id, AccountId
      FROM Contact
      WHERE FirstName = 'Testing'
      LIMIT 1
    ];
    List<String> Events = new List<String>{
      'EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT',
      'EME Exclusive #4 September 15-18, 2024, Zachari Dunes on Mandalay Beach, Curio Collection by Hilton, Oxnard, CA'
    };
    Test.startTest();
    CreateRecordFromWordPress.HandleOpp(
      existingContacts,
      'firstName',
      'lastName',
      'email@test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Distributor Booking Opportunity'
    );
    CreateRecordFromWordPress.HandleOpp(
      existingContacts,
      'firstName',
      'lastName',
      'Test@Test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Distributor Booking Opportunity'
    );
    CreateRecordFromWordPress.HandleOpp(
      existingContacts,
      'firstName',
      'lastName',
      'Test1@Test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Vendor Booking Opportunity'
    );

    CreateRecordFromWordPress.HandleOpp(
      existingContacts2,
      'firstName',
      'lastName',
      'Test@Test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Distributor Booking Opportunity'
    );
    CreateRecordFromWordPress.HandleOpp(
      existingContacts2,
      'firstName',
      'lastName',
      'Test1@Test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Distributor Booking Opportunity'
    );
    CreateRecordFromWordPress.HandleOpp(
      existingContacts2,
      'firstName',
      'lastName',
      'Test1@Test.com',
      '234567894',
      'company',
      'title',
      'ASI',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'HowDidYouHear',
      Events,
      'EME Vendor Booking Opportunity'
    );

    CreateRecordFromWordPress.ValidateData(
      '',
      'lastName',
      'email',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      '',
      'email',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'email',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      '',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      '',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      '',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '03145628952',
      '',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'Supplier',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      'HowDidYouHear'
    );
    CreateRecordFromWordPress.ValidateData(
      'firstName',
      'lastName',
      'Test@Test.com',
      'company',
      'title',
      'ASI',
      '03145628952',
      'street',
      'city',
      'NY',
      'zipCode',
      'US',
      'flag',
      Events,
      ''
    );
    Test.stopTest();
  }
}
