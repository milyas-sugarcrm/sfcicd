public class ApproveOrderController {
  public Id recId;
  public ApproveOrderController(ApexPages.StandardController std) {
    recId = ApexPages.currentPage().getParameters().get('Id');
  }

  public void updateStatus() {
    List<Order> orders = [SELECT Id, Status FROM Order WHERE Id = :recId];
    for (Order orderObj : orders) {
      if (orderObj.Status == '03_-_Proof_Sent_-_Waiting_for_Approval') {
        orderObj.Status = '04_-_Order_Blanks-Approved/Deposit';
      }
    }
    update orders;
  }
}
