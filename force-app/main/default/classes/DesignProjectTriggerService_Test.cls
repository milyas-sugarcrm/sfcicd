@isTest
public class DesignProjectTriggerService_Test {
  @testSetup
  public static void createData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('bStreet', 'bCity', 'bState', 'bCountry');
    testFactory.createEstimate();
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
    Test.stopTest();
  }
  @isTest
  public static void testDesignProject() {
    Test.startTest();
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
    Estimate__c estimate = [SELECT id FROM Estimate__c LIMIT 1];
    Design_Project__c designProject = new Design_Project__c();

    designProject.Name = 'Design Product ';
    designProject.Estimate__c = estimate.id;
    insert designProject;
    designProject.Bank_Credits__c = true;
    designProject.Credits__c = 10;
    update designProject;

    Product2 prod = new Product2();
    prod.Name = 'Test Prod';
    prod.Product_Cost__c = 22;
    prod.Sales_Price_Rate__c = 22;
    prod.Sales_Tax_Category__c = 'Nontaxable';
    prod.Purchasing_Info__c = 'Info';
    prod.Supplier__c = 'Alphabroder';
    prod.Product_Supplier_Code__c = 'Code';
    prod.Net_Price__c = 22;
    insert prod;

    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    update standardPricebook;
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = prod.Id,
      UnitPrice = 1020,
      IsActive = true
    );

    insert pbe;

    Order order = new Order();
    Opportunity opp = [
      SELECT id, AccountId, Contact__c
      FROM Opportunity
      LIMIT 1
    ];
    order.OpportunityId = opp.id;
    order.Invoice_Number__c = 'SalesOrder-' + opp.id;
    order.Status = '01_-_Waiting_for_Client_Payment';
    order.EffectiveDate = system.today();
    order.Invoice_Terms__c = 'Credit Card';
    order.Primary_Contact__c = opp.Contact__c;
    order.AccountId = opp.AccountId;
    order.Invoice_Value__c = 0;
    order.Invoice_Tax__c = 0;
    order.Invoice_Discount__c = 0;
    order.Invoice_Due_Date__c = system.today();
    order.Invoice_Total__c = 0;
    order.Invoice_Estimated_Ship_Date__c = '';
    insert order;
    designProject.Work_Order__c = order.id;
    designProject.Estimate__c = null;
    update designProject;
    designProject.Bank_Credits__c = false;
    update designProject;
    designProject.Bank_Credits__c = true;
    update designProject;
    delete designProject;
    Test.stopTest();
  }
}
