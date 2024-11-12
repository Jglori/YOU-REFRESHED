import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import REPORTASE_FIELD from '@salesforce/schema/Contact.Reporta_se_A__c';
import { getRecord as getUserRecord } from 'lightning/uiRecordApi';
import USER_NAME_FIELD from '@salesforce/schema/User.Name';

export default class ContratoEquipe extends NavigationMixin(LightningElement) {
    @api recordId;
    managerId;
    managerName;
    error;

    @wire(getRecord, { recordId: '$recordId', fields: [REPORTASE_FIELD] })
    wiredContact({ error, data }) {
        if (data) {
            this.managerId = getFieldValue(data, REPORTASE_FIELD);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.managerId = undefined;
        }
    }

    @wire(getUserRecord, { recordId: '$managerId', fields: [USER_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.managerName = getFieldValue(data, USER_NAME_FIELD);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.managerName = undefined;
        }
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