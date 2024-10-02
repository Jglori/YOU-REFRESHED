import { LightningElement, track, api , wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import buscarNomesEmpreendimentos from '@salesforce/apex/EspelhoVendasController.buscarNomesEmpreendimentos';
import buscarBlocosPorEmpreendimento from '@salesforce/apex/EspelhoVendasController.buscarBlocosPorEmpreendimento';
import buscarStatusUnidades from '@salesforce/apex/EspelhoVendasController.buscarStatusUnidades';
import buscarTiposUnidades from '@salesforce/apex/EspelhoVendasController.buscarTiposUnidades';

export default class EspelhoDeVendasFiltro extends LightningElement {
    @track empreendimento;

    @track bloco = '';
    @track andar = '';
    @track status = '';

    @track finalUnidade = '';
    

    @track valor = 0;
    @track minValue = 0;
    @track maxValue = 50000000;
    @track stepValue = 1000;
    @track metragem = 50; // Valor inicial do slider
    @track metragemPills = [];
    @track valorPills = [];
    @track showSuggestions = false;
    @track empreendimentoOptions = [];
    @track selectedEmpreendimento = '';
    @track blocoOptions = [];
    @track andarOptions = [];
    @track selectedBloco = '';
    @track previousFilteredApartments = []; 
    @track empreendimentoPills = [];
    @track valorPills = []
    @track blocoPills = [];
    @track tipoUnidade = '';
    @track andarPills = [];
    @track statusPills = [];
    @track finalUnidadePills = [];
    @track quantidadeQuartosPills = []
    @track tipoUnidadePills = [];
    @track quantidadeSuitesPills = []
    @track quantidadeSuites = '';
    @track andares = [];
    @track mostrarFiltrosExtras = false;    
    @track typeOptions = [];
    @track selectedType = [];

    @track statusOptions = [];
    @track selectedStatus = '';
    @track statusPills = [];

    @track filtroState = false;
    
    @track blocoSelecionado;
    @track andaresSelecionados = [];
    @track apartamentosBloco = [];
    @track statusSelecionados = [];
    @track tipoUnidadeSelecionados = [];

    @track valorMinimo;
    @track valorMaximo;
    
    @track metragemMinima;
    @track metragemMaxima;

    @api apartments;
    

    @wire(buscarStatusUnidades)
    wiredStatuses({ error, data }) {
        if (data) {
            this.statusOptions = data.map(status => ({ label: status, value: status }));
        } else if (error) {
            console.error('Error fetching unit statuses', error);
        }
    }



    @wire(buscarTiposUnidades)
    wiredTypes({ error, data }) {
        if (data) {
            this.typeOptions = data.map(type => ({ label: type.Name, value: type.Id }));
        } else if (error) {
            console.error('Error fetching unit types', error);
        }
    }

    @track FilteredApartments;

    get filteredApartments() {
        return this.filteredApartments;
    }

    get getBlocoOptions(){
        return this.blocoOptions;
    }

    get getBlocoSelecionado(){
        return this.blocoSelecionado;
    }

    get getAndaresSelecionados(){
        return this.andaresSelecionados;
    }

    get getStatusSelecionados(){
        return this.statusSelecionados
    }

    get getTipoUnidadeSelecionados(){
        return this.tipoUnidadeSelecionados;
    }

    get getEmpreendimento(){
        return this.empreendimento;
    }

    get isBlocoNotSelecionado(){
        return this.getBlocoSelecionado ? false : true
    }

    get getFinalUnidade(){
        return this.finalUnidade
    }


    renderedCallback() {
        this.template.querySelector('[role="cm-picklist-status"]').setOptions(this.statusOptions);
        
        if (this.mostrarFiltrosExtras) {
            const picklistTipo = this.template.querySelector('[role="cm-picklist-tipoUnidade"]');
            if (picklistTipo) {
                picklistTipo.setOptions(this.typeOptions);
                picklistTipo.setSelectedList(null);
            }
        }
    }


    handleEmpreendimento(event) {
        const empreendimentoId = event.detail.recordId;
        
        this.limparFiltros();
        this.blocoSelecionado = null;
        
        this.empreendimento = empreendimentoId

        if(empreendimentoId === null){
            this.blocoOptions = [];


            const selectEmpreendimento = new CustomEvent('selectempreendimento', {
                detail: {idEmpreendimento: null}
            });

            this.dispatchEvent(selectEmpreendimento);
            return;
        }
        
        const selectEmpreendimento = new CustomEvent('selectempreendimento', {
            detail: {idEmpreendimento: this.empreendimento}
        });

        this.dispatchEvent(selectEmpreendimento);
        
        this.buscarBlocos();
    }

    limparFiltros(){
        this.andarOptions = null;
            
        let andarMultipicklist = this.template.querySelector('[role="cm-picklist-andar"]');
        let statusMultipicklist = this.template.querySelector('[role="cm-picklist-status"]');
        let tipoUnidadeMultipicklist = this.template.querySelector('[role="cm-picklist-tipoUnidade"]');
        
        let finalUnidadeInput = this.template.querySelector('[data-field="finalUnidade"]');
        let quantidadeQuartosInput = this.template.querySelector('[data-field="quantidadeQuartos"]');
        
        let valorMinimoInput = this.template.querySelector('[data-field="valorMinimo"]');
        let valorMaximoInput = this.template.querySelector('[data-field="valorMaximo"]');
        
        let metragemMinimaInput = this.template.querySelector('[data-field="metragemMinima"]');
        let metragemMaximaInput = this.template.querySelector('[data-field="metragemMaxima"]');
        
        let quantidadeSuitesInput = this.template.querySelector('[data-field="quantidadeSuites"]');


        if(andarMultipicklist){
            andarMultipicklist.setOptions([]);
            andarMultipicklist.clearSelectedList();
        } 

        if(statusMultipicklist){
            statusMultipicklist.clearSelectedList();
        } 

        if(tipoUnidadeMultipicklist){
            tipoUnidadeMultipicklist.clearSelectedList();
        } 
        
        if(finalUnidadeInput){
            finalUnidadeInput.value = null;
        } 

        if (quantidadeQuartosInput) {
            quantidadeQuartosInput.value = null;
        }
        
        if (valorMinimoInput) {
            valorMinimoInput.value = null;
        }
        
        if (valorMaximoInput) {
            valorMaximoInput.value = null;
        }
        
        if (metragemMinimaInput) {
            metragemMinimaInput.value = null;
        }
        
        if (metragemMaximaInput) {
            metragemMaximaInput.value = null;
        }
        
        if (quantidadeSuitesInput) {
            quantidadeSuitesInput.value = null;
        }
        
        this.finalUnidadePills = [];
        this.quantidadeQuartosPills = [];
        this.quantidadeSuitesPills = [];
        this.andaresSelecionados = [];
        
    }
    
    buscarAndares(){
        if (this.apartamentosBloco.length <= 0){
            return;
        }

        let andarValues = [];


        this.apartamentosBloco.forEach(apartamento=>{
            if(!andarValues.includes(apartamento.Andar__c)){
                andarValues.push(apartamento.Andar__c)
            }
        })

        andarValues.sort((a, b) => a - b);

        this.andarOptions = andarValues.map(andar=> {return {"label": "Andar "+ andar, "value": andar}})


        this.template.querySelector('[role="cm-picklist-andar"]').setOptions(this.andarOptions);

    }

    buscarBlocos(){
        buscarBlocosPorEmpreendimento({idEmpreendimento: this.empreendimento})
        .then(response=>{
            this.blocoOptions = response.map(bloco => {return {"label": bloco.Name, "value": bloco.Id}});
        })
    }

    handleChangeBloco(event){
        this.limparFiltros()

        const blocoSelecionado = event.detail.value;
        
        this.blocoSelecionado = blocoSelecionado;
        
        let apartamentosFiltrados = [...this.apartments];


        apartamentosFiltrados = this.filtrarPorBloco(apartamentosFiltrados, this.blocoSelecionado);

        this.apartamentosBloco = [...apartamentosFiltrados]


        this.buscarAndares()

        this.filterSuggestions();
    }

    handleAndarChange(event) {
        const selectedValues = event.detail.selectedValues;


        if (!selectedValues || selectedValues.trim() === '') {
            this.andaresSelecionados = []
            this.filterSuggestions();
            return;
        } else {
            this.andaresSelecionados = selectedValues.split(';').map(Number);
            this.filterSuggestions();
        }
    
        //tem que ter essa porqueira pra n entrar em um loop :(
    }

    handleStatusChange(event){
        const selectedValues = event.detail.selectedValues;

        if (!selectedValues || selectedValues.trim() === '') {
            this.statusSelecionados = []
        } else {
            this.statusSelecionados = selectedValues.split(';');
        }

        this.filterSuggestions();
    }

    handleTipoUnidadeChange(event){
        const selectedValues = event.detail.selectedValues;

        if (!selectedValues || selectedValues.trim() === '') {
            this.tipoUnidadeSelecionados = []
        } else {
            this.tipoUnidadeSelecionados = selectedValues.split(';');
        }

        this.filterSuggestions();
    }


    removerTipoUnidade(event) {

        
        // Acessar o valor do data-label
        const labelToRemove = event.currentTarget.dataset.label;


        // Remover o item da lista de pílulas
        this.tipoUnidadePills = this.tipoUnidadePills.filter(pill => pill.label !== labelToRemove);
        
        // Atualizar o filtro após a remoção
        this.filterSuggestions();
    }

    removerQuantidadeSuites(event) {

        
        // Acessar o valor do data-label
        const labelToRemove = event.currentTarget.dataset.label;


        // Remover o item da lista de pílulas
        this.quantidadeSuitesPills = this.quantidadeSuitesPills.filter(pill => pill.label !== labelToRemove);
        
        // Atualizar o filtro após a remoção
        this.filterSuggestions();
    }

    handleKeydown(event) {
        if (event.key === 'Enter') {
            this.adicionarMetragemPill();
        }
    }

    adicionarMetragemPill() {
        if (!this.metragemPills.some(pill => pill.label === this.metragem)) {
            this.metragemPills = [...this.metragemPills, { label: this.metragem }];
        }

        this.filterSuggestions();
    }

    removerQuantidadeQuartos(event) {
       
        const labelToRemove = event.currentTarget.dataset.label;
       
        if (labelToRemove) {
            this.quantidadeQuartosPills = this.quantidadeQuartosPills.filter(pill => pill.label !== labelToRemove);
            this.filterSuggestions();
        } else {
            console.error('No label found for removal.');
        }
    }


    handleInputChange(event) {

        const field = event.target.dataset.field; 
        const valor = Number(event.target.value); 
 

        if (!isNaN(valor)) {
            this[field] = valor; 
        } else {
            this[field] = null; 
        }
    
        this.filterSuggestions();
    }

    


    handleInputMetragem(event){
        this.metragem = event.target.value;
        this.filterSuggestions();
    }

    handleInputQuantidadeSuites(event) {
        this.quantidadeSuites = event.target.value;
        this.filterSuggestions();
    }

    handleInputValor(event){
        this.valor = event.target.value;
        this.filterSuggestions();
    }
    formatarParaRealBrasileiro(event) {
        let valor = event.target.value;
    
        valor = valor.replace(/[^\d.]/g, '');
    
        valor = parseFloat(valor);
    
        if (isNaN(valor)) {
            this.valor = '';
            return;
        }
    
        this.valor = valor.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    }

    handleKeyup(event) {
        if (event.key === 'Enter') {
            const fieldName = event.target.dataset.field;
            const value = event.target.value; 
           
        
            if (value) {
                const fieldPills = this[`${fieldName}Pills`];
                const valueExists = fieldPills.some(pill => pill.label.toLowerCase() === value.toLowerCase());
    
                if (!valueExists) {
                    fieldPills.push({ label: value, value: value });
                    this.filterSuggestions(); 
                } else {
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Aviso',
                        message: `O valor "${value}" já existe na lista de filtros.`,
                        variant: 'warning'
                    }));
                }
            }
        }
    }
    
    handleRemove(event) {
        const fieldName = event.target.dataset.field;
        const pillLabel = event.target.label;
    
        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);
        
      
        this.filterSuggestions();
    }
    

    filterSuggestions() {
        const apartamentos = this.apartments;
        let apartamentosFiltrados = [...apartamentos];


        const bloco = this.getBlocoSelecionado;
        const andaresSelecionados = this.getAndaresSelecionados;
        const statusSelecionados = this.getStatusSelecionados;
        const finalUnidadeSelecionados = this.finalUnidadePills.map(item => Number(item.label));

        const quantidadeQuartosSelecionados = this.quantidadeQuartosPills.map(item => Number(item.label));
        const valorMinimo = this.valorMinimo;
        const valorMaximo = this.valorMaximo;
        const metragemMinima = this.metragemMinima;
        const metragemMaxima = this.metragemMaxima;
        const quantidadeSuitesSelecionados = this.quantidadeSuitesPills.map(item => Number(item.label));
        const tipoUnidadeSelecionados = this.getTipoUnidadeSelecionados;

        apartamentosFiltrados = this.filtrarPorBloco(apartamentosFiltrados, bloco);
        apartamentosFiltrados = this.filtrarPorAndares(apartamentosFiltrados, andaresSelecionados);
        apartamentosFiltrados = this.filtrarPorStatus(apartamentosFiltrados, statusSelecionados);
        apartamentosFiltrados = this.filtrarPorUnidades(apartamentosFiltrados, finalUnidadeSelecionados);

        apartamentosFiltrados = this.filtrarPorQuantidadeDeQuartos(apartamentosFiltrados, quantidadeQuartosSelecionados);
        apartamentosFiltrados = this.filtrarPorValor(apartamentosFiltrados, valorMinimo, valorMaximo);
        apartamentosFiltrados = this.filtrarPorMetragem(apartamentosFiltrados, metragemMinima, metragemMaxima);
        apartamentosFiltrados = this.filtrarPorQuantidadeSuites(apartamentosFiltrados, quantidadeSuitesSelecionados);
        apartamentosFiltrados = this.filtrarPorTipoUnidade(apartamentosFiltrados, tipoUnidadeSelecionados);
        
        const filterUpdateEvent = new CustomEvent('filterupdate', {
            detail: apartamentosFiltrados
        });
        this.dispatchEvent(filterUpdateEvent);

        
    }

    filtrarPorBloco(apartamentos, bloco) {
        if (bloco) {
            return apartamentos.filter(apartamento => apartamento.Bloco__c === bloco);
        }
        return apartamentos;
    }

    filtrarPorAndares(apartamentos, andaresSelecionados) {
        if (andaresSelecionados.length > 0) {
            return apartamentos.filter(apartamento => andaresSelecionados.includes(apartamento.Andar__c));
        }
        return apartamentos;
    }

    filtrarPorStatus(apartamentos, statusSelecionados) {
        if (statusSelecionados.length > 0) {
            return apartamentos.filter(apartamento => statusSelecionados.includes(apartamento.Status__c));
        }
        return apartamentos;
    }
    
    filtrarPorUnidades(apartamentos, finaisUnidadeSelecionados) {
        if (finaisUnidadeSelecionados.length > 0) {
            return apartamentos.filter(apartamento => {
                const ultimosTresDigitos = apartamento.NumeroDaUnidade__c.toString().slice(-3);
                return finaisUnidadeSelecionados.includes(Number(ultimosTresDigitos));
            });
        }
        return apartamentos;
    }
    
    filtrarPorQuantidadeDeQuartos(apartamentos, quantidadeQuartosSelecionados) {
        if (quantidadeQuartosSelecionados.length > 0) {
            return apartamentos.filter(apartamento => 
                quantidadeQuartosSelecionados.includes(apartamento.NumeroQuartos__c)
            );
        }
        return apartamentos;
    }

    filtrarPorValor(apartamentos, valorMinimo, valorMaximo) {

        if (valorMinimo && valorMaximo) {
            return apartamentos.filter(apartamento => 
                apartamento.PrecoLista__c >= valorMinimo && apartamento.PrecoLista__c <= valorMaximo
            );
        }

        return apartamentos;
    }
    
    filtrarPorMetragem(apartamentos, metragemMinima, metragemMaxima) {
        if (metragemMinima && metragemMaxima) {
            return apartamentos.filter(apartamento => 
                apartamento.ValorM2__c >= metragemMinima && apartamento.ValorM2__c <= metragemMaxima
            );
        }
        return apartamentos; 
    }

    filtrarPorQuantidadeSuites(apartamentos, quantidadeSuitesSelecionados) {
        if (quantidadeSuitesSelecionados.length > 0) {
            return apartamentos.filter(apartamento => 
                quantidadeSuitesSelecionados.includes(apartamento.NumeroDeSuites__c)
            );
        }
        return apartamentos;
    }

    filtrarPorTipoUnidade(apartamentos, tipoUnidadeSelecionados) {

        if (tipoUnidadeSelecionados.length > 0) {
            return apartamentos.filter(apartamento => 
                tipoUnidadeSelecionados.includes(apartamento.RecordTypeId)
            );
        }

        return apartamentos;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    
    remover(event) {
        const pillLabel = event.currentTarget.dataset.label;  
        const fieldName = 'andar';
    

    
        if (pillLabel === undefined) {
            console.error('Label da pílula é undefined');
            return;
        }
        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);
    

        
        
        this.filterSuggestions();
    }
    
    get valorFormatado() {
        const formatador = new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL',
        });
        return formatador.format(this.valor);
    }
   
    removerBloco(event) {
        const labelToRemove = event.currentTarget.dataset.label;
        this.blocoPills = this.blocoPills.filter(pill => pill.label !== labelToRemove);
        this.filterSuggestions();
    }


    removerStatus(event) {
        const labelToRemove = event.currentTarget.dataset.label;
        this.statusPills = this.statusPills.filter(pill => pill.label !== labelToRemove);
        this.filterSuggestions();
    }
    

    removerFinalUnidade(event){
        const pillLabel = event.currentTarget.dataset.label; 
        const fieldName = 'finalUnidade';  

        if (pillLabel === undefined) {
            console.error('Label da pílula é undefined');
            return;
        }

      
        
        this[`${fieldName}Pills`] = this[`${fieldName}Pills`].filter(pill => pill.label !== pillLabel);

                
        this.filterSuggestions();
    }
    
    abrirFiltrosExtras() {
        this.filtroState = !this.filtroState;
        this.mostrarFiltrosExtras = !this.mostrarFiltrosExtras;
    }



    selecionarUnidade(event){
        this.dispatchEvent(new CustomEvent('selecionarunidade', {
            detail: {id: event.detail}
        }));
    }
    
    
}