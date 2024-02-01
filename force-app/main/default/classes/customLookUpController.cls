public class customLookUpController {
  public class JSON2Apex {
    public String Id;
    public String Name;
    public JSON2Apex parse(String json) {
      return (JSON2Apex) System.JSON.deserialize(json, JSON2Apex.class);
    }
  }

  @AuraEnabled
  public static List<sObject> fetchLookUpValues(
    String searchKeyWord,
    String ObjectName,
    String filter
  ) {
    String searchKey = searchKeyWord + '%';
    List<sObject> returnList = new List<sObject>();
    String sQuery;
    if (ObjectName.equalsIgnoreCase('account')) {
      List<String> lstfiltersUpdated = new List<String>();
      List<String> lstfilters = new List<String>();
      lstfilters = filter.split(',');
      for (String obj : lstfilters) {
        obj = obj.replaceAll('"', '');
        obj += '%';
        lstfiltersUpdated.add(obj);
      }
      if (lstfiltersUpdated.size() > 0) {
        filter = lstfiltersUpdated.get(0);
      } else {
        filter = filter.replaceAll('"', '');
        filter += '%';
      }
      List<RecordType> lstrecordType = [
        SELECT SobjectType, Id, Name
        FROM RecordType
        WHERE SobjectType = :ObjectName AND Name LIKE :filter
      ];
      if (
        (filter.equalsIgnoreCase('vendor%')) &&
        (lstrecordType.size() > 0) &&
        (lstfiltersUpdated.size() == 1)
      ) {
        String finalId = '\'' + lstrecordType.get(0).Id + '\'';
        sQuery =
          'SELECT id, Name FROM ' +
          ObjectName +
          ' WHERE Name LIKE: searchKey AND RecordTypeId = ' +
          finalId +
          ' order by createdDate DESC limit 5';
      } else if (
        (filter.equalsIgnoreCase('vendor%')) &&
        (lstrecordType.size() > 0) &&
        (lstfiltersUpdated.size() == 2)
      ) {
        String finalId = '\'' + lstrecordType.get(0).Id + '\'';
        String decorator = '\'' + lstfiltersUpdated.get(1) + '\'';
        sQuery =
          'SELECT id, Name FROM ' +
          ObjectName +
          ' WHERE Name LIKE: searchKey AND RecordTypeId = ' +
          finalId +
          ' AND  Primary_Category__c LIKE ' +
          decorator +
          ' order by createdDate DESC limit 5';
      } else {
        sQuery =
          'SELECT id, Name FROM ' +
          ObjectName +
          ' WHERE Name LIKE: searchKey  order by createdDate DESC limit 5';
      }
    } else if (ObjectName.equalsIgnoreCase('address__c')) {
      if (filter.contains('Id')) {
        JSON2Apex parser = new JSON2Apex();
        JSON2Apex finalResult = parser.parse(filter);
        ID recordID = finalResult.Id;
        String finalId = '\'' + recordID + '\'';
        // sQuery = 'SELECT Id, Name,Address_1__c, Address_2__c, City__c, Postal_Zip_Code__c, Country__c, State_Provience__c,DisplayAddress__c FROM ' +ObjectName + ' WHERE Account__c = '+finalId+' order by createdDate DESC limit 5';
        sQuery =
          'SELECT Id, ShippingStreet,ShippingCity, ShippingState, ShippingPostalCode, ShippingCountry FROM  Account  WHERE Id = ' +
          finalId;
      }
    } else {
      sQuery =
        'SELECT id, Name FROM ' +
        ObjectName +
        ' WHERE Name LIKE: searchKey order by createdDate DESC limit 5';
    }
    try {
      System.debug(sQuery);
      List<sObject> lstOfRecords = Database.query(sQuery);
      for (sObject obj : lstOfRecords) {
        returnList.add(obj);
      }
      return returnList;
    } catch (Exception e) {
      System.debug('Exception Occurs :- ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static String getAccountAddress(Id Recid) {
    List<Account> accs = [
      SELECT
        Id,
        ShippingStreet,
        ShippingCity,
        ShippingState,
        ShippingPostalCode,
        ShippingCountry
      FROM Account
      WHERE Id = :Recid
    ];
    if (!accs.isEmpty()) {
      return getAddress(accs[0]);
    }
    return null;
  }
  public static String getAddress(Account acc) {
    String address = '';
    if (acc.ShippingStreet != null)
      address = acc.ShippingStreet;
    if (acc.ShippingCity != null)
      address = address + ' ' + acc.ShippingCity;
    if (acc.ShippingState != null)
      address = address + ',' + acc.ShippingState;
    if (acc.ShippingPostalCode != null)
      address = address + ' ' + acc.ShippingPostalCode;
    if (acc.ShippingCountry != null)
      address = address + ' ' + acc.ShippingCountry;
    return address;
  }
  @AuraEnabled
  public static sObject getObjectRecord(string objectname, string recid) {
    try {
      System.debug('recid: ' + recid);
      sObject obj = Database.query(
        'SELECT id,name FROM ' + objectname + ' WHERE id =: recid'
      );
      return obj;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
