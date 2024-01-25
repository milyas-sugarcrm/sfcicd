public class GoogleAuthController {
  public PageReference GoogleAuthController() {
    Google_Auth_Key__mdt googleCred = GoogleAuthHelper.getGoogleAuthMetaData();
    String authUrl = googleCred.Auth_URL__c;
    authUrl +=
      '?client_id=' + EncodingUtil.urlEncode(googleCred.Client_Id__c, 'UTF-8');
    authUrl +=
      '&redirect_uri=' +
      EncodingUtil.urlEncode(googleCred.Redirect_URI__c, 'UTF-8');
    authUrl += '&response_type=code';
    authUrl +=
      '&scope=' + EncodingUtil.urlEncode(googleCred.Scopes__c, 'UTF-8');
    authUrl += '&access_type=offline';
    authUrl += '&prompt=consent';
    PageReference pageRef = new PageReference(authUrl);
    return pageRef;
  }
}
