import { api, LightningElement } from 'lwc';

export default class UnidadeCard extends LightningElement {
    @api unidade;

    
    get getUnidadePreco(){
        return this.unidade && this.unidade.preco ? this.formatCurrency(this.unidade.preco) : this.formatCurrency(0.00);
    }
    
    get getUnidadeTipoUnidade(){
        return this.unidade && this.unidade.tipoUnidade ? this.unidade.tipoUnidade : null;
    }

    get getUnidadeName(){
        return this.unidade && this.unidade.name ? this.unidade.name : null;
    }

    get getUnidadeNumeroQuartos(){
        return this.unidade && this.unidade.numeroQuartos ? this.unidade.numeroQuartos === 1 ? `${this.unidade.numeroQuartos} Quarto` : `Quartos ${this.unidade.numeroQuartos}` : `0 quartos`;
    }


    get getUnidadeMetrosQuadrados(){
        return this.unidade && this.unidade.metrosQuadrados ?  `${this.unidade.metrosQuadrados} m²`  : `0 m²` ;
    }

    get getUnidadeSelected(){
        return this.unidade && this.unidade.selected ? this.unidade.selected : false
    }

    formatCurrency(value) {
        if (!value) return 'R$ 0,00';
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
            minimumFractionDigits: 2,
            maximumFractionDigits: 2
        }).format(value);
    }

}