@isTest
public class TestConstants {
  @isTest
  static void testAllConstants() {
    Constants obj = new Constants();
    System.assertEquals(
      'PFA Customer Lead',
      Constants.PFA_CUSTOMER_LEAD_LABEL,
      'Invalid PFA_CUSTOMER_LEAD_LABEL'
    );
    System.assertEquals(
      'Vendor Lead',
      Constants.VENDOR_LEAD_LABEL,
      'Invalid VENDOR_LEAD_LABEL'
    );
    System.assertEquals(
      'Customer Lead',
      Constants.CUSTOMER_LEAD_LABEL,
      'Invalid CUSTOMER_LEAD_LABEL'
    );

    System.assertEquals(
      'Opportunity',
      Constants.OPPORTUNITY_API_NAME,
      'Invalid OPPORTUNITY_API_NAME'
    );
    System.assertEquals(
      'Default Opportunity',
      Constants.DEFAULT_OPPORTUNITY,
      'Invalid DEFAULT_OPPORTUNITY'
    );
    System.assertEquals(
      'PFA Customer Opportunity',
      Constants.PFA_CUSTOMER_OPPORTUNITY,
      'Invalid PFA_CUSTOMER_OPPORTUNITY'
    );

    System.assertEquals('New', Constants.NEW_STATUS, 'Invalid NEW_STATUS');

    System.assertEquals(
      'Prepare SOW',
      Constants.PREPARE_SOW_STAGE,
      'Invalid PREPARE_SOW_STAGE'
    );

    System.assertEquals(
      'Product2',
      Constants.PRODUCT2_API_NAME,
      'Invalid PRODUCT2_API_NAME'
    );
    System.assertEquals(
      'PFA Product',
      Constants.PFA_PRODUCT,
      'Invalid PFA_PRODUCT'
    );
  }
}
