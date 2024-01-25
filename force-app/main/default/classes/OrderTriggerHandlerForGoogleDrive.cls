/*
*********************************************************
Apex Class Name    : OrderTriggerHandlerForGoogleDrive
Created Date       : July 04, 2023
@description       : This is class is used to make a pdf on Google Drive when Work Order Stage reaches 02_-_Send_Mock_Up_to_Client_for_Approval
@author            : Sohaib Saqib
Modification Log:
Ver   Date         Author                               Modification
--   --   --                      --
*********************************************************
*/
public class OrderTriggerHandlerForGoogleDrive {
  // public static Id workOrderIdTest = NULL;

  /*
*********************************************************
@Method Name    : handleAfterUpdate 
@author         : Sohaib Saqib
@description    : Called from Trigger
@param          : 
@return         : Void
********************************************************
*/

  public static void handleAfterUpdate(
    List<Order> newOrders,
    Map<Id, Order> oldOrderMap
  ) {
    List<Order> updatedOrders = new List<Order>();
    for (Order newOrder : newOrders) {
      Order oldOrder = oldOrderMap.get(newOrder.Id);
      if (
        newOrder.Status == '02_-_Send_Mock_Up_to_Client_for_Approval' &&
        (oldOrder.Status == '01_-_Waiting_for_Client_Payment' ||
        oldOrder.Status == '99_-_Design Projects')
      ) {
        updatedOrders.add(newOrder);
      }
    }

    if (!updatedOrders.isEmpty()) {
      List<Id> updatedOrderIds = new List<Id>();
      for (Order order : updatedOrders) {
        updatedOrderIds.add(order.Id);
      }
      PDFGeneratorQueueableClass queueable = new PDFGeneratorQueueableClass(
        updatedOrderIds
      );
      System.enqueueJob(queueable);
    }
  }
}
