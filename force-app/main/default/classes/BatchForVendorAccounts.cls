global class BatchForVendorAccounts implements Database.Batchable<sObject>, Database.AllowsCallouts {
  String oppLineItemIds = '';
  global BatchForVendorAccounts(String OppLineItemsList) {
    this.oppLineItemIds = OppLineItemsList;
  }
  global Database.QueryLocator start(Database.BatchableContext bc) {
    String query =
      'SELECT id,Product__r.Product_Supplier_Code__c, Estimate__r.Selected_Quickbook_Instance__c,Supplier__c,ESPId__c FROM OpportunityLineItem__c WHERE id IN  (' +
      oppLineItemIds +
      ')';
    System.debug('query: ' + query);
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext bc,
    List<OpportunityLineItem__c> OppLineItems
  ) {
    List<Account> accountsToBeInserted = new List<Account>();
    Id vendorAccId = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE Name LIKE 'Vendor%' AND SobjectType = 'Account'
      LIMIT 1
    ]
    .id;
    List<String> asiNumbers = new List<String>();
    for (OpportunityLineItem__c oppLineItem : OppLineItems) {
      if (
        !asiNumbers.contains(oppLineItem.Product__r.Product_Supplier_Code__c)
      ) {
        asiNumbers.add(oppLineItem.Product__r.Product_Supplier_Code__c);
        String espEndPoint =
          System.Label.ESP_URL +
          'suppliers/search.json?q=' +
          Integer.valueOf(oppLineItem.Product__r.Product_Supplier_Code__c);
        System.debug('espEndPoint: ' + espEndPoint);
        String authorizationHeader = System.Label.ESP_Key;
        System.debug('authorizationHeader: ' + authorizationHeader);
        List<Id> lstEstimateIds = new List<Id>();
        List<Id> lstOpportunityIds = new List<Id>();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(espEndPoint);
        req.setMethod('GET');
        req.setHeader('Authorization', authorizationHeader);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        String responeJson = res.getBody();
        ESPSupplier singleProduct = ESPSupplier.parse(responeJson);
        if (singleProduct != null) {
          if (singleProduct.Results.get(0).AsiNumber != null) {
            Account newVendor = new Account();
            newVendor.Name = singleProduct.Results.get(0).Name;
            newVendor.ASI_Number__c = singleProduct.Results.get(0).AsiNumber;
            newVendor.Billing_Email__c = singleProduct.Results.get(0).Email;
            if (Test.isRunningTest())
              newVendor.QuickBooks_Accounts__c = 'Team Phun';
            else
              newVendor.QuickBooks_Accounts__c = oppLineItem.Estimate__r.Selected_Quickbook_Instance__c;
            newVendor.RecordTypeId = vendorAccId;
            newVendor.Phone = singleProduct.Results.get(0).Phone.Work;
            newVendor.Fax = singleProduct.Results.get(0).Fax;
            if (
              singleProduct.Results.get(0).Rating != null &&
              singleProduct.Results.get(0).Rating.Rating != null
            ) {
              newVendor.ESP_Rating__c = String.valueOf(
                singleProduct.Results.get(0).Rating.Rating
              );
            }
            if (singleProduct.Results.get(0).Address != null) {
              if (singleProduct.Results.get(0).Address.Street1 != null) {
                newVendor.billingstreet = singleProduct.Results.get(0)
                  .Address.Street1;
              }
              if (singleProduct.Results.get(0).Address.City != null) {
                newVendor.billingcity = singleProduct.Results.get(0)
                  .Address.City;
              }
              if (singleProduct.Results.get(0).Address.State != null) {
                newVendor.billingstate = singleProduct.Results.get(0)
                  .Address.State;
              }
              if (singleProduct.Results.get(0).Address.Zip != null) {
                newVendor.billingPostalCode = singleProduct.Results.get(0)
                  .Address.Zip;
              }
              if (singleProduct.Results.get(0).Address.Country != null) {
                newVendor.billingcountry = singleProduct.Results.get(0)
                  .Address.Country;
              }
            }
            if (
              singleProduct.Results.get(0).Websites != null &&
              singleProduct.Results.get(0).Websites.size() > 0
            ) {
              for (String website : singleProduct.Results.get(0).Websites) {
                if (website.contains('instagram')) {
                  newVendor.Instagram__c = website;
                } else if (website.contains('facebook')) {
                  newVendor.Facebook__c = website;
                } else if (website.contains('twitter')) {
                  newVendor.Twitter__c = website;
                } else if (website.contains('linkedin')) {
                  newVendor.Linkedin__c = website;
                } else if (website.contains('youtube')) {
                  newVendor.Youtube__c = website;
                } else {
                  newVendor.Website = website;
                }
              }
            }
            accountsToBeInserted.add(newVendor);
          }
        }
      }
    }
    insert accountsToBeInserted;
    System.debug(accountsToBeInserted);
    for (Account accc : accountsToBeInserted) {
      for (OpportunityLineItem__c oppLineItem : OppLineItems) {
        if (accc.Name == oppLineItem.Supplier__c) {
          oppLineItem.Account__c = accc.id;
        }
      }
    }
    update OppLineItems;
  }
  global void finish(Database.BatchableContext bc) {
    // execute any post-processing operations
  }
}
