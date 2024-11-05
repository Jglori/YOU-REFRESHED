import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConciergeCriacao extends LightningElement {
    @api telaCancelar;
    @api telaCriar;
    @api origens;
    @api canais;
    @api formularioNovo;
    @api forms;
    @api tipoPessoa;

    @track formulario = {
        tipoPessoa: '',
        nome: '',
        email: '',
        origem: '',
        canal: '',
        mostrarCelular: false,
        mostrarNome: false,
        mobilePhone: '',
        mostrarTelefone: false,
        phone: '',
        mostrarRazaoSocial: false,
        razaoSocial: '',
        mostrarNomeRepresentante: false,
        nomeRepresentante: '',
        mostrarCelularRepresentante: false,
        celularRepresentante: ''
    };

    @track tipoPessoaOptions = [
        { label: 'Pessoa Física', value: 'fisica' },
        { label: 'Pessoa Jurídica', value: 'juridica' }
    ];

    @track mostrarCampos = true; // Sempre mostrar o formulário

    set tipoPessoa(value) {
        this._tipoPessoa = (value && value.toLowerCase()) || '';
        console.log("Tipo pessoa em concierge criação: " + this._tipoPessoa);
        this.updateCampos();
    }

    get tipoPessoa() {
        return this._tipoPessoa;
    }

    updateCampos() {
        if (this._tipoPessoa) {
            console.log("Tipo pessoa em update campos: " + this._tipoPessoa);
            this.atualizarExibicaoCampos(this._tipoPessoa);
        }
    }

    connectedCallback() {
        this.updateCampos();
    
        console.log("Forms em concierge criação:", JSON.stringify(this.forms));
        const celular = this.forms?.celular || '';
        const telefone = this.forms?.telefone || '';
        const razaoSocial = this.forms?.razaoSocial || '';
        console.log("Formulário novo em concierge criação:", JSON.stringify(this.formularioNovo)); // Debug
       
        this.formulario.mobilePhone = celular;
        this.formulario.phone = telefone;
        this.formulario.razaoSocial = razaoSocial;
        if (this.forms) {
            this.formulario = {
                ...this.formulario,
                nome: this.forms.nome || '',
                email: this.forms.email || '',
            };
        }
    
        if (this.formularioNovo) {
            this.formulario = {
                ...this.formulario,
                ...this.formularioNovo
            };
        } else {
            console.warn('formularioNovo está indefinido'); // Adicione uma mensagem de alerta
        }
    
        this.formulario.origem = this.origens && this.origens.length > 0 ? this.origens[0].value : '';
        this.formulario.canal = this.canais && this.canais.length > 0 ? this.canais[0].value : '';
    
        this.template.addEventListener('mudancaformulario', this.handleMudancaFormulario.bind(this));
    }
    
    

    handleMudancaFormulario(event) {
        const { nome, email, celular } = event.detail;
    
        console.log("Dados recebidos no handleMudancaFormulario:", event.detail); // Debug
    
        this.formulario = {
            ...this.formulario,
            nome: nome || this.formulario.nome,
            email: email || this.formulario.email,
            mobilePhone: celular || this.formulario.mobilePhone // Certifique-se de que a propriedade é mobilePhone
        };
    
        console.log("Formulário após atualização:", this.formulario); // Debug
        this.updateCampos();
    }
    
    handleChange(event) {
        const { name, value } = event.target;
        console.log(`Alterando campo ${name} para ${value}`); // Debug
    
        this.formulario = {
            ...this.formulario,
            [name]: value
        };
    
        console.log("Formulário após alteração:", this.formulario); // Debug
        this.handleMudancaFormulario({ detail: this.formulario });
    }
    
    handleAtualizarDados(event) {
        const { formulario } = event.detail;
        this.formulario = { ...this.formulario, ...formulario };
        this.updateCampos();
    }

    handleChangeTipoPessoa(event) {
        const tipoPessoa = event.detail.value;
        this.tipoPessoa = tipoPessoa;
    
        console.log("Tipo de pessoa selecionado:", tipoPessoa); // Debug
    
        this.formulario.mobilePhone = tipoPessoa === 'fisica' ? this.forms?.celular || '' : '';
        this.formulario.phone = tipoPessoa === 'juridica' ? this.forms?.telefone || '' : '';
        this.formulario.razaoSocial = tipoPessoa === 'juridica' ? this.forms?.razaoSocial || '' : '';
        this.formulario.nomeRepresentante = tipoPessoa === 'juridica' ? this.forms?.nomeRepresentante || '' : '';
        this.formulario.celularRepresentante = tipoPessoa === 'juridica' ? this.forms?.celularRepresentante || '' : '';
    
        console.log("Formulário após mudança de tipo de pessoa:", this.formulario); // Debug
    
        this.updateCampos();
    }
    
    
    atualizarExibicaoCampos(thisTipoPessoa) {
        console.log("Tipo pessoa em atualizar exibicao campos: " + thisTipoPessoa);
        if (thisTipoPessoa === 'fisica') {
            this.formulario.mostrarCelular = true;
            this.formulario.mostrarNome = true;
            this.formulario.mostrarTelefone = false;
            this.formulario.mostrarRazaoSocial = false;
            this.formulario.mostrarNomeRepresentante = false;
            this.formulario.mostrarCelularRepresentante = false;
        } else if (thisTipoPessoa === 'juridica') {
            this.formulario.mostrarCelular = false;
            this.formulario.mostrarTelefone = true;
            this.formulario.mostrarRazaoSocial = true;
            this.formulario.mostrarNomeRepresentante = true;
            this.formulario.mostrarCelularRepresentante = true;
        } else {
            this.formulario.mostrarCelular = false;
            this.formulario.mostrarTelefone = false;
            this.formulario.mostrarRazaoSocial = false;
            this.formulario.mostrarNomeRepresentante = false;
            this.formulario.mostrarCelularRepresentante = false;
        }
    }
    
    handleCriarLead() {
        console.log('Formulário:', JSON.stringify(this.formulario));
        
        // Inicializa uma lista para coletar mensagens de erro
        let mensagensDeErro = [];
        
        // Coleta as mensagens de erro para cada campo
        let razaoSocialErro = this.razaoSocialPreenchido(this.formulario.razaoSocial);
        let celularErro = this.celularPreenchido(this.formulario.mobilePhone);
        let emailErro = this.emailPreenchido(this.formulario.email);
        let canalErro = this.canalPreenchido(this.formulario.canal);
        let nomeErro = this.nomePreenchido(this.formulario.nome);
        let nomeRepresentanteErro = this.nomeRepresentantePreenchido(this.formulario.nomeRepresentante);
        let celularRepresentanteErro = this.celularRepresentantePreenchido(this.formulario.celularRepresentante);
        let telefoneErro = this.telefonePreenchido(this.formulario.phone);
        
        // Adiciona as mensagens de erro à lista dependendo das condições
        if (this.formulario.razaoSocial.trim() === '' || this.formulario.phone.trim() === '') {
            if (celularErro) mensagensDeErro.push(`Celular: ${celularErro}`);
            if (emailErro) mensagensDeErro.push(`Email: ${emailErro}`);
            if (canalErro) mensagensDeErro.push(`Canal: ${canalErro}`);
            if (nomeErro) mensagensDeErro.push(`Nome: ${nomeErro}`);
        } else if (this.formulario.mobilePhone.trim() === '') {
            if (razaoSocialErro) mensagensDeErro.push(`Razão Social: ${razaoSocialErro}`);
            if (emailErro) mensagensDeErro.push(`Email: ${emailErro}`);
            if (canalErro) mensagensDeErro.push(`Canal: ${canalErro}`);
            if (nomeRepresentanteErro) mensagensDeErro.push(`Nome do Representante: ${nomeRepresentanteErro}`);
            if (celularRepresentanteErro) mensagensDeErro.push(`Celular do Representante: ${celularRepresentanteErro}`);
            if (telefoneErro) mensagensDeErro.push(`Telefone: ${telefoneErro}`);
        }
        
        // Se houver mensagens de erro, exibe-as
        if (mensagensDeErro.length > 0) {
            this.apresentarMensagem('Atenção', `Por favor, preencha todos os campos obrigatórios e verifique se os dados estão no formato correto. Corrija os erros e tente novamente: \n${mensagensDeErro.join('\n')}`, 'warning');
            return;
        }
        
        this.dispatchEvent(new CustomEvent('criarlead', {
            detail: { tela: this.telaCriar, formulario: this.formulario }
        }));
    }
    
   
    
    nomePreenchido(nome) {
        if(nome == '') {
            return 'Nome não preenchido'
        }
        else if(nome.length < 3) { 
            return 'Nome deve ter pelo menos 3 caracteres';
        }
        if (nome.length > 250) {
            return 'Nome não pode ter mais de 250 caracteres';
        }
        return '';
    }
    
    emailPreenchido(email) {
        if (email == '') {
            return 'Email não preenchido';
        }
        const regex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
        if (!regex.test(email)) {
            return 'Email não está em um formato válido';
        }
        return '';
    }
    
    celularPreenchido(celular) {
          if (celular === '') {
                return 'Celular não preenchido';
            }
            const regex = /^\(?\d{2}\)?[\s-]?9\d{4}[\s-]?\d{4}$/;
            if (!regex.test(celular)) {
                return 'Celular não está em um formato válido';
            }
        
        return '';
    }
    
    telefonePreenchido(telefone) {
            if (telefone == '') {
                return 'Telefone não preenchido';
            }
            const regex = /^\(?\d{2}\)?[\s-]?\d{4}[\s-]?\d{4}$/;
            if (!regex.test(telefone)) {
                return 'Telefone não está em um formato válido';
            }
        
        return '';
    }
    
    razaoSocialPreenchido(razaoSocial) {
        // Verifica se o campo está vazio
        if (!razaoSocial) {
            return 'Razão Social não preenchida';
        }
    
        if (razaoSocial.length < 3) {
            return 'Razão Social deve ter pelo menos 3 caracteres';
        }
    
        return '';
    }
    
    
    nomeRepresentantePreenchido(nomeRepresentante) {
        if (nomeRepresentante === '') {
            return 'Nome do representante não preenchido';
        }
        else if(nomeRepresentante.length < 3) { 
            return 'Nome do representante deve ter pelo menos 3 caracteres';
        }
        if (nomeRepresentante.length > 250) {
            return 'Nome do representante não pode ter mais de 250 caracteres';
        }
        return '';
    }
    
    celularRepresentantePreenchido(celularRepresentante) {
        if (celularRepresentante === '') {
            return 'Celular do representante não preenchido';
        }

        const regex = /^\(?\d{2}\)?[\s-]?9\d{4}[\s-]?\d{4}$/;
        if (!regex.test(celularRepresentante)) {
            return 'Celular não está em um formato válido';
        }
    
        return '';
    }
    
    
    canalPreenchido(canal) {
        if (!canal) {
            return 'Canal não preenchido';
        }
        return '';
    }
    
    apresentarMensagem(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    

    handleCancelar() {
        console.log('Cancelando criação de lead');
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaCancelar }
        }));
    }
}