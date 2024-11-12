import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCustomMetadata from '@salesforce/apex/MetadataService.createCustomMetadata';

export default class ChecklistDocumentos extends LightningElement {
    @track nomeDocumento = '';
    @track obrigatorio = false;
    @track papel = '';

    papelOptions = [
        { label: 'Procurador', value: 'Procurador' },
        { label: 'Cônjuge/Companheiro', value: 'Cônjuge/Companheiro' },
        { label: 'Fiador', value: 'Fiador' },
        { label: 'Comprador', value: 'Comprador' },
    ];

    handleNomeChange(event) {
        this.nomeDocumento = event.target.value;
    }

    handleCheckboxChange(event) {
        this.obrigatorio = event.target.checked;
        console.log(this.obrigatorio);
    }

    handlePapelChange(event) {
        this.papel = event.target.value;
    }

    adicionarDocumento() {
        if (this.nomeDocumento && this.papel) {
            createCustomMetadata({
                fullName: 'MyNamespace__' + this.nomeDocumento,
                label: this.nomeDocumento,
                documentName: this.nomeDocumento,
                isMandatory: this.obrigatorio,
                role: this.papel
            })
            .then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: 'Documento adicionado com sucesso.',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao adicionar documento: ' + error.body.message,
                        variant: 'error',
                    }),
                );
            });

            this.nomeDocumento = '';
            this.obrigatorio = false;
            this.papel = '';
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Por favor, preencha todos os campos.',
                    variant: 'error',
                }),
            );
        }
    }
}