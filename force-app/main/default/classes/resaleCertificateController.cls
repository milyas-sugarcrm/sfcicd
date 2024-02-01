public with sharing class resaleCertificateController {
  public final Account accountId { get; set; }

  public resaleCertificateController() {
    String accountIds = ApexPages.currentPage().getParameters().get('id');
    this.accountId = [SELECT Id, Name FROM Account WHERE id = :accountIds];
  }

  public resaleCertificateController(
    ApexPages.StandardController stdController
  ) {
    this.accountId = (Account) stdController.getRecord();
  }
  public String getVendorAccountName() {
    Account accountName = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :this.accountId.Id
    ];
    return accountName.Name;
  }
  public map<String, String> getVendorAddress() {
    map<String, String> address = new Map<String, String>();
    Account acc = [
      SELECT
        Id,
        Name,
        billingstreet,
        billingcity,
        billingstate,
        billingPostalCode,
        BillingCountry
      FROM Account
      WHERE Id = :this.accountId.Id
    ];

    if (acc.billingstreet != null) {
      address.put('billingstreet', acc.billingstreet + ', ');
    } else {
      address.put('billingstreet', '');
    }
    if (acc.billingcity != null) {
      address.put('billingcity', acc.billingcity + ', ');
    } else {
      address.put('billingcity', '');
    }
    if (acc.billingstate != null) {
      address.put('billingstate', acc.billingstate + ', ');
    } else {
      address.put('billingstate', '');
    }
    if (acc.billingPostalCode != null) {
      address.put('billingPostalCode', acc.billingPostalCode + ', ');
    } else {
      address.put('billingPostalCode', '');
    }
    if (acc.BillingCountry != null) {
      address.put('billingCountry', acc.BillingCountry);
    } else {
      address.put('billingCountry', '');
    }
    return address;
  }

  public String getCurrentDate() {
    String pdfdate = Date.newInstance(System.date.today().Year(), 1, 1)
      .format();
    return pdfdate;
  }
  public Account getAccount() {
    return accountId;
  }
}
