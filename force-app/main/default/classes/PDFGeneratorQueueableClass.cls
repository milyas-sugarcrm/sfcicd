public class PDFGeneratorQueueableClass implements Queueable {
  private List<Id> updatedOrderIds;

  public PDFGeneratorQueueableClass(List<Id> updatedOrderIds) {
    System.debug('We are in the PDFGeneratorQueueableClass Constructor');
    this.updatedOrderIds = updatedOrderIds;
  }

  public void execute(QueueableContext context) {
    createPDF(updatedOrderIds);
  }

  private static Blob generatePDF(Id WOId) {
    //     return Blob.valueOf('Testing');

    PageReference pageRef = Page.TemplateForGoogleDrive;
    pageRef.getParameters().put('woID', WOId);
    //    pageRef.getParameters().put('renderAs', 'pdf');
    if (Test.isRunningTest()) {
      return Blob.valueOf('Testing');
    }
    Blob pdfContent = pageRef.getContentAsPDF();
    return pdfContent;
  }

  public static String GenerateName(Id OrderId) {
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

      Id opportunityId = workOrder.OpportunityId; // Retrieve the OpportunityId field
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

  @Future(callout=true)
  public static void createPDF(List<Id> updatedOrderIds) {
    List<Attachment> attachmentsToInsert = new List<Attachment>();
    Set<Id> accountIds = new Set<Id>();
    for (Order order : [
      SELECT AccountId
      FROM Order
      WHERE Id IN :updatedOrderIds
    ]) {
      accountIds.add(order.AccountId);
    }

    Map<Id, Account> accountMap = new Map<Id, Account>(
      [
        SELECT Id, Name, Vector_Folder_ID__c, Google_Drive_Folder_Id__c
        FROM Account
        WHERE Id IN :accountIds
      ]
    );
    String accessToken = GoogleAPIMethods.getLatestAccessToken();

    Map<Id, Order> orderMap = new Map<Id, Order>(
      [SELECT Id, AccountId FROM Order WHERE Id IN :updatedOrderIds]
    );
    List<Order> ordersToUpdate = new List<Order>();
    String folderIdofAccount, folderIdofVector;
    Blob pdfBlob;
    for (Id orderId : updatedOrderIds) {
      pdfBlob = generatePDF(orderId);
      folderIdofAccount = accountMap.get(orderMap.get(orderId).AccountId)
        .Google_Drive_Folder_Id__c;
      folderIdofVector = accountMap.get(orderMap.get(orderId).AccountId)
        .Vector_Folder_ID__c;
      if (
        (folderIdofAccount != null || !String.isBlank(folderIdofAccount)) &&
        (folderIdofVector != null || !String.isBlank(folderIdofVector))
      ) {
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
            GoogleAPIMethods.moveFileOrFolder(
              fileId,
              folderIdofVector,
              accessToken
            );
            GoogleAPIMethods.setAccessToPublicEdit(fileId, accessToken);
          }

          // Update the Order record with the Google Drive link
          String link = GoogleAPIMethods.getGoogleDriveFileLink(
            fileId,
            accessToken
          );

          Order orderToUpdate = new Order(
            Id = orderId,
            Google_Drive_Template_Link__c = link
          );
          ordersToUpdate.add(orderToUpdate);

          // Rename the file
          GoogleAPIMethods.renameFile(
            fileId,
            GenerateName(orderId),
            accessToken
          );
        } else {
          System.debug('Overall issue ' + response.getStatusCode());
        }
      }
    }

    // }
    // Update the Order records with the Google Drive links
    if (!ordersToUpdate.isEmpty()) {
      update ordersToUpdate;
    }
  }
}
