@isTest
public class Hourly_Estimate_Trigger_Test {
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
    List<Hourly_Estimate__c> estimatObjList = [
      SELECT Id
      FROM Hourly_Estimate__c
      LIMIT 3
    ];
    System.assertEquals(true, estimatObjList.size() > 0);
  }

  @isTest
  static void testUpdateField() {
    Id testId;
    List<Hourly_Estimate__c> estimatObjList = [
      SELECT Id, Region__c
      FROM Hourly_Estimate__c
      LIMIT 3
    ];
    if (estimatObjList.size() > 0) {
      testId = estimatObjList[0].Id;
      estimatObjList[0].Region__c = 'Tier 2';
      Test.startTest();
      update estimatObjList;
      Test.stopTest();
    }
    List<Hourly_Estimate__c> estimatObjList2 = [
      SELECT Id, Region__c, Hourly_Rate__c
      FROM Hourly_Estimate__c
      WHERE Id = :testId
    ];
    if (estimatObjList2.size() > 0) {
      System.assertEquals(true, estimatObjList2[0].Hourly_Rate__c != 0);
    }
  }
}
