public without sharing class JobPostingController {
    @AuraEnabled
    public static List<Job_Posting__c> getJobPostings() {
        return [
            SELECT Id, Name, Job_Description__c, Title__c, Location__c, Open_Positions__c 
            FROM Job_Posting__c 
            WHERE Active__c = true
            AND Open_Positions__c > 0
        ];
    }
}