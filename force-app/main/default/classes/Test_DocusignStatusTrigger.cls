@isTest
private class Test_DocusignStatusTrigger {
  @isTest
  static void testDocusignStatusUpdate() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Lead testLead = new Lead(
      FirstName = 'Test Class for Lead Record',
      LastName = 'Testing',
      Company = 'Test Company',
      email = 'test@test.com',
      New_Client_Form_Status__c = 'Sent',
      RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
        .getRecordTypeId()
    );
    insert testLead;

    Test.startTest();
    dfsle__EnvelopeStatus__c testDocuStatus = new dfsle__EnvelopeStatus__c();
    testDocuStatus.dfsle__Lead__c = testLead.Id;
    insert testDocuStatus;
    testDocuStatus.dfsle__Status__c = 'Completed';
    update testDocuStatus;
    Test.stopTest();

    // Verify the changes on the Lead record
    dfsle__EnvelopeStatus__c updatedDocuStatus = [
      SELECT Id, dfsle__Status__c
      FROM dfsle__EnvelopeStatus__c
      WHERE Id = :testDocuStatus.Id
    ];
    System.assertEquals(
      'Completed',
      updatedDocuStatus.dfsle__Status__c,
      'Incorrect Docusign Status'
    );
  }
}
