import criarConjuntoCriterios from '@salesforce/apex/ParametrizarCriteriosController.criarConjuntoCriterios';
import getVariacoesLimite from '@salesforce/apex/ParametrizarCriteriosController.getVariacoesLimite';
import testarConjuntoCriterios from '@salesforce/apex/ParametrizarCriteriosController.testarConjuntoCriterios';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { LightningElement, wire, track } from 'lwc';

export default class ParametrizarCriteriosAnalise extends LightningElement {
    limiteOptions = [];

    @wire(getVariacoesLimite)
    wiredVariacoes({ error, data }) {
        if (data) {
            this.limiteOptions = data.map(item => {
                return { label: item, value: item };
            });
        } else if (error) {
            console.error('Erro ao buscar variações', error);
        }
    }

    // variaveis de inputs
    valorNominal = 0;
    valorVpl = 0;
    valorMetro = 0;
    valorPrazo = 0;
    valorCaptacaoVista = 0;
    valorCaptacaoPos = 0;
    valorCaptacaoMensal = 0;

    // variaveis de variações
    variacaoNominal = '';
    variacaoVpl = '';
    variacaoMetro = '';
    variacaoPrazo = '';
    variacaoCaptacaoVista = '';
    variacaoCaptacaoPos = '';
    variacaoCaptacaoMensal = '';

    //variaveis de visibilidade
    showPorcentagemCapVista = true;
    showPorcentagemNominal = true;
    showPorcentagemVpl = true;
    showPorcentagemMetro = true;
    showPorcentagemCapPos = true;
    showPorcentagemCapMensal = true;

    displayTeste = false;

    limite = [];

    // formatação do campo Nominal
    get valorNominalDisplay() {
        return this.showPorcentagemNominal ? `${this.valorNominal}%` : this.valorNominal;
    }

    adicionarPorcentagemNominal() {
        if (!isNaN(this.valorNominal) && this.valorNominal !== '') {
            this.showPorcentagemNominal = true;
        }
    }

    handleMudancaNominal(event) {
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorNominal = inputValue;
        } else {
            this.valorNominal = 0;
        }
    }

    retirarPorcentagemNominal() {
        this.showPorcentagemNominal = false;
    }

    handleMudancaLimiteNominal(event) {
        this.variacaoNominal = event.target.value;
        if (this.bloqueioInputNominal) {
            this.valorNominal = 0;
        }
    }

    get bloqueioInputNominal() {
        if (this.variacaoNominal === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }

    // formatação do campo VPL

    get valorVplDisplay(){
        return this.showPorcentagemVpl ? `${this.valorVpl}%` : this.valorVpl;
    }

    retirarPorcentagemVpl() {
        this.showPorcentagemVpl = false;
    }

    adicionarPorcentagemVpl() {
        if (!isNaN(this.valorVpl) && this.valorVpl !== '') {
            this.showPorcentagemVpl = true;
        }
    }

    handleMudancaVpl(event) {
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorVpl = inputValue;
        } else {
            this.valorVpl = 0;
        }
    }

    handleMudancaLimiteVPL(event){
        this.variacaoVpl = event.target.value;
        if (this.bloqueioInputVpl) {
            this.valorVpl = 0;
        }
    }

    get bloqueioInputVpl(){
        if (this.variacaoVpl === 'Não for igual'){
            this.valorVpl = 0;
            return true;
        } else {
            return false;
        }
    }

    // formatação do campo Metro²

    get valorMetroDisplay(){
        return this.showPorcentagemMetro ? `${this.valorMetro}%` : this.valorMetro;
    }
    retirarPorcentagemMetro(){
        this.showPorcentagemMetro = false;
    }
    adicionarPorcentagemMetro(){
        if (!isNaN(this.valorMetro) && this.valorMetro !== '') {
            this.showPorcentagemMetro = true;
        }
    }

    handleMudancaMetro(){
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorMetro = inputValue;
        }
    }

    handleMudancaLimiteMetro(event) {
        this.variacaoMetro = event.target.value;
        if (this.bloqueioInputMetro) {
            this.valorMetro = 0;
        }
    }

    get bloqueioInputMetro(){
        if (this.variacaoMetro === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }

    // formatação do campo Prazo Financiamento

    get valorPrazoDisplay(){
        return this.valorPrazo;
    }

    handleMudancaPrazo(event){
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorPrazo = inputValue;
        }
    }

    handleMudancaLimitePrazo(event) {
        this.variacaoPrazo = event.target.value;
        if (this.bloqueioInputPrazo) {
            this.valorPrazo = 0;
        }
    }

    get bloqueioInputPrazo() {
        if (this.variacaoPrazo === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }

    // formatação do campo de % captação a vista

    get valorCaptacaoVistaDisplay(){
        return this.showPorcentagemCapVista ? `${this.valorCaptacaoVista}%` : this.valorCaptacaoVista;
    }

    retirarPorcentagemCaptacaoVista(){
        this.showPorcentagemCapVista = false;
    }

    adicionarPorcentagemCaptacaoVista(){
        if (!isNaN(this.valorCaptacaoVista) && this.valorCaptacaoVista !== '') {
            this.showPorcentagemCapVista = true;
        }
    }

    handleMudancaCaptacaoVista(event){
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorCaptacaoVista = inputValue;
        }
    }

    handleMudancaLimiteCapVista(event) {
        this.variacaoCaptacaoVista = event.target.value;
        if (this.bloqueioInputCapVista) {
            this.valorCaptacaoVista = 0;
        }
    }

    get bloqueioInputCapVista() {
        if (this.variacaoCaptacaoVista === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }

    // formatação do campo de % captação Pos

    get valorCaptacaoPosDisplay() {
        
        if (this.showPorcentagemCapPos) {
            return `${this.valorCaptacaoPos}%`;
        } else {
            return this.valorCaptacaoPos;
        }
    }
    

    retirarPorcentagemCaptacaoPos(){
        this.showPorcentagemCapPos = false;
    }

    adicionarPorcentagemCaptacaoPos() {
        if (!isNaN(this.valorCaptacaoPos) && this.valorCaptacaoPos !== '') {
            this.showPorcentagemCapPos = true;
        }
    }


    handleMudancaCaptacaoPos(event) {
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorCaptacaoPos = inputValue;
        }
    }

    handleMudancaLimiteCapPos(event) {
        this.variacaoCaptacaoPos = event.target.value;
        if (this.bloqueioInputPos) {
            this.valorCaptacaoPos = 0;
        }
    }
    
    get bloqueioInputPos() {
        if (this.variacaoCaptacaoPos === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }
    // formatação captação Mensal

    get valorMensalDisplay(){
        return this.showPorcentagemCapMensal ? `${this.valorCaptacaoMensal}%` : this.valorCaptacaoMensal;
    }

    retirarPorcentagemMensal(){
        this.showPorcentagemCapMensal = false;
    }

    adicionarPorcentagemMensal(){
        if (!isNaN(this.valorCaptacaoMensal) && this.valorCaptacaoMensal !== '') {
            this.showPorcentagemCapMensal = true;
        }
    }

    handleMudancaMensal(event){
        const inputValue = parseFloat(event.target.value);
        if (!isNaN(inputValue)) {
            this.valorCaptacaoMensal = inputValue;
        }
    }

    handleMudancaLimiteMensal(event) {
        this.variacaoCaptacaoMensal = event.target.value;
        if (this.bloqueioInputMensal) {
            this.valorCaptacaoMensal = 0;
        }
    }

    get bloqueioInputMensal() {
        if (this.variacaoCaptacaoMensal === 'Não for igual'){
            return true;
        } else {
            return false;
        }
    }

    salvarConjuntoCriterios() {
        if (!this.validarCampos()) {
            return;
        }
    
        this.limite = {
            nominal: this.valorNominal,
            nominalVariacao: this.variacaoNominal,
            vpl: this.valorVpl,
            vplVariacao: this.variacaoVpl,
            metro: this.valorMetro,
            metroVariacao: this.variacaoMetro,
            prazo: this.valorPrazo,
            prazoVariacao: this.variacaoPrazo,
            captacaoVista: this.valorCaptacaoVista,
            captacaoVistaVariacao: this.variacaoCaptacaoVista,
            captacaoPos: this.valorCaptacaoPos,
            captacaoPosVariacao: this.variacaoCaptacaoPos,
            captacaoMensal: this.valorCaptacaoMensal,
            captacaoMensalVariacao: this.variacaoCaptacaoMensal
        };
    
        criarConjuntoCriterios({ conjunto: this.limite })
            .then(() => {
                this.mostrarToast('Sucesso', 'Conjunto de critérios salvo com sucesso.', 'success');
                this.limparCampos();  // Limpar os inputs após o sucesso
            })
            .catch(error => {
                this.mostrarToast('Erro', 'Falha ao salvar o conjunto de critérios.', 'error');
                console.error('Erro ao salvar conjunto de critérios', error);
            });
    }
    
    //Inicio da seção de teste

    //variaveis de tabela
    valorNominalTabelaTeste = 0;
    valorVplTabelaTeste = 0;
    valorMetroTabelaTeste = 0;
    valorPrazoTabelaTeste =  this.valorPrazo;
    valorCapVistaTabelaTeste = 0;
    valorcapPosTabelaTeste = 0;
    valorCapMensalTabelaTeste = 0;

    teste = 0;

    //variaveis da Proposta
    valorNominalPropostaTeste = 0;
    valorVplPropostaTeste = 0;
    valorMetroPropostaTeste = 0;
    valorPrazoPropostaTeste = 0;
    valorCapVistaPropostaTeste = 0;
    valorCapPosPropostaTeste = 0;
    valorCapMensalPropostaTeste = 0;

    //variaveis de diferença
    diferencaNominal = 0;
    diferencaNominalPorcentagem = 0;
    diferencaVpl = 0;
    diferencaVplPorcentagem = 0;
    diferencaMetro = 0;
    diferencaMetroPorcentagem = 0;

    @track corVarialNominal = "";
    @track corVarialVpl = "";
    @track corVarialMetro = "";
    @track corVarialPrazo = "";
    @track corVarialCapVista = "";
    @track corVarialCapPos = "";
    @track corVarialCapMensal = "";

    // visibilidade da seção de teste
    
    displayTest() {
        if(!this.validarCampos()){
            return;
        }
        this.displayTeste = !this.displayTeste;
        this.limite.push({
            nominal: this.valorNominal,
            nominalVariacao: this.variacaoNominal,
            vpl: this.valorVpl,
            vplVariacao: this.variacaoVpl,
            prazoFinanciamento: this.valorPrazo,
            prazoFinanciamentoVariacao: this.variacaoPrazo,
            captacaoVista: this.valorCaptacaoVista,
            captacaoVistaVariacao: this.variacaoCaptacaoVista,
            captacaoPos: this.valorCaptacaoPos,
            captacaoPosVariacao: this.variacaoCaptacaoPos,
            captacaoMensal: this.valorCaptacaoMensal,
            captacaoMensalVariacao: this.variacaoCaptacaoMensal
        })
    }

    // Valor nominal

    salvarValorNominalTab(event) {
        this.valorNominalTabelaTeste = event.target.value;
    }

    salvarValorNominalProp(event) {
        this.valorNominalPropostaTeste = event.target.value;

        testarConjuntoCriterios({valorTabela:this.valorNominalTabelaTeste , valorProposta: this.valorNominalPropostaTeste})
            .then(result => {
                this.diferencaNominal = this.formatarMoedaBrasileira(result[0]);
                this.diferencaNominalPorcentagem = this.formatarPorcentagem(result[1]);
            })
            .catch(error => {
                console.error('Erro ao calcular a diferença:', error);
            })
        this.corVarialNominal = this.validarAceitacao(
            this.variacaoNominal,
            this.valorNominal,
            this.diferencaNominalPorcentagem,
            this.valorNominalTabelaTeste,
            this.valorNominalPropostaTeste
        )
    }
    // Valor Vpl

    salvarValorVplTab(event) {
        this.valorVplTabelaTeste = event.target.value;
    }

    salvarValorVplProp(event) {
        this.valorVplPropostaTeste = event.target.value;

        testarConjuntoCriterios({ valorTabela: this.valorVplTabelaTeste, valorProposta: this.valorVplPropostaTeste })
            .then(result => {
                this.diferencaVpl = this.formatarMoedaBrasileira(result[0]);
                this.diferencaVplPorcentagem = this.formatarPorcentagem(result[1]);
                console.log(JSON.stringify(result));
            })
            .catch(error => {
                console.error('Erro ao calcular a diferença:', error);
            });
        
        this.corVarialVpl = this.validarAceitacao(
            this.variacaoVpl,
            this.valorVpl,
            this.diferencaVplPorcentagem,
            this.valorVplTabelaTeste,
            this.valorVplPropostaTeste
        )
    }

    // Valor M²

    salvarValorMetroTab(event) {
        this.valorMetroTabelaTeste = event.target.value;
    }

    salvarValorMetroProp(event) {
        this.valorMetroPropostaTeste = event.target.value;
        
        testarConjuntoCriterios({valorTabela: this.valorMetroTabelaTeste, valorProposta: this.valorMetroPropostaTeste})
            .then(result => {
                this.diferencaMetro = this.formatarMoedaBrasileira(result[0]);
                this.diferencaMetroPorcentagem = this.formatarPorcentagem(result[1]);
            })
        this.corVarialMetro = this.validarAceitacao(
            this.variacaoMetro,
            this.valorMetro,
            this.diferencaMetroPorcentagem,
            this.valorMetroTabelaTeste,
            this.valorMetroPropostaTeste
        )
    }

    // Prazo Financiamento

    salvarValorPrazoTab(event){
        this.valorPrazoTabelaTeste = event.target.value;

        this.corVarialPrazo = this.validarAceitacaoSimplificado(
            this.variacaoPrazo,
            this.valorPrazo,
            this.valorPrazoTabelaTeste,
            this.valorPrazoPropostaTeste
        )
    }

    salvarValorPrazoProp(event) {
        this.valorPrazoPropostaTeste = event.target.value;

        this.corVarialPrazo = this.validarAceitacaoSimplificado(
            this.variacaoPrazo,
            this.valorPrazo,
            this.valorPrazoTabelaTeste,
            this.valorPrazoPropostaTeste
        )
    }

    // % captação à vista

    salvarValorCapVistaTab(event) {
        let valor = event.target.value;
        if (!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null) {
            this.valorCapVistaTabelaTeste = valor / 100;
        }
        else {this.valorCapVistaTabelaTeste;}
    }
    

    get adicionarPorcentagemCapVistaTabela() {
        return this.formatarPorcentagem(this.valorCapVistaTabelaTeste)
    }

    val1 = this.calcularLimitePorcentagem(this.valorCaptacaoVista, this.valorCapVistaTabelaTeste)

    salvarValorCapVistaProp(event) {
        let valor = event.target.value;
        if (!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null) {
            this.valorCapVistaPropostaTeste = valor / 100

            console.log(this.val1)

            this.corVarialCapVista = this.validarAceitacaoSimplificado(
                this.variacaoCaptacaoVista,
                this.val1,
                this.valorCapVistaTabelaTeste,
                this.valorCapVistaPropostaTeste
            )
        }
        else {this.valorCapVistaPropostaTeste;}
    }

    get adicionarPorcentagemCapVistaProposta() {
        return this.formatarPorcentagem(this.valorCapVistaPropostaTeste )
    }

    get limiteTesteCapVista(){
        return this.formatarPorcentagem(this.calcularLimitePorcentagem(this.valorCaptacaoVista, this.valorCapVistaTabelaTeste));
    }

    // % de captação Pos habita-se

    salvarValorCapPosTab(event) {
        let valor = event.target.value;
        if(!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null){
            this.teste = valor / 100;
        }
        else{console.log("entrou no else"); this.teste;}
    }
        
    val2 = this.calcularLimitePorcentagem(this.valorCaptacaoPos, this.teste)
    
    get AdicionarPorcentagemCapPosTabela() {
        console.log( `valor do capTabela: ${this.teste}`);
        return this.formatarPorcentagem(this.teste);
    }

    salvarValorCapPosProp(event) {
        let valor = event.target.value;
        if(!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null){
            this.valorCapPosPropostaTeste = valor / 100;
            
            this.corVarialCapPos = this.validarAceitacaoSimplificado(
                this.variacaoCaptacaoPos,
                this.val2,
                this.valorcapPosTabelaTeste,
                this.valorCapPosPropostaTeste
            )
        }
        else {this.valorCapPosPropostaTeste;}
    }

    get AdicionarPorcentagemCapPosProposta() {
        return this.formatarPorcentagem(this.valorCapPosPropostaTeste);
    }

    get limiteTesteCapPos(){
        return this.formatarPorcentagem(this.calcularLimitePorcentagem(this.valorCaptacaoPos, this.teste));
    }

    // % captação Mensal

    salvarValorCapMensalTab(event) {
        let valor = event.target.value;
        if(!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null){
            this.valorCapMensalTabelaTeste = valor / 100;
        }
        else {this.valorCapMensalTabelaTeste;}
    }

    get AdicionarPorcentagemCapMensalTabela() {
        return this.formatarPorcentagem(this.valorCapMensalTabelaTeste)
    }

    val3 = this.calcularLimitePorcentagem(this.valorCaptacaoMensal, this.valorCapMensalTabelaTeste)

    salvarValorCapMensalProp(event) {
        let valor = event.target.value;
        if(!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null){
            this.valorCapMensalPropostaTeste = valor / 100;
        
            this.corVarialCapMensal = this.validarAceitacaoSimplificado(
                this.variacaoCaptacaoMensal,
                this.val3,
                this.valorCapMensalTabelaTeste,
                this.valorCapMensalPropostaTeste
            )
        }
        else {this.valorCapMensalPropostaTeste;}
    }

    get AdicionarPorcentagemCapMensalProposta() {
        return this.formatarPorcentagem(this.valorCapMensalPropostaTeste)
    }

    get limiteTesteCapMensal(){
        return this.formatarPorcentagem(this.calcularLimitePorcentagem(this.valorCaptacaoMensal, this.valorCapMensalTabelaTeste));
    }


    // funções utilitarias

    calcularLimitePorcentagem(ValorLimite, valorTeste){
        return (ValorLimite * valorTeste) / 100;
    }

    validarCampos() {
        const campos = [
            { valor: this.valorNominal, nome: 'Valor Nominal' },
            { valor: this.valorVpl, nome: 'Valor VPL' },
            { valor: this.valorMetro, nome: 'Valor Metro²' },
            { valor: this.valorPrazo, nome: 'Prazo Financiamento' },
            { valor: this.valorCaptacaoVista, nome: 'Captação à Vista' },
            { valor: this.valorCaptacaoPos, nome: 'Captação Pós Habita-se' },
            { valor: this.valorCaptacaoMensal, nome: 'Captação Mensal' },
            { valor: this.variacaoNominal, nome: 'Variacao Nominal'},
            { valor: this.variacaoVpl, nome: 'Variação VPL'},
            { valor: this.variacaoMetro, nome: 'Variação Metro'},
            { valor: this.variacaoPrazo, nome: 'Variação Prazo'},
            { valor: this.variacaoCaptacaoVista, nome: 'Variação Captação a Vista'},
            { valor: this.variacaoCaptacaoPos, nome: 'Variação Captação Pos'},
            { valor: this.variacaoCaptacaoMensal, nome: 'Variação Captação Mensal'},
        ];

        for (let campo of campos) {
            if (campo.valor === null || campo.valor === undefined || campo.valor === '' || campo.valor < 0) {
                this.mostrarToast('ERRO', `O campo ${campo.nome} não pode ser vazio ou abaixo de 0.`, 'error');
                return false;
            }
        }
        return true;
    }

    mostrarToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    limparCampos() {
        this.valorNominal = 0;
        this.variacaoNominal = '';
        this.valorVpl = 0;
        this.variacaoVpl = '';
        this.valorMetro = 0;
        this.variacaoMetro = '';
        this.valorPrazo = 0;
        this.variacaoPrazo = '';
        this.valorCaptacaoVista = 0;
        this.variacaoCaptacaoVista = '';
        this.valorCaptacaoPos = 0;
        this.variacaoCaptacaoPos = '';
        this.valorCaptacaoMensal = 0;
        this.variacaoCaptacaoMensal = '';
    }

    formatarMoedaBrasileira(valor) {
        const valorNumerico = parseFloat(valor);
        return valorNumerico.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    }

    formatarPorcentagem(valor) {
        const valorNumerico = parseFloat(valor);
        return valorNumerico.toLocaleString('pt-BR', { style: 'percent', minimumFractionDigits: 2});
    }

    validarCampo(valor){
        if(!isNaN(valor) && valor !== '' && valor !== undefined && valor !== null){
            return true;
        }
        return false
    }


    validarAceitacao(variacao, limiteTabela, diferenca, valorTabela, valorProposta) {
        switch(variacao) {
            case "Abaixo do limite":
                return diferenca < limiteTabela ? 'border: 2px solid red;' : 'border: 2px solid green;';
            case "Acima do limite":
                return diferenca > limiteTabela ? 'border: 2px solid red;' : 'border: 2px solid green;';
            case "Não for igual":
                console.log("Entrou no if de não for igual");
                return valorTabela !== valorProposta ? 'border: 2px solid red;' : 'border: 2px solid green;';
            default:
                return null;
        }
    }

    validarAceitacaoSimplificado(variacao, limiteTabela, valorTabela, valorProposta) {
        const diferenca = valorTabela - valorProposta;
        return this.validarAceitacao(variacao, limiteTabela, diferenca, valorTabela, valorProposta);
    }
}