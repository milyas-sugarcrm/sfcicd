public class OpportunityStageUpdate {
  @AuraEnabled
  public static void createEstimateWithoutProductsInDb(
    String recordId,
    String selectedValue
  ) {
    try {
      Opportunity opp = [
        SELECT
          Id,
          Order_Date__c,
          In_Hands_Date__c,
          StageName,
          Currency__c,
          Presentation_Style__c
        FROM Opportunity
        WHERE Id = :recordId
      ];
      Estimate__c estimate = new Estimate__c();
      estimate.Opportunity__c = recordId;
      estimate.Status__c = 'Converted';
      estimate.In_Hands_Date__c = system.today();
      estimate.Selected_Quickbook_Instance__c = selectedValue;
      estimate.Terms__c = 'Credit Card';
      insert estimate;

      opp.Order_Date__c = system.today();
      opp.In_Hands_Date__c = system.today();
      opp.Currency__c = 'USD';
      opp.Presentation_Style__c = 'List';
      opp.StageName = 'Estimate';
      opp.Estimate_Change_Status__c = 'not changed from picklist';
      system.debug('here aleeta in product without prod in db');
      update opp;
    } catch (Exception ex) {
      if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
        String message = ex.getMessage().split(',').get(1).split(':').get(0);
        throw new AuraHandledException(message);
      } else {
        throw new AuraHandledException(ex.getMessage());
      }
    }
  }
  @AuraEnabled
  public static List<String> getAccountDropDown(String recId) {
    Opportunity opp = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE Id = :recId
    ];
    List<QBO_Details__c> qboDetails = [
      SELECT Id, QBO_Account__c, Id_Type__c, IsPrimary__c, Account__c
      FROM QBO_Details__c
      WHERE Account__c = :opp.AccountId AND Id_Type__c = 'Account'
    ];
    List<String> accountNames = new List<String>();
    for (QBO_Details__c qbo : qboDetails) {
      accountNames.add(qbo.QBO_Account__c);
    }
    return accountNames;
  }
  @AuraEnabled
  public static void changeStateOfOpportunityInDb(
    String recordId,
    String stage,
    String reason
  ) {
    try {
      Opportunity opp = [
        SELECT Id, StageName, Loss_Reason__c
        FROM Opportunity
        WHERE Id = :recordId
      ];
      opp.StageName = stage;
      opp.Loss_Reason__c = reason;
      update opp;
    } catch (Exception ex) {
      if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
        String message = ex.getMessage().split(',').get(1).split(':').get(0);
        throw new AuraHandledException(message);
      } else {
        throw new AuraHandledException(ex.getMessage());
      }
    }
  }
  @AuraEnabled
  public static void updateStage(String stageName, String recordId) {
    Opportunity opp = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :recordId
    ];
    opp.StageName = stageName;
    update opp;
  }
  @AuraEnabled
  public static String getStage(String recordId) {
    Opportunity opp = [
      SELECT Id, StageName
      FROM Opportunity
      WHERE Id = :recordId
    ];
    return opp.StageName;
  }
  @AuraEnabled
  public static Boolean checkEstimateExists(String recid) {
    try {
      List<Estimate__c> estimateList = [
        SELECT id, Opportunity__c
        FROM Estimate__c
        WHERE Opportunity__c = :recId
      ];
      return estimateList.size() != 0;
    } catch (Exception ex) {
      System.debug(
        'Error in  Estimate -->>>>>' +
          ex.getMessage() +
          '+++++' +
          ex.getStackTraceString()
      );
      return null;
    }
  }
}
