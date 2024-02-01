public class SowVFController {
  private ApexPages.StandardController stdController;
  public Contact relatedContact { get; set; }
  public List<Hourly_Estimate__c> relatedTierEstimate { get; set; }
  public List<Expenses_Miscellaneous__c> relatedExpense { get; set; }
  public String wire { get; set; }
  public String cc { get; set; }
  public String check { get; set; }
  public String bill { get; set; }
  public String sowCreationDate { get; set; }
  List<String> selectedOptionsList = new List<String>();
  String selectedOptions;
  String checkBoxColor = '#eb7253';

  public SowVFController(ApexPages.StandardController controller) {
    stdController = controller;
    Opportunity opp = (Opportunity) stdController.getRecord();

    // Get contact info Account to which opportuntiy is related
    if (opp.AccountId != null) {
      List<Contact> relatedContactList = [
        SELECT Id, Name, Email, Department
        FROM Contact
        WHERE AccountId = :opp.AccountId
        LIMIT 1
      ];
      if (!relatedContactList.isEmpty()) {
        relatedContact = relatedContactList[0];
      }
    }
    Date currentDate = Date.today();
    sowCreationDate = currentDate.format();
    List<Opportunity> relatedEstimateAndExpense = [
      SELECT
        Id,
        Preferred_Payment_Method_PFA__c,
        Terms_and_Conditions__c,
        PFA_User_Title__c,
        (
          SELECT
            Name,
            Region__c,
            Market__c,
            Number_of_Activations__c,
            Hours__c,
            Hourly_Rate__c,
            Total__c
          FROM PFA_SOW_Estimates__r
        ),
        (
          SELECT
            Name,
            Expense_Type__c,
            Number_of_Months__c,
            Number_of_Activations__c,
            Number_of_Ambassadors__c,
            Estimated_Cost__c,
            Total__c
          FROM Expenses__r
        )
      FROM Opportunity
      WHERE Id = :opp.Id
    ];

    if (!relatedEstimateAndExpense.isEmpty()) {
      relatedTierEstimate = relatedEstimateAndExpense[0].PFA_SOW_Estimates__r;
      relatedExpense = relatedEstimateAndExpense[0].Expenses__r;
      selectedOptions = relatedEstimateAndExpense[0]
        .Preferred_Payment_Method_PFA__c;
    }
    if (selectedOptions != null) {
      selectedOptionsList = selectedOptions.split(';');
    }

    // Get options of multi picklist field for Preferred Payment Method on Opportunity object
    Schema.DescribeFieldResult fieldResult = Opportunity.Preferred_Payment_Method_PFA__c.getDescribe();
    List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();

    if (selectedOptionsList != null && picklistEntries != null) {
      for (Schema.PicklistEntry entry : picklistEntries) {
        for (String selectedOpt : selectedOptionsList) {
          String opt = selectedOpt.trim(); // Trim the option
          if (entry.getValue() == opt) {
            if (opt == 'ACH Transfer' || opt == 'Wire Transfer') {
              wire = checkBoxColor;
            } else if (opt == 'Credit Card') {
              cc = checkBoxColor;
            } else if (opt == 'Check') {
              check = checkBoxColor;
            } else if (opt == 'Bill.com') {
              bill = checkBoxColor;
            } else {
            }
          }
        }
      }
    }
  }
}
