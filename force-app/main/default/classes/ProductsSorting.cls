public class ProductsSorting {
  public static List<OpportunityLineItem__c> sortProducts(
    List<OpportunityLineItem__c> relatedOpportunityLineItems
  ) {
    List<OpportunityLineItem__c> sortedDetails = new List<OpportunityLineItem__c>();
    for (Integer i = 0; i < relatedOpportunityLineItems.size(); i++) {
      sortedDetails.add(relatedOpportunityLineItems[i]);
      if ((i + 1) < relatedOpportunityLineItems.size()) {
        for (Integer j = i + 1; j < relatedOpportunityLineItems.size(); j++) {
          if (
            sortedDetails[sortedDetails.size() - 1].Name ==
            relatedOpportunityLineItems[j].Name
          ) {
            sortedDetails.add(relatedOpportunityLineItems[j]);
            relatedOpportunityLineItems.remove(j);
            j--;
          }
        }
      }
    }
    return sortedDetails;
  }
}
