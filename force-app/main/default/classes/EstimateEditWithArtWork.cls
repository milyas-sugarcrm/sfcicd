public class EstimateEditWithArtWork {
  @AuraEnabled
  public String artworkName { get; set; }
  @AuraEnabled
  public List<EstimateEditClass> estimateBreakdownWithArtWork { get; set; }
  public EstimateEditWithArtWork() {
    artworkName = '';
    estimateBreakdownWithArtWork = new List<EstimateEditClass>();
  }
}
