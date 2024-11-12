import { LightningElement, track  } from 'lwc';

import criarLead from '@salesforce/apex/ConciergeController.criarLead';
import atualizarLead from '@salesforce/apex/ConciergeController.atualizarLead';
import obterCanaisAtendimento from '@salesforce/apex/ConciergeController.obterCanaisAtendimento';
import criarReiteracaoEAssociarCorretor from '@salesforce/apex/ConciergeController.criarTaskReiteracaoeAssociarCorretor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import criarTaskReiteracaoSalesforce from '@salesforce/apex/ConciergeController.criarTaskReiteracao'
import obterLeadsPorInformacoesConcierge from '@salesforce/apex/ConciergeController.obterLeadsPorInformacoesConcierge';
import criarTaskReiteracao from '@salesforce/apex/ConciergeController.criarTaskReiteracao'
import obterOrigens from '@salesforce/apex/ConciergeController.obterOrigens';
import obterRoletasLeadsVigentes from '@salesforce/apex/ConciergeController.obterRoletasLeadsVigentes';

const TELA_FORMULARIO = 'FORMULARIO';
const TELA_CLIENTE_NAO_ENCONTRADO = 'CLIENTE_NAO_ENCONTRADO';
const TELA_CLIENTE_ENCONTRADO = 'CLIENTE_ENCONTRADO';
const TELA_CRIAR_CLIENTE = 'CRIAR_CLIENTE';
const TELA_DISTRIBUICAO = 'DISTRIBUICAO';
const TELA_INICIO = 'INICIO';
const TELA_DISTRIBUICAO_REALIZADA = 'DISTRIBUICAO_REALIZADA';
const TELA_LEAD_ENCAMINHADO = 'LEAD_ENCAMINHADO';
const TELA_CRIAR_REITERACAO = 'CRIAR_REITERACAO';
const TELA_FINAL_CONCLUSAO_CORRETOR = 'FINAL_CONCLUSAO_CORRETOR';

export default class Concierge extends LightningElement {
    @track formulario = {
        tipoPessoa: '',
        nome: '',
        email: '',
        origem: '',
        canal: '',
        mostrarCelular: false,
        mobilePhone: '',
        mostrarTelefone: false,
        phone: '',
        mostrarRazaoSocial: false,
        razaoSocial: '',
        nomeRepresentante: '',
        celularRepresentante: '',
        corretor: "",
        idRoletaLeads: null
    };

    @track mostrarFormulario = false;
    @track leadSelecionado = {};
    @track leadExistente = [];
    nomeCorretor;

    @track tipoPessoaSelecionado;
    @track forms = {
        nome: '',
        email: '',
        celular: ''
    }
   
    leads = [];
    canais = [];
    origens = [];
    roletasLeads = [];

    telaAtual = TELA_FORMULARIO;
    tela = {
        inicio: TELA_INICIO,
        formulario: TELA_FORMULARIO,
        clienteNaoEncontrado: TELA_CLIENTE_NAO_ENCONTRADO,
        clienteEncontrado: TELA_CLIENTE_ENCONTRADO,
        criarCliente: TELA_CRIAR_CLIENTE,
        distribuicao: TELA_DISTRIBUICAO,
        distribuicaoRealizada: TELA_DISTRIBUICAO_REALIZADA,
        leadEnchaminhado : TELA_LEAD_ENCAMINHADO,
        criarReiteracao: TELA_CRIAR_REITERACAO,
        finalConcluicaoCorretor: TELA_FINAL_CONCLUSAO_CORRETOR
    };

    get telaFinalConclusaoCorretor() {
        return this.telaAtual === this.tela.finalConcluicaoCorretor;
    }
    get telaInicio() {
        return this.telaAtual === this.tela.inicio;
    }

    get telaFormulario() {
        return this.telaAtual === this.tela.formulario;
    }

    get telaClienteNaoEncontrado() {
        return this.telaAtual === this.tela.clienteNaoEncontrado;
    }

    get telaClienteEncontrado() {
        return this.telaAtual === this.tela.clienteEncontrado;
    }

    get telaCriarCliente() {
        return this.telaAtual === this.tela.criarCliente;
    }

    get telaDistribuicao() {
        return this.telaAtual === this.tela.distribuicao;
    }

    get telaDistribuicaoRealizada() {
        return this.telaAtual === this.tela.distribuicaoRealizada;
    }

    get telaLeadEncaminhado() {
        return this.telaAtual === this.tela.leadEnchaminhado
    }

    get telaCriarReiteracao() { 
        return this.telaAtual === this.tela.criarReiteracao;
    }
    connectedCallback() {
        this.obterOrigens();
        this.obterCanaisAtendimento();
        this.addEventListener('criarTaskReiteracao', this.handleCriarTaskReiteracao.bind(this));
    }

    obterOrigens() {
        obterOrigens()
            .then(origens => {
                this.origens = Object.keys(origens).map(opcao => {
                    return {
                        label: origens[opcao],
                        value: opcao
                    };
                });
            })
            .catch(erro => console.log('Erro ao obter origens: ' + erro));
    }

    obterCanaisAtendimento() {
        obterCanaisAtendimento()
            .then(canais => {
                this.canais = Object.keys(canais).map(opcao => {
                    return {
                        label: canais[opcao],
                        value: opcao
                    };
                });
            })
            .catch(erro => console.log('Erro ao obter canais de atendimento: ' + erro));
    }

    handleMudancaTela(event) {
        this.telaAtual = event.detail ? event.detail.tela : event.tela;
        this.formulario.tipoPessoa = this.tipoPessoaSelecionado === 'fisica' ? 'Física' : 'Jurídica';
        if (event.detail && event.detail.nomeCorretor) {
            this.nomeCorretor = event.detail.nomeCorretor;
        }
    
    }
    handleTipoPessoaAlterado(event) {
        this.tipoPessoaSelecionado = event.detail.tipoPessoa;

        if (this.tipoPessoaSelecionado) {
            this.formulario.tipoPessoa = this.tipoPessoaSelecionado === 'fisica' ? 'Física' : 'Jurídica';
            this.mostrarFormulario = true;
        }
    }

    handleMudancaFormulario(event) {
        this.formulario[event.detail.target.dataset.name] = event.detail.target.value;
        this.forms[event.detail.target.dataset.name] = event.detail.target.value;
    }
    handleConsultarLeads(event) {
        let isJuridica = this.tipoPessoaSelecionado !== 'fisica';
    
        console.log("JSON " + JSON.stringify(this.formulario));
        obterLeadsPorInformacoesConcierge({ 
            celular:this.formulario.celular, 
            email:this.formulario.email, 
            isJuridica:isJuridica,
            phone:this.formulario.telefone
        })
        .then(leads => {
            this.leads = JSON.parse(leads);
    
            this.handleMudancaTela({
                detail: {
                    tela: this.leads.length > 0
                        ? event.detail.telaClienteEncontrado
                        : event.detail.telaClienteNaoEncontrado
                }
            });
        })
        .catch(erro => {
            console.error('Erro ao obter leads: ' + JSON.stringify(erro));
        });
    }

    handleCriarLead(event) {
        
        const { formulario } = event.detail; 

       
        
        this.formulario.nome = formulario.nome || '';
        this.formulario.email = formulario.email || '';
        this.formulario.origem = formulario.origem || '';
        this.formulario.canal = formulario.canal || '';
        this.formulario.mobilePhone = formulario.mobilePhone || '';
        this.formulario.phone = formulario.phone || '';
        this.formulario.razaoSocial = formulario.razaoSocial || '';
        this.formulario.corretor = formulario.corretor || '';
        this.formulario.nomeRepresentante = formulario.nomeRepresentante || '';
        this.formulario.celularRepresentante = formulario.celularRepresentante || '';
        
        obterRoletasLeadsVigentes()
            .then(roletasLeads => {
                this.roletasLeads = JSON.parse(roletasLeads);
                this.handleMudancaTela(event);
            })
            .catch(erro => console.log('Erro ao obter roletasLeads validas: ' + erro));
    }
    
    
   
    handleSalvarCorretor(event) {
        const corretorId = event.detail.corretorId;
    }

    salvar(event){
       
    }

    handleDistribuirLeads(event) {
        obterRoletasLeadsVigentes()
        .then(roletasLeads => {
            this.roletasLeads = JSON.parse(roletasLeads);

            this.handleMudancaTela(event);
        })
        .catch(erro => console.log('Erro ao obter roletasLeads validas: ' + erro));
    }

    handleConfirmarDistribuicao(event) {
        let leadsParaAtualizar = [];
        const corretorId = event.detail.idCorretor; 
        const reiteracao = event.detail.reiteracao;
        const nomeCorretor = event.detail.nomeCorretor;


        if(reiteracao == true){
           criarTarefaEAssociarCorretor(corretorId , this.formulario)
        }
    

        this.formulario.corretor = corretorId;
        this.formulario.tipoPessoa = this.tipoPessoaSelecionado === 'fisica' ? 'Física' : 'Jurídica';
    


        if (this.formulario.leads && this.formulario.leads.length > 0) {
            leadsParaAtualizar.push({
                id: this.formulario.leads[0].id,
                idRoleta: this.formulario.idRoletaLeads
            });
    
            atualizarLead({ formulario: leadsParaAtualizar })
                .then(() => {
                    this.handleMudancaTela(event);
                })
                .catch(error => {
                    console.error('Erro ao atualizar lead:', error);
                });
        } else {
           
            if (this.formulario.corretor != null) {
                this.formulario.idRoletaLeads = null;
            }

            console.log('Criando lead com os seguintes dados: ' + JSON.stringify(this.formulario));
        
            criarLead({ formulario: this.formulario })
                .then(() => {
                    this.formulario.nome = '';
                    this.formulario.email = '';
                    this.formulario.celular = '';
                    this.formulario.phone = '';

                    console.log("JSON DE CRIAR LEAD " + JSON.stringify(this.formulario));
                    if (this.formulario.corretor != null) {
                        this.handleMudancaTela({ tela: 'FINAL_CONCLUSAO_CORRETOR' });
                        
                    } else {
                        this.handleMudancaTela(event);
                    }
                })
                .catch(error => {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao criar lead: ' + error.body.message,
                        variant: 'error'
                    }));
                    console.error('Erro ao criar lead:', error);
                });
        }
    }

    criarTarefaEAssociarCorretor(idCorretor, formulario) {
    }
    handleCriarTaskReiteracao(event) {
        const { lead, nomeCorretor } = event.detail;
        this.leadSelecionado = lead; 
        this.nomeCorretor = nomeCorretor;
    
        const params = {
            lead: lead,
            nomeCorretor: nomeCorretor
        };
    

        
        criarTaskReiteracao({ jsonData: JSON.stringify(params), roletaId: this.roletaId })
            .then(() => {
                this.handleMudancaTela({tela: 'LEAD_ENCAMINHADO'});
            })
            .catch(error => {
                console.error('Erro ao criar reiteração:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao criar reiteração: ' + error.body.message,
                    variant: 'error'
                }));
            });
    }
    

    handleReiterarLeadCorretor(event){
        const { idCorretor, lead } = event.detail;
        const jsonLead = JSON.stringify(lead);

        criarReiteracaoEAssociarCorretor({ jsonData: jsonLead, corretorId: idCorretor })
        .then(() => {
            this.handleMudancaTela({tela: 'FINAL_CONCLUSAO_CORRETOR'});
        })
        .catch(error => {
            console.error('Erro ao criar reiteração:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: 'Erro ao criar reiteração: ' + error.body.message,
                variant: 'error'
            }));
        });
    }
    handleTelaCorretor(event){
        const { lead, nomeCorretor } = event.detail;
        this.leadSelecionado = lead; 
        this.nomeCorretor = nomeCorretor;

        const params = {
            lead: lead,
            nomeCorretor: nomeCorretor
        };
    
        console.log("Criando tarefa de reiteração com os seguintes parâmetros: " + JSON.stringify(params));
        
        criarTaskReiteracao({ jsonData: JSON.stringify(params), roletaId: this.roletaId })
            .then(() => {
                this.handleMudancaTela({tela: 'LEAD_ENCAMINHADO'});
            })
            .catch(error => {
                console.error('Erro ao criar reiteração:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao criar reiteração: ' + error.body.message,
                    variant: 'error'
                }));
            });
    }

    handleTelaReiteracao(event){
        this.leadExistente = event.detail;
        obterRoletasLeadsVigentes()
        .then(roletasLeads => {
            this.handleMudancaTela({tela: 'CRIAR_REITERACAO'});
            this.roletasLeads = JSON.parse(roletasLeads);
        })
        .catch(erro => console.log('Erro ao obter roletasLeads validas: ' + erro));
    }
    
    handleCorretorReiteracao(event) {
        // Extrair lead e corretor do JSON
        const { lead, corretor } = event.detail;
    
        const leadData = lead?.lead || lead;  
        const corretorData = corretor;
        criarReiteracaoEAssociarCorretor({ params: leadData, corretorId: corretorData })
        .then(() => {
            
            this.handleMudancaTela({tela: 'FINAL_CONCLUSAO_CORRETOR'});
        })
        .catch(error => {
            console.error('Erro ao criar reiteração:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro',
                message: 'Erro ao criar reiteração: ' + error.body.message,
                variant: 'error'
            }));
        });
    }
    
    reiterarLead(event) {
        const { roletaId, lead } = event.detail;
      
    
        const jsonLead = JSON.stringify(lead);

        console.log("Criando tarefa de reiteração com os seguintes parâmetros: " + JSON.stringify(jsonLead));
        console.log("RoletaId: " + roletaId);

        criarTaskReiteracaoSalesforce({ jsonData: jsonLead, roletaId: roletaId })
            .then(() => {
                this.handleMudancaTela({tela: 'DISTRIBUICAO_REALIZADA'});
            })
            .catch(error => {
                console.error('Erro ao criar reiteração:', error);
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao criar reiteração: ' + error.body.message,
                    variant: 'error'
                }));
            });
    }
    
    
    
}