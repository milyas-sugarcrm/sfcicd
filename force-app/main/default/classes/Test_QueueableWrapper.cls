@isTest
public class Test_QueueableWrapper {
  @testSetup
  public static void createDate() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('4', 'lhr', 'Punjab', 'Pakistan');
  }

  @isTest
  public static void testQueueableWrapper() {
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    Map<String, Set<Id>> datamap = new Map<String, Set<Id>>();
    List<Account> lstAccount = [
      SELECT Id, QuickBooks_Accounts__c
      FROM Account
      LIMIT 1
    ];
    List<QBO_Details__c> lstQBODetails = new List<QBO_Details__c>();

    List<QB_Credentials__c> lstQBCredentails = new List<QB_Credentials__c>();
    Set<String> setAccountTypes = new Set<String>();
    for (Account acc : lstAccount) {
      List<String> lstQBAccounts = new List<String>();
      lstQBAccounts.addAll(acc.QuickBooks_Accounts__c.split(';'));
      String type = '';
      for (String key : lstQBAccounts) {
        type = key;
        if (datamap.containsKey(key)) {
          datamap.get(key).add(acc.Id);
        } else {
          datamap.put(key, new Set<Id>());
          datamap.get(key).add(acc.Id);
        }
        setAccountTypes.add(key);
      }
      QBO_Details__c qboDetails = new QBO_Details__c();
      qboDetails.QB_Id__c = null;
      qboDetails.Account__c = acc.Id;
      qboDetails.id_Type__c = 'Account';
      qboDetails.QBO_Account__c = type;
      qboDetails.Salesforce_Record_Id__c = acc.id;
      lstQBODetails.add(qboDetails);
    }
    for (String key : setAccountTypes) {
      QB_Credentials__c qbCredentialsObj = new QB_Credentials__c();
      qbCredentialsObj.Access_token__c = 'rtAccessToken';
      qbCredentialsObj.Refresh_token__c = 'rtRefreshToken';
      qbCredentialsObj.Synced_Account_Title__c = key;
      lstQBCredentails.add(qbCredentialsObj);
    }
    insert lstQBODetails;
    insert lstQBCredentails;
    Test.startTest();
    QueueableWrapper.testPass();
    Test.stopTest();
  }
}
