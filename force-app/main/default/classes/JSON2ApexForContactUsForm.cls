public class JSON2ApexForContactUsForm {
  public String firstName { get; set; }
  public String lastName { get; set; }
  public String email { get; set; }
  public String company { get; set; }
  public String Venues { get; set; }
  public String phone { get; set; }
  public String Message { get; set; }
  public String flag { get; set; }
  public String HowDidYouHear { get; set; }
  public List<String> interestedIn { get; set; }

  public JSON2ApexForContactUsForm(JSONParser parser) {
    while (parser.nextToken() != System.JSONToken.END_OBJECT) {
      if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
        String text = parser.getText();
        if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
          if (text == 'firstName') {
            firstName = parser.getText();
          } else if (text == 'lastName') {
            lastName = parser.getText();
          } else if (text == 'email') {
            email = parser.getText();
          } else if (text == 'company') {
            company = parser.getText();
          } else if (text == 'Venues') {
            Venues = parser.getText();
          } else if (text == 'phone') {
            phone = parser.getText();
          } else if (text == 'Message') {
            Message = parser.getText();
          } else if (text == 'flag') {
            flag = parser.getText();
          } else if (text == 'HowDidYouHear') {
            HowDidYouHear = parser.getText();
          } else if (text == 'interestedIn') {
            interestedIn = arrayOfString(parser);
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

  public static JSON2ApexForContactUsForm parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new JSON2ApexForContactUsForm(parser);
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
