@isTest
public class LeadTriggerService_Test {
  @testSetup
  static void setupmethod() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createTestAccount();
    string values = 'Team Phun';
    Lead testLead = new Lead(
      FirstName = 'Test1',
      LastName = 'Lead1',
      Company = 'Test Company1',
      Status = 'New',
      Email = 'Test1@Test.com',
      Title = 'Title1',
      Phone = '6851132',
      Street = 'Street1',
      City = 'city1',
      State = 'NY',
      PostalCode = '3424',
      Art_Approval_Email__c = 'Test@Test.com',
      Billing_Email__c = 'Test@Test.com',
      QuickBooks_Accounts__c = values,
      Estimated_Amount__c = 20
    );
    insert testLead;
  }

  @isTest
  static void testLeadProcesses1() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Lead testLead = [
      SELECT id, Billing_Email__c, Art_Approval_Email__c
      FROM Lead
      LIMIT 1
    ];

    Database.LeadConvert lc = new database.LeadConvert();
    lc.setLeadId(testLead.Id);
    lc.setConvertedStatus('Qualified');
    Database.LeadConvertResult lcr = Database.convertLead(lc);
    Id customerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
      .get('Customer_Lead')
      .getRecordTypeId();
    testLead.RecordTypeId = customerLeadRecordTypeId;
    Test.startTest();
    testLead.LeadSource = 'Seamless.AI';
    update testLead;
    Test.StopTest();
  }
}
