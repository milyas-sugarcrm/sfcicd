@isTest
private class BillingReportControllerTest {
  @testSetup
  static void TestSetup() {
    TestFactory TF = new TestFactory();
    TF.createSimpleTestAccount();
    TF.createOpportunities();
    Account acc = [SELECT id FROM Account LIMIT 1];
    Opportunity opp = [SELECT id FROM opportunity LIMIT 1];
    PFA_Campaign__c PFACam = new PFA_Campaign__c(
      Name = 'test cam',
      PFA_Client__c = acc.id,
      PFA_Opportunity__c = opp.id,
      Photo_check_in__c = 'Disabled',
      Photo_check_out__c = 'Disabled'
    );
    insert PFACam;
    PFA_Event__c Event = new PFA_Event__c(
      Name = 'Test',
      PFA_Campaign_Id__c = PFACam.id
    );
    insert Event;
  }

  @isTest
  static void testGetEventBillingRecords() {
    String filterString = '';
    BillingReportController.getEventBillingRecords(filterString);
  }

  @isTest
  static void testCreateRecords() {
    PFA_Event__c Event = [SELECT id FROM PFA_Event__c LIMIT 1];
    List<String> recordIds = new List<String>{ Event.Id };
    Date eventStartDate = Date.today();
    Date eventEndDate = Date.today().addDays(7);

    Test.startTest();
    Id eventBilllingReportId = BillingReportController.createRecords(
      recordIds,
      eventStartDate,
      eventEndDate
    );
    Test.stopTest();
  }

  @isTest
  static void testCreatePFAEventBillingRecord() {
    List<PFA_Event__c> eventList = new List<PFA_Event__c>();

    Date eventStartDate = Date.today();
    Date eventEndDate = Date.today().addDays(7);

    Test.startTest();
    Id eventBilllingReportId = BillingReportController.createPFAEventBillingRecord(
      eventList,
      eventStartDate,
      eventEndDate
    );
    Test.stopTest();
  }
}
