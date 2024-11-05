import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import obterLeadsEmTrabalho from '@salesforce/apex/OmnichannelController.obterLeadsEmTrabalho';
import obterLeadsEmNovo from '@salesforce/apex/OmnichannelController.obterLeadsEmNovo';
import alterarSituacao from '@salesforce/apex/OmnichannelController.alterarSituacao';
import obterCanaisAtendimento from '@salesforce/apex/OmnichannelController.obterCanaisAtendimento';
import obterSituacoes from '@salesforce/apex/OmnichannelController.obterSituacoes';
import obterUsuario from '@salesforce/apex/OmnichannelController.obterUsuario';
import aceitarLead from '@salesforce/apex/OmnichannelController.aceitarLead';
import rejeitarLead from '@salesforce/apex/OmnichannelController.rejeitarLead';
import selecionarCanais from '@salesforce/apex/OmnichannelController.selecionarCanais';
import isguest from '@salesforce/user/isGuest';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled }  from 'lightning/empApi';


export default class Omnichannel extends NavigationMixin(LightningElement) {
    @track usuario = {};
    @track leadsEmNovo = [];
    @track leadsEmTrabalho = [];
    carregando = false;
    carregandoLeadsEmNovo = false;
    carregandoLeadsEmTrabalho = false;
    apresentarPainel = false;
    apresentarConfiguracoes = false;
    canaisAtendimento = {};
    canaisAtendimentoParaExibir = [];
    todosCanaisHabilitados = false;
    situacoes = [];

    channelName = '/event/OmnichannelRefresh__e';

    get online() {
        return this.usuario.situacao === 'Online';
    }

    get indisponivel() {
        return this.usuario.situacao === 'Indisponível';
    }

    get offline() {
        return this.usuario.situacao === 'Offline';
    }

    get novo() {
        return `Novo (${this.leadsEmNovo.length})`;
    }

    get trabalho() {
        return `Trabalho (${this.leadsEmTrabalho.length})`;
    }

  
    async connectedCallback() {
        await this.handleObterUsuario();
        await this.handleObterSituacoes();
        await this.handleObterCanaisAtendimento();
        //  this.usuario.situacao = 'Offline'
        this.handleObterLeadsEmNovo();
        this.handleObterLeadsEmTrabalho();
        if(!isguest){
            this.handleSubscribe();
        }
    }

    getLeadsEmTrabalho(){
        this.handleObterLeadsEmTrabalho();
    }
    getLeadsEmNovo(){
        this.handleObterLeadsEmNovo();
    }
  
    async handleObterLeadsEmTrabalho() {
        this.carregandoLeadsEmTrabalho = true;

        try {
            this.leadsEmTrabalho = await this.obterLeadsEmTrabalho();

            this.leadsEmTrabalho = this.leadsEmTrabalho.map(lead => ({
                ...lead,
                createdDateFormatted: this.formatCreatedDate(lead.CreatedDate)
            }));


            this.leadsEmTrabalho.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));

            console.log(this.leadsEmTrabalho);
            
        } catch (erro) {
            console.log(erro);
        }

        this.carregandoLeadsEmTrabalho = false;
    }




    async obterLeadsEmTrabalho() {
        return new Promise((resolve, reject) => {
            obterLeadsEmTrabalho()
                .then(resultado => resolve(JSON.parse(resultado)))
                .catch(erro => reject(erro));
        });
    }



 
    async handleObterLeadsEmNovo() {
        this.carregandoLeadsEmNovo = true;

        try {
            this.leadsEmNovo = await this.obterLeadsEmNovo();

            this.leadsEmNovo = this.leadsEmNovo.map(lead => ({
                 ...lead,
                 createdDateFormatted: this.formatCreatedDate(lead.CreatedDate)
            }));

            
            this.leadsEmNovo.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
        } catch (erro) {
            console.log(erro);
        }

        this.carregandoLeadsEmNovo = false;
    }

    async handleObterLeadsEmNovo() {
        this.carregandoLeadsEmNovo = true;

        try {
            this.leadsEmNovo = await this.obterLeadsEmNovo();

            this.leadsEmNovo = this.leadsEmNovo.map(lead => ({
                 ...lead,
                 createdDateFormatted: this.formatCreatedDate(lead.CreatedDate)
            }));

            
            this.leadsEmNovo.sort((a, b) => new Date(b.CreatedDate) - new Date(a.CreatedDate));
        } catch (erro) {
            console.log(erro);
        }

        this.carregandoLeadsEmNovo = false;
    }

  
    formatCreatedDate(createdDate) {
        const createdDateObj = new Date(createdDate);
        const now = new Date();
        const timeDiff = now - createdDateObj;
        const daysDiff = Math.floor(timeDiff / (1000 * 60 * 60 * 24));
        return daysDiff === 0 ? 'Lead criado hoje' : `${daysDiff} dias atrás`;
    }

    
    async obterLeadsEmNovo() {
        return new Promise((resolve, reject) => {
            obterLeadsEmNovo()
                .then(resultado => resolve(JSON.parse(resultado)))
                .catch(erro => reject(erro));
        });
    }





    async handleAceitarLead(event) {
        this.carregandoLeadsEmNovo = true;

        try {
            this.leadsEmNovo = await this.aceitarLead(event.target.dataset.id);

            this.handleObterLeadsEmTrabalho();
        } catch (erro) {
            console.log(erro);
        }

        this.carregandoLeadsEmNovo = false;
    }

    async aceitarLead(idLead) {
        return new Promise((resolve, reject) => aceitarLead({ idLead })
            .then(resultado => resolve(JSON.parse(resultado)))
            .catch(erro => reject(erro))
        );
    }



    async handleRejeitarLead(event) {
        this.carregandoLeadsEmNovo = true;

        try {
            this.leadsEmNovo = await this.rejeitarLead(event.target.dataset.id);
            
        } catch (erro) {
            console.log(erro);
        }

        this.carregandoLeadsEmNovo = false;
    }

    async rejeitarLead(idLead) {
        return new Promise((resolve, reject) => rejeitarLead({ idLead })
            .then(resultado => resolve(JSON.parse(resultado)))
            .catch(erro => reject(erro))
        )
    }

    async handleObterCanaisAtendimento() {
        this.carregando = true;

        try {
            this.canaisAtendimento = await this.obterCanaisAtendimento();

            this.tratarCanaisAtendimento(this.canaisAtendimento);
        } catch (erro) {
            console.log(erro);
        }

        this.carregando = false;
    }

    tratarCanaisAtendimento(canaisAtendimento) {
        this.canaisAtendimentoParaExibir = Object.keys(canaisAtendimento).map(value => ({
            label: canaisAtendimento[value], 
            value, 
            selecionado: this.usuario.canaisAtendimento.includes(value)
        }));
        this.todosCanaisHabilitados = this.todosCanaisHabilitados || this.usuario.canaisAtendimento.length === Object.keys(canaisAtendimento).length;
    }




    obterCanaisAtendimento() {
        return new Promise((resolve, reject) => obterCanaisAtendimento()
            .then(resultado => resolve(resultado))
            .catch(erro => reject(erro))
        );
    }

    async handleObterSituacoes() {
        this.carregando = true;

        try {
            const situacoes = await this.obterSituacoes();

            this.tratarSituacoes(situacoes);
        } catch (erro) {
            console.log(erro);
        }

        this.carregando = false;
    }




    tratarSituacoes(situacoes) {
        this.situacoes = Object.keys(situacoes).map(value => ({ label: situacoes[value], value }));
    }

    obterSituacoes() {
        return new Promise((resolve, reject) => obterSituacoes()
            .then(resultado => resolve(resultado))
            .catch(erro => reject(erro))
        );
    }





    async handleObterUsuario() {
        this.carregando = true;

        try {
            this.usuario = await this.obterUsuario();
        } catch (erro) {
            console.log(erro);
        }

        this.carregando = false;
    }

    obterUsuario() {
        return new Promise((resolve, reject) => obterUsuario()
            .then(resultado => resolve(JSON.parse(resultado)))
            .catch(erro => reject(erro))
        );
    }


    async handleAlterarSituacao(event) {
        this.carregando = true;
    
        try {
            this.usuario = await this.alterarSituacao(event.target.value);
            location.reload();
        } catch (erro) {
            console.log(erro);
        }
    
        this.carregando = false;
    }


    async alterarSituacao(novaSituacao) {
        return new Promise((resolve, reject) => alterarSituacao({ novaSituacao })
            .then(resultado => resolve(JSON.parse(resultado)))
            .catch(erro => reject(erro))
        )
    }

    handleApresentarPainel() {
        this.apresentarPainel = !this.apresentarPainel;
    }

    handleApresentarConfiguracoes() {
        this.apresentarConfiguracoes = !this.apresentarConfiguracoes;
    }





    handleSelecionarCanal(event) {
        this.carregando = true;

        try {
            this.atualizarCanais(event);
            this.selecionarCanais(this.usuario.canaisAtendimento);
        } catch (erro) {
            console.log(erro);
        }

        this.carregando = false;
    }

    async selecionarCanais(canaisAtendimento) {
        return new Promise((resolve, reject) => selecionarCanais({ canaisAtendimento })
            .then(resultado => resolve(JSON.parse(resultado)))
            .catch(erro => reject(erro))
        );
    }

    atualizarCanais(event) {
        this.usuario.canaisAtendimento = this.usuario.canaisAtendimento.includes(event.target.dataset.name)
            ? this.usuario.canaisAtendimento.filter(canalAtendimento => canalAtendimento !== event.target.dataset.name)
            : [...this.usuario.canaisAtendimento, event.target.dataset.name];

        this.tratarCanaisAtendimento(this.canaisAtendimento);
    }

    handleHabilitarTodosCanais() {
        this.carregando = true;

        try {
            this.todosCanaisHabilitados = !this.todosCanaisHabilitados;

            this.atualizarTodosCanaisHabilitados();
            this.selecionarCanais(this.usuario.canaisAtendimento);
        } catch (erro) {
            console.log(erro);
        }

        this.carregando = false;
    }

    atualizarTodosCanaisHabilitados() {
        this.usuario.canaisAtendimento = this.todosCanaisHabilitados 
            ? Object.keys(this.canaisAtendimento)
            : [];

        this.tratarCanaisAtendimento(this.canaisAtendimento);
    }

    handleCliqueLead(event) {
       
        let leadId = event.currentTarget.dataset.id;

       
        console.log('Lead ID clicado:', leadId);

      
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: leadId,
                actionName: 'view'
            }
        });
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        console.log('Antes de invocar subscribe');

        const messageCallback = (response) => {
            console.log('evento recebido');

            this.handleObterLeadsEmNovo();
            this.handleObterLeadsEmTrabalho();
        };

        subscribe(this.channelName, -1, messageCallback).then((response) => {
            console.log(
                'Subscription request sent to: ',
                JSON.stringify(response.channel)
            );
            this.subscription = response;
        });
    }

    // Handles unsubscribe button click
    handleUnsubscribe() {
        // Invoke unsubscribe method of empApi
        unsubscribe(this.subscription, response => {
            console.log('Unsubscribed from channel: ', JSON.stringify(response));
        });
    }

    disconnectedCallback() {
        this.handleUnsubscribe();
    }
}