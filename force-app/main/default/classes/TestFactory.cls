@isTest
public class TestFactory {
  Integer numberOfRecords;
  public TestFactory() {
    this.numberOfRecords = 1;
  }

  public TestFactory(Integer NoOfRecords) {
    this.numberOfRecords = NoOfRecords;
  }
  public void createExtraCharges() {
    List<Opportunity> allOpps = new List<Opportunity>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Opportunity opp = new Opportunity(Name = 'Opp ' + i);
      opp.StageName = 'Needs Analysis';
      opp.CloseDate = Date.today();
      opp.Estimate_Change_Status__c = 'not changed from picklist';
      allOpps.add(opp);
    }
    insert allOpps;
  }
  public void createContact() {
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Account acc = [SELECT Id FROM Account LIMIT 1];
    Contact contact = new Contact();
    contact.FirstName = 'Test ';
    contact.LastName = 'Contact';
    contact.AccountId = acc.id;
    insert contact;
    QBO_Details__c qboDetail = new QBO_Details__c();
    qbodetail.Opportunity__c = opp.Id;
    qbodetail.QB_Estimate_Number__c = '1234';
    qbodetail.Account__c = acc.Id;
    insert qboDetail;
    opp.Contact__c = contact.Id;
    update opp;
  }
  public void createConfiguration() {
    Quickbooks_Accounts_Configurations__c config = new Quickbooks_Accounts_Configurations__c();
    config.Name = 'test';
    config.QB_Access_token_End_Point__c = 'asdsadasdasdsadasdsad';
    config.QB_API_End_Point__c = 'asdasdasddsadasdasdasd';
    config.QB_Authorization_End_Point__c = 'asdasdsadasdasdsadasdas';
    config.QB_Authorization_Scope__c = 'asdasdasdsadasd';
    config.QB_Client_Id__c = 'asdasdasdasdasdas';
    config.QB_Client_Secret__c = 'asdasdasdasd';
    config.QB_ID__c = 'asdsadasdasdsadas';
    config.QBO_Custom_Field_1__c = 'asdasdsadsadasdas';
    config.QBO_Custom_Field_1_Id__c = '1';
    config.QB_Redirect_URI__c = 'asdasdasdasdasd';
    config.Quickbooks_Account_Tittle__c = 'Team Phun';
    config.Service_Id_Breakdown__c = 'asdasdasdsadasdas';
    config.Service_Id_Brokerage__c = 'asdasdasdasd';
    config.Service_Id_Duty__c = 'asdsadsadasdasd';
    config.Service_Id_FixedCharges__c = 'asdasdasdasdasd';
    config.Service_Id_InboundFreight__c = 'asdasdasdasdas';
    config.Service_Id_RunCharges__c = 'asdsadasdas';
    insert config;
  }

  public void createOpportunities() {
    List<Opportunity> allOpps = new List<Opportunity>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Opportunity opp = new Opportunity(Name = 'Opp ' + i);
      opp.StageName = 'Needs Analysis';
      opp.CloseDate = Date.today();
      allOpps.add(opp);
    }
    insert allOpps;
  }
  public void approveRejectOrder() {
    Order order = [
      SELECT
        id,
        Approved_By__c,
        Approved_Date__c,
        Work_Order_Notes__c,
        Sale_Order_Status__c,
        Invoice_Number__c
      FROM Order
      LIMIT 1
    ];

    order.Approved_By__c = 'Test User';
    order.Work_Order_Notes__c = 'Test Notes';
    order.Sale_Order_Status__c = 'Approved';
    order.Approved_Date__c = system.today();
    update order;
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
    activity.Type__c = order.Sale_Order_Status__c;
    activity.RelatedObjectId__c = order.Invoice_Number__c;
    activity.Opportunity__c = opp.id;
    activity.Approved_Date__c = order.Approved_Date__c;
    activity.Approved_By__c = order.Approved_By__c;
    insert activity;
  }

  public void createAccount(
    String bStreet,
    String bCity,
    String bState,
    String bCountry
  ) {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Account acc = new Account();
    acc.Name = 'Testing account';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.BillingStreet = bStreet;
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = bCity;
    acc.Billingstate = bState;
    acc.BillingCountry = bCountry;

    acc.ShippingStreet = bStreet;
    acc.ShippingCity = bCity;
    acc.ShippingState = bState;
    acc.ShippingCountry = bCountry;
    insert acc;
    opp.AccountId = acc.id;
    update opp;
    QBO_Details__c qboDetails = new QBO_Details__c();
    qboDetails.Account__c = acc.Id;
    qboDetails.Id_Type__c = 'Account';
    qboDetails.IsPrimary__c = true;
    qboDetails.QB_Id__c = '123';
    qboDetails.Salesforce_Record_Id__c = acc.Id;
    qboDetails.QBO_Account__c = 'Team Phun';
    insert qboDetails;

    QBO_Details__c qboDetailsTpSupply = new QBO_Details__c();
    qboDetailsTpSupply.Account__c = acc.Id;
    qboDetailsTpSupply.Id_Type__c = 'Account';
    qboDetailsTpSupply.IsPrimary__c = true;
    qboDetailsTpSupply.QB_Id__c = '123';
    qboDetailsTpSupply.Salesforce_Record_Id__c = acc.Id;
    qboDetailsTpSupply.QBO_Account__c = 'Team Phun';
    insert qboDetailsTpSupply;
  }

  public void createAccWithotAddress() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Account acc = new Account();
    acc.Name = 'Testing account';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testnoAddress@gmail.com';
    //acc.BillingStreet = bStreet;
    acc.QuickBooks_Accounts__c = 'Team Phun';
    //acc.Billingcity = bCity;
    //acc.Billingstate = bState;
    //acc.BillingCountry = bCountry;

    //acc.ShippingStreet = bStreet;
    //acc.ShippingCity = bCity;
    //acc.ShippingState = bState;
    //acc.ShippingCountry = bCountry;
    insert acc;
    opp.AccountId = acc.id;
    update opp;
    QBO_Details__c qboDetails = new QBO_Details__c();
    qboDetails.Account__c = acc.Id;
    qboDetails.Id_Type__c = 'Account';
    qboDetails.IsPrimary__c = true;
    qboDetails.QB_Id__c = '123';
    qboDetails.Salesforce_Record_Id__c = acc.Id;
    qboDetails.QBO_Account__c = 'Team Phun';
    insert qboDetails;

    QBO_Details__c qboDetailsTpSupply = new QBO_Details__c();
    qboDetailsTpSupply.Account__c = acc.Id;
    qboDetailsTpSupply.Id_Type__c = 'Account';
    qboDetailsTpSupply.IsPrimary__c = true;
    qboDetailsTpSupply.QB_Id__c = '123';
    qboDetailsTpSupply.Salesforce_Record_Id__c = acc.Id;
    qboDetailsTpSupply.QBO_Account__c = 'Team Phun';
    insert qboDetailsTpSupply;
  }
  public void createSimpleTestAccount() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    String bStreet = '4', bCity = 'Lhr', bState = 'Punjab', bCountry = 'Pak';
    Account acc = new Account();
    acc.Name = 'Testing account';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.BillingStreet = bStreet;
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = bCity;
    acc.Billingstate = bState;
    acc.BillingCountry = bCountry;

    acc.ShippingStreet = bStreet;
    acc.ShippingCity = bCity;
    acc.ShippingState = bState;
    acc.ShippingCountry = bCountry;
    insert acc;
  }

  public void createTestAccount() {
    Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    String bStreet = '4', bCity = 'Lhr', bState = 'Punjab', bCountry = 'Pak';
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    Account acc = new Account();
    acc.Name = 'Testing account';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.BillingStreet = bStreet;
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = bCity;
    acc.Billingstate = bState;
    acc.BillingCountry = bCountry;

    acc.ShippingStreet = bStreet;
    acc.ShippingCity = bCity;
    acc.ShippingState = bState;
    acc.ShippingCountry = bCountry;
    insert acc;
    opp.AccountId = acc.id;
    update opp;
    QBO_Details__c qboDetails = new QBO_Details__c();
    qboDetails.Account__c = acc.Id;
    qboDetails.Id_Type__c = 'Account';
    qboDetails.IsPrimary__c = true;
    qboDetails.QB_Id__c = '123';
    qboDetails.Salesforce_Record_Id__c = acc.Id;
    qboDetails.QBO_Account__c = 'Team Phun';
    insert qboDetails;

    QBO_Details__c qboDetailsTpSupply = new QBO_Details__c();
    qboDetailsTpSupply.Account__c = acc.Id;
    qboDetailsTpSupply.Id_Type__c = 'Account';
    qboDetailsTpSupply.IsPrimary__c = true;
    qboDetailsTpSupply.QB_Id__c = '123';
    qboDetailsTpSupply.Salesforce_Record_Id__c = acc.Id;
    qboDetailsTpSupply.QBO_Account__c = 'Team Phun';
    insert qboDetailsTpSupply;
  }

  public void createEstimate() {
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    opp.StageName = 'Presentation';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;
    Estimate__c estimate = new Estimate__c();
    estimate.In_Hands_Date__c = Date.today();
    estimate.Terms__c = 'Prepay';
    estimate.Customer_PO__c = '4';
    estimate.Opportunity__c = opp.id;
    insert estimate;
    opp.StageName = 'Estimate';
    opp.Estimate_Change_Status__c = 'not changed from picklist';
    update opp;
  }

  public void createActivity() {
    List<Opportunity_ACTIVITIES__c> activities = new List<Opportunity_ACTIVITIES__c>();
    List<Comment__c> comments = [
      SELECT id, OpportunityLineItem__c
      FROM Comment__c
    ];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    for (Comment__c comm : comments) {
      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = 'Comment';
      activity.RelatedObjectId__c = comm.OpportunityLineItem__c;
      activity.Comment__c = comm.id;
      activity.Opportunity__c = opp.id;
      activities.add(activity);
    }

    EmailMessage email = new EmailMessage();
    email.FromAddress = 'test@abc.org';
    email.Incoming = true;
    email.ToAddress = 'test@xyz.org';
    email.Subject = 'Test Email';
    email.HtmlBody = 'Test email body';
    email.RelatedToId = opp.id;
    insert email;

    Opportunity_ACTIVITIES__c activity2 = new Opportunity_ACTIVITIES__c();
    activity2.Type__c = 'Email';
    activity2.RelatedObjectId__c = email.id;
    activity2.Opportunity__c = email.RelatedToId;
    activities.add(activity2);

    Comment__c comment = [SELECT id, OpportunityLineItem__c FROM Comment__c];
    Opportunity_ACTIVITIES__c activity4 = new Opportunity_ACTIVITIES__c();
    activity4.Type__c = 'Proof (Change Requested)';
    activity4.RelatedObjectId__c = comment.id;
    activity4.Opportunity__c = opp.id;
    activity4.Approved_Date__c = Datetime.valueOf(System.now());
    activity4.Approved_By__c = 'Test User';
    activities.add(activity4);

    insert activities;
  }
  public void createSalesOrder() {
    createPriceBookEntry();
    Order order = new Order();
    Opportunity opp = [
      SELECT id, AccountId, Contact__c
      FROM Opportunity
      LIMIT 1
    ];
    order.OpportunityId = opp.id;
    order.Invoice_Number__c = 'SalesOrder-' + opp.id;
    order.Status = '01_-_Waiting_for_Client_Payment';
    order.EffectiveDate = system.today();
    order.Invoice_Terms__c = 'Credit Card';
    order.Primary_Contact__c = opp.Contact__c;
    order.AccountId = opp.AccountId;
    //  order.Account_Name__c = 'testName';
    order.Invoice_Value__c = 0;
    order.Invoice_Tax__c = 0;
    order.Invoice_Discount__c = 0;
    order.Invoice_Due_Date__c = system.today();
    order.Invoice_Total__c = 0;
    order.Invoice_Estimated_Ship_Date__c = '';
    insert order;
  }
  public void createPriceBookEntry() {
    Product2 prod = new Product2();
    prod.Name = 'Test Prod';
    prod.Product_Cost__c = 22;
    prod.Sales_Price_Rate__c = 22;
    prod.Sales_Tax_Category__c = 'Nontaxable';
    prod.Purchasing_Info__c = 'Info';
    prod.Supplier__c = 'Alphabroder';
    prod.Product_Supplier_Code__c = 'Code';
    prod.Net_Price__c = 22;
    insert prod;

    //Instantiate the Pricebook2 record with StandardPricebookId
    Pricebook2 standardPricebook = new Pricebook2(
      Id = Test.getStandardPricebookId(),
      IsActive = true
    );
    System.debug('Standard Price Book ' + standardPricebook);
    //Execute an update DML on the Pricebook2 record, to make IsStandard to true
    update standardPricebook;

    //Query for the Pricebook2 record, to check IsStandard field
    standardPricebook = [
      SELECT Id, IsStandard
      FROM Pricebook2
      WHERE Id = :standardPricebook.Id
    ];
    //It should return true

    //Create the PricebookEntry
    PricebookEntry pbe = new PricebookEntry(
      Pricebook2Id = standardPricebook.Id,
      Product2Id = prod.Id,
      UnitPrice = 1020,
      IsActive = true
    );
    insert pbe;
  }
  public void createDepositInvoice() {
    /*Order order = [SELECT id,Deposit_Invoice__c from Order Limit 1];
        Deposit_Invoice__c depositInfo = new Deposit_Invoice__c();
        depositInfo.Allow_credit_card__c = true;
        depositInfo.Amount_Received__c = 45;
        depositInfo.Confirmation__c = '0001';
        depositInfo.Deposit_Amount__c = ((12/100)*50);
        depositInfo.Deposit_Percent__c = 10;
        insert depositInfo;
        order.Deposit_Invoice__c = depositInfo.id;
        update order;*/
  }
  public void createProducts() {
    List<Product2> allProds = new List<Product2>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Product2 prod = new Product2();
      prod.Name = 'Test Prod ' + i;
      prod.Product_Cost__c = 22;
      prod.Sales_Price_Rate__c = 22;
      prod.isActive = true;
      prod.Sales_Tax_Category__c = 'Nontaxable';
      prod.Purchasing_Info__c = 'Info';
      prod.Supplier__c = 'Alphabroder';
      prod.Product_Supplier_Code__c = '81084';
      prod.Net_Price__c = 22;
      prod.Design_Project__c = true;
      allProds.add(prod);
    }

    insert allProds;
  }
  public void createProductsPrices() {
    List<Product2> prodList = [SELECT id FROM Product2];
    List<Pricing_Product__c> pricesList = new List<Pricing_Product__c>();
    for (Product2 prods : prodList) {
      Pricing_Product__c prodPrice = new Pricing_Product__c();
      prodPrice.Net_Cost__c = 21;
      prodPrice.Quantity__c = 1;
      prodPrice.Retail_Price__c = 98;
      prodPrice.Product__c = prods.id;
      pricesList.add(prodPrice);
    }
    insert pricesList;
  }
  public void createProductLineItems() {
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    List<Order> order = [SELECT id FROM Order LIMIT 1];
    System.debug(order);
    List<Estimate__c> lstEstimate = [SELECT id FROM Estimate__c LIMIT 1];

    Estimate__c estimate = new Estimate__c();
    if (lstEstimate.size() > 0) {
      estimate = lstEstimate.get(0);
    }
    List<Account> account = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    List<OpportunityLineItem__c> allItems = new List<OpportunityLineItem__c>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      OpportunityLineItem__c lineItem = new OpportunityLineItem__c();
      lineItem.Description__c = 'Desc';
      lineItem.Product__c = prod.Id;
      lineItem.Estimate__c = estimate.id;
      lineItem.Opportunity__c = opp.id;
      if (order != null && order.Size() > 0) {
        lineItem.Work_Order__c = order.get(0).id;
      }
      lineItem.Quantity_Estimate__c = 100;
      ////
      //  createOppProductLineAttachments(lineItem);
      ////
      allItems.add(lineItem);
    }
    insert allItems;
  }

  /*    public void createOppProductLineAttachments(OpportunityLineItem__c lineItem){
        OpportunityLineItemAttachment__c oppLineItemAttachment = new OpportunityLineItemAttachment__c();
        oppLineItemAttachment.Estimate__c = lineItem.Estimate__c;
        oppLineItemAttachment.OpportunityLineItem__c = lineItem.Id;
        oppLineItemAttachment.Estimate__c = lineItem.Estimate__c;
        oppLineItemAttachment.Estimate__c = lineItem.Estimate__c;
    }
*/
  //
  public void createOppProductLineItems() {
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    List<Order> order = [SELECT id FROM Order LIMIT 1];
    List<Estimate__c> lstEstimate = [SELECT id FROM Estimate__c LIMIT 1];

    Estimate__c estimate = new Estimate__c();
    if (lstEstimate.size() > 0) {
      estimate = lstEstimate.get(0);
    }
    List<OpportunityLineItem__c> allItems = new List<OpportunityLineItem__c>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      OpportunityLineItem__c lineItem = new OpportunityLineItem__c();
      lineItem.Description__c = 'Desc';
      lineItem.Product__c = prod.Id;
      lineItem.Estimate__c = estimate.id;
      lineItem.Opportunity__c = opp.id;
      if (order != null && order.Size() > 0) {
        lineItem.Work_Order__c = order.get(0).id;
      }

      lineItem.Quantity_Estimate__c = 100;
      allItems.add(lineItem);
    }
    insert allItems;
  }
  //
  public void createProductLineItemsRelatedItems() {
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    List<Estimate__c> estimate = [SELECT id FROM Estimate__c LIMIT 1];
    List<OpportunityLineItem__c> allItems = [
      SELECT id
      FROM OpportunityLineItem__c
    ];
    List<OpportunityLineItem_ArtWork__c> artWorkList = new List<OpportunityLineItem_ArtWork__c>();
    List<ColorLineItem__c> colors = new List<ColorLineItem__c>();
    List<PricingLineItem__c> pricing = new List<PricingLineItem__c>();
    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    List<Line_Item_Pricing_RunCharge__c> runCharges = new List<Line_Item_Pricing_RunCharge__c>();

    List<SizeLineItem__c> sizes = new List<SizeLineItem__c>();
    List<Comment__c> comments = new List<Comment__c>();

    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedChargesOfArtwork = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    List<Line_Item_Pricing_RunCharge__c> runChargesOfArtwork = new List<Line_Item_Pricing_RunCharge__c>();
    List<ExtraChargesEstimate__c> extraCharges = new List<ExtraChargesEstimate__c>();
    List<OpportunityLineItemAttachment__c> attachements = new List<OpportunityLineItemAttachment__c>();
    List<WarningsOpportunityLineItem__c> warningsToBeAdded = new List<WarningsOpportunityLineItem__c>();

    for (Integer i = 0; i < numberOfRecords; i++) {
      OpportunityLineItem_ArtWork__c art = new OpportunityLineItem_ArtWork__c();
      art.Title__c = 'ABC' + i;
      art.OpportunityLineItem__c = allItems[i].Id;
      artWorkList.add(art);

      Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(
        allItems[i].Id
      );
      Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(
        shippingInformation.Id
      );

      Line_Item_Pricing_RunCharge__c runCharge = new Line_Item_Pricing_RunCharge__c();
      runCharge.Title__c = 'ABC' + i;
      runCharge.OpportunityLineItem_ArtWork__c = artworkList[i].Id;
      runCharge.Is_Associated_With_Artwork__c = true;
      runCharge.OpportunityLineItem__c = allItems[i].Id;
      runCharge.EstimatedQuantity__c = 10;
      runCharge.Value1__c = 20;
      runCharge.Value2__c = 20;
      runCharge.Value3__c = 20;
      runCharge.Value4__c = 20;
      runCharge.Value5__c = 20;
      runCharges.add(runCharge);

      WarningsOpportunityLineItem__c warning = new WarningsOpportunityLineItem__c();
      warning.OpportunityLineItem__c = allItems[i].Id;
      warningsToBeAdded.add(warning);

      ColorLineItem__c color = new ColorLineItem__c();
      color.Color__c = 'Red';
      color.isSelected__c = true;
      color.OpportunityLineItem__c = allItems[i].id;
      colors.add(color);

      PricingLineItem__c price = new PricingLineItem__c();
      price.Quantity__c = i;
      price.Net_Cost__c = 22;
      price.Show_To_Client__c = true;
      price.Margin__c = 25;
      price.Estimated_Quantity__c = 10;
      price.Retail_Price__c = 10;
      price.Total__c = 10;
      price.Display__c = true;
      price.Default__c = false;
      if (estimate.size() > 0)
        price.Estimate__c = estimate.get(0).id;
      price.OpportunityLineItem__c = allItems[i].id;
      pricing.add(price);

      PricingLineItem__c priceRec = new PricingLineItem__c();
      priceRec.Quantity__c = 10;
      priceRec.Net_Cost__c = 22;
      priceRec.Show_To_Client__c = true;
      priceRec.Display__c = false;
      priceRec.Default__c = true;
      priceRec.Margin__c = 25;
      priceRec.Estimated_Quantity__c = 10;
      priceRec.Retail_Price__c = 10;
      if (estimate.size() > 0)
        price.Estimate__c = estimate.get(0).id;
      priceRec.Total__c = 10;
      priceRec.OpportunityLineItem__c = allItems[i].id;
      pricing.add(priceRec);

      PricingLineItem__c priceReco = new PricingLineItem__c();
      priceReco.Quantity__c = i;
      priceReco.Net_Cost__c = 22;
      priceReco.Show_To_Client__c = true;
      priceReco.Display__c = true;
      priceReco.Default__c = false;
      if (estimate.size() > 0)
        price.Estimate__c = estimate.get(0).id;
      priceReco.Margin__c = 25;
      priceReco.Total__c = 10;
      priceReco.Estimated_Quantity__c = 10;
      priceReco.Retail_Price__c = 10;
      priceReco.OpportunityLineItem__c = allItems[i].id;
      pricing.add(priceReco);

      PricingLineItem__c priceRecord = new PricingLineItem__c();
      priceRecord.Quantity__c = i;
      priceRecord.Net_Cost__c = 22;
      priceRecord.Show_To_Client__c = true;
      priceRecord.Display__c = true;
      priceRecord.Default__c = true;
      priceRecord.Margin__c = 25;
      priceRecord.Total__c = 10;
      priceRecord.Estimated_Quantity__c = 10;
      priceRecord.Retail_Price__c = 10;
      if (estimate.size() > 0)
        price.Estimate__c = estimate.get(0).id;
      priceRecord.OpportunityLineItem__c = allItems[i].id;
      pricing.add(priceRecord);

      OpportunityLineItem_Add_Fixed_Charge__c fixedCharge = new OpportunityLineItem_Add_Fixed_Charge__c();
      fixedCharge.Retail_Price__c = 22;
      fixedCharge.Margin__c = 10;
      fixedCharge.Cost__c = 10;
      fixedCharge.Is_Associated_With_Artwork_c__c = false;
      fixedCharge.OpportunityLineItem__c = allItems[i].id;
      fixedCharges.add(fixedCharge);

      SizeLineItem__c size = new SizeLineItem__c();
      size.Size__c = '16';
      size.isSelected__c = true;
      size.OpportunityLineItem__c = allItems[i].id;
      sizes.add(size);

      Comment__c comment = new Comment__c();
      comment.Comment__c = 'My comment';
      comment.Comment_Date__c = DateTime.now();
      comment.OpportunityLineItem__c = allItems[i].id;
      comments.add(comment);

      ExtraChargesEstimate__c extraChargefixed = new ExtraChargesEstimate__c();
      extraChargefixed.Quantity__c = 3;
      extraChargefixed.Retail_Price__c = 4;
      extraChargefixed.Margin__c = 4;
      extraChargefixed.Total__c = 12;
      extraChargefixed.Net_Cost__c = 4;
      extraChargefixed.Charge_Type__c = 'AdditionalCost_FixedCharge';
      extraChargefixed.OpportunityLineItem__c = allItems[i].id;
      extraChargefixed.Is_Associated_With_Artwork__c = false;
      extraCharges.add(extraChargefixed);

      ExtraChargesEstimate__c extraChargeRun = new ExtraChargesEstimate__c();
      extraChargeRun.Quantity__c = 3;
      extraChargeRun.Retail_Price__c = 4;
      extraChargeRun.Total__c = 12;
      extraChargeRun.Net_Cost__c = 4;
      extraChargeRun.Charge_Type__c = 'AdditionalCost_RunCharge';
      extraChargeRun.OpportunityLineItem__c = allItems[i].id;
      extraChargeRun.Is_Associated_With_Artwork__c = false;
      extraCharges.add(extraChargeRun);

      ExtraChargesEstimate__c extraChargeInboundFrieght = new ExtraChargesEstimate__c();
      extraChargeInboundFrieght.Quantity__c = 3;
      extraChargeInboundFrieght.Retail_Price__c = 4;
      extraChargeInboundFrieght.Total__c = 12;
      extraChargeInboundFrieght.Net_Cost__c = 4;
      extraChargeInboundFrieght.Charge_Type__c = 'InternationalCost_InboundFreight';
      extraChargeInboundFrieght.OpportunityLineItem__c = allItems[i].id;
      extraChargeInboundFrieght.Is_Associated_With_Artwork__c = false;
      extraCharges.add(extraChargeInboundFrieght);

      ExtraChargesEstimate__c extraChargeBrokerage = new ExtraChargesEstimate__c();
      extraChargeBrokerage.Quantity__c = 3;
      extraChargeBrokerage.Retail_Price__c = 4;
      extraChargeBrokerage.Total__c = 12;
      extraChargeBrokerage.Net_Cost__c = 4;
      extraChargeBrokerage.Charge_Type__c = 'InternationalCost_Brokerage';
      extraChargeBrokerage.OpportunityLineItem__c = allItems[i].id;
      extraChargeBrokerage.Is_Associated_With_Artwork__c = false;
      extraCharges.add(extraChargeBrokerage);

      ExtraChargesEstimate__c extraChargeDuty = new ExtraChargesEstimate__c();
      extraChargeDuty.Quantity__c = 3;
      extraChargeDuty.Retail_Price__c = 4;
      extraChargeDuty.Total__c = 12;
      extraChargeDuty.Net_Cost__c = 4;
      extraChargeDuty.Charge_Type__c = 'InternationalCost_Duty';
      extraChargeDuty.OpportunityLineItem__c = allItems[i].id;
      extraChargeDuty.Is_Associated_With_Artwork__c = false;
      extraCharges.add(extraChargeDuty);

      ExtraChargesEstimate__c extraChargefixedArtwork = new ExtraChargesEstimate__c();
      extraChargefixedArtwork.Quantity__c = 3;
      extraChargefixedArtwork.Retail_Price__c = 4;
      extraChargefixedArtwork.Total__c = 12;
      extraChargefixedArtwork.Net_Cost__c = 4;
      extraChargefixedArtwork.OpportunityLineItem_ArtWork__c = artworkList[i]
        .Id;
      extraChargefixedArtwork.Charge_Type__c = 'AdditionalCost_FixedCharge';
      extraChargefixedArtwork.OpportunityLineItem__c = allItems[i].id;
      extraChargefixedArtwork.Is_Associated_With_Artwork__c = true;
      extraCharges.add(extraChargefixedArtwork);

      ExtraChargesEstimate__c extraChargeRunArtwork = new ExtraChargesEstimate__c();
      extraChargeRunArtwork.Quantity__c = 3;
      extraChargeRunArtwork.Retail_Price__c = 4;
      extraChargeRunArtwork.Total__c = 12;
      extraChargeRunArtwork.Net_Cost__c = 4;
      extraChargeRunArtwork.Charge_Type__c = 'AdditionalCost_RunCharge';
      extraChargeRunArtwork.OpportunityLineItem_ArtWork__c = artworkList[i].Id;
      extraChargeRunArtwork.OpportunityLineItem__c = allItems[i].id;
      extraChargeRunArtwork.Is_Associated_With_Artwork__c = true;
      extraCharges.add(extraChargeRunArtwork);
    }
    insert colors;
    insert artWorkList;
    insert pricing;
    insert fixedCharges;
    insert runCharges;
    insert sizes;
    insert comments;
    insert extraCharges;
    insert warningsToBeAdded;

    for (Integer i = 0; i < numberOfRecords; i++) {
      Line_Item_Pricing_RunCharge__c runChargeArtwork = new Line_Item_Pricing_RunCharge__c();
      runChargeArtwork.Title__c = 'ABC' + i;
      runChargeArtwork.OpportunityLineItem_ArtWork__c = artworkList[i].Id;
      runChargeArtwork.Is_Associated_With_Artwork__c = true;
      runChargeArtwork.OpportunityLineItem__c = allItems[i].Id;
      runChargeArtwork.Value1__c = 20;
      runChargeArtwork.Value2__c = 20;
      runChargeArtwork.Value3__c = 20;
      runChargeArtwork.Value4__c = 20;
      runChargeArtwork.Value5__c = 20;
      runChargesOfArtwork.add(runChargeArtwork);

      OpportunityLineItem_Add_Fixed_Charge__c fixedChargeArt = new OpportunityLineItem_Add_Fixed_Charge__c();
      fixedChargeArt.Title__c = 'ABC' + i;
      fixedChargeArt.OpportunityLineItem__c = allItems[i].Id;
      fixedChargeArt.Is_Associated_With_Artwork_c__c = true;
      fixedChargeArt.Cost__c = 20;
      fixedChargeArt.OpportunityLineItem_ArtWork__c = artworkList[i].Id;
      fixedChargeArt.Margin__c = 20;
      fixedChargeArt.Retail_Price__c = 20;
      fixedChargesOfArtwork.add(fixedChargeArt);
    }

    insert fixedChargesOfArtwork;
    insert runChargesOfArtwork;
  }

  public void createArtWork() {
    List<OpportunityLineItem_ArtWork__c> artWorkList = new List<OpportunityLineItem_ArtWork__c>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      OpportunityLineItem_ArtWork__c art = new OpportunityLineItem_ArtWork__c();

      art.Title__c = 'ABC' + i;
      artWorkList.add(art);
    }
    insert artWorkList;
  }

  public void createRunCharge() {
    List<Line_Item_Pricing_RunCharge__c> runCharges = new List<Line_Item_Pricing_RunCharge__c>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Line_Item_Pricing_RunCharge__c runCharge = new Line_Item_Pricing_RunCharge__c();
      runCharge.Title__c = 'ABC' + i;
      runCharge.Value1__c = 20;
      runCharge.Value2__c = 20;
      runCharge.Value3__c = 20;
      runCharge.Value4__c = 20;
      runCharge.Value5__c = 20;
      runCharges.add(runCharge);
    }
    insert runCharges;
  }
  public void createFixedCharge() {
    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      OpportunityLineItem_Add_Fixed_Charge__c fixedCharge = new OpportunityLineItem_Add_Fixed_Charge__c();
      fixedCharge.Title__c = 'ABC' + i;
      fixedCharge.Cost__c = 20;
      fixedCharge.Margin__c = 20;
      fixedCharge.Retail_Price__c = 20;
      fixedCharges.add(fixedCharge);
    }
    insert fixedCharges;
  }
  public void addAddressRelatedData() {
    List<RecordType> lstrecordType = [
      SELECT SobjectType, Id, Name
      FROM RecordType
      WHERE SobjectType = 'Account' AND Name LIKE 'Vendor%'
    ];

    Account acc = new Account();
    acc.Name = 'Supplier account';
    acc.Billing_Email__c = 'testing12@gmail.com';
    acc.Art_Approval_Email__c = 'testing12@gmail.com';
    if (lstrecordType != null && lstrecordType.size() > 0)
      acc.RecordTypeId = lstrecordType.get(0).id;
    acc.BillingStreet = '5';
    acc.Billingcity = 'LHR';
    acc.Billingstate = 'Punjab';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.BillingCountry = 'PAK';
    insert acc;
    Address__c addressObj = new Address__c();
    addressObj.Account__c = acc.id;
    addressObj.Name = 'AddressName';
    insert addressObj;
  }
  public void createPurchaseOrder() {
    Order workOrder = [
      SELECT OpportunityId, Id
      FROM Order
      LIMIT 1
    ];
    PurchaseOrder__c purchaseOrder = new PurchaseOrder__c();
    purchaseOrder.Opportunity__c = workOrder.OpportunityId;
    purchaseOrder.Purchase_Order_Date__c = System.Today();
    insert purchaseOrder;
  }
  public void createPurchaseOrders() {
    Order workOrder = [
      SELECT OpportunityId, Id
      FROM Order
      LIMIT 1
    ];
    PurchaseOrder_LineItem__c purchaseOrder = new PurchaseOrder_LineItem__c();
    purchaseOrder.WO_Status__c = 'Open';
    purchaseOrder.Shipping_Information__c = [
      SELECT id
      FROM Shipping_Information__c
      LIMIT 1
    ]
    .Id;
    insert purchaseOrder;
  }
  public void saveShippingInformation() {
    List<Account> account = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Shipping_Information__c shippingInformation = new Shipping_Information__c();
    shippingInformation.Ship_To__c = 'Client';
    shippingInformation.Supplier__c = account[0].id;
    insert shippingInformation;
    List<OpportunityLineItem__c> opportunityLineItems = [
      SELECT
        Id,
        Name,
        Shipping_Information__r.Ship_To__c,
        Description__c,
        Shipping_Information__r.In_Hands_Date__c,
        Product__c,
        Product__r.Name,
        SKU__c,
        Supplier__c,
        CreatedDate,
        Work_Order__c,
        Shipping_Information__r.supplier__c
      FROM OpportunityLineItem__c
    ];
    for (OpportunityLineItem__c lineItem : opportunityLineItems) {
      lineItem.Shipping_Information__c = shippingInformation.Id;
    }
    update opportunityLineItems;
  }
  public void createPurchaseOrderAndPurchaseOrderLineItems() {
    Order workOrder = [
      SELECT OpportunityId, Id
      FROM Order
      LIMIT 1
    ];

    List<Account> account = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Product2 prod = [SELECT id FROM Product2 LIMIT 1];
    Opportunity opp = [SELECT id FROM Opportunity LIMIT 1];
    List<Order> order = [SELECT id FROM Order LIMIT 1];
    List<Estimate__c> lstEstimate = [SELECT id FROM Estimate__c LIMIT 1];

    Estimate__c estimate = new Estimate__c();
    if (lstEstimate.size() > 0) {
      estimate = lstEstimate.get(0);
    }
    List<PurchaseOrder_LineItem__c> poLineItems = new List<PurchaseOrder_LineItem__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      PurchaseOrder_LineItem__c po = new PurchaseOrder_LineItem__c();
      po.WO_Status__c = 'Open';
      po.Boxes__c = '25';
      po.Signed_for_By__c = 'Test User';
      po.Supplier__c = account[0].Id;
      po.Delivery_Date_Time__c = Date.valueOf('2008-01-01 00:00:00');
      po.Work_Order__c = workOrder.Id;
      poLineItems.add(po);
    }
    insert poLineItems;

    List<Comment__c> commentsToBeInserted = new List<Comment__c>();
    for (Integer i = 0; i < numberOfRecords; i++) {
      Comment__c comm = new Comment__c();
      comm.Comment__c = 'comment';
      comm.Date__c = System.now().format('MM-dd-yyyy');
      comm.PurchaseOrder_LineItem__c = poLineItems[i].Id;
      commentsToBeInserted.add(comm);
    }
    insert commentsToBeInserted;
    List<OpportunityLineItem__c> allItems = new List<OpportunityLineItem__c>();
    List<Proof__c> proofToBeInserted = new List<Proof__c>();
    //List<Account> account = [SELECT Id, Name
    //                       FROM account
    //                     WHERE Name = 'Supplier account'];
    Shipping_Information__c shippingInformation = new Shipping_Information__c();
    shippingInformation.Ship_To__c = 'Client';
    shippingInformation.Supplier__c = account[0].id;
    insert shippingInformation;
    for (Integer i = 0; i < numberOfRecords; i++) {
      OpportunityLineItem__c lineItem = new OpportunityLineItem__c();
      lineItem.Description__c = 'Desc';
      lineItem.Product__c = prod.Id;
      lineItem.Estimate__c = estimate.id;
      lineItem.PurchaseOrder_LineItem__c = poLineItems[i].Id;
      lineItem.Opportunity__c = opp.id;
      if (order != null && order.Size() > 0) {
        lineItem.Work_Order__c = order.get(0).id;
      }

      lineItem.Quantity_Estimate__c = 100;
      lineItem.Shipping_Information__c = shippingInformation.Id;
      allItems.add(lineItem);
    }
    insert allItems;
    insert proofToBeInserted;
    /*List<Comment__c> commentsToBeInsertedProof = new List<Comment__c>();
        for (Integer i = 0 ; i < numberOfRecords ; i++)
        {
            Comment__c comm = new Comment__c();
            comm.Proof__c = proofToBeInserted[i].Id;
            comm.Comment__c = 'Comment';
            commentsToBeInsertedProof.add(comm);
        }
        insert commentsToBeInsertedProof;
        
        */

    List<Account> acc = [
      SELECT Id, Name
      FROM account
      WHERE Name = 'Supplier account'
    ];
    Address__c addressObj = [
      SELECT Id, Name
      FROM Address__c
      WHERE Name = 'AddressName'
    ];
    List<PricingLineItem__c> pricing = new List<PricingLineItem__c>();
    if (acc.Size() > 0) {
      for (Integer i = 0; i < numberOfRecords; i++) {
        Shipping_Information__c shippingInformation1 = ShippingMainComponentController.getRelatedShipping_InformationItems(
          allItems[i].Id
        );
        Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(
          shippingInformation.Id
        );
        shippingInformation1.Ship_To__c = 'Client';
        shippingInformation1.Supplier__c = acc[0].id;
        Account decoratorAccount = getAccountRecord(shipping.Decorator__c);
        Account otherSupplierAccount = getAccountRecord(shipping.Supplier__c);
        Address__c decoratorAddress = getAddressRecord(
          shipping.Decorator_Address__c
        );
        Address__c otherSupplierAddress = getAddressRecord(
          shipping.Supplier_Address__c
        );
        String clientAddress = 'Test ' + i;
        String otherAddress = 'Test ' + i;
        String otherSupplierAddressStr = 'Test ' + i;
        String decoratorAddressStr = 'Test ' + i;
        String decoratorClientAddress = 'Test ' + i;
        ShippingMainComponentController.saveData(
          shippingInformation1,
          acc[0],
          shipping,
          decoratorAccount,
          decoratorAddress,
          otherSupplierAccount,
          otherSupplierAddress,
          clientAddress,
          otherAddress,
          otherSupplierAddressStr,
          decoratorAddressStr,
          decoratorClientAddress
        );

        PricingLineItem__c priceReco = new PricingLineItem__c();
        priceReco.Quantity__c = i;
        priceReco.Net_Cost__c = 22;
        priceReco.Show_To_Client__c = true;
        priceReco.Display__c = true;
        priceReco.Default__c = false;
        priceReco.Color__c = 'asd';
        priceReco.Size__c = 'xl';
        priceReco.Margin__c = 25;
        priceReco.Estimated_Quantity__c = 10;
        priceReco.Retail_Price__c = 10;
        priceReco.OpportunityLineItem__c = allItems[i].id;
        pricing.add(priceReco);
      }
      insert pricing;
    }
  }

  /*    public static void getShippingInfo()
    {
                List<Account> acc = [SELECT Id, Name 
                             FROM account 
                             WHERE Name = 'Supplier account'];
        
        if(acc.Size()>0)
        {
            for(Integer i = 0 ; i < numberOfRecords ; i++)
            {
                Shipping_Information__c shippingInformation = ShippingMainComponentController.getRelatedShipping_InformationItems(allItems[i].Id);
                Shipping__c shipping = ShippingMainComponentController.getRelatedShipping_Items(shippingInformation.Id);
                shippingInformation.Ship_To__c = 'Client';
                shippingInformation.Supplier__c = acc[0].id;
                Account decoratorAccount =  getAccountRecord(shipping.Decorator__c);
                Account otherSupplierAccount =  getAccountRecord(shipping.Supplier__c);
                Address__c decoratorAddress = getAddressRecord(shipping.Decorator_Address__c);
                Address__c otherSupplierAddress = getAddressRecord(shipping.Supplier_Address__c);
                lineItem.Shipping_Information__c = shippingInformation;
                ShippingMainComponentController.saveData(shippingInformation, acc[0], shipping, decoratorAccount, decoratorAddress, otherSupplierAccount, otherSupplierAddress);
                
                    }
        }
    }
*/
  public static Account getAccountRecord(String finalId) {
    if (finalId != null) {
      String sQuery = 'SELECT id, Name FROM Account WHERE Id = ' + finalId;
      try {
        List<Account> lstOfRecords = Database.query(sQuery);
        for (Account obj : lstOfRecords) {
          Test.stopTest();
          return obj;
        }
      } catch (Exception e) {
        System.debug('Exception Occurs :- ' + e.getMessage());
      }
      Test.stopTest();
      return null;
    }
    return null;
  }
  public static Address__c getAddressRecord(String finalId) {
    if (finalId != null) {
      String sQuery = 'SELECT id, Name FROM Address__c WHERE Id = ' + finalId;
      try {
        List<Address__c> lstOfRecords = Database.query(sQuery);
        for (Address__c obj : lstOfRecords) {
          return obj;
        }
        return null;
      } catch (Exception e) {
        System.debug('Exception Occurs :- ' + e.getMessage());
        throw new AuraHandledException(e.getMessage());
      }
    }
    return null;
  }
  public List<opportunity> TestDataForUpdateMargin() {
    //created account
    Account acc = new Account();
    acc.Name = 'Testing account789';
    acc.Billing_Email__c = 'testing@gmail.com';
    acc.Art_Approval_Email__c = 'testing@gmail.com';
    acc.BillingStreet = 'TestBS';
    acc.QuickBooks_Accounts__c = 'Team Phun';
    acc.Billingcity = 'testCity789';
    acc.Billingstate = 'testState789';
    acc.BillingCountry = 'testCountry789';

    acc.ShippingStreet = 'testSTreet';
    acc.ShippingCity = 'testSCity';
    acc.ShippingState = 'TestSS';
    acc.ShippingCountry = 'TestSc';
    try {
      insert acc;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    //created opportunity
    List<Opportunity> allOpps = new List<Opportunity>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Opportunity opp = new Opportunity(Name = 'Opp ' + i);
      opp.StageName = 'Needs Analysis';
      opp.CloseDate = Date.today();
      opp.AccountId = acc.id;
      allOpps.add(opp);
    }
    try {
      insert allOpps;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    Estimate__c estimate = new Estimate__c();
    estimate.In_Hands_Date__c = Date.today();
    estimate.Terms__c = 'Prepay';
    estimate.Customer_PO__c = '4';
    estimate.Opportunity__c = allOpps[0].id;
    try {
      insert estimate;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    //created product
    Product2 prod = new Product2();
    prod.Name = 'Test Prod ';
    prod.Product_Cost__c = 22;
    prod.Sales_Price_Rate__c = 22;
    prod.isActive = true;
    prod.Sales_Tax_Category__c = 'Nontaxable';
    prod.Purchasing_Info__c = 'Info';
    prod.Supplier__c = 'Alphabroder';
    prod.Product_Supplier_Code__c = '81084';
    prod.Net_Price__c = 22;
    prod.Design_Project__c = true;
    try {
      insert prod;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    //created opportunityLineitem
    OpportunityLineItem__c lineItem = new OpportunityLineItem__c();
    lineItem.Description__c = 'Desc';
    lineItem.Product__c = prod.Id;
    lineItem.Opportunity__c = allOpps[0].id;
    lineItem.Estimate__c = estimate.id;
    lineItem.Quantity_Estimate__c = 100;
    try {
      insert lineItem;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    //created productLineitem record
    List<PricingLineItem__c> PricingList = new List<PricingLineItem__c>();
    PricingLineItem__c price = new PricingLineItem__c();
    for (integer i = 0; i < 2; i++) {
      price.Quantity__c = 1;
      price.Net_Cost__c = 22;
      price.Show_To_Client__c = true;
      price.Margin__c = 55;
      if (i == 0)
        price.Estimated_Quantity__c = 10;
      price.Retail_Price__c = 10;
      price.Total__c = 10;
      price.Display__c = true;
      price.Default__c = false;
      price.OpportunityLineItem__c = lineItem.id;
      PricingList.add(price);
      price = new PricingLineItem__c();
    }
    try {
      insert PricingList;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    //created fix charge record
    OpportunityLineItem_Add_Fixed_Charge__c fixedCharge = new OpportunityLineItem_Add_Fixed_Charge__c();
    fixedCharge.Retail_Price__c = 22;
    fixedCharge.Margin__c = 10;
    fixedCharge.Cost__c = 10;
    fixedCharge.Is_Associated_With_Artwork_c__c = false;
    fixedCharge.OpportunityLineItem__c = lineItem.id;
    try {
      insert fixedCharge;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    // created extra charge estimate record
    ExtraChargesEstimate__c extraChargefixed = new ExtraChargesEstimate__c();
    extraChargefixed.Quantity__c = 3;
    extraChargefixed.Retail_Price__c = 4;
    extraChargefixed.Margin__c = 4;
    extraChargefixed.Total__c = 12;
    extraChargefixed.Net_Cost__c = 4;
    extraChargefixed.Charge_Type__c = 'AdditionalCost_FixedCharge';
    extraChargefixed.OpportunityLineItem__c = lineItem.id;
    extraChargefixed.Is_Associated_With_Artwork__c = false;
    try {
      insert extraChargefixed;
    } catch (exception e) {
      system.debug(
        'Error: ' + e.getStackTraceString() + ' Message: ' + e.getMessage()
      );
    }
    return allOpps;
  }
}
