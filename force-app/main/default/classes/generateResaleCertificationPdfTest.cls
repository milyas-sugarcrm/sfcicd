@isTest
public class generateResaleCertificationPdfTest {
  @testSetup
  public static void createData() {
    List<RecordType> lstrecordType = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE SobjectType = 'Account' AND Name LIKE 'Vendor%'
    ];
    Account acc = new Account();
    acc.Name = 'Testing Vednor Account';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Standard_Turnaround__c = 1;
    acc.Primary_Category__c = 'Promotional Products';
    acc.BillingStreet = 'street';
    acc.Billingcity = 'city';
    acc.Billingstate = 'state';
    acc.BillingCountry = 'country';
    acc.ShippingStreet = 'street';
    acc.ShippingCity = 'city';
    acc.ShippingState = 'state';
    acc.ShippingCountry = 'country';
    if (lstrecordType != null && lstrecordType.size() > 0) {
      acc.RecordTypeId = lstrecordType.get(0).id;
    }
    insert acc;
  }

  @isTest
  public static void testResaleCertificate() {
    Account a = [
      SELECT id
      FROM Account
      WHERE name = 'Testing Vednor Account'
      LIMIT 1
    ];
    Test.startTest();
    generateResaleCertificationPdf.generateResalePDF(a.id);
    Test.stopTest();
  }
}
