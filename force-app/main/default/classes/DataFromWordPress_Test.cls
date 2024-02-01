@IsTest
public class DataFromWordPress_Test {
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json =
      '{' +
      '  \"firstName\": \"Alex\",' +
      '  \"lastName\": \"Johnson\",' +
      '  \"email\": \"alexjohnson@example.com\",' +
      '  \"company\": \"Tech Innovators\",' +
      '  \"title\": \"Product Manager\",' +
      '  \"ASI\": \"543210\",' +
      '  \"phone\": \"777-888-9999\",' +
      '  \"Street\": \"789 Elm Street\",' +
      '  \"City\": \"Techville\",' +
      '  \"State\": \"ST\",' +
      '  \"ZipCode\": \"12345\",' +
      '  \"flag\": \"true\",' +
      '  \"Events\": [' +
      '    \"EME Exclusive #3 August 4-7, 2024, Westgate Park City Resort & Spa, Park City, UT\"' +
      '  ],' +
      '  \"HowDidYouHear\": \"Social Media\"' +
      '}';
    DataFromWordPress r = DataFromWordPress.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    DataFromWordPress objJSON2Apex = new DataFromWordPress(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2Apex != null);
    System.assert(objJSON2Apex.firstName == null);
    System.assert(objJSON2Apex.lastName == null);
    System.assert(objJSON2Apex.email == null);
    System.assert(objJSON2Apex.company == null);
    System.assert(objJSON2Apex.title == null);
    System.assert(objJSON2Apex.ASI == null);
    System.assert(objJSON2Apex.phone == null);
    System.assert(objJSON2Apex.Street == null);
    System.assert(objJSON2Apex.City == null);
    System.assert(objJSON2Apex.State == null);
    System.assert(objJSON2Apex.ZipCode == null);
    System.assert(objJSON2Apex.flag == null);
    System.assert(objJSON2Apex.Events == null);
    System.assert(objJSON2Apex.HowDidYouHear == null);
  }
}
