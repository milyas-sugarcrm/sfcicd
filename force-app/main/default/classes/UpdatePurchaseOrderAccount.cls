public class UpdatePurchaseOrderAccount {
  // Process Builder - Update Purchase Order Account converted to this method
  public static void SetAccountId(List<PurchaseOrder_LineItem__c> newValues) {
    Map<Id, Id> workOrderAccountMap = new Map<Id, Id>();
    Set<Id> OrderIds = new Set<Id>();
    for (PurchaseOrder_LineItem__c poli : newValues) {
      if (poli.Work_Order__c != null) {
        OrderIds.add(poli.Work_Order__c);
      }
    }

    for (Order orderRecord : [
      SELECT Id, AccountId
      FROM Order
      WHERE Id IN :OrderIds
    ]) {
      workOrderAccountMap.put(orderRecord.Id, orderRecord.AccountId); // Store the mapping in the map
    }

    for (PurchaseOrder_LineItem__c poli : newValues) {
      if (poli.Work_Order__c != null) {
        poli.Account__c = workOrderAccountMap.get(poli.Work_Order__c);
      }
    }
  }

  // This method is a part of Process Builder - Purchase Order Status Change Notifications i.e Most of that logic is converted into Flows
  public static void SetVendorBillingEmail(
    List<PurchaseOrder_LineItem__c> newValues
  ) {
    Set<Id> supplierIds = new Set<Id>();
    Set<Id> WOIds = new Set<Id>();
    for (PurchaseOrder_LineItem__c poli : newValues) {
      if (poli.Supplier__c != null) {
        supplierIds.add(poli.Supplier__c);
      }
      if (poli.Work_Order__c != null) {
        WOIds.add(poli.Work_Order__c);
      }
    }
    Map<Id, Account> supplierMap = new Map<Id, Account>(
      [
        SELECT Id, Billing_email__c, Owner.Email
        FROM Account
        WHERE Id IN :supplierIds
      ]
    );
    Map<Id, Order> OrderMap = new Map<Id, Order>(
      [
        SELECT Id, Owner.Email
        FROM Order
        WHERE Id IN :WOIds
      ]
    );

    for (PurchaseOrder_LineItem__c poli : newValues) {
      if (poli.Supplier__c != null) {
        Account acc = supplierMap.get(poli.Supplier__c);

        if (acc != null) {
          poli.POVendorEmailField__c = acc.Billing_email__c;
        }
      }
      if (poli.Work_Order__c != null) {
        Order orderOj = OrderMap.get(poli.Work_Order__c);

        if (orderOj != null) {
          poli.WorkOrderOwnerEmail__c = orderOj.Owner.Email;
        }
      }
    }
  }
}
