public class AccountTriggerHandler {
  public static boolean firstRun = true;
  public static void checkDuplicateAccount(List<Account> lstNewAccount) {
    List<String> accountNameList = new List<String>();
    for (Account accoun : lstNewAccount) {
      accountNameList.add(accoun.Name);
    }
    List<Account> listOfExistingAccounts = [
      SELECT Id, Name
      FROM Account
      WHERE Name = :accountNameList
    ];
    for (Account acc : listOfExistingAccounts) {
      for (Account accoun : lstNewAccount) {
        if (acc.Name == accoun.Name && acc.Id != accoun.Id) {
          accoun.addError('Account with same name already exists');
        }
      }
    }
  }
  public static boolean checkFieldsChangedForSync(
    List<Account> lstNewAccount,
    Map<Id, Account> mapOldAccount
  ) {
    if (
      lstNewAccount != null &&
      mapOldAccount != null &&
      mapOldAccount.size() > 0
    ) {
      for (Account acc : lstNewAccount) {
        if (
          acc.Name != mapOldAccount.get(acc.Id).Name ||
          acc.Phone != mapOldAccount.get(acc.Id).Phone ||
          acc.Billing_Email__c != mapOldAccount.get(acc.Id).Billing_Email__c ||
          acc.BillingStreet != mapOldAccount.get(acc.Id).BillingStreet ||
          acc.BillingCity != mapOldAccount.get(acc.Id).BillingCity ||
          acc.BillingPostalCode !=
          mapOldAccount.get(acc.Id).BillingPostalCode ||
          acc.BillingState != mapOldAccount.get(acc.Id).BillingState ||
          acc.ShippingStreet != mapOldAccount.get(acc.Id).ShippingStreet ||
          acc.ShippingCity != mapOldAccount.get(acc.Id).ShippingCity ||
          acc.ShippingCountry != mapOldAccount.get(acc.Id).ShippingCountry ||
          acc.ShippingPostalCode !=
          mapOldAccount.get(acc.Id).ShippingPostalCode ||
          acc.ShippingState != mapOldAccount.get(acc.Id).ShippingState ||
          acc.Website != mapOldAccount.get(acc.Id).Website ||
          acc.QuickBooks_Accounts__c !=
          mapOldAccount.get(acc.Id).QuickBooks_Accounts__c ||
          acc.Sales_Terms__c != mapOldAccount.get(acc.Id).Sales_Terms__c ||
          acc.Payment_Method__c !=
          mapOldAccount.get(acc.Id).Payment_Method__c ||
          acc.Tax_Code__c != mapOldAccount.get(acc.Id).Tax_Code__c ||
          acc.Fax != mapOldAccount.get(acc.Id).Fax ||
          acc.Phone != mapOldAccount.get(acc.Id).Phone ||
          acc.QBO_Accounts_Count__c !=
          mapOldAccount.get(acc.Id).QBO_Accounts_Count__c ||
          acc.Sync_Billing_Contact__c !=
          mapOldAccount.get(acc.Id).Sync_Billing_Contact__c ||
          acc.Billing_Contact__c !=
          mapOldAccount.get(acc.Id).Billing_Contact__c ||
          acc.Notes__c != mapOldAccount.get(acc.Id).Notes__c
        ) {
          return true;
        }
      }
    }
    return false;
  }
  public static Boolean restrictQBOInstance(
    List<Account> lstNewAccount,
    Map<Id, Account> mapOldAccount
  ) {
    Boolean error = false;
    if (lstNewAccount != null && mapOldAccount.size() > 0) {
      for (Account acc : lstNewAccount) {
        List<String> lstOldQBAccounts = new List<String>();
        List<String> lstNewQBAccounts = new List<String>();
        if (
          mapOldAccount.containsKey(acc.Id) &&
          mapOldAccount.get(acc.Id).QuickBooks_Accounts__c != null &&
          acc.QuickBooks_Accounts__c != null
        ) {
          lstOldQBAccounts.addAll(
            mapOldAccount.get(acc.Id).QuickBooks_Accounts__c.split(';')
          );
          lstNewQBAccounts.addAll(acc.QuickBooks_Accounts__c.split(';'));
          for (String key : lstOldQBAccounts) {
            if (!lstNewQBAccounts.contains(key)) {
              error = true;
            }
          }
        }
      }
    }
    if (error == true) {
      lstNewAccount.get(0)
        .addError('QB Account Cannot be removed once added ' + error);
    }

    return true;
  }
  //TODO
  public static void handleRecordTypeChange(
    List<Account> newAccounts,
    Map<Id, Account> oldAccounts
  ) {
    for (Account acc : newAccounts) {
      if (acc.RecordTypeId != oldAccounts.get(acc.Id).RecordTypeId) {
        if (acc.QBO_Accounts_Count__c > 0) {
          acc.addError('Record type of synced record cannot be changed.');
        }
      }
    }
  }

  public static void checkAndUpdateStatusOfOutdatedCheckbox(
    List<Account> newValues,
    Map<Id, Account> oldValues
  ) {
    Set<Id> accountsRelatedToOpportunities = new Set<Id>();
    for (Account acc : newValues) {
      Account relatedOldValue = oldValues.get(acc.Id);
      if (
        relatedOldValue.BillingAddress != acc.BillingAddress ||
        relatedOldValue.Billing_Contact__c != acc.Billing_Contact__c
      ) {
        accountsRelatedToOpportunities.add(acc.Id);
      }
    }

    if (
      accountsRelatedToOpportunities != null &&
      accountsRelatedToOpportunities.size() > 0
    ) {
      List<Opportunity> opportunitiesList = new List<Opportunity>(
        [
          SELECT Id, isOutdated__c
          FROM Opportunity
          WHERE AccountId IN :accountsRelatedToOpportunities
        ]
      );
      for (Opportunity opp : opportunitiesList) {
        opp.isOutdated__c = true;
      }
      update opportunitiesList;
    }
  }
  public static void handleWebiste(List<Account> newAccounts) {
    for (Account acc : newAccounts) {
      try {
        if (acc.Website != null) {
          String website = acc.Website.toLowerCase();
          if (
            !(website.startsWith('http://') || website.startsWith('https://'))
          ) {
            acc.Website = 'https://' + acc.Website;
          }
        }
      } catch (System.StringException e) {
        acc.addError('Please Add Valid Website');
        System.debug(e.getMessage());
      }
    }
  }

  public static void syncToQBO(
    List<Account> newAccounts,
    Map<Id, Account> mapOldAccounts,
    String triggerType
  ) {
    System.debug('triggerType: ' + triggerType);
    List<Id> convertedLeadIds = new List<Id>();
    Set<Id> accountIds = new Set<Id>();
    for (Account acc : newAccounts) {
      convertedLeadIds.add(acc.Lead_Id__c);
      accountIds.add(acc.Id);
    }
    Schema.sObjectField quickbooksAvailableAccounts = Account.QuickBooks_Accounts__c.getDescribe()
      .getSObjectField();
    List<PicklistEntry> picklistValues = quickbooksAvailableAccounts.getDescribe()
      .getPicklistValues();
    Map<String, Set<Id>> mapQBInstanceAccountId = new Map<String, Set<Id>>();
    Map<String, Set<Id>> mapQBInstanceVendorAccountId = new Map<String, Set<Id>>();
    Map<Id, Lead> convertedLeadMap = new Map<Id, Lead>(
      [SELECT RecordtypeId FROM Lead WHERE Id = :convertedLeadIds]
    );
    try {
      for (Account acc : newAccounts) {
        Boolean isSyncCustomer = false;
        Boolean isSyncVendor = false;
        if (
          Trigger.isInsert &&
          convertedLeadMap.containsKey(acc.Lead_Id__c) //If Account is created upon Lead Conversion
        ) {
          Lead convertedLead = convertedLeadMap.get(acc.Lead_Id__c);
          if (
            convertedLead.RecordTypeId ==
            Schema.SObjectType.Lead.getRecordTypeInfosByName()
              .get('Customer Lead')
              .getRecordTypeId()
          ) {
            isSyncCustomer = true;
          } else if (
            convertedLead.RecordTypeId ==
            Schema.SObjectType.Lead.getRecordTypeInfosByName()
              .get('Vendor Lead')
              .getRecordTypeId()
          ) {
            isSyncVendor = true;
          } else if (
            convertedLead.RecordTypeId ==
            Schema.SObjectType.Lead.getRecordTypeInfosByName()
              .get('PFA Customer Lead')
              .getRecordTypeId()
          ) {
            isSyncCustomer = true;
          }
        } else {
          if (
            acc.RecordTypeId ==
            Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Customer Account')
              .getRecordTypeId()
          ) {
            system.debug('Customer account got synced.');
            isSyncCustomer = true;
          } else if (
            acc.RecordTypeId ==
            Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('Vendor Account')
              .getRecordTypeId()
          ) {
            system.debug('Vendor account got synced.');
            isSyncVendor = true;
          } else if (
            acc.RecordTypeId ==
            Schema.SObjectType.Account.getRecordTypeInfosByName()
              .get('PFA Customer Account')
              .getRecordTypeId()
          ) {
            system.debug('PFA customer account got synced.');
            isSyncCustomer = true;
          }
        }
        List<String> lstQBAccounts = new List<String>();
        lstQBAccounts.addAll(acc.QuickBooks_Accounts__c.split(';'));
        if (isSyncCustomer) {
          for (String key : lstQBAccounts) {
            if (mapQBInstanceAccountId.containsKey(key)) {
              mapQBInstanceAccountId.get(key).add(acc.Id);
            } else {
              mapQBInstanceAccountId.put(key, new Set<Id>());
              mapQBInstanceAccountId.get(key).add(acc.Id);
            }
          }
        } else if (isSyncVendor) {
          for (String key : lstQBAccounts) {
            if (mapQBInstanceVendorAccountId.containsKey(key)) {
              mapQBInstanceVendorAccountId.get(key).add(acc.Id);
            } else {
              mapQBInstanceVendorAccountId.put(key, new Set<Id>());
              mapQBInstanceVendorAccountId.get(key).add(acc.Id);
            }
          }
          system.debug(
            'Vendor details in insert: ' + mapQBInstanceVendorAccountId
          );
        }
      }

      if (!System.isFuture() && firstRun) {
        firstRun = false;
        if (mapQBInstanceAccountId.size() > 0 && !system.isBatch()) {
          // There will be no opportunities related to vendor accounts so we have put Queueable with Customer Accounts only
          Integer testCount = 0;
          for (String key : mapQBInstanceAccountId.keySet()) {
            Map<String, Set<Id>> mapQBInstanceAccountIdUpdated = new Map<String, Set<Id>>();
            mapQBInstanceAccountIdUpdated.put(
              key,
              mapQBInstanceAccountId.get(key)
            );
            if (!Test.isRunningTest()) {
              QueueableWrapper.enqueue(
                new QuickbookAPIHelper(mapQBInstanceAccountIdUpdated)
              );
            }
          }
        }
        system.debug(mapQBInstanceVendorAccountId.size());
        if (mapQBInstanceVendorAccountId.size() > 0) {
          Set<Id> accIds = new Set<Id>();
          String accountTitle = '';
          for (String key : mapQBInstanceVendorAccountId.keySet()) {
            //QuickbookApiCrud.syncVendor(mapQBInstanceVendorAccountId.get(key),key);
            //System.enqueueJob(new QuickbookApiCrud(mapQBInstanceVendorAccountId.get(key),key));
            accIds = mapQBInstanceVendorAccountId.get(key);
            accountTitle = key;
          }
          System.enqueueJob(new QuickbookApiCrud(accIds, accountTitle));
        }
      }
      /*
            system.debug(mapQBInstanceVendorAccountId.size());
            if(mapQBInstanceVendorAccountId.size()>0){ 
                for(String key:mapQBInstanceVendorAccountId.keySet()){
                    //QuickbookApiCrud.syncVendor(mapQBInstanceVendorAccountId.get(key),key);
                    System.enqueueJob(new QuickbookApiCrud(mapQBInstanceVendorAccountId.get(key),key));
                }
            }
			*/
    } catch (Exception ex) {
      if (
        ex.getMessage().contains('entity with same name already exists in QBO')
      ) {
        newAccounts[0]
          .addError(
            'Another entity with same name already exists in QBO. Kindly update account name and try again'
          );
      }
    }
  }

  public static void updateWorkOrderOwnerCheckbox(
    List<Account> newAccounts,
    Map<Id, Account> oldAccounts
  ) {
    Set<Id> acccountIds = new Set<Id>();
    for (Account acct : newAccounts) {
      if (acct.OwnerId != oldAccounts.get(acct.Id).OwnerId) {
        acccountIds.add(acct.Id);
      }
    }
    List<Order> workorders = [
      SELECT Id, Account_Owner_Changed__c
      FROM Order
      WHERE AccountId IN :acccountIds
    ];
    for (Order ord : workorders) {
      ord.Account_Owner_Changed__c = true;
    }
    update workorders;
  }

  /*
*********************************************************
@Method Name    : updateShippingInfo 
@author         : Hina Hashim
@description    : called from Trigger.Replacement of process builder "Account Processes" calling in this function
@param          : List<Account>
@return         : void
********************************************************
*/

  public static void updateShippingInfo(
    List<Account> newTrigger,
    Map<Id, Account> oldTriggerMap,
    Map<Id, Account> newTriggerMap
  ) {
    List<Id> accsToUpdateIds = new List<Id>();
    UpdateShippingAddressFields(newTrigger, oldTriggerMap);
    for (Account acc : newTrigger) {
      if (oldTriggerMap != null) {
        if (
          acc.ShippingStreet != oldTriggerMap.get(acc.Id).ShippingStreet ||
          acc.ShippingCity != oldTriggerMap.get(acc.Id).ShippingCity ||
          acc.ShippingState != oldTriggerMap.get(acc.Id).ShippingState ||
          acc.ShippingPostalCode !=
          oldTriggerMap.get(acc.Id).ShippingPostalCode ||
          acc.ShippingCountry != oldTriggerMap.get(acc.Id).ShippingCountry
        ) {
          accsToUpdateIds.add(acc.Id);
        }
      } else {
        accsToUpdateIds.add(acc.Id);
      }
    }
    List<Shipping__c> shippingRecsForDecorator = [
      SELECT Id, Ship_To__c, Decorator__c, Decorator_Shipping_Address__c
      FROM Shipping__c
      WHERE Decorator__c IN :accsToUpdateIds
    ];
    List<Shipping__c> shippingRecsForSupplier = [
      SELECT Id, Ship_To__c, Supplier__c, Other_Supplier_Address__c
      FROM Shipping__c
      WHERE Supplier__c IN :accsToUpdateIds
    ];
    for (Shipping__c shipping : shippingRecsForDecorator) {
      if (shipping.Decorator__c != null) {
        Account acc = newTriggerMap.get(shipping.Decorator__c);
        //replacement of process builder Account Processes
        String address = '';
        if (acc.ShippingStreet != null)
          address = acc.ShippingStreet;
        if (acc.ShippingCity != null)
          address = address + ' ' + acc.ShippingCity;
        if (acc.ShippingState != null)
          address = address + ',' + acc.ShippingState;
        if (acc.ShippingPostalCode != null)
          address = address + ' ' + acc.ShippingPostalCode;
        if (acc.ShippingCountry != null)
          address = address + ' ' + acc.ShippingCountry;
        shipping.Decorator_Shipping_Address__c = address;
      }
    }

    for (Shipping__c shippingSupplier : shippingRecsForSupplier) {
      if (shippingSupplier.Supplier__c != null) {
        Account acc = newTriggerMap.get(shippingSupplier.Supplier__c);
        //replacement of process builder Account Processes
        String address = '';
        if (acc.ShippingStreet != null)
          address = acc.ShippingStreet;
        if (acc.ShippingCity != null)
          address = address + ' ' + acc.ShippingCity;
        if (acc.ShippingState != null)
          address = address + ',' + acc.ShippingState;
        if (acc.ShippingPostalCode != null)
          address = address + ' ' + acc.ShippingPostalCode;
        if (acc.ShippingCountry != null)
          address = address + ' ' + acc.ShippingCountry;
        shippingSupplier.Other_Supplier_Address__c = address;
      }
    }

    update shippingRecsForSupplier;
    update shippingRecsForDecorator;
  }

  /*
*********************************************************
@Method Name    : UpdateShippingAddressFields 
@author         : Hina Hashim
@description    : called from Trigger.Replacement of process builder "Account Processes" function body
@param          : List<Account>
@return         : void
********************************************************
*/

  public static void UpdateShippingAddressFields(
    List<Account> newAccounts,
    Map<Id, Account> oldAccounts
  ) {
    List<Account> acct = new List<Account>();
    for (Account acc : newAccounts) {
      if (acc.copy_to_shipping_Address__c == true) {
        acct.add(acc);
      }
    }
    for (Account acc2 : acct) {
      acc2.ShippingCity = acc2.BillingCity;
      acc2.ShippingCountry = acc2.BillingCountry;
      acc2.ShippingPostalCode = acc2.BillingPostalCode;
      acc2.ShippingState = acc2.BillingState;
      acc2.ShippingStreet = acc2.BillingStreet;
    }
  }

  /*
*********************************************************
@Method Name    : SetArtApprovalEmailBilling 
@author         : !Hina Hashim  !!Sohiab Saqib
@description    : called from Trigger. Replacement of process builder "Set Art Approval Email/Billing Contact - Account"
@param          : List<Account>
@return         : void
********************************************************
*/

  public static void SetArtApprovalEmailBilling(
    List<Account> newAccounts,
    Map<Id, Account> oldAccounts
  ) {
    Set<Id> accountIdsToUpdate = new Set<Id>();
    Map<Id, Account> newAccountsMap = new Map<Id, Account>(newAccounts);

    for (Account newAccount : newAccounts) {
      Account oldAccount = oldAccounts.get(newAccount.Id);
      if (
        newAccount.Billing_Contact__c != oldAccount.Billing_Contact__c ||
        newAccount.Art_Approval_Email__c != oldAccount.Art_Approval_Email__c
      ) {
        accountIdsToUpdate.add(newAccount.Id);
      }
    }

    if (!accountIdsToUpdate.isEmpty()) {
      List<Order> ordersToUpdate = [
        SELECT Id, AccountId, Art_Approval_Email__c, Billing_Contact__c
        FROM Order
        WHERE AccountId IN :accountIdsToUpdate
      ];

      for (Order order : ordersToUpdate) {
        Account relatedAccount = newAccountsMap.get(order.AccountId);
        order.Art_Approval_Email__c = relatedAccount.Art_Approval_Email__c;
        order.Billing_Contact__c = relatedAccount.Billing_Contact__c;
      }
      if (!ordersToUpdate.isEmpty()) {
        update ordersToUpdate;
      }
    }
  }

  public static void handleRecordType(List<Account> newTrigger) {
    Id pfaRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('PFA Customer Account')
      .getRecordTypeId();
    Id pfaRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('PFA Customer Lead')
      .getRecordTypeId();
    Id VendorRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Vendor Account')
      .getRecordTypeId();
    Id VendorRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Vendor Lead')
      .getRecordTypeId();
    Id CustomerRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Customer Account')
      .getRecordTypeId();
    Id CustomerRecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Customer Lead')
      .getRecordTypeId();
    Id BATypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName()
      .get('Brand Ambassador Staffing Account')
      .getRecordTypeId();
    Id BARecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('Brand Ambassador Lead')
      .getRecordTypeId();

    for (Account acc : newTrigger) {
      if (acc.Lead_Record_Id__c != null) {
        if (acc.Lead_Record_Id__c == pfaRecordTypeIdLead) {
          acc.RecordTypeId = pfaRecordTypeIdAccount;
        } else if (acc.Lead_Record_Id__c == VendorRecordTypeIdLead) {
          acc.RecordTypeId = VendorRecordTypeIdAccount;
        } else if (acc.Lead_Record_Id__c == CustomerRecordTypeIdLead) {
          acc.RecordTypeId = CustomerRecordTypeIdAccount;
        } else if (acc.Lead_Record_Id__c == BARecordTypeIdLead) {
          acc.RecordTypeId = BATypeIdAccount;
        }
      }
    }
  }
}
