@isTest
private class DemoControllerTests1 {
  @isTest
  static void testGetAppVersion1() {
    DemoController demo = new DemoController();
    System.assertEquals(demo.getAppVersion(), '1.0.0', 'OK');
  }
}
