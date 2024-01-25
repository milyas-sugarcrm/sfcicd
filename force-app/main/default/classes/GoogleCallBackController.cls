public class GoogleCallBackController {
  public String baseUrl { get; set; }

  public void handleCallback() {
    baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

    String authCode = ApexPages.currentPage().getParameters().get('code');
    system.debug('authCode' + authCode);
    Google_Auth_Key__mdt googleCred = GoogleAuthHelper.getGoogleAuthMetaData();

    String endPoint = 'https://oauth2.googleapis.com/token';
    String method = 'POST';
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/x-www-form-urlencoded');

    String requestBody = 'code=' + EncodingUtil.urlEncode(authCode, 'UTF-8');
    requestBody +=
      '&client_id=' + EncodingUtil.urlEncode(googleCred.Client_Id__c, 'UTF-8');
    requestBody +=
      '&client_secret=' +
      EncodingUtil.urlEncode(googleCred.Client_Secret__c, 'UTF-8');
    requestBody +=
      '&redirect_uri=' +
      EncodingUtil.urlEncode(googleCred.Redirect_URI__c, 'UTF-8');
    requestBody += '&grant_type=authorization_code';

    HttpResponse response = GoogleAuthHelper.sendRequest(
      GoogleAuthHelper.prepareRequest(endPoint, method, header, requestBody)
    );

    if (response.getStatusCode() == 200) {
      Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );

      if ([SELECT COUNT() FROM Google_Auth__c] == 1) {
        Google_Auth__c gAuth = [
          SELECT
            id,
            Access_Token__c,
            Refresh_Token__c,
            Token_Type__c,
            Token_Name__c
          FROM Google_Auth__c
          WHERE Token_Name__c = 'Latest'
          LIMIT 1
        ];
        gAuth.Access_Token__c = (String) tokenResponse.get('access_token');
        if ((String) tokenResponse.get('refresh_token') != null) {
          gAuth.Refresh_Token__c = (String) tokenResponse.get('refresh_token');
        }

        gAuth.Token_Type__c = (String) tokenResponse.get('token_type');
        update gAuth;
      } else {
        Google_Auth__c gAuth = new Google_Auth__c();
        gAuth.Token_Name__c = 'Latest';
        gAuth.Access_Token__c = (String) tokenResponse.get('access_token');
        gAuth.Refresh_Token__c = (String) tokenResponse.get('refresh_token');

        gAuth.Token_Type__c = (String) tokenResponse.get('token_type');
        insert gAuth;
      }

      ApexPages.addMessage(
        new ApexPages.Message(
          ApexPages.Severity.INFO,
          'Authentication successful'
        )
      );
    }
  }
}
