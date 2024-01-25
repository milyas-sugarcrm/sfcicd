/*
 * Description: This class is for common utility methods
 * Author: Imran
 * Name: CommonUtility
 * Created Date: 27th July 2023
 * Version:1.0.0 - Imran
 */
public class CommonUtility {
  //get recordTypeId by Object Name & Record Type Developer Name
  public static Id recordTypeIdByDevName(
    Schema.SObjectType sObjType,
    string recTypeDevName
  ) {
    Id recTypeId;
    if (sObjType != null && String.isNotBlank(recTypeDevName)) {
      recTypeId = sObjType.getDescribe()
        .getRecordTypeInfosByDeveloperName()
        .get(recTypeDevName)
        .getRecordTypeId();
    }
    return recTypeId;
  }

  //get recordTypeId by Object Name & Record Type Name
  public static Id recordTypeIdByName(
    Schema.SObjectType sObjType,
    string recTypeName
  ) {
    Id recTypeId;
    if (sObjType != null && String.isNotBlank(recTypeName)) {
      recTypeId = sObjType.getDescribe()
        .getRecordTypeInfosByName()
        .get(recTypeName)
        .getRecordTypeId();
    }
    return recTypeId;
  }

  //get picklist field values
  public static List<String> getPicklistValues(
    Schema.SObjectType sObjType,
    String fieldAPIName
  ) {
    List<String> picklistValues = new List<String>();
    Schema.DescribeSObjectResult desResult = sObjType.getDescribe();
    Map<String, Schema.SObjectField> sObjectFields = desResult.fields.getMap();
    Schema.DescribeFieldResult fieldDesResult = sObjectFields.get(fieldAPIName)
      .getDescribe();
    for (Schema.PicklistEntry ple : fieldDesResult.getPicklistValues()) {
      picklistValues.add(ple.getValue());
    }
    return picklistValues;
  }
}
