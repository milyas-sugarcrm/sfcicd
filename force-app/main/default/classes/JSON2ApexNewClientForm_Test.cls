@IsTest
public class JSON2ApexNewClientForm_Test {
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
    JSON2ApexNewClientForm r = JSON2ApexNewClientForm.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    JSON2ApexNewClientForm objJSON2ApexNewClientForm = new JSON2ApexNewClientForm(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2ApexNewClientForm != null);
    System.assert(objJSON2ApexNewClientForm.email == null);
    System.assert(objJSON2ApexNewClientForm.organizationName == null);
    System.assert(objJSON2ApexNewClientForm.organizationAddress == null);
    System.assert(objJSON2ApexNewClientForm.signorName == null);
    System.assert(objJSON2ApexNewClientForm.signorTitle == null);
    System.assert(objJSON2ApexNewClientForm.signorEmail == null);
    System.assert(objJSON2ApexNewClientForm.legalCompanyName == null);
    System.assert(objJSON2ApexNewClientForm.legalBillingAddress == null);
    System.assert(objJSON2ApexNewClientForm.billingContactName == null);
    System.assert(objJSON2ApexNewClientForm.billingContactEmail == null);
    System.assert(objJSON2ApexNewClientForm.billingContactPhone == null);
    System.assert(objJSON2ApexNewClientForm.paymentMethod == null);
    System.assert(objJSON2ApexNewClientForm.productsOrBrands == null);
    System.assert(objJSON2ApexNewClientForm.eventLocations == null);
    System.assert(objJSON2ApexNewClientForm.campaignPOC == null);
    System.assert(objJSON2ApexNewClientForm.campaignPOCEmail == null);
    System.assert(objJSON2ApexNewClientForm.campaignStartDate == null);
    System.assert(objJSON2ApexNewClientForm.campaignEndDate == null);
    System.assert(objJSON2ApexNewClientForm.productDescription == null);
    System.assert(objJSON2ApexNewClientForm.schedulingResponsible == null);
    System.assert(objJSON2ApexNewClientForm.baAttireRequest == null);
    System.assert(objJSON2ApexNewClientForm.needPOS == null);
    System.assert(objJSON2ApexNewClientForm.materialSummary == null);
  }
}
