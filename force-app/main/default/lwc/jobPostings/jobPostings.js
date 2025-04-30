import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getJobPostings from '@salesforce/apex/JobPostingController.getJobPostings';

export default class JobPostings extends NavigationMixin(LightningElement) {
    isLoading = true;

    @track jobPostings = [];

    connectedCallback() {

        getJobPostings().then(result => {
            this.jobPostings = result;
        })
        .catch(error => {
            console.log('error in fetching job postings : ' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = false;
        })
    }

    navigateToJobApplication(event) {
        console.log('job id : ' + event.currentTarget.dataset.jobPostingId);
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Job_Application__c'
            },
            state : {
                jobPostingId : event.currentTarget.dataset.jobPostingId
            }
        });
    }
}