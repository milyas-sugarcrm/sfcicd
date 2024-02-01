@isTest
public class SowVFControllerTest {
  @isTest
  static void testSowVFController() {
    Id pfaAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('PFA Customer Account')
      .getRecordTypeId();
    Id pfaOpportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

    // Create test Account and Opportunity
    Account testAccount = new Account(
      Name = 'Test Account',
      QuickBooks_Accounts__c = 'Team Phun',
      RecordTypeId = pfaAccountRecordType
    );
    insert testAccount;

    Opportunity testOpportunity = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today(),
      Preferred_Payment_Method_PFA__c = 'ACH Transfer; Credit Card; Check; Bill.com',
      AccountId = testAccount.Id,
      RecordTypeId = pfaOpportunityRecordType
    );
    insert testOpportunity;

    // Create test Contact
    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'test.contact@example.com',
      AccountId = testAccount.Id
    );
    insert testContact;

    // Create test Hourly Estimate and Expenses_Miscellaneous__c record
    Hourly_Estimate__c testEstimate = new Hourly_Estimate__c(
      Number_of_Activations__c = 2,
      Hours__c = 3.5,
      Hourly_Rate__c = 75,
      Opportunity__c = testOpportunity.Id
    );
    insert testEstimate;

    // Create test Expenses_Miscellaneous__c and Expenses_Miscellaneous__c record
    Expenses_Miscellaneous__c testExpense = new Expenses_Miscellaneous__c(
      Number_of_Months__c = 2,
      Number_of_Activations__c = 2,
      Number_of_Ambassadors__c = 2,
      Estimated_Cost__c = 40,
      Opportunity__c = testOpportunity.Id
    );
    insert testExpense;

    // Instantiate the controller with the StandardController
    Test.startTest();
    PageReference pageRef = Page.SOW;
    Test.setCurrentPage(pageRef);

    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testOpportunity
    );
    SowVFController controller = new SowVFController(stdController);
    Test.stopTest();

    // Verify the controller's behavior
    System.assertEquals(testContact.Id, controller.relatedContact.Id);
    System.assertEquals(true, controller.relatedTierEstimate.size() > 0);
    System.assertEquals(true, controller.relatedExpense.size() > 0);
  }
}
