@isTest
public class ContentVersionTriggerService_Test {
  @isTest
  public static void testDepositAfterUpdateTrigger() {
    List<Profile> p = [
      SELECT Id
      FROM Profile
      WHERE
        Name = 'System Administrator'
        AND profile.Userlicense.Name = 'Salesforce'
    ];
    User futureUser = new User(
      firstname = 'Future',
      lastname = 'User',
      alias = 'future',
      defaultgroupnotificationfrequency = 'N',
      digestfrequency = 'N',
      email = 'test@test.org',
      emailencodingkey = 'UTF-8',
      languagelocalekey = 'en_US',
      localesidkey = 'en_US',
      profileid = p[0].Id,
      timezonesidkey = 'America/Los_Angeles',
      username = 'futureasdasdasuser@test.org',
      userpermissionsmarketinguser = false,
      userpermissionsofflineuser = false
    );
    insert futureUser;
    System.runAs(futureUser) {
      Account acct = new Account(Name = 'TEST_ACCT');
      acct.BillingCity = 'Test City';
      acct.BillingState = 'Test state';
      acct.BillingCountry = 'Test cnt';
      acct.BillingStreet = 'Test st';
      acct.BillingPostalCode = 'Test 213';
      acct.BillingLatitude = 12.32;
      acct.BillingLongitude = 23.09;
      acct.QuickBooks_Accounts__c = 'Team Phun';
      acct.Art_Approval_Email__c = 'test@test.com';
      acct.Billing_Email__c = 'test@abc.com';
      insert acct;

      Opportunity opp = new Opportunity();
      opp.Name = 'Test Opp';
      opp.AccountId = acct.Id;
      opp.StageName = 'Needs Analysis';
      opp.CloseDate = Date.today();
      opp.OwnerId = futureUser.id;
      insert opp;

      ContentVersion contentVersion = new ContentVersion(
        Title = 'Penguins',
        PathOnClient = 'Penguins.jpg',
        VersionData = Blob.valueOf('Test Content'),
        IsMajorVersion = true
      );
      insert contentVersion;
      List<ContentDocument> documents = [
        SELECT Id, Title, LatestPublishedVersionId
        FROM ContentDocument
      ];

      //create ContentDocumentLink  record
      ContentDocumentLink cdl = new ContentDocumentLink();
      cdl.LinkedEntityId = opp.Id;
      cdl.ContentDocumentId = documents[0].Id;
      cdl.shareType = 'V';
      insert cdl;
    }
  }
}
