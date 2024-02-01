public class ConvertToSalesOrderObject {
  @AuraEnabled
  public boolean value;
  @AuraEnabled
  public String recordId;

  public void ConvertToSalesOrderObject() {
    value = false;
    recordId = '';
  }
}
