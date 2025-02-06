import { api, LightningElement } from 'lwc';
import cotacaoTabelaRelacionada from "@salesforce/apex/CotacaoController.cotacaoTabelaRelacionada";
import obterValorVpl from "@salesforce/apex/CotacaoController.calcularTotalVPLTabela";

export default class SeriePagamento extends LightningElement {
    @api recordId;
    resultadosMatriz;

    get getCotacaoId(){
        return this.recordId;
    }

    get getResultadoMatriz(){
        return this.resultadosMatriz;
    }

    connectedCallback() {
        cotacaoTabelaRelacionada({ idCotacao: this.recordId }).then(response => {
            obterValorVpl({ idTabelaVendas: response[0].Id }).then(result => {
                this.resultadosMatriz = result;
                console.log("São fases e fases", JSON.stringify(this.getResultadoMatriz))
            }).catch(error => {
                console.log(error)
            });
        }).catch(error => {
            console.log(error)
        });
    }
}