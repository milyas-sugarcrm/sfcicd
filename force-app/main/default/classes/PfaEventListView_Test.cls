@isTest
private class PfaEventListView_Test {
  @TestSetup
  public static void makeData() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Id pfaCustomerAccRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('PFA Customer Account')
      .getRecordTypeId();
    // Create a new Account record
    Account newAccount = new Account(
      Name = 'Test Account',
      Industry = 'Technology',
      BillingCity = 'Test City',
      RecordTypeId = pfaCustomerAccRecordType,
      QuickBooks_Accounts__c = 'Phun for All'
    );
    insert newAccount;

    Id pfaCustomerOppRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();
    // Create a new Opportunity record
    Opportunity newOpportunity = new Opportunity(
      Name = 'Test PFA Opportunity',
      AccountId = newAccount.Id,
      StageName = 'Needs Analysis',
      CloseDate = Date.today().addDays(30),
      Amount = 10000,
      Probability = 25,
      RecordTypeId = pfaCustomerOppRecordType
    );
    insert newOpportunity;

    PFA_Campaign__c newCampaign = new PFA_Campaign__c(
      Name = 'Test PFA Campaign',
      PFA_Client__c = newAccount.Id,
      PFA_Opportunity__c = newOpportunity.Id
    );
    insert newCampaign;
  }

  static ID testID = '000000000000000000';
  @isTest
  static void testGetEvents() {
    List<PFA_Event__c> result = PfaEventListView.getEvents(testID, 'Active');
    System.assertEquals(0, result.size());
  }

  @isTest
  static void testDeleteEventRecord() {
    PfaEventListView.deleteEventRecord(testID);
    List<PFA_Event__c> deletedEvents = [
      SELECT Id
      FROM PFA_Event__c
      WHERE Id = :testID
    ];
    System.assertEquals(0, deletedEvents.size());
  }

  @isTest
  static void testgetClientAccountId() {
    List<Account> accList = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Account'
      LIMIT 1
    ];
    List<PFA_Campaign__c> campaignRecord = [
      SELECT Id, Name, PFA_Client__c, PFA_Opportunity__c
      FROM PFA_Campaign__c
      WHERE Name = 'Test PFA Campaign'
      LIMIT 1
    ];
    Id accId = PfaEventListView.getClientAccountId(campaignRecord[0].Id);
    System.assertEquals(accList[0].Id, accId);
  }
}
