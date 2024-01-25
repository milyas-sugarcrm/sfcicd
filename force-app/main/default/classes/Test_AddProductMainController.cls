@istest
public class Test_AddProductMainController {
  @TestSetup
  public static void setData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createProducts();
    testFactory.createProductLineItems();

    TestFactory.createFixedCharge();
    TestFactory.createProductLineItemsRelatedItems();
    TestFactory.createRunCharge();
  }
  @isTest
  public static void testGetOpportunityName() {
    Opportunity opp = [SELECT id, Name FROM Opportunity LIMIT 1];
    AddProductMainController.getOpportunityName(opp.Id);
  }
}
