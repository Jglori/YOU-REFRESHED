import { LightningElement, api, wire } from 'lwc';
    import { NavigationMixin } from 'lightning/navigation';
    import getReportingContacts from '@salesforce/apex/ReportingContactsController.getReportingContacts';
    
    export default class ContactManager extends NavigationMixin(LightningElement) {
        @api recordId;
        @api managerId;
        reportingContacts;
        error;
    
        @wire(getReportingContacts, { contactId: '$recordId' })
        wiredReportingContacts({ error, data }) {
            if (data) {
                this.reportingContacts = data.map(contact => ({
                    ...contact,
                    nameUrl: this.getRecordUrl(contact.Id, 'Contact'),
                    AccountName: contact.Account ? contact.Account.Name : '',
                    AccountUrl: contact.Account ? this.getRecordUrl(contact.Account.Id, 'Account') : ''
                }));
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.reportingContacts = undefined;
            }
        }
    
        get columns() {
            return [
                { 
                    label: 'Nome completo', 
                    fieldName: 'nameUrl', 
                    type: 'url', 
                    typeAttributes: { 
                        label: { fieldName: 'Name' }, 
                        target: '_self' 
                    },
                    cellAttributes: { 
                        class: 'slds-theme_shade slds-text-color_default' 
                    }
                },
                { 
                    label: 'Nome da empresa', 
                    fieldName: 'AccountUrl', 
                    type: 'url', 
                    typeAttributes: { 
                        label: { fieldName: 'AccountName' }, 
                        target: '_self' 
                    },
                    cellAttributes: { 
                        class: 'slds-theme_shade slds-text-color_default' 
                    }
                },
                { label: 'Telefone', fieldName: 'MobilePhone', type: 'phone' }
            ];
        }
    
        getRecordUrl(recordId, objectApiName) {
            return this[NavigationMixin.GenerateUrl]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: recordId,
                    objectApiName: objectApiName,
                    actionName: 'view'
                }
            });
        }
    
        navigateToManager() {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.managerId,
                    objectApiName: 'Contact',
                    actionName: 'view'
                }
            });
        }
    }