public with sharing class AddProductMainController {
  @AuraEnabled
  public static String getOpportunityName(Id oppId) {
    List<Opportunity> lstOpp = new List<Opportunity>();
    lstOpp = [SELECT id, Name FROM Opportunity WHERE id = :oppId];
    if (lstOpp.size() > 0) {
      return lstOpp.get(0).Name;
    }
    return oppId;
  }
}
