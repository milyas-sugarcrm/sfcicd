public class SowAwsS3Handler {
  public static final String CALLOUT_URL = 'callout:AWS_Named';
  public static final String S3_BUCKET = 'phun-for-all-salesforce';
  public static final String S3_BUCKET_FOLDER = 'pandadoc';

  /*
   * Return the Content type against the file type
   * for API call AWS server
   */
  public static string ContentType(string fileType) {
    switch on fileType.toLowerCase() {
      when 'docx' {
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      }
      when 'csv' {
        return 'application/vnd.ms-excel';
      }
      when 'wav' {
        return 'audio/wav';
      }
      when 'wmv' {
        return 'video/x-ms-wmv';
      }
      when 'mp3' {
        return 'audio/mpeg';
      }
      when 'mp4' {
        return 'video/mp4';
      }
      when 'png' {
        return 'image/png';
      }
      when 'pdf' {
        return 'application/pdf';
      }
      when else {
        return 'image/jpeg';
      }
    }
  }

  /*
   * Prepare the filename for the AWS
   */
  public static String prepareFileName(
    String title,
    String fileId,
    String fileExtension
  ) {
    if (
      String.isBlank(title) ||
      String.isBlank(fileId) ||
      String.isBlank(fileExtension)
    ) {
      return '';
    }

    return title.deleteWhitespace()
        .replaceAll('[^a-zA-Z0-9\\s+]', '-')
        .toLowerCase() +
      fileId +
      '.' +
      fileExtension.toLowerCase();
  }

  /*
   * Prepare and return the S3Callout end point
   * for Rest API call to AWS S3 services.
   */
  public static String getS3CallOutEndPoint(String filename) {
    List<String> urlString = new List<String>{
      SowAwsS3Handler.CALLOUT_URL,
      SowAwsS3Handler.S3_BUCKET,
      SowAwsS3Handler.S3_BUCKET_FOLDER,
      filename
    };
    return String.join(urlString, '/');
  }

  /*
   * Return the ContentVersion record against the
   * specified fileId
   */
  public static List<ContentVersion> getContentVersion(Id fileId) {
    return [
      SELECT VersionData, Title, ContentDocumentId, FileExtension
      FROM ContentVersion
      WHERE ContentDocumentId = :fileId AND IsLatest = TRUE
    ];
  }

  /*
   * Return the Aws File URL according to
   * the S3 bucket.
   */
  public static String getAwsFileURL(String awsFileName) {
    if (String.isBlank(awsFileName)) {
      return '';
    }
    return 'https://' +
      SowAwsS3Handler.S3_BUCKET +
      '.s3.amazonaws.com/' +
      SowAwsS3Handler.S3_BUCKET_FOLDER +
      '/' +
      awsFileName;
  }

  /*
   * Srote the file in AWS bucket and call
   * the PandaDoc function to create the document
   * in the pandadoc and update the fields in
   * Opportunity
   */
  @future(callout=true)
  public static void putFileInS3FromObject(
    String fileId,
    String orgFileName,
    String oppId
  ) {
    List<ContentVersion> versions = getContentVersion(fileId);

    if (versions.size() > 0) {
      String fileExtension = versions[0].FileExtension;
      String awsFileName = prepareFileName(
        versions[0].Title,
        versions[0].ContentDocumentId,
        fileExtension
      );
      if (String.isBlank(awsFileName)) {
        System.debug(
          'SowAwsS3Handler:putFileInS3FromObject -> File Name is empty.'
        );
        return;
      }

      String attachmentBody = EncodingUtil.base64Encode(
        versions[0].VersionData
      );
      String formattedDateString = Datetime.now()
        .formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
      String contentType = ContentType(fileExtension);
      String endpoint = getS3CallOutEndPoint(awsFileName);

      HttpRequest req = new HttpRequest();
      req.setMethod('PUT');
      req.setEndpoint(endpoint);
      req.setHeader('Content-Encoding', 'UTF-8');
      req.setHeader('Content-type', contentType);
      req.setHeader('Connection', 'keep-alive');
      req.setHeader('Date', formattedDateString);
      req.setHeader('ACL', 'public-read');
      Blob pdfBlob = EncodingUtil.base64Decode(attachmentBody);
      req.setBodyAsBlob(pdfBlob);
      Http http = new Http();

      try {
        HTTPResponse res = http.send(req);
        if (res.getStatusCode() == 201 || res.getStatusCode() == 200) {
          System.debug(
            'SowAwsS3Handler:putFileInS3FromObject -> Success, File is upload successfully to S3.'
          );
          String awsFileURL = getAwsFileURL(awsFileName);

          System.debug(
            'SowAwsS3Handler:putFileInS3FromObject -> SowPandaDocHandler.postProcessingOfPutFileInS3FromObject call started.'
          );
          SowPandaDocHandler.postProcessingOfPutFileInS3FromObject(
            orgFileName,
            awsFileName,
            awsFileURL,
            oppId
          );
        } else {
          System.debug(
            'SowAwsS3Handler:putFileInS3FromObject -> Error: Status code: ' +
              res.getStatusCode() +
              ': ' +
              res.getBody()
          );
        }
      } catch (CalloutException ex) {
        system.debug(
          'SowAwsS3Handler:putFileInS3FromObject -> CallOutException: ' +
            ex.getMessage() +
            ' : Cause : ' +
            ex.getCause()
        );
      } catch (Exception ex) {
        system.debug(
          'SowAwsS3Handler:putFileInS3FromObject -> General Exception: ' +
            ex.getMessage() +
            ' : Cause : ' +
            ex.getCause()
        );
      }
    }
  }

  /*
   * Delete the given file from AWS bucket
   */
  @future(callout=true)
  public static void deleteFileInS3(String awsFileName) {
    if (String.isBlank(awsFileName)) {
      System.debug(
        'SowAwsS3Handler:deleteFileInS3 -> awsFileName is empty. So we cannot remove the file from S3'
      );
      return;
    }

    HttpRequest req = new HttpRequest();
    req.setMethod('DELETE');
    req.setEndpoint(getS3CallOutEndPoint(awsFileName));
    Http http = new Http();

    try {
      HTTPResponse res = http.send(req);
      if (res.getStatusCode() == 204) {
        System.debug(
          'SowAwsS3Handler:deleteFileInS3 -> Success, File' +
            awsFileName +
            ' is deleted successfully from S3.'
        );
      } else {
        System.debug(
          'SowAwsS3Handler:deleteFileInS3 -> Error: Status code: ' +
            res.getStatusCode() +
            ': ' +
            res.getBody() +
            ': FileName : ' +
            awsFileName
        );
      }
    } catch (CalloutException ex) {
      system.debug(
        'SowAwsS3Handler:deleteFileInS3 -> CallOutException: ' +
          ex.getMessage() +
          ' : Cause : ' +
          ex.getCause()
      );
    } catch (Exception ex) {
      system.debug(
        'SowAwsS3Handler:deleteFileInS3 -> General Exception: ' +
          ex.getMessage() +
          ' : Cause : ' +
          ex.getCause()
      );
    }
  }
}
