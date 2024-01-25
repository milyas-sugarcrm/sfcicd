@isTest
public class TestFactoryPfa {
  static final Id pfaRecordTypeIdProduct = CommonUtilitiesPfa.getRecordTypeIdByName(
    Constants.PRODUCT2_API_NAME,
    Constants.PFA_PRODUCT
  );
  static final Id pfaOppRecordTypeId = CommonUtilitiesPfa.getRecordTypeIdByName(
    Constants.OPPORTUNITY_API_NAME,
    Constants.PFA_CUSTOMER_OPPORTUNITY
  );
  static final Id pfaAccountRecordTypeId = CommonUtilitiesPfa.getRecordTypeIdByName(
    Constants.ACCOUNT_API_NAME,
    Constants.PFA_CUSTOMER_Account
  );

  Integer numberOfRecords;

  public TestFactoryPfa() {
    this.numberOfRecords = 1;
  }

  public TestFactoryPfa(Integer NoOfRecords) {
    this.numberOfRecords = NoOfRecords;
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

  public void createOpportunities() {
    List<Opportunity> allOpps = new List<Opportunity>();
    for (Integer i = 1; i <= numberOfRecords; i++) {
      Opportunity opp = new Opportunity(Name = 'Opp ' + i);
      opp.StageName = 'Needs Analysis';
      opp.CloseDate = Date.today();
      opp.RecordTypeId = pfaOppRecordTypeId;
      allOpps.add(opp);
    }
    insert allOpps;
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
    acc.RecordTypeId = pfaAccountRecordTypeId;
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
    acc.RecordTypeId = pfaAccountRecordTypeId;
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
      prod.RecordTypeId = pfaRecordTypeIdProduct;
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
}
