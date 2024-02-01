@isTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest request) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');

    // Create a map to hold the folder data
    Map<String, Object> folderData = new Map<String, Object>();
    folderData.put('id', 'mock-folder-id');
    folderData.put('name', 'mock-folder-name');
    folderData.put('mimeType', 'application/vnd.google-apps.folder');

    // Create a list and add the folder data to it
    List<Object> folders = new List<Object>();
    folders.add(folderData);

    // Create a map to hold the response data
    Map<String, Object> responseData = new Map<String, Object>();
    responseData.put('files', folders);

    // Serialize the response data and set it as the response body
    String responseBody = JSON.serialize(responseData);
    response.setBody(responseBody);
    response.setStatusCode(200);

    return response;
  }
}
