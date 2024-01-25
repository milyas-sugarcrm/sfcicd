public class JSON2ApexNewCampaignForm {
  public String email { get; set; }
  public String organizationName { get; set; }
  public String organizationAddress { get; set; }
  public String signorName { get; set; }
  public String signorTitle { get; set; }
  public String signorEmail { get; set; }
  public String legalCompanyName { get; set; }
  public String legalBillingAddress { get; set; }
  public String billingContactName { get; set; }
  public String billingContactEmail { get; set; }
  public String billingContactPhone { get; set; }
  public String paymentMethodStr { get; set; }
  public List<String> paymentMethod { get; set; }
  public String productsOrBrands { get; set; }
  public String eventLocations { get; set; }
  public String campaignPOC { get; set; }
  public String campaignPOCEmail { get; set; }
  public String campaignStartDate { get; set; }
  public String campaignEndDate { get; set; }
  public String productDescription { get; set; }
  public String schedulingResponsible { get; set; }
  public String baAttireRequest { get; set; }
  public String needPOS { get; set; }
  public String materialSummary { get; set; }

  public JSON2ApexNewCampaignForm(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'email') {
            email = parser.getText();
          } else if (text == 'organizationName') {
            organizationName = parser.getText();
          } else if (text == 'organizationAddress') {
            organizationAddress = parser.getText();
          } else if (text == 'signorName') {
            signorName = parser.getText();
          } else if (text == 'signorTitle') {
            signorTitle = parser.getText();
          } else if (text == 'signorEmail') {
            signorEmail = parser.getText();
          } else if (text == 'legalCompanyName') {
            legalCompanyName = parser.getText();
          } else if (text == 'legalBillingAddress') {
            legalBillingAddress = parser.getText();
          } else if (text == 'billingContactName') {
            billingContactName = parser.getText();
          } else if (text == 'billingContactEmail') {
            billingContactEmail = parser.getText();
          } else if (text == 'billingContactPhone') {
            billingContactPhone = parser.getText();
          } else if (text == 'paymentMethod') {
            paymentMethodStr = parser.getText();
            paymentMethod = arrayOfString(parser);
          } else if (text == 'productsOrBrands') {
            productsOrBrands = parser.getText();
          } else if (text == 'eventLocations') {
            eventLocations = parser.getText();
          } else if (text == 'campaignPOC') {
            campaignPOC = parser.getText();
          } else if (text == 'campaignPOCEmail') {
            campaignPOCEmail = parser.getText();
          } else if (text == 'campaignStartDate') {
            campaignStartDate = parser.getText();
          } else if (text == 'campaignEndDate') {
            campaignEndDate = parser.getText();
          } else if (text == 'productDescription') {
            productDescription = parser.getText();
          } else if (text == 'schedulingResponsible') {
            schedulingResponsible = parser.getText();
          } else if (text == 'baAttireRequest') {
            baAttireRequest = parser.getText();
          } else if (text == 'needPOS') {
            needPOS = parser.getText();
          } else if (text == 'materialSummary') {
            materialSummary = parser.getText();
          } else {
            System.debug(
              LoggingLevel.WARN,
              'JSON2ApexNewCampaignForm consuming unrecognized property: ' +
              text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }

  public static JSON2ApexNewCampaignForm parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new JSON2ApexNewCampaignForm(parser);
  }

  public static void consumeObject(System.JSONParser parser) {
    Integer depth = 0;
    do {
      System.JSONToken curr = parser.getCurrentToken();
      if (
        curr == System.JSONToken.START_OBJECT ||
        curr == System.JSONToken.START_ARRAY
      ) {
        depth++;
      } else if (
        curr == System.JSONToken.END_OBJECT ||
        curr == System.JSONToken.END_ARRAY
      ) {
        depth--;
      }
    } while (depth > 0 && parser.nextToken() != null);
  }

  private static List<String> arrayOfString(System.JSONParser p) {
    List<String> res = new List<String>();
    if (p.getCurrentToken() == null)
      p.nextToken();
    while (p.nextToken() != System.JSONToken.END_ARRAY) {
      res.add(p.getText());
    }
    return res;
  }
}
