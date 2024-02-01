@RestResource(urlMapping='/ContactUs')
global class WordPressContactUsForm {
  @HttpPost
  global static String doPost() {
    String ERROR_CODE_EXCEPTION = '500';
    try {
      RestRequest req = RestContext.request;
      Blob body = req.requestBody;
      String requestString = body.toString();
      JSON2ApexForContactUsForm leadData = (JSON2ApexForContactUsForm) JSON.deserialize(
        requestString,
        JSON2ApexForContactUsForm.class
      );
      String firstName = leadData.firstName;
      String lastName = leadData.lastName;
      String email = leadData.email;
      String company = leadData.company;
      String venues = leadData.Venues;
      String phone = leadData.phone;
      String message = leadData.Message;
      String FormName = leadData.flag;
      String HowDidYouHear = leadData.HowDidYouHear;
      List<String> interestedIn = leadData.interestedIn;

      String ValidationCode = ValidateData(
        firstName,
        lastName,
        email,
        company,
        venues,
        phone,
        message,
        FormName,
        HowDidYouHear,
        interestedIn
      );
      if (ValidationCode != '200') {
        RestContext.response.statusCode = 400;
        return ValidationCode;
      }

      String Status = HandleBrandContact(
        firstName,
        lastName,
        email,
        company,
        venues,
        phone,
        message,
        FormName,
        HowDidYouHear,
        interestedIn
      );
      RestContext.response.statusCode = 201;
      if (Status == '404') {
        return HandleLeads(
          firstName,
          lastName,
          email,
          company,
          venues,
          phone,
          message,
          FormName,
          HowDidYouHear,
          interestedIn,
          'PFA Customer Lead'
        );
      } else {
        return Status;
      }
    } catch (DmlException e) {
      System.debug('Error: ' + e);
      RestContext.response.statusCode = 500;
      return ERROR_CODE_EXCEPTION;
    }
  }

  public static String generateQuoteRequestLink(Id quoteRequestId) {
    String quoteRequestLink =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      quoteRequestId;
    return quoteRequestLink;
  }

  public static void SendEmail(
    String firstName,
    String lastName,
    String emailOfRecord,
    String company,
    String phone,
    String message,
    String flag,
    String HowDidYouHear,
    List<String> interestedIn,
    String RecordId
  ) {
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'Contact Us Form'
    ];

    try {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;

      htmlBody = htmlBody.replace('{!FirstName}', firstName);
      htmlBody = htmlBody.replace('{!LastName}', lastName);
      htmlBody = htmlBody.replace('{!Email}', emailOfRecord);
      htmlBody = htmlBody.replace('{!Flag}', flag);
      htmlBody = htmlBody.replace('{!Company}', company);
      htmlBody = htmlBody.replace('{!Phone}', phone);
      htmlBody = htmlBody.replace('{!Message}', message);
      htmlBody = htmlBody.replace('{!HowDidYouHear}', HowDidYouHear);
      htmlBody = htmlBody.replace(
        '{!InterestedIn}',
        formatAsList(interestedIn)
      );
      htmlBody = htmlBody.replace('{!URL}', generateQuoteRequestLink(RecordId));
      email.setSubject(et.Subject);
      email.setHtmlBody(htmlBody);
      email.setTemplateId(et.Id);
      email.setSaveAsActivity(false);

      // get email address from metadata
      Organization orgInfo = [
        SELECT Id, InstanceName, IsSandbox, Name, OrganizationType
        FROM Organization
      ];
      String recordName = (orgInfo.IsSandbox == true)
        ? 'Sandbox'
        : 'Production';
      Email_Address__mdt emailConfig = [
        SELECT Contact_Us__c
        FROM Email_Address__mdt
        WHERE DeveloperName = :recordName
        LIMIT 1
      ];
      String emailAddress = emailConfig != null
        ? emailConfig.Contact_Us__c
        : null;
      List<String> toAddress = new List<String>{ emailAddress };
      email.setToAddresses(toAddress);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    } catch (Exception e) {
      System.debug(
        'Exception upon sending email: ' +
          e.getMessage() +
          '\n' +
          e.getStackTraceString()
      );
    }
  }

  private static String formatAsList(List<String> items) {
    String formattedList = '<ul style="list-style-type: disc; margin-left: 20px;">';
    for (String item : items) {
      formattedList += '<li>' + item + '</li>';
    }
    formattedList += '</ul>';
    return formattedList;
  }

  private static String HandleBrandContact(
    String firstName,
    String lastName,
    String email,
    String company,
    String venues,
    String phone,
    String message,
    String flag,
    String HowDidYouHear,
    List<String> interestedIn
  ) {
    String SUCCESS_CODE_CONTACT_UPDATED = '5001';
    String ERROR_CODE_CONTACT_NOT_FOUND = '404';
    List<Contact> existingContactsList = [
      SELECT
        Id,
        FirstName,
        Email,
        LastName,
        Company__c,
        Venues_Accounts_Located_In__c,
        Phone,
        Message__c,
        Contact_Created_From__c,
        Where_did_you_hear_about_us__c,
        What_are_you_interested_in__c,
        AccountId
      FROM Contact
      WHERE Email = :email AND RecordType.Name = 'Contact'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (!existingContactsList.isEmpty()) {
      Contact ExistingContact = existingContactsList[0];
      ExistingContact.FirstName = firstName;
      ExistingContact.LastName = lastName;
      ExistingContact.Company__c = company;
      ExistingContact.Email = email;
      ExistingContact.Phone = phone;
      ExistingContact.Message__c = message;
      ExistingContact.Venues_Accounts_Located_In__c = venues;
      ExistingContact.Contact_Created_From__c = flag;
      if (HowDidYouHear != null) {
        ExistingContact.Where_did_you_hear_about_us__c = HowDidYouHear;
      }
      ExistingContact.What_are_you_interested_in__c = String.join(
        interestedIn,
        ';'
      );
      update ExistingContact;
      System.debug('Id of existing Contact is: ' + ExistingContact.id);
      return SUCCESS_CODE_CONTACT_UPDATED;
    } else {
      return ERROR_CODE_CONTACT_NOT_FOUND;
    }
  }

  private static String HandleLeads(
    String firstName,
    String lastName,
    String email,
    String company,
    String venues,
    String phone,
    String message,
    String FormName,
    String HowDidYouHear,
    List<String> interestedIn,
    String leadRecordTypeName
  ) {
    String SUCCESS_CODE_LEAD_UPDATED = '3001';
    String SUCCESS_CODE_LEAD_CREATED = '3002';
    String SUCCESS_CODE_LEAD_DUPL_UPDATED = '6002';
    List<Lead> existingLeads = [
      SELECT
        Id,
        FirstName,
        LastName,
        Company,
        Email,
        Phone,
        Message_PFA__c,
        Venues_Accounts_Located_In__c,
        Lead_Created_From__c,
        Where_did_you_hear_about_us__c,
        Interested_In__c
      FROM Lead
      WHERE Email = :email AND IsConverted = FALSE
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (!existingLeads.isEmpty()) {
      // Update the existing Lead
      Lead existingLead = existingLeads[0];
      existingLead.FirstName = firstName;
      existingLead.LastName = lastName;
      existingLead.Company = company;
      existingLead.Email = email;
      existingLead.Phone = phone;
      existingLead.Message_PFA__c = message;
      existingLead.Venues_Accounts_Located_In__c = venues;
      existingLead.Lead_Created_From__c = FormName;
      if (HowDidYouHear != null) {
        existingLead.Where_did_you_hear_about_us__c = HowDidYouHear;
      }
      existingLead.Interested_In__c = String.join(interestedIn, ';');
      update existingLead;
      System.debug('Id ofexistingLead  is: ' + existingLead.id);
      return SUCCESS_CODE_LEAD_UPDATED;
    } else {
      // Create a new Lead
      Lead newLead = new Lead();
      newLead.FirstName = firstName;
      newLead.LastName = lastName;
      newLead.Email = email;
      newLead.Company = company;
      newLead.Phone = phone;
      newLead.Message_PFA__c = message;
      newLead.Venues_Accounts_Located_In__c = venues;
      newLead.Lead_Created_From__c = FormName;
      if (HowDidYouHear != null) {
        newLead.Where_did_you_hear_about_us__c = HowDidYouHear;
      }
      newLead.Interested_In__c = String.join(interestedIn, ';');
      newLead.RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Lead' AND Name = :leadRecordTypeName
        LIMIT 1
      ]
      .Id;
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.DuplicateRuleHeader.allowSave = true;
      Database.SaveResult result = Database.insert(newLead, dmlOptions);
      System.debug('New Lead Id: ' + newLead.Id);
      SendEmail(
        firstName,
        lastName,
        email,
        company,
        phone,
        message,
        FormName,
        HowDidYouHear,
        interestedIn,
        newLead.Id
      );
      return SUCCESS_CODE_LEAD_CREATED;
    }
  }

  public static String ValidateData(
    String firstName,
    String lastName,
    String email,
    String company,
    String venues,
    String phone,
    String message,
    String FormName,
    String HowDidYouHear,
    List<String> interestedIn
  ) {
    // ERROR CODES
    String SUCCESS_CODE = '200';
    String ERROR_CODE_INVALID_FIRSTNAME = '4001';
    String ERROR_CODE_INVALID_LASTNAME = '4002';
    String ERROR_CODE_INVALID_EMAIL = '4003';
    String ERROR_CODE_INVALID_COMPANY = '4004';
    String ERROR_CODE_INVALID_PHONE = '4006';
    String ERROR_CODE_INVALID_FORMNAME = '4008';
    String ERROR_CODE_INVALID_HOWDIDYOUHEAR_LENGTH = '4014';
    String ERROR_CODE_INVALID_MESSAGE = '4018';
    String ERROR_CODE_EMPTY_INTERESTED_IN = '4019';
    String ERROR_CODE_INVALID_INTERESTS = '4020';
    String EMAIL_REGEX = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    String PHONE_REGEX = '^[^a-zA-Z]*$';

    Schema.DescribeSObjectResult leadSchema = Lead.sObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = leadSchema.fields.getMap();
    List<Schema.PicklistEntry> fld = fieldMap.get('Interested_In__c')
      .getDescribe()
      .getPicklistValues();
    List<String> validInterestedIn = new List<String>();
    for (Schema.PicklistEntry pl : fld) {
      validInterestedIn.add(pl.getValue());
    }
    if (String.isBlank(firstName) || firstName == null) {
      return ERROR_CODE_INVALID_FIRSTNAME;
    }
    if (String.isBlank(lastName) || lastName == null) {
      return ERROR_CODE_INVALID_LASTNAME;
    }
    if (email != null) {
      if (!Pattern.matches(EMAIL_REGEX, email)) {
        return ERROR_CODE_INVALID_EMAIL;
      }
    } else {
      return ERROR_CODE_INVALID_EMAIL;
    }
    if (String.isBlank(company) || company == null) {
      return ERROR_CODE_INVALID_COMPANY;
    }

    if (phone != null && !String.isBlank(phone)) {
      if (!Pattern.matches(PHONE_REGEX, phone)) {
        return ERROR_CODE_INVALID_PHONE;
      }
    } else {
      return ERROR_CODE_INVALID_PHONE;
    }
    if (
      !('Contact Us'.equals(FormName) ||
      'About Us'.equals(FormName) ||
      'Our Services'.equals(FormName))
    ) {
      return ERROR_CODE_INVALID_FORMNAME;
    }
    if (String.isBlank(message) || message == null) {
      return ERROR_CODE_INVALID_MESSAGE;
    }
    if (HowDidYouHear != null) {
      if (HowDidYouHear.length() > 23) {
        return ERROR_CODE_INVALID_HOWDIDYOUHEAR_LENGTH;
      }
    }

    if (interestedIn == null || interestedIn.isEmpty()) {
      return ERROR_CODE_EMPTY_INTERESTED_IN;
    }
    for (String Interests : interestedIn) {
      if (!validInterestedIn.contains(Interests)) {
        return ERROR_CODE_INVALID_INTERESTS;
      }
    }
    return SUCCESS_CODE;
  }
}
