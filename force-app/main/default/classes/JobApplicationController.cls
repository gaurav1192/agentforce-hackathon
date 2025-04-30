public without sharing class JobApplicationController {
	@AuraEnabled
	public static ApplicationWrapper submitDraftApplication(ApplicationWrapper application) {
		Contact con = new Contact();
		con.FirstName = application.firstName;
		con.LastName = application.lastName;
		con.Email = application.email;
		con.Phone = application.phone;
		insert con;
		
		Job_Application__c app = new Job_Application__c();
		app.Candidate__c = con.Id;
		app.Job_Posting__c = application.jobPostingId;
		app.Status__c = 'Draft';
		insert app;

		application.applicationId = app.Id;
		application.docId = null;
		return application;
	}

	@AuraEnabled
	public static Boolean submitApplication(Id applicationId) {
		if(applicationId != null) {
			update new Job_Application__c(Id=applicationId, Status__c='Submitted');
			invokeDocumentAIApi(new List<Id> {applicationId});
			return true;
		}
		return false;
	}

	@future(callout=true)
	public static void invokeDocumentAIApi(List<Id> appIds) {
		Id appId = appIds[0];
		ContentDocumentLink cdl = [SELECT LinkedEntityId, ContentDocument.LatestPublishedVersionId 
									FROM ContentDocumentLink 
									WHERE LinkedEntityId =: appId  
									AND LinkedEntity.Type = 'Job_Application__c'
									LIMIT 1];
		System.debug('appId : ' + appId);
		String output = DocumentAIServiceJWT.callDocumentAI(cdl.ContentDocument.LatestPublishedVersionId); 
		System.debug('extracted text : ' + output);
		update new Job_Application__c(Id=appId, Extracted_Data__c=output);
	}

	public class ApplicationWrapper {
		@AuraEnabled
		public String applicationId {get; set;}
		@AuraEnabled
		public String jobPostingId {get; set;}
		@AuraEnabled
		public String firstName {get; set;}
		@AuraEnabled
		public String lastName {get; set;}
		@AuraEnabled
		public String email {get; set;}
		@AuraEnabled
		public String phone {get; set;}
		@AuraEnabled
		public String docId {get; set;}
	}
}