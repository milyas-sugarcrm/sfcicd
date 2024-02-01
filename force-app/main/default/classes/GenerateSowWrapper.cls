public without sharing class GenerateSowWrapper {
  public Opportunity opp;
  public String oppId { get; set; }
  public String msg { get; set; }
  public String success { get; set; }

  public GenerateSowWrapper(ApexPages.StandardController controller) {
    opp = (Opportunity) controller.getRecord();
    oppId = opp.Id;
  }

  public void genPdfSow() {
    Map<String, Object> response = GenerateSOW.generateSowPdfHandler(oppId);
    success = (String) response.get('success');
    msg = (String) response.get('msg');
  }
}
