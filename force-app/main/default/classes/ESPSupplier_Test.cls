@isTest
public class ESPSupplier_Test {
  @isTest
  public static void testParseSupplier() {
    String jsonData =
      '{"Results": [ { "Id": 2180,  "Name": "Leeds",  "AsiNumber": "66887", "Address": {' +
      '"Street1": "400 Hunt Valley Rd","City": "New Kensington","State": "PA","Zip": "15068-7059",' +
      '"Country": "US" }, "Phone": {"Work": "(724) 334-9000","TollFree": "(866) LEE-DS24","$index": 1' +
      '}, "Fax": "(800) 860-6661", "Email": "customerservice@leedsworld.com",' +
      '"Websites": [ "https://www.pcna.com/Leeds/en-us" ],"Products": 2598,"Rating": { ' +
      '"Rating": 9,  "Companies": 183, "Transactions": 1873 }}], "Selections": {}, "Dimensions": {},' +
      ' "Links": {"Self": "?q=66887&page=1&rpp=10&sort=DFLT"},"Query": "66887","Page": 1, "ResultsPerPage": 10,' +
      ' "ResultsTotal": 1, "CompletedIn": 0.50000369999999994}';
    ESPSupplier.parse(jsonData);
  }
}
