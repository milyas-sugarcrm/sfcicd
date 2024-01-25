public class QuickbookAPIHelper extends QueueableWrapper implements Database.AllowsCallouts {
  Map<String, Set<Id>> mapQBInstanceAccountId;

  public QuickbookAPIHelper(Map<String, Set<Id>> datamap) {
    super('SyncChangesQueueable', datamap);
    this.mapQBInstanceAccountId = datamap;
  }

  public void syncCustomer(Map<String, Set<Id>> mapQBInstanceAccountIdData) {
    Set<Id> accIds = new Set<Id>();
    String accountTitle = '';
    Set<Id> accountsSyncOppIds = new Set<Id>();
    String accountDetails = '';
    if (mapQBInstanceAccountIdData.size() > 0) {
      for (String key : mapQBInstanceAccountIdData.keySet()) {
        accIds = mapQBInstanceAccountIdData.get(key);
        accountTitle = key;
      }
    }

    try {
      List<QB_Credentials__c> qbcList = [
        SELECT
          Id,
          Access_token__c,
          Refresh_token__c,
          realmid__c,
          Synced_Account_Title__c
        FROM QB_Credentials__c
        WHERE Synced_Account_Title__c = :accountTitle
        ORDER BY LastModifiedDate DESC
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
          Quickbooks_Account_Tittle__c,
          Service_Id_Breakdown__c,
          Service_Id_Brokerage__c,
          Service_Id_Duty__c,
          Service_Id_FixedCharges__c,
          Service_Id_InboundFreight__c,
          Service_Id_RunCharges__c
        FROM Quickbooks_Accounts_Configurations__c
        WHERE Quickbooks_Account_Tittle__c = :accountTitle
      ];
      Map<Id, QBO_Details__c> accountQBOIdMap = QuickbookApiCrud.getAccountQBOIdMap(
        accIds,
        accountTitle
      );

      if (qbcList.size() > 0) {
        List<Account> toUpdateAccounts = new List<Account>();
        List<QBO_Details__c> qboDetailsToUpdate = new List<QBO_Details__c>();
        System.debug('accIds ' + accIds);
        List<Account> accList = Database.query(
          'SELECT ' +
            String.join(
              new List<String>(
                Schema.getGlobalDescribe()
                  .get('Account')
                  .getDescribe()
                  .fields.getMap()
                  .keySet()
              ),
              ','
            ) +
            ',Billing_Contact__r.FirstName, Billing_Contact__r.LastName, Billing_Contact__r.MobilePhone, Billing_Contact__r.Phone FROM Account where id in :accIDs'
        );
        List<String> customerIds = new List<String>();
        for (Account acc : accList) {
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
          }
          accountDetails += accountDetails + acc.Name + ' (' + acc.Id + ')  ,';
          customerIds.add(String.valueOf(qboDetails.QB_Id__c));
        }
        List<String> authorizationCredentials = new List<String>();
        authorizationCredentials.add(qbcList[0].Access_token__c);
        authorizationCredentials.add(qbcList[0].Refresh_token__c);
        authorizationCredentials.add(qbcList[0].realmid__c);

        Map<String, String> syncTokenMap = QuickbookApiCrud.getSyncToken(
          'Customer',
          customerIds,
          authorizationCredentials,
          accountTitle
        );
        for (Account acc : accList) {
          QBO_Details__c qboDetails = accountQBOIdMap.get(acc.Id);
          if (qboDetails == null) {
            qboDetails = new QBO_Details__c();
            qboDetails.QB_Id__c = null;
            accountsSyncOppIds.add(acc.id);
          }
          String json = QuickbookApiCrud.getAccountJson(
            acc,
            'Customer',
            qboDetails.QB_Id__c,
            syncTokenMap.get(String.valueOf(qboDetails.QB_Id__c)),
            accountTitle
          );
          //QuickbookApiCrud.sendEmail('JSON',json);
          HttpRequest request = new HttpRequest();
          HttpResponse response = new HttpResponse();
          Http http = new Http();
          request.setMethod('POST');
          if (Test.isRunningTest()) {
            request.setEndpoint('http://test.com/test/sendCustomer');
          } else {
            request.setEndPoint(
              accountConfiguration[0].QB_API_End_Point__c +
                '/v3/company/' +
                qbcList[0].realmid__c +
                '/customer'
            );
          }
          request.setHeader(
            'Authorization',
            'Bearer ' + qbcList[0].Access_token__c
          );
          System.debug('IN Sync Customers 7 ' + qbcList[0].Access_token__c);
          request.setHeader('Accept', 'application/json');
          request.setHeader('Content-Type', 'application/json;charset=UTF-8');
          request.setBody(json);
          response = http.send(request);
          System.debug(response.getBody());
          System.debug(response.getStatus());
          if (response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) System.JSON.deserializeUntyped(
              response.getBody()
            );
            System.debug('results ' + results);
            if (qboDetails.QB_Id__c == null) {
              qboDetails.QB_Id__c = (String) ((Map<String, Object>) results.get(
                  'Customer'
                ))
                .get('Id');
              qboDetails.Name =
                'Account - ' +
                qboDetails.QB_Id__c +
                ' (' +
                accountTitle +
                ')';
              qboDetails.Id_Type__c = 'Account';
              qboDetails.Salesforce_Record_Id__c = acc.id;
              qboDetails.QBO_Account__c = accountTitle;
              toUpdateAccounts.add(acc);
              qboDetails.Account__c = acc.id;
              qboDetailsToUpdate.add(qboDetails);
            }
          } else if (response.getStatusCode() == 401) {
            QuickbookApiCrud.authenticationErrorEmail(
              response,
              accountDetails,
              'Accounts',
              accountTitle
            );
          } else {
            QuickbookApiCrud.DuplicateAccountResponse returnedResponse = QuickbookApiCrud.isDuplicateAccountError(
              response,
              acc,
              accountTitle,
              authorizationCredentials,
              'Customer'
            );
            if (
              returnedResponse != null &&
              returnedResponse.qboDetails != null
            ) {
              qboDetailsToUpdate.add(returnedResponse.qboDetails);
            } else if (
              returnedResponse != null &&
              returnedResponse.isDuplicateEntityExist != null &&
              returnedResponse.isDuplicateEntityExist == true
            ) {
              acc.Duplicate_Exists__c = true;
              toUpdateAccounts.add(acc);
            } else {
              QuickbookApiCrud.serverErrorEmails(
                response,
                acc.Name,
                'Account',
                accountTitle,
                'Class QuickbookApiHelper , syncCustomer ',
                'Account',
                acc.Id
              );
            }
          }
        }

        if (toUpdateAccounts.size() > 0) {
          update toUpdateAccounts;
        }
        if (qboDetailsToUpdate.size() > 0) {
          upsert qboDetailsToUpdate;
        }
      }
    } catch (Exception ex) {
      System.debug(ex.getStackTraceString());
      System.debug(ex.getCause());

      String subjectEmail =
        'IMPORTANT | QBO (' +
        accountTitle +
        ') | Error while Syncing Account at "' +
        System.now() +
        '"';
      QuickbookApiCrud.sendEmail(
        subjectEmail,
        'Error Message <br/>' +
          ex.getMessage() +
          ' Error On Accounts <br/> ' +
          accountDetails +
          '<br/><br/>Error Cause<br/>' +
          ex.getCause() +
          '<br/><br/>Error On Line Number<br/>' +
          ex.getStackTraceString()
      );
    }
  }
}
