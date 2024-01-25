@isTest
private class OpportunityDeleteScheduler_Test {
  @isTest
  static void testOpportunityDeleteScheduler() {
    TestFactory testFactory = new TestFactory(1);
    testFactory.createOpportunities();
    testFactory.createAccount('test', 'test', 'test', 'test');

    List<Opportunity> opportunitiesToDelete = [SELECT id FROM Opportunity];
    List<Id> opportunityIdsToDelete = new List<Id>();
    for (Opportunity opp : opportunitiesToDelete) {
      opportunityIdsToDelete.add(opp.Id);
    }

    Test.startTest();
    Datetime dt = System.now().addMinutes(1);
    String cronExp =
      dt.second() +
      ' ' +
      dt.minute() +
      ' ' +
      dt.hour() +
      ' ' +
      dt.day() +
      ' ' +
      dt.month() +
      ' ? ' +
      dt.year();
    System.schedule(
      cronExp,
      cronExp,
      new OpportunityDeleteScheduler(opportunityIdsToDelete)
    );
    Test.stopTest();
  }
}
