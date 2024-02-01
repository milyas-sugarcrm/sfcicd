public with sharing class extraChargesObject {
  @AuraEnabled
  public Boolean displayTotal;
  @AuraEnabled
  public String chargeType;
  @AuraEnabled
  public String title;
  @AuraEnabled
  public String quantity;
  @AuraEnabled
  public String netCost;
  @AuraEnabled
  public String margin;
  @AuraEnabled
  public String retail;
  @AuraEnabled
  public String status;
  @AuraEnabled
  public String dutyPercentage;

  public extraChargesObject() {
    displayTotal = true;
    chargeType = '';
    title = '';
    quantity = '';
    netCost = '';
    margin = '';
    retail = '';
    status = '';
    dutyPercentage = '';
  }
}
