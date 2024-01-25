public class EstimateEditClass {
  @AuraEnabled
  public Integer index { get; set; }
  @AuraEnabled
  public Decimal subtotal { get; set; }
  @AuraEnabled
  public String Id { get; set; }
  @AuraEnabled
  public String ProductName { get; set; }
  @AuraEnabled
  public Decimal cost { get; set; }
  @AuraEnabled
  public Decimal Quantity { get; set; }
  @AuraEnabled
  public Decimal retailPrice { get; set; }
  @AuraEnabled
  public Decimal CostPrice { get; set; }
  @AuraEnabled
  public Decimal TotalPrice { get; set; }
  @AuraEnabled
  public Decimal PricePerUnit { get; set; }
  @AuraEnabled
  public String Color { get; set; }
  @AuraEnabled
  public String Size { get; set; }
  @AuraEnabled
  public String description { get; set; }
  @AuraEnabled
  public String ObjectName { get; set; }
  @AuraEnabled
  public String recordType { get; set; }
  @AuraEnabled
  public String OppLineItemId { get; set; }
  @AuraEnabled
  public Boolean toggle { get; set; }
  @AuraEnabled
  public Boolean isCreditAvailable { get; set; }
  @AuraEnabled
  public Decimal usedCredits { get; set; }
  public EstimateEditClass() {
    Quantity = 0;
    retailPrice = 0;
    index = null;
    costPrice = 0;
    PricePerUnit = 0;
    Color = '';
    ObjectName = '';
    usedCredits = 0;
    Size = '';
    isCreditAvailable = true;
    OppLineItemId = '';
    recordType = '';
    description = '';
  }
}
