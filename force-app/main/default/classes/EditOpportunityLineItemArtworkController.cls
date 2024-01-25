public class EditOpportunityLineItemArtworkController {
  @AuraEnabled
  public static List<String> getValuesForSizeTextBox(String recId) {
    try {
      List<String> sizes = new List<String>();
      List<SizeLineItem__c> sizesList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      for (SizeLineItem__c s : sizesList) {
        if (s.isSelected__c) {
          sizes.add(s.Size__c);
        }
      }
      return sizes;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForColorTextBox--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }

  @AuraEnabled
  public static String getOpportunityStage1(String recid) {
    try {
      Opportunity opp = [
        SELECT Id, stageName
        FROM Opportunity
        WHERE Id = :recid
      ];
      return opp.stageName;
    } catch (Exception ex) {
      System.debug('Error in getting stage ---->>>>>' + ex.getMessage());
      return null;
    }
  }

  @AuraEnabled
  public static List<String> getValuesForColorTextBox(String recId) {
    try {
      List<String> colors = new List<String>();
      List<ColorLineItem__c> colorsList = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      for (ColorLineItem__c col : colorsList) {
        if (col.isSelected__c) {
          colors.add(col.Color__c);
        }
      }
      return colors;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForColorTextBox--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static boolean UpdateColorsList(
    String recId,
    List<String> selectedColors
  ) {
    try {
      List<ColorLineItem__c> colorsListToUpdate = new List<ColorLineItem__c>();
      List<ColorLineItem__c> colorsListToRemoveUpdate = new List<ColorLineItem__c>();
      List<ColorLineItem__c> colorsList = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      colorsListToRemoveUpdate = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND Color__c NOT IN :selectedColors
      ];

      for (integer i = 0; i < selectedColors.size(); i++) {
        for (ColorLineItem__c color : colorsList) {
          if (
            (color.Color__c == selectedColors.get(i)) &&
            (color.isSelected__c != true)
          ) {
            color.isSelected__c = true;
            colorsListToUpdate.add(color);
          }
        }
      }
      update colorsListToUpdate;
      for (ColorLineItem__c color : colorsListToRemoveUpdate) {
        color.isSelected__c = false;
      }
      update colorsListToRemoveUpdate;

      List<ColorLineItem__c> colorsListToDelete = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND isFromProduct__c = FALSE
          AND isSelected__c = FALSE
      ];

      delete colorsListToDelete;

      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN UpdateColorsList--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static boolean UpdateSizesList(
    String recId,
    List<String> selectedSizes
  ) {
    try {
      List<SizeLineItem__c> sizesListToUpdate = new List<SizeLineItem__c>();
      List<SizeLineItem__c> sizesListToRemoveUpdate = new List<SizeLineItem__c>();
      List<SizeLineItem__c> sizesList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      sizesListToRemoveUpdate = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId AND Size__c NOT IN :selectedSizes
      ];

      for (integer i = 0; i < selectedSizes.size(); i++) {
        for (SizeLineItem__c size : sizesList) {
          if (
            (size.Size__c == selectedSizes.get(i)) &&
            (size.isSelected__c != true)
          ) {
            size.isSelected__c = true;
            sizesListToUpdate.add(size);
          }
        }
      }
      update sizesListToUpdate;
      for (SizeLineItem__c size : sizesListToRemoveUpdate) {
        size.isSelected__c = false;
      }
      update sizesListToRemoveUpdate;

      List<SizeLineItem__c> sizesListToDelete = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE
          OpportunityLineItem__c = :recId
          AND isFromProduct__c = FALSE
          AND isSelected__c = FALSE
      ];

      delete sizesListToDelete;

      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN UpdateSizesList--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static boolean addColorInDb(String recId, String color) {
    try {
      ColorLineItem__c newColor = new ColorLineItem__c();
      newColor.Color__c = color;
      newColor.isFromProduct__c = false;
      newColor.isSelected__c = true;
      newColor.OpportunityLineItem__c = recId;
      insert newColor;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addColorInDb--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static boolean addSizeInDb(String recId, String size) {
    try {
      SizeLineItem__c newSize = new SizeLineItem__c();
      newSize.Size__c = size;
      newSize.isFromProduct__c = false;
      newSize.isSelected__c = true;
      newSize.OpportunityLineItem__c = recId;
      insert newSize;
      return true;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN addSizeInDb--->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static List<OppLineItemSizes> getValuesForSizePiklist(String recId) {
    try {
      List<SizeLineItem__c> sizesList = [
        SELECT
          Id,
          OpportunityLineItem__c,
          Size__c,
          isSelected__c,
          isFromProduct__c
        FROM SizeLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<OppLineItemSizes> listToReturn = new List<OppLineItemSizes>();

      for (SizeLineItem__c size : sizesList) {
        OppLineItemSizes s = new OppLineItemSizes();
        s.id = size.Id;
        s.size = size.Size__c;
        if (size.isSelected__c) {
          s.isSelected = true;
        } else {
          s.isSelected = false;
        }
        listToReturn.add(s);
      }
      return listToReturn;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForSizePiklist--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static List<OppLineItemColors> getValuesForColorPiklist(String recId) {
    try {
      List<ColorLineItem__c> colorsList = [
        SELECT
          Id,
          Color__c,
          isFromProduct__c,
          isSelected__c,
          OpportunityLineItem__c
        FROM ColorLineItem__c
        WHERE OpportunityLineItem__c = :recId
      ];
      List<OppLineItemColors> listToReturn = new List<OppLineItemColors>();

      for (ColorLineItem__c color : colorsList) {
        OppLineItemColors col = new OppLineItemColors();
        col.id = color.Id;
        col.color = color.Color__c;
        if (color.isSelected__c) {
          col.isSelected = true;
        } else {
          col.isSelected = false;
        }
        listToReturn.add(col);
      }
      return listToReturn;
    } catch (Exception ex) {
      System.debug(
        'EXCEPTION IN getValuesForColorPiklist--->>>>>>>' + ex.getMessage()
      );
      return null;
    }
  }
  @AuraEnabled
  public static OpportunityLineItem_ArtWork__c getArtworkToEdit(Id recId) {
    try {
      OpportunityLineItem_ArtWork__c artwork = [
        SELECT
          Id,
          OpportunityLineItem__c,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Title__c,
          Counter__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];
      return artwork;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN GETARTWORKTOEDIT--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static boolean deleteArtworkInDb(String recId, String oppLineItem) {
    try {
      OpportunityLineItem_ArtWork__c artwork = [
        SELECT Id, Name
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];
      List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges = [
        SELECT Id, OpportunityLineItem_ArtWork__c
        FROM OpportunityLineItem_Add_Fixed_Charge__c
        WHERE
          OpportunityLineItem_ArtWork__c = :recId
          AND Is_Associated_With_Artwork_c__c = TRUE
      ];
      List<Line_Item_Pricing_RunCharge__c> runCharges = [
        SELECT Id, OpportunityLineItem_ArtWork__c
        FROM Line_Item_Pricing_RunCharge__c
        WHERE
          OpportunityLineItem_ArtWork__c = :recId
          AND Is_Associated_With_Artwork__c = TRUE
      ];
      delete fixedCharges;
      delete runCharges;
      delete artwork;

      List<OpportunityLineItem_ArtWork__c> relatedArtwork = [
        SELECT
          Id,
          Name,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :oppLineItem
        ORDER BY CreatedDate ASC
      ];
      List<OpportunityLineItem_ArtWork__c> updatedRelatedArtwork = new List<OpportunityLineItem_ArtWork__c>();
      integer counter = 1;
      for (OpportunityLineItem_ArtWork__c art : relatedArtwork) {
        art.Counter__c = counter++;
        updatedRelatedArtwork.add(art);
      }
      update updatedRelatedArtwork;
      return true;
    } catch (Exception ex) {
      System.debug('Error Deleting Artwork->>>>>>>' + ex.getMessage());
      return false;
    }
  }
  @AuraEnabled
  public static List<artworkResults> getArtworks(String recId) {
    try {
      integer counter = 1;
      List<id> artworkIds = new List<id>();
      List<id> lstContentDocumentIds = new List<id>();
      List<OpportunityLineItem_ArtWork__c> updatedRelatedArtwork = new List<OpportunityLineItem_ArtWork__c>();
      Map<Id, Id> mapContentLink_ContentVersion = new Map<id, id>();
      Map<Id, String> artworkFileTypes = new Map<Id, String>();
      List<artworkResults> resultsToReturn = new List<artworkResults>();

      List<OpportunityLineItem_ArtWork__c> relatedArtwork = [
        SELECT
          Id,
          Name,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Title__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Document_ID__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE OpportunityLineItem__c = :recId
        ORDER BY CreatedDate ASC
      ];
      for (OpportunityLineItem_ArtWork__c art : relatedArtwork) {
        artworkIds.add(art.Id);
      }

      List<ContentDocumentLink> documentIds = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId IN :artworkIds
      ];

      for (ContentDocumentLink obj : documentIds) {
        lstContentDocumentIds.add(obj.ContentDocumentId);
      }

      List<ContentVersion> imageFiles = [
        SELECT id, FileType, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
      ];
      for (ContentVersion contentVersion : imageFiles) {
        mapContentLink_ContentVersion.put(
          contentVersion.ContentDocumentId,
          contentVersion.id
        );
        artworkFileTypes.put(
          contentVersion.ContentDocumentId,
          contentVersion.FileType
        );
      }

      for (OpportunityLineItem_ArtWork__c artwork : relatedArtwork) {
        artworkResults resultItem = new artworkResults();

        resultItem.counter = counter;
        artwork.Counter__c = counter++;
        resultItem.id = artwork.Id;
        resultItem.imprintType = artwork.Imprint_Type__c;
        resultItem.logoColor = artwork.Logo_Color__c;
        resultItem.title = artwork.Title__c;
        resultItem.logoName = artwork.logo_Name__c;
        resultItem.logoSize = artwork.Logo_Size__c;
        resultItem.proofRequired = artwork.Proof_Required__c;
        resultItem.repeatLogo = artwork.Repeat_Logo__c;
        resultItem.supplierNotes = artwork.Supplier_Notes__c;
        resultItem.documentId = mapContentLink_ContentVersion.get(
          artwork.Document_ID__c
        );
        if (
          artworkFileTypes.get(artwork.Document_ID__c) == 'JPG' ||
          artworkFileTypes.get(artwork.Document_ID__c) == 'JPEG' ||
          artworkFileTypes.get(artwork.Document_ID__c) == 'PNG'
        ) {
          resultItem.artworkImageSupportExtension = true;
        } else {
          resultItem.artworkImageSupportExtension = false;
        }
        updatedRelatedArtwork.add(artwork);
        resultsToReturn.add(resultItem);
      }

      update updatedRelatedArtwork;
      updatedFixedChargesCounter(recId);
      return resultsToReturn;
    } catch (Exception ex) {
      System.debug('EXCEPTION IN GETARTWORK--->>>>>>>' + ex.getMessage());
      return null;
    }
  }
  @AuraEnabled
  public static void updatedFixedChargesCounter(String recId) {
    List<OpportunityLineItem_Add_Fixed_Charge__c> fixedCharges = [
      SELECT
        Id,
        Title__c,
        Is_Associated_With_Artwork_c__c,
        OpportunityLineItem_ArtWork__c,
        Cost__c,
        Counter__c,
        Margin__c,
        Retail_Price__c,
        CreatedDate
      FROM OpportunityLineItem_Add_Fixed_Charge__c
      WHERE
        OpportunityLineItem__c = :recId
        AND Is_Associated_With_Artwork_c__c = TRUE
      ORDER BY CreatedDate ASC
    ];
    List<Line_Item_Pricing_RunCharge__c> runCharges = [
      SELECT
        Id,
        Title__c,
        Is_Associated_With_Artwork__c,
        OpportunityLineItem_ArtWork__c,
        Value1__c,
        Value2__c,
        Value3__c,
        Value4__c,
        Value5__c,
        CreatedDate
      FROM Line_Item_Pricing_RunCharge__c
      WHERE
        OpportunityLineItem__c = :recId
        AND Is_Associated_With_Artwork__c = TRUE
      ORDER BY CreatedDate ASC
    ];
    List<OpportunityLineItem_ArtWork__c> artwork = [
      SELECT Id, OpportunityLineItem__c, Counter__c
      FROM OpportunityLineItem_ArtWork__c
      WHERE OpportunityLineItem__c = :recId
    ];
    Map<Id, decimal> mapArtworkCounter = new Map<id, decimal>();

    for (OpportunityLineItem_ArtWork__c art : artwork) {
      mapArtworkCounter.put(art.Id, art.Counter__c);
    }
    List<OpportunityLineItem_Add_Fixed_Charge__c> updatedFixedCharges = new List<OpportunityLineItem_Add_Fixed_Charge__c>();
    for (OpportunityLineItem_Add_Fixed_Charge__c charges : fixedCharges) {
      charges.Counter__c = mapArtworkCounter.get(
        charges.OpportunityLineItem_ArtWork__c
      );
      updatedFixedCharges.add(charges);
    }
    List<Line_Item_Pricing_RunCharge__c> updatedRunCharges = new List<Line_Item_Pricing_RunCharge__c>();
    for (Line_Item_Pricing_RunCharge__c charges : runCharges) {
      charges.Counter__c = mapArtworkCounter.get(
        charges.OpportunityLineItem_ArtWork__c
      );
      updatedRunCharges.add(charges);
    }
    update updatedFixedCharges;
    update updatedRunCharges;
  }
  @AuraEnabled
  public static boolean editArtworkInDatabases(
    String recId,
    String imprintType,
    String proofRequired,
    String logoName,
    String logoSize,
    String logoColor,
    String repeatLogo,
    String supplierNotes,
    String documentId,
    String title,
    String OpportunityLineItemId
  ) {
    try {
      integer index = 0;
      OpportunityLineItem_ArtWork__c artwork = [
        SELECT
          Id,
          OpportunityLineItem__c,
          ArtWorkNumber__c,
          Imprint_Type__c,
          Proof_Required__c,
          logo_Name__c,
          Logo_Size__c,
          Logo_Color__c,
          Repeat_Logo__c,
          Supplier_Notes__c,
          Title__c,
          Counter__c
        FROM OpportunityLineItem_ArtWork__c
        WHERE Id = :recId
      ];

      artwork.Imprint_Type__c = imprintType;
      artwork.Logo_Color__c = logoColor;
      artwork.logo_Name__c = logoName;
      artwork.Logo_Size__c = logoSize;
      artwork.Proof_Required__c = proofRequired;
      artwork.Repeat_Logo__c = repeatLogo;
      artwork.Supplier_Notes__c = supplierNotes;
      artwork.Title__c = title;

      //document id handling

      List<ContentDocumentLink> documentIds = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recId
        ORDER BY ContentDocument.CreatedDate DESC
      ];

      if (documentIds.size() != 0) {
        ContentDocumentLink updatedDocument = documentIds.get(index).clone();
        updatedDocument.LinkedEntityId = artwork.Id;
        updatedDocument.ShareType = 'V';
        delete documentIds;
        insert updatedDocument;
        artwork.Document_ID__c = updatedDocument.ContentDocumentId;
      }
      update artwork;
      return true;
    } catch (Exception ex) {
      System.debug('ERROR IN EDITING ARTWORK' + ex.getMessage());
      return false;
    }
  }

  @AuraEnabled
  public static boolean saveArtworkInDatabases(
    String recId,
    String imprintType,
    String proofRequired,
    String logoName,
    String logoSize,
    String logoColor,
    String repeatLogo,
    String supplierNotes,
    String documentId,
    String title
  ) {
    try {
      integer index = 0;
      OpportunityLineItem_ArtWork__c artwork = new OpportunityLineItem_ArtWork__c();
      artwork.OpportunityLineItem__c = recId;
      artwork.Imprint_Type__c = imprintType;
      artwork.Logo_Color__c = logoColor;
      artwork.logo_Name__c = logoName;
      artwork.Logo_Size__c = logoSize;
      artwork.Proof_Required__c = proofRequired;
      artwork.Repeat_Logo__c = repeatLogo;
      artwork.Supplier_Notes__c = supplierNotes;
      artwork.Title__c = title;
      insert artwork;

      List<ContentDocumentLink> documentIds = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :recId
        ORDER BY ContentDocument.CreatedDate DESC
      ];

      if (documentIds.size() != 0) {
        ContentDocumentLink updatedDocument = documentIds.get(index).clone();
        updatedDocument.LinkedEntityId = artwork.Id;
        updatedDocument.ShareType = 'V';
        insert updatedDocument;
        delete documentIds;
        artwork.Document_ID__c = updatedDocument.ContentDocumentId;
        update artwork;
      }

      Line_Item_Pricing_RunCharge__c runChargesAsscociatedToArtWork = new Line_Item_Pricing_RunCharge__c();
      runChargesAsscociatedToArtWork.Is_Associated_With_Artwork__c = true;
      runChargesAsscociatedToArtWork.Title__c = 'Imprint Cost';
      runChargesAsscociatedToArtWork.Value1__c = 0.00;
      runChargesAsscociatedToArtWork.Value2__c = 0.00;
      runChargesAsscociatedToArtWork.Value3__c = 0.00;
      runChargesAsscociatedToArtWork.Value4__c = 0.00;
      runChargesAsscociatedToArtWork.Value5__c = 0.00;
      runChargesAsscociatedToArtWork.OpportunityLineItem_ArtWork__c = artwork.Id;
      runChargesAsscociatedToArtWork.OpportunityLineItem__c = recId;

      insert runChargesAsscociatedToArtWork;

      OpportunityLineItem_Add_Fixed_Charge__c fixedChargesAssociatedWithArtwork = new OpportunityLineItem_Add_Fixed_Charge__c();
      fixedChargesAssociatedWithArtwork.Title__c = 'Setup Cost';
      fixedChargesAssociatedWithArtwork.Cost__c = 0.00;
      fixedChargesAssociatedWithArtwork.Margin__c = 0.00;
      fixedChargesAssociatedWithArtwork.Retail_Price__c = 0.00;
      fixedChargesAssociatedWithArtwork.Is_Associated_With_Artwork_c__c = true;
      fixedChargesAssociatedWithArtwork.OpportunityLineItem_ArtWork__c = artwork.Id;
      fixedChargesAssociatedWithArtwork.OpportunityLineItem__c = recId;
      insert fixedChargesAssociatedWithArtwork;

      getArtworks(recId);

      return true;
    } catch (Exception ex) {
      System.debug('Error in adding artwork +' + ex.getMessage());
      return false;
    }
  }
}
