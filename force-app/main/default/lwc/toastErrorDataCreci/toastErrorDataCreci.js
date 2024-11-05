import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastErrorDataCreci extends LightningElement {
    connectedCallback() {
        const evt = new ShowToastEvent({
            title: 'Erro',
            message: 'Erro na Data Creci',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    } 
}