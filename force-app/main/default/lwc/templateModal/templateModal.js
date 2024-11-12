import { api, LightningElement } from 'lwc';
import LightningModal from 'lightning/modal';
import enviarTemplatePadrao from "@salesforce/apex/WhatsAppController.enviarTemplatePadrao";
import getLeadDetails from "@salesforce/apex/WhatsAppController.getLeadDetails";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

export default class TemplateModal extends LightningModal {
    @api recordId;

    nomeLead; 
    nomeOwner; 
    nomeOrganizacao; 
    nomeEmpreendimento;
    celularLead;
    
    isContatoleadSelected = false;
    isHelloWorldSelected = false;

    selectedTemplateId = '';

    connectedCallback() {
        this.fetchLeadDetails();
    }
    renderedCallback() {
        this.fetchLeadDetails();
    }

    /**
     * Busca os detalhes do Lead a partir do Apex Controller e popula as variáveis do componente com esses dados.
     */
    fetchLeadDetails() {
        getLeadDetails({ leadId: this.recordId })
            .then((data) => {
                const leadInfo = data.leadInfo;
                this.nomeLead = leadInfo.FirstName;
                this.nomeOwner = leadInfo.Owner.Name;
                this.nomeOrganizacao = data.orgName;
                this.nomeEmpreendimento = data.nomeEmpreendimento,
                this.celularLead = leadInfo.MobilePhone;
            })
            .catch((error) => {
                console.error('Erro ao buscar os detalhes do Lead:', error);
            });
    }

    /**
     * Fecha o modal ao disparar o evento de fechamento com o valor 'okay'.
     */
    handleClose() {
        this.close('okay');
    }

    /**
     * Realiza a validação e o envio do template selecionado. Caso faltem campos obrigatórios, exibe uma mensagem de erro.
     */
    async handleSend() {
        if (!this.selectedTemplateId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Por favor, selecione um template antes de enviar.',
                    variant: 'error',
                })
            );
            return;
        }

        const camposFaltantes = [
            this.nomeLead === null ? 'Primeiro Nome' : null,
            this.nomeEmpreendimento === null ? 'Empreendimento de Interesse' : null,
            this.celularLead === null ? 'Celular' : null,
        ].filter(campo => campo !== null);

        if (camposFaltantes.length > 0) {
            const mensagemErro = `Verifique ${camposFaltantes.length > 1 ? 'os campos' : 'o campo'}: ${camposFaltantes.join(', ')}`;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Lead não possui informações suficientes',
                    message: mensagemErro,
                    variant: 'error',
                })
            );
            return;
        }

        try {
            await enviarTemplatePadrao({ idLead: this.recordId, nomeTemplate: this.selectedTemplateId });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso',
                    message: 'Template enviado com sucesso!',
                    variant: 'success',
                })
            );
            this.close('sent');
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro ao enviar template',
                    message: error.body.message,
                    variant: 'error',
                })
            );
        }
    }

    /**
     * Define o template selecionado com base no card clicado pelo usuário e atualiza o estado do componente.
     */
    handleCardClick(event) {
        const cardId = event.currentTarget.dataset.id;

        this.isContatoleadSelected = false;
        this.isHelloWorldSelected = false;

        if (cardId === "contatolead") {
            this.isContatoleadSelected = true;
            this.selectedTemplateId = 'contatolead';
        } else if (cardId === "hello_world") {
            this.isHelloWorldSelected = true;
            this.selectedTemplateId = 'hello_world'; 
        }
    }
}