import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConciergeTabelaRoleta extends LightningElement {
    @api telaCancelar;
    @api telaDistribuir;
    @api formulario;
    @api lead
    
    @track isModalOpen = false;
    @track selectedRoletaId = null; // Inicialmente, nenhum ID de roleta selecionado
    @track selectedCorretorId = null;
    _roletasLeadsOriginal = []

    @api 
    set roletasLeads(data) {
        this._roletasLeads = data;
        this._roletasLeadsOriginal = [...data]; 
    }

    get roletasLeads() {
        const roletasFiltradas = [];
        const lead = this.formulario;

        this._roletasLeads.forEach(roleta => {
            if (roleta.canaisAtendimento.includes(lead.canal)) {
                roletasFiltradas.push(roleta);
            }
        });

        return roletasFiltradas;
    }

    _roletasLeads = [];

    colunas = [
        { label: 'Nome', fieldName: 'nome', type: 'text' },
        { label: 'Canais de atendimento', fieldName: 'canaisAtendimento', type: 'text' },
        { label: 'Hora de início', fieldName: 'horaInicio', type: 'date', typeAttributes: { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' } },
        { label: 'Hora de fim', fieldName: 'horaFim', type: 'date', typeAttributes: { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' } }
    ];

  
    handleFiltrar(event) {
        const filtro = event.detail.value.toLowerCase();
        if (filtro) {
            this._roletasLeads = this._roletasLeadsOriginal.filter(lead => lead.nome?.toLowerCase().includes(filtro));
        } else {
            this._roletasLeads = [...this._roletasLeadsOriginal]; // Restaura a lista original quando o filtro é removido
        }
    }

    getSelectedRows(event) {
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
    
        // Se a roleta selecionada for a mesma já armazenada, desmarque-a
        if (roleta && this.selectedRoletaId === roleta.id) {
            this.selectedRoletaId = null;
        } else {
            this.selectedRoletaId = roleta ? roleta.id : null;
        }
    
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

        console.log('corretorId', corretorId);
        this.dispatchEvent(new CustomEvent('reiteracaocorretor', {
            detail: {
                lead: this.lead,
                idCorretor: corretorId
            }
        }));
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }

    handleDistribuirLeads() {
        if (this.selectedRoletaId) {
            this.dispatchEvent(new CustomEvent('reiterarlead', {
                detail: {
                    roletaId: this.selectedRoletaId,
                    lead: this.lead
                }
            }));
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro!',
                    message: 'Por favor, selecione uma roleta antes de encaminhar.',
                    variant: 'error',
                }),
            );
        }
    }

    distribuirCorretor() {
        if (this.selectedRoletaId) {
            this.selectedRoletaId = null;
        }
    
        this.isModalOpen = true;
    }

    handleModalClose() {
        this.isModalOpen = false;
    }
}