public with sharing class AddProductTeamPhunTabForWOController {
  @AuraEnabled
  public static List<QueriedProducts> getSearchResults(
    String netMin,
    String netMax,
    String supplier,
    String searchName,
    String offset,
    String tabName
  ) {
    List<QueriedProducts> products = AddProductTeamPhunTabController.getSearchResults(
      netMin,
      netMax,
      supplier,
      searchName,
      offset,
      tabName
    );
    return products;
  }
}
