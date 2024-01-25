global class AccountsUpdationBatch implements Database.Batchable<sObject> {
  global Database.QueryLocator start(Database.BatchableContext BC) {
    String query =
      'SELECT Id,Name,QB_Record_ID__c,QBO_Accounts_Count__c ' +
      ' FROM Account where QB_Record_ID__c != null And QBO_Accounts_Count__c = 0 ';
    return Database.getQueryLocator(query);
  }
  global void execute(Database.BatchableContext BC, List<Account> lstAccounts) {
    List<QBO_Details__c> lstRelatedDetailsQB = new List<QBO_Details__c>();
    for (Account acc : lstAccounts) {
      acc.QuickBooks_Accounts__c = 'Team Phun';
      if (acc.QB_Record_ID__c != null) {
        QBO_Details__c qbDetailObj = new QBO_Details__c();
        qbDetailObj.Account__c = acc.id;
        qbDetailObj.Id_Type__c = 'Account';
        qbDetailObj.QBO_Account__c = 'Team Phun';
        qbDetailObj.Salesforce_Record_Id__c = acc.id;
        qbDetailObj.QB_Id__c = acc.QB_Record_ID__c;
        lstRelatedDetailsQB.add(qbDetailObj);
      }
    }
    insert lstRelatedDetailsQB;
    update lstAccounts;
  }
  global void finish(Database.BatchableContext BC) {
    // execute any post-processing operations
  }
}
