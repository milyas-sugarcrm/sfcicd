@isTest
public class TemplateUploadManuallyControllerTest {
  @TestSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createTestAccount();
    testFactory.addAddressRelatedData();
    testFactory.createEstimate();
    testFactory.createProducts();
    testFactory.createSalesOrder();

    Google_Auth__c auth = new Google_Auth__c(
      Token_Name__c = 'Latest',
      Access_Token__c = 'TestAccessToken'
    );
    insert auth;
  }

  @isTest
  public static void testTemplateUploadManuallyController() {
    Order testOrder = [SELECT id FROM order LIMIT 1];
    MockHttpResponseGenerator mockResponse = new MockHttpResponseGenerator();
    ApexPages.StandardController stdController = new ApexPages.StandardController(
      testOrder
    );

    TemplateUploadManuallyController controller = new TemplateUploadManuallyController(
      stdController
    );

    List<Id> orderIds = new List<Id>{ testOrder.Id };
    String expectedDebugLog = 'Record ID: ' + testOrder.Id;

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, mockResponse);
    controller = new TemplateUploadManuallyController(stdController);
    System.debug('We are at Point AAAAAAAAAAA');
    controller.uploadPdfTemplate();
    System.debug('We are at Point BBBBBBBBBB');
    Test.stopTest();
  }
}
