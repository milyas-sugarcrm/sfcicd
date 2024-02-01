@isTest
public class OpportunityStageUpdate_Test {
  @testSetup
  public static void populateData() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('bStreet', 'bCity', 'bState', 'bCountry');
    testFactory.createEstimate();
  }
  @isTest
  public static void testCreateEstimateWithoutProductsInDb() {
    try {
      Test.setMock(HttpCalloutMock.class, new MockTestResponse());
      Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
      OpportunityStageUpdate.getAccountDropDown(opp.Id);
      OpportunityStageUpdate.createEstimateWithoutProductsInDb(
        opp.Id,
        'Team tr456[[]] Phun'
      );
    } catch (Exception ex) {
    }
  }
  @isTest
  public static void testChangeStateOfOpportunityInDb() {
    try {
      Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
      OpportunityStageUpdate.changeStateOfOpportunityInDb(
        opp.Id,
        'Sales',
        null
      );
    } catch (Exception ex) {
    }
  }
  @isTest
  public static void testupdateStage() {
    try {
      Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
      OpportunityStageUpdate.updateStage('Sales', opp.Id);
    } catch (Exception ex) {
    }
  }

  @isTest
  public static void testgetStage() {
    try {
      Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
      OpportunityStageUpdate.getStage(opp.Id);
    } catch (Exception ex) {
    }
  }
  @isTest
  public static void testCheckEstimateExists() {
    try {
      Opportunity opp = [SELECT Id, StageName FROM Opportunity LIMIT 1];
      OpportunityStageUpdate.checkEstimateExists(opp.Id);
    } catch (Exception ex) {
    }
  }
}
