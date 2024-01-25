@istest
public class QBODetailsTriggerService_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount(
      'testStreet',
      'testCity',
      'testState',
      'testCountry'
    );
    List<Opportunity> opportunities = [
      SELECT Id, AccountId
      FROM Opportunity
    ];
    Account acc = [
      SELECT Id, QBO_Accounts_Count__c
      FROM Account
      WHERE QBO_Accounts_Count__c > 0
      LIMIT 1
    ];

    for (Opportunity opp : opportunities) {
      opp.AccountId = acc.Id;
    }
  }
  @istest
  public static void testDeletion() {
    try {
      Account acc = [
        SELECT Id, QBO_Accounts_Count__c
        FROM Account
        WHERE QBO_Accounts_Count__c > 0
        LIMIT 1
      ];
      QBO_Details__c qboDetailsTpSupply = new QBO_Details__c();
      qboDetailsTpSupply.Account__c = acc.Id;
      qboDetailsTpSupply.Id_Type__c = 'Account';
      qboDetailsTpSupply.IsPrimary__c = true;
      qboDetailsTpSupply.QB_Id__c = '123';
      qboDetailsTpSupply.Salesforce_Record_Id__c = acc.Id;
      qboDetailsTpSupply.QBO_Account__c = 'Team Phun';
      insert qboDetailsTpSupply;
      delete qboDetailsTpSupply;
    } catch (Exception ex) {
    }
  }
}
