import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import infoContrato from '@salesforce/apex/ContractController.infoContrato';
import rolesContatoOpp from '@salesforce/apex/ContractController.rolesContatoOpp';
import getTemplates from '@salesforce/apex/TemplateController.getTemplates';
import retornarContratoGerado from '@salesforce/apex/ContractController.retornarContratoGerado';
import obterPDFContrato from '@salesforce/apex/ContractController.obterPDFContrato';
import assinarContrato from '@salesforce/apex/ContractController.assinarContrato';
import { NavigationMixin } from 'lightning/navigation';

export default class ContratoForm extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track status;
    @track dataInicioContrato;
    @track dataEnvioParaAssinatura;
    @track dataAssinaturaCliente;
    @track templateSelecionado;
    @track templateOptions = [''];
    @track statusIsGerado = false;
    @track statusIsAssinado = false;
    @track isLoading = false;
    @track contrato;
    @track contratoVazio = false; 
    contentDocumentId;
    nomeContrato;
    nomeConta;
    signatarios = [];

    connectedCallback() {
        this.fetchRoles();
        this.fetchContrato();
    }

    async fetchContrato() {
        this.isLoading = true;

        try {
            const templates = await getTemplates({ oppId: this.recordId });
            this.contrato = await infoContrato({ oppId: this.recordId });

            console.log('templates: '+ JSON.stringify(templates));

            console.log(JSON.stringify(this.contrato));   

            if (this.contrato.AccountId != null) {
                this.nomeConta = this.contrato.Account.Name != null ? this.contrato.Account.Name : 'N/A';
                this.status = this.contrato.Status != null ? this.contrato.Status : 'N/A';
                this.dataInicioContrato = this.contrato.StartDate != null ? this.contrato.StartDate : 'N/A';
                this.dataEnvioParaAssinatura = this.contrato.DataEnvioParaAssinatura__c != null ? this.contrato.DataEnvioParaAssinatura__c : 'N/A';
                this.dataAssinaturaCliente = this.contrato.CustomerSignedDate != null ? this.contrato.CustomerSignedDate : 'N/A'; 
            } else {
                this.contratoVazio = true;
            }

            this.templateOptions = templates.map(template => ({
                label: template.Name,
                value: template.Id
            }));

            if (templates.length == 0 || templates == null) {
                this.templateOptions = [{
                    label: 'Nenhum template criado! Crie um a partir do empreendimento.',
                    value: ''
                }];
            }

            if (this.status === 'Contrato Gerado' || this.status === 'Ativo') {
                this.statusIsGerado = true;
                this.statusIsAssinado = true;
                this.fetchContentVersion();    
            }
        } catch (error) {
            console.error('Erro ao buscar contrato:', error);
        } finally{
            this.isLoading = false;
        }
    }

    async fetchRoles() {
        this.isLoading = true;

        try {
            const roles = await rolesContatoOpp({ oppId: this.recordId });
            this.signatarios = roles.map(role => ({
                label: role.Contact.Name,
                role: role.Role,
                value: role.Contact.Id
            }));
        } catch (error) {
            console.error('Erro ao buscar roles:', error);
        } finally{
            this.isLoading = false;
        }
    }

    async gerarContrato() {
        this.isLoading = true;

        try {
            const content = await retornarContratoGerado({ oppId: this.recordId, templateId: this.templateSelecionado });
            
            this.contentDocumentId = content.ContentDocumentId;
            this.nomeContrato = content.Title;
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Contrato Gerado',
                    message: 'Contrato gerado com sucesso',
                    variant: 'success'
                })
            );
            
            this.statusIsGerado = true;
            await this.fetchContentVersion();
            
        } catch (error) {
            console.error('Erro ao gerar contrato:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Ocorreu um erro ao gerar o contrato. Verifique as informações da oportunidade e tente novamente.',
                    variant: 'error'
                })
            );
        } finally{
            this.isLoading = false;
        }
    }

    async signHandler(){
        this.isLoading = true;

        try {
            await assinarContrato({ oppId: this.recordId });
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Contrato Assinado',
                    message: 'Contrato assinado com sucesso',
                    variant: 'success'
                })
            );

            this.statusIsAssinado = true;
        } catch (error) {
            console.error('Erro ao assinar o contrato:', error);
        } finally{
            this.isLoading = false;
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
        this.isLoading = true;
        try {
            const contentVersion = await obterPDFContrato({ oppId: this.recordId });
            if (contentVersion) {
                this.contentDocumentId = contentVersion.ContentDocumentId;
                this.nomeContrato = contentVersion.ContentDocument.Title;
            }
        } catch (error) {
            console.error('Erro ao buscar ContentVersion:', error);
        } finally{
            this.isLoading = false;
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