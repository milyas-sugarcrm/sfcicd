public class ContentVersionTriggerService {
  public static void createPublicLinks(List<ContentVersion> contentVersions) {
    ContentDistribution[] distributionsToInsert = new List<ContentDistribution>();
    for (ContentVersion objContentVersion : contentVersions) {
      //if image uploaded then only create public link
      if (
        objContentVersion.FileType.toLowerCase() == 'jpg' ||
        objContentVersion.FileType.toLowerCase() == 'jpeg' ||
        objContentVersion.FileType.toLowerCase() == 'png'
      ) {
        system.debug(
          'objContentVersion.FileExtension.toLowerCase():' +
          objContentVersion.FileType
        );
        distributionsToInsert.add(
          createContentDistribution(objContentVersion.Id)
        );
      }
    }
    if (!distributionsToInsert.isEmpty()) {
      insert distributionsToInsert;
    }
  }

  public static ContentDistribution createContentDistribution(
    Id contentVersionId
  ) {
    ContentDistribution newDist = new ContentDistribution();
    newDist.ContentVersionId = contentVersionId;
    newDist.Name = 'External Link';
    newDist.PreferencesNotifyOnVisit = false;
    newDist.PreferencesAllowViewInBrowser = true;
    newDist.PreferencesAllowOriginalDownload = true;
    return newDist;
  }
}
