/*
*********************************************************
Apex Class Name    : OrderTriggerHandlerForGoogleDrive
Created Date       : July 04, 2023
@description       : This is class is used to make a pdf on Google Drive when Work Order Stage reaches 02_-_Send_Mock_Up_to_Client_for_Approval
@author            : Sohaib Saqib
Modification Log: 
Ver   Date         Author                               Modification
--   --   --                      --
*********************************************************
*/
public class AccountHandlerForGoogleDrive {
  /*
*********************************************************
@Method Name    : handleNewAccounts 
@author         : Sohaib Saqib
@description    : called from Trigger.
@param          : List<Account>
@return         : void testing
********************************************************
*/
  public static void handleNewAccounts(List<Account> newAccounts) {
    List<Id> accountIds = new List<Id>();
    for (Account acc : newAccounts) {
      accountIds.add(acc.Id);
    }
    //testing 123
    /*
     * sa asd
     */
    createFolderForAccount(accountIds);
  }

  /*
*********************************************************
@Method Name    : createFolderForAccount 
@author         : Sohaib Saqib
@description    : Main function responsible to make folder on name of Account and for making sub Folders.
@param          : List<Id>
@return         : Void
********************************************************
*/
  @future(callout=true)
  public static void createFolderForAccount(List<Id> accountIds) {
    String accessToken = GoogleAPIMethods.getLatestAccessToken();

    List<Account> accounts = [
      SELECT
        Id,
        Name,
        RecordType.Name,
        Vector_Folder_ID__c,
        Google_Drive_Folder_Link__c,
        Google_Drive_Folder_Id__c
      FROM Account
      WHERE Id IN :accountIds
    ];
    List<Account> accountsToUpdate = new List<Account>();

    string VendorAccountFolderId = GoogleAPIMethods.findFolder(
      '04.VENDOR ACCOUNTS',
      accessToken
    );
    String CustomerAccountFOlderId = GoogleAPIMethods.findFolder(
      '02.CUSTOMER ACCOUNTS',
      accessToken
    );
    if (VendorAccountFolderId == '404') {
      VendorAccountFolderId = GoogleAPIMethods.createFolder(
        '04.VENDOR ACCOUNTS',
        null,
        accessToken
      );
    }
    if (CustomerAccountFOlderId == '404') {
      CustomerAccountFOlderId = GoogleAPIMethods.createFolder(
        '02.CUSTOMER ACCOUNTS',
        null,
        accessToken
      );
    }

    for (Account acc : accounts) {
      String firstName = acc.Name;
      String folderName = firstName != null ? firstName : 'Default Folder Name';
      String SubFolderName = folderName.substring(0, 1).toUpperCase();

      // Check if SubFolderName is not an English alphabet from A to Z
      Pattern pattern = Pattern.compile('[A-Z]');
      Matcher matcher = pattern.matcher(SubFolderName);

      if (!matcher.matches()) {
        SubFolderName = '0-9';
      }

      String RecordType = acc.RecordType.Name;
      if (RecordType == 'Vendor Account' || RecordType == 'Customer Account') {
        String SubFolderID;
        String RecordTypeFolderId;
        if (RecordType == 'Vendor Account') {
          RecordTypeFolderId = VendorAccountFolderId;
          SubFolderID = GoogleAPIMethods.findSubFolder(
            SubFolderName,
            VendorAccountFolderId,
            accessToken
          );
        } else if (RecordType == 'Customer Account') {
          RecordTypeFolderId = CustomerAccountFOlderId;
          SubFolderID = GoogleAPIMethods.findSubFolder(
            SubFolderName,
            CustomerAccountFOlderId,
            accessToken
          );
        }

        if (SubFolderID == '001' || SubFolderID == '404') {
          SubFolderID = GoogleAPIMethods.MakeFolder(
            RecordTypeFolderId,
            SubFolderName,
            accessToken
          );
        }

        String FolderID = GoogleAPIMethods.MakeFolder(
          SubFolderID,
          folderName,
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainViewOnly(FolderID, accessToken);

        String TempID;
        String VectorID = GoogleAPIMethods.MakeFolder(
          FolderID,
          'Mockup Files',
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainEdit(VectorID, accessToken);
        TempID = GoogleAPIMethods.MakeFolder(
          FolderID,
          'Vector Files',
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainEdit(TempID, accessToken);
        TempID = GoogleAPIMethods.MakeFolder(
          FolderID,
          'Brand Guidelines',
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainEdit(TempID, accessToken);
        TempID = GoogleAPIMethods.MakeFolder(
          FolderID,
          'Raster Files',
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainEdit(TempID, accessToken);
        TempID = GoogleAPIMethods.MakeFolder(
          FolderID,
          'Experiential',
          accessToken
        );
        GoogleAPIMethods.setAccessToDomainEdit(TempID, accessToken);

        acc.Google_Drive_Folder_Id__c = FolderID;
        acc.Vector_Folder_ID__c = VectorID;
        acc.Google_Drive_Folder_Link__c = GoogleAPIMethods.getGoogleDriveFileLink(
          FolderID,
          accessToken
        );
        accountsToUpdate.add(acc);
      }
    }

    if (!accountsToUpdate.isEmpty()) {
      update accountsToUpdate;
    }
  }
  /*
*********************************************************
@Method Name    : updateDriveFolderNameWrapper 
@author         : Sohaib Saqib
@description    : Wrapper function of updateDriveFolderName and is called from Trigger
@param          : List<Account> , Map<Id, Account>
@return         : Void
********************************************************
*/

  public static void updateDriveFolderNameWrapper(
    List<Account> newAccounts,
    Map<Id, Account> oldAccountMap
  ) {
    List<Id> accountIdsToUpdate = new List<Id>();
    for (Account newAccount : newAccounts) {
      Account oldAccount = oldAccountMap.get(newAccount.Id);

      if (newAccount.Name != oldAccount.Name) {
        if (
          newAccount.Name.substring(0, 1) != oldAccount.Name.substring(0, 1)
        ) {
          accountIdsToUpdate.add(newAccount.Id);
        } else {
          accountIdsToUpdate.add(newAccount.Id);
        }
      }
    }
    if (!accountIdsToUpdate.isEmpty()) {
      updateDriveFolderName(accountIdsToUpdate);
    }
  }
  /*
*********************************************************
@Method Name    : updateDriveFolderName 
@author         : Sohaib Saqib
@description    : Fucntion to handle the name change and the movement of folder to other folder if starting Alphabet change. 
@param          : List<Id> accountIds
@return         : Void
********************************************************
*/
  @future(callout=true)
  public static void updateDriveFolderName(List<Id> accountIds) {
    Map<Id, Account> newAccountMap = new Map<Id, Account>(
      [
        SELECT Id, Name, RecordType.Name, Google_Drive_Folder_Id__c
        FROM Account
        WHERE Id IN :accountIds
      ]
    );

    string AccessToken = GoogleAPIMethods.getLatestAccessToken();
    string VendorAccountFolderId = GoogleAPIMethods.findFolder(
      '04.VENDOR ACCOUNTS',
      accessToken
    );
    String CustomerAccountFOlderId = GoogleAPIMethods.findFolder(
      '02.CUSTOMER ACCOUNTS',
      accessToken
    );

    for (Id accountId : accountIds) {
      Account newAccount = newAccountMap.get(accountId);
      if (newAccount != null) {
        String folderId = newAccount.Google_Drive_Folder_Id__c;
        if (Test.isRunningTest()) {
          folderId = 'Test';
        }
        if (folderId != null) {
          // Create an HTTP PATCH request to update the folder name
          HttpRequest request = new HttpRequest();
          request.setEndpoint(
            'https://www.googleapis.com/drive/v3/files/' + folderId
          );
          request.setMethod('PATCH');
          request.setHeader('Authorization', 'Bearer ' + AccessToken);
          request.setHeader('Content-Type', 'application/json');
          request.setBody('{"name":"' + newAccount.Name + '"}');
          HttpResponse response = new Http().send(request);
          if (response.getStatusCode() == 200) {
            System.debug(
              'Folder name updated successfully for Account: ' + newAccount.Name
            );
            String folderName = newAccount.Name;
            String SubFolderName = folderName.substring(0, 1).toUpperCase();
            // Check if SubFolderName is not an English alphabet from A to Z
            Pattern pattern = Pattern.compile('[A-Z]');
            Matcher matcher = pattern.matcher(SubFolderName);
            if (!matcher.matches()) {
              SubFolderName = '0-9';
            }

            String RecordType = newAccount.RecordType.Name;
            String SubFolderID;
            String RecordTypeFolderId;
            if (RecordType == 'Vendor Account') {
              RecordTypeFolderId = VendorAccountFolderId;
              SubFolderID = GoogleAPIMethods.findSubFolder(
                SubFolderName,
                VendorAccountFolderId,
                AccessToken
              );
            } else if (RecordType == 'Customer Account') {
              RecordTypeFolderId = CustomerAccountFOlderId;
              SubFolderID = GoogleAPIMethods.findSubFolder(
                SubFolderName,
                CustomerAccountFOlderId,
                AccessToken
              );
            }
            system.debug(
              'folderId: ' +
                folderId +
                'SubFolderID: ' +
                SubFolderID +
                'RecordType: ' +
                RecordType
            );
            GoogleAPIMethods.moveFileOrFolder(
              folderId,
              SubFolderID,
              AccessToken
            );
          } else {
            System.debug(
              'Error updating folder name for Account: ' + newAccount.Name
            );
            System.debug('Response status code: ' + response.getStatusCode());
            System.debug('Response body: ' + response.getBody());
          }
        }
      }
    }
  }

  /*
*********************************************************
@Method Name    : handleAccountDeletion 
@author         : Sohaib Saqib
@description    : Delete Folder when Accont is deleted. Called from Fucntion.
@param          : List<Account>
@return         : void
********************************************************
*/
  public static void handleAccountDeletion(List<Account> deletedAccounts) {
    List<Id> accountIds = new List<Id>();
    List<String> DriveIDs = new List<String>();
    for (Account acc : deletedAccounts) {
      accountIds.add(acc.Id);
      DriveIDs.add(acc.Google_Drive_Folder_Id__c);
    }

    deleteGoogleDriveFolder(DriveIDs);
  }

  /*
*********************************************************
@Method Name    : deleteGoogleDriveFolder 
@author         : Sohaib Saqib
@description    : Main function that do the deletion.
@param          : List<String> DriveIDs The reason that we are getting List<String> DriveIDs instead of List<ID> AccountID is because the Trigger is synchronous  and this
is an asynchronous Method. So at the time this fnction runs, the Accounts are already deleted. 
@return         : void
********************************************************
*/
  @future(callout=true)
  public static void deleteGoogleDriveFolder(List<String> DriveIDs) {
    String accessToken = GoogleAPIMethods.getLatestAccessToken();
    for (String DriveId : DriveIDs) {
      String folderId = DriveId;
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
  }
}
