import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import submitDraftApplication from '@salesforce/apex/JobApplicationController.submitDraftApplication';
import submitApplication from '@salesforce/apex/JobApplicationController.submitApplication';

export default class JobApplicationForm extends NavigationMixin(LightningElement) {

    @track application = {};

    isLoading = false;
    pageReference;
    showForm = true;

    @wire(CurrentPageReference)
	getCurrentPageReference(currentPageReference) {
		this.pageReference = currentPageReference;
	}

    get buttonName() {
        return this.showForm ? 'Next' : 'Submit';
    }

    connectedCallback() {
        if (this.pageReference?.state && this.pageReference?.state?.applicationId) {
            this.application.applicationId = this.pageReference?.state?.applicationId;
            this.showForm = false;
        } else if(this.pageReference?.state && this.pageReference?.state?.jobPostingId) {
             this.application.jobPostingId = this.pageReference?.state?.jobPostingId; 
        }
    }

    draftApplication() {
        submitDraftApplication({
            application : this.application
        })
        .then(result => {
            this.application = result;
            console.log('application : ' + JSON.stringify(this.application));
            this.showForm = false;
            this.showToast('Success', 'Your details has been saved. Please upload your resume.', 'success');
        })
        .catch(error => {
            console.log('error : ' + JSON.stringify(error));
        })
        .finally(() => {
            this.isLoading = false;
        }); 
    }
 
    handleInputChange(event) {
        this.application[event.target.name] = event.target.value;
    }

    showSubmit = false;
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if(uploadedFiles.length > 0) {
            this.showSubmit = true;
            this.application.docId = uploadedFiles[0].documentId;
        } else {
            this.showToast('Error', 'Please upload your resume.', 'error');
        }
    }

    handleButtonAction() {
        this.isLoading = true;
        if (this.isFormValid() && this.showForm) {
            this.draftApplication();
        } else if(this.showSubmit) {
            submitApplication({
                applicationId : this.application.applicationId
            })
            .then(result => {
                if(result) {
                    this.showToast('Success', 'Your application has been submitted successfully.', 'success');
                    this.isLoading = true;
                    this.resetForm();
                    setTimeout(() => {
                        this.navigateToHome();
                    }, 3000);
                }
            })
            .catch(error => {
                console.log('error : ' + JSON.stringify(error));
                this.isLoading = false;
            })
        } else {
            this.showToast('Error', 'Please fill all required fields.', 'error');
        }
    }

    isFormValid() {
        return this.application.firstName && this.application.lastName && this.application.email && this.application.phone;
    }

    resetForm() {
        this.application = {};
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    navigateToHome() {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Home'
            }
        });
    }
}