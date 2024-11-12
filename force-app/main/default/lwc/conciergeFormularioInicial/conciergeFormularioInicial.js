import { LightningElement, track, api } from 'lwc';

export default class ConciergeFormularioInicial extends LightningElement {
    // Opções para o combobox
    tipoPessoaOptions = [
        { label: 'Pessoa Física', value: 'fisica' },
        { label: 'Pessoa Jurídica', value: 'juridica' }
    ];

    @api formulario;

    @track selectedTipoPessoa;

    connectedCallback() {
        
       if (!this.selectedTipoPessoa || this.selectedTipoPessoa === undefined) {
            const tipoPessoa = this.formulario.tipoPessoa;
            
            if (tipoPessoa === 'Física') {
                this.selectedTipoPessoa = 'fisica';
            } else if (tipoPessoa === 'Jurídica') {
                this.selectedTipoPessoa = 'juridica';
            } else {
                this.selectedTipoPessoa = ''; // ou algum valor padrão
            }
        }
        
    }

    handleTipoPessoaChange(event) { 
        this.selectedTipoPessoa = event.detail.value;
        this.dispatchEvent(new CustomEvent('tipoalterado', {
            detail: { tipoPessoa: this.selectedTipoPessoa }
        }));
    }
}