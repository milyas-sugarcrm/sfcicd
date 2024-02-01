@isTest
public with sharing class resaleCertificateControllerTest {
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
  public static void testPdf() {
    Test.startTest();
    ApexPages.StandardController sc = new ApexPages.StandardController(
      [SELECT id FROM Account LIMIT 1]
    );
    resaleCertificateController ext = new resaleCertificateController(sc);
    ext.getAccount();
    ext.getCurrentDate();
    ext.getVendorAccountName();
    ext.getVendorAddress();
    Test.stopTest();
  }

  @isTest
  public static void testPdf2() {
    Test.setCurrentPageReference(
      new PageReference('Page.resaleCertificationPDF')
    );
    System.currentPageReference()
      .getParameters()
      .put('id', [SELECT id FROM Account LIMIT 1].id);
    resaleCertificateController ext = new resaleCertificateController();
  }
}
