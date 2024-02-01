@isTest
public class customLookUpController_Test {
  @TestSetup
  public static void createData() {
    TestFactory tf = new TestFactory(1);
    tf.createOpportunities();
    tf.createAccount('testStreet', 'testCity', 'testState', 'testCountry');
    tf.createEstimate();
  }

  @isTest
  public static void testfetchLookUpValues() {
    List<Account> lstDecorators = customLookUpController.fetchLookUpValues(
      'testStreet',
      'account',
      'vendor,decorator'
    );
    System.assertEquals(lstDecorators.size(), 0);
    List<Account> lstSuppliers = customLookUpController.fetchLookUpValues(
      '',
      'account',
      'vendor'
    );
    System.assertEquals(lstSuppliers.size(), 0);
    List<Account> lstAccounts = customLookUpController.fetchLookUpValues(
      '',
      'account',
      ''
    );
    System.assertEquals(lstAccounts.size(), 1);
    List<Account> lstAcc = [SELECT id, Name FROM Account];
    if (lstAcc.size() > 0) {
      customLookUpController.fetchLookUpValues(
        '',
        'address__c',
        JSON.serialize(lstAcc.get(0))
      );
      customLookUpController.getObjectRecord('account', lstAcc.get(0).Id);
      customLookUpController.getAccountAddress(lstAcc.get(0).Id);
    }
  }
}
