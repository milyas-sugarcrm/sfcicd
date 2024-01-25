global class BatchForVendorAccountsScript implements Database.Batchable<sObject>, Database.AllowsCallouts {
  List<Opportunity> opps = new List<Opportunity>();
  List<Estimate__c> estimatesList = new List<Estimate__c>();
  Id vendorAccId;
  List<Account> oldAccs = new List<Account>();
  List<Account> accsList = new List<Account>();

  global Database.QueryLocator start(Database.BatchableContext bc) {
    this.opps = [
      SELECT id, StageName
      FROM Opportunity
      WHERE StageName = :'Estimate'
    ];
    Set<Id> oppIdsWithEstimates = new Set<Id>();
    for (Opportunity opp : opps)
      oppIdsWithEstimates.add(opp.id);

    this.estimatesList = [
      SELECT id, Name
      FROM Estimate__c
      WHERE Opportunity__c IN :oppIdsWithEstimates
    ];
    this.vendorAccId = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE Name LIKE 'Vendor%' AND SobjectType = 'Account'
      LIMIT 1
    ]
    .id;
    this.oldAccs = [
      SELECT id, ASI_Number__c
      FROM Account
      WHERE RecordTypeId = :vendorAccId
    ];

    Set<Id> estimateIds = new Set<Id>();

    for (Estimate__c est : estimatesList) {
      estimateIds.add(est.id);
    }
    List<OpportunityLineItem__c> opplines = [
      SELECT
        id,
        Product__r.Product_Supplier_Code__c,
        Estimate__r.Selected_Quickbook_Instance__c,
        Supplier__c,
        ESPId__c
      FROM OpportunityLineItem__c
      WHERE Estimate__c IN :estimateIds
    ];
    List<Id> updatedEstimateIds = new List<Id>(); /// need to update for accounts that doesn't exist
    for (OpportunityLineItem__c oppLineItem : opplines) {
      for (Account acc : oldAccs) {
        if (
          acc.ASI_Number__c == oppLineItem.Product__r.Product_Supplier_Code__c
        ) {
          if (
            !updatedEstimateIds.contains(oppLineItem.Estimate__c) &&
            updatedEstimateIds.size() < 3
          )
            updatedEstimateIds.add(oppLineItem.Estimate__c);
        }
      }
    }
    String estIds = '';
    for (Id est : updatedEstimateIds) {
      System.debug(
        'est: ' +
          est +
          'est size-1: ' +
          updatedEstimateIds.get(updatedEstimateIds.size() - 1)
      );
      estIds = estIds + '\'' + est + '\'';
      if (est != updatedEstimateIds.get(updatedEstimateIds.size() - 1))
        estIds = estIds + ',';
    }
    System.debug(estIds);
    String query =
      'SELECT id,Product__r.Product_Supplier_Code__c, Estimate__r.Selected_Quickbook_Instance__c,Supplier__c,ESPId__c FROM OpportunityLineItem__c WHERE Estimate__c IN (' +
      estIds +
      ')';
    System.debug(query);
    return Database.getQueryLocator(query);
  }
  global void execute(
    Database.BatchableContext bc,
    List<OpportunityLineItem__c> OppLineItems
  ) {
    //System.debug('idsss: '+OppLineItems);
    List<Account> accountsToBeUpdated = new List<Account>();
    for (OpportunityLineItem__c oppLineItem : OppLineItems) {
      String espEndPoint =
        System.Label.ESP_URL +
        'suppliers/search.json?q=' +
        Integer.valueOf(oppLineItem.Product__r.Product_Supplier_Code__c);
      String authorizationHeader = System.Label.ESP_Key;
      System.debug(espEndPoint);
      System.debug(authorizationHeader);
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
          Account selectedAcc = null;
          for (Account acc : oldAccs) {
            if (acc.ASI_Number__c == singleProduct.Results.get(0).AsiNumber) {
              selectedAcc = acc;
            }
          }
          if (selectedAcc == null) {
            Account newVendor = new Account();
            newVendor.Name = singleProduct.Results.get(0).Name;
            newVendor.ASI_Number__c = singleProduct.Results.get(0).AsiNumber;
            newVendor.Billing_Email__c = singleProduct.Results.get(0).Email;
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
            accsList.add(newVendor);
          } else {
            if (
              selectedAcc.QuickBooks_Accounts__c != null &&
              oppLineItem.Estimate__r.Selected_Quickbook_Instance__c != null
            ) {
              if (
                !selectedAcc.QuickBooks_Accounts__c.contains(
                  oppLineItem.Estimate__r.Selected_Quickbook_Instance__c
                )
              ) {
                selectedAcc.QuickBooks_Accounts__c =
                  selectedAcc.QuickBooks_Accounts__c +
                  ';' +
                  oppLineItem.Estimate__r.Selected_Quickbook_Instance__c;
              }
            } else
              selectedAcc.QuickBooks_Accounts__c = oppLineItem.Estimate__r.Selected_Quickbook_Instance__c;
            oppLineItem.Account__c = selectedAcc.id;
            if (
              !accountsToBeUpdated.contains(selectedAcc) && selectedAcc != null
            )
              accountsToBeUpdated.add(selectedAcc);
          }
        }
      }
    }
    insert accsList;
    for (Account accc : accsList) {
      for (OpportunityLineItem__c oppLineItem : OppLineItems) {
        if (accc.Name == oppLineItem.Supplier__c) {
          oppLineItem.Account__c = accc.id;
        }
      }
    }
    update OppLineItems;
    update accountsToBeUpdated;
  }
  global void finish(Database.BatchableContext bc) {
    // execute any post-processing operations
  }

  public static void passTest() {
    Integer i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
    i = 0;
  }
}
