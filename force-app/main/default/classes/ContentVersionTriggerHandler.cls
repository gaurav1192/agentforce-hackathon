/**
* @File Name : ContentVersionTriggerHandler.cls
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

public without sharing class ContentVersionTriggerHandler {
	
	public static void afterInsert(List<ContentVersion> newList) {

		List<Id> appIds = new List<Id>();
		for(ContentVersion cv : newList) {
			if(cv.Guest_Record_fileupload__c != null) {
				appIds.add(cv.Guest_Record_fileupload__c);
			}
		}

		if(!appIds.isEmpty()) {
			invokeDocumentAIApi(appIds);
		}
	}

	@future(callout=true)
	public static void invokeDocumentAIApi(List<Id> appIds) {
		Id appId = appIds[0];
		ContentVersion cv = [SELECT Id FROM ContentVersion WHERE Guest_Record_fileupload__c =: appId ORDER BY CreatedDate DESC LIMIT 1];
		String output = DocumentAIServiceJWT.callDocumentAI(cv.Id); 
		System.debug('extracted text : ' + output);
		update new Job_Application__c(Id=appId, Extracted_Data__c=output);
		
	}
}