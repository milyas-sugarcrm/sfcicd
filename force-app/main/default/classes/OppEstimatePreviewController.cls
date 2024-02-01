public class OppEstimatePreviewController {
  public final Opportunity opp { get; set; }
  decimal pageTotal = 0;
  String oppLink;
  Boolean restRequestNeeded = System.isFuture() || System.isScheduled(); // System.isBatch() too?
  public OppEstimatePreviewController() {
    String oppId = ApexPages.currentPage().getParameters().get('id');
    if (oppId != null)
      this.opp = [
        SELECT
          Id,
          Name,
          Owner.Name,
          Owner.Email,
          Expration_Date__c,
          Estimate_Date__c,
          Shipping_Date__c
        FROM Opportunity
        WHERE id = :oppId
      ];
  }
  public OppEstimatePreviewController(
    ApexPages.StandardController stdController
  ) {
    this.opp = (Opportunity) stdController.getRecord();
  }
  public String getBillingAddressPreview() {
    Opportunity opportunity = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE id = :opp.id
    ];
    Account account = [
      SELECT
        Id,
        Name,
        billingstreet,
        billingcity,
        billingstate,
        billingPostalCode,
        BillingCountry
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    String address;
    if (account.billingstreet != null) {
      address = account.billingstreet;
    }
    if (account.billingcity != null) {
      if (address != null) {
        address = address + '<br/>' + account.billingcity;
      } else
        address = account.billingcity;
    }
    if (account.billingstate != null) {
      if (address != null) {
        address =
          address +
          ', ' +
          account.billingstate +
          ' ' +
          account.billingPostalCode;
      } else
        address = account.billingstate + ' ' + account.billingPostalCode;
    }
    if (account.BillingCountry != null) {
      if (address != null) {
        address = address + '<br/>' + account.BillingCountry;
      } else
        address = account.BillingCountry;
    }
    return address;
  }
  public String getShippingAddressPreview() {
    Opportunity opportunity = [
      SELECT Id, AccountId
      FROM Opportunity
      WHERE id = :opp.id
    ];
    Account account = [
      SELECT
        Id,
        shippingstreet,
        shippingcity,
        shippingstate,
        shippingPostalCode,
        shippingCountry
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    String address;
    if (account.shippingstreet != null) {
      address = account.shippingstreet;
    }
    if (account.shippingcity != null) {
      if (address != null) {
        address = address + '<br/>' + account.shippingcity;
      } else
        address = account.shippingcity;
    }
    if (account.shippingstate != null) {
      if (address != null) {
        address =
          address +
          ', ' +
          account.shippingstate +
          ' ' +
          account.shippingPostalCode;
      } else
        address = account.shippingstate + ' ' + account.shippingPostalCode;
    }
    if (account.shippingCountry != null) {
      if (address != null) {
        address = address + '<br/>' + account.shippingCountry;
      } else
        address = account.shippingCountry;
    }
    return address;
  }

  public Map<String, String> getBillingAddress() {
    Opportunity opportunity = [
      SELECT Id, AccountId, Billing_Address1__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    Address billingAddress = opportunity.Billing_Address1__c;
    Map<String, String> address = new Map<String, String>();
    if (billingAddress != null) {
      if (billingAddress.getStreet() != null) {
        address.put('billingstreet', billingAddress.getStreet());
      } else {
        address.put('billingstreet', '');
      }
      if (billingAddress.getCity() != null) {
        address.put('billingcity', billingAddress.getCity() + ', ');
      } else {
        address.put('billingcity', ', ');
      }
      if (billingAddress.getState() != null) {
        address.put(
          'billingstate',
          billingAddress.getState() + ' ' + billingAddress.getPostalCode()
        );
      } else {
        address.put('billingstate', '');
      }
      if (billingAddress.getCountry() != null) {
        address.put('BillingCountry', billingAddress.getCountry());
      } else {
        address.put('BillingCountry', '');
      }
    } else {
      Account account = [
        SELECT
          Id,
          Name,
          billingstreet,
          billingcity,
          billingstate,
          billingPostalCode,
          BillingCountry
        FROM Account
        WHERE id = :opportunity.AccountId
      ];
      if (account.billingstreet != null) {
        address.put('billingstreet', account.billingstreet);
      } else {
        address.put('billingstreet', '');
      }
      if (account.billingcity != null) {
        address.put('billingcity', account.billingcity + ', ');
      } else {
        address.put('billingcity', ', ');
      }
      if (account.billingstate != null) {
        address.put(
          'billingstate',
          account.billingstate + ' ' + account.billingPostalCode
        );
      } else {
        address.put('billingstate', '');
      }
      if (account.BillingCountry != null) {
        address.put('BillingCountry', account.BillingCountry);
      } else {
        address.put('BillingCountry', '');
      }
    }
    return address;
  }
  public Map<String, String> getShippingAddress() {
    Opportunity opportunity = [
      SELECT Id, AccountId, Shipping_Address__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    Address shippingAddress = opportunity.Shipping_Address__c;
    Map<String, String> address = new Map<String, String>();
    if (shippingAddress != null) {
      if (shippingAddress.getStreet() != null) {
        address.put('shippingstreet', shippingAddress.getStreet());
      } else {
        address.put('shippingstreet', '');
      }
      if (shippingAddress.getCity() != null) {
        address.put('shippingcity', shippingAddress.getCity());
      } else {
        address.put('shippingcity', '');
      }
      if (shippingAddress.getState() != null) {
        address.put(
          'shippingstate',
          shippingAddress.getState() + ' ' + shippingAddress.getPostalCode()
        );
      } else {
        address.put('shippingstate', '');
      }
      if (shippingAddress.getCountry() != null) {
        address.put('shippingCountry', shippingAddress.getCountry());
      } else {
        address.put('shippingCountry', '');
      }
    } else {
      Account account = [
        SELECT
          Id,
          shippingstreet,
          shippingcity,
          shippingstate,
          shippingPostalCode,
          shippingCountry
        FROM Account
        WHERE id = :opportunity.AccountId
      ];
      if (account.shippingstreet != null) {
        address.put('shippingstreet', account.shippingstreet);
      } else {
        address.put('shippingstreet', '');
      }
      if (account.shippingcity != null) {
        address.put('shippingcity', account.shippingcity);
      } else {
        address.put('shippingcity', '');
      }
      if (account.shippingstate != null) {
        address.put(
          'shippingstate',
          account.shippingstate + ' ' + account.shippingPostalCode
        );
      } else {
        address.put('shippingstate', '');
      }
      if (account.shippingCountry != null) {
        address.put('shippingCountry', account.shippingCountry);
      } else {
        address.put('shippingCountry', '');
      }
    }
    return address;
  }
  public Estimate__c getEstimateDetails() {
    List<Estimate__c> estimate = [
      SELECT
        Id,
        Name,
        Estimate_Number__c,
        Approved_By__c,
        Approved_Date__c,
        Client_Approval_Status__c,
        Default_Tax__c,
        In_Hands_Date__c,
        Terms__c,
        Customer_PO__c
      FROM Estimate__c
      WHERE Opportunity__r.id = :opp.id
    ];
    if (estimate.get(0).Approved_Date__c != null) {
      estimate.get(0).Estimate_Number__c = estimate.get(0)
        .Approved_Date__c.format('dd-MM-yyyy');
    }
    return estimate.get(0);
  }
  public List<QuriedProductsForOpportunityEstimate> getLineItemsList() {
    List<QuriedProductsForOpportunityEstimate> LineItemsList = new List<QuriedProductsForOpportunityEstimate>();

    List<Estimate__c> estimate = [
      SELECT Id, Opportunity__r.id
      FROM Estimate__c
      WHERE Opportunity__r.id = :opp.id
    ];
    List<OpportunityLineItem__c> lineItemDetailsUnsorted = [
      SELECT
        id,
        Name,
        Estimate__r.id,
        Quantity_Estimate__c,
        Description__c,
        Product__r.id,
        Product__r.Name,
        ContentDocument_ID__c,
        CreatedDate,
        Sorting_Date__c
      FROM OpportunityLineItem__c
      WHERE Estimate__r.id = :estimate[0].id
      ORDER BY Sorting_Date__c ASC
    ];

    //Sorting Logic
    List<OpportunityLineItem__c> lineItemDetails = ProductsSorting.sortProducts(
      lineItemDetailsUnsorted
    );

    List<String> ids = new List<String>();
    List<Id> selectContentDocIds = new List<Id>();
    Map<Id, String> selectImageRelatedToOpp = new Map<Id, String>();
    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      ids.add(lineItems.id);
      if (lineItems.ContentDocument_ID__c != null) {
        selectContentDocIds.add(lineItems.ContentDocument_ID__c);
      }
    }

    List<ContentDistribution> CDList = [
      SELECT ContentDocumentId, ContentDownloadUrl
      FROM ContentDistribution
      WHERE ContentDocumentId IN :selectContentDocIds
    ];

    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      for (ContentDistribution cd : CDList) {
        if (lineItems.ContentDocument_ID__c == cd.ContentDocumentId) {
          selectImageRelatedToOpp.put(lineItems.Id, cd.ContentDownloadUrl);
        }
      }
    }

    List<ColorLineItem__c> colors;
    List<SizeLineItem__c> sizes;
    List<PricingLineItem__c> pricing;
    List<OpportunityLineItem_ArtWork__c> lineItemArtWork;
    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges;
    List<Line_Item_Pricing_RunCharge__c> runCharges;
    List<ExtraChargesEstimate__c> extraCharges;
    List<ContentDocumentLink> relatedImages = new List<ContentDocumentLink>();
    List<ContentDocumentLink> artworkImages = new List<ContentDocumentLink>();

    colors = [
      SELECT OpportunityLineItem__c, isSelected__c, Color__c
      FROM ColorLineItem__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    pricing = [
      SELECT
        Id,
        Quantity__c,
        Color__c,
        Size__c,
        Net_Cost__c,
        Retail_Price__c,
        Margin__c,
        Total__c,
        Show_To_Client__c,
        Estimate__c,
        Estimated_Quantity__c,
        Display__c,
        Default__c,
        OpportunityLineItem__c
      FROM PricingLineItem__c
      WHERE
        OpportunityLineItem__c IN :ids
        AND Display__c = TRUE
        AND Default__c = FALSE
      ORDER BY CreatedDate ASC
    ];
    extraCharges = [
      SELECT
        Id,
        Title__c,
        Quantity__c,
        Charge_Type__c,
        Margin__c,
        Retail_Price__c,
        Total__c,
        Display__c,
        Duty_Percentage__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem__c,
        Default__c,
        Net_Cost__c
      FROM ExtraChargesEstimate__c
      WHERE OpportunityLineItem__c IN :ids
      ORDER BY CreatedDate ASC
    ];
    lineItemArtWork = [
      SELECT
        id,
        OpportunityLineItem__c,
        Document_ID__c,
        Proof_Required__c,
        Title__c,
        Imprint_Type__c,
        Logo_Color__c,
        logo_Name__c,
        Logo_Size__c
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    fixedCharges = [
      SELECT
        OpportunityLineItem__c,
        Name,
        EstimatedQuantity__c,
        Cost__c,
        Retail_Price__c,
        Title__c
      FROM OpportunityLineItem_Add_Fixed_Charge__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    runCharges = [
      SELECT
        OpportunityLineItem__c,
        Title__c,
        EstimatedQuantity__c,
        Counter__c,
        Value1__c,
        Value2__c,
        Value3__c,
        Value4__c,
        Value5__c
      FROM Line_Item_Pricing_RunCharge__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    sizes = [
      SELECT OpportunityLineItem__c, isSelected__c, Size__c
      FROM SizeLineItem__c
      WHERE OpportunityLineItem__c IN :ids
    ];
    List<OpportunityLineItemAttachment__c> attachements = [
      SELECT id, OpportunityLineItem__c
      FROM OpportunityLineItemAttachment__c
      WHERE OpportunityLineItem__c IN :ids
    ];

    List<String> attachmentiIds = new List<String>();
    for (OpportunityLineItemAttachment__c attachment : attachements) {
      attachmentiIds.add(attachment.id);
    }

    List<String> artworkiIds = new List<String>();
    for (OpportunityLineItem_ArtWork__c artworkImg : lineItemArtWork) {
      artworkiIds.add(artworkImg.id);
    }

    Map<Id, List<String>> relatedImagesMap = new Map<Id, List<String>>();

    if (attachmentiIds.size() > 0) {
      relatedImages = [
        SELECT
          id,
          ContentDocumentId,
          ContentDocument.FileType,
          ContentDocument.CreatedDate,
          ContentDocument.LatestPublishedVersionID,
          LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :attachmentiIds
      ];
      List<Id> contentDocIds = new List<Id>();
      for (ContentDocumentLink image : relatedImages) {
        contentDocIds.add(image.ContentDocumentId);
      }
      List<ContentDistribution> ContentDistributionList = [
        SELECT Id, DistributionPublicUrl, ContentDocumentId, ContentDownloadUrl
        FROM ContentDistribution
        WHERE ContentDocumentId IN :contentDocIds
      ];
      for (ContentDocumentLink image : relatedImages) {
        for (ContentDistribution contentDoc : ContentDistributionList) {
          if (image.ContentDocumentId == contentDoc.ContentDocumentId) {
            List<String> imgLinks = new List<String>();
            imgLinks.add(contentDoc.ContentDownloadUrl);
            imgLinks.add(contentDoc.DistributionPublicUrl);
            relatedImagesMap.put(image.LinkedEntityId, imgLinks);
          }
        }
      }
    }

    Map<Id, List<String>> artworkImagesMap = new Map<Id, List<String>>();
    if (artworkiIds.size() > 0) {
      artworkImages = [
        SELECT
          id,
          ContentDocumentId,
          ContentDocument.FileType,
          ContentDocument.CreatedDate,
          ContentDocument.LatestPublishedVersionID,
          LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :artworkiIds
      ];
      List<Id> contentDocIds = new List<Id>();
      for (ContentDocumentLink image : artworkImages) {
        contentDocIds.add(image.ContentDocumentId);
      }
      List<ContentDistribution> ContentDistributionList = [
        SELECT Id, DistributionPublicUrl, ContentDocumentId, ContentDownloadUrl
        FROM ContentDistribution
        WHERE ContentDocumentId IN :contentDocIds
      ];
      for (ContentDocumentLink image : artworkImages) {
        for (ContentDistribution contentDoc : ContentDistributionList) {
          if (image.ContentDocumentId == contentDoc.ContentDocumentId) {
            List<String> imgLinks = new List<String>();
            imgLinks.add(contentDoc.ContentDownloadUrl);
            imgLinks.add(contentDoc.DistributionPublicUrl);
            artworkImagesMap.put(image.LinkedEntityId, imgLinks);
          }
        }
      }
    }

    for (OpportunityLineItem__c lineItems : lineItemDetails) {
      QuriedProductsForOpportunityEstimate lItems = new QuriedProductsForOpportunityEstimate();
      lItems.id = lineItems.id;
      lItems.name = lineItems.Name;
      lItems.description = lineItems.Description__c;
      lItems.lineItemTotalPricingAmount = 0;
      lItems.lineItemPricingAmount = 0;

      for (PricingLineItem__c pricingList : pricing) {
        if (pricingList.OpportunityLineItem__c == lineItems.id) {
          lItems.color = lItems.color + pricingList.Color__c;
          lItems.size = lItems.size + pricingList.Size__c;
          pricingList.Total__c =
            (pricingList.Retail_Price__c == null
              ? 0
              : pricingList.Retail_Price__c) *
            (pricingList.Estimated_Quantity__c == null
              ? 0
              : pricingList.Estimated_Quantity__c);
          lItems.lineItemPricings.add(pricingList);
          lItems.lineItemQuantity =
            lItems.lineItemQuantity +
            (pricingList.Estimated_Quantity__c == null
              ? 0
              : pricingList.Estimated_Quantity__c);
          lItems.lineItemTotalPricingAmount =
            lItems.lineItemTotalPricingAmount +
            (pricingList.Total__c == null ? 0 : pricingList.Total__c);
        }
      }
      for (ExtraChargesEstimate__c chargesList : extraCharges) {
        if (chargesList.OpportunityLineItem__c == lineItems.id) {
          if (chargesList.Net_Cost__c == null) {
            chargesList.Net_Cost__c = 0;
          }
          chargesList.Total__c =
            chargesList.Retail_Price__c * chargesList.Quantity__c;
          lItems.lineItemTotalPricingAmount =
            lItems.lineItemTotalPricingAmount + chargesList.Total__c;
          if (chargesList.Display__c == 'Display To Client') {
            lItems.lineItemExtraCharges.add(chargesList);
          }
        }
      }
      for (OpportunityLineItem_ArtWork__c artworkList : lineItemArtWork) {
        if (artworkList.OpportunityLineItem__c == lineItems.id) {
          ArtworkDetailsObject artDetails = new ArtworkDetailsObject();
          artworkList.Proof_Required__c = null;
          artworkList.Document_ID__c = null;
          for (ContentDocumentLink imagesList : artworkImages) {
            if (artworkList.id == imagesList.LinkedEntityId) {
              if (
                imagesList.ContentDocument.FileType == 'PNG' ||
                imagesList.ContentDocument.FileType == 'JPG' ||
                imagesList.ContentDocument.FileType == 'JPEG'
              ) {
                artDetails.artworkImageSupportExtension = true;
              } else {
                artDetails.artworkImageSupportExtension = false;
              }
              if (relatedImagesMap != null && relatedImagesMap.size() > 0) {
                artworkList.Document_ID__c = artworkImagesMap.get(
                  imagesList.LinkedEntityId
                )[0];
                artworkList.Proof_Required__c = artworkImagesMap.get(
                  imagesList.LinkedEntityId
                )[1];
                break;
              }
            }
          }
          artDetails.artworkList.add(artworkList);

          if (artworkList.Document_ID__c != null) {
            artDetails.artworkImageExist = true;
          } else {
            artDetails.artworkImageExist = false;
          }

          lItems.artworkDetails.add(artDetails);
        }
      }

      Integer imgCount = 0;
      List<String> activeImagelink = new List<String>();
      for (ContentDocumentLink imagesList : relatedImages) {
        for (OpportunityLineItemAttachment__c attachment : attachements) {
          if (
            lineItems.id == attachment.OpportunityLineItem__c &&
            imagesList.LinkedEntityId == attachment.id &&
            imgCount < 2
          ) {
            if (relatedImagesMap != null && relatedImagesMap.size() > 0) {
              activeImagelink.add(
                relatedImagesMap.get(imagesList.LinkedEntityId)[0]
              );
              Images img = new Images();
              img.imageDownloadLink = relatedImagesMap.get(
                imagesList.LinkedEntityId
              )[0];
              img.imagePreviewLink = relatedImagesMap.get(
                imagesList.LinkedEntityId
              )[1];
              lItems.filesDownloadURL.add(img);
              imgCount++;
              break;
            }
          }
        }
      }
      if (lItems.filesDownloadURL.size() > 0) {
        if (lineItems.ContentDocument_ID__c != null) {
          for (Id oppId : selectImageRelatedToOpp.keySet()) {
            lItems.activeImage = selectImageRelatedToOpp.get(lItems.Id);
            break;
          }
        } else {
          lItems.activeImage = lItems.filesDownloadURL[0].imageDownloadLink;
        }
        lItems.activeImagePreviewLink = lItems.filesDownloadURL[0]
          .imagePreviewLink;
        lItems.imageExits = true;
      } else {
        lItems.imageExits = false;
      }
      pageTotal = pageTotal + lItems.lineItemTotalPricingAmount;
      LineItemsList.add(lItems);
    }
    return lineItemsList;
  }
  public decimal getPageTotal() {
    return pageTotal;
  }
  public decimal getTax() {
    String val = getEstimateDetails().Default_Tax__c;
    if (val != null) {
      String[] str1 = val.split('[(]');
      String[] str2 = str1[1].split('%');
      return decimal.valueOf(str2[0]);
    } else {
      return 0.0;
    }
  }
  public decimal getTotalPlusTax() {
    return ((pageTotal * (getTax() / 100)) + pageTotal).setScale(2);
  }
  public String getOppLink() {
    oppLink =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/r/Opportunity/' +
      opp.id +
      '/view';
    return oppLink;
  }
  public Opportunity getOpportunity() {
    return opp;
  }
  public void approveRejectEstimate() {
    try {
      Estimate__c estimate = [
        SELECT
          id,
          Opportunity__c,
          Approved_By__c,
          Approved_Date__c,
          Notes__c,
          Client_Approval_Status__c
        FROM Estimate__c
        WHERE Opportunity__c = :opp.id
      ];
      estimate.Approved_By__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_by');
      estimate.Notes__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_notes');
      estimate.Client_Approval_Status__c = Apexpages.currentPage()
        .getParameters()
        .get('myStatus');
      estimate.Approved_Date__c = system.today();
      update estimate;

      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = estimate.Client_Approval_Status__c;
      activity.RelatedObjectId__c = estimate.id;
      activity.Opportunity__c = opp.id;
      activity.Approved_Date__c = estimate.Approved_Date__c;
      activity.Approved_By__c = estimate.Approved_By__c;
      insert activity;
      if (
        Apexpages.currentPage().getParameters().get('myStatus') ==
        'Change Requested'
      ) {
        sendUnapproveEmail();
      } else {
        sendApproveEmail();
      }
    } catch (Exception ex) {
      System.debug('exception --->>>>>' + ex.getStackTraceString());
    }
  }
  public Pagereference setApprove() {
    PageReference pageRef = Page.OpportunitySalesOrderApproveChange;
    pageRef.getParameters().put('approv', 'true');
    return PageRef;
  }

  public void sendApproveEmail() {
    Opportunity opportunity = [
      SELECT Id, AccountId, OwnerId, Owner.Email, Contact__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    //QBO_Details__c qboDetails = [SELECT Id, QB_Estimate_Number__c FROM QBO_Details__c WHERE Opportunity__c = :opp.Id LIMIT 1];
    Contact contact = [
      SELECT Id, Email
      FROM Contact
      WHERE id = :opportunity.Contact__c
    ];
    User user = [
      SELECT Id, Name, Email
      FROM User
      WHERE id = :opportunity.OwnerId
    ];
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    Estimate__c estimate = [
      SELECT Id, Name, Opportunity__c, Estimate_Number__c, Estimate_QB_Id__c
      FROM Estimate__c
      WHERE Opportunity__c = :opportunity.Id
    ];
    try {
      EmailTemplate et = [
        SELECT Id, Name, HtmlValue, Subject
        FROM EmailTemplate
        WHERE Name = 'Approved Email'
      ];
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      String htmlBody = et.HtmlValue;
      htmlBody = htmlBody.replace('{!Account.Name}', acc.Name);
      htmlBody = htmlBody.replace(
        '{!Estimate__c.Estimate_Number__c}',
        estimate.Name
      );
      htmlBody = htmlBody.replace('{!Opportunity.OwnerEmail}', user.Email);
      //if(qboDetails.QB_Estimate_Number__c != null){
      //    htmlBody = htmlBody.replace('{!Estimate__c.Estimate_QB_Id__c}', qboDetails.QB_Estimate_Number__c);
      //}
      email.setHtmlBody(htmlBody);
      email.setSubject(et.Subject);
      String[] toaddress = new List<String>{ contact.Email };
      String[] ccAddress = new List<String>{ opportunity.Owner.Email };
      email.setTemplateId(et.Id);
      email.setTargetObjectId(contact.Id);
      email.setSaveAsActivity(false);
      email.setToAddresses(toaddress);
      email.setCcAddresses(ccAddress);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    } catch (Exception e) {
      system.debug('Exception upon sending email: ' + e.getMessage());
    }
  }

  public Pagereference setChange() {
    PageReference pageRef = Page.OpportunitySalesOrderApproveChange;
    pageRef.getParameters().put('chang', 'true');
    return PageRef;
  }

  public void sendUnapproveEmail() {
    Opportunity opportunity = [
      SELECT Id, AccountId, OwnerId, Contact__c
      FROM Opportunity
      WHERE id = :opp.id
    ];
    //QBO_Details__c qboDetails = [SELECT Id, QB_Estimate_Number__c FROM QBO_Details__c WHERE Opportunity__c = :opp.Id LIMIT 1];
    //System.debug(qboDetails);
    Contact contact = [
      SELECT Id, Email
      FROM Contact
      WHERE id = :opportunity.Contact__c
      LIMIT 1
    ];
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE id = :opportunity.AccountId
    ];
    User user = [
      SELECT Id, Name, Email
      FROM User
      WHERE id = :opportunity.OwnerId
    ];
    Estimate__c estimate = [
      SELECT
        Id,
        Name,
        Notes__c,
        Opportunity__c,
        Approved_By__c,
        Client_Approval_Status__c,
        Estimate_QB_Id__c
      FROM Estimate__c
      WHERE Opportunity__c = :opportunity.Id
      LIMIT 1
    ];

    try {
      EmailTemplate et = [
        SELECT Id, Name, HtmlValue
        FROM EmailTemplate
        WHERE Name = 'Unapproved Email'
      ];
      Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
      email.setTemplateId(et.Id);
      email.setTargetObjectId(contact.Id);

      String htmlBody = et.HtmlValue;
      htmlBody = htmlBody.replace('{!Account.Name}', acc.Name);
      htmlBody = htmlBody.replace(
        '{!Estimate__c.Estimate_Number__c}',
        estimate.Name
      );
      //if(qboDetails.QB_Estimate_Number__c != null){
      //  htmlBody = htmlBody.replace('{!Estimate__c.Estimate_QB_Id__c}', qboDetails.QB_Estimate_Number__c);
      //}

      if (estimate.Notes__c != null) {
        htmlBody = htmlBody.replace(
          '{!Estimate__c.Notes__c}',
          estimate.Notes__c
        );
      }
      htmlBody = htmlBody.replace('{!Opportunity.OwnerEmail}', user.Email);
      email.setHtmlBody(htmlBody);

      String[] toaddress = new List<String>{ contact.Email };
      String[] ccAddress = new List<String>{ System.Label.ccAddress };
      email.setSaveAsActivity(false);
      email.setToAddresses(toaddress);
      email.setCcAddresses(ccAddress);
      Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email });
    } catch (Exception e) {
      system.debug('Exception upon sending email: ' + e.getMessage());
    }
  }
  public String getChangeStatus() {
    if (System.currentPagereference().getParameters().get('chang') == 'true') {
      return 'checked';
    } else
      return '';
  }
}
