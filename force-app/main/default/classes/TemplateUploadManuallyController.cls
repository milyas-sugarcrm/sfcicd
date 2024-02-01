public class TemplateUploadManuallyController {
  private Order order;

  public TemplateUploadManuallyController(
    ApexPages.StandardController controller
  ) {
    order = (Order) controller.getRecord();
  }

  public void uploadPdfTemplate() {
    Id recordId = order.Id;
    OrderButtonController.uploadPdfTemplate(recordId);
  }
}
