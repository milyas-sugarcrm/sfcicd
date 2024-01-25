public class GoogleAPIMethods {
  /* 
*********************************************************
@Method Name    : getLatestAccessToken 
@author         : Sohaib Saqib
@description    : To get latest Access token that will be used in every API call. And to avoide querying again and again. 
@param          : void
@return         : Access Token
********************************************************
*/
  public static String getLatestAccessToken() {
    List<Google_Auth__c> authList = [
      SELECT Access_Token__c
      FROM Google_Auth__c
      WHERE Token_Name__c = 'Latest'
      LIMIT 1
    ];
    if (authList != null && !authList.isEmpty()) {
      Google_Auth__c auth = authList[0];
      if (auth.Access_Token__c != null) {
        return auth.Access_Token__c;
      }
    }
    return null;
  }

  /*
*********************************************************
@Method Name    : moveFolder 
@author         : Sohaib Saqib
@description    : Move folder from one location to other.
@param          : fileId to move which folder. folderId is the destination folder id.
@return         : Void
********************************************************
*/
  public static void moveFileOrFolder(
    String fileId,
    String folderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' +
        fileId +
        '?addParents=' +
        folderId
    );
    request.setMethod('PATCH');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    HttpResponse response = new Http().send(request);
  }

  /*
*********************************************************
@Method Name    : findFolder 
@author         : Sohaib Saqib
@description    : Find Folder by name in entire Google Drive.
@param          : Name 
@return         : return Id of folder
********************************************************
*/
  public static String findFolder(String folderName, String accessToken) {
    String encodedFolderName = EncodingUtil.urlEncode(folderName, 'UTF-8');
    String query = 'name="' + encodedFolderName + '"';

    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files?q=' +
        query +
        '&mimeType="application/vnd.google-apps.folder"'
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() == 200) {
      Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      List<Object> folders = (List<Object>) responseData.get('files');

      if (!folders.isEmpty()) {
        for (Object folder : folders) {
          String folderId2 = (String) ((Map<String, Object>) folder).get('id');
          return folderId2;
        }
      } else {
        return '404';
      }
    } else {
      return '001';
    }
    return '101';
  }

  /*
*********************************************************
@Method Name    : findSubFolder 
@author         : Sohaib Saqib
@description    : same as findFolder method but is restricted to find folder in a specific folder.
@param          : Name of foder and id of the parent Folder. 
@return         : return Id of folder
********************************************************
*/
  public static String findSubFolder(
    String folderName,
    String folderId,
    String accessToken
  ) {
    String encodedFolderName = folderName.replace(' ', '%20');
    String query =
      'name=\'' +
      encodedFolderName +
      '\' and mimeType=\'application/vnd.google-apps.folder\' and trashed=false';
    query += ' and \'' + folderId + '\' in parents';
    String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files?q=' + encodedQuery
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);

    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() == 200) {
      Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      List<Object> folders = (List<Object>) responseData.get('files');

      if (!folders.isEmpty()) {
        for (Object folder : folders) {
          String folderId2 = (String) ((Map<String, Object>) folder).get('id');
          return folderId2;
        }
      } else {
        return '404';
      }
    } else {
      return '001';
    }
    return '001';
  }

  public static void setAccessToPublicEdit(
    String folderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' + folderId + '/permissions'
    );
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    String requestBody = '{"role": "writer", "type": "anyone", "allowFileDiscovery": true}';
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);
  }

  public static void setAccessToDomainEdit(
    String folderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' + folderId + '/permissions'
    );
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    String requestBody = '{"role": "writer","type": "domain","domain": "teamphun.com", "allowFileDiscovery": false}';
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);
  }

  public static void setAccessToPublicViewOnly(
    String folderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' + folderId + '/permissions'
    );
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');
    String requestBody = '{"role": "reader","type": "anyone","allowFileDiscovery": true}';
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);
  }

  public static void setAccessToDomainViewOnly(
    String folderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' + folderId + '/permissions'
    );
    request.setMethod('POST');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');

    // Updated requestBody JSON to restrict view access to @teamphun.com domain
    String requestBody = '{"role": "reader","type": "domain","domain": "teamphun.com","allowFileDiscovery": false}';
    request.setBody(requestBody);
    HttpResponse response = new Http().send(request);
  }

  public static void DeleteFileOrFolder(String folderId, String accessToken) {
    if (folderId != null) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'https://www.googleapis.com/drive/v3/files/' + folderId
      );
      request.setMethod('DELETE');
      request.setHeader('Authorization', 'Bearer ' + accessToken);

      HttpResponse response = new Http().send(request);
      if (response.getStatusCode() == 204) {
        System.debug('Folder deleted successfully: ');
      } else {
        System.debug('Response status code: ' + response.getStatusCode());
        System.debug('Response body: ' + response.getBody());
      }
    }
  }

  public static boolean findFolderById(String folderId, String accessToken) {
    if (folderId == null || String.isBlank(folderId)) {
      return false;
    }
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' + folderId
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    HttpResponse response = new Http().send(request);

    if (response.getStatusCode() == 200) {
      return true;
    } else {
      return false;
    }
  }

  public static Datetime convertDateStringToDatetime(String dateString) {
    if (dateString != null) {
      // Convert the ISO 8601 date string to Apex Datetime format
      Datetime lastModifiedDate = Datetime.valueOf(dateString);
      return lastModifiedDate;
    } else {
      return null;
    }
  }

  public static String getLastModifiedDateAsString(
    String fileIdOrFolderId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' +
        fileIdOrFolderId +
        '?fields=modifiedTime'
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);

    HttpResponse response = new Http().send(request);

    if (response.getStatusCode() == 200) {
      Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      String lastModifiedDateStr = (String) responseData.get('modifiedTime');
      return lastModifiedDateStr;
    } else {
      return null;
    }
  }

  /*
*********************************************************
@Method Name    : MakeFolder 
@author         : Sohaib Saqib
@description    : Make folder inside other folder.
@param          : FOlder name and the Id of the parent folder. 
@return         : Id of newly created Folder
********************************************************
*/
  public static string MakeFolder(
    String ParentFolderID,
    String FolderName,
    String accessToken
  ) {
    String encodedFolderName = EncodingUtil.urlEncode(FolderName, 'UTF-8');
    encodedFolderName = encodedFolderName.replace('+', ' ');
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/json');
    header.put('Authorization', 'Bearer ' + accessToken);

    String requestBody =
      '{"name": "' +
      encodedFolderName +
      '","mimeType": "application/vnd.google-apps.folder"';
    requestBody += ',"parents": ["' + ParentFolderID + '"]';
    requestBody += '}';

    HttpRequest request = GoogleAuthHelper.prepareRequest(
      'https://www.googleapis.com/drive/v3/files',
      'POST',
      header,
      requestBody
    );
    HttpResponse response = GoogleAuthHelper.sendRequest(request);

    if (response.getStatusCode() == 200) {
      Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      String folderId = (String) responseData.get('id');
      return folderId;
    } else {
      return 'Error Making Folder';
    }
  }

  /*
*********************************************************
@Method Name    : generatePDF 
@author         : Sohaib Saqib
@description    : To get the link of the file that is uploaded
@param          : just provide the file Id to get it's link
@return         : Return Link in String Foam
********************************************************
*/
  public static String getGoogleDriveFileLink(
    String fileId,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      'https://www.googleapis.com/drive/v3/files/' +
        fileId +
        '?fields=webViewLink'
    );
    request.setMethod('GET');
    request.setHeader('Authorization', 'Bearer ' + accessToken);

    HttpResponse response = new Http().send(request);
    if (response.getStatusCode() == 200) {
      Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      String webViewLink = (String) responseData.get('webViewLink');
      return webViewLink;
    } else {
      return 'Failed to retrieve Google Drive file link.';
    }
  }

  /*
*********************************************************
@Method Name    : generatePDF 
@author         : Sohaib Saqib
@description    : To rename the file from Untilted to desired name.
@param          : fileId, and the FileName.
@return         : Return Link in String Foam
********************************************************
*/
  public static void renameFile(
    String fileId,
    String newFileName,
    String accessToken
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint('https://www.googleapis.com/drive/v3/files/' + fileId);
    request.setMethod('PATCH');
    request.setHeader('Authorization', 'Bearer ' + accessToken);
    request.setHeader('Content-Type', 'application/json');

    String body = '{"name": "' + newFileName + '"}';
    request.setBody(body);

    HttpResponse response = new Http().send(request);
  }

  public static String createFolder(
    String folderName,
    String parentFolderId,
    String accessToken
  ) {
    String folderId = null;

    if (folderName != null) {
      Map<String, String> header = new Map<String, String>();
      header.put('Content-Type', 'application/json');
      header.put('Authorization', 'Bearer ' + accessToken);

      String mimeType = 'application/vnd.google-apps.folder';

      String requestBody =
        '{"name": "' +
        folderName +
        '", "mimeType": "' +
        mimeType +
        '"';
      if (parentFolderId != null) {
        requestBody += ', "parents": ["' + parentFolderId + '"]';
      }
      requestBody += '}';

      HttpRequest request = GoogleAuthHelper.prepareRequest(
        'https://www.googleapis.com/drive/v3/files',
        'POST',
        header,
        requestBody
      );
      HttpResponse response = GoogleAuthHelper.sendRequest(request);

      if (response.getStatusCode() == 200) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        folderId = (String) responseData.get('id');
        System.debug('Folder created successfully. Folder ID: ' + folderId);
      } else {
        System.debug(
          'Failed to create folder. Status code: ' + response.getStatusCode()
        );
      }
    }

    return folderId;
  }
}
