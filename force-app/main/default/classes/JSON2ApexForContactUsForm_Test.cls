@IsTest
public class JSON2ApexForContactUsForm_Test {
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json =
      '{' +
      '    \"firstName\": \"John\",' +
      '    \"lastName\": \"Doe\",' +
      '    \"email\": \"johndoe@example.com\",' +
      '    \"company\": \"ABC Company\",' +
      '    \"Venues\": \"Venue XYZ\",' +
      '    \"phone\": \"123-456-7890\",' +
      '    \"Message\": \"Hello, I\'m interested in your services.\",' +
      '    \"flag\": \"Flag Value\",' +
      '    \"HowDidYouHear\": \"Through a friend\",' +
      '    \"interestedIn\": [' +
      '      \"In Store Demos\",' +
      '      \"Event/Trade Staff\",' +
      '      \"Brand Ambassador\",' +
      '      \"Street Team/Guerrilla Marketing\",' +
      '      \"Experiential Marketing Consulting\"' +
      '    ]' +
      '  }';
    JSON2ApexForContactUsForm r = JSON2ApexForContactUsForm.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    JSON2ApexForContactUsForm objJSON2Apex = new JSON2ApexForContactUsForm(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2Apex != null);
    System.assert(objJSON2Apex.firstName == null);
    System.assert(objJSON2Apex.lastName == null);
    System.assert(objJSON2Apex.email == null);
    System.assert(objJSON2Apex.company == null);
    System.assert(objJSON2Apex.Venues == null);
    System.assert(objJSON2Apex.phone == null);
    System.assert(objJSON2Apex.Message == null);
    System.assert(objJSON2Apex.flag == null);
    System.assert(objJSON2Apex.HowDidYouHear == null);
    System.assert(objJSON2Apex.interestedIn == null);
  }
}
