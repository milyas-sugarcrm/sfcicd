public class JSON2ApexForJoinOurTeamForm {
  public String first_name { get; set; }
  public String last_name { get; set; }
  public String email { get; set; }
  public String phone { get; set; }
  public String state_of_residence { get; set; }
  public String birthday { get; set; }
  public String primary_language { get; set; }
  public String secondary_language { get; set; }
  public List<String> brand_activations_experience { get; set; }
  public List<String> certifications { get; set; }
  public String rbs_server_id { get; set; }
  public String pop_bookings_profile { get; set; }
  public String supplies { get; set; }
  public String certify_age { get; set; }
  public String hear_about_us { get; set; }
  public String referral_name { get; set; }
  public Blob Headshot_Photo { get; set; }
  public Blob Full_Length_Photo { get; set; }
  public Blob Additional_Image { get; set; }

  public JSON2ApexForJoinOurTeamForm(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'first_name') {
            first_name = parser.getText();
          } else if (text == 'last_name') {
            last_name = parser.getText();
          } else if (text == 'email') {
            email = parser.getText();
          } else if (text == 'phone') {
            phone = parser.getText();
          } else if (text == 'state_of_residence') {
            state_of_residence = parser.getText();
          } else if (text == 'birthday') {
            birthday = parser.getText();
          } else if (text == 'primary_language') {
            primary_language = parser.getText();
          } else if (text == 'secondary_language') {
            secondary_language = parser.getText();
          } else if (text == 'brand_activations_experience') {
            brand_activations_experience = arrayOfString(parser);
          } else if (text == 'certifications') {
            certifications = arrayOfString(parser);
          } else if (text == 'rbs_server_id') {
            rbs_server_id = parser.getText();
          } else if (text == 'pop_bookings_profile') {
            pop_bookings_profile = parser.getText();
          } else if (text == 'supplies') {
            supplies = parser.getText();
          } else if (text == 'certify_age') {
            certify_age = parser.getText();
          } else if (text == 'hear_about_us') {
            hear_about_us = parser.getText();
          } else if (text == 'Headshot_Photo') {
            Headshot_Photo = EncodingUtil.base64Decode(parser.getText());
          } else if (text == 'Full_Length_Photo') {
            Full_Length_Photo = EncodingUtil.base64Decode(parser.getText());
          } else if (text == 'Additional_Image') {
            Additional_Image = EncodingUtil.base64Decode(parser.getText());
          } else if (text == 'referral_name') {
            referral_name = parser.getText();
          } else {
            System.debug(
              LoggingLevel.WARN,
              'JSON2Apex consuming unrecognized property: ' + text
            );
            consumeObject(parser);
          }
        }
      }
    }
  }
  public static JSON2ApexForJoinOurTeamForm parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new JSON2ApexForJoinOurTeamForm(parser);
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
