@isTest
public class Test_TriggerOnContact {
  @isTest
  static void testContactTrigger() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Account acc = new Account();
    acc.Name = 'Testing account789';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.BillingStreet = 'TestBS';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = 'testCity789';
    acc.Billingstate = 'testState789';
    acc.BillingCountry = 'testCountry789';

    acc.ShippingStreet = 'testSTreet';
    acc.ShippingCity = 'testSCity';
    acc.ShippingState = 'TestSS';
    acc.ShippingCountry = 'TestSc';
    try {
      insert acc;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }

    Contact testContact = new Contact(
      FirstName = 'test1',
      LastName = 'Doe',
      AccountId = acc.Id
    );
    insert testContact;
    testContact.FirstName = 'test2';
    update testContact;
    Contact updatedContact = [
      SELECT Id, FirstName
      FROM Contact
      WHERE Id = :testContact.Id
    ];
    System.assertEquals('test2', updatedContact.FirstName);
  }
}
