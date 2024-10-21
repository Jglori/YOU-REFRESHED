import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import infoContrato from '@salesforce/apex/ContractController.infoContrato';
import rolesContatoOpp from '@salesforce/apex/ContractController.rolesContatoOpp';
import getTemplates from '@salesforce/apex/TemplateController.getTemplates';
import retornarContratoGerado from '@salesforce/apex/ContractController.retornarContratoGerado';
import obterPDFContrato from '@salesforce/apex/ContractController.obterPDFContrato';

export default class ContratoForm extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track status;
    @track dataInicioContrato;
    @track dataEnvioParaAssinatura;
    @track dataAssinaturaCliente;
    @track templateSelecionado;
    @track templateOptions = [''];
    @track statusIsGerado = false;
    @track contrato;
    contentDocumentId;
    nomeContrato;
    nomeConta;
    signatarios = [];

    connectedCallback() {
        this.fetchContrato();
        this.fetchRoles();
    }

    async fetchContrato() {
        try {
            const templates = await getTemplates({ oppId: this.recordId });
            this.contrato = await infoContrato({ oppId: this.recordId });
            this.nomeConta = this.contrato.Account.Name;
            this.status = this.contrato.Status;
            this.dataInicioContrato = this.contrato.StartDate;
            this.dataEnvioParaAssinatura = this.contrato.DataEnvioParaAssinatura__c;
            this.dataAssinaturaCliente = this.contrato.CustomerSignedDate;

            this.templateOptions = templates.map(template => ({
                label: template.Name,
                value: template.Id
            }));

            if(templates.length == 0 || templates == null){
                this.templateOptions = [{
                    label: 'Nenhum template criado!',
                    value: ''
                }];
            }else{
                if(this.status === 'Contrato Gerado') {
                    this.statusIsGerado = true;
                    this.fetchContentVersion();    
                }
            }

        } catch (error) {
            console.error('Erro ao buscar contrato:', error);
        }
    }

    async fetchRoles() {
        try {
            const roles = await rolesContatoOpp({ oppId: this.recordId });
            this.signatarios = roles.map(role => ({
                label: role.Contact.Name,
                role: role.Role,
                value: role.Contact.Id
            }));
        } catch (error) {
            console.error('Erro ao buscar roles:', error);
        }
    }

    async gerarContrato() {
        const content = await retornarContratoGerado({ oppId: this.recordId, templateId: this.templateSelecionado });
        this.connectedCallback();

        try {
            this.contentDocumentId = this.statusIsGerado ? content.ContentDocumentId : content.Id;
            this.nomeContrato = content.Title;
        } catch (error) {
            console.error('Erro ao gerar contrato:', error);
        }

        if (this.contentDocumentId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Contrato Gerado',
                    message: 'Contrato gerado com sucesso',
                    variant: 'success'
                })
            );
        }
    }

    previewHandler() {
        if (this.contentDocumentId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: this.contentDocumentId
                }
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'O contrato precisa ser gerado antes de visualizá-lo.',
                    variant: 'error'
                })
            );
        }
    }

    async fetchContentVersion() {
        try {
            const contentVersion = await obterPDFContrato({ oppId: this.recordId });
            if (contentVersion) {
                this.contentDocumentId = contentVersion.ContentDocumentId;
                this.nomeContrato = contentVersion.ContentDocument.Title;
            }
        } catch (error) {
            console.error('Erro ao buscar ContentVersion:', error);
        }
    }

    downloadHandler() {
        if (this.contentDocumentId) {
            const url = `/sfc/servlet.shepherd/document/download/${this.contentDocumentId}`;
            window.open(url, '_blank');
        }
    }

    handleTemplate(event) {
        this.templateSelecionado = event.detail.value;
    }
}