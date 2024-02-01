@RestResource(urlMapping='/JoinOurTeam')
global class WordPressJoinOurTeamForm {
  @HttpPost
  global static String createRecord() {
    String ERROR_CODE_EXCEPTION = '500';
    try {
      RestRequest req = RestContext.request;
      Blob body = req.requestBody;
      String requestString = body.toString();
      JSON2ApexForJoinOurTeamForm leadData = (JSON2ApexForJoinOurTeamForm) JSON.deserialize(
        requestString,
        JSON2ApexForJoinOurTeamForm.class
      );
      String ValidationCode = ValidateJoinOurTeamFormData(leadData);
      if (ValidationCode != '200') {
        RestContext.response.statusCode = 400;
        return ValidationCode;
      }
      RestContext.response.statusCode = 201;
      return HandleLead(leadData);
    } catch (DmlException e) {
      System.debug('Error: ' + e);
      RestContext.response.statusCode = 500;
      return ERROR_CODE_EXCEPTION;
    }
  }
  private static String HandleLead(JSON2ApexForJoinOurTeamForm leadData) {
    id RecordId;
    String ReturnCode;
    String SUCCESS_CODE_Lead_CREATED = '5002';
    String SUCCESS_CODE_Lead_UPDATED = '5001';
    List<Lead> ExistingLeads = [
      SELECT
        Id,
        FirstName,
        LastName,
        Phone,
        State_of_Residence__c,
        Birthday__c,
        Primary_Language__c,
        Secondary_Language__c,
        Brand_activations_and_Support_activities__c,
        Certifications_you_hold__c,
        RBS_Server_ID__c,
        Pop_Bookings_profile_for_direct_deposit__c,
        Necessary_Supplies__c,
        Atleast_21_years__c,
        hear_about_us__c,
        Referred_by_a_Brand_Ambassador__c
      FROM Lead
      WHERE
        Email = :leadData.email
        AND IsConverted = FALSE
        AND RecordType.Name = 'Brand Ambassador Lead'
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    if (!ExistingLeads.isEmpty()) {
      RecordId = UpdateExisitingLead(leadData, ExistingLeads);
      ReturnCode = SUCCESS_CODE_Lead_UPDATED;
    } else {
      RecordId = CreateNewLead(leadData);
      ReturnCode = SUCCESS_CODE_Lead_CREATED;
    }
    createAttachment(LeadData.Headshot_Photo, RecordId, 'Headshot Photo.png');
    createAttachment(
      LeadData.Full_Length_Photo,
      RecordId,
      'Full Length Photo.png'
    );
    if (LeadData.Additional_Image != null) {
      createAttachment(
        LeadData.Additional_Image,
        RecordId,
        'Additional Image.png'
      );
    }
    return ReturnCode;
  }
  private static id UpdateExisitingLead(
    JSON2ApexForJoinOurTeamForm leadData,
    List<Lead> ExistingLeads
  ) {
    Lead existingLead = ExistingLeads[0];
    existingLead.FirstName = leadData.first_name;
    existingLead.LastName = leadData.last_name;
    existingLead.Phone = leadData.phone;
    existingLead.State_of_Residence__c = leadData.state_of_residence;
    if (leadData.birthday != null) {
      existingLead.Birthday__c = Date.valueOf(leadData.birthday);
    }
    existingLead.Primary_Language__c = leadData.primary_language;
    existingLead.Secondary_Language__c = leadData.secondary_language;
    existingLead.Brand_activations_and_Support_activities__c = String.join(
      leadData.brand_activations_experience,
      ';'
    );
    existingLead.Certifications_you_hold__c = String.join(
      leadData.certifications,
      ';'
    );
    if (LeadData.rbs_server_id != null) {
      existingLead.RBS_Server_ID__c = LeadData.rbs_server_id;
    }
    if (LeadData.pop_bookings_profile != null) {
      existingLead.Pop_Bookings_profile_for_direct_deposit__c = LeadData.pop_bookings_profile;
    }
    existingLead.Necessary_Supplies__c = LeadData.supplies;
    existingLead.Atleast_21_years__c = true;
    if (LeadData.hear_about_us != null) {
      existingLead.hear_about_us__c = LeadData.hear_about_us;
    }
    if (LeadData.referral_name != null) {
      existingLead.Referred_by_a_Brand_Ambassador__c = LeadData.referral_name;
    }
    update existingLead;
    return existingLead.id;
  }
  private static id CreateNewLead(JSON2ApexForJoinOurTeamForm leadData) {
    Lead NewLead = new Lead();
    NewLead.Status = 'Not Yet Approved';
    NewLead.Company = 'Phun for All';
    NewLead.LeadSource = 'Webform';
    NewLead.FirstName = leadData.first_name;
    NewLead.LastName = leadData.last_name;
    NewLead.Phone = leadData.phone;
    NewLead.Email = leadData.email;
    NewLead.State_of_Residence__c = leadData.state_of_residence;
    if (leadData.birthday != null) {
      NewLead.Birthday__c = Date.valueOf(leadData.birthday);
    }
    NewLead.Primary_Language__c = leadData.primary_language;
    NewLead.Secondary_Language__c = leadData.secondary_language;
    NewLead.Brand_activations_and_Support_activities__c = String.join(
      leadData.brand_activations_experience,
      ';'
    );
    NewLead.Certifications_you_hold__c = String.join(
      leadData.certifications,
      ';'
    );
    if (LeadData.rbs_server_id != null) {
      NewLead.RBS_Server_ID__c = LeadData.rbs_server_id;
    }
    if (LeadData.pop_bookings_profile != null) {
      NewLead.Pop_Bookings_profile_for_direct_deposit__c = LeadData.pop_bookings_profile;
    }
    NewLead.Necessary_Supplies__c = LeadData.supplies;
    NewLead.Atleast_21_years__c = true;
    if (LeadData.hear_about_us != null) {
      NewLead.hear_about_us__c = LeadData.hear_about_us;
    }
    if (LeadData.referral_name != null) {
      NewLead.Referred_by_a_Brand_Ambassador__c = LeadData.referral_name;
    }
    NewLead.RecordTypeId = [
      SELECT Id
      FROM RecordType
      WHERE SObjectType = 'Lead' AND Name = 'Brand Ambassador Lead'
      LIMIT 1
    ]
    .Id;
    List<Account> AccList = [
      SELECT id
      FROM Account
      WHERE Name = 'Phun For All'
      LIMIT 1
    ];
    Database.DMLOptions dmlOptions = new Database.DMLOptions();
    dmlOptions.DuplicateRuleHeader.allowSave = true;
    Database.SaveResult result = Database.insert(NewLead, dmlOptions);
    SendEmail(LeadData, NewLead.Id);
    return NewLead.Id;
  }

  private static String generateLink(Id quoteRequestId) {
    String quoteRequestLink =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/' +
      quoteRequestId;
    return quoteRequestLink;
  }

  private static void SendEmail(
    JSON2ApexForJoinOurTeamForm leadData,
    Id RecordId
  ) {
    EmailTemplate et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = 'Join Our Team'
    ];

    try {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;
      htmlBody = htmlBody.replace('{!FirstName}', leadData.first_name);
      htmlBody = htmlBody.replace('{!LastName}', leadData.last_name);
      htmlBody = htmlBody.replace('{!Email}', leadData.email);
      htmlBody = htmlBody.replace('{!Phone}', leadData.phone);
      htmlBody = htmlBody.replace(
        '{!MailingState}',
        leadData.state_of_residence
      );
      htmlBody = htmlBody.replace(
        '{!Primary_Language__c}',
        leadData.primary_language
      );
      htmlBody = htmlBody.replace(
        '{!Secondary_Language__c}',
        leadData.secondary_language
      );
      String brandActivitiesList = formatAsList(
        leadData.brand_activations_experience
      );
      htmlBody = htmlBody.replace(
        '{!Brand_activations_and_Support_activities__c}',
        brandActivitiesList
      );
      String certificationsList = formatAsList(leadData.certifications);
      htmlBody = htmlBody.replace(
        '{!Certifications_you_hold__c}',
        certificationsList
      );
      htmlBody = htmlBody.replace(
        '{!Pop_Bookings_profile_for_direct_deposit__c}',
        leadData.pop_bookings_profile
      );
      htmlBody = htmlBody.replace(
        '{!Necessary_Supplies__c}',
        leadData.supplies
      );
      htmlBody = htmlBody.replace('{!Atleast_21_years__c}', 'YES');
      htmlBody = htmlBody.replace('{!URL}', generateLink(RecordId));

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
        SELECT Join_Our_Team__c
        FROM Email_Address__mdt
        WHERE DeveloperName = :recordName
        LIMIT 1
      ];
      String emailAddress = emailConfig != null
        ? emailConfig.Join_Our_Team__c
        : null;
      List<String> toAddress = new List<String>{ emailAddress };
      email.setToAddresses(toAddress);
      email.setTemplateId(et.Id);
      email.setSaveAsActivity(false);

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

  private static void createAttachment(
    Blob blobData,
    Id contactId,
    String fileName
  ) {
    ContentVersion contentVersion = new ContentVersion();
    contentVersion.VersionData = blobData;
    contentVersion.Title = fileName;
    contentVersion.PathOnClient = '/' + fileName;
    insert contentVersion;
    // Create a ContentDocumentLink to associate the file with the parent record
    ContentDocumentLink contentLink = new ContentDocumentLink();
    contentLink.ContentDocumentId = [
      SELECT Id, ContentDocumentId
      FROM ContentVersion
      WHERE Id = :contentVersion.Id
    ]
    .ContentDocumentId;
    contentLink.LinkedEntityId = contactId;
    contentLink.ShareType = 'V';
    contentLink.Visibility = 'AllUsers';
    insert contentLink;
  }

  public static String ValidateJoinOurTeamFormData(
    JSON2ApexForJoinOurTeamForm leadData
  ) {
    // ERROR CODES
    String SUCCESS_CODE = '200';
    String ERROR_CODE_INVALID_FIRSTNAME = '4001';
    String ERROR_CODE_INVALID_LASTNAME = '4002';
    String ERROR_CODE_INVALID_EMAIL = '4003';
    String ERROR_CODE_INVALID_PHONE = '4006';
    String ERROR_CODE_INVALID_BRAND_ACTIVATIONS_EXPERIENCE = '4021';
    String ERROR_CODE_INVALID_CERTIFICATIONS = '4022';
    String ERROR_CODE_INVALID_RBS_SERVER_ID = '4023';
    String ERROR_CODE_INVALID_POP_BOOKINGS_PROFILE = '4024';
    String ERROR_CODE_INVALID_SUPPLIES = '4025';
    String ERROR_CODE_INVALID_RBS_SERVER_ID_FORMAT = '4026';
    String ERROR_CODE_INVALID_STATE_OF_RESIDENCE = '4027';
    String ERROR_CODE_INVALID_BIRTHDAY_FORMAT = '4028';
    String ERROR_CODE_INVALID_BIRTHDAY_RANGE = '4029';
    String ERROR_CODE_INVALID_PRIMARY_LANGUAGE = '4030';
    String ERROR_CODE_INVALID_SECONDARY_LANGUAGE = '4031';
    String ERROR_CODE_INVALID_CERTIFY_AGE = '4032';
    String ERROR_CODE_INVALID_HEAR_ABOUT_US = '4033';
    String ERROR_CODE_INVALID_HEADSHOT_PHOTO = '4034';
    String ERROR_CODE_INVALID_FULL_LENGTH_PHOTO = '4035';
    String ERROR_CODE_MISSING_ADDITIONAL_IMAGE = '4036';

    String EMAIL_REGEX = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    String PHONE_REGEX = '^[^a-zA-Z]*$';
    Set<String> validStateNames = new Set<String>{
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
      'Illinois',
      'Indiana',
      'Iowa',
      'Kansas',
      'Kentucky',
      'Louisiana',
      'Maine',
      'Maryland',
      'Massachusetts',
      'Michigan',
      'Minnesota',
      'Mississippi',
      'Missouri',
      'Montana',
      'Nebraska',
      'Nevada',
      'New Hampshire',
      'New Jersey',
      'New Mexico',
      'New York',
      'North Carolina',
      'North Dakota',
      'Ohio',
      'Oklahoma',
      'Oregon',
      'Pennsylvania',
      'Rhode Island',
      'South Carolina',
      'South Dakota',
      'Tennessee',
      'Texas',
      'Utah',
      'Vermont',
      'Virginia',
      'Washington',
      'West Virginia',
      'Wisconsin',
      'Wyoming'
    };
    Set<String> validBrandActivationsExperience = validPicklistValues(
      'Brand_activations_and_Support_activities__c'
    );
    Set<String> validCertifications = validPicklistValues(
      'Certifications_you_hold__c'
    );
    Set<String> validPopBookingsProfile = validPicklistValues(
      'Pop_Bookings_profile_for_direct_deposit__c'
    );
    Set<String> validSupplies = validPicklistValues('Necessary_Supplies__c');
    Set<String> validPrimaryLanguages = validPicklistValues(
      'Primary_Language__c'
    );
    Set<String> validSecondaryLanguages = validPicklistValues(
      'Secondary_Language__c'
    );
    Set<String> validHearAboutUs = validPicklistValues('hear_about_us__c');

    if (String.isBlank(leadData.first_name) || leadData.first_name == null) {
      return ERROR_CODE_INVALID_FIRSTNAME;
    }
    if (String.isBlank(leadData.last_name) || leadData.last_name == null) {
      return ERROR_CODE_INVALID_LASTNAME;
    }
    if (leadData.email != null) {
      if (!Pattern.matches(EMAIL_REGEX, leadData.email)) {
        return ERROR_CODE_INVALID_EMAIL;
      }
    } else {
      return ERROR_CODE_INVALID_EMAIL;
    }
    if (leadData.phone != null && !String.isBlank(leadData.phone)) {
      if (!Pattern.matches(PHONE_REGEX, leadData.phone)) {
        return ERROR_CODE_INVALID_PHONE;
      }
    } else {
      return ERROR_CODE_INVALID_PHONE;
    }

    if (leadData.brand_activations_experience != null) {
      for (String brandExperience : leadData.brand_activations_experience) {
        if (!validBrandActivationsExperience.contains(brandExperience)) {
          return ERROR_CODE_INVALID_BRAND_ACTIVATIONS_EXPERIENCE;
        }
      }
    } else {
      return ERROR_CODE_INVALID_BRAND_ACTIVATIONS_EXPERIENCE;
    }
    if (leadData.certifications != null) {
      for (String certification : leadData.certifications) {
        if (!validCertifications.contains(certification)) {
          return ERROR_CODE_INVALID_CERTIFICATIONS;
        }
      }
    } else {
      return ERROR_CODE_INVALID_CERTIFICATIONS;
    }
    if (leadData.rbs_server_id != null) {
      if (!Pattern.matches('^[0-9]*$', leadData.rbs_server_id)) {
        return ERROR_CODE_INVALID_RBS_SERVER_ID_FORMAT;
      }
    }
    if (
      leadData.pop_bookings_profile != null &&
      !validPopBookingsProfile.contains(leadData.pop_bookings_profile)
    ) {
      return ERROR_CODE_INVALID_POP_BOOKINGS_PROFILE;
    }
    if (leadData.supplies != null) {
      if (!validSupplies.contains(leadData.supplies)) {
        return ERROR_CODE_INVALID_SUPPLIES;
      }
    } else {
      return ERROR_CODE_INVALID_SUPPLIES;
    }

    if (leadData.state_of_residence != null) {
      if (!validStateNames.contains(leadData.state_of_residence)) {
        return ERROR_CODE_INVALID_STATE_OF_RESIDENCE;
      }
    } else {
      return ERROR_CODE_INVALID_STATE_OF_RESIDENCE;
    }
    // Add more validations as needed
    if (leadData.birthday != null) {
      if (!isValidDateFormat(leadData.birthday)) {
        return ERROR_CODE_INVALID_BIRTHDAY_FORMAT;
      }

      // Assuming you want to check that the birthday is not in the future
      Date birthdayDate = Date.valueOf(leadData.birthday);
      Date currentDate = Date.today();
      if (birthdayDate > currentDate) {
        return ERROR_CODE_INVALID_BIRTHDAY_RANGE;
      }
    }

    if (leadData.hear_about_us != null) {
      if (!validHearAboutUs.contains(leadData.hear_about_us)) {
        return ERROR_CODE_INVALID_HEAR_ABOUT_US;
      }
    }

    if (
      String.isBlank(leadData.primary_language) ||
      leadData.primary_language == null
    ) {
      return ERROR_CODE_INVALID_PRIMARY_LANGUAGE;
    } else if (!validPrimaryLanguages.contains(leadData.primary_language)) {
      return ERROR_CODE_INVALID_PRIMARY_LANGUAGE;
    }
    if (
      String.isBlank(leadData.secondary_language) ||
      leadData.secondary_language == null
    ) {
      return ERROR_CODE_INVALID_SECONDARY_LANGUAGE;
    } else if (!validSecondaryLanguages.contains(leadData.secondary_language)) {
      return ERROR_CODE_INVALID_SECONDARY_LANGUAGE;
    }
    if (leadData.certify_age != null) {
      if (leadData.certify_age != 'true' || leadData.certify_age != 'TRUE') {
        return ERROR_CODE_INVALID_CERTIFY_AGE;
      }
    }
    // Check for Headshot_Photo
    if (leadData.Headshot_Photo == null) {
      return ERROR_CODE_INVALID_HEADSHOT_PHOTO;
    }
    // Check for Full_Length_Photo
    if (leadData.Full_Length_Photo == null) {
      return ERROR_CODE_INVALID_FULL_LENGTH_PHOTO;
    }
    return SUCCESS_CODE;
  }

  // Assume this method retrieves valid picklist values from the specified field on the related object
  private static Set<String> validPicklistValues(String fieldApiName) {
    Set<String> validValues = new Set<String>();
    Schema.DescribeFieldResult fieldResult = Schema.getGlobalDescribe()
      .get('Lead')
      .getDescribe()
      .fields.getMap()
      .get(fieldApiName)
      .getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry picklistEntry : picklistValues) {
      validValues.add(picklistEntry.getValue());
    }
    return validValues;
  }
  private static Boolean isValidDateFormat(String dateString) {
    try {
      Date dt = Date.valueOf(dateString);
      return true;
    } catch (Exception e) {
      return false;
    }
  }
}
