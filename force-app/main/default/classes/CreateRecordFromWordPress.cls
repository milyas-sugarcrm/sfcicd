@RestResource(urlMapping='/RecordCreate')
global class CreateRecordFromWordPress {
  @HttpPost
  global static String createRecord() {
    RestRequest req = RestContext.request;
    Blob body = req.requestBody;
    String requestString = body.toString();
    DataFromWordPress leadData = (DataFromWordPress) JSON.deserialize(
      requestString,
      DataFromWordPress.class
    );
    String firstName = leadData.firstName;
    String lastName = leadData.lastName;
    String email = leadData.email;
    String company = leadData.company;
    String title = leadData.title;
    String phone = leadData.phone;
    String street = leadData.Street;
    String city = leadData.City;
    String state = leadData.State;
    String country = leadData.Country.toUpperCase();

    String zipCode = leadData.ZipCode;
    String flag = leadData.flag;
    String ASI = leadData.ASI;
    String HowDidYouHear = leadData.HowDidYouHear;
    List<String> Events = leadData.Events;
    String ValidationCode = ValidateData(
      firstName,
      lastName,
      email,
      company,
      title,
      ASI,
      phone,
      street,
      city,
      state,
      zipCode,
      country,
      flag,
      Events,
      HowDidYouHear
    );
    if (ValidationCode != '200') {
      return ValidationCode;
    }
    // Find contacts based on flag and email
    List<Contact> existingContacts;
    String opportunityRecordTypeName;
    String leadRecordTypeName;
    if (flag == 'Supplier') {
      existingContacts = [
        SELECT Id, Email, AccountId
        FROM Contact
        WHERE Email = :email AND RecordType.Name = 'Contact'
        LIMIT 1
      ];
      opportunityRecordTypeName = 'EME Vendor Booking Opportunity';
      leadRecordTypeName = 'Vendor Lead';
    } else if (flag == 'Distributor') {
      existingContacts = [
        SELECT Id, Email, AccountId
        FROM Contact
        WHERE Email = :email AND RecordType.Name = 'Distributor Contacts'
        LIMIT 1
      ];
      opportunityRecordTypeName = 'EME Distributor Booking Opportunity';
      leadRecordTypeName = 'Distributor Lead';
    }
    // Check if a contact is found
    if (!existingContacts.isEmpty()) {
      return HandleOpp(
        existingContacts,
        firstName,
        lastName,
        email,
        phone,
        company,
        title,
        ASI,
        street,
        city,
        state,
        zipCode,
        country,
        HowDidYouHear,
        Events,
        opportunityRecordTypeName
      );
    } else {
      return HandleLeads(
        firstName,
        lastName,
        email,
        phone,
        company,
        title,
        ASI,
        street,
        city,
        state,
        zipCode,
        country,
        HowDidYouHear,
        Events,
        leadRecordTypeName
      );
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
    String emailID,
    String phone,
    String company,
    String title,
    String ASI,
    String street,
    String city,
    String state,
    String zipCode,
    String HowDidYouHear,
    List<String> Events,
    String opportunityRecordTypeName,
    Id OppID
  ) {
    EmailTemplate et;
    String TemplateName, RecipentEmail;
    if (opportunityRecordTypeName == 'EME Distributor Booking Opportunity') {
      TemplateName = 'For Distributor Opp (Eric Johnson)';
      RecipentEmail = System.Label.Eric_Johnson_s_Email;
    } else if (opportunityRecordTypeName == 'EME Vendor Booking Opportunity') {
      TemplateName = 'For Vendor Opp (Vicky Tirpack)';
      RecipentEmail = System.Label.Vicky_Tirpack_s_Email;
    }
    et = [
      SELECT Id, Name, HtmlValue, Subject
      FROM EmailTemplate
      WHERE Name = :TemplateName
    ];

    try {
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;
      String opportunityLink =
        '<a href="' +
        generateQuoteRequestLink(OppID) +
        '">' +
        opportunity.Name +
        '</a>';
      String address = street + ' ' + city + ' ' + state + ' ' + zipCode;

      htmlBody = htmlBody.replace('{!Contact.FirstName}', firstName);
      htmlBody = htmlBody.replace('{!Contact.LastName}', lastName);
      htmlBody = htmlBody.replace('{!Opportunity.Title__c}', title);
      htmlBody = htmlBody.replace('{!Opportunity.Phone__c}', phone);
      htmlBody = htmlBody.replace('{!Opportunity.Email__c}', emailID);
      htmlBody = htmlBody.replace('{!Opportunity.Company__c}', company);
      htmlBody = htmlBody.replace('{!Opportunity.Billing_Address__c}', address);
      htmlBody = htmlBody.replace('{!Opportunity.Industry_Number__c}', ASI);
      String eventsHtml = '';
      for (Integer i = 0; i < Events.size(); i++) {
        eventsHtml += Events[i] + '<br>';
      }
      htmlBody = htmlBody.replace('{!Opportunity.Event_Name__c}', eventsHtml);
      htmlBody = htmlBody.replace('{!URL}', generateQuoteRequestLink(OppID));
      if (opportunityRecordTypeName == 'EME Distributor Booking Opportunity') {
        htmlBody = htmlBody.replace(
          '{!Opportunity.How_did_you_hear_about_EME__c}',
          HowDidYouHear
        );
      }

      email.setHtmlBody(htmlBody);
      email.setSubject(et.Subject);
      String EmailAddress = RecipentEmail;
      String[] toAddress = new List<String>{ EmailAddress };
      email.setTemplateId(et.Id);
      email.setSaveAsActivity(false);
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

  private static String HandleLeads(
    String firstName,
    String lastName,
    String email,
    String phone,
    String company,
    String title,
    String ASI,
    String street,
    String city,
    String state,
    String zipCode,
    String Country,
    String HowDidYouHear,
    List<String> Events,
    String leadRecordTypeName
  ) {
    String SUCCESS_CODE_LEAD_UPDATED = '3001';
    String SUCCESS_CODE_LEAD_CREATED = '3002';
    String SUCCESS_CODE_LEAD_DUPL_UPDATED = '6002';
    List<Lead> existingLeads = [
      SELECT Id
      FROM Lead
      WHERE Email = :email AND recordtype.Name = :leadRecordTypeName
      LIMIT 1
    ];
    if (!existingLeads.isEmpty()) {
      // Update the existing Lead
      Lead existingLead = existingLeads[0];
      existingLead.FirstName = firstName;
      existingLead.LastName = lastName;
      existingLead.Company = company;
      existingLead.Title = title;
      existingLead.Email = email;
      existingLead.Phone = phone;
      existingLead.Street = street;
      existingLead.City = city;
      existingLead.State = state;
      existingLead.PostalCode = zipCode;
      existingLead.Country = Country;
      existingLead.Industry_Number__c = ASI;
      existingLead.Event_Name__c = String.join(Events, ';');
      if (leadRecordTypeName == 'Distributor Lead') {
        existingLead.How_did_you_hear_about_EME__c = HowDidYouHear;
      }
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
      newLead.Title = title;
      newLead.Phone = phone;
      newLead.Street = street;
      newLead.City = city;
      newLead.State = state;
      newLead.PostalCode = zipCode;
      newLead.Country = Country;
      newLead.Industry_Number__c = ASI;
      newLead.RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Lead' AND Name = :leadRecordTypeName
        LIMIT 1
      ]
      .Id;
      if (leadRecordTypeName == 'Distributor Lead') {
        newLead.How_did_you_hear_about_EME__c = HowDidYouHear;
      }
      newLead.Event_Name__c = String.join(Events, ';');
      Database.DMLOptions dmlOptions = new Database.DMLOptions();
      dmlOptions.DuplicateRuleHeader.allowSave = true;

      Database.SaveResult result = Database.insert(newLead, dmlOptions);
      return SUCCESS_CODE_LEAD_CREATED;
    }
  }

  public static String findYearInEvents(List<String> events) {
    String yearInString;

    for (Integer year = 2023; year <= 2050; year++) {
      yearInString = String.valueOf(year);

      for (String event : events) {
        if (event.contains(yearInString)) {
          return yearInString;
        }
      }
    }

    return yearInString;
  }

  public static string HandleOpp(
    List<Contact> existingContacts,
    String firstName,
    String lastName,
    String email,
    String phone,
    String company,
    String title,
    String ASI,
    String street,
    String city,
    String state,
    String zipCode,
    String Country,
    String HowDidYouHear,
    List<String> Events,
    String opportunityRecordTypeName
  ) {
    String SUCCESS_CODE_OPPORTUNIY_UPDATED = '2001';
    String SUCCESS_CODE_OPPORTUNIY_CREATED = '2002';
    String SUCCESS_CODE_OPP_DUPL_UPDATED = '6001';
    // Find the Account associated with the Contact
    Account existingAccount = [
      SELECT Id, Name
      FROM Account
      WHERE Id = :existingContacts[0].AccountId
      LIMIT 1
    ];
    // Find an Opportunity related to the Account and email
    List<Opportunity> existingOpportunities = [
      SELECT Id
      FROM Opportunity
      WHERE
        AccountId = :existingAccount.Id
        AND Contact__c = :existingContacts[0].Id
      LIMIT 1
    ];
    if (!existingOpportunities.isEmpty()) {
      // Update the existing Opportunity
      Opportunity existingOpportunity = existingOpportunities[0];
      existingOpportunity.Name =
        existingAccount.Name +
        ' ' +
        findYearInEvents(Events);
      existingOpportunity.Email__c = email;
      existingOpportunity.Phone__c = phone;
      existingOpportunity.Company__c = company;
      existingOpportunity.Title__c = title;
      existingOpportunity.Industry_Number__c = ASI;

      existingOpportunity.Billing_Address1__street__s = street;
      existingOpportunity.Billing_Address1__City__s = city;
      existingOpportunity.Billing_Address1__StateCode__s = state;
      existingOpportunity.Billing_Address1__PostalCode__s = zipCode;
      existingOpportunity.Billing_Address1__CountryCode__s = Country;

      existingOpportunity.Event_Name__c = String.join(Events, ';');
      if (opportunityRecordTypeName == 'EME Distributor Booking Opportunity') {
        existingOpportunity.How_did_you_hear_about_EME__c = HowDidYouHear;
      }
      update existingOpportunity;
      return SUCCESS_CODE_OPPORTUNIY_UPDATED;
    } else {
      // Create a new Opportunity
      Opportunity newOpportunity = new Opportunity();
      newOpportunity.Name =
        existingAccount.Name +
        ' ' +
        findYearInEvents(Events);
      newOpportunity.Email__c = email;
      newOpportunity.Phone__c = phone;
      newOpportunity.Company__c = company;
      newOpportunity.Title__c = title;
      newOpportunity.Industry_Number__c = ASI;

      newOpportunity.Billing_Address1__street__s = street;
      newOpportunity.Billing_Address1__City__s = city;
      newOpportunity.Billing_Address1__StateCode__s = state;
      newOpportunity.Billing_Address1__PostalCode__s = zipCode;
      newOpportunity.Billing_Address1__CountryCode__s = Country;

      newOpportunity.Event_Name__c = String.join(Events, ';');
      newOpportunity.AccountId = existingAccount.Id;
      newOpportunity.Contact__c = existingContacts[0].Id;
      newOpportunity.StageName = 'Needs Analysis';
      newOpportunity.CloseDate = System.today() + 30;
      newOpportunity.RecordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE SObjectType = 'Opportunity' AND Name = :opportunityRecordTypeName
        LIMIT 1
      ]
      .Id;
      if (opportunityRecordTypeName == 'EME Distributor Booking Opportunity') {
        newOpportunity.How_did_you_hear_about_EME__c = HowDidYouHear;
      }
      insert newOpportunity;
      SendEmail(
        firstName,
        lastName,
        email,
        phone,
        company,
        title,
        ASI,
        street,
        city,
        state,
        zipCode,
        HowDidYouHear,
        Events,
        opportunityRecordTypeName,
        newOpportunity.Id
      );
      return SUCCESS_CODE_OPPORTUNIY_CREATED;
    }
  }

  public static String ValidateData(
    String firstName,
    String lastName,
    String email,
    String company,
    String title,
    String ASI,
    String phone,
    String street,
    String city,
    String state,
    String zipCode,
    String Country,
    String flag,
    List<String> Events,
    String HowDidYouHear
  ) {
    // ERROR CODES
    String SUCCESS_CODE = '200';
    String ERROR_CODE_INVALID_FIRSTNAME = '4001';
    String ERROR_CODE_INVALID_LASTNAME = '4002';
    String ERROR_CODE_INVALID_EMAIL = '4003';
    String ERROR_CODE_INVALID_COMPANY = '4004';
    String ERROR_CODE_INVALID_TITLE = '4005';
    String ERROR_CODE_INVALID_PHONE = '4006';
    String ERROR_CODE_INVALID_ADDRESS = '4007';
    String ERROR_CODE_INVALID_FLAG = '4008';
    String ERROR_CODE_INVALID_EVENTS = '4009';
    String ERROR_CODE_EMPTY_EVENTS = '4010';
    String ERROR_CODE_INVALID_ASI = '4011';
    String ERROR_CODE_INVALID_TITLE_LENGTH = '4012';
    String ERROR_CODE_INVALID_EVENTS_NUMBER = '4013';
    String ERROR_CODE_INVALID_HOWDIDYOUHEAR_LENGTH = '4014';
    String ERROR_CODE_INVALID_STATE = '4015';
    String ERROR_CODE_INVALID_COUNTRY = '4016';
    String EMAIL_REGEX = '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$';
    String PHONE_REGEX = '^[^a-zA-Z]*$';
    Map<String, Boolean> validStateCodes = new Map<String, Boolean>{
      'AL' => true,
      'AK' => true,
      'AZ' => true,
      'AR' => true,
      'CA' => true,
      'CO' => true,
      'CT' => true,
      'DE' => true,
      'FL' => true,
      'GA' => true,
      'HI' => true,
      'ID' => true,
      'IL' => true,
      'IN' => true,
      'IA' => true,
      'KS' => true,
      'KY' => true,
      'LA' => true,
      'ME' => true,
      'MD' => true,
      'MA' => true,
      'MI' => true,
      'MN' => true,
      'MS' => true,
      'MO' => true,
      'MT' => true,
      'NE' => true,
      'NV' => true,
      'NH' => true,
      'NJ' => true,
      'NM' => true,
      'NY' => true,
      'NC' => true,
      'ND' => true,
      'OH' => true,
      'OK' => true,
      'OR' => true,
      'PA' => true,
      'RI' => true,
      'SC' => true,
      'SD' => true,
      'TN' => true,
      'TX' => true,
      'UT' => true,
      'VT' => true,
      'VA' => true,
      'WA' => true,
      'WV' => true,
      'WI' => true,
      'WY' => true
    };
    Map<String, Boolean> validStateCodesCA = new Map<String, Boolean>{
      'AB' => true, // Alberta
      'BC' => true, // British Columbia
      'MB' => true, // Manitoba
      'NB' => true, // New Brunswick
      'NL' => true, // Newfoundland and Labrador
      'NS' => true, // Nova Scotia
      'NT' => true, // Northwest Territories
      'NU' => true, // Nunavut
      'ON' => true, // Ontario
      'PE' => true, // Prince Edward Island
      'QC' => true, // Quebec
      'SK' => true, // Saskatchewan
      'YT' => true // Yukon
    };

    Schema.DescribeSObjectResult leadSchema = Lead.sObjectType.getDescribe();
    Map<String, Schema.SObjectField> fieldMap = leadSchema.fields.getMap();
    List<Schema.PicklistEntry> fld = fieldMap.get('Event_Name__c')
      .getDescribe()
      .getPicklistValues();

    List<String> validEvents = new List<String>();
    for (Schema.PicklistEntry pl : fld) {
      validEvents.add(pl.getValue());
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
    if (flag == 'Supplier') {
      if (title == null || String.isBlank(title)) {
        return ERROR_CODE_INVALID_TITLE;
      }
    }
    if (String.isBlank(ASI) || ASI == null) {
      return ERROR_CODE_INVALID_ASI;
    }
    if (title.length() > 128) {
      return ERROR_CODE_INVALID_TITLE_LENGTH;
    }
    if (ASI.length() > 10) {
      return ERROR_CODE_INVALID_ASI;
    }
    if (phone != null && !String.isBlank(phone)) {
      if (!Pattern.matches(PHONE_REGEX, phone)) {
        return ERROR_CODE_INVALID_PHONE;
      }
    } else {
      return ERROR_CODE_INVALID_PHONE;
    }
    if (
      String.isBlank(street) ||
      String.isBlank(city) ||
      String.isBlank(state) ||
      String.isBlank(zipCode) ||
      street == null ||
      city == null ||
      state == null ||
      zipCode == null
    ) {
      return ERROR_CODE_INVALID_ADDRESS;
    }

    // Check if the state code is valid
    if (Country.toLowerCase() == 'ca') {
      if (!validStateCodesCA.containsKey(state.toUpperCase())) {
        return ERROR_CODE_INVALID_STATE;
      }
    } else if (Country.toLowerCase() == 'us') {
      if (!validStateCodes.containsKey(state.toUpperCase())) {
        return ERROR_CODE_INVALID_STATE;
      }
    } else {
      return ERROR_CODE_INVALID_COUNTRY;
    }

    if (!('Supplier'.equals(flag) || 'Distributor'.equals(flag))) {
      return ERROR_CODE_INVALID_FLAG;
    }

    if (Events == null || Events.isEmpty()) {
      return ERROR_CODE_EMPTY_EVENTS;
    }
    if (Events.size() > 5) {
      return ERROR_CODE_INVALID_EVENTS_NUMBER;
    }
    for (String event : Events) {
      if (!validEvents.contains(event)) {
        return ERROR_CODE_INVALID_EVENTS;
      }
    }
    if (HowDidYouHear.length() > 254) {
      return ERROR_CODE_INVALID_HOWDIDYOUHEAR_LENGTH;
    }
    return SUCCESS_CODE;
  }
}
