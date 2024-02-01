public with sharing class CommonUtilitiesPfa {
  public static Id getRecordTypeIdByName(
    String objectApiName,
    String recordTypeDeveloperName
  ) {
    Id recordTypeId;

    try {
      recordTypeId = Schema.getGlobalDescribe()
        .get(objectApiName)
        .getDescribe()
        .getRecordTypeInfosByName()
        .get(recordTypeDeveloperName)
        .getRecordTypeId();
    } catch (Exception e) {
    }

    return recordTypeId;
  }

  public static String getRecordLink(Id recordId) {
    return URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
  }
}
