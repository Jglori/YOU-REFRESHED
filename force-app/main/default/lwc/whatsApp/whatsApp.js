import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import { CurrentPageReference } from 'lightning/navigation';
import obterLeadPorId from "@salesforce/apex/WhatsAppController.obterLeadPorId";
import obterMensagensPorChaveExternaCliente from "@salesforce/apex/WhatsAppController.obterMensagensPorChaveExternaCliente";
import controlarDialogo from "@salesforce/apex/WhatsAppController.controlarDialogo";
import enviarMensagem from "@salesforce/apex/WhatsAppController.enviarMensagem";
import enviarMidia from "@salesforce/apex/WhatsAppController.enviarMidia";
import enviarTemplatePadrao from "@salesforce/apex/WhatsAppController.enviarTemplatePadrao";
import templateModal from 'c/templateModal';

export default class WhatsApp extends LightningElement {
    @api recordId;
    @track lead = {};
    @track mensagens = [];
    channelName = '/event/EventoWhatsApp__e';
    carregando = false;
    mensagemTexto = null;
    subscription = {};
    intervalId;

    /**
     *  Obtém o 'recordId' da URL se ele não estiver presente no componente
     */
    @wire(CurrentPageReference)
    getPageReference(pageRef) {
        if (!this.recordId && pageRef && pageRef.state && pageRef.state.recordId) {
            this.recordId = pageRef.state.recordId;
            this.obterLead();
        }
    }

    /**
     * Verifica se o diálogo com o lead está em andamento
     */ 
    get dialogoEmAndamento() {
        return !Boolean(this.lead.fimDialogo);
    }

    /**
     * Método executado quando o componente é conectado ao DOM. Inicializa
     * o componente e ativa a verificação periódica de novas mensagens.
     */
    connectedCallback() {
        this.initializeComponent();
    }

    /**
     * Inicializa o componente, carregando as informações do lead e as mensagens
     * associadas, e realiza a assinatura no canal para eventos do WhatsApp.
     */
    async initializeComponent() {
        await this.obterLead();
        await this.obterMensagensCarregando();
        this.handleSubscribe();
        this.intervalId = setInterval(() => this.verificarNovasMensagens(), 10000);
    }

    /**
     * Método chamado quando o componente é renderizado no DOM
     */
    renderedCallback() {
        this.apresentarUltimasMensagens();
    }

    /**
     * Rolagem automática para a última mensagem no chat
     */ 
    apresentarUltimasMensagens() {
        const chat = this.template.querySelector('[data-id="chat"]');
        
        // Verifica se o chat é encontrado e é um elemento válido
        if (chat instanceof HTMLElement) {
            // console.log("Elemento de chat encontrado:", chat);
    
            // // Configura o MutationObserver para detectar mudanças no conteúdo do chat
            // const observer = new MutationObserver(() => {
            //     chat.scrollTop = chat.scrollHeight; // Rolagem até a última mensagem
            // });
    
            // // Observa mudanças no número de filhos do elemento chat
            // observer.observe(chat, { childList: true });
    
            // // Realiza a rolagem inicial e desconecta o observador
            // chat.scrollTop = chat.scrollHeight;
            // observer.disconnect();
        } else {
            console.error("Elemento de chat não encontrado ou não é um HTMLElement:", chat);
        }
    }
    
    /**
     * Ativa o estado de carregamento, chama o método para obter as mensagens,
     * e desativa o estado de carregamento ao final.
     */
    async obterMensagensCarregando() {
        this.carregando = true;
        await this.obterMensagens();
        this.carregando = false;
    }

    /**
     * Obtém as mensagens associadas ao lead utilizando a chave externa
     * do WhatsApp e exibe mensagens de erro em caso de falha.
     */
    async obterMensagens() {
        try {
            this.mensagens = await this.obterMensagensPorChaveExternaCliente(this.lead.chaveExternaWhatsApp);
        } catch (erro) {
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
    }

    /**
     * Chama o método Apex para obter as mensagens usando a chave externa do cliente
     */ 
    obterMensagensPorChaveExternaCliente(chaveExternaCliente) {
        return obterMensagensPorChaveExternaCliente({ chaveExternaCliente })
            .then(resultado => JSON.parse(resultado))
            .catch(erro => {
                console.error('Erro ao obter mensagens:', erro);
                throw erro;
            });
    }

    /**
     * Obtém os dados do lead usando o 'recordId' atual e exibe mensagens de
     * erro em caso de falha.
     */
    async obterLead() {
        this.carregando = true;
        try {
            this.lead = await this.obterLeadPorId(this.recordId);
        } catch (erro) {
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
        this.carregando = false;
    }

    /**
     * Chama o método Apex para obter o lead pelo ID
     */ 
    obterLeadPorId(idLead) {
        return obterLeadPorId({ idLead })
            .then(resultado => JSON.parse(resultado))
            .catch(erro => {
                console.error('Erro ao obter lead:', erro);
                throw erro;
            });
    }

    /**
     * Controla o andamento do diálogo com o lead, atualizando o status de fim de diálogo.
     */
    async handleControlarDialogo() {
        this.carregando = true;
        try {
            this.lead = await this.controlarDialogo(this.recordId);
        } catch (erro) {
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
        this.carregando = false;
    }

    /**
     * Chama o método Apex para controlar o diálogo
     */ 
    controlarDialogo(idLead) {
        return controlarDialogo({ idLead })
            .then(resultado => JSON.parse(resultado))
            .catch(erro => {
                console.error('Erro ao controlar diálogo:', erro);
                throw erro;
            });
    }

    /**
     * Captura a mensagem de texto do input
     */
    handleAlteracaoMensagemTexto(event) {
        this.mensagemTexto = event.target.value;
    }

    /**
     * Envia uma nova mensagem de texto para o lead e atualiza o histórico de mensagens.
     */
    async handleEnviarMensagem() {
        if (!this.mensagemTexto || !this.lead.chaveExternaWhatsApp) {this.apresentarMensagem('Erro', 'Não é possivel enviar mensagem.', 'error'); return};
        try {
            const novaMensagem = await this.enviarMensagem(this.recordId, this.mensagemTexto);
            this.mensagens = [...this.mensagens, novaMensagem];
            this.mensagemTexto = null;
            this.apresentarUltimasMensagens();
        } catch (erro) {
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
    }

    /**
     * Chama o método Apex para enviar a mensagem de texto
     */
    enviarMensagem(idLead, mensagemTexto) {
        return enviarMensagem({ idLead, mensagemTexto })
            .then(resultado => JSON.parse(resultado))
            .catch(erro => {
                console.error('Erro ao enviar mensagem:', erro);
                throw erro;
            });
    }

    /**
     * Método responsável pelo envio de template padrão para o cliente. O template
     * é enviado apenas se o lead possuir informações mínimas necessárias para
     * envio do template.
     * IMPORTANTE: Verifique os parâmetros que o template exige antes de enviar.
     */
    async handleEnviarTemplatePadrao() {
        await this.obterLead();
        const camposFaltantes = [
            this.lead.primeiroNome === null ? 'Primeiro Nome' : null,
            this.lead.empreendimentoInteresse === null ? 'Empreendimento de Interesse' : null,
            this.lead.celular === null ? 'Celular' : null
        ].filter(campo => campo !== null);
        if (camposFaltantes.length > 0) {
            const mensagemErro = `Verifique ${camposFaltantes.length > 1 ? 'os campos' : 'o campo'}: ${camposFaltantes.join(', ')}`;
            this.apresentarMensagem('Lead não possui informações suficientes para envio de template.', mensagemErro, 'error');
            return;
        }
        try {
            await enviarTemplatePadrao({ idLead: this.recordId, nomeTemplate: 'contatolead' });
            this.apresentarMensagem('Sucesso', 'Template enviado com sucesso', 'success');
        } catch (erro) {
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
    }
    

    /**
     * Trata o envio de arquivos de mídia
     */
    handleEnviarMidia(event) {
        Array.from(event.target.files).forEach(arquivo => {
            const leitor = new FileReader();
            leitor.onload = (e) => this.carregarArquivo(e, arquivo);
            leitor.readAsDataURL(arquivo);
        });
    }

    /**
     * Converte o arquivo para Base64 e envia para o servidor.
     */
    async carregarArquivo(event, arquivo) {
        this.carregando = true;
        try {
            const base64Data = this.obterBase64(event.target.result);
            const mensagemEnviada = await this.enviarMidia(this.recordId, arquivo.type, arquivo.name, base64Data);
            this.mensagens = [...this.mensagens, mensagemEnviada];
            this.apresentarUltimasMensagens();
        } catch (erro) {
            console.error('Erro ao carregar arquivo:', erro);
            this.apresentarMensagem('Erro', erro.body.message, 'error');
        }
        this.carregando = false;
    }

    /**
     * Chama o método Apex para enviar a mídia
     */
    enviarMidia(idLead, tipoArquivo, nomeArquivo, corpoArquivo) {
        return enviarMidia({ idLead, tipoArquivo, nomeArquivo, corpoArquivo })
            .then(resultado => JSON.parse(resultado))
            .catch(erro => {
                console.error('Erro ao enviar mídia:', erro);
                throw erro;
            });
    }

    /**
     *  Obtém o conteúdo Base64 do arquivo carregado
     */
    obterBase64(conteudo) {
        return conteudo.match(/,(.*)$/)[1];
    }

    /**
     * Inscreve o componente no canal de eventos do WhatsApp
     */
    handleSubscribe() {
        const thisReference = this;
        subscribe(this.channelName, -1, function (mensagem) {
            thisReference.verificarNovasMensagens();
        }).then(response => {
            this.subscription = response;
        });
    }

    /**
     * Verifica se há novas mensagens no WhatsApp e as atualiza no componente
     */
    async verificarNovasMensagens() {
        const mensagensAtuais = this.mensagens;
        await this.obterMensagens();
        if (mensagensAtuais.length !== this.mensagens.length) {
            this.apresentarUltimasMensagens();
        }
    }

    /**
     * Exibe um toast de notificação com o status da operação
     */
    apresentarMensagem(titulo, mensagem, variacao) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: titulo,
                message: mensagem,
                variant: variacao
            })
        );
    }

    /**
     * Limpa o intervalo e remove a assinatura do canal de eventos ao desconectar o componente
     */
    disconnectedCallback() {
        clearInterval(this.intervalId);
        unsubscribe(this.subscription, () => {});
    }

    async handleSelecionarTemplate() {
        const result = await templateModal.open({
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            recordId: this.recordId
        });
        // console.log(result);
    }
}