/*
*********************************************************
Apex Class Name    : OrderButtonController
Created Date       : July 04, 2023
@description       : Class used as a controller for class TemplateUploadManuallyController.
The test Coverage of this class is covered in TemplateUploadManuallyControllerTest
This class is part of uplaoding the mockup template to Google Drive through the buttonOn the Order page.
@author            : Sohaib Saqib
Modification Log:
Ver   Date         Author                               Modification
--   --   --                      --
*********************************************************
*/
public class OrderButtonController {
  private Id orderId;

  public OrderButtonController(
    ApexPages.StandardController standardController
  ) {
    orderId = standardController.getId();
  }

  public static Map<String, String> createFolderFromButton(Id accountId) {
    String accessToken = GoogleAPIMethods.getLatestAccessToken();
    String VectorID;
    Map<String, String> folderIds = new Map<String, String>();
    List<Account> accountList = [
      SELECT
        Id,
        Name,
        RecordType.Name,
        Google_Drive_Folder_Id__c,
        Vector_Folder_ID__c
      FROM Account
      WHERE Id = :accountId
    ];
    Account acc;
    if (!accountList.isEmpty()) {
      acc = accountList[0];
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
      String SubFolderID;
      String RecordTypeFolderId;

      if (RecordType == 'Vendor Account') {
        RecordTypeFolderId = GoogleAPIMethods.findFolder(
          '04.VENDOR ACCOUNTS',
          accessToken
        );
        if (RecordTypeFolderId == '404') {
          RecordTypeFolderId = GoogleAPIMethods.createFolder(
            '04.VENDOR ACCOUNTS',
            null,
            accessToken
          );
        }
        SubFolderID = GoogleAPIMethods.findSubFolder(
          SubFolderName,
          RecordTypeFolderId,
          accessToken
        );
      } else if (RecordType == 'Customer Account') {
        RecordTypeFolderId = GoogleAPIMethods.findFolder(
          '02.CUSTOMER ACCOUNTS',
          accessToken
        );
        if (RecordTypeFolderId == '404') {
          RecordTypeFolderId = GoogleAPIMethods.createFolder(
            '02.CUSTOMER ACCOUNTS',
            null,
            accessToken
          );
        }
        SubFolderID = GoogleAPIMethods.findSubFolder(
          SubFolderName,
          RecordTypeFolderId,
          accessToken
        );
      }

      if (SubFolderID == '404') {
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
      VectorID = GoogleAPIMethods.MakeFolder(
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

      folderIds.put('VectorID', VectorID);
      folderIds.put('FolderID', FolderID);
      folderIds.put(
        'GoogleDriveFileLink',
        GoogleAPIMethods.getGoogleDriveFileLink(FolderID, accessToken)
      );
    }
    return folderIds;
  }

  private static Blob generatePDF(Id WOId) {
    PageReference pageRef = Page.TemplateForGoogleDrive;
    pageRef.getParameters().put('woID', WOId);
    //    pageRef.getParameters().put('renderAs', 'pdf');
    if (Test.isRunningTest()) {
      return Blob.valueOf('Testing');
    }
    Blob pdfContent = pageRef.getContentAsPDF();
    return pdfContent;
  }

  private static String GenerateName(Id OrderId) {
    List<Order> orderList = [
      SELECT
        Id,
        Name,
        OpportunityId,
        AccountId,
        OrderNumber,
        WONameLink__c,
        Invoice_Number__c,
        Invoice_Due_Date__c
      FROM Order
      WHERE Id = :OrderId
    ];
    String generatedName;
    Order workOrder;
    if (!orderList.isEmpty()) {
      workOrder = orderList[0];
      String orderNumber = workOrder.OrderNumber.replaceAll('^0+', '');

      Id opportunityId = workOrder.OpportunityId;
      List<Opportunity> opportunityList = [
        SELECT Id, Name
        FROM Opportunity
        WHERE Id = :opportunityId
      ];
      Opportunity opp;
      if (!opportunityList.isEmpty()) {
        opp = opportunityList[0];
        String OppName = opp.Name;
        List<Account> accountList = [
          SELECT Id, Name
          FROM Account
          WHERE Id = :workOrder.AccountId
        ];
        Account acc;
        if (!accountList.isEmpty()) {
          acc = accountList[0];
          String clientName = acc.Name;
          String currentDate = DateTime.now().format('MMyy');
          generatedName =
            orderNumber +
            '_' +
            clientName +
            '_' +
            OppName +
            '_' +
            currentDate +
            '.pdf';
        }
      }
    }

    return generatedName;
  }

  public static void uploadPdfTemplate(Id updatedOrderId) {
    List<Attachment> attachmentsToInsert = new List<Attachment>();
    Set<Id> accountIds = new Set<Id>();

    List<Order> orderList = [
      SELECT AccountId
      FROM Order
      WHERE Id = :updatedOrderId
    ];
    Order order;
    if (!orderList.isEmpty()) {
      order = orderList[0];
      accountIds.add(order.AccountId);

      Map<Id, Account> accountMap = new Map<Id, Account>(
        [
          SELECT
            Id,
            Google_Drive_Folder_Link__c,
            Google_Drive_Folder_Id__c,
            Vector_Folder_ID__c
          FROM Account
          WHERE Id IN :accountIds
        ]
      );

      String accessToken = GoogleAPIMethods.getLatestAccessToken();
      Map<Id, Order> orderMap = new Map<Id, Order>(
        [SELECT Id, AccountId FROM Order WHERE Id = :updatedOrderId]
      );
      List<Order> ordersToUpdate = new List<Order>();
      List<Account> AccountsToUpdate = new List<Account>();
      Blob pdfBlob = generatePDF(updatedOrderId);

      String folderId = accountMap.get(orderMap.get(updatedOrderId).AccountId)
        .Google_Drive_Folder_Id__c;
      String vectorId = accountMap.get(orderMap.get(updatedOrderId).AccountId)
        .Vector_Folder_ID__c;
      String GoogleDriveFileLink = accountMap.get(
          orderMap.get(updatedOrderId).AccountId
        )
        .Google_Drive_Folder_Link__c;

      if (
        folderId == null ||
        String.isBlank(folderId) ||
        !GoogleAPIMethods.findFolderById(folderId, accessToken)
      ) {
        Account acco = accountMap.get(orderMap.get(updatedOrderId).AccountId);
        Map<String, String> folderIds = createFolderFromButton(acco.id);
        // Retrieve the VectorID and FolderID from the map
        vectorId = folderIds.get('VectorID');
        folderId = folderIds.get('FolderID');
        GoogleDriveFileLink = folderIds.get('GoogleDriveFileLink');
        Account AccountToUpdate = new Account(
          Id = acco.id,
          Vector_Folder_ID__c = vectorId,
          Google_Drive_Folder_Id__c = folderId,
          Google_Drive_Folder_Link__c = GoogleDriveFileLink
        );
        AccountsToUpdate.add(AccountToUpdate);
      }

      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=media'
      );
      request.setMethod('POST');
      request.setHeader('Authorization', 'Bearer ' + accessToken);
      request.setHeader('Content-Type', 'application/pdf');
      request.setHeader(
        'Content-Disposition',
        'attachment; filename=Testing File.pdf'
      );
      request.setBodyAsBlob(pdfBlob);

      HttpResponse response = new Http().send(request);

      if (response.getStatusCode() == 200) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(
          response.getBody()
        );
        String fileId = (String) responseData.get('id');
        // Move the file to the desired folder
        if (fileId != null) {
          GoogleAPIMethods.moveFileOrFolder(fileId, vectorId, accessToken);
          GoogleAPIMethods.setAccessToPublicEdit(fileId, accessToken);
        }
        // Update the Order record with the Google Drive link
        String link = GoogleAPIMethods.getGoogleDriveFileLink(
          fileId,
          accessToken
        );
        Order orderToUpdate = new Order(
          Id = updatedOrderId,
          Google_Drive_Template_Link__c = link
        );
        ordersToUpdate.add(orderToUpdate);
        // Rename the file
        GoogleAPIMethods.renameFile(
          fileId,
          GenerateName(updatedOrderId),
          accessToken
        );
      }
      // Update the Order records with the Google Drive links
      if (!ordersToUpdate.isEmpty()) {
        update ordersToUpdate;
      }
      if (!AccountsToUpdate.isEmpty()) {
        update AccountsToUpdate;
      }
    }
  }
}
