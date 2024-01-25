@isTest
public class Test_ProductTriggerService {
  @isTest
  public static void testUpdateIsExistsField() {
    TestFactory testFactory = new TestFactory(5);
    testFactory.createProducts();

    delete [SELECT Id FROM Product2];
  }
}
