@isTest
public class ExpensesMiscellaneousTrigger_Test {
  static final Id pfaOppRecordTypeId = CommonUtilitiesPfa.getRecordTypeIdByName(
    Constants.OPPORTUNITY_API_NAME,
    Constants.PFA_CUSTOMER_OPPORTUNITY
  );
  static Id oppId;

  @TestSetup
  static void setupTestData() {
    Opportunity opp = new Opportunity(Name = 'Test Opp ');
    opp.StageName = 'Needs Analysis';
    opp.CloseDate = Date.today();
    opp.RecordTypeId = pfaOppRecordTypeId;
    insert opp;
    oppId = opp.id;
  }

  @isTest
  static void testObjectCreated() {
    List<Expenses_Miscellaneous__c> expenseObjList = [
      SELECT Id
      FROM Expenses_Miscellaneous__c
      LIMIT 3
    ];
    System.assertEquals(true, expenseObjList.size() > 0);
  }

  @isTest
  static void testUpdateField() {
    Id testId;
    List<Expenses_Miscellaneous__c> expObjList = [
      SELECT Id, Estimated_Cost__c, Expense_Type__c
      FROM Expenses_Miscellaneous__c
      LIMIT 3
    ];
    if (expObjList.size() > 0) {
      testId = expObjList[0].Id;
      expObjList[0].Expense_Type__c = Constants.EXP_TYPE_3;
      Test.startTest();
      update expObjList;
      Test.stopTest();
    }
    List<Expenses_Miscellaneous__c> expObjList2 = [
      SELECT Id, Estimated_Cost__c, Expense_Type__c
      FROM Expenses_Miscellaneous__c
      WHERE Id = :testId
    ];
    if (expObjList2.size() > 0) {
      System.assertEquals(true, expObjList2[0].Estimated_Cost__c != 0);
    }
  }
}
