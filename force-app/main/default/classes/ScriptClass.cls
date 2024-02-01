public class ScriptClass {
  // public static Map<String,Order> getOrders(){
  //     List<QB_Credentials__c> qbcList=[Select Id, Access_token__c, Refresh_token__c,
  //                                      realmid__c from QB_Credentials__c];
  //     if(qbcList.size()>0){
  //         List<String> authorizationCredentials=new List<String>  ();
  //         authorizationCredentials.add(qbcList[0].Access_token__c);
  //         authorizationCredentials.add(qbcList[0].Refresh_token__c);
  //         authorizationCredentials.add(qbcList[0].realmid__c);

  //         Map <String,Order> mapQbIdOrder = new Map <String,Order>();
  //         List<Order> existingOrders = [Select id,QbId__c from Order];
  //         Map<String,String> classRefs = new Map<String,String>();
  //         for(Class__c classR : [SELECT Id, Name, Fully_Qualified_Name__c, Id__c FROM Class__c]){
  //             classRefs.put(classR.Id__c, classR.Fully_Qualified_Name__c);
  //         }
  //         Map<String,String> termRefs = new Map<String,String>();
  //         for(Sales_Term__c term : [SELECT Id, Id__c, Name FROM Sales_Term__c]){
  //             termRefs.put(term.Id__c, term.Name);
  //         }
  //         Map<String,Id> customerRefMap = new Map<String,Id>();
  //         for(Account acc : [SELECT Id,QB_Record_ID__c FROM Account WHERE QB_Record_ID__c != null]){
  //             customerRefMap.put(acc.QB_Record_ID__c,acc.Id);
  //         }

  //         for(Integer i = 0; i < 33 ; i++){
  //             String query = 'Select * from Invoice STARTPOSITION ' + ((i*100)+1) + ' MAXRESULTS 100';
  //             String responseData = QuickbookScheduler.QuickBookRecordGetter(query, authorizationCredentials,null);
  //             QuickbookApiCrud.InvoiceResponse results= (QuickbookApiCrud.InvoiceResponse) JSON.deserialize(responseData, QuickbookApiCrud.InvoiceResponse.class);

  //             if(results.QueryResponse != null){
  //                 List<QuickbookApiCrud.Invoice> invoices = results.QueryResponse.Invoice;
  //                 if(invoices != null){
  //                     for(QuickbookApiCrud.Invoice inv : invoices){
  //                     Order orderObj = new Order();
  //                     orderObj.QbId__c = inv.Id;
  //                     orderObj.Invoice_Number__c = inv.DocNumber;
  //                     orderObj.Status = 'Waiting_for_Client_Payment';

  //                     orderObj.Order_Amount__c  = inv.TotalAmt;
  //                     orderObj.Invoice_Total__c = inv.TotalAmt;
  //                     orderObj.Balance_Due__c = inv.Balance;
  //                     orderObj.Amount_Received__c = orderObj.Order_Amount__c - orderObj.Balance_Due__c;

  //                     orderObj.Invoice_Email__c = inv.BillEmail != null ? inv.BillEmail.Address : null;
  //                     orderObj.AccountId = inv.CustomerRef != null ? customerRefMap.get(inv.CustomerRef.value) : null;
  //                     orderObj.Invoice_Ship_Via__c = inv.ShipMethodRef != null ? inv.ShipMethodRef.value : null;
  //                     orderObj.Invoice_Tax__c = inv.TxnTaxDetail != null ? inv.TxnTaxDetail.TotalTax : null;

  //                     orderObj.Invoice_Date__c =inv.TxnDate !=null ? getDateFromString(inv.TxnDate):null;
  //                     orderObj.EffectiveDate = inv.TxnDate !=null ? getDateFromString(inv.TxnDate):null;
  //                     orderObj.Invoice_Due_Date__c = inv.DueDate !=null ? getDateFromString(inv.DueDate):null;
  //                     orderObj.Invoice_Ship_Date__c = inv.ShipDate;
  //                     orderObj.Invoice_Terms__c = inv.SalesTermRef != null ? termRefs.get(inv.SalesTermRef.value) : '';
  //                     List<QuickbookApiCrud.Line> lineItems = inv.Line;
  //                     for(QuickbookApiCrud.Line line : lineItems){
  //                         if(line.DetailType == 'SubTotalLineDetail'){
  //                             orderObj.Invoice_Value__c = line.Amount;
  //                         }
  //                         else if(line.DetailType == 'DiscountLineDetail'){
  //                             orderObj.Invoice_Discount__c = line.Amount;
  //                         }
  //                     }
  //                     if(inv.CustomField.size() > 0){
  //                         for(QuickbookApiCrud.CustomField cField : inv.CustomField){
  //                             if(cField.Name == 'Client Due Date'){
  //                                 orderObj.Client_Due_Date__c = cField.StringValue;
  //                             }
  //                             else if(cField.Name == 'Est. Ship Date'){
  //                                 orderObj.Invoice_Estimated_Ship_Date__c = cField.StringValue;
  //                             }
  //                             else if(cField.Name == 'SF Opportunity'){
  //                                 try{
  //                                     orderObj.OpportunityId = cField.StringValue !=null ? ((Id) cField.StringValue) :null;
  //                                 }
  //                                 catch(Exception e){
  //                                     orderObj.OpportunityId = null;
  //                                 }
  //                             }
  //                         }
  //                     }

  //                     if (inv.BillAddr != null){
  //                         orderObj.BillingStreet = inv.BillAddr.Line1;
  //                         orderObj.BillingCity = inv.BillAddr.City;
  //                         orderObj.BillingState = inv.BillAddr.CountrySubDivisionCode;
  //                         orderObj.BillingPostalCode = inv.BillAddr.PostalCode;
  //                         orderObj.BillingCountry = inv.BillAddr.Country;
  //                     }
  //                     if (inv.ShipAddr != null){
  //                         orderObj.ShippingStreet = inv.ShipAddr.Line1;
  //                         orderObj.ShippingCity = inv.ShipAddr.City;
  //                         orderObj.ShippingState = inv.ShipAddr.CountrySubDivisionCode;
  //                         orderObj.ShippingPostalCode = inv.ShipAddr.PostalCode;
  //                         orderObj.ShippingCountry = inv.ShipAddr.Country;
  //                     }
  //                     mapQbIdOrder.put(orderObj.QbId__c,orderObj);
  //                 }

  //                     for(Order ordObj: existingOrders){
  //                         Order newOrder= mapQbIdOrder.get(ordObj.QbId__c);
  //                         if(newOrder != null){
  //                             newOrder.Id = ordObj.Id;
  //                             mapQbIdOrder.put(ordObj.QbId__c,newOrder);
  //                         }
  //                     }
  //                 }
  //             }
  //         }
  //         return mapQbIdOrder;
  //     }
  //     return null;
  // }

  // public static Date getDateFromString (String input){
  //     String[] arrDate = input.split('-');
  //     if(arrDate != null){
  //         Date datetmp = Date.newInstance(Integer.valueOf(arrDate[0]), Integer.valueOf(arrDate[1]), Integer.valueOf(arrDate[2]));
  //         return datetmp;
  //     }
  //     return null;
  // }
}
