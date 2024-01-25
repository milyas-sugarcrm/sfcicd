@isTest
public class QuoteRequestTriggerHandlerTest {
  @isTest
  static void testHandleAfterInsert() {
    // Create test data
    List<String> quickBooksValues = new List<String>{
      'Team Phun',
      'Phun for All'
    };
    String quickBooksValuesString = String.join(quickBooksValues, ';');

    Account testAccount = new Account(
      Name = 'Test Account',
      Billing_Email__c = 'Sohaibsaqib102@gmail.com',
      Art_Approval_Email__c = 'Sohaibsaqib102@gmail.com',
      QuickBooks_Accounts__c = quickBooksValuesString,
      BillingStreet = '2542',
      BillingCity = 'NY',
      BillingCountry = 'USA'
    );
    insert testAccount;

    Contact testContact = new Contact(
      FirstName = 'First Name',
      LastName = 'Test Contact',
      AccountId = testAccount.Id
    );
    insert testContact;

    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      AccountId = testAccount.Id,
      StageName = 'Needs Analysis',
      CloseDate = System.today() + 7
    );
    insert testOpportunity;

    Quote_Request__c testQuoteRequest = new Quote_Request__c(
      Name = 'Test Quote Request',
      Opportunity_Name__c = testOpportunity.Id,
      //Email_Address__c = 'Sohaibsaqib102@gmail.com',
      Art_File_Name__c = 'Art File Name'
    );
    insert testQuoteRequest;

    // Set up test context
    Test.startTest();

    // Trigger the after insert event
    List<Quote_Request__c> newRecords = new List<Quote_Request__c>{
      testQuoteRequest
    };
    QuoteRequestTriggerHandler.handleAfterInsert(newRecords);

    Test.stopTest();
  }
}
