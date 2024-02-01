@isTest
public class WordPressJoinOurTeamForm_Test {
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
  }
  @isTest
  static void test1() {
    Test.startTest();
    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();

    req.requestURI = '/services/apexrest/JoinOurTeam'; //Request URL
    req.httpMethod = 'POST';
    req.addHeader('Content-Type', 'application/json');
    req.requestBody = Blob.valueOf(
      '{"first_name": "Sohaib",  "last_name": "YourLastName",  "email": "SohaibSaqib@example.com",  "phone": "123-456-7890",  "state_of_residence": "Georgia",  "birthday": "1998-10-12", "primary_language": "Arabic",  "secondary_language": "N/A",  "brand_activations_experience": [    "Alcoholic Beverage Promotions",    "Field Team Lead",    "Gourmet Food & Beverage Demos & Samplings",    "Guerrilla Marketing",    "Merchandising & Market Research",    "Mobile Tours",    "On Premise Bar",    "Road Show Activations (Warehouse/Club Stores)",    "Special Events & Fundraising Events",    "Street Teams"  ],  "certifications": [    "Cicerone (Level 1 or above)",    "Food & Beverage Handling",    "Responsible Alcoholic Beverage Serving (TIPS)",    "Sommelier (Introductory to Master)",    "State-Mandated Alcoholic Beverage Serving",    "State-Mandated Food & Beverage Handling"  ],  "rbs_server_id": "12345",   "pop_bookings_profile": "Yes",   "supplies": "Yes! I have a portable table, black fabric tablecloth, and unbranded neutral color ice bucket",  "certify_age": true,   "hear_about_us": "Instagram",  "referral_name": "ReferrerName",  "Headshot_Photo": "Paste Blob Here", "Full_Length_Photo": "Paste Blob Here", "Additional_Image": "Paste Blob Here"}'
    );

    RestContext.request = req;
    RestContext.response = res;
    WordPressJoinOurTeamForm.createRecord();
    ////////////////
    RestRequest req2 = new RestRequest();
    RestResponse res2 = new RestResponse();

    req2.requestURI = '/services/apexrest/ContactUs'; //Request URL
    req2.httpMethod = 'POST';
    req2.addHeader('Content-Type', 'application/json');
    req2.requestBody = Blob.valueOf(
      '{"first_name": "Sohaib",  "last_name": "YourLastName",  "email": "SohaibSaqib@example.com",  "phone": "123-456-7890",  "state_of_residence": "Georgia",  "birthday": "1998-10-12", "primary_language": "Arabic",  "secondary_language": "N/A",  "brand_activations_experience": [    "Alcoholic Beverage Promotions",    "Field Team Lead",    "Gourmet Food & Beverage Demos & Samplings",    "Guerrilla Marketing",    "Merchandising & Market Research",    "Mobile Tours",    "On Premise Bar",    "Road Show Activations (Warehouse/Club Stores)",    "Special Events & Fundraising Events",    "Street Teams"  ],  "certifications": [    "Cicerone (Level 1 or above)",    "Food & Beverage Handling",    "Responsible Alcoholic Beverage Serving (TIPS)",    "Sommelier (Introductory to Master)",    "State-Mandated Alcoholic Beverage Serving",    "State-Mandated Food & Beverage Handling"  ],  "rbs_server_id": "12345",   "pop_bookings_profile": "Yes",   "supplies": "Yes! I have a portable table, black fabric tablecloth, and unbranded neutral color ice bucket",  "certify_age": true,   "hear_about_us": "Instagram",  "referral_name": "ReferrerName",  "Headshot_Photo": "Paste Blob Here", "Full_Length_Photo": "Paste Blob Here", "Additional_Image": "Paste Blob Here"}'
    );

    RestContext.request = req2;
    RestContext.response = res2;
    WordPressJoinOurTeamForm.createRecord();

    Test.stopTest();
  }
}
