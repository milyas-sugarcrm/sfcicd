public class TeamPhunSearchDetailsVFpageController {
  private final Opportunity opp;
  public String productID = '';
  List<Product2> queriedProducts = new List<Product2>();
  QueriedProducts p = new QueriedProducts();
  public TeamPhunSearchDetailsVFpageController() {
    productID = apexpages.currentpage().getparameters().get('ProductId');
    getSearchResults();
  }
  public void getSearchResults() {
    List<ContentDocumentLink> productRelatedImages;
    List<Color_Product__c> productColors;
    List<Size_Product__c> productSizes;
    if (Test.isRunningTest()) {
      queriedProducts = [
        SELECT
          id,
          Name,
          Product_Cost__c,
          Description,
          ProductCode,
          CommonSku_Id__c,
          Product_Supplier_Code__c,
          productBrand__c,
          Supplier__c,
          Net_Price__c
        FROM Product2
      ];
      productID = queriedProducts[0].id;
    } else {
      queriedProducts = [
        SELECT
          id,
          Name,
          Product_Cost__c,
          Description,
          ProductCode,
          CommonSku_Id__c,
          Product_Supplier_Code__c,
          productBrand__c,
          Supplier__c,
          Net_Price__c
        FROM Product2
        WHERE id = :+productID
      ];
    }
    if (queriedProducts != null && queriedProducts.size() > 0) {
      productRelatedImages = [
        SELECT ContentDocumentId, LinkedEntityId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :productID AND LinkedEntity.Type = 'Product2'
      ];
      productsizes = [
        SELECT Size__c, Product__c
        FROM Size_Product__c
        WHERE Product__c = :productID
      ];
      productcolors = [
        SELECT Color__c, Product__c
        FROM Color_Product__c
        WHERE Product__c = :productID
      ];
      List<Pricing_Product__c> productPrices = [
        SELECT Net_Cost__c, Product__c, Quantity__c, Retail_Price__c
        FROM Pricing_Product__c
        WHERE Product__c = :productID
      ];
      Map<Id, Id> mapContentLink_ContentVersion = new Map<Id, Id>();
      List<Id> lstContentDocumentIds = new List<Id>();
      for (ContentDocumentLink obj : productRelatedImages) {
        lstContentDocumentIds.add(obj.ContentDocumentId);
      }
      List<ContentVersion> productRelatedImageFiles = [
        SELECT id, ContentDocumentId
        FROM ContentVersion
        WHERE ContentDocumentId IN :lstContentDocumentIds AND FileType != 'PDF'
      ];
      for (ContentVersion contentVersion : productRelatedImageFiles) {
        mapContentLink_ContentVersion.put(
          contentVersion.ContentDocumentId,
          contentVersion.id
        );
      }

      for (Product2 product : queriedProducts) {
        //QueriedProducts p=new QueriedProducts();
        p.id = product.id == null ? null : product.id;
        p.name = product.Name == null ? null : product.Name;
        p.description = product.Description == null
          ? null
          : product.Description;
        p.ProductCode = product.ProductCode == null
          ? null
          : product.ProductCode;
        if (p.ProductCode == null) {
          p.productCodeExist = false;
        } else {
          p.productCodeExist = true;
        }
        p.productSupplierCode = product.Product_Supplier_Code__c == null
          ? null
          : product.Product_Supplier_Code__c;
        if (p.productSupplierCode == null) {
          p.productSupplierCodeExist = false;
        } else {
          p.productSupplierCodeExist = true;
        }
        p.productBrand = product.productBrand__c == null
          ? null
          : product.productBrand__c;
        p.supplier = product.Supplier__c == null ? null : product.Supplier__c;
        if (p.supplier == null) {
          p.productSupplierExist = false;
        } else {
          p.productSupplierExist = true;
        }
        p.commonSkuId = product.CommonSku_Id__c == null
          ? null
          : product.CommonSku_Id__c;
        if (p.commonSkuId == null) {
          p.commonSkuIdExist = false;
        } else {
          p.commonSkuIdExist = true;
        }
        p.netPrice = product.Net_Price__c == null ? null : product.Net_Price__c;
        p.productCost = product.Product_Cost__c == null
          ? null
          : product.Product_Cost__c;
        p.profit =
          (p.netPrice == null ? 0 : p.netPrice) -
          (p.productCost == null ? 0 : p.productCost);
        String productColorTemp = '';
        for (Color_Product__c prodColor : productColors) {
          if (prodColor.Product__c == p.id) {
            productColorTemp = productColorTemp + prodColor.Color__c + ',';
          }
        }
        p.productColor = productColorTemp.removeEnd(',');
        if (p.productColor == '') {
          p.productColorsExist = false;
        } else {
          p.productColorsExist = true;
        }
        String ProductSizeTemp = '';
        for (Size_Product__c prodSize : productSizes) {
          if (prodSize.Product__c == p.id) {
            ProductSizeTemp = ProductSizeTemp + +prodSize.Size__c + ',';
          }
        }
        p.productSize = ProductSizeTemp.removeEnd(',');
        if (p.productSize == '') {
          p.productSizesExist = false;
        } else {
          p.productSizesExist = true;
        }
        for (Pricing_Product__c prodPrice : productPrices) {
          if (prodPrice.Product__c == p.id) {
            ProductPrice newPrice = new ProductPrice();
            newPrice.cost = prodPrice.Net_Cost__c;
            newPrice.price = prodPrice.Retail_Price__c;
            newPrice.quantity = prodPrice.Quantity__c;
            if (newPrice.cost != null && newPrice.price != null)
              newPrice.profit = newPrice.price - newPrice.cost;
            p.prices.add(newPrice);
          }
        }
        if (p.prices.size() > 0) {
          p.pricingExist = true;
        } else {
          p.pricingExist = false;
        }
        for (ContentDocumentLink attatchment : productRelatedImages) {
          if (attatchment.LinkedEntityId == p.id) {
            if (
              mapContentLink_ContentVersion.containskey(
                attatchment.ContentDocumentid
              )
            ) {
              p.attatchmentIds.add(
                mapContentLink_ContentVersion.get(attatchment.ContentDocumentid)
              );
            }
          }
        }
        if (p.attatchmentIds.size() > 0) {
          p.imageUrl =
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/sfc/servlet.shepherd/version/download/' +
            p.attatchmentIds.get(0);
          p.imageExits = true;
        } else {
          p.imageExits = false;
        }
      }
    }
  }
  public QueriedProducts getSearch() {
    return p;
  }
}
