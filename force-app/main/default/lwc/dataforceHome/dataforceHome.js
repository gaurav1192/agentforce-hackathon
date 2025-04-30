import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class DataforceHome extends NavigationMixin(LightningElement) {
    // You can add JavaScript logic here if needed
    // For example, handling button clicks or fetching data

    navigateToJobPostings() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Job_Posting__c'
            }
        });
    }
}