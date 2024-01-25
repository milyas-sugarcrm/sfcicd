public class LeadTriggerHandlerforPFA {
  public static void sendEmailAndBellNotification(
    List<Lead> leadList,
    Map<Id, Lead> leadOldMap
  ) {
    String SLA_DOCUMENT = 'SLA Document';
    String COMPLETED = 'Completed';
    String currentUserEmail = UserInfo.getUserEmail();
    Id pfaCustomerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
      .getRecordTypeId();

    List<Lead> leadsWithSubmittedClientForm = new List<Lead>();
    List<Messaging.SingleEmailMessage> emailNotificationsToSend = new List<Messaging.SingleEmailMessage>();

    for (Lead newLead : leadList) {
      if (
        newLead.New_Client_Form_Status__c == COMPLETED &&
        leadOldMap.get(newLead.id).New_Client_Form_Status__c != COMPLETED &&
        newLead.RecordTypeId == pfaCustomerLeadRecordTypeId
      ) {
        leadsWithSubmittedClientForm.add(newLead);
      }
    }

    if (!leadsWithSubmittedClientForm.isEmpty()) {
      CustomNotificationType notificationType = [
        SELECT Id
        FROM CustomNotificationType
        WHERE DeveloperName = 'Client_Form_Submitted_Notification'
      ];
      for (Lead lead : leadsWithSubmittedClientForm) {
        //changing lead status
        lead.Status = SLA_DOCUMENT;

        //pushing bell notification in SF
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('New Client Form Submitted');
        notification.setBody(
          'New Client Form Submitted and related data is also updated in lead record fields'
        );
        notification.setNotificationTypeId(notificationType.id);
        notification.setTargetId(lead.Id);
        notification.send(new Set<String>{ Userinfo.getUserId() });

        //sending email notification
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new List<String>{ currentUserEmail };
        email.setToAddresses(toAddresses);
        email.setSubject('New Client Form Submitted');
        email.setPlainTextBody(
          'New Client Form Submitted and related data is also updated in lead record fields'
        );
        emailNotificationsToSend.add(email);
      }
      Messaging.sendEmail(emailNotificationsToSend);
    }
  }

  // Setting status of lead to New for specific lead record types as it change by some other flow or trigger
  public static void setStatusOnInsert(
    List<Lead> leadList,
    Map<Id, Lead> leadOldMap
  ) {
    Id pfaCustomerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
      .getRecordTypeId();
    Id vendorLeadTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get(Constants.VENDOR_LEAD_LABEL)
      .getRecordTypeId();
    for (Lead newLead : leadList) {
      if (
        newLead.Status == Constants.RERIEVE_ACCOUNT_INFO_STATUS &&
        (newLead.RecordTypeId == pfaCustomerLeadRecordTypeId ||
        newLead.RecordTypeId == vendorLeadTypeId)
      ) {
        newLead.Status = Constants.NEW_STATUS;
      }
    }
  }

  // Set the Recrod Type of Lead coming from "Phun For All Contact Us Form" as "PFA Customer Lead
  public static void setLeadRecordType(List<Lead> leadList) {
    Id pfaCustomerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get(Constants.PFA_CUSTOMER_LEAD_LABEL)
      .getRecordTypeId();
    for (Lead newLead : leadList) {
      if (
        newLead.Webform_URL__c == 'Phun_for_all' &&
        newLead.LeadSource == 'Webform'
      ) {
        newLead.RecordTypeId = pfaCustomerLeadRecordTypeId;
      }
    }
  }

  public static void convertLeadOnStatusCompleted(
    List<Lead> leadList,
    Map<Id, Lead> leadOldMap
  ) {
    final String COMPLETED = 'Completed';
    final String PHUN_FOR_ALL = 'Phun for All';
    final String QUALIFIED_STATUS = 'Qualified';
    Id pfaCustomerLeadRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName()
      .get('PFA Customer Lead')
      .getRecordTypeId();

    Set<Id> leadIdsToUpdate = new Set<Id>();
    Set<String> leadNames = new Set<String>();
    Set<String> leadCompanyNames = new Set<String>();
    Set<String> leadEmails = new Set<String>();

    for (Lead leadRec : leadList) {
      if (
        leadRec.IsSLADocumentCompleted__c == true &&
        leadOldMap.get(leadRec.Id).IsSLADocumentCompleted__c == false &&
        leadRec.RecordTypeId == pfaCustomerLeadRecordTypeId
      ) {
        leadIdsToUpdate.add(leadRec.Id);
      }
    }

    List<Lead> leadsToUpdate = [
      SELECT Id, Name, Email, Company, QuickBooks_Accounts__c, RecordTypeId
      FROM Lead
      WHERE Id IN :leadIdsToUpdate
    ];
    // Collect the Lead names and emails for queries outside the loop
    for (Lead leadRecord : leadsToUpdate) {
      if (
        leadRecord.QuickBooks_Accounts__c == null &&
        leadRecord.RecordTypeId == pfaCustomerLeadRecordTypeId
      ) {
        leadRecord.QuickBooks_Accounts__c = PHUN_FOR_ALL;
      }
      leadNames.add(leadRecord.Name.toLowerCase());
      leadCompanyNames.add(leadRecord.Company.toLowerCase());
      leadEmails.add(leadRecord.Email.toLowerCase());
    }

    List<Database.LeadConvert> leadConverts = new List<Database.LeadConvert>();
    Map<String, Id> accountNameToIdMap = new Map<String, Id>();
    Map<String, Id> contactKeyToIdMap = new Map<String, Id>();
    Map<Id, Id> contactToAccountIdMap = new Map<Id, Id>(); // New map to store Contact Id to Account Id mapping

    // Query Accounts based on Lead Company Name
    for (Account existingAccount : [
      SELECT Id, Name
      FROM Account
      WHERE Name IN :leadCompanyNames
      LIMIT 1
    ]) {
      accountNameToIdMap.put(
        existingAccount.Name.toLowerCase(),
        existingAccount.Id
      );
    }

    // Query Contacts based on Lead Name and Email
    for (Contact existingContact : [
      SELECT Id, Name, Email, AccountId
      FROM Contact
      WHERE Name IN :leadNames AND Email IN :leadEmails
      LIMIT 1
    ]) {
      contactKeyToIdMap.put(
        (existingContact.Name + existingContact.Email).toLowerCase(),
        existingContact.Id
      );
      contactToAccountIdMap.put(existingContact.Id, existingContact.AccountId);
    }

    for (Lead leadRecord : leadsToUpdate) {
      // Use the collected data to set Account and Contact IDs in the LeadConvert object
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(leadRecord.Id);
      lc.setConvertedStatus(QUALIFIED_STATUS);

      if (leadRecord.Company != null) {
        // Set Account ID if an Account with the same name exists
        String lowerCaseCompanyName = leadRecord.Company.toLowerCase();
        Id accountId = accountNameToIdMap.get(lowerCaseCompanyName);
        if (accountId != null) {
          lc.setAccountId(accountId);
        }
      }

      if (leadRecord.Name != null && leadRecord.Email != null) {
        // Set Account and Contact IDs if a Contact with the same name and email exists
        String lowerCaseContactKey = (leadRecord.Name.toLowerCase() +
        leadRecord.Email.toLowerCase());
        Id contactId = contactKeyToIdMap.get(lowerCaseContactKey);
        if (contactId != null) {
          lc.setContactId(contactId);
          // Set the Account ID to the Account ID associated with the Contact
          lc.setAccountId(contactToAccountIdMap.get(contactId));
        }
      }
      leadConverts.add(lc);
    }

    // Update the leads
    update leadsToUpdate;

    // Perform Lead conversion
    List<Database.LeadConvertResult> lcrList = Database.convertLead(
      leadConverts
    );
    for (Database.LeadConvertResult lcr : lcrList) {
      if (!lcr.isSuccess()) {
        System.debug('Failed Lead Conversion: ' + lcr.getErrors());
      }
    }
  }
}
