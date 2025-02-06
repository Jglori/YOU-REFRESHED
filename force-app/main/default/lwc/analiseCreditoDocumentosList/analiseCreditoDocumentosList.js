import { refreshApex } from '@salesforce/apex';
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validate from '@salesforce/apex/DocumentController.validateDocument';
import invalidate from '@salesforce/apex/DocumentController.invalidateDocument';
import getDocuments from '@salesforce/apex/DocumentController.getDocumentosByAnaliseCredito';

export default class AnaliseCreditoDocumentosList extends LightningElement {
    @api recordId;
    @track documents;
    @track title;
    wiredDocumentsResult;
    
    @wire(getDocuments, { analiseCreditoId: '$recordId' })
    wiredDocuments(result) {
        this.wiredDocumentsResult = result;
        const { data, error } = result;

        if (data) {
            this.documents = data;
            this.title = `Documentos (${this.documents.length})`;
        } else if (error) {
            this.documents = undefined;
            this.title = 'Documentos (0)';
            console.error(error);
        }
    }

    get documentsAction() {
        console.log(JSON.stringify(this.documents));
            
        return this.documents?.map(document => ({
            ...document,
            label: document.Validado__c ? 'Invalidar' : 'Validar',
            title: document.Validado__c ? 'Invalida documento' : 'Valida documento',
            class: document.Validado__c ? 'slds-button btn-red-transparent' : 'slds-button btn-green-transparent',
            profileUrl: `/lightning/r/Documentacao__c/${document.Id}/view`
        }));
    }

    handleValidate(event) {
        const documentId = event.target.dataset.id;
        const document = this.documents?.find(doc => doc.Id == documentId); 
        
        if (document.Validado__c) {
            this.handleDocumentValidate( invalidate({ id: document.Id }), 'invalidado' );
        } else {
            this.handleDocumentValidate( validate({ id: document.Id }), 'validado');
        }
    }

    handleDocumentValidate( methodValidation, status ) {
        methodValidation
        .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Sucesso',
                        message: `Documento ${status} com sucesso!`,
                        variant: 'success'
                    })
                );
            refreshApex(this.wiredDocumentsResult);          
            })  
            .catch(error =>{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: `Não foi possível validar Documento! ${error.message}`,
                        variant: 'erro'
                    })
                );
            });
    }
}