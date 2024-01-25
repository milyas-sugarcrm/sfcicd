public class DataFromWordPress {
  public String firstName { get; set; }
  public String lastName { get; set; }
  public String email { get; set; }
  public String company { get; set; }
  public String title { get; set; }
  public String ASI { get; set; }
  public String phone { get; set; }
  public String Street { get; set; }
  public String City { get; set; }
  public String State { get; set; }
  public String ZipCode { get; set; }
  public String Country { get; set; }
  public String flag { get; set; }
  public List<String> Events { get; set; }
  public String HowDidYouHear { get; set; }

  public DataFromWordPress(JSONParser parser) {
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
          } else if (text == 'title') {
            title = parser.getText();
          } else if (text == 'ASI') {
            ASI = parser.getText();
          } else if (text == 'phone') {
            phone = parser.getText();
          } else if (text == 'Street') {
            Street = parser.getText();
          } else if (text == 'City') {
            City = parser.getText();
          } else if (text == 'State') {
            State = parser.getText();
          } else if (text == 'ZipCode') {
            ZipCode = parser.getText();
          } else if (text == 'Country') {
            Country = parser.getText();
          } else if (text == 'flag') {
            flag = parser.getText();
          } else if (text == 'Events') {
            Events = arrayOfString(parser);
          } else if (text == 'HowDidYouHear') {
            HowDidYouHear = parser.getText();
          } else {
            consumeObject(parser);
          }
        }
      }
    }
  }

  public static DataFromWordPress parse(String json) {
    System.JSONParser parser = System.JSON.createParser(json);
    return new DataFromWordPress(parser);
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
