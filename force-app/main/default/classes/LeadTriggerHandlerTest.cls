@isTest
public class LeadTriggerHandlerTest {
  @isTest
  static void testSendEmailAndBellNotification() {
    // Create a test Lead with the "PFA Customer Lead" record type and the required status
    Lead testLead = new Lead(
      FirstName = 'Test Class for Lead Record',
      LastName = 'Testing',
      Company = 'Test Company',
      Webform_URL__c = 'Phun_for_all',
      LeadSource = 'Webform',
      New_Client_Form_Status__c = 'Sent',
      RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
        .getRecordTypeId()
    );
    insert testLead;

    // Perform the trigger action by updating insertedLead record
    Test.startTest();
    testLead.New_Client_Form_Status__c = 'Completed';
    update testLead;
    Test.stopTest();

    // Verify the changes on the Lead record
    Lead updatedLead = [SELECT Id, Status FROM Lead WHERE Id = :testLead.Id];
    System.assertEquals(
      'SLA Document',
      updatedLead.Status,
      'Lead Status should be "SLA Document"'
    );
  }
}
