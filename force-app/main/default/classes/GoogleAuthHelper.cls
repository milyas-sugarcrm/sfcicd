public with sharing class GoogleAuthHelper {
  public GoogleAuthHelper() {
  }

  public static Google_Auth_Key__mdt getGoogleAuthMetaData() {
    List<Google_Auth_Key__mdt> metadataList = [
      SELECT Id
      FROM Google_Auth_Key__mdt
      LIMIT 1
    ];
    Id MetadataID;
    if (metadataList != null) {
      MetadataID = metadataList[0].id;
    }

    Google_Auth_Key__mdt googleCred = Google_Auth_Key__mdt.getInstance(
      MetadataID
    );
    return googleCred;
  }

  public static HttpRequest prepareRequest(
    String endPoint,
    String method,
    Map<String, String> header,
    String requestBody
  ) {
    HttpRequest request = new HttpRequest();
    request.setEndpoint(endPoint);
    request.setMethod(method);
    for (String value : header.keySet()) {
      request.setHeader(value, header.get(value));
    }
    request.setBody(requestBody);
    return request;
  }

  public static HttpResponse sendRequest(HttpRequest request) {
    Http http = new Http();
    HttpResponse response = http.send(request);
    Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(
      response.getBody()
    );
    return response;
  }
}
