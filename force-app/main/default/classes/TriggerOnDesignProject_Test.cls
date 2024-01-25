@isTest
public class TriggerOnDesignProject_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('bStreet', 'bCity', 'bState', 'bCountry');
    testFactory.createEstimate();
    testFactory.createSalesOrder();
    Test.startTest();
    List<Product2> allProds = new List<Product2>();
    for (Integer i = 1; i <= 2; i++) {
      Product2 prod = new Product2();
      prod.Name = 'Test Prod ' + i;
      prod.Product_Cost__c = 22;
      prod.Sales_Price_Rate__c = 22;
      prod.Sales_Tax_Category__c = 'Nontaxable';
      prod.Purchasing_Info__c = 'Info';
      prod.Supplier__c = 'Alphabroder';
      prod.Design_Project__c = true;
      prod.Product_Supplier_Code__c = 'Code';
      prod.Net_Price__c = 22;
      allProds.add(prod);
    }
    insert allProds;
    testFactory.createProductLineItems();
    testFactory.createProductLineItemsRelatedItems();
    testFactory.createArtWork();
    testFactory.createRunCharge();
    testFactory.createFixedCharge();
    // ConvertToEstimateQuickActionController.convertToEstimateInDb();

    Test.stopTest();
  }
  @isTest
  public static void testDesignProject() {
    String currentuser = UserInfo.getUserId();
    List<User> lstUsers = [
      SELECT id, Design_Bank__c
      FROM User
      WHERE id = :currentuser
    ];
    if (lstUsers.size() > 0) {
      lstUsers.get(0).Design_Bank__c = 20;
      update lstUsers.get(0);
    }
    Order order = [SELECT id FROM Order LIMIT 1];
    Design_Project__c designProject = new Design_Project__c();
    designProject.Work_Order__c = order.id;
    designProject.Name = 'Design Product ';
    insert designProject;
    designProject.Bank_Credits__c = true;
    designProject.Credits__c = 10;
    update designProject;

    designProject.Work_Order__c = null;
    update designProject;
    delete designProject;
  }
}
