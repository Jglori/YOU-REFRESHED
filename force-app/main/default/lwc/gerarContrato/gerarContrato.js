import { refreshApex } from '@salesforce/apex';
import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import infoContrato from '@salesforce/apex/ContractController.infoContrato';
// import getD4SignCreateUrl from '@salesforce/apex/IntegrationD4Sign.getSanboxCreateUrl';
import getContractsByOpportunityId from '@salesforce/apex/ContractController.getByOpportunityId';
import rolesContatoOpp from '@salesforce/apex/ContractController.rolesContatoOpp';
import createContract from '@salesforce/apex/ContractController.create';
import obterPDFContrato from '@salesforce/apex/ContractController.obterPDFContrato';
import assinarContrato from '@salesforce/apex/ContractController.assinarContrato';
import getStatusValues from '@salesforce/apex/Utils.getPicklistValues';
import getAccountByOpportunityId from '@salesforce/apex/AccountController.getByOpportunityId';
import getTemplatesDocumentosByOpportunityId from '@salesforce/apex/TemplateDocumentoController.getByOpportunityId';

import { NavigationMixin } from 'lightning/navigation';

export default class ContratoForm extends NavigationMixin(LightningElement) {
    @api recordId; 
    @track isLoading = false;
   
    statusOptions;
    @track templatePlaceholder = 'Selecione o template...';
    templateOptions;

    @track isModalOpen;
    @track contracts;

    @track status;
    @track dataInicioContrato;
    @track contaNome;
    @track conta;
    @track dataEnvioParaAssinatura;
    @track dataAssinaturaCliente;
    @track signatarios;
    @track template;

    wiredContracts;
    
    connectedCallback() {
        this.getAccount();
        this.getRoles();
        this.getTemplates();
    }

    @wire(getContractsByOpportunityId, { oppId: '$recordId' })
    getContracts(result) {
        this.wiredContracts = result;
        const { error, data }  = result;
        
        if (data) {
            this.contracts = data;
        } else {
            console.error('Error: ' + error);
        }
    }

    get contractsAction() {
        return this.contracts?.map(contract => ({
            ...contract,
            disabled: contract.Status != 'ContratoGerado',
            profileUrl: `/lightning/r/contractacao__c/${contract.Id}/view`
        }));
    }

    @wire(getStatusValues, { objAPIName: 'Contract', fieldAPIName: 'Status' })
    getStatusValues(result) { 
        const { error, data } = result;
        if (data) {
            this.statusOptions = data;
        } else {
            console.error('Error: ', error);
        }
    }

    getAccount() {
        getAccountByOpportunityId({ opportunityId: this.recordId })
        .then(result => {
            this.contaNome = result.Name
            this.conta = result;
        })
        .catch(error => {
            console.error('Error: ', error);
        })
    }

    handleInputChange(event) {
        const field = event.target.dataset.name;
        const value = event.target.value;
        this[field] = value;
    }

    getTemplates() {
        getTemplatesDocumentosByOpportunityId({ opportunityId: this.recordId })
        .then(result => {
            if (result == null) {
                this.templatePlaceholder = 'Nenhum template relacionado a essa oportunidade.'
            } else {
                this.templateOptions = result.map(template => ({
                    label: template.Name,
                    value: template.Id
                }));
            }
        })
        .catch(error => {
            console.error('Error: ', error);
        })
    }

    getRoles() {
        rolesContatoOpp({ oppId: this.recordId })
        .then(result => {
            this.signatarios = result.map(role => ({
                label: role.Contact.Name,
                role: role.Role,
                value: role.Contact.Id
            }));
        })
        .catch(error => {
            console.error('Erro ao buscar roles:', error);
        })
    }

    gerarContrato() {
        const validation = this.checkFieldsValidity();
        if (!validation.isValid) {
            console.error(validation.message);
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: validation.message,
                    variant: 'error'
                })
            );
            return;
        }
        this.isLoading = true;
        
        
        const contract = {
            status: this.status,
            dataInicioContrato: this.dataInicioContrato,
            conta: this.conta,
            dataEnvioParaAssinatura: this.dataEnvioParaAssinatura,
            dataAssinaturaCliente: this.dataAssinaturaCliente,
            signatarios: this.signatarios,
            template: this.template,
            oportunidade: this.recordId
        };

        createContract({ data: contract })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Contrato Gerado',
                    message: 'Contrato gerado com sucesso',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error('Error:', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Ocorreu um erro ao gerar o contrato. Verifique as informações da oportunidade e tente novamente.',
                    variant: 'error'
                })
            );
        })
        .finally(() => {
            this.isLoading = false;
            this.closeModal();
            refreshApex(this.wiredContracts);
        })
    }

    checkFieldsValidity() {
        if (!this.status) {
            return { isValid: false, message: "O status é obrigatório." };
        }
        if (!this.dataInicioContrato) {
            return { isValid: false, message: "A data de início do contrato é obrigatória." };
        }
        if (!this.contaNome) {
            return { isValid: false, message: "O nome da conta é obrigatório." };
        }
        if (!this.dataEnvioParaAssinatura) {
            return { isValid: false, message: "A data de envio para assinatura é obrigatória." };
        }
        if (!this.dataAssinaturaCliente) {
            return { isValid: false, message: "A data de assinatura do cliente é obrigatória." };
        }
        // if (!this.signatarios || this.signatarios.length === 0) {
        //     return { isValid: false, message: "Pelo menos um signatário é obrigatório." };
        // }
        if (!this.template) {
            return { isValid: false, message: "O template é obrigatório." };
        }
        
        return { isValid: true };
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

    handleAssinaturaClick() {
        this.isLoading = true;
        // getD4SignCreateUrl()
        // .then(result => {
        //     const urlCreate = result;
        //     window.open(urlCreate, '_blank');
        // })
        // .catch(error => {
        //     console.error(error);
        // })
        // .finally(() => {
        //     this.isLoading = false;
        // })
    }

    downloadHandler() {
        if (this.contentDocumentId) {
            const url = `/sfc/servlet.shepherd/document/download/${this.contentDocumentId}`;
            window.open(url, '_blank');
        }
    }

    openModal() {
        this.isModalOpen = true;
    } 

    closeModal() {
        this.isModalOpen = false;
    }

    get isValidGeneration() {
        return !this.checkFieldsValidity().isValid;
    }

}