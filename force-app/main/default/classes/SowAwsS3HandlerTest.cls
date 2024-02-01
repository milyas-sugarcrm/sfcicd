@isTest
private class SowAwsS3HandlerTest {
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
  static void testContentType() {
    Assert.areEqual(
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      SowAwsS3Handler.ContentType('docx'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'application/pdf',
      SowAwsS3Handler.ContentType('pdf'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'image/jpeg',
      SowAwsS3Handler.ContentType('image12'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'application/vnd.ms-excel',
      SowAwsS3Handler.ContentType('csv'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'audio/wav',
      SowAwsS3Handler.ContentType('wav'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'video/x-ms-wmv',
      SowAwsS3Handler.ContentType('wmv'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'audio/mpeg',
      SowAwsS3Handler.ContentType('mp3'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'video/mp4',
      SowAwsS3Handler.ContentType('mp4'),
      'ContentType should match.'
    );
    Assert.areEqual(
      'image/png',
      SowAwsS3Handler.ContentType('png'),
      'ContentType should match.'
    );
  }

  @isTest
  static void testPrepareFileName() {
    // Test when inputs are valid
    String title = 'Test Title';
    String fileId = '123';
    String fileExtension = 'pdf';
    String expectedFileName = 'testtitle123.pdf';
    Assert.areEqual(
      expectedFileName,
      SowAwsS3Handler.prepareFileName(title, fileId, fileExtension),
      'FileName should match.'
    );

    // Test when inputs are blank
    Assert.areEqual(
      '',
      SowAwsS3Handler.prepareFileName('', '', ''),
      'FileName should be blank'
    );
    Assert.areEqual(
      '',
      SowAwsS3Handler.prepareFileName('', '1122', ''),
      'FileName should be blank'
    );
    Assert.areEqual(
      '',
      SowAwsS3Handler.prepareFileName('', '', 'pdf'),
      'FileName should be blank'
    );
    Assert.areEqual(
      '',
      SowAwsS3Handler.prepareFileName('Test', '', 'pdf'),
      'FileName should be blank'
    );
  }

  @isTest
  static void testGetAwsFileURL() {
    String awsFileName = 'testtitle123.pdf';
    String expectedAwsFileURL =
      'https://' +
      SowAwsS3Handler.S3_BUCKET +
      '.s3.amazonaws.com/' +
      SowAwsS3Handler.S3_BUCKET_FOLDER +
      '/' +
      awsFileName;

    Assert.areEqual(
      expectedAwsFileURL,
      SowAwsS3Handler.getAwsFileURL(awsFileName),
      'File Urls should match.'
    );

    Assert.areEqual(
      '',
      SowAwsS3Handler.getAwsFileURL(''),
      'File Urls should match.'
    );
  }

  @isTest
  static void testGetS3CallOutEndPoint() {
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

    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(201, 'Created', 'Mock Response')
    );

    try {
      SowAwsS3Handler.putFileInS3FromObject(
        contentDocumentId,
        content.Title,
        opp.Id
      );
      List<ContentVersion> versions = SowAwsS3Handler.getContentVersion(
        contentDocumentId
      );

      String actualAwsFileName = '';
      String expectedAwsFileName = '';
      String actualAwsFileURL = '';
      String expectedAwsFileURL = '';

      if (versions.size() > 0) {
        actualAwsFileName = SowAwsS3Handler.prepareFileName(
          versions[0].Title,
          versions[0].ContentDocumentId,
          versions[0].FileExtension
        );
        expectedAwsFileName = 'testfile' + contentDocumentId + '.pdf';

        actualAwsFileURL = SowAwsS3Handler.getAwsFileURL(actualAwsFileName);
        expectedAwsFileURL =
          'https://' +
          SowAwsS3Handler.S3_BUCKET +
          '.s3.amazonaws.com/' +
          SowAwsS3Handler.S3_BUCKET_FOLDER +
          '/' +
          actualAwsFileName;
      }

      Assert.areEqual(
        expectedAwsFileName,
        actualAwsFileName,
        'Aws File Name should match'
      );
      Assert.areEqual(
        expectedAwsFileURL,
        actualAwsFileURL,
        'Aws File URL should match'
      );
    } catch (Exception e) {
      System.debug('Exception caught: ' + e.getMessage());
    }

    Test.stopTest();
  }

  @isTest
  static void testDeleteFileInS3() {
    // Set the Success Response
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponse(204, 'Deleted', 'Mock Response')
    );

    Test.startTest();
    try {
      SowAwsS3Handler.deleteFileInS3('testfile123.pdf');
      SowAwsS3Handler.deleteFileInS3('');
    } catch (Exception e) {
      System.debug('Exception caught: ' + e.getMessage());
    }

    Test.stopTest();
  }
}
