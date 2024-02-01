@isTest
public class Test_QuickbookConnection {
  @isTest
  public static void testQuickbookConnection() {
    TestFactory testFactory = new TestFactory();
    testFactory.createConfiguration();
    QuickbookConnection conn = new QuickbookConnection();
    conn.selectedQBAccount = 'Team Phun';
    conn.getQbCred();
    conn.doAuthorizationQuickBooks();
    conn.quickbooksAccountsList = new List<SelectOption>();
    List<SelectOption> lstSelected = conn.quickbooksAccountsList;
    List<QuickbookConnection.OptionsClass> lstAccounts = conn.quickbooksAccounts;
    //  conn.getquickbooksAccounts();
    // conn.getquickbooksAccountsList();
  }

  @isTest
  public static void testFetchAccessToken() {
    TestFactory testFactory = new TestFactory();
    testFactory.createConfiguration();
    Test.setMock(HttpCalloutMock.class, new MockTestResponse());
    PageReference page = new PageReference('/apex/QuickbookAuthentication');
    page.getParameters().put('code', '112233445566778899');
    page.getParameters().put('realmId', '7735254');
    Test.setCurrentPage(page);
    QuickbookConnection newConn = new QuickbookConnection();
    newConn.selectedQBAccount = 'Team Phun';

    // newConn.doFetchAccessToken();
    Test.startTest();
    newConn.doFetchAccessToken();
    Test.stopTest();
  }
}
