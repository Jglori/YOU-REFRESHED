import { LightningElement, api, track } from 'lwc';
import calcularComparacao from '@salesforce/apex/ComparativoController.calcularComparacao';

const colunas = [
    { label: 'Item', fieldName: 'item' }, 
    { label: 'Tabela', fieldName: 'valorTabela', type: 'text' }, 
    { label: 'Proposta', fieldName: 'valorProposta', type: 'text' },
    { label: 'Diferença', fieldName: 'diferenca', type: 'text' } 
];

export default class SimuladorTelaExtratoTabelaComparativa extends LightningElement {
    @api propostasCliente = [];
    
    @api idTabelaVenda;

    @track comparacaoResultados = [];
    @track colunas = colunas;

    connectedCallback() {
        console.log('connectedCallback executed');
        console.log('PropostasCliente:', this.propostasCliente); 
        console.log('IdTabelaVenda:', this.idTabelaVenda); 
        this.carregarComparacao();
    }

    carregarComparacao() {
        if (this.propostasCliente && this.idTabelaVenda) {
            calcularComparacao({ tabelaId: this.idTabelaVenda, proposta: this.propostasCliente })
                .then(result => {
                    console.log('Apex Result:', result); 
                    
                    this.comparacaoResultados = result.map(item => {
                        console.log('Mapping Item:', item); 
                        console.log('Item:', item.item);
                        console.log('ValorTabela:', item.valorTabela);
                        console.log('ValorProposta Before Mapping:', item.valorProposta); 

                        const mappedItem = {
                            item: item.item,
                            valorTabela: this.formatCurrency(item.valorTabela),
                            valorProposta: this.formatCurrency(item.valorProposta),
                            diferenca: this.formatCurrency(item.diferenca)
                        };

                        console.log('Mapped Item:', mappedItem); 
                        return mappedItem;
                    });

                    console.log('Mapped Results:', this.comparacaoResultados); 
                })
                .catch(error => {
                    console.error('Hata: ', error);
                });
        } else {
            console.error('PropostasCliente ou idTabelaVenda nao existe');
        }
    }

    formatCurrency(value) {
        return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL', minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);
    }
}
