import { LightningElement, api } from 'lwc';

export default class ConciergeLeadEncaminhado extends LightningElement {
    @api corretor;

    @api telaPesquisar;

    
    get message() {
        return `Lead encaminhado para ${this.corretor} com sucesso`;
    }

    
    handlePesquisar() {
        this.dispatchEvent(new CustomEvent('mudancatela', {
            detail: { tela: this.telaPesquisar }
        }));
    }
}