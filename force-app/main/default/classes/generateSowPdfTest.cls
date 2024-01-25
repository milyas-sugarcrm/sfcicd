@isTest
public class generateSowPdfTest {
  @isTest
  static void testGenPdfSow() {
    Test.startTest();
    Id pfaOpportunityRecordType = Schema.SObjectType.Opportunity.getRecordTypeInfosByName()
      .get('PFA Customer Opportunity')
      .getRecordTypeId();

    // Blank Opportunity Record
    Opportunity blankOpportunityRecord = new Opportunity();
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      blankOpportunityRecord
    );
    GenerateSowWrapper pdfGenerator = new GenerateSowWrapper(stdController);

    pdfGenerator.genPdfSow();
    Assert.areEqual(
      'false',
      (String) pdfGenerator.success,
      'Response should be false as Blank Opportunity.'
    );

    // Create a test Opportunity
    Opportunity testOpp = new Opportunity(
      Name = 'Test Opportunity',
      StageName = 'Needs Analysis',
      CloseDate = Date.today(),
      Preferred_Payment_Method_PFA__c = 'ACH Transfer; Credit Card; Check; Bill.com',
      RecordTypeId = pfaOpportunityRecordType
    );
    insert testOpp;

    // Create a PageReference mock for the SOW page
    PageReference mockPage = Page.SOW;
    Test.setCurrentPage(mockPage);
    // Set parameters on the PageReference
    ApexPages.currentPage().getParameters().put('id', testOpp.Id);

    // Create an instance of the GenerateSowWrapper class
    ApexPages.StandardController stdController1 = new ApexPages.StandardController(
      testOpp
    );
    GenerateSowWrapper pdfGenerator1 = new GenerateSowWrapper(stdController1);
    pdfGenerator1.genPdfSow();
    Assert.areEqual(
      'true',
      (String) pdfGenerator1.success,
      'Response should be true.'
    );

    // Verify that ContentVersion and ContentDocumentLink were created
    Integer contentVersionCount = [SELECT COUNT() FROM ContentVersion];
    Assert.areEqual(1, contentVersionCount, 'Count should be 1');

    Test.stopTest();
  }
}
