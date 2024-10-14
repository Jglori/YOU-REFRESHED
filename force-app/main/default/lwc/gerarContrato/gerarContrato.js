import { LightningElement, api, track } from 'lwc';
import infoContrato from '@salesforce/apex/ContractController.infoContrato';
// import getTemplateOptions from '@salesforce/apex/ContratoController.getTemplateOptions';

export default class ContratoForm extends LightningElement {
    @api recordId; 

    @track status;
    @track dataInicioContrato;
    @track dataEnvioParaAssinatura;
    @track dataAssinaturaCliente;
    @track templateSelecionado;

    nomeConta;

    templateOptions = [];
    signatariosOptions = [
        { label: 'Signatário 1', value: '1' },
        { label: 'Signatário 2', value: '2' },
        { label: 'Signatário 3', value: '3' }
    ];

    connectedCallback() {
        this.fetchContrato();
    }

    async fetchContrato() {
        try {
            const contrato = await infoContrato({ oppId: this.recordId });
            this.nomeConta = contrato.Account.Name;
            this.status = contrato.Status;
            this.dataInicioContrato = contrato.StartDate;
            this.dataEnvioParaAssinatura = contrato.DataEnvioParaAssinatura__c;
            this.dataAssinaturaCliente = contrato.CustomerSignedDate;
            console.log(JSON.stringify(contrato));
        } catch (error) {
            console.error('Erro ao buscar contrato:', error);
        }
    }

    // handleTemplate(event) {
    //     this.templateSelecionado = event.target.value;
    // }
}
