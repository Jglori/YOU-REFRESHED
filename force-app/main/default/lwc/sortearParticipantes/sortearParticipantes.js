import { LightningElement, track } from 'lwc';
import executarSorteio from '@salesforce/apex/SorteioController.executarSorteio';

export default class SortearParticipantes extends LightningElement {
    @track isProcessing = false;
    @track message = '';
    @track messageClass = '';

    
    iniciarSorteio() {
        this.isProcessing = true;
        this.message = '';

        executarSorteio()
            .then(() => {
                this.message = 'Sorteio executado com sucesso!';
                this.messageClass = 'slds-text-color_success';
            })
            .catch(error => {
                this.message = 'Erro ao executar sorteio: ' + error.body.message;
                this.messageClass = 'slds-text-color_error';
            })
            .finally(() => {
                this.isProcessing = false;
            });
    }
}