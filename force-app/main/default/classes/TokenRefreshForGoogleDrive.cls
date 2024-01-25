public class TokenRefreshForGoogleDrive implements Schedulable {
  public void execute(SchedulableContext sc) {
    refreshToken();
  }

  @future(Callout=true)
  public static void refreshToken() {
    Google_Auth_Key__mdt googleCred = GoogleAuthHelper.getGoogleAuthMetaData();

    String endPoint = 'https://accounts.google.com/o/oauth2/token';
    String method = 'POST';
    Map<String, String> header = new Map<String, String>();
    header.put('Content-Type', 'application/x-www-form-urlencoded');

    // Fetch the refresh token from the Google_Auth__c object
    Google_Auth__c authData = [
      SELECT Refresh_Token__c
      FROM Google_Auth__c
      WHERE Token_Name__c = 'Latest'
      LIMIT 1
    ];

    if (authData == null || String.isBlank(authData.Refresh_Token__c)) {
      system.debug('Refresh token not found.');
    }

    String refreshToken = authData.Refresh_Token__c;

    String requestBody =
      'client_id=' + EncodingUtil.urlEncode(googleCred.Client_Id__c, 'UTF-8');
    requestBody +=
      '&client_secret=' +
      EncodingUtil.urlEncode(googleCred.Client_Secret__c, 'UTF-8');
    requestBody +=
      '&refresh_token=' + EncodingUtil.urlEncode(refreshToken, 'UTF-8');
    requestBody += '&grant_type=refresh_token';

    HttpResponse response = GoogleAuthHelper.sendRequest(
      GoogleAuthHelper.prepareRequest(endPoint, method, header, requestBody)
    );

    if (response.getStatusCode() == 200) {
      Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(
        response.getBody()
      );
      System.debug('tokenResponse GoogleTokenRefresh: ' + tokenResponse);

      if ([SELECT COUNT() FROM Google_Auth__c] == 1) {
        Google_Auth__c gAuth = [
          SELECT Id, Access_Token__c, Token_Type__c
          FROM Google_Auth__c
          WHERE Token_Name__c = 'Latest'
          LIMIT 1
        ];
        gAuth.Access_Token__c = (String) tokenResponse.get('access_token');
        System.debug(
          'New Access Token in GoogleTokenRefresh: ' +
          (String) tokenResponse.get('access_token')
        );
        gAuth.Token_Type__c = (String) tokenResponse.get('token_type');
        update gAuth;
      } else {
        Google_Auth__c gAuth = new Google_Auth__c();
        gAuth.Token_Name__c = 'Latest';
        gAuth.Access_Token__c = (String) tokenResponse.get('access_token');
        System.debug(
          'New Access Token GoogleTokenRefresh: ' +
          (String) tokenResponse.get('access_token')
        );
        gAuth.Token_Type__c = (String) tokenResponse.get('token_type');
        insert gAuth;
      }

      System.debug('Token refreshed successfully');
    }
  }
}
