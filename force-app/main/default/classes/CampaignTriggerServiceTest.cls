@isTest
public class CampaignTriggerServiceTest {
  @isTest
  public static void testPopulateIdOnOpp() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      OwnerId = UserInfo.getUserId(),
      Billing_Contact_Email_PFA__c = 'test@email.com',
      Campaign_POC__c = 'Test POC',
      Campaign_POC_Email__c = 'poc@email.com',
      Campaign_Start_Date__c = Date.today(),
      Campaign_End_Date__c = Date.today() + 30,
      CloseDate = Date.today() + 30
    );
    insert testOpp;

    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.Art_Approval_Email__c = 'test@test.com';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.QuickBooks_Accounts__c = 'Team Phun';
    insert acc;
    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    PFA_Campaign__c testCampaign = new PFA_Campaign__c(
      PFA_Opportunity__c = testOpp.id,
      PFA_Client__c = acc.id
    );

    insert testCampaign;

    List<PFA_Campaign__c> testCampaignList = new List<PFA_Campaign__c>{
      testCampaign
    };
    CampaignTriggerService.PopulateIdOnOpp(testCampaignList);

    Opportunity updatedOpportunity = [
      SELECT Id, PFA_Campaign__c
      FROM Opportunity
      WHERE Id = :testOpp.Id
    ];
    System.assertEquals(testCampaign.Id, updatedOpportunity.PFA_Campaign__c);
  }

  @isTest
  public static void testPopulateOppProducts() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      OwnerId = UserInfo.getUserId(),
      Billing_Contact_Email_PFA__c = 'test@email.com',
      Campaign_POC__c = 'Test POC',
      Campaign_POC_Email__c = 'poc@email.com',
      Campaign_Start_Date__c = Date.today(),
      Campaign_End_Date__c = Date.today() + 30,
      CloseDate = Date.today() + 30
    );
    insert testOpp;

    Account acc = new Account();
    acc.Name = 'Test Account';
    acc.Billing_Email__c = 'test@test.com';
    acc.BillingStreet = 'Test Billing Address';
    acc.Art_Approval_Email__c = 'test@test.com';
    acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    acc.QuickBooks_Accounts__c = 'Team Phun';
    insert acc;
    Contact con = new Contact();
    con.FirstName = 'Rt';
    con.LastName = 'Test Contact';
    con.AccountId = acc.Id;
    insert con;

    PFA_Campaign__c testCampaign = new PFA_Campaign__c(
      PFA_Opportunity__c = testOpp.id,
      PFA_Client__c = acc.id
    );

    List<PFA_Campaign__c> testCampaignList = new List<PFA_Campaign__c>{
      testCampaign
    };
    CampaignTriggerService.populateOppProducts(testCampaignList);
  }
}
