import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ConciergeFormulario extends LightningElement {
    @api tipoPessoa;
    @api telaClienteEncontrado;
    @api telaClienteNaoEncontrado;
    @api formulario;

    @track mostrarCamposFisica = false;
    @track mostrarCamposJuridica = false;
    @track celularError = false;
    @track telefoneError = false;
    @track emailError = false;

    get celularErrorClass() {
        return this.celularError ? 'slds-has-error' : '';
    }

    get telefoneErrorClass() {
        return this.telefoneError ? 'slds-has-error' : '';
    }

    get emailErrorClass() {
        return this.emailError ? 'slds-has-error' : '';
    }

    get celularErrorMessage() {
        return 'Campo Celular é obrigatório e deve conter 11 dígitos';
    }

    get telefoneErrorMessage() {
        return 'Campo Telefone é obrigatório e deve conter 10 dígitos';
    }

    get emailErrorMessage() {
        return 'Campo Email é obrigatório e deve ser um email válido';
    }

    set tipoPessoa(value) {
        this._tipoPessoa = value;
        this.updateCampos();
    }

    get tipoPessoa() {
        return this._tipoPessoa;
    }

    updateCampos() {
        this.mostrarCamposFisica = this.tipoPessoa === 'fisica';
        this.mostrarCamposJuridica = this.tipoPessoa === 'juridica';
    }

    handleChange(event) {
        this.dispatchEvent(new CustomEvent('mudancaformulario', {
            detail: event
        }));
    }

    handleConsultarLeads() {
        this.resetErrors();

        let valid = true;
        if (this.mostrarCamposFisica && (!this.formulario.celular || !this.validateCelular(this.formulario.celular))) {
            this.celularError = true;
            valid = false;
        }
        if (this.mostrarCamposJuridica && (!this.formulario.telefone || !this.validateTelefone(this.formulario.telefone))) {
            this.telefoneError = true;
            valid = false;
        }
        if (!this.formulario.email || !this.validateEmail(this.formulario.email)) {
            this.emailError = true;
            valid = false;
        }

        if (valid) {
            this.dispatchEvent(new CustomEvent('consultarleads', {
                detail: {
                    telaClienteEncontrado: this.telaClienteEncontrado,
                    telaClienteNaoEncontrado: this.telaClienteNaoEncontrado
                }
            }));
        } else {
            this.apresentarMensagem('Erro', 'Por favor, corrija os campos com erro.', 'error');
        }
    }

    validateCelular(celular) {
        const regex = /^[0-9]{11}$/;
        return regex.test(celular);
    }

    validateTelefone(telefone) {
        const regex = /^[0-9]{10}$/;
        return regex.test(telefone);
    }

    validateEmail(email) {
        const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return regex.test(email);
    }

    resetErrors() {
        this.celularError = false;
        this.telefoneError = false;
        this.emailError = false;
    }

    apresentarMensagem(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}