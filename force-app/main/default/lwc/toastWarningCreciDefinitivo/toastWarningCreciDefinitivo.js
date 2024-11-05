import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ToastWarningCreciDefinitivo extends LightningElement {

    connectedCallback() {
        const evt = new ShowToastEvent({
            title: 'Erro',
            message: 'Campo CRECI é obrigatório quando o tipo de CRECI é definitivo',
            variant: 'error',
        });
        this.dispatchEvent(evt);
    } 
}