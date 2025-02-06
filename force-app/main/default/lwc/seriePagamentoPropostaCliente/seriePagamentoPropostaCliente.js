import { api, LightningElement, track } from 'lwc';
    import obterSeriesProposta from "@salesforce/apex/CotacaoController.obterSeriesProposta";
    import {calcularInicioPagamentoSeriePagamentos, calcularPorcParcelaSeriePagamento, calcularValorParcelaSeriePagamento, calcularValorTotalSeriePagamento, calcularDiferencaMeses} from 'c/utils';
    const columns = [
        { label: 'Inicio Pagamento', fieldName: 'inicioPagamento', type: 'date', cellAttributes: { alignment: 'left' },
        typeAttributes: {
            day: '2-digit', 
            month: '2-digit', 
            year: 'numeric'
        }},
        { label: 'Tipo de Condição', fieldName: 'tipoCondicao', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'Dia de Vencimento', fieldName: 'diaVencimento', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'Qtd. Parcelas', fieldName: 'qtdParcelas', type: 'number', cellAttributes: { alignment: 'left' } },
        { label: 'Valor parcela', fieldName: 'valorParcela', type: 'currency', cellAttributes: { alignment: 'left' } },
        { label: 'Valor total', fieldName: 'valorTotal', type: 'currency', cellAttributes: { alignment: 'left' } },
        { label: '% Parcela', fieldName: 'percParcela', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: '% Total', fieldName: 'percTotal', type: 'text', cellAttributes: { alignment: 'left' } },
        { label: 'Apo habite-se?', fieldName: 'apoHabiteSe', type: 'boolean'}
    ];

    export default class SeriePagamentoPropostaCliente extends LightningElement {
        data = [];
        columns = columns;
    
        _resultadosmatriz;
    
        @api recordId;
    
        @api
        get resultadosmatriz() {
            return this._resultadosmatriz;
        }
    
        set resultadosmatriz(value) {
            if (value) {
                this._resultadosmatriz = value;
                console.log("Resultados Matriz Atualizado no Filho:", JSON.stringify(this._resultadosmatriz));
                this.plotarProposta();
            }
        }
    
        plotarProposta() {
            if (!this._resultadosmatriz || !this.recordId) {
                console.log("Dados insuficientes para plotar proposta");
                return;
            }
    
            obterSeriesProposta({ idCotacao: this.recordId })
                .then(result => {
                    let seriesFormatadas = [];
                    result.forEach(serie => {
                        let porcParcela = calcularPorcParcelaSeriePagamento(serie.ValorTotal__c, serie.QuantidadeParcelas__c);
                        let valorParcela = calcularValorParcelaSeriePagamento(porcParcela, this._resultadosmatriz.valorNominal);
                        let valorTotal = calcularValorTotalSeriePagamento(serie.ValorTotal__c, this._resultadosmatriz.valorNominal);
    
                        seriesFormatadas.push({
                            tipoCondicao: serie.TipoCondicao__c,
                            inicioPagamento: calcularInicioPagamentoSeriePagamentos(serie),
                            diaVencimento: "Dia " + serie.DiaDeVencimento__c,
                            qtdParcelas: serie.QuantidadeParcelas__c,
                            valorParcela: parseFloat(valorParcela).toFixed(2),
                            valorTotal: parseFloat(valorTotal).toFixed(2),
                            percParcela: (porcParcela).toFixed(2) + '%',
                            percTotal: (serie.ValorTotal__c).toFixed(2) + '%',
                            apoHabiteSe: serie.AposHabiteSe__c
                        });
                    });
    
                    this.data = seriesFormatadas;
                })
                .catch(error => {
                    console.log("error", error);
                });
        }
    }