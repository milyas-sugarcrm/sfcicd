@isTest
private class SowPandaDocHandlerTest {
  private class MockHttpResponse implements HttpCalloutMock {
    private Integer statusCode;
    private String status;
    private String responseBody;

    public MockHttpResponse(
      Integer statusCode,
      String status,
      String responseBody
    ) {
      this.statusCode = statusCode;
      this.status = status;
      this.responseBody = responseBody;
    }

    public HTTPResponse respond(HttpRequest req) {
      HTTPResponse res = new HTTPResponse();
      res.setStatusCode(statusCode);
      res.setStatus(status);
      res.setBody(responseBody);
      return res;
    }
  }

  @isTest
  static void testGetOpportunityDetails() {
    Test.startTest();
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today()
    );
    insert opp;

    Opportunity actualOpp = SowPandaDocHandler.getOpportunityDetails(opp.Id);
    Assert.areEqual(opp.Id, actualOpp.Id, 'Opportunity Ids should be equal');

    Opportunity actualOpp1 = SowPandaDocHandler.getOpportunityDetails('');
    Assert.isNull(
      actualOpp1.Id,
      'Opportunity is not retrieved as passed empty id.'
    );

    Test.stopTest();
  }

  @isTest
  static void testInitialProcessingOffOppSow() {
    Test.startTest();

    // Create Opportunity
    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today()
    );
    insert opp;

    // Create ContentVersion record
    ContentVersion content = new ContentVersion();
    content.Title = 'Test File';
    content.PathOnClient = 'test.pdf';
    content.VersionData = Blob.valueOf('File content goes here');
    content.IsMajorVersion = true;
    content.ContentLocation = 'S';

    insert content;

    String contentDocumentId = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :content.Id
    ]
    .ContentDocumentId;

    // Create ContentDocumentLink to link the ContentVersion with the Account
    ContentDocumentLink link = new ContentDocumentLink();
    link.ContentDocumentId = contentDocumentId;
    link.LinkedEntityId = opp.Id;
    link.ShareType = 'V';
    link.Visibility = 'AllUsers';
    insert link;

    String fileId = contentDocumentId;
    String orgFileName = 'testfile345.pdf';
    String oppId = opp.Id;
    String oldAwsFileNameToDelete = 'oldtestfile345.pdf';

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        201,
        'Created',
        '{"id": "msFYActMfJHqNTKH8YSvF1", "status": "document.uploaded"}'
      )
    );

    SowPandaDocHandler.initialProcessingOffOppSow(
      '',
      orgFileName,
      oppId,
      oldAwsFileNameToDelete
    );

    SowPandaDocHandler.initialProcessingOffOppSow(
      fileId,
      orgFileName,
      oppId,
      oldAwsFileNameToDelete
    );

    Test.stopTest();
  }

  @isTest
  static void testSendSowProcess() {
    Test.startTest();
    String pandaDocId = 'pandadocid';
    String awsFileName = 'testfile123.pdf';
    String oppId = 'testopp980';

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        201,
        'Created',
        '{"id": "msFYActMfJHqNTKH8YSvF1", "status": "document.uploaded"}'
      )
    );

    Assert.areEqual(
      false,
      SowPandaDocHandler.sendSowProcess('', oppId, awsFileName),
      'Should be false as PandaDoc Id is empty.'
    );
    Assert.areEqual(
      false,
      SowPandaDocHandler.sendSowProcess(pandaDocId, '', awsFileName),
      'Should be false as opp Id is empty.'
    );

    SowPandaDocHandler.sendSowProcess(pandaDocId, oppId, awsFileName);

    Test.stopTest();
  }

  @isTest
  static void testPostProcessingOfPutFileInS3FromObject() {
    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        201,
        'Created',
        '{"id": "msFYActMfJHqNTKH8YSvF1", "status": "document.uploaded"}'
      )
    );

    Opportunity opp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today(),
      Signor_Email_PFA__c = '',
      Signor_Name_PFA__c = ''
    );
    insert opp;

    String orgFileName = 'testFile.pdf';
    String awsFileName = 'testFile' + opp.Id + '.pdf';
    String awsFileURL = SowAwsS3Handler.getAwsFileURL(awsFileName);
    String oppId = opp.Id;

    SowPandaDocHandler.postProcessingOfPutFileInS3FromObject(
      orgFileName,
      awsFileName,
      awsFileURL,
      opp.Id
    );

    Opportunity oppRetrieve = [
      SELECT Id, StageName, Panda_Doc_Id__c, Aws_File_Name__c
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    Assert.isNull(
      oppRetrieve.Panda_Doc_Id__c,
      'Null as Signor_Email_PFA__c is blank.'
    );

    Test.stopTest();
  }

  @isTest
  static void testGetPandaDocProvider() {
    String provider = SowPandaDocHandler.getPandaDocProvider();
    if (SowPandaDocHandler.getInstanceName() == 'sandbox') {
      Assert.areEqual(
        SowPandaDocHandler.PROVIDER_SANDBOX,
        provider,
        'Provider should be Sandobx instance.'
      );
    } else {
      Assert.areEqual(
        SowPandaDocHandler.PROVIDER_PRODUCTION,
        provider,
        'Provider should be prodcution instance.'
      );
    }
  }

  @isTest
  static void testJsonParsePandaDocResponse() {
    String httpResponseBodyValid = '{"key1": "value1", "key2": "value2"}';
    Map<String, Object> expectedResult = new Map<String, Object>{
      'key1' => 'value1',
      'key2' => 'value2'
    };

    Map<String, Object> actualResult = SowPandaDocHandler.jsonParsePandaDocResponse(
      httpResponseBodyValid
    );
    Assert.areEqual(
      expectedResult,
      actualResult,
      'Parsed map should match expected result.'
    );

    String httpResponseBodyInvalid = ''; // or any other invalid JSON content
    Map<String, Object> actualResultInvalid = SowPandaDocHandler.jsonParsePandaDocResponse(
      httpResponseBodyInvalid
    );
    Map<String, Object> emptyMap = new Map<String, Object>();
    Assert.areEqual(
      emptyMap,
      actualResultInvalid,
      'Returned map should be empty for invalid JSON or blank response.'
    );
  }

  @isTest
  static void testCreateDocumentInPandaDoc() {
    Map<String, Object> recipient = new Map<String, Object>{
      'first_name' => 'Test',
      'last_name' => 'PandaDoc',
      'email' => 'test@example.com'
    };
    String fileName = 'testFile.pdf';
    String awsFileURL = SowAwsS3Handler.getAwsFileURL(fileName);

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        201,
        'Created',
        '{"id": "msFYActMfJHqNTKH8YSvF1", "status": "document.uploaded"}'
      )
    );

    Assert.areEqual(
      '',
      SowPandaDocHandler.createDocumentInPandaDoc('', awsFileURL, recipient),
      'Response should be empty as passed FileName is empty.'
    );

    Assert.areEqual(
      '',
      SowPandaDocHandler.createDocumentInPandaDoc(fileName, '', recipient),
      'Response should be empty as passed recipiawsFileURLent is empty.'
    );

    Assert.areEqual(
      '',
      SowPandaDocHandler.createDocumentInPandaDoc(fileName, awsFileURL, null),
      'Response should be empty as passed recipient is empty.'
    );

    String createdPandaDocId = SowPandaDocHandler.createDocumentInPandaDoc(
      fileName,
      awsFileURL,
      recipient
    );
    Assert.areNotEqual(
      '',
      createdPandaDocId,
      'Panda Doc Id should not be empty.'
    );

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(400, 'Created Error', '')
    );

    String createdPandaDocId2 = SowPandaDocHandler.createDocumentInPandaDoc(
      fileName,
      awsFileURL,
      recipient
    );
    Assert.areEqual(
      '',
      createdPandaDocId2,
      'Panda Doc Id should be empty as not success on panda doc server.'
    );

    Test.stopTest();
  }

  @isTest
  static void testSendDocumentToRecipients() {
    String pandaDocId = 'msFYActMfJHqNTKH8YSvF1';

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        200,
        'Created',
        '{"id": "msFYActMfJHqNTKH8YSvF1", "status": "document.sent"}'
      )
    );

    // Success Response
    System.assertEquals(
      '',
      SowPandaDocHandler.sendDocumentToRecipients(''),
      'Responsed pandaDocId should be empty as passed pandaDoc Id is empty.'
    );

    Assert.areNotEqual(
      '',
      SowPandaDocHandler.sendDocumentToRecipients(pandaDocId),
      'Panda Doc Id should not be empty.'
    );

    // Failure Response
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        400,
        'Created Error',
        '{"info_message": "Document creation failed"}'
      )
    );

    System.assertEquals(
      '',
      SowPandaDocHandler.sendDocumentToRecipients(''),
      'Responsed pandaDocId should be empty as passed pandaDoc Id is empty.'
    );

    Assert.areEqual(
      '',
      SowPandaDocHandler.sendDocumentToRecipients(pandaDocId),
      'Panda Doc Id should be empty as not success on panda doc server.'
    );

    Test.stopTest();
  }

  @isTest
  static void testLinkDocumentToObject() {
    String pandaDocId = 'msFYActMfJHqNTKH8YSvF1';
    String oppId = 'testOppId';

    Test.startTest();
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(
        200,
        'Created',
        '{"id": "abb4d3fc-919b-491e-9e08-775036660c0b"}'
      )
    );

    // Success Response
    System.assertEquals(
      '',
      SowPandaDocHandler.linkDocumentToObject('', oppId),
      'Responsed plinked andaDocId should be empty as passed pandaDocId is empty.'
    );

    System.assertEquals(
      '',
      SowPandaDocHandler.linkDocumentToObject(pandaDocId, ''),
      'Responsed plinked andaDocId should be empty as passed oppId is empty.'
    );

    System.assertEquals(
      '',
      SowPandaDocHandler.linkDocumentToObject('', ''),
      'Responsed linked andaDocId should be empty as passed pandaDocId and oppId are empty.'
    );

    Assert.areNotEqual(
      '',
      SowPandaDocHandler.linkDocumentToObject(pandaDocId, oppId),
      'Responsed panda doc id should not empty.'
    );

    // Failure Response
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(400, 'Linked Error', '{"type": "request_error"}')
    );

    System.assertEquals(
      '',
      SowPandaDocHandler.linkDocumentToObject(pandaDocId, oppId),
      'Responsed linked andaDocId should be empty as not success on panda doc server.'
    );

    Test.stopTest();
  }
}
