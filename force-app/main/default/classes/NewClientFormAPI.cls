@RestResource(urlMapping='/NewClientFormAPI/*')
global class NewClientFormAPI {
  @HttpPost
  global static void doPost() {
    try {
      RestRequest req = RestContext.request;
      Blob body = req.requestBody;
      String requestString = body.toString();
      JSON2ApexNewClientForm parsedData = (JSON2ApexNewClientForm) JSON.deserialize(
        requestString,
        JSON2ApexNewClientForm.class
      );
      String validationErrorCode = validateFields(parsedData);
      if (validationErrorCode != '200') {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf(validationErrorCode);
        return;
      }
      Lead lead = getUpdatedLead(parsedData);
      if (lead != null) {
        update lead;
        sendEmail(lead);
        RestContext.response.statusCode = 201;
        RestContext.response.responseBody = Blob.valueOf('201');
        return;
      } else {
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = Blob.valueOf('4002');
        return;
      }
    } catch (DmlException e) {
      System.debug('Error updating Lead: ' + e);
      RestContext.response.statusCode = 500;
      RestContext.response.responseBody = Blob.valueOf(
        'Problem in submitting form. Ask technical support please.'
      );
      return;
    }
  }

  private static String validateFields(JSON2ApexNewClientForm parsedData) {
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
      List<Schema.PicklistEntry> picklistEntries = Lead.Preferred_Payment_Method_PFA__c.getDescribe()
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

  // Function to create or update a Lead based on the parsed data
  private static Lead getUpdatedLead(JSON2ApexNewClientForm parsedData) {
    Lead leadToUpdate;
    List<Lead> existingLeadList = [
      SELECT
        Id,
        Email,
        FirstName,
        LastName,
        Status,
        Company,
        Phone,
        Organization_Address_PFA__c,
        Signor_Name_PFA__c,
        Signor_Title_PFA__c,
        Signor_Email_PFA__c,
        Legal_Company_Name_PFA__c,
        Legal_Billing_Address_PFA__c,
        Billing_Contact_Name_PFA__c,
        Billing_Contact_Email_PFA__c,
        Billing_Contact_Phone_PFA__c,
        Preferred_Payment_Method_PFA__c,
        Promoted_Sampled_Products_Brands__c,
        Scheduling_Events_Account_Venue_s__c,
        Campaign_POC__c,
        Campaign_POC_Email__c,
        Campaign_Start_Date__c,
        Campaign_End_Date__c,
        Product_Description__c,
        Responsible_for_Scheduling__c,
        BA_Attire__c,
        Do_you_need_POS__c,
        Summary_of_Materials__c
      FROM Lead
      WHERE Email = :parsedData.email
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    if (existingLeadList.size() > 0) {
      leadToUpdate = existingLeadList[0];
    } else {
      return null;
    }

    // mapping
    leadToUpdate.Status = 'SLA Document';

    if (parsedData.email != null && parsedData.email != '') {
      leadToUpdate.Email = parsedData.email;
    }
    if (
      parsedData.organizationName != null &&
      parsedData.organizationName != ''
    ) {
      leadToUpdate.Company = parsedData.organizationName;
      leadToUpdate.Organization_Name_PFA__c = parsedData.organizationName;
    }
    if (
      parsedData.organizationAddress != null &&
      parsedData.organizationAddress != ''
    ) {
      leadToUpdate.Organization_Address_PFA__c = parsedData.organizationAddress;
    }
    if (parsedData.signorName != null && parsedData.signorName != '') {
      leadToUpdate.Signor_Name_PFA__c = parsedData.signorName;
    }
    if (parsedData.signorTitle != null && parsedData.signorTitle != '') {
      leadToUpdate.Signor_Title_PFA__c = parsedData.signorTitle;
    }
    if (parsedData.signorEmail != null && parsedData.signorEmail != '') {
      leadToUpdate.Signor_Email_PFA__c = parsedData.signorEmail;
    }
    if (
      parsedData.legalCompanyName != null &&
      parsedData.legalCompanyName != ''
    ) {
      leadToUpdate.Legal_Company_Name_PFA__c = parsedData.legalCompanyName;
    }
    if (
      parsedData.legalBillingAddress != null &&
      parsedData.legalBillingAddress != ''
    ) {
      leadToUpdate.Legal_Billing_Address_PFA__c = parsedData.legalBillingAddress;
    }
    if (
      parsedData.billingContactName != null &&
      parsedData.billingContactName != ''
    ) {
      leadToUpdate.Billing_Contact_Name_PFA__c = parsedData.billingContactName;
    }
    if (
      parsedData.billingContactEmail != null &&
      parsedData.billingContactEmail != ''
    ) {
      leadToUpdate.Billing_Contact_Email_PFA__c = parsedData.billingContactEmail;
    }
    if (
      parsedData.billingContactPhone != null &&
      parsedData.billingContactPhone != ''
    ) {
      leadToUpdate.Billing_Contact_Phone_PFA__c = parsedData.billingContactPhone;
    }
    if (parsedData.paymentMethod != null) {
      leadToUpdate.Preferred_Payment_Method_PFA__c = String.join(
        parsedData.paymentMethod,
        ';'
      );
    }
    if (
      parsedData.productsOrBrands != null &&
      parsedData.productsOrBrands != ''
    ) {
      leadToUpdate.Promoted_Sampled_Products_Brands__c = parsedData.productsOrBrands;
    }
    if (parsedData.eventLocations != null && parsedData.eventLocations != '') {
      leadToUpdate.Scheduling_Events_Account_Venue_s__c = parsedData.eventLocations;
    }
    if (parsedData.campaignPOC != null && parsedData.campaignPOC != '') {
      leadToUpdate.Campaign_POC__c = parsedData.campaignPOC;
    }
    if (
      parsedData.campaignPOCEmail != null &&
      parsedData.campaignPOCEmail != ''
    ) {
      leadToUpdate.Campaign_POC_Email__c = parsedData.campaignPOCEmail;
    }
    if (parsedData.campaignStartDate != null) {
      leadToUpdate.Campaign_Start_Date__c = Date.valueOf(
        parsedData.campaignStartDate
      );
    }
    if (parsedData.campaignEndDate != null) {
      leadToUpdate.Campaign_End_Date__c = Date.valueOf(
        parsedData.campaignEndDate
      );
    }
    if (
      parsedData.productDescription != null &&
      parsedData.productDescription != ''
    ) {
      leadToUpdate.Product_Description__c = parsedData.productDescription;
    }
    if (
      parsedData.schedulingResponsible != null &&
      parsedData.schedulingResponsible != ''
    ) {
      leadToUpdate.Responsible_for_Scheduling__c = parsedData.schedulingResponsible;
    }
    if (
      parsedData.baAttireRequest != null &&
      parsedData.baAttireRequest != ''
    ) {
      leadToUpdate.BA_Attire__c = parsedData.baAttireRequest;
    }
    if (parsedData.needPOS != null && parsedData.needPOS != '') {
      leadToUpdate.Do_you_need_POS__c = parsedData.needPOS;
    }
    if (
      parsedData.materialSummary != null &&
      parsedData.materialSummary != ''
    ) {
      leadToUpdate.Summary_of_Materials__c = parsedData.materialSummary;
    }

    return leadToUpdate;
  }

  public static void sendEmail(Lead lead) {
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'LeadUpdateNewClientForm'
      LIMIT 1
    ];
    try {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;
      if (lead != null) {
        if (lead.FirstName != null) {
          htmlBody = htmlBody.replace('{!FirstName}', lead.FirstName);
        }
        if (lead.LastName != null) {
          htmlBody = htmlBody.replace('{!LastName}', lead.LastName);
        }
        if (lead.Email != null) {
          htmlBody = htmlBody.replace('{!Email}', lead.Email);
        }
        if (lead.Phone != null) {
          htmlBody = htmlBody.replace('{!Phone}', lead.Phone);
        }
        if (lead.Company != null) {
          htmlBody = htmlBody.replace('{!Company}', lead.Company);
        }
        if (lead.Id != null) {
          htmlBody = htmlBody.replace(
            '{!URL}',
            CommonUtilitiesPfa.getRecordLink(lead.Id)
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
        SELECT New_Client_Form_Email__c
        FROM Email_Address__mdt
        WHERE DeveloperName = :recordName
        LIMIT 1
      ];
      if (emailConfig != null) {
        String emailAddress = emailConfig.New_Client_Form_Email__c;
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
