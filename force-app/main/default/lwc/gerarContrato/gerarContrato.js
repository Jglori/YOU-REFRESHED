import { LightningElement, api, track } from 'lwc';
import infoContrato from '@salesforce/apex/ContractController.infoContrato';
import rolesContatoOpp from '@salesforce/apex/ContractController.rolesContatoOpp';
import getTemplates from '@salesforce/apex/TemplateController.getTemplates';
import retornarContratoGerado from '@salesforce/apex/ContractController.retornarContratoGerado';

export default class ContratoForm extends LightningElement {
    @api recordId; 

    @track status;
    @track dataInicioContrato;
    @track dataEnvioParaAssinatura;
    @track dataAssinaturaCliente;
    @track templateSelecionado;
    @track templateOptions = [''];

    nomeConta;
    signatarios = [];

    connectedCallback() {
        this.fetchContrato();
        this.fetchRoles();
    }

    async fetchContrato() {
        try {
            const contrato = await infoContrato({ oppId: this.recordId });
            const templates = await getTemplates({ oppId: this.recordId });
            console.log('templates', this.templateOptions);
            this.nomeConta = contrato.Account.Name;
            this.status = contrato.Status;
            this.dataInicioContrato = contrato.StartDate;
            this.dataEnvioParaAssinatura = contrato.DataEnvioParaAssinatura__c;
            this.dataAssinaturaCliente = contrato.CustomerSignedDate;
            console.log(JSON.stringify(contrato));

            this.templateOptions = templates.map(template => {
                return {
                    label: template.Name,
                    value: template.Id
                }
            });
        } catch (error) {
            console.error('Erro ao buscar contrato:', error);
        }
    }

    async fetchRoles(){
        try {
            const roles = await rolesContatoOpp({ oppId: this.recordId });
            this.signatarios = roles.map(role => {
                return {
                    label: role.Contact.Name,
                    role: role.Role,
                    value: role.Contact.Id
                }
            });
            
            console.log(JSON.stringify(roles));
        } catch (error) {
            console.error('Erro ao buscar roles:', error);
        }
    }

    async gerarContrato(){
        try{
            const res = await retornarContratoGerado({ oppId: this.recordId, templateId: this.templateSelecionado })
            console.log(JSON.stringify(res));
        } catch (error) {
            console.error('Erro ao gerar contrato:', error.getMessage());
        };
    }

    handleTemplate(event) {
        this.templateSelecionado = event.detail.value;
        console.log(this.templateSelecionado);
    }
}
