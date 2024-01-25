public class GoogleDriveFolderCreator {
  @future(callout=true)
  public static void createFoldersForCustomerAccount() {
    String accessToken = GoogleAPIMethods.getLatestAccessToken();
    // Create Customer Account folder
    String customerAccountFolderId = GoogleAPIMethods.createFolder(
      '02.CUSTOMER ACCOUNTS',
      null,
      accessToken
    );
    GoogleAPIMethods.setAccessToDomainViewOnly(
      customerAccountFolderId,
      accessToken
    );
    createSubFolders(customerAccountFolderId, accessToken);
  }

  @future(callout=true)
  public static void createFoldersForVendorAccount() {
    String accessToken = GoogleAPIMethods.getLatestAccessToken();
    // Create Vendor Account folder
    String vendorAccountFolderId = GoogleAPIMethods.createFolder(
      '04.VENDOR ACCOUNTS',
      null,
      accessToken
    );
    GoogleAPIMethods.setAccessToDomainViewOnly(
      vendorAccountFolderId,
      accessToken
    );
    createSubFolders(vendorAccountFolderId, accessToken);
  }

  public static void createSubFolders(
    String parentFolderId,
    String accessToken
  ) {
    if (parentFolderId != null) {
      Set<String> folderNames = new Set<String>{
        '0-9',
        'A',
        'B',
        'C',
        'D',
        'E',
        'F',
        'G',
        'H',
        'I',
        'J',
        'K',
        'L',
        'M',
        'N',
        'O',
        'P',
        'Q',
        'R',
        'S',
        'T',
        'U',
        'V',
        'W',
        'X',
        'Y',
        'Z'
      };

      for (String folderName : folderNames) {
        GoogleAPIMethods.setAccessToDomainViewOnly(
          GoogleAPIMethods.createFolder(
            folderName,
            parentFolderId,
            accessToken
          ),
          accessToken
        );
      }
    }
  }
}
