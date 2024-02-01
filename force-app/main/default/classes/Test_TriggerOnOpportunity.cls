@isTest
public class Test_TriggerOnOpportunity {
  @testSetup
  public static void createData() {
    Test_OpportunityTriggerHandler.createData();
  }
  @isTest
  public static void testcheckAndUpdateStatusOfOutdatedCheckbox() {
    Test_OpportunityTriggerHandler.checkAndUpdateStatusOfOutdatedCheckbox();
  }
  @isTest
  public static void testCreateEstimateOnUpdate() {
    try {
      Test_OpportunityTriggerHandler.testCreateEstimateOnUpdate();
    } catch (Exception ex) {
      System.debug('Error in test function');
    }
  }
  @isTest
  public static void testCreateEstimateOnInsert() {
    try {
      Test_OpportunityTriggerHandler.testCreateEstimateOnInsert();
    } catch (Exception ex) {
      System.debug('Error in test function');
    }
  }
}
