public class QuickbookConnection {
  public QB_Credentials__c qbc { get; set; }
  public String selectedQBAccount { get; set; }
  public String selectedButtonQBAccount { get; set; }
  public string codeparam { get; set; }
  public string realmId;
  public string baseurl { get; set; }
  public class OptionsClass {
    public String nameOfInstance { get; set; }
    public Boolean isSynced { get; set; }
  }
  public PageReference authenticateSelected() {
    selectedQBAccount = selectedButtonQBAccount;
    return doAuthorizationQuickBooks();
  }

  public List<OptionsClass> quickbooksAccounts {
    get {
      List<OptionsClass> lstInstances = new List<OptionsClass>();
      List<QB_Credentials__c> qbcList = [
        SELECT Id, Synced_Account_Title__c
        FROM QB_Credentials__c
        WHERE isActive__c = TRUE
      ]; // Deactivated TP Supply Co.
      for (QB_Credentials__c qboObj : qbcList) {
        OptionsClass optionsObj = new OptionsClass();
        optionsObj.nameOfInstance = qboObj.Synced_Account_Title__c;
        Boolean alreadyExist = false;
        if (lstInstances.size() > 0) {
          for (OptionsClass optionObj : lstInstances) {
            if (optionObj.nameOfInstance == optionsObj.nameOfInstance) {
              alreadyExist = true;
            }
          }
        }
        if (!alreadyExist)
          lstInstances.add(optionsObj);
      }
      return lstInstances;
    }
    set;
  }

  public List<SelectOption> quickbooksAccountsList {
    get {
      List<Quickbooks_Accounts_Configurations__c> listOfAccounts = [
        SELECT Quickbooks_Account_Tittle__c, Id
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Is_Active__c = TRUE
      ]; // Deactivated TP Supply Co.

      List<SelectOption> listToReturn = new List<SelectOption>();

      for (Quickbooks_Accounts_Configurations__c con : listOfAccounts) {
        listToReturn.add(
          new SelectOption(
            con.Quickbooks_Account_Tittle__c,
            con.Quickbooks_Account_Tittle__c
          )
        );
      }
      return listToReturn;
    }
    set;
  }

  public QuickbookConnection() {
    codeparam = apexpages.currentpage().getparameters().get('code');
    realmId = apexpages.currentpage().getparameters().get('realmId');
    selectedQBAccount = apexpages.currentpage().getparameters().get('state');
    System.debug('--------Reached------' + selectedQBAccount);
    System.debug('codeparam' + codeparam);
    System.debug('realmId' + realmId);
    baseurl =
      System.URL.getSalesforceBaseUrl().toExternalForm() +
      '/apex/QuickBookAuthentication';
  }

  public QB_Credentials__c getQbCred() {
    List<QB_Credentials__c> qbcList = [
      SELECT Id, Synced_Account_Title__c
      FROM QB_Credentials__c
    ];

    // where Synced_Account_Title__c  =:selectedQBAccount];
    if (qbcList.size() > 0) {
      return qbcList[0];
    }

    return null;
  }

  /*
   * @Name - doAuthorizationQuickBooks
   * @Param - None
   * @Description - to get the authentication code from the QuickBooks Account
   * @ReturnType - PageReference
   */

  public PageReference doAuthorizationQuickBooks() {
    system.debug('=====' + selectedQBAccount);
    List<QB_Credentials__c> qbCredentials = [
      SELECT
        Id,
        Access_token__c,
        RealMId__c,
        Refresh_token__c,
        Synced_Account_Title__c
      FROM QB_Credentials__c
      WHERE Synced_Account_Title__c = :selectedQBAccount
    ];

    List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
      SELECT
        Id,
        QBO_Custom_Field_1__c,
        QBO_Custom_Field_1_Id__c,
        QB_Access_token_End_Point__c,
        QB_API_End_Point__c,
        QB_Authorization_End_Point__c,
        QB_Authorization_Scope__c,
        QB_Client_Id__c,
        QB_Client_Secret__c,
        QB_ID__c,
        QB_Redirect_URI__c,
        QB_Timezone__c,
        Quickbooks_Account_Tittle__c
      FROM Quickbooks_Accounts_Configurations__c
      WHERE Quickbooks_Account_Tittle__c = :selectedQBAccount
    ];
    if (accountConfiguration != null && accountConfiguration.size() > 0) {
      String authorization_endpoint = accountConfiguration[0]
        .QB_Authorization_End_Point__c;
      String scope = accountConfiguration[0].QB_Authorization_Scope__c;
      String client_Id = accountConfiguration[0].QB_Client_Id__c;
      String redirect_URI = accountConfiguration[0].QB_Redirect_URI__c;
      System.debug('redirect_URI ' + redirect_URI);
      String final_EndPoint =
        authorization_endpoint +
        '?client_id=' +
        client_Id +
        '&response_type=code&scope=' +
        scope +
        '&state=' +
        selectedQBAccount +
        '&redirect_uri=' +
        redirect_URI;
      //selectedQBAccount
      //state=123445633443
      PageReference pageRef = new PageReference(final_EndPoint);
      return pageRef;
    }
    return null;
  }

  /* @Name - doFetchAccessToken
   * @Param - None
   * @Description - to get the Access Token , Refresh Token and other Information after getting the authentication code
   * @ReturnType - void
   */
  public void doFetchAccessToken() {
    if (codeparam != null && realmId != null) {
      List<Quickbooks_Accounts_Configurations__c> accountConfiguration = [
        SELECT
          Id,
          QBO_Custom_Field_1__c,
          QBO_Custom_Field_1_Id__c,
          QB_Access_token_End_Point__c,
          QB_API_End_Point__c,
          QB_Authorization_End_Point__c,
          QB_Authorization_Scope__c,
          QB_Client_Id__c,
          QB_Client_Secret__c,
          QB_ID__c,
          QB_Redirect_URI__c,
          QB_Timezone__c,
          Quickbooks_Account_Tittle__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :selectedQBAccount
      ];
      if (accountConfiguration != null && accountConfiguration.size() > 0) {
        String client_Id = accountConfiguration[0].QB_Client_Id__c;
        String redirect_URI = accountConfiguration[0].QB_Redirect_URI__c;
        String consumer_Secret = accountConfiguration[0].QB_Client_Secret__c;
        String authorization_endpoint = accountConfiguration[0]
          .QB_Authorization_End_Point__c;
        String encodedString = EncodingUtil.base64Encode(
          Blob.valueOf(client_Id + ':' + consumer_Secret)
        );
        String endPoint;
        if (Test.isRunningTest()) {
          endPoint = 'http://test.com/test/refreshtoken';
        } else {
          endPoint = accountConfiguration[0].QB_Access_token_End_Point__c;
        }

        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        httpReq.setMethod('POST');
        httpReq.setEndPoint(endPoint);
        httpReq.setHeader('Authorization', 'Basic ' + encodedString);
        httpReq.setHeader('Host', 'oauth.platform.intuit.com');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpReq.setBody(
          'grant_type=authorization_code&code=' +
            codeparam +
            '&redirect_uri=' +
            redirect_URI
        );

        httpRes = http.send(httpReq);

        if (httpRes.getStatusCode() == 200) {
          Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(
            httpRes.getBody()
          );

          String accessToken = (String) results.get('access_token');
          String refreshToken = (String) results.get('refresh_token');
          String realmId = realmId;

          if (accessToken != null) {
            QB_Credentials__c qbc = new QB_Credentials__c();
            List<QB_Credentials__c> qbcList = [
              SELECT Id, Synced_Account_Title__c
              FROM QB_Credentials__c
              WHERE Synced_Account_Title__c = :selectedQBAccount
            ];
            if (qbcList.size() > 0) {
              qbc.Access_token__c = accessToken;
              qbc.Refresh_token__c = refreshToken;
              qbc.Synced_Account_Title__c = selectedQBAccount;
              qbc.Id = qbcList[0].Id;
            } else {
              qbc.Access_token__c = accessToken;
              qbc.Refresh_token__c = refreshToken;
              qbc.Synced_Account_Title__c = selectedQBAccount;
              qbc.realmid__c = realmId;
            }
            upsert qbc;
          }
        }
      }
    }
  }
}
