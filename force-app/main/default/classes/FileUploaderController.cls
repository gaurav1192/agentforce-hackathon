/**
* @File Name : FileUploaderController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : April 30, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | April 30, 2025 |   | Initial Version
**/

public class FileUploaderController {
	@AuraEnabled
	public static void LightningStudio(){
		System.debug('Lightning Studio');
	}

	@AuraEnabled
  	public static String uploadFile(String base64, String filename, String recordId) {
        ContentVersion cv = createContentVersion(base64, filename);
        // ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
        // if (cv == null || cdl == null) { return null; }
        // return cdl.Id;
		return 'success';
  	}

	private static ContentVersion createContentVersion(String base64, String filename) {
		ContentVersion cv = new ContentVersion();
		cv.VersionData = EncodingUtil.base64Decode(base64);
		cv.Title = filename;
		cv.PathOnClient = filename;
		try {
			insert cv;
			return cv;
		} catch(DMLException e) {
			System.debug(e);
			return null;
		}
  	}

	// private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
    //     if (contentVersionId == null || recordId == null) { return null; }
	// 	ContentDocumentLink cdl = new ContentDocumentLink();
	// 	cdl.ContentDocumentId = [
	// 		SELECT ContentDocumentId 
	// 		FROM ContentVersion 
	// 		WHERE Id =: contentVersionId
	// 		].ContentDocumentId;
	// 	cdl.LinkedEntityId = recordId;
	// 	cdl.ShareType = 'V';
	// 	try {
	// 		insert cdl;
	// 		return cdl;
	// 	} catch(DMLException e) {
	// 		System.debug(e);
	// 		return null;
	// 	}
	// }
}