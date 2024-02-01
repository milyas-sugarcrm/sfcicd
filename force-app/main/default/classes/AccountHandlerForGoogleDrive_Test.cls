@isTest
public class AccountHandlerForGoogleDrive_Test {
  @testSetup
  static void setupTestData() {
    Google_Auth__c auth = new Google_Auth__c(
      Token_Name__c = 'Latest',
      Access_Token__c = 'TestAccessToken'
    );
    insert auth;
  }

  public static List<Account> generateTestAccounts() {
    List<Account> testAccounts = new List<Account>();

    for (Integer i = 0; i < 10; i++) {
      Account acc = new Account(
        Name = 'Test Account ' + i,
        Google_Drive_Folder_Id__c = 'adasdasd' + i + 'adasd' + i + 3,
        Billing_Email__c = 'billing' + i + '@example.com',
        Art_Approval_Email__c = 'art' + i + '@example.com',
        QuickBooks_Accounts__c = 'Team Phun',
        BillingStreet = '123 Test Street',
        BillingCity = 'Test City',
        BillingState = 'Test State',
        BillingPostalCode = '12345',
        BillingCountry = 'Test Country'
      );
      testAccounts.add(acc);
    }
    return testAccounts;
  }

  @isTest
  public static void testHandleNewAccounts() {
    Account acc = new Account(
      Name = 'Test Account 100',
      Google_Drive_Folder_Id__c = 'adasdasd100adasd103',
      Billing_Email__c = 'billing100@example.com',
      Art_Approval_Email__c = 'art100@example.com',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country'
    );
    List<Account> newAccounts = generateTestAccounts();
    newAccounts.add(acc);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    AccountHandlerForGoogleDrive.handleNewAccounts(newAccounts);
    insert acc;
    acc.Name = 'B Test';
    acc.Google_Drive_Folder_Id__c = 'TestId';
    update acc;
    Test.stopTest();
  }

  @isTest
  public static void testcreateFolderFromButton() {
    Account acc = new Account(
      Name = 'Test Account 100',
      Google_Drive_Folder_Id__c = 'adasdasd100adasd103',
      Billing_Email__c = 'billing100@example.com',
      Art_Approval_Email__c = 'art100@example.com',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country'
    );

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    insert acc;
    Test.stopTest();
  }

  @isTest
  public static void testUpdateDriveFolderNameWrapper() {
    Account testAccount = new Account(
      Name = 'Test Account',
      Billing_Email__c = 'billing@example.com',
      Art_Approval_Email__c = 'art@example.com',
      Google_Drive_Folder_Id__c = 'TestkId',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country'
    );
    insert testAccount;

    Map<Id, Account> oldAccountMap = new Map<Id, Account>();
    oldAccountMap.put(testAccount.Id, testAccount);

    List<id> TestIds = new List<id>();
    TestIds.add(testAccount.Id);
    List<Account> newAccounts = new List<Account>();
    newAccounts.add(testAccount);

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    AccountHandlerForGoogleDrive.updateDriveFolderNameWrapper(
      newAccounts,
      oldAccountMap
    );
    testAccount.Name = 'Changed';

    update testAccount;
    AccountHandlerForGoogleDrive.updateDriveFolderName(TestIds);
    Test.stopTest();
  }

  @isTest
  public static void testDeleteGoogleDriveFolder() {
    List<Account> deletedAccounts = generateTestAccounts();

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    AccountHandlerForGoogleDrive.handleAccountDeletion(deletedAccounts);
    Test.stopTest();
  }

  @isTest
  public static void testUpdateDriveFolderName() {
    Account testAccount = new Account(
      Name = 'TestAccount',
      Google_Drive_Folder_Id__c = 'adasdasd123adasd123',
      Billing_Email__c = 'billing123@example.com',
      Art_Approval_Email__c = 'art123@example.com',
      QuickBooks_Accounts__c = 'Team Phun',
      BillingStreet = '123 Test Street',
      BillingCity = 'Test City',
      BillingState = 'Test State',
      BillingPostalCode = '12345',
      BillingCountry = 'Test Country'
    );
    insert testAccount;
    testAccount.Name = 'Changed';
    update testAccount;
    List<Id> accountIds = new List<Id>{ testAccount.Id };

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    AccountHandlerForGoogleDrive.updateDriveFolderName(accountIds);
    update testAccount;
    Test.stopTest();
  }
}
