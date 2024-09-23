import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ErrorToastAlways extends LightningElement {
    connectedCallback() {
        const evt = new ShowToastEvent({
            title: 'Erro',
            message: 'Erro no CPF',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    } 
}