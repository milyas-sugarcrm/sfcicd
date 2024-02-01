@IsTest
public class JSON2ApexForJoinOurTeamForm_Test {
  // This test method should give 100% coverage
  static testMethod void testParse() {
    String json =
      '{' +
      '  \"first_name\": \"YourFirstName\",' +
      '  \"last_name\": \"YourLastName\",' +
      '  \"email\": \"your.email@example.com\",' +
      '  \"phone\": \"123-456-7890\",' +
      '  \"state_of_residence\": \"Georgia\",' +
      '  \"birthday\": \"01/01/1990\",' +
      '  \"primary_language\": \"Arabic\",' +
      '  \"secondary_language\": \"N/A\",' +
      '  \"brand_activations_experience\": [' +
      '    \"Alcoholic Beverage Promotions\",' +
      '    \"Field Team Lead\",' +
      '    \"Gourmet Food & Beverage Demos & Samplings\",' +
      '    \"Guerrilla Marketing\",' +
      '    \"Merchandising & Market Research\",' +
      '    \"Mobile Tours\",' +
      '    \"On Premise Bar\",' +
      '    \"Road Show Activations (Warehouse/Club Stores)\",' +
      '    \"Special Events & Fundraising Events\",' +
      '    \"Street Teams\"' +
      '  ],' +
      '  \"certifications\": [' +
      '    \"Cicerone (Level 1 or above)\",' +
      '    \"Food & Beverage Handling\",' +
      '    \"Responsible Alcoholic Beverage Serving (TIPS)\",' +
      '    \"Sommelier (Introductory to Master)\",' +
      '    \"State-Mandated Alcoholic Beverage Serving\",' +
      '    \"State-Mandated Food & Beverage Handling\"' +
      '  ],' +
      '  \"rbs_server_id\": \"12345\", ' +
      '  \"pop_bookings_profile\": \"Yes\", ' +
      '  \"supplies\": \"Yes! I have a portable table, black fabric tablecloth, and unbranded neutral color ice bucket\",' +
      '  \"certify_age\": true, ' +
      '  \"hear_about_us\": \"Instagram\",' +
      '  \"referral_name\": \"ReferrerName\" ' +
      '}';
    JSON2ApexForJoinOurTeamForm r = JSON2ApexForJoinOurTeamForm.parse(json);
    System.assert(r != null);

    json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    JSON2ApexForJoinOurTeamForm objJSON2ApexForJoinOurTeamForm = new JSON2ApexForJoinOurTeamForm(
      System.JSON.createParser(json)
    );
    System.assert(objJSON2ApexForJoinOurTeamForm != null);
    System.assert(objJSON2ApexForJoinOurTeamForm.first_name == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.last_name == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.email == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.phone == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.state_of_residence == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.birthday == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.primary_language == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.secondary_language == null);
    System.assert(
      objJSON2ApexForJoinOurTeamForm.brand_activations_experience == null
    );
    System.assert(objJSON2ApexForJoinOurTeamForm.certifications == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.rbs_server_id == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.pop_bookings_profile == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.supplies == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.certify_age == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.hear_about_us == null);
    System.assert(objJSON2ApexForJoinOurTeamForm.referral_name == null);
  }
}
