public class SowPandaDocHandler {
  public static final String MAIN_END_POINT = 'https://api.pandadoc.com/public/v1/documents';
  public static final String PROVIDER_SANDBOX = 'salesforce-oauth2-sandbox';
  public static final String PROVIDER_PRODUCTION = 'salesforce-oauth2';
  public static final String ENTITY_TYPE = 'opportunity';

  /*
   * Return the instance name either
   * Productio or Sandbox
   */
  public static String getInstanceName() {
    Organization orgInfo = [
      SELECT Id, InstanceName, IsSandbox, Name, OrganizationType
      FROM Organization
    ];
    return (orgInfo.IsSandbox == true) ? 'Sandbox' : 'Production';
  }

  /*
   * Return the API key from the custom metadata
   */
  public static String getApiKey() {
    String instanceName = getInstanceName();

    Panda_Docs__mdt pandaDocConfig = [
      SELECT Api_Key__c
      FROM Panda_Docs__mdt
      WHERE DeveloperName = :instanceName
      LIMIT 1
    ];

    return (pandaDocConfig != null) ? pandaDocConfig.Api_Key__c : '';
  }

  /*
   * Called from genenrate SOW button and check
   * pre-requisites and call the helper function
   */
  public static void initialProcessingOffOppSow(
    String fileId,
    String orgFileName,
    String oppId,
    String oldAwsFileNameToDelete
  ) {
    System.debug('In SowPandaDocHandler.initialProcessingOffOppSow');
    if (
      String.isBlank(orgFileName) ||
      String.isBlank(fileId) ||
      String.isBlank(oppId)
    ) {
      System.debug(
        'SowPandaDocHandler:initialProcessingOffOppSow -> PreRequisiteError: filName, oppId or fileId is empty.'
      );
      return;
    }

    if (String.isNotBlank(oldAwsFileNameToDelete)) {
      SowAwsS3Handler.deleteFileInS3(oldAwsFileNameToDelete);
    }
    SowAwsS3Handler.putFileInS3FromObject(fileId, orgFileName, oppId);
    System.debug('Out SowPandaDocHandler.initialProcessingOffOppSow');
  }

  /*
   * Called onces a Document is created in AWS
   * (SowAwsS3Handler.putFileInS3FromObject)
   * on Generate SOW button click and here PandaDoc
   * Document is created in Pandadoc server with recipient
   * and then update the opportunity with AWS file and PandaDod
   * Id.
   */
  public static void postProcessingOfPutFileInS3FromObject(
    String orgFileName,
    String awsFileName,
    String awsFileURL,
    String oppId
  ) {
    System.debug('In SowPandaDocHandler.postProcessingOfPutFileInS3FromObject');
    if (String.isBlank(awsFileURL) || String.isBlank(oppId)) {
      System.debug(
        'SowPandaDocHandler:postProcessingOfPutFileInS3FromObject -> AWSS3ProcessingError: awsFileURL or oppId is empty. So there is some error on uploading file to S3.'
      );
      return;
    }

    Opportunity opp = [
      SELECT
        Id,
        Signor_Email_PFA__c,
        Signor_Name_PFA__c,
        Panda_Doc_Id__c,
        Aws_File_Name__c
      FROM Opportunity
      WHERE id = :oppId
      LIMIT 1
    ];

    if (opp == null) {
      System.debug(
        'SowPandaDocHandler:postProcessingOfPutFileInS3FromObject -> Opportunity is empty.'
      );
      return;
    }

    if (String.isBlank(opp.Signor_Email_PFA__c)) {
      System.debug(
        'SowPandaDocHandler:postProcessingOfPutFileInS3FromObject -> Signor_Email_PFA__c is empty.'
      );
      return;
    }

    Map<String, Object> recipient = new Map<String, Object>{
      'first_name' => opp.Signor_Name_PFA__c,
      'last_name' => '',
      'email' => opp.Signor_Email_PFA__c
    };

    String createdPandaDocId = createDocumentInPandaDoc(
      orgFileName,
      awsFileURL,
      recipient
    );
    if (String.isNotBlank(createdPandaDocId)) {
      System.debug(
        'SowPandaDocHandler:postProcessingOfPutFileInS3FromObject -> PandaDocCreateSuccess: Doc successfully created in PandaDoc and ID is ' +
        createdPandaDocId
      );

      opp.Panda_Doc_Id__c = createdPandaDocId;
      opp.Aws_File_Name__c = awsFileName;
      update opp;
    }
    System.debug(
      'Out SowPandaDocHandler.postProcessingOfPutFileInS3FromObject'
    );
  }

  /*
   * Return the necessary information of
   * Opportunity to the Aura Component that
   * is used on the Send SOW button on Opportunity
   * detail view. This information is futher used
   * to process send SOW.
   */
  @AuraEnabled
  public static Opportunity getOpportunityDetails(String oppId) {
    if (String.isBlank(oppId)) {
      return new Opportunity();
    }

    return [
      SELECT Id, StageName, Panda_Doc_Id__c, Aws_File_Name__c
      FROM Opportunity
      WHERE Id = :oppId
    ];
  }

  /*
   * Send the SOW to the recipient and this
   * process is called from the Send SOW button
   * on Opportunity detail view.
   */
  @AuraEnabled
  public static boolean sendSowProcess(
    String pandaDocId,
    String oppId,
    String awsFileName
  ) {
    boolean success = false;
    System.debug('In SowPandaDocHandler.sendSowProcess');
    if (String.isBlank(pandaDocId) || String.isBlank(oppId)) {
      System.debug(
        'SowPandaDocHandler:sendSowProcess -> pandaDocId or oppId is empty.'
      );
      return success;
    }

    String linkRecordID = linkDocumentToObject(pandaDocId, oppId);
    if (String.isNotBlank(linkRecordID)) {
      System.debug(
        'SowPandaDocHandler:sendSowProcess -> PandaDocLinkSuccess: Doc successfully Linked with ' +
        oppId
      );
    }

    String sentPandaDocId = sendDocumentToRecipients(pandaDocId);
    if (String.isNotBlank(sentPandaDocId)) {
      System.debug(
        'SowPandaDocHandler:sendSowProcess -> PandaDocSentSuccess: Doc successfully Sent to recipients in PandaDoc and ID is ' +
        sentPandaDocId
      );

      success = true;

      SowAwsS3Handler.deleteFileInS3(awsFileName);
    }

    System.debug('Out SowPandaDocHandler.sendSowProcess');
    return success;
  }

  /*
   * Return the Provider for the PandaDoc
   * Rest API endpoints to have connection
   * between the documents and SF objects
   */
  public static String getPandaDocProvider() {
    return (getInstanceName() == 'Sandbox')
      ? SowPandaDocHandler.PROVIDER_SANDBOX
      : SowPandaDocHandler.PROVIDER_PRODUCTION;
  }

  /*
   * Create the Document in pandadoc
   */
  public static String createDocumentInPandaDoc(
    String fileName,
    String awsFileURL,
    Map<String, Object> recipient
  ) {
    System.debug('In SowPandaDocHandler.createDocumentInPandaDoc');
    if (
      String.isBlank(fileName) ||
      String.isBlank(awsFileURL) ||
      recipient == null ||
      recipient.isEmpty()
    ) {
      System.debug(
        'SowPandaDocHandler:createDocumentInPandaDoc -> PreRequisiteError: filName, awsFileURL or recipients is empty.'
      );
      return '';
    }

    String jsonBody =
      '{' +
      '"name":"' +
      fileName +
      '",' +
      '"url":"' +
      awsFileURL +
      '",' +
      '"recipients": [' +
      '{' +
      '"email":"' +
      recipient.get('email') +
      '",' +
      '"first_name":"' +
      recipient.get('first_name') +
      '",' +
      '"last_name":"' +
      recipient.get('last_name') +
      '",' +
      '"role": "client",' +
      '"signing_order": "1"' +
      '}' +
      '],' +
      '"parse_form_fields": false' +
      '}';

    String httpResponseBody = pandaDocApiCall(
      'POST',
      SowPandaDocHandler.MAIN_END_POINT,
      jsonBody,
      true
    );
    Map<String, Object> responseBodyMap = jsonParsePandaDocResponse(
      httpResponseBody
    );
    System.debug('Out SowPandaDocHandler.createDocumentInPandaDoc');
    return ((String) responseBodyMap.get('status') == 'document.uploaded')
      ? (String) responseBodyMap.get('id')
      : '';
  }

  /*
   * Send the Panda Document to Recipients
   */
  public static String sendDocumentToRecipients(String pandaDocId) {
    System.debug('In SowPandaDocHandler.sendDocumentToRecipients');
    if (String.isBlank(pandaDocId)) {
      System.debug(
        'SowPandaDocHandler:sendDocumentToRecipients -> Error: pandaDocId is empty.'
      );
      return '';
    }

    String endpoint =
      SowPandaDocHandler.MAIN_END_POINT +
      '/' +
      pandaDocId +
      '/send';
    String httpResponseBody = pandaDocApiCall('POST', endpoint, '', false);

    Map<String, Object> responseBodyMap = jsonParsePandaDocResponse(
      httpResponseBody
    );
    System.debug('Out SowPandaDocHandler.sendDocumentToRecipients');
    return ((String) responseBodyMap.get('status') == 'document.sent')
      ? (String) responseBodyMap.get('id')
      : '';
  }

  /*
   * Link the Panda Document to the Opportunity Id
   */
  public static String linkDocumentToObject(String pandaDocId, String oppId) {
    System.debug('In SowPandaDocHandler.linkDocumentToObject');
    if (String.isBlank(pandaDocId) || String.isBlank(oppId)) {
      System.debug(
        'SowPandaDocHandler:linkDocumentToObject -> PreRequisiteError: pandaDocId or oppId is empty.'
      );
      return '';
    }

    String endpoint =
      SowPandaDocHandler.MAIN_END_POINT +
      '/' +
      pandaDocId +
      '/linked-objects';
    String jsonBody =
      '{' +
      '"provider":"' +
      getPandaDocProvider() +
      '",' +
      '"entity_type":"' +
      SowPandaDocHandler.ENTITY_TYPE +
      '",' +
      '"entity_id":"' +
      oppId +
      '"' +
      '}';

    String httpResponseBody = pandaDocApiCall('POST', endpoint, jsonBody, true);
    Map<String, Object> responseBodyMap = jsonParsePandaDocResponse(
      httpResponseBody
    );
    System.debug('Out SowPandaDocHandler.linkDocumentToObject');
    String returnedLinkedPandaDocId = (String) responseBodyMap.get('id');
    return String.isBlank(returnedLinkedPandaDocId)
      ? ''
      : returnedLinkedPandaDocId;
  }

  /*
   * Parse the http response body
   */
  public static Map<String, Object> jsonParsePandaDocResponse(
    String httpResponseBody
  ) {
    Map<String, Object> responseMap = new Map<String, Object>();
    if (String.isNotBlank(httpResponseBody)) {
      try {
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(
          httpResponseBody
        );
      } catch (Exception ex) {
        system.debug(
          'SowPandaDocHandler:jsonParsePandaDocResponse -> Exception: ' +
            ex.getMessage() +
            ' : Cause : ' +
            ex.getCause()
        );
      }
    }

    return responseMap;
  }

  /*
   * Call the PandaDoc Rest End points
   */
  public static String pandaDocApiCall(
    String method,
    String endPoint,
    String jsonBody,
    Boolean setBody
  ) {
    System.debug('In SowPandaDocHandler.pandaDocApiCall');
    if (String.isBlank(method) || String.isBlank(endPoint)) {
      System.debug(
        'SowPandaDocHandler:pandaDocApiCall -> PreRequisiteError: method or endPoint is empty.'
      );
      return '';
    }

    HttpRequest req = new HttpRequest();
    req.setEndpoint(endPoint);
    req.setMethod(method);
    req.setHeader('Authorization', 'API-Key ' + getApiKey());
    req.setHeader('Content-Type', 'application/json');

    if (setBody && !String.isBlank(jsonBody)) {
      req.setBody(jsonBody);
    }

    // Create an HTTP object and send the request
    Http http = new Http();
    String responseBody = '';

    try {
      HttpResponse res = http.send(req);

      // Handle the response
      if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
        // Successful response handling
        responseBody = res.getBody();
        System.debug(
          'SowPandaDocHandler:pandaDocApiCall -> Success: ' + res.getBody()
        );
      } else {
        // Handle error cases
        System.debug(
          'SowPandaDocHandler:pandaDocApiCall -> Error: Status code: ' +
            res.getStatusCode() +
            ': ' +
            res.getBody()
        );
      }
    } catch (Exception ex) {
      System.debug(
        'SowPandaDocHandler:pandaDocApiCall -> Exception: ' +
          ex.getMessage() +
          ' : Cause : ' +
          ex.getCause()
      );
    }

    return responseBody;
  }
}
