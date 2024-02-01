public class TriggerOnDepositInvoiceService {
  public static void generatePDF(List<Deposit_Invoice__c> triggerNew) {
    List<Id> ids = new List<Id>();
    for (Deposit_Invoice__c depositInvoice : triggerNew) {
      ids.add(depositInvoice.id);
    }
    List<Order> orders = [
      SELECT Id, OpportunityId, Deposit_Invoice__c
      FROM Order
      WHERE Deposit_Invoice__c IN :ids
    ];
    for (Order order : orders) {
      generateDepositPDF(order.id, order.OpportunityId);
    }
  }
  @future(callout=true)
  public static void generateDepositPDF(Id orderId, Id OppId) {
    PageReference pdf = Page.OpportunitySalesOrderDepositInvoicePDF;
    pdf.getParameters().put('id', orderId);

    Blob body;
    if (Test.isRunningTest()) {
      body = blob.valueOf('Unit.Test');
    } else {
      body = pdf.getContentAsPDF();
    }

    ContentVersion conVer = new ContentVersion();
    conVer.ContentLocation = 'S'; // S specify this document is in SF, use E for external files
    conVer.PathOnClient = 'Preview Deposit Invoice.pdf'; // The files name, extension is very important here which will help the file in preview.
    conVer.Title = 'Preview Deposit Invoice'; // Display name of the files
    conVer.VersionData = body;
    insert conVer;
    Id conDoc = [
      SELECT ContentDocumentId
      FROM ContentVersion
      WHERE Id = :conVer.Id
    ]
    .ContentDocumentId;

    delete [
      SELECT id
      FROM ContentDocumentLink
      WHERE
        LinkedEntityId = :OppId
        AND ContentDocument.Title = 'Preview Deposit Invoice'
    ];
    //Create ContentDocumentLink
    ContentDocumentLink cDe = new ContentDocumentLink();
    cDe.ContentDocumentId = conDoc;
    cDe.LinkedEntityId = OppId;
    cDe.ShareType = 'V';
    insert cDe;
  }
}
