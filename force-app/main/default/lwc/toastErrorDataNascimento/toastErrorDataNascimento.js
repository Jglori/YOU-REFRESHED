import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ToastErrorDataNascimento extends LightningElement {
    connectedCallback() {
        const evt = new ShowToastEvent({
            title: 'Erro',
            message: 'Erro na Data de Nascimento',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    } 
}