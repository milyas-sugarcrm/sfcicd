@RestResource(urlMapping='/NewCampaignFormAPI/*')
global class NewCampaignFormAPI {
  @HttpPost
  global static void doPost() {
    try {
      RestRequest req = RestContext.request;
      Blob body = req.requestBody;
      String requestString = body.toString();
      JSON2ApexNewCampaignForm parsedData = (JSON2ApexNewCampaignForm) JSON.deserialize(
        requestString,
        JSON2ApexNewCampaignForm.class
      );
      String validationErrorCode = validateFields(parsedData);
      if (validationErrorCode != '200') {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(validationErrorCode);
        return;
      }
      Account acc = getAccount(parsedData.email);
      if (acc != null) {
        Opportunity opp = createOpportunity(acc, parsedData);
        sendEmail(opp);
        RestContext.response.statusCode = 201;
        RestContext.response.responseBody = Blob.valueOf('201');
        return;
      } else {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf('4002');
        return;
      }
    } catch (DmlException e) {
      System.debug('exception in doPost() of NewCampaignFormAPI: ' + e);
      RestContext.response.statusCode = 500;
      RestContext.response.responseBody = Blob.valueOf(
        'Problem in submitting form. Ask technical support please.'
      );
      return;
    }
  }

  private static String validateFields(JSON2ApexNewCampaignForm parsedData) {
    String EMAIL_REGEX = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    String PHONE_REGEX = '^[^a-zA-Z]*$';
    String DATE_REGEX = '^(\\d{4})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$';
    List<String> errorCodes = new List<String>();

    // Validate Email using a simple regex pattern
    if (
      String.isBlank(parsedData.email) ||
      !Pattern.matches(EMAIL_REGEX, parsedData.email)
    ) {
      errorCodes.add('4003');
    }
    // Validate Organization Name
    if (String.isBlank(parsedData.organizationName)) {
      errorCodes.add('4004');
    }
    // Validate Organization Address
    if (String.isBlank(parsedData.organizationAddress)) {
      errorCodes.add('4005');
    }
    // Validate signorName
    if (String.isBlank(parsedData.signorName)) {
      errorCodes.add('4006');
    }
    // Validate signorTitle
    if (String.isBlank(parsedData.signorTitle)) {
      errorCodes.add('4007');
    }
    // Validate signorEmail using a simple regex pattern
    if (
      !String.isBlank(parsedData.signorEmail) &&
      !Pattern.matches(EMAIL_REGEX, parsedData.signorEmail)
    ) {
      errorCodes.add('4008');
    }
    // Validate legalCompanyName
    if (String.isBlank(parsedData.legalCompanyName)) {
      errorCodes.add('4009');
    }
    // Validate legalBillingAddress
    if (String.isBlank(parsedData.legalBillingAddress)) {
      errorCodes.add('4010');
    }
    // Validate billingContactName
    if (String.isBlank(parsedData.billingContactName)) {
      errorCodes.add('4011');
    }
    // Validate billingContactEmail using a simple regex pattern
    if (
      !String.isBlank(parsedData.billingContactEmail) &&
      !Pattern.matches(EMAIL_REGEX, parsedData.billingContactEmail)
    ) {
      errorCodes.add('4012');
    }
    // Validate billingContactPhone using a regex pattern for a common phone number format
    if (
      !String.isBlank(parsedData.billingContactPhone) &&
      !Pattern.matches(PHONE_REGEX, parsedData.billingContactPhone)
    ) {
      errorCodes.add('4013');
    }
    // Validate Payment Method
    if (
      parsedData.paymentMethod != null && !parsedData.paymentMethod.isEmpty()
    ) {
      Set<String> validPaymentMethods = new Set<String>();
      List<Schema.PicklistEntry> picklistEntries = Opportunity.Preferred_Payment_Method_PFA__c.getDescribe()
        .getPicklistValues();
      for (Schema.PicklistEntry entry : picklistEntries) {
        validPaymentMethods.add(entry.getValue());
      }
      for (String method : parsedData.paymentMethod) {
        if (!validPaymentMethods.contains(method)) {
          errorCodes.add('4014');
        }
      }
    } else {
      errorCodes.add('4015');
    }
    // Validate productsOrBrands
    if (String.isBlank(parsedData.productsOrBrands)) {
      errorCodes.add('4016');
    }
    // Validate eventLocations
    if (String.isBlank(parsedData.eventLocations)) {
      errorCodes.add('4017');
    }
    // Validate campaignPOC
    if (String.isBlank(parsedData.campaignPOC)) {
      errorCodes.add('4018');
    }
    // Validate campaignPOCEmail using a simple regex pattern
    if (
      !String.isBlank(parsedData.campaignPOCEmail) &&
      !Pattern.matches(EMAIL_REGEX, parsedData.campaignPOCEmail)
    ) {
      errorCodes.add('4019');
    }
    // campaignStartDate
    if (
      String.isBlank(parsedData.campaignStartDate) ||
      !Pattern.matches(DATE_REGEX, parsedData.campaignStartDate)
    ) {
      errorCodes.add('4020');
    }
    //campaignEndDate
    if (
      String.isBlank(parsedData.campaignEndDate) ||
      !Pattern.matches(DATE_REGEX, parsedData.campaignEndDate)
    ) {
      errorCodes.add('4021');
    }
    // Validate productDescription
    if (String.isBlank(parsedData.productDescription)) {
      errorCodes.add('4022');
    }
    // Validate schedulingResponsible
    if (String.isBlank(parsedData.schedulingResponsible)) {
      errorCodes.add('4023');
    }
    // Validate baAttireRequest
    if (String.isBlank(parsedData.baAttireRequest)) {
      errorCodes.add('4024');
    }
    // Validate needPOS
    if (String.isBlank(parsedData.needPOS)) {
      errorCodes.add('4025');
    }
    // Validate materialSummary
    if (String.isBlank(parsedData.materialSummary)) {
      errorCodes.add('4026');
    }

    if (errorCodes.size() > 0) {
      return errorCodes[0];
    }
    return '200';
  }

  // get account object on the basis of email
  private static Account getAccount(String email) {
    List<Contact> contacts = [
      SELECT Id, AccountId
      FROM Contact
      WHERE Email = :email
      LIMIT 1
    ];
    List<Account> associatedAccounts = new List<Account>();
    if (!contacts.isEmpty()) {
      Id accountId = contacts[0].AccountId;
      if (accountId != null) {
        associatedAccounts = [
          SELECT Id, Name
          FROM Account
          WHERE Id = :accountId
          LIMIT 1
        ];
      }
    }
    if (!associatedAccounts.isEmpty()) {
      return associatedAccounts[0];
    } else {
      return null;
    }
  }

  // create opportunity after setting fields
  private static Opportunity createOpportunity(
    Account acc,
    JSON2ApexNewCampaignForm parsedData
  ) {
    Opportunity oppToInsert = new Opportunity();
    oppToInsert.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get(Constants.PFA_CUSTOMER_OPPORTUNITY)
      .getRecordTypeId();

    // mapping
    oppToInsert.AccountId = acc.Id;
    oppToInsert.Name = parsedData.organizationName;
    oppToInsert.StageName = 'Needs Analysis';
    oppToInsert.Organization_Name_PFA__c = parsedData.organizationName;
    oppToInsert.Organization_Address_PFA__c = parsedData.organizationAddress;
    oppToInsert.Signor_Name_PFA__c = parsedData.signorName;
    oppToInsert.Signor_Title_PFA__c = parsedData.signorTitle;
    oppToInsert.Signor_Email_PFA__c = parsedData.signorEmail;
    oppToInsert.Legal_Company_Name_PFA__c = parsedData.legalCompanyName;
    oppToInsert.Legal_Billing_Address_PFA__c = parsedData.legalBillingAddress;
    oppToInsert.Billing_Contact_Name_PFA__c = parsedData.billingContactName;
    oppToInsert.Billing_Contact_Email_PFA__c = parsedData.billingContactEmail;
    oppToInsert.Billing_Contact_Phone_PFA__c = parsedData.billingContactPhone;
    oppToInsert.Preferred_Payment_Method_PFA__c = String.join(
      parsedData.paymentMethod,
      ';'
    );
    oppToInsert.Promoted_Sampled_Products_Brands__c = parsedData.productsOrBrands;
    oppToInsert.Scheduling_Events_Account_Venue_s__c = parsedData.eventLocations;
    oppToInsert.Campaign_POC__c = parsedData.campaignPOC;
    oppToInsert.Campaign_POC_Email__c = parsedData.campaignPOCEmail;
    oppToInsert.Campaign_Start_Date__c = Date.valueOf(
      parsedData.campaignStartDate
    );
    oppToInsert.Campaign_End_Date__c = Date.valueOf(parsedData.campaignEndDate);
    oppToInsert.CloseDate = oppToInsert.Campaign_Start_Date__c.addDays(-14);
    oppToInsert.Product_Description__c = parsedData.productDescription;
    oppToInsert.Responsible_for_Scheduling__c = parsedData.schedulingResponsible;
    oppToInsert.BA_Attire__c = parsedData.baAttireRequest;
    oppToInsert.Do_you_need_POS__c = parsedData.needPOS;
    oppToInsert.Summary_of_Materials__c = parsedData.materialSummary;

    insert oppToInsert;
    return oppToInsert;
  }

  public static void sendEmail(Opportunity opp) {
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'OpportunityCreatedNewCampaignForm'
      LIMIT 1
    ];
    try {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;
      if (opp != null) {
        if (opp.Name != null) {
          htmlBody = htmlBody.replace('{!Name}', opp.Name);
        }
        if (opp.Organization_Name_PFA__c != null) {
          htmlBody = htmlBody.replace(
            '{!OrganizationName}',
            opp.Organization_Name_PFA__c
          );
        }
        if (opp.Billing_Contact_Phone_PFA__c != null) {
          htmlBody = htmlBody.replace(
            '{!BillingEmail}',
            opp.Billing_Contact_Email_PFA__c
          );
        }
        if (opp.Billing_Contact_Phone_PFA__c != null) {
          htmlBody = htmlBody.replace(
            '{!BillingPhone}',
            opp.Billing_Contact_Phone_PFA__c
          );
        }
        if (opp.Id != null) {
          htmlBody = htmlBody.replace(
            '{!URL}',
            CommonUtilitiesPfa.getRecordLink(opp.Id)
          );
        }
      }
      email.setSubject(et.Subject);
      email.setHtmlBody(htmlBody);

      // get email address from metadata
      Organization orgInfo = [
        SELECT Id, InstanceName, IsSandbox, Name, OrganizationType
        FROM Organization
      ];
      String recordName = (orgInfo.IsSandbox == true)
        ? 'Sandbox'
        : 'Production';
      Email_Address__mdt emailConfig = [
        SELECT New_Campaign_Form_Email__c
        FROM Email_Address__mdt
        WHERE DeveloperName = :recordName
        LIMIT 1
      ];
      if (emailConfig != null) {
        String emailAddress = emailConfig.New_Campaign_Form_Email__c;
        List<String> toAddress = new List<String>{ emailAddress };
        email.setToAddresses(toAddress);
        email.setTemplateId(et.Id);
        email.setSaveAsActivity(false);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
      }
    } catch (Exception e) {
      System.debug(
        'Exception upon sending email: ' +
          e.getMessage() +
          '\n' +
          e.getStackTraceString()
      );
    }
  }
}
