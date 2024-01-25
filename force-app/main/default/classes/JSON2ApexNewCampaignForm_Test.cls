@IsTest
public class JSON2ApexNewCampaignForm_Test {
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json =
      '{' +
      '  \"email\": \"emilyjohnson@example.com\",' +
      '  \"organizationName\": \"ABC Corp\",' +
      '  \"organizationAddress\": \"123 Main Street\",' +
      '  \"signorName\": \"John Smith\",' +
      '  \"signorTitle\": \"CEO\",' +
      '  \"signorEmail\": \"john.smith@example.com\",' +
      '  \"legalCompanyName\": \"ABC Corporation\",' +
      '  \"legalBillingAddress\": \"456 Legal Ave\",' +
      '  \"billingContactName\": \"Jane Doe\",' +
      '  \"billingContactEmail\": \"jane.doe@example.com\",' +
      '  \"billingContactPhone\": \"555-123-4567\",' +
      '  \"paymentMethod\": [\"Credit Card\", \"ACH Transfer\"],' +
      '  \"productsOrBrands\": \"Product X, Brand Y\",' +
      '  \"eventLocations\": \"Venue A, Venue B\",' +
      '  \"campaignPOC\": \"Sarah Johnson\",' +
      '  \"campaignPOCEmail\": \"sarah.johnson@example.com\",' +
      '  \"campaignStartDate\": \"2023-09-01\",' +
      '  \"campaignEndDate\": \"2023-09-30\",' +
      '  \"productDescription\": \"Description of Product X\",' +
      '  \"schedulingResponsible\": \"Mark Davis\",' +
      '  \"baAttireRequest\": \"attire option value\",' +
      '  \"needPOS\": \"Yes\",' +
      '  \"materialSummary\": \"10 promotional items for each event.\"' +
      '}';
    JSON2ApexNewCampaignForm r = JSON2ApexNewCampaignForm.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    JSON2ApexNewCampaignForm objJSON2ApexNewCampaignForm = new JSON2ApexNewCampaignForm(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2ApexNewCampaignForm != null);
    System.assert(objJSON2ApexNewCampaignForm.email == null);
    System.assert(objJSON2ApexNewCampaignForm.organizationName == null);
    System.assert(objJSON2ApexNewCampaignForm.organizationAddress == null);
    System.assert(objJSON2ApexNewCampaignForm.signorName == null);
    System.assert(objJSON2ApexNewCampaignForm.signorTitle == null);
    System.assert(objJSON2ApexNewCampaignForm.signorEmail == null);
    System.assert(objJSON2ApexNewCampaignForm.legalCompanyName == null);
    System.assert(objJSON2ApexNewCampaignForm.legalBillingAddress == null);
    System.assert(objJSON2ApexNewCampaignForm.billingContactName == null);
    System.assert(objJSON2ApexNewCampaignForm.billingContactEmail == null);
    System.assert(objJSON2ApexNewCampaignForm.billingContactPhone == null);
    System.assert(objJSON2ApexNewCampaignForm.paymentMethod == null);
    System.assert(objJSON2ApexNewCampaignForm.productsOrBrands == null);
    System.assert(objJSON2ApexNewCampaignForm.eventLocations == null);
    System.assert(objJSON2ApexNewCampaignForm.campaignPOC == null);
    System.assert(objJSON2ApexNewCampaignForm.campaignPOCEmail == null);
    System.assert(objJSON2ApexNewCampaignForm.campaignStartDate == null);
    System.assert(objJSON2ApexNewCampaignForm.campaignEndDate == null);
    System.assert(objJSON2ApexNewCampaignForm.productDescription == null);
    System.assert(objJSON2ApexNewCampaignForm.schedulingResponsible == null);
    System.assert(objJSON2ApexNewCampaignForm.baAttireRequest == null);
    System.assert(objJSON2ApexNewCampaignForm.needPOS == null);
    System.assert(objJSON2ApexNewCampaignForm.materialSummary == null);
  }
}
