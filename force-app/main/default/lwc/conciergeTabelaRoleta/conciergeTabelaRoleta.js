import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id'; // Obtém o ID do usuário atual
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name'; // Campo de nome do perfil


export default class ConciergeTabelaRoleta extends LightningElement {
    @api telaCancelar;
    @api telaDistribuir;
    @api formulario;
    @track userProfile;

    
    @track isModalOpen = false;
    @track selectedRoletaId = null; 
    @api 
    set roletasLeads(data) {
        this._roletasLeads = data;
        this._roletasLeadsOriginal = [...data]; 
    }

    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.userProfile = data.fields.Profile.value.fields.Name.value;
            console.log('Perfil do usuário:', this.userProfile); // Verifica se está buscando o perfil corretamente
        } else if (error) {
            console.error('Erro ao buscar perfil do usuário:', error);
        }
    }
    
    get isCoordenadorOuRecepcionista() {
        return this.isCoordenador || this.isRecepcionista;
    }
    
    get isRecepcionista() {
        return this.userProfile === 'Recepcionista Comunidade';
    }

    get isCoordenador() {
        return this.userProfile === 'Coordenador Comunidade';
    }

    get isGerente() {
        return this.userProfile === 'Gerente Comunidade';
    }

    get isCorretor() {
        return this.userProfile === 'Corretor Comunidade';
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
    _roletasLeadsOriginal = []; 

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
        const selectedRows = event.detail.selectedRows;
        const roleta = selectedRows.length > 0 ? selectedRows[0] : null;

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

        if (roleta && this.selectedRoletaId === roleta.id) {
            this.selectedRoletaId = null;
            this.template.querySelector('lightning-datatable').selectedRows = [];
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
        console.log('ID do corretor selecionado:', corretorId);

        if (this.formulario) {
            this.dispatchEvent(new CustomEvent('confirmardistribuicao', {
                detail: {
                    tela: this.telaDistribuir,
                    idCorretor: corretorId,
                    nomeCorretor: event.detail.nomeCorretor
                }
            }));
        } else {
            console.error('Formulário não definido.');
        }
    }

    handleCancelar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }

    handleDistribuirLeads() {
        if (this.selectedRoletaId) {
            this.dispatchEvent(new CustomEvent('confirmardistribuicao', {
                detail: {
                    tela: this.telaDistribuir
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
        this.selectedRoletaId = '';
        if (this.template.querySelector('lightning-datatable')) {
            this.template.querySelector('lightning-datatable').selectedRows = [];
        }
        
        this.isModalOpen = true;
    }
    

    handleModalClose() {
        this.isModalOpen = false;
    }
}