@isTest
public class TemplateForGoogleDriveController_Test {
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
  public static void testhandleWorkOrder() {
    Account acc = [SELECT id FROM Account LIMIT 1];
    Order ord = [SELECT id FROM Order LIMIT 1];
    ord.Order_Due_Date__c = System.today();

    Test.startTest();
    TemplateForGoogleDriveController controller = new TemplateForGoogleDriveController();
    controller.workOrderId = ord.Id;

    controller.handleWorkOrder();
    update ord;

    controller.handleWorkOrder();
    controller.products = new List<TemplateForGoogleDriveController.ProductInfo>{
      new TemplateForGoogleDriveController.ProductInfo(
        'Product A',
        'Description A',
        'Red',
        'Large'
      )
    };
    Test.stopTest();
  }
}
