@isTest
public class MockTestResponse implements HttpCalloutMock {
  public HTTPResponse respond(HTTPRequest req) {
    HttpResponse res = new HttpResponse();
    res.setHeader('Content-Type', 'application/json');
    res.setStatusCode(200);
    system.debug(' req.getEndpoint()---->>>>>' + req.getEndpoint());
    if (req.getEndpoint() == 'http://test.com/test/refreshtoken') {
      res.setBody(
        '{' +
          '"token_type": "bearer",' +
          '"expires_in": 3600,' +
          '"refresh_token":"Q311488394272qbajGfLBwGmVsbF6VoNpUKaIO5oL49aXLVJUB",' +
          '"x_refresh_token_expires_in":15551893,' +
          '"access_token":"eJlbmMiOiJBMTI4Q0JDLUhTMjU2IiwiYWxnIjoiZGGlyIn0..KM1_Fezsm6BUSaqqfTedaA.' +
          'dBUCZWiVmjH8CdpXeh_pmaM3kJlJkLEqJlfmavwGQDThcf94fbj9nBZkjEPLvBcQznJnEmltCIvsTGX0ue_w45h7_' +
          'yn1zBoOb-1QIYVE0E5TI9z4tMUgQNeUkD1w-X8ECVraeOEecKaqSW32Oae0yfKhDFbwQZnptbPzIDaqiduiM_q' +
          'EFcbAzT-7-znVd09lE3BTpdMF9MYqWdI5wPqbP8okMI0l8aa-UVFDH9wtli80zhHb7GgI1eudqRQc0sS9zWWb' +
          'I-eRcIhjcIndNUowSFCrVcYG6_kIj3uRUmIV-KjJUeXdSV9kcTAWL9UGYoMnTPQemStBd2thevPUuvKrPdz3ED' +
          'ft-RVRLQYUJSJ1oA2Q213Uv4kFQJgNinYuG9co_qAE6A2YzVn6A8jCap6qGR6vWHFoLjM2TutVd6eOeYoL2bb7jl' +
          'QALEpYGj4E1h3y2xZITWvnmI0CEL_dYQX6B3QTO36TDaVl9WnTaCCgAcP6bt70rFlPYbCjOxLoI6qFm5pUwGLLp' +
          '67JZ36grc58k7NIyKJ8dLJUL_Q9r1WoUvw.ZS298t_u7dSlkfajxLfO9Q"' +
          '}'
      );
    } else if (
      req.getEndpoint() == 'http://test.com/test/sendCustomer' ||
      req.getEndpoint() == 'http://test.com/test/sendVendor'
    ) {
      res.setBody(
        '{' +
          (req.getEndpoint() == 'http://test.com/test/sendCustomer'
            ? '"Customer"'
            : '"Vendor"') +
          ': {' +
          '"domain": "QBO",' +
          '"DisplayName": "King\'s Groceries",' +
          '"CurrencyRef": {' +
          '"name": "United States Dollar",' +
          '"value": "USD"' +
          '}, ' +
          '"GivenName": "James",' +
          '"FullyQualifiedName": "King\'s Groceries",' +
          '"BillWithParent": false, ' +
          '"Title": "Mr", ' +
          '"Job": false, ' +
          '"MetaData": {' +
          '"CreateTime": "2015-07-23T10:58:12-07:00",' +
          '"LastUpdatedTime": "2015-07-23T10:58:12-07:00"' +
          '}, ' +
          '"MiddleName": "B",' +
          '"Notes": "Here are other details.",' +
          '"Active": true, ' +
          '"Balance": 0, ' +
          '"SyncToken": "0",' +
          '"Suffix": "Jr", ' +
          '"CompanyName": "King Groceries",' +
          '"FamilyName": "King", ' +
          '"Id": "1"' +
          '}, ' +
          '"time": "2015-07-23T10:58:12.099-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/sendEstimate') {
      res.setBody(
        '{' +
          '"Estimate": {' +
          '"DocNumber": "1001", ' +
          '"SyncToken": "0", ' +
          '"domain": "QBO", ' +
          '"TxnStatus": "Pending", ' +
          '"BillEmail": {' +
          '"Address": "Cool_Cars@intuit.com"' +
          '}, ' +
          '"TxnDate": "2015-03-26", ' +
          '"TotalAmt": 31.5, ' +
          '"CustomerRef": {' +
          '"name": "Cool Cars",' +
          '"value": "3"' +
          '}, ' +
          '"CustomerMemo": {' +
          '"value": "Thank you for your business and have a great day!"' +
          '}, ' +
          '"ShipAddr": {' +
          '"CountrySubDivisionCode": "CA",' +
          '"City": "Half Moon Bay",' +
          '"PostalCode": "94213", ' +
          '"Id": "104", ' +
          '"Line1": "65 Ocean Dr."' +
          '}, ' +
          '"PrintStatus": "NeedToPrint",' +
          '"BillAddr": {' +
          '"CountrySubDivisionCode": "CA", ' +
          '"City": "Half Moon Bay", ' +
          '"PostalCode": "94213",' +
          '"Id": "103", ' +
          '"Line1": "65 Ocean Dr."' +
          '}, ' +
          '"sparse": false, ' +
          '"EmailStatus": "NotSet", ' +
          '"Line": [' +
          '{' +
          '"Description": "Pest Control Services", ' +
          '"DetailType": "SalesItemLineDetail", ' +
          '"SalesItemLineDetail": {' +
          '"TaxCodeRef": {' +
          '"value": "NON"' +
          '}, ' +
          '"Qty": 1,' +
          '"UnitPrice": 35,' +
          '"ItemRef": {' +
          '"name": "Pest Control",' +
          '"value": "10"' +
          '}' +
          '},' +
          '"LineNum": 1,' +
          '"Amount": 35.0,' +
          '"Id": "1"' +
          '}, ' +
          '{' +
          '"DetailType": "SubTotalLineDetail",' +
          '"Amount": 35.0, ' +
          '"SubTotalLineDetail": {}' +
          '}, ' +
          '{' +
          '"DetailType": "DiscountLineDetail",' +
          '"Amount": 3.5, ' +
          '"DiscountLineDetail": {' +
          '"DiscountAccountRef": {' +
          '"name": "Discounts given",' +
          '"value": "86"' +
          '}, ' +
          '"PercentBased": true, ' +
          '"DiscountPercent": 10' +
          '}' +
          '}' +
          '],' +
          '"ApplyTaxAfterDiscount": false,' +
          '"CustomField": [' +
          '{' +
          '"DefinitionId": "1",' +
          '"Type": "StringType",' +
          '"Name": "Crew #"' +
          '}' +
          '],' +
          '"Id": "1", ' +
          '"TxnTaxDetail": {' +
          '"TotalTax": 0' +
          '}, ' +
          '"MetaData": {' +
          '"CreateTime": "2015-03-26T13:25:05-07:00",' +
          '"LastUpdatedTime": "2015-03-26T13:25:05-07:00"' +
          '}' +
          '},' +
          '"time": "2015-03-26T13:25:05.473-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getSyncToken') {
      system.debug('test---->>>>sync tokemn');
      res.setBody(
        '{' +
          '"QueryResponse": {' +
          '"Estimate": [' +
          '{' +
          '"sparse": true,' +
          '"Id": "1",' +
          '"SyncToken": "0",' +
          '"Line": [],' +
          '"BillAddr": {' +
          '"Id": "8789"' +
          '},' +
          '"ShipFromAddr": {' +
          '"Id": "8790"' +
          '}' +
          '},' +
          '{' +
          '"sparse": true,' +
          '"Id": "43603",' +
          '"SyncToken": "2",' +
          '"Line": [],' +
          '"BillAddr": {' +
          '"Id": "8773"' +
          '}' +
          '},' +
          '{' +
          '"sparse": true,' +
          '"Id": "43600",' +
          '"SyncToken": "1",' +
          '"Line": [],' +
          '"BillAddr": {' +
          '"Id": "8069"' +
          '}' +
          '},' +
          '{' +
          '"sparse": true,' +
          '"Id": "43601",' +
          '"SyncToken": "1",' +
          '"Line": [],' +
          '"BillAddr": {' +
          '"Id": "8046"' +
          '}' +
          '},' +
          '{' +
          '"sparse": true,' +
          '"Id": "43605",' +
          '"SyncToken": "1",' +
          '"Line": [],' +
          '"BillAddr": {' +
          '"Id": "5024"' +
          '}' +
          '}' +
          '],' +
          '"startPosition": 1,' +
          '"maxResults": 5' +
          '},' +
          ' "time": "2020-03-05T20:41:30.779-08:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getInvoice') {
      List<Opportunity> opps = [SELECT id FROM Opportunity LIMIT 1];
      Id oppId;
      if (opps != null && opps.size() > 0) {
        oppId = opps.get(0).id;
      }
      res.setBody(
        '{' +
          '"QueryResponse":{' +
          '"startPosition":1,' +
          '"totalCount":1,' +
          '"maxResults":1,' +
          '"Invoice":[' +
          '{' +
          '"DocNumber":"1070",' +
          '"SyncToken":"0",' +
          '"domain":"QBO",' +
          '"Balance":150.0,' +
          '"BillAddr":{' +
          '"City":"Bayshore",' +
          '"Line1":"4581FinchSt.",' +
          '"PostalCode":"94326",' +
          '"Lat":"INVALID",' +
          '"Long":"INVALID",' +
          '"CountrySubDivisionCode":"CA",' +
          '"Id":"2"' +
          '},' +
          '"TxnDate":"2015-07-24",' +
          '"TotalAmt":150.0,' +
          '"CustomerRef":{' +
          '"name":"Amy\'sBirdSanctuary",' +
          '"value":"123"' +
          '},' +
          '"ShipAddr":{' +
          '"City":"Bayshore",' +
          '"Line1":"4581FinchSt.",' +
          '"PostalCode":"94326",' +
          '"Lat":"INVALID",' +
          '"Long":"INVALID",' +
          '"CountrySubDivisionCode":"CA",' +
          '"Id":"109"' +
          '},' +
          '"LinkedTxn":[],' +
          '"DueDate":"2015-08-23",' +
          '"PrintStatus":"NeedToPrint",' +
          '"Deposit":0,' +
          '"sparse":false,' +
          '"EmailStatus":"NotSet",' +
          '"Line":[' +
          '{' +
          '"LineNum":1,' +
          '"Amount":150.0,' +
          '"SalesItemLineDetail":{' +
          '"TaxCodeRef":{' +
          '"value":"NON"' +
          '},' +
          '"ItemRef":{' +
          '"name":"Services",' +
          '"value":"1"' +
          '}' +
          '},' +
          '"Id":"1",' +
          '"DetailType":"SalesItemLineDetail"' +
          '},' +
          '{' +
          '"DetailType":"SubTotalLineDetail",' +
          '"Amount":150.0,' +
          '"SubTotalLineDetail":{}' +
          '}' +
          '],' +
          '"ApplyTaxAfterDiscount":false,' +
          '"CustomField":[' +
          '{' +
          '"DefinitionId":"1",' +
          '"Type":"StringType",' +
          '"Name":"Crew#"' +
          '}' +
          '{' +
          '"DefinitionId":"2",' +
          '"Name":"SF Opportunity"' +
          '"Type":"StringType",' +
          '"StringValue":' +
          oppId +
          '}' +
          '],' +
          '"Id":"239",' +
          '"TxnTaxDetail":{' +
          '"TotalTax":0' +
          '},' +
          '"MetaData":{' +
          '"CreateTime":"2015-07-24T10:35:08-07:00",' +
          '"LastUpdatedTime":"2015-07-24T10:35:08-07:00"' +
          '}' +
          '}' +
          ']' +
          '},' +
          '"time":"2015-07-24T10:38:50.01-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getEstimate') {
      res.setBody(
        '{' +
          '"QueryResponse":{' +
          '"startPosition":1,' +
          '"totalCount":1,' +
          '"maxResults":1,' +
          '"Estimate":[' +
          '{' +
          '"DocNumber":"1070",' +
          '"SyncToken":"0",' +
          '"domain":"QBO",' +
          '"Balance":150.0,' +
          '"BillAddr":{' +
          '"City":"Bayshore",' +
          '"Line1":"4581FinchSt.",' +
          '"PostalCode":"94326",' +
          '"Lat":"INVALID",' +
          '"Long":"INVALID",' +
          '"CountrySubDivisionCode":"CA",' +
          '"Id":"2"' +
          '},' +
          '"TxnDate":"2015-07-24",' +
          '"TotalAmt":150.0,' +
          '"CustomerRef":{' +
          '"name":"Amy\'sBirdSanctuary",' +
          '"value":"1"' +
          '},' +
          '"ShipAddr":{' +
          '"City":"Bayshore",' +
          '"Line1":"4581FinchSt.",' +
          '"PostalCode":"94326",' +
          '"Lat":"INVALID",' +
          '"Long":"INVALID",' +
          '"CountrySubDivisionCode":"CA",' +
          '"Id":"109"' +
          '},' +
          '"LinkedTxn":[],' +
          '"DueDate":"2015-08-23",' +
          '"PrintStatus":"NeedToPrint",' +
          '"Deposit":0,' +
          '"sparse":false,' +
          '"EmailStatus":"NotSet",' +
          '"Line":[' +
          '{' +
          '"LineNum":1,' +
          '"Amount":150.0,' +
          '"SalesItemLineDetail":{' +
          '"TaxCodeRef":{' +
          '"value":"NON"' +
          '},' +
          '"ItemRef":{' +
          '"name":"Services",' +
          '"value":"1"' +
          '}' +
          '},' +
          '"Id":"1",' +
          '"DetailType":"SalesItemLineDetail"' +
          '},' +
          '{' +
          '"DetailType":"SubTotalLineDetail",' +
          '"Amount":150.0,' +
          '"SubTotalLineDetail":{}' +
          '}' +
          '],' +
          '"ApplyTaxAfterDiscount":false,' +
          '"CustomField":[' +
          '{' +
          '"DefinitionId":"1",' +
          '"Type":"StringType",' +
          '"Name":"Crew#"' +
          '}' +
          '],' +
          '"Id":"239",' +
          '"TxnTaxDetail":{' +
          '"TotalTax":0' +
          '},' +
          '"MetaData":{' +
          '"CreateTime":"2015-07-24T10:35:08-07:00",' +
          '"LastUpdatedTime":"2015-07-24T10:35:08-07:00"' +
          '}' +
          '}' +
          ']' +
          '},' +
          '"time":"2015-07-24T10:38:50.01-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getCustomer') {
      res.setBody(
        '{' +
          '"QueryResponse":{' +
          '"startPosition":1,' +
          '"totalCount":1,' +
          '"maxResults":1,' +
          '"Customer":[' +
          '{' +
          '"Id": "1",' +
          '"SyncToken": "0"' +
          '}' +
          ']' +
          '},' +
          '"time":"2015-07-24T10:38:50.01-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getVendor') {
      res.setBody(
        '{' +
          '"QueryResponse":{' +
          '"startPosition":1,' +
          '"totalCount":1,' +
          '"maxResults":1,' +
          '"Vendor":[' +
          '{' +
          '"Id": "1",' +
          '"SyncToken": "0"' +
          '}' +
          ']' +
          '},' +
          '"time":"2015-07-24T10:38:50.01-07:00"' +
          '}'
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getTaxCode') {
      res.setBody(
        '   {  ' +
          '    "QueryResponse": {  ' +
          '     "TaxCode": [  ' +
          '      {  ' +
          '       "Name": "TAX",  ' +
          '       "Description": "TAX",  ' +
          '       "Taxable": true,  ' +
          '       "TaxGroup": false,  ' +
          '       "Id": "TAX",  ' +
          '       "MetaData": {  ' +
          '        "CreateTime": "2019-08-04T01:03:00-07:00",  ' +
          '        "LastUpdatedTime": "2019-08-04T01:03:00-07:00"  ' +
          '       }  ' +
          '      }  ' +
          '   ],  ' +
          '     "startPosition": 1,  ' +
          '     "maxResults": 1,  ' +
          '     "totalCount": 1  ' +
          '    },  ' +
          '    "time": "2019-08-28T01:56:56.105-07:00"  ' +
          '  }  '
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getPaymentMethod') {
      res.setBody(
        '   {  ' +
          '    "QueryResponse": {  ' +
          '     "PaymentMethod": [  ' +
          '      {  ' +
          '       "Name": "American Express",  ' +
          '       "Active": true,  ' +
          '       "Type": "CREDIT_CARD",  ' +
          '       "domain": "QBO",  ' +
          '       "sparse": false,  ' +
          '       "Id": "6",  ' +
          '       "SyncToken": "0",  ' +
          '       "MetaData": {  ' +
          '        "CreateTime": "2019-07-18T14:42:05-07:00",  ' +
          '        "LastUpdatedTime": "2019-07-18T14:42:05-07:00"  ' +
          '       }  ' +
          '      }  ' +
          '   ],  ' +
          '     "startPosition": 1,  ' +
          '     "maxResults": 1  ' +
          '    },  ' +
          '    "time": "2019-08-28T01:59:32.631-07:00"  ' +
          '  }  '
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getTerm') {
      res.setBody(
        '   {  ' +
          '    "QueryResponse": {  ' +
          '     "Term": [  ' +
          '      {  ' +
          '       "Name": "Due on receipt",  ' +
          '       "Active": true,  ' +
          '       "Type": "STANDARD",  ' +
          '       "DueDays": 0,  ' +
          '       "DiscountDays": 0,  ' +
          '       "domain": "QBO",  ' +
          '       "sparse": false,  ' +
          '       "Id": "1",  ' +
          '       "SyncToken": "0",  ' +
          '       "MetaData": {  ' +
          '        "CreateTime": "2019-07-18T14:41:49-07:00",  ' +
          '        "LastUpdatedTime": "2019-07-18T14:41:49-07:00"  ' +
          '       }  ' +
          '      }  ' +
          '     ],  ' +
          '     "startPosition": 1,  ' +
          '     "maxResults": 1  ' +
          '    },  ' +
          '    "time": "2019-08-28T02:01:18.525-07:00"  ' +
          '  }  '
      );
    } else if (req.getEndpoint() == 'http://test.com/test/getClass') {
      res.setBody(
        '   {  ' +
          '    "QueryResponse": {  ' +
          '     "Class": [  ' +
          '      {  ' +
          '       "Name": "Ali Imran",  ' +
          '       "SubClass": false,  ' +
          '       "FullyQualifiedName": "Ali Imran",  ' +
          '       "Active": true,  ' +
          '       "domain": "QBO",  ' +
          '       "sparse": false,  ' +
          '       "Id": "5000000000000130536",  ' +
          '       "SyncToken": "6",  ' +
          '       "MetaData": {  ' +
          '        "CreateTime": "2019-08-27T09:37:28-07:00",  ' +
          '        "LastUpdatedTime": "2019-08-27T23:36:28-07:00"  ' +
          '       }  ' +
          '      }  ' +
          '     ],  ' +
          '     "startPosition": 1,  ' +
          '     "maxResults": 1,  ' +
          '     "totalCount": 1  ' +
          '    },  ' +
          '    "time": "2019-08-28T02:02:07.649-07:00"  ' +
          '  }  '
      );
    } else if (
      req.getEndpoint().contains('http://api.asicentral.com/v1/suppliers/')
    ) {
      res.setBody(
        '{"Results": [ { "Id": 2180,  "Name": "Leeds",  "AsiNumber": "66887", "Address": {' +
          '"Street1": "400 Hunt Valley Rd","City": "New Kensington","State": "PA","Zip": "15068-7059",' +
          '"Country": "US" }, "Phone": {"Work": "(724) 334-9000","TollFree": "(866) LEE-DS24","$index": 1' +
          '}, "Fax": "(800) 860-6661", "Email": "customerservice@leedsworld.com",' +
          '"Websites": [ "https://www.pcna.com/Leeds/en-us" ],"Products": 2598,"Rating": { ' +
          '"Rating": 9,  "Companies": 183, "Transactions": 1873 }}], "Selections": {}, "Dimensions": {},' +
          ' "Links": {"Self": "?q=66887&page=1&rpp=10&sort=DFLT"},"Query": "66887","Page": 1, "ResultsPerPage": 10,' +
          ' "ResultsTotal": 1, "CompletedIn": 0.50000369999999994}'
      );
    } else if (
      req.getEndpoint().contains('http://api.asicentral.com/v1/products/')
    ) {
      System.debug('----------Reached -----------' + req.getEndpoint());
      res.setBody(
        '{"Id":550396415,"Name":"Badger Camo T-Shirt","Description":"Add something different to your t-shirt drawer! Our Badger Camo Short Sleeve T-Shirt is made of 100% sublimated polyester and features moisture-management and anti-microbial properties, badger sport paneled shoulder for maximum movement, self-fabric collar, double-needle stitched hem with tack and badger heat seal logo on left sleeve. Available in bold colors and a variety of sizes, this terrific top will stand out!","ShortDescription":"Badger Camo Short Sleeve T-Shirt, blank.","Number":"4181","Numbers":["4181"],"ImageUrl":"media/33807255","Images":["media/33807255","media/31280153","media/31280154","media/31280155","media/31280156","media/31280157","media/31280158","media/31280159","media/31280160","media/31280161","media/31280162","media/31280163","media/31280164","media/31280165","media/31280166","media/31280167","media/31280168","media/31280169","media/31280170","media/31280171","media/31280172","media/31280173","media/31280174","media/31280175","media/31280176","media/31280177","media/31280178","media/31280179","media/31280180","media/31280181","media/31280182","media/31280183","media/31280184","media/31280185","media/31280186","media/31280187","media/31280188","media/31280189","media/31280190","media/31280191","media/31280192","media/31280193","media/31280194"],"Supplier":{"Id":3112,"Name":"S \u0026 S Activewear","AsiNumber":"84358","Phone":{"Work":"(630) 679-9940","TollFree":"(800) 523-2155","Primary":"(630) 679-9940","$index":1},"Fax":{"Work":"(630) 679-9941","Primary":"(630) 679-9941","$index":1},"Email":"info@ssactivewear.com","Websites":["https://www.ssactivewear.com/"],"Rating":{"Rating":10,"Companies":12,"Transactions":229},"MarketingPolicy":"Supplier indicates they sell advertising specialties exclusively through distributors and/or incentive resellers","HasNotes":false,"IsMinorityOwned":false,"IsQcaCertified":false,"IsUnionAvailable":true},"Catalog":{"Id":235398,"Name":"2020 S \u0026 S Activewear","Year":"2020","Asset":"ASI/84358 2020 S and S Activewear","CompanyId":0,"ProductCount":0,"EndUserSafe":false},"Catalogs":[{"Id":235398,"Name":"2020 S \u0026 S Activewear","Year":"2020","Asset":"ASI/84358 2020 S and S Activewear","CompanyId":0,"ProductCount":0,"EndUserSafe":false}],"Categories":[{"Id":"A03228003","Name":"Antimicrobial Enhanced Products"},{"Id":"P03110003","Name":"Performance Apparel"},{"Id":"T00253003","Name":"Unisex","Parent":{"Id":"T00250003","Name":"T-shirts"}}],"Themes":["Hunting"],"TradeNames":["Badger"],"Attributes":{"Colors":{"Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","SKU":"B14285502","$index":3},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66","SKU":"B14285662"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26","SKU":"B14285262"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54","SKU":"B14285542"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12","SKU":"B14285122"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16","SKU":"B14285162"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53","SKU":"B14285532"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65","SKU":"B14285652"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19","SKU":"B14285192"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67","SKU":"B14285672"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70","SKU":"B14285702"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75","SKU":"B14285752"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73","SKU":"B14285732"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00","SKU":"B14285002"}]},"Sizes":{"Values":[{"Code":"AZCW","Name":"XS","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"2","SKU":"B14285502","$index":3},{"Code":"AZCW","Name":"S","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"3","SKU":"B14285503"},{"Code":"AZCW","Name":"M","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"4","SKU":"B14285504"},{"Code":"AZCW","Name":"L","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"5","SKU":"B14285505"},{"Code":"AZCW","Name":"XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"6","SKU":"B14285506"},{"Code":"BBOB","Name":"2XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"7","SKU":"B14285507"},{"Code":"BBOB","Name":"3XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"8","SKU":"B14285508"},{"Code":"BBOB","Name":"4XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"9","SKU":"B14285509"}]},"Materials":{"Values":[{"Code":"$02B","Name":"Polyester","$index":3}]}},"Imprinting":{"Methods":{"Values":[{"Code":"$UNI","Name":"UNIMPRINTED","$index":3}]},"FullColorProcess":false,"Personalization":false,"SoldUnimprinted":true},"Variants":[{"Id":840880292,"Name":"XS,S,M,L,XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,San...","Description":"Size: XS, Size: S, Size: M, Size: L, Size: XL","ImageUrl":"media/31280153","Attributes":{"Colors":{"Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","SKU":"B14285502","$index":3},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66","SKU":"B14285662"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26","SKU":"B14285262"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54","SKU":"B14285542"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12","SKU":"B14285122"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16","SKU":"B14285162"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53","SKU":"B14285532"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65","SKU":"B14285652"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19","SKU":"B14285192"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67","SKU":"B14285672"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70","SKU":"B14285702"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75","SKU":"B14285752"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73","SKU":"B14285732"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00","SKU":"B14285002"}]},"Sizes":{"Values":[{"Code":"AZCW","Name":"XS","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"2","SKU":"B14285502","$index":3},{"Code":"AZCW","Name":"S","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"3","SKU":"B14285503"},{"Code":"AZCW","Name":"M","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"4","SKU":"B14285504"},{"Code":"AZCW","Name":"L","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"5","SKU":"B14285505"},{"Code":"AZCW","Name":"XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"6","SKU":"B14285506"}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":18.480,"Cost":9.240,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":835649391,"Name":"2XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 2XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"2XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"7","SKU":"B14285507","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":23.200,"Cost":11.600,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":835574717,"Name":"3XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 3XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"3XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"8","SKU":"B14285508","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":28.500,"Cost":14.250,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":833827929,"Name":"4XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 4XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"4XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"9","SKU":"B14285509","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":30.980,"Cost":15.490,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"}],"Warnings":[{"Name":"","Description":"No safety warnings for this product","Warning":"No safety warnings for this product","Type":"SWCH"}],"Prop65AdditionalInfo":"","Currency":"USD","Currencies":["USD"],"LowestPrice":{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":18.480,"Cost":9.240,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false},"HighestPrice":{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":30.980,"Cost":15.490,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false},"IsNew":false,"IsConfirmed":true,"HasFullColorProcess":false,"HasRushService":false,"UpdateDate":"2020-02-26T20:56:25.000-05:00","RequiresConfiguration":false,"Values":[{"Id":773581271,"Name":"Size","Description":"Size","Code":"SIZE","Values":[{"Id":761405622,"Name":"2XL","IsSelected":false,"VendorCode":"7"},{"Id":761405621,"Name":"3XL","IsSelected":false,"VendorCode":"8"},{"Id":782461296,"Name":"4XL","IsSelected":false,"VendorCode":"9"},{"Id":761405624,"Name":"L","IsSelected":false,"VendorCode":"5"},{"Id":761405625,"Name":"M","IsSelected":false,"VendorCode":"4"},{"Id":761405626,"Name":"S","IsSelected":false,"VendorCode":"3"},{"Id":761405623,"Name":"XL","IsSelected":false,"VendorCode":"6"},{"Id":782461297,"Name":"XS","IsSelected":false,"VendorCode":"2"}],"IsRequired":false,"IsMultiSelect":false},{"Id":773581272,"Name":"Material","Description":"Material","Code":"MTRL","Values":[{"Id":761405614,"Name":"Polyester","IsSelected":false}],"IsRequired":false,"IsMultiSelect":false},{"Id":24939750115,"Name":"Color","Description":"Product Color","Code":"PRCL","Values":[{"Id":24937885484,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274257,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274258,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274259,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274260,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274261,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274262,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274263,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24937885485,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274264,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274265,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274266,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274267,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274268,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274269,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274270,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24937885486,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274271,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274272,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274273,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274274,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274275,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274276,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274277,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24937868054,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308974,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308975,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308976,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308977,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308978,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308979,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308980,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24937885487,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274278,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274279,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274280,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274281,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274282,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274283,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274284,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24937868055,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308981,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308982,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308983,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308984,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308985,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308986,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308987,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24937885810,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274285,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274286,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274287,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274288,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274289,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274290,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274291,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24937869176,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308988,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308989,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308990,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308991,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308992,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308993,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308994,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24937884848,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274292,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274293,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274294,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274295,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274296,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274297,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274298,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24937885811,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274299,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274300,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274301,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274302,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274303,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274304,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274305,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24937869392,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308995,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308996,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308997,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308998,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308999,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939309000,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939309001,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24937869177,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309002,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309003,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309004,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309005,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309006,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309007,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309008,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24937867259,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309009,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309010,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309011,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309012,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309013,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309014,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309015,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24937867260,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309016,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309017,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309018,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309019,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309020,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309021,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309022,"Name":"White","IsSelected":false,"VendorCode":"00"}],"IsRequired":false,"IsMultiSelect":false}],"SKU":[{"SKU":"B14285502","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285503","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285504","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285505","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285506","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285507","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285508","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285509","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285662","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285663","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285664","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285665","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285666","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285667","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285668","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285669","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285262","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285263","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285264","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285265","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285266","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285267","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285268","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285269","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285542","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285543","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285544","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285545","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285546","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285547","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285548","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285549","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285122","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285123","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285124","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285125","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285126","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285127","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285128","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285129","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285162","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285163","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285164","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285165","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285166","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285167","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285168","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285169","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285532","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285533","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285534","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285535","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285536","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285537","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285538","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285539","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285652","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285653","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285654","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285656","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285657","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285658","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285659","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285192","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285193","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285194","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285195","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285196","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285197","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285198","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285199","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285672","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285673","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285674","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285675","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285676","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285677","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285678","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285679","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285702","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285703","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285704","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285706","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285707","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285708","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285709","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285752","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285755","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285759","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285732","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285733","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285734","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285735","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285736","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285737","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285738","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285739","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285002","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285003","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285004","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285006","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285007","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285008","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285009","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285753","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285758","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285754","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285756","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285757","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285705","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285005","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285655","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]}],"IsAssembled":true,"HasInventory":true,"Services":[{"Id":550005773,"Name":"Inventory API","Code":"IAPI"},{"Id":550005239,"Name":"Order Creation API","Code":"OAPI"},{"Id":550005774,"Name":"Product API","Code":"PAPI"},{"Id":550005235,"Name":"Pricing API","Code":"RAPI"},{"Id":550005248,"Name":"Order Status API","Code":"SAPI"}]}'
      );
      //    String jsonData = '{"Id": 12345,"Name": "Sophisticant Art Glass Award","Description": "Whether","ShortDescription": "8.75\" x 4\" x 4\" art glass award with sleek oval shape with rainbow swirls.","Number": "IC910","Numbers": ["IC910"],"ImageUrl": "media/7187614","Supplier": {"Id": 491276,"Name": "The Magnet Group","AsiNumber": "68507","HasNotes": false,"IsMinorityOwned": false,"IsQcaCertified": false,"IsUnionAvailable": false},"LineNames": ["Benchmark Crystal & Clocks"],"Attributes": {"Colors": {"Values": [{"Code": "UNCL","Name": "Unclassfied","ImageUrl": "media/7187614","$index": 3}]},"Sizes": {"Values": [{"Code": "QOCR","Name": "8.75 \" x 4 \" x 4 \"","$index": 3}]}},"Packaging": [{"Type": "Packaging","Values": [{"Code": "$2HU","Name": "Gift Box","$index": 1}]}],"Variants": [{"Id": 831288927,"Name": "Etched Imprint","Description": "Imprint Method: Etched Imprint","Imprinting": {"Methods": {"Values": [{"Code": "$0TU","Name": "Etched Imprint","Options": [{"Type": "Rush Time","Values": [{"Name": "1 business days","$index": 1}]},{"Type": "Production Time","Values": [{"Name": "5-7 business days","$index": 1}]},{"Type": "Imprint Size","Values": [{"Code": "$2HQ","Name": "2\" x 2\"","$index": 1}]},{"Type": "Imprint Location","Values": ["Front"]}],"Charges": [{"TypeCode": "COCH","Type": "Add. Color Charge","Description": "Additional Color Charge","Prices": [{"Quantity": {"From": 3,"To": 5,"$index": 1},"Price": 6.000,"Cost": 4.800,"DiscountCode": "V","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 6,"To": 9,"$index": 1},"Price": 6.000,"Cost": 4.800,"DiscountCode": "V","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 10,"To": 24,"$index": 1},"Price": 6.000,"Cost": 4.800,"DiscountCode": "V","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 25,"To": 2147483647,"$index": 1},"Price": 6.000,"Cost": 4.800,"DiscountCode": "V","CurrencyCode": "USD","IsQUR": false}],"UsageLevelCode": "PORD","UsageLevel": "Per Order","VendorCode": "CRY-ADDL-COLOR","IsRequired": true},{"TypeCode": "STCH","Type": "Set-up Charge","Description": "Setup Charge","Prices": [{"Quantity": {"From": 1,"To": 2147483647,"$index": 1},"Price": 50.000,"Cost": 40.000,"DiscountCode": "V","CurrencyCode": "USD","IsQUR": false}],"UsageLevelCode": "PORD","UsageLevel": "Per Order","VendorCode": "CRY-SETUP","IsRequired": true}],"VendorCode": "CZ","$index": 3}]}},"Shipping": {"WeightUnit": "Pounds","WeightPerPackage": 33,"PackageUnit": "Case","ItemsPerPackage": 5,"Dimensions": {"Description": "18.5 \" x 12.5 \" x 12.5 \"","Length": "18.5","LengthUnit": "Inches","Width": "12.5","WidthUnit": "Inches","Height": "12.5","HeightUnit": "Inches"},"BillsByWeight": false,"BillsBySize": false},"Prices": [{"Quantity": {"From": 3,"To": 5,"$index": 1},"Price": 85.010,"Cost": 51.006,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 6,"To": 9,"$index": 1},"Price": 83.410,"Cost": 50.046,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 10,"To": 24,"$index": 1},"Price": 81.800,"Cost": 49.080,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false},{"Quantity": {"From": 25,"To": 2147483647,"$index": 1},"Price": 80.200,"Cost": 48.120,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false}]}],"Warnings": [{"Name": "","Description": "No safety warnings for this product","Warning": "No safety warnings for this product","Type": "SWCH"}],"Prop65AdditionalInfo": "","Currency": "USD","Currencies": ["USD"],"LowestPrice": {"Quantity": {"From": 25,"To": 2147483647,"$index": 1},"Price": 80.200,"Cost": 48.120,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false},"HighestPrice": {"Quantity": {"From": 3,"To": 5,"$index": 1},"Price": 89.290,"Cost": 53.574,"DiscountCode": "R","CurrencyCode": "USD","IsQUR": false},"IsNew": false,"IsConfirmed": true,"HasFullColorProcess": false,"HasRushService": true,"UpdateDate": "2020-02-07T23:35:19.000-05:00","RequiresConfiguration": true,"Values": [{"Id": 68441831,"Name": "Imprint Method","Description": "Imprint Method","Code": "IMMD","Values": [{"Id": 772583317,"Name": "Etched Imprint","IsSelected": false,"VendorCode": "CZ"},{"Id": 812950340,"Name": "Sand Carve","IsSelected": false,"VendorCode": "SC"},{"Id": 777177111,"Name": "UNIMPRINTED","IsSelected": false,"VendorCode": "BL"}],"IsRequired": false,"IsMultiSelect": false},{"Id": 762106269,"Name": "Size","Description": "Size","Code": "SIZE","Values": [{"Id": 828709603,"Name": "8.75 \" x 4 \" x 4 \"","IsSelected": false}],"IsRequired": false,"IsMultiSelect": false},{"Id": 783380131,"Name": "Color","Description": "Product Color","Code": "PRCL","Values": [{"Id": 784318840,"Name": "Unclassfied","IsSelected": false}],"IsRequired": false,"IsMultiSelect": false}],"Weight": {"Values": ["6.6 lbs"]},"HasInventory": true}';
      //  res.setBody(jsonData);
    }

    return res;
  }
}
