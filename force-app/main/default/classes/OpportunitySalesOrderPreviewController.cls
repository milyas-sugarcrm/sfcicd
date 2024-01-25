public class OpportunitySalesOrderPreviewController {
  private final Opportunity opp;
  decimal pageTotal = 0;

  public OpportunitySalesOrderPreviewController() {
    String oppId = ApexPages.currentPage().getParameters().get('id');
    this.opp = [
      SELECT Id, Name, Owner.Name, Owner.Email
      FROM Opportunity
      WHERE id = :oppId
    ];
  }
  public OpportunitySalesOrderPreviewController(
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
    Map<String, String> address = new Map<String, String>();
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
      address.put('billingCountry', account.BillingCountry);
    } else {
      address.put('billingCountry', '');
    }
    return address;
  }
  public Map<String, String> getShippingAddress() {
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
    Map<String, String> address = new Map<String, String>();
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
    return address;
  }
  public Order getSalesOrderDetails() {
    try {
      Order order = [
        SELECT
          Id,
          OrderNumber,
          Invoice_Ship_Via__c,
          Invoice_Number__c,
          Invoice_Tax__c,
          Invoice_Ship_Date__c,
          Invoice_Date__c,
          Invoice_Due_Date__c,
          Approved_Date__c,
          Amount_Received__c,
          Approved_By__c,
          Sale_Order_Status__c,
          EffectiveDate,
          Invoice_Terms__c,
          PoNumber
        FROM Order
        WHERE OpportunityId = :opp.id
      ];
      System.debug('oder details: ' + order);
      if (order.Approved_Date__c != null) {
        order.Invoice_Ship_Via__c = order.Approved_Date__c.format('dd-MM-yyyy');
      }

      return order;
    } catch (Exception Ex) {
      System.debug(
        'Exception in OrderDetails  ' +
          Ex.getMessage() +
          '>>>> ' +
          Ex.getStackTraceString()
      );
      return null;
    }
  }
  public List<QuriedProductsForOpportunityEstimate> getLineItemsList() {
    try {
      List<QuriedProductsForOpportunityEstimate> LineItemsList = new List<QuriedProductsForOpportunityEstimate>();

      Order order = [
        SELECT Id, Invoice_Number__c
        FROM Order
        WHERE OpportunityId = :opp.id
      ];
      List<OpportunityLineItem__c> lineItemDetailsUnsorted = [
        SELECT
          id,
          Name,
          Estimate__r.id,
          Quantity_Estimate__c,
          Description__c,
          Work_Order__c,
          Product__r.Name,
          CreatedDate,
          Sorting_Date__c
        FROM OpportunityLineItem__c
        WHERE Work_Order__c = :order.id
        ORDER BY Sorting_Date__c ASC
      ];

      //Sorting Logic
      List<OpportunityLineItem__c> lineItemDetails = ProductsSorting.sortProducts(
        lineItemDetailsUnsorted
      );
      List<String> ids = new List<String>();
      for (OpportunityLineItem__c lineItems : lineItemDetails) {
        ids.add(lineItems.id);
      }

      List<ColorLineItem__c> colors;
      List<SizeLineItem__c> sizes;
      List<PricingLineItem__c> pricing;
      List<OpportunityLineItem_ArtWork__c> lineItemArtWork;
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges;
      List<Line_Item_Pricing_RunCharge__c> runCharges;
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
      List<ExtraChargesEstimate__c> extraCharges = [
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
          SELECT
            Id,
            DistributionPublicUrl,
            ContentDocumentId,
            ContentDownloadUrl
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
          SELECT
            Id,
            DistributionPublicUrl,
            ContentDocumentId,
            ContentDownloadUrl
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
        for (ColorLineItem__c colorsList : colors) {
          if (
            colorsList.OpportunityLineItem__c == lineItems.id &&
            colorsList.isSelected__c == true
          ) {
            lItems.lineItemColors = colorsList.Color__c;
            break;
          }
        }
        for (SizeLineItem__c sizesList : sizes) {
          if (
            sizesList.OpportunityLineItem__c == lineItems.id &&
            sizesList.isSelected__c == true
          ) {
            lItems.lineItemSizes = sizesList.Size__c;
            break;
          }
        }

        Double previousPriceQauntity = 0;
        Double previousNetCost = 0;
        Integer pricePosition = 1;
        Double previousMargin = 0;
        Double priceMargin = 0;
        for (PricingLineItem__c pricingList : pricing) {
          if (pricingList.OpportunityLineItem__c == lineItems.id) {
            pricingList.Total__c =
              (pricingList.Retail_Price__c == null
                ? 0
                : pricingList.Retail_Price__c) *
              (pricingList.Estimated_Quantity__c == null
                ? 0
                : pricingList.Estimated_Quantity__c);
            lItems.lineItemPricings.add(pricingList);
            lItems.lineItemQuantity =
              lItems.lineItemQuantity + pricingList.Estimated_Quantity__c;
            lItems.lineItemTotalPricingAmount =
              lItems.lineItemTotalPricingAmount + pricingList.Total__c;
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
                if (artworkImagesMap != null) {
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
            lItems.lineItemArtWork.add(artworkList);
          }
        }

        for (ExtraChargesEstimate__c chargesList : extraCharges) {
          if (chargesList.OpportunityLineItem__c == lineItems.id) {
            if (chargesList.Retail_Price__c == null) {
              chargesList.Retail_Price__c = 0;
            }
            chargesList.Total__c =
              chargesList.Retail_Price__c * chargesList.Quantity__c;
            lItems.lineItemTotalPricingAmount =
              lItems.lineItemTotalPricingAmount + chargesList.Total__c;
            if (
              chargesList.Is_Associated_With_Artwork__c == false &&
              chargesList.Display__c == 'Display To Client' &&
              chargesList.Charge_Type__c !=
              'InternationalCost_InboundFreight' &&
              chargesList.Charge_Type__c != 'InternationalCost_Brokerage' &&
              chargesList.Charge_Type__c != 'InternationalCost_Duty'
            ) {
              lItems.lineItemExtraCharges.add(chargesList);
            }
          }
        }
        Integer imgCount = 0;
        for (ContentDocumentLink imagesList : relatedImages) {
          for (OpportunityLineItemAttachment__c attachment : attachements) {
            if (
              lineItems.id == attachment.OpportunityLineItem__c &&
              imagesList.LinkedEntityId == attachment.id &&
              imgCount < 2
            ) {
              if (relatedImagesMap != null && relatedImagesMap.size() > 0) {
                lItems.activeImage = relatedImagesMap.get(
                  imagesList.LinkedEntityId
                )[0];
                lItems.activeImagePreviewLink = relatedImagesMap.get(
                  imagesList.LinkedEntityId
                )[1];
                break;
              }
            }
          }
        }
        if (lItems.activeImage == null) {
          lItems.imageExits = false;
        } else {
          lItems.imageExits = true;
        }
        pageTotal = pageTotal + lItems.lineItemTotalPricingAmount;
        LineItemsList.add(lItems);
      }
      return lineItemsList;
    } catch (Exception Ex) {
      System.debug(
        'Exception in getting lineitems  ' +
          Ex.getMessage() +
          '>>>> ' +
          Ex.getStackTraceString()
      );
      return null;
    }
  }
  public decimal getPageTotal() {
    return pageTotal;
  }

  public decimal getTotalDue() {
    decimal total = getTotalPlusTax() == null ? 0 : getTotalPlusTax();
    decimal amount_recived = getSalesOrderDetails().Amount_Received__c == null
      ? 0
      : getSalesOrderDetails().Amount_Received__c;

    decimal totalDue = total - amount_recived;
    return totalDue;
  }

  public decimal getTotalPlusTax() {
    decimal tax = ((getSalesOrderDetails().Invoice_Tax__c) / 100) * pageTotal;
    return (pageTotal + tax).setScale(2);
  }
  public void approveRejectOrder() {
    try {
      Order order = [
        SELECT
          id,
          Approved_By__c,
          Approved_Date__c,
          Work_Order_Notes__c,
          Sale_Order_Status__c,
          Invoice_Number__c
        FROM Order
        WHERE OpportunityId = :opp.id
      ];

      order.Approved_By__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_by');
      order.Work_Order_Notes__c = Apexpages.currentPage()
        .getParameters()
        .get('approved_notes');
      order.Sale_Order_Status__c = Apexpages.currentPage()
        .getParameters()
        .get('myStatus');
      order.Approved_Date__c = system.today();
      update order;

      Opportunity_ACTIVITIES__c activity = new Opportunity_ACTIVITIES__c();
      activity.Type__c = order.Sale_Order_Status__c;
      activity.RelatedObjectId__c = order.Invoice_Number__c;
      activity.Opportunity__c = opp.id;
      activity.Approved_Date__c = order.Approved_Date__c;
      activity.Approved_By__c = order.Approved_By__c;
      insert activity;
    } catch (Exception ex) {
      System.debug('exception --->>>>>' + ex.getStackTraceString());
    }
  }
  public String getOppLink() {
    return URL.getSalesforceBaseUrl().toExternalForm() +
      '/lightning/r/Opportunity/' +
      opp.id +
      '/view';
  }

  public String getChangeStatus() {
    if (System.currentPagereference().getParameters().get('chang') == 'true') {
      return 'checked';
    } else
      return '';
  }

  public Pagereference setApprove() {
    PageReference pageRef = Page.OpportunitySalesOrderApproveChange;
    pageRef.getParameters().put('approv', 'true');
    return PageRef;
  }
  public Pagereference setChange() {
    PageReference pageRef = Page.OpportunitySalesOrderApproveChange;
    pageRef.getParameters().put('chang', 'true');
    return PageRef;
  }
  public Opportunity getOpportunity() {
    return opp;
  }
}
