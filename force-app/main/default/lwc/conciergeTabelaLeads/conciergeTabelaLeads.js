import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConciergeTabelaLeads extends LightningElement {
    @api telaCancelar;
    @api telaDistribuir;
    @track leadSelecionado = [];
    @track selectedRoletaId = null; // Inicialmente, nenhum ID de roleta selecionado
    @track selectedCorretorId = null; // Inicialmente, nenhum ID de corretor selecionado

    @api
    set leads(data) {
        console.log(data);
        this._leads = data;
        this.updateColumns(data);
    }

    get leads() {
        return this._leads;
    }

    _leads;
    selectedLead;

    colunas = [
        { label: "Nome", fieldName: "nome", type: "text" },
        { label: "Email", fieldName: "email", type: "email" },
        { label: "Celular", fieldName: "celular", type: "phone" },
        { label: "Status", fieldName: "status", type: "text" },
        { label: "Proprietário", fieldName: "proprietario", type: "text" }
    ];

    updateColumns(data) {
        if (data && data.length > 0) {
            const sampleLead = data[0];
    
            console.log('Sample lead:', JSON.stringify(sampleLead));
            if (sampleLead.telefone === "" || sampleLead.telefone === null) {
                this.colunas = [
                    { label: "Nome", fieldName: "nome", type: "text" },
                    { label: "Email", fieldName: "email", type: "email" },
                    { label: "Celular", fieldName: "celular", type: "phone" },
                    { label: "Status", fieldName: "status", type: "text" },
                    { label: "Proprietário", fieldName: "proprietario", type: "text" }
                ];
            } else if (sampleLead.telefone) {
                this.colunas = [
                    { label: "Nome", fieldName: "nome", type: "text" },
                    { label: "Email", fieldName: "email", type: "email" },
                    { label: "Telefone", fieldName: "telefone", type: "phone" },
                    { label: "Status", fieldName: "status", type: "text" },
                    { label: "Proprietário", fieldName: "proprietario", type: "text" }
                ];
            }
        }
    }

    connectedCallback() {
        console.log('Leads em concierge tabela leads', this.leads);
        this.showLeadAlreadyRegisteredToast();
    }

    showLeadAlreadyRegisteredToast() { 
        this.dispatchEvent(new ShowToastEvent({
            title: 'Atenção',
            message: 'Este Lead já está cadastrado',
            variant: 'warning'
        }));
    }

    handleFiltrar(event) {
        this._leads = this._leads.filter(lead => lead.nome?.includes(event.detail.value));
    }

    getSelectedRows(event) {
        const selectedRows = event.detail.selectedRows;
        console.log('Selected Rows:', selectedRows);
        if (selectedRows.length > 0) {
            this.selectedLead = selectedRows[0];
            this.leadSelecionado = selectedRows[0];
            console.log('Lead selecionado ' + JSON.stringify(this.leadSelecionado));
        } else {
            this.selectedLead = null; 
        }
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: 'FORMULARIO' }
        }));
    }

    encaminharCorretor() {
        if (this.leadSelecionado.length === 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Atenção',
                message: 'Nenhum lead selecionado',
                variant: 'error'
            }));
            return;
        }

        console.log('Lead selecionado:', JSON.stringify(this.leadSelecionado));

        if (!this.leadSelecionado.nomeCorretor || this.leadSelecionado.nomeCorretor.trim() === '') {
            console.log('Nome do corretor está vazio. Criando reiteração.');
            this.dispatchEvent(new CustomEvent('telareiteracao', {
                detail: { lead: this.leadSelecionado }
            }));
        } else {
            console.log('Nome do corretor preenchido. Criando tarefa de reiteração.');
            this.dispatchEvent(new CustomEvent('telacorretor', {
                detail: { lead: this.leadSelecionado, nomeCorretor: this.leadSelecionado.nomeCorretor }
            }));
        }
    }

    handleSalvarCorretor(event) {
        const corretorId = event.detail.corretorId;
        if (this.selectedRoletaId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro!',
                    message: 'Não é possível selecionar uma roleta e um corretor ao mesmo tempo.',
                    variant: 'error',
                }),
            );
            return;
        }
        this.selectedCorretorId = corretorId;

        console.log('ID do corretor selecionado:', corretorId);

        if (this.formulario) {
            this.dispatchEvent(new CustomEvent('confirmardistribuicao', {
                detail: {
                    tela: this.telaDistribuir,
                    idCorretor: corretorId
                }
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso!',
                    message: 'Lead associado ao corretor com sucesso.',
                    variant: 'success',
                }),
            );
        } else {
            console.error('Formulário não definido.');
        }
    }

    getSelectedRoleta(event) {
        const roleta = event.detail.selectedRows[0];
        if (this.selectedCorretorId) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro!',
                    message: 'Não é possível selecionar uma roleta e um corretor ao mesmo tempo.',
                    variant: 'error',
                }),
            );
            return;
        }
        this.selectedRoletaId = roleta ? roleta.id : null;

        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: {           
                target: {
                    value: this.selectedRoletaId,
                    dataset: {
                        name: 'idRoletaLeads'
                    }
                }
            }
        }));
    }
}