@isTest
private class Test_CommonUtilitiesPfa {
  @isTest
  static void testGetRecordTypeIdByName() {
    Schema.RecordTypeInfo rtInfo = Account.SObjectType.getDescribe()
      .getRecordTypeInfosByName()
      .values()[0];
    Id testRecordTypeId = rtInfo.getRecordTypeId();

    Test.startTest();
    Id returnedRecordTypeId = CommonUtilitiesPfa.getRecordTypeIdByName(
      'Account',
      rtInfo.getName()
    );
    Test.stopTest();

    System.assertEquals(
      testRecordTypeId,
      returnedRecordTypeId,
      'Expected and actual record type IDs should match'
    );
  }
  @isTest
  static void testGetRecordLink() {
    Test.startTest();
    Lead testLead = new Lead(
      FirstName = 'Test Class for Lead Record',
      LastName = 'Testing',
      Email = 'test@example.com',
      Company = 'Test Org',
      Webform_URL__c = 'Phun_for_all',
      LeadSource = 'Webform',
      New_Client_Form_Status__c = 'Sent',
      RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
        .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
        .getRecordTypeId()
    );
    insert testLead;
    String url = CommonUtilitiesPfa.getRecordLink(testLead.Id);
    Test.stopTest();

    System.assertNotEquals(
      null,
      url,
      'Expected and actual record type IDs should match'
    );
  }
}
