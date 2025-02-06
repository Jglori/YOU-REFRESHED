import { api, LightningElement } from 'lwc';
import obterSeriesProposta from '@salesforce/apex/CotacaoController.obterSeriesProposta';
import {calcularInicioPagamentoSeriePagamentos, calcularPorcParcelaSeriePagamento, calcularValorParcelaSeriePagamento, calcularValorTotalSeriePagamento, calcularDiferencaMeses} from 'c/utils';

const columns = [
    { label: 'Data de Vencimento', fieldName: 'diaVencimento', type: 'text', cellAttributes: { alignment: 'left' } },
    { label: 'Inicio Pagamento', fieldName: 'inicioPagamento', type: 'text', cellAttributes: { alignment: 'left' } },
    { label: 'Tipo de Condição', fieldName: 'tipoCondicao', type: 'text', cellAttributes: { alignment: 'left' } },
    { label: 'Valor parcela', fieldName: 'valorParcela', type: 'currency', cellAttributes: { alignment: 'left' } },
];

export default class SeriePagamentoPropostaCliente extends LightningElement {
    data = [];
    columns = columns;
    
    @api recordId;
    _resultadosmatriz;
    
    get getCotacaoId() {
        return this.recordId;
    }

    @api
    get resultadosmatriz() {
        return this._resultadosmatriz;
    }

    set resultadosmatriz(value) {
        if (value) {
            this._resultadosmatriz = value;
            this.plotarProposta();
        }
    }

    plotarProposta() {
        obterSeriesProposta({ idCotacao: this.getCotacaoId })
            .then(result => {
                let expandedData = [];
                console.log("result", JSON.stringify(result));
                result.forEach(item => {
                    let inicioPagamento = item.InicioPagamento__c;
                    let quantidadeParcelas = item.QuantidadeParcelas__c;
                    let valorTotal = item.ValorTotal__c;

                    let porcParcela = calcularPorcParcelaSeriePagamento(valorTotal, item.QuantidadeParcelas__c);
                    let valorParcela = calcularValorParcelaSeriePagamento(porcParcela, this._resultadosmatriz.valorNominal);

                    let dataVencimento = new Date();
                    dataVencimento.setMonth(dataVencimento.getMonth() + inicioPagamento);

                    for (let i = 0; i < quantidadeParcelas; i++) {
                        let mesVencimento = (dataVencimento.getMonth() + 1).toString().padStart(2, '0');
                        let anoVencimento = dataVencimento.getFullYear();
                        let formattedDiaVencimento = `${mesVencimento}/${anoVencimento}`;

                        expandedData.push({
                            diaVencimento: formattedDiaVencimento,
                            tipoCondicao: item.TipoCondicao__c,
                            inicioPagamento: inicioPagamento,
                            valorParcela: valorParcela,
                            valorTotal: valorTotal,
                            dataVencimento: new Date(dataVencimento) 
                        });

                        dataVencimento.setMonth(dataVencimento.getMonth() + 1);
                    }
                });


                this.data = expandedData.map(({ dataVencimento, ...rest }) => rest);
            })
            .catch(error => {
                console.log("error", error);
            });
    }    
}