import { LightningElement, api } from 'lwc';

const propostaColunas = [
    { label: 'Tipo de condição', fieldName: 'TipoCondicao__c' },
    { label: 'Início de pagamento', fieldName: 'InicioPagamento__c', type: 'date', 
    typeAttributes: {
        day: '2-digit', 
        month: '2-digit', 
        year: 'numeric'
    }},
    { label: 'Dia de vencimento', fieldName: 'vencimentoParcela'},
    { label: 'Quantidade de Parcelas', fieldName: 'QuantidadeParcelas__c'},
    { label: 'Valor Parcela ', fieldName: 'valorParcela', type: 'currency'}, 
    { label: 'Valor Total', fieldName: 'valorTotal', type: 'currency'},
    { label: '% parcela', fieldName: 'porcentagemParcela'}, 
    { label: '% total', fieldName: 'ValorTotal__c'},
    { label: 'Após habite-se?', fieldName: 'AposHabiteSe__c', type: 'boolean' }
    
];

export default class SimuladorTelaExtratoPropostaCliente extends LightningElement {
    @api condicoesPropostaCliente;
    @api valoresMatrizProposta;


    propostaColunas = propostaColunas;

    connectedCallback(){
        console.log(JSON.stringify(this.valoresMatrizProposta));
    }

    get nominalProposta(){
        return this.valoresMatrizProposta.nominalProposta ? this.formatCurrency(this.valoresMatrizProposta.nominalProposta) : this.formatCurrency(0) 
    }
    
    get vplProposta(){
        return this.valoresMatrizProposta.vplProposta ? this.formatCurrency(this.valoresMatrizProposta.vplProposta) : this.formatCurrency(0) 
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