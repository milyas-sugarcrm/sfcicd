@RestResource(urlMapping='/Lead/*')
global with sharing class GoogleFormToLead {
  // This method is the entry point for the REST service and is invoked when a POST request is made.
  @HttpPost
  global static void doPost() {
    // Parse the incoming POST request
    RestRequest req = RestContext.request;
    String jsonString = req.requestBody.toString();
    List<GoogleFromToLeadParser> formResponses = parseFormData(jsonString);
    // Define the mapping between form questions and Salesforce fields
    List<QuestionFieldMapping> mappings = new List<QuestionFieldMapping>{
      new QuestionFieldMapping('email', 'email'),
      new QuestionFieldMapping(
        'What is your Name of Your Organization?',
        'Organization_Name_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is your Organization\'s Corporate Address?',
        'Organization_Address_PFA__c'
      ),
      new QuestionFieldMapping(
        'Who is the Signor for this Organization (First & Last)?',
        'Signor_Name_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the Title of the Signor?',
        'Signor_Title_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the Signor\'s Email Address?',
        'Signor_Email_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the legal company name and dba (if applicable)?',
        'Legal_Company_Name_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the legal billing address?',
        'Legal_Billing_Address_PFA__c'
      ),
      new QuestionFieldMapping(
        'Who is the accounts payable billing contact name (First & Last)?',
        'Billing_Contact_Name_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the accounts payable billing contact email?',
        'Billing_Contact_Email_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the accounts payable billing contact phone number?',
        'Billing_Contact_Phone_PFA__c'
      ),
      new QuestionFieldMapping(
        'What is the preferred payment method?',
        'Preferred_Payment_Method_PFA__c'
      ),
      new QuestionFieldMapping(
        'What product(s) or brand(s) are being promoted or sampled?',
        'Promoted_Sampled_Products_Brands__c'
      ),
      new QuestionFieldMapping(
        'What account/venue(s) are we scheduling events (demos, activations, trade shows, etc.) at?',
        'Scheduling_Events_Account_Venue_s__c'
      ),
      new QuestionFieldMapping(
        'Who is the campaign Point of Contact (POC)?',
        'Campaign_POC__c'
      ),
      new QuestionFieldMapping(
        'What is the campaign POC email?',
        'Campaign_POC_Email__c'
      ),
      new QuestionFieldMapping(
        'What is the estimated start date of this campaign',
        'Campaign_Start_Date__c'
      ),
      new QuestionFieldMapping(
        'What is the estimated end date of this campaign',
        'Campaign_End_Date__c'
      ),
      new QuestionFieldMapping(
        'Please include a brief product description including SKU\'s (max 3 SKU\'s) and any other relevant information (i.e. wet/dry, on/off premise, special instructions).',
        'Product_Description__c'
      ),
      new QuestionFieldMapping(
        'Who is responsible for scheduling with account(s)/venues(s)?',
        'Responsible_for_Scheduling__c'
      ),
      new QuestionFieldMapping(
        'Are there any specific requests for brand ambassador attire?',
        'BA_Attire__c'
      ),
      new QuestionFieldMapping(
        'Do you need Point of Sale (POS), print materials, promotional giveaways, branded apparel, or other displays (i.e. pullup banners, table covers, or sampling mats) for this campaign?',
        'Do_you_need_POS__c'
      ),
      new QuestionFieldMapping(
        'Phun for All will store and ship promotional materials, branded apparel, displays, and giveaway items on your behalf. Please include a summary of the materials we will receive, and advise what quantities should be sent out for each event.',
        'Summary_of_Materials__c'
      )
    };

    // Prepare the fields and values to update in the Lead record
    Map<String, Object> fieldsToUpdate = new Map<String, Object>{
      'New_Client_Form_Status__c' => 'Completed'
    };
    String email = '';
    for (GoogleFromToLeadParser response : formResponses) {
      for (QuestionFieldMapping mapping : mappings) {
        if (response.question == mapping.question) {
          System.debug('response.question: ' + response.question);
          System.debug('mapping.question: ' + mapping.question);
          String fieldName = mapping.fieldName;
          String fieldValue = response.answer;

          if (fieldName == 'email') {
            email = fieldValue;
          } else {
            fieldsToUpdate.put(fieldName, fieldValue);
          }

          break; // Break out of the loop as we found the matching mapping
        }
      }
    }

    // Update the Lead record in Salesforce
    updateLeadByEmail(email, fieldsToUpdate);
  }

  // Update the Lead record based on the email
  public static void updateLeadByEmail(
    String email,
    Map<String, Object> fieldsToUpdate
  ) {
    try {
      List<Lead> matchingLeads = [
        SELECT Id
        FROM Lead
        WHERE Email = :email
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];

      if (!matchingLeads.isEmpty()) {
        Lead leadToUpdate = matchingLeads[0];

        // Update the desired fields with the new values
        for (String fieldName : fieldsToUpdate.keySet()) {
          Object fieldValue = fieldsToUpdate.get(fieldName);
          System.debug(fieldName + ' => ' + fieldValue);

          // Handle Date fields separately
          if (fieldValue != '') {
            if (
              fieldName == 'Campaign_Start_Date__c' ||
              fieldName == 'Campaign_End_Date__c'
            ) {
              Date dateValue = Date.valueOf((String) fieldValue);
              leadToUpdate.put(fieldName, dateValue);
            } else {
              leadToUpdate.put(fieldName, fieldValue);
            }
          }
        }
        // Perform the update operation
        System.debug(leadToUpdate + ' => leadToUpdate');
        update leadToUpdate;
      } else {
        System.debug('No lead found with email: ' + email);
      }
    } catch (Exception ex) {
      System.debug('Error updating lead: ' + ex.getMessage());
    }
  }

  // Parse the JSON response from the Google Form
  public static List<GoogleFromToLeadParser> parseFormData(String jsonString) {
    List<GoogleFromToLeadParser> formResponses = new List<GoogleFromToLeadParser>();
    Map<String, String> jsonData = (Map<String, String>) JSON.deserialize(
      jsonString,
      Map<String, String>.class
    );
    String jsonArrayString = jsonData.get('json');
    List<Map<String, String>> jsonList = (List<Map<String, String>>) JSON.deserialize(
      jsonArrayString,
      List<Map<String, String>>.class
    );

    for (Map<String, String> jsonObject : jsonList) {
      for (String key : jsonObject.keySet()) {
        GoogleFromToLeadParser response = new GoogleFromToLeadParser();
        response.question = key;
        response.answer = jsonObject.get(key);
        formResponses.add(response);
      }
    }

    return formResponses;
  }
}
