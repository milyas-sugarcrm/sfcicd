public class LeadTriggerService {
  public static void LeadProcess(List<Lead> newLeads, Boolean FromInsert) {
    List<Opportunity> OppsToUpdate = new List<Opportunity>();
    List<Contact> ConsToUpdate = new List<Contact>();
    List<Account> AccountToUpdate = new List<Account>();
    Map<String, Id> userMap = new Map<String, Id>();
    Set<String> seamlessOwners = new Set<String>();
    Set<Id> convertedAccountIds = new Set<Id>();
    Set<Id> convertedOpportunityIds = new Set<Id>();
    Set<Id> convertedContactIds = new Set<Id>();
    Set<Id> LeadIDs = new Set<Id>();
    for (Lead nlead : newLeads) {
      LeadIDs.add(nlead.Id);
      if (nlead.LeadSource == 'Seamless.AI') {
        seamlessOwners.add(nlead.Seamless_Owner_Assignment__c);
      }
      if (nlead.isConverted == true) {
        convertedOpportunityIds.add(nlead.ConvertedOpportunityId);
      }
      if (nlead.isConverted == true) {
        convertedContactIds.add(nlead.ConvertedContactId);
      }
      if (nlead.isConverted == true) {
        convertedAccountIds.add(nlead.ConvertedAccountId);
      }
    }

    if (!seamlessOwners.isEmpty()) {
      List<User> userList = [
        SELECT Id, Username
        FROM User
        WHERE Username IN :seamlessOwners AND IsActive = TRUE
      ];
      for (User user : userList) {
        userMap.put(user.Username, user.Id);
      }
    }
    // Opportunities
    List<Opportunity> convertedOpportunities = [
      SELECT Id, Amount
      FROM Opportunity
      WHERE Id IN :convertedOpportunityIds
    ];
    Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
    for (Opportunity opp : convertedOpportunities) {
      opportunityMap.put(opp.Id, opp);
    }

    // Contacts
    List<Contact> convertedContacts = [
      SELECT Id, Email
      FROM Contact
      WHERE Id IN :convertedContactIds
    ];
    Map<Id, Contact> contactMap = new Map<Id, Contact>();
    for (Contact con : convertedContacts) {
      contactMap.put(con.Id, con);
    }

    List<Account> convertedAccounts = [
      SELECT
        Id,
        RecordType.Id,
        ShippingStreet,
        ShippingCity,
        ShippingCountry,
        ShippingPostalCode,
        ShippingState
      FROM Account
      WHERE Id IN :convertedAccountIds
    ];

    // Map to store Account Id to Account
    Map<Id, Account> accountMap = new Map<Id, Account>();
    for (Account acc : convertedAccounts) {
      accountMap.put(acc.Id, acc);
    }

    List<RecordType> AccountRecordTypeIdsC = [
      SELECT id
      FROM RecordType
      WHERE Name = 'Customer Account'
    ];
    id CustomerAccountId;
    if (AccountRecordTypeIdsC != null) {
      CustomerAccountId = AccountRecordTypeIdsC[0].id;
    }

    List<RecordType> AccountRecordTypeIdsV = [
      SELECT Id, Name
      FROM RecordType
      WHERE Name = 'Vendor Account'
    ];
    id VandorAccountId;
    if (AccountRecordTypeIdsV != null) {
      VandorAccountId = AccountRecordTypeIdsV[0].id;
    }

    List<Group> GroupList = [SELECT Id FROM Group WHERE Name = 'Sales Queue'];
    id GroupSalesQueueId;
    if (GroupList != null) {
      GroupSalesQueueId = GroupList[0].id;
    }
    Map<Id, Lead> recordTypeMap = new Map<Id, Lead>();
    if (!FromInsert) {
      List<Lead> leads = [
        SELECT Id, RecordTypeId, RecordType.Name
        FROM Lead
        WHERE Id IN :LeadIDs
      ];
      for (Lead lead : leads) {
        recordTypeMap.put(lead.Id, lead);
      }
    }
    for (Lead nlead : newLeads) {
      // YAMM Status Set (Negatively)
      if (
        nlead.YAMM_Merge_Status__c == 'UNSUBSCRIBED' ||
        nlead.YAMM_Merge_Status__c == 'BOUNCED'
      ) {
        nlead.Status = 'Unqualified';
      }

      // YAMM Status Set (Positively)
      if (
        nlead.YAMM_Merge_Status__c == 'RESPONDED' ||
        nlead.YAMM_Merge_Status__c == 'EMAIL_OPENED' ||
        nlead.YAMM_Merge_Status__c == 'EMAIL_CLICKED'
      ) {
        nlead.Status = 'Retrieve Account Info';
      }

      // Lead Converted
      if (nlead.isConverted == true) {
        Opportunity convertedOpportunity = opportunityMap.get(
          nlead.ConvertedOpportunityId
        );
        if (nlead.Estimated_Amount__c != null) {
          if (convertedOpportunity != null) {
            convertedOpportunity.Amount = nlead.Estimated_Amount__c;
            OppsToUpdate.add(convertedOpportunity);
          }
        }
      }

      // Lead Converted With Billing Email
      if (nlead.isConverted == true && nlead.Billing_Email__c != null) {
        Contact convertedContact = contactMap.get(nlead.ConvertedContactId);
        convertedContact.Email = nlead.Billing_Email__c;
        ConsToUpdate.add(convertedContact);
      }
      // Lead Converted with Art Approval Email
      if (
        nlead.isConverted == true &&
        nlead.Billing_Email__c == null &&
        nlead.Art_Approval_Email__c != null
      ) {
        if (convertedContactIds.contains(nlead.ConvertedContactId)) {
          Contact convertedContact = contactMap.get(nlead.ConvertedContactId);
          convertedContact.Email = nlead.Art_Approval_Email__c;
          ConsToUpdate.add(convertedContact);
        }
      }

      // Copy to Shipping Address
      if (nlead.Copy_to_Shipping_Address__c == true) {
        nlead.Shipping_City__c = nlead.City;
        nlead.Shipping_Country__c = nlead.Country;
        nlead.Shipping_State__c = nlead.State;
        nlead.Shipping_Street__c = nlead.Street;
        nlead.Shipping_Zip__c = nlead.PostalCode;
      }
      // Lead Convert (Customer)
      if (
        nlead.isConverted == true &&
        recordTypeMap.get(nlead.Id).RecordType.Name == 'Customer Lead'
      ) {
        Account convertedAccount = accountMap.get(nlead.ConvertedAccountId);
        convertedAccount.RecordType.id = CustomerAccountId;
        convertedAccount.ShippingStreet = nlead.Shipping_Street__c;
        convertedAccount.ShippingCity = nlead.Shipping_City__c;
        convertedAccount.ShippingCountry = nlead.Shipping_Country__c;
        convertedAccount.ShippingPostalCode = nlead.Shipping_Zip__c;
        convertedAccount.ShippingState = nlead.Shipping_State__c;
        convertedAccount.Lead_Record_Id__c = Schema.SObjectType.Lead.getRecordTypeInfosByName()
          .get('Customer Lead')
          .getRecordTypeId();
        AccountToUpdate.add(convertedAccount);
      }

      // Lead Convert (Vendor)
      if (
        nlead.isConverted == true &&
        recordTypeMap.get(nlead.Id).RecordType.Name == 'Vendor Lead'
      ) {
        Account convertedAccount = accountMap.get(nlead.ConvertedAccountId);
        convertedAccount.RecordType.id = VandorAccountId;
        convertedAccount.ShippingStreet = nlead.Shipping_Street__c;
        convertedAccount.ShippingCity = nlead.Shipping_City__c;
        convertedAccount.ShippingCountry = nlead.Shipping_Country__c;
        convertedAccount.ShippingPostalCode = nlead.Shipping_Zip__c;
        convertedAccount.ShippingState = nlead.Shipping_State__c;
        convertedAccount.Lead_Record_Id__c = Schema.SObjectType.Lead.getRecordTypeInfosByName()
          .get('Vendor Lead')
          .getRecordTypeId();
        AccountToUpdate.add(convertedAccount);
      }

      // Non Seamless Lead
      if (nlead.LeadSource != 'Seamless.AI') {
        if (nlead.Rating == null) {
          nlead.Rating = 'Warm';
        }
      }

      // Seamless Lead
      if (nlead.LeadSource == 'Seamless.AI') {
        if (userMap.containsKey(nlead.Seamless_Owner_Assignment__c)) {
          nlead.OwnerId = userMap.get(nlead.Seamless_Owner_Assignment__c);
        } else {
          // Handle the case where no matching User record is found
          nlead.OwnerId = GroupSalesQueueId;
        }
        if (nlead.Rating == null) {
          nlead.Rating = 'Cold';
        }
      }
    }

    if (!AccountToUpdate.isEmpty()) {
      update AccountToUpdate;
    }
    if (!OppsToUpdate.isEmpty()) {
      update OppsToUpdate;
    }
    if (!ConsToUpdate.isEmpty()) {
      update ConsToUpdate;
    }
  }
}
