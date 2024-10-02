import { LightningElement, wire, track , api } from 'lwc';
import retornarUnidadesDisponiveis from '@salesforce/apex/EspelhoVendasController.retornarUnidadesDisponiveis';
import { NavigationMixin } from 'lightning/navigation';
import configuracaoCoresEspelho from '@salesforce/apex/EspelhoVendasController.getConfiguracaoEspelho';

// colorMap.js
const colorMap = {
    'vermelho': '#DC143C',
    'verde': '#00FF7F',
    'azul': '#00BFFF',
    'amarelo': '#FFFF00',
    'preto': '#000000',
    'branco': '#FFFFFF',
    'cinza': '#808080',
    'laranja': '#FFA500',
    'roxo': '#800080',
    'rosa': '#FF1493',
    'marrom': '#A52A2A',
    'ciano': '#00FFFF',
    'magenta': '#FF00FF',
    'limão': '#00FF00',
    'azul claro': '#ADD8E6',
    'verde claro': '#90EE90',
    'dourado': '#FFD700',
    'prata': '#C0C0C0',
    'violeta': '#EE82EE',
    'índigo': '#4B0082',
    'turquesa': '#40E0D0',
    'salmon': '#FA8072',
    'chocolate': '#D2691E',
    'coral': '#FF7F50',
    'caqui': '#F0E68C',
};
export default class FloorApartmentComponent extends NavigationMixin(LightningElement) {
    @track currentPage = 0;
    @track totalPages = 0;
    itemsPerPage = 6;   
    maxFloorsPerPage = 4;
    @track floors = [];
    @api apartments;
    @track visibleFloors = [];
    @track empreendimentosBancoDados = [];
    @api filtrados;
    @track configuracoesCorres = [];
    @track cores = [];
    @track corDisponivel = '';
    @track corReservado = '';
    @track corVendida = '';
    @track idUnidadeSelecionada;

    _empreendimentoSelecionado;
    _filteredApartments

    @api
    set empreendimentoSelecionado(value) {
        this.floors = null;
        this.currentPage = 0;
        this.visibleFloors = null;
        
        this._empreendimentoSelecionado = value;
        this.buscarUnidadesDisponiveis(this.empreendimentoSelecionado); 
    }

    get empreendimentoSelecionado() {
        return this._empreendimentoSelecionado;
    }
    
    @api
    set filteredApartments(value){
        this._filteredApartments = value;
        this.resetComponent(this.filteredApartments)
    }

    get filteredApartments() {
        return this._filteredApartments;
    }


    @wire(configuracaoCoresEspelho)
    retornarCores({ error, data }) {
        if (data) {
            // Verifique se 'data' é um array
            if (Array.isArray(data)) {
                this.configuracoesCorres = data;
               
                // Verifique se colorMap está definido
                if (!colorMap) {
                    console.error('colorMap não está definido');
                    return;
                }
    
                // Mapeamento de cores com status e cor hexadecimal
               // Mapeamento de cores com status e cor hexadecimal
                this.cores = this.configuracoesCorres.map(corConfig => {
                    // Verifique se corConfig.Cor__c e corConfig.Status__c estão definidos
                    if (!corConfig.Cor__c || !corConfig.Status__c) {
                        console.error('corConfig.Cor__c ou corConfig.Status__c não estão definidos:', corConfig);
                        return {}; // Retornar um objeto vazio em vez de null
                    }

                    const corNome = corConfig.Cor__c.toLowerCase(); // Converter o nome da cor para minúsculas
                    const corHexadecimal = colorMap[corNome] || '#000000'; // Se não encontrar a cor, usar preto como padrão

                    return {
                        status: corConfig.Status__c, // Adicionar o status
                        corHexadecimal: corHexadecimal // Adicionar a cor hexadecimal
                    };
                }).filter(cor => cor.status && cor.corHexadecimal); // Filtrar objetos que possuem status e corHexadecimal
    

                
                this.pintarCores();
            } else {
                console.error('Dados recebidos não são um array:', data);
            }
        } else if (error) {
            console.error('Erro ao carregar cores:', error);
        }
    }

    
    showAlert(message) {
        console.log(
            `%c${message}`,
            'color: white; background-color: red; padding: 10px; border-radius: 5px; font-weight: bold;'
        );
    }
      
    @api
    updateFilteredApartments(filteredApartments) {
        this.filteredApartments = filteredApartments;

        if (!filteredApartments || filteredApartments.length === 0) {
            this.resetComponent(this.empreendimentoSelecionado);
        } else {
            this.atualizarMatriz(filteredApartments);
        }
    }


    atualizarMatriz(filteredApartments) {
        const allFloors = [...this.visibleFloors];
        
        this.visibleFloors = [];
        const floorMap = new Map();
    
        filteredApartments.forEach(unit => {

            const floorId = unit.andar;
    
            if (!floorMap.has(floorId)) {
                floorMap.set(floorId, {
                    id: 'floor-' + floorId,
                    andar: floorId,
                    apartments: []
                });
            }
    
            // Adiciona apartamentos ao andar correspondente
            let colorStyle = unit.color || ''; // Verifica a cor
            floorMap.get(floorId).apartments.push({
                id: unit.id,
                price: unit.price,
                valor: unit.valor,
                status: unit.status,
                rooms: unit.rooms,
                color: colorStyle,
                preco: unit.preco,
                quantidadeSuites: unit.quantidadeSuites,
                numeroQuartos: unit.numeroQuartos,
                metrosQuadrados: unit.metrosQuadrados,
                name: unit.name,
                empreendimento: unit.empreendimento,
                empreendimentoId: unit.Empreendimento__c ? unit.Empreendimento__c : 'Desconhecido' ,
                andar: unit.andar,
                tipoUnidade: unit.tipoUnidade,
                selected: unit.selected || false
            });
        });
    
            const floors = [];
        floorMap.forEach(floor => {
            const apartmentChunks = this.chunkArray(floor.apartments, this.itemsPerPage);
            apartmentChunks.forEach((chunk, index) => {
                floors.push({
                    id: floor.id + '-' + index,
                    andar: floor.andar,
                    apartments: chunk
                });
            });
        });
    
        // Ordena os andares por número
        floors.sort((a, b) => parseInt(a.andar) - parseInt(b.andar));
    
        // Atualiza visibleFloors com os andares filtrados
        this.visibleFloors = floors;
        this.totalPages = Math.ceil(floors.length / this.itemsPerPage); // Calcula o total de páginas
    }
    
    resetComponent(filteredApartments) {
        this.currentPage = 1;
        // this.visibleFloors.forEach(floor => {
        //     floor.apartments.forEach(apartment => {
        //         apartment.color = '';
        //     });
        // });

        this.loadUnidadesDisponiveis(filteredApartments);
    }

    
    buscarUnidadesDisponiveis(idEmpreendimento){
        if(idEmpreendimento === null || !idEmpreendimento){return;}

        retornarUnidadesDisponiveis({idEmpreendimento: idEmpreendimento})
        .then(data => {
                this.dispatchEvent(new CustomEvent('changeapartments', {
                    detail: data
                }));

            })
            .catch(error => {
                console.error('Erro ao carregar unidades disponíveis:', error);
            });
    }

    loadUnidadesDisponiveis(filteredApartments) {
        if(!filteredApartments){
            this.floors = null;
            this.currentPage = 0;
        }

        this.floors = this.structureFloors(filteredApartments);
        this.totalPages = Math.ceil(this.floors.length / this.maxFloorsPerPage);
        this.updateVisibleFloors();

    }
    



    
    updateVisibleFloors() {
        const startIdx = (this.currentPage - 1) * this.maxFloorsPerPage;
        const endIdx = startIdx + this.maxFloorsPerPage;
        this.visibleFloors = this.floors.slice(startIdx, endIdx);
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateVisibleFloors();
            this.pintarCores()
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updateVisibleFloors();
            this.pintarCores()
        }
    }

    truncateName(name, maxLength = 20) {
        return name.length > maxLength ? name.substring(0, maxLength) + '...' : name;
    }
    structureFloors(units) {
        let floors = [];
        let floorMap = new Map();
    
        let corDisponivel = '';
        let corReservado = '';
        let corVendida = '';
    
        this.configuracoesCorres.forEach(config => {
            switch (config.Status__c) {
                case 'Livre':
                    corDisponivel = config.Cor__c.toLowerCase(); 
                    break;
                case 'Reservada':
                    corReservado = config.Cor__c.toLowerCase(); 
                    break;
                case 'Vendida':
                    corVendida = config.Cor__c.toLowerCase(); 
                    break;
                default:
                    break;
            }
        });
    

    
        const corDisponivelRGB = colorMap[corDisponivel] || 'defaultColor'; // 'defaultColor' é uma cor padrão caso o nome não seja encontrado
        const corReservadoRGB = colorMap[corReservado] || 'defaultColor';
        const corVendidaRGB = colorMap[corVendida] || 'defaultColor';
    

    
        // Passo 1: Agrupar por Andares
        units.forEach(unit => {

            let floorId = unit.Andar__c;
            if (!floorMap.has(floorId)) {
                floorMap.set(floorId, {
                    id: 'floor-' + floorId,
                    andar: floorId,
                    apartments: []
                });
            }
    
            let colorStyle = '';
            if (unit.Status__c === 'Livre') {
                colorStyle ='background-color: ' + corDisponivelRGB + ';';
            } else if (unit.Status__c === 'Reservada') {
                colorStyle = 'background-color: ' + corReservadoRGB + ';';
            } else if (unit.Status__c === 'Vendida') {
                colorStyle = 'background-color: ' + corVendidaRGB + ';';
            }
    
            // Extrair os últimos dois dígitos do campo numeroUnidade
            let lastTwoDigits = this.pegarUltimosDoisNumeros(unit.NumeroDaUnidade__c);
    

    
            floorMap.get(floorId).apartments.push({
                id: unit.Id,
                preco: unit.PrecoLista__c,
                metrosQuadrados: unit.ValorM2__c,
                area: unit.Area__c,
                empreendimento: unit.Empreendimento__r ? unit.Empreendimento__r.Name : 'Desconhecido',
                empreendimentoId: unit.Empreendimento__c ? unit.Empreendimento__c : 'Desconhecido' ,
                diasVencimento: unit.Empreendimento__r ? unit.Empreendimento__r.DiasDeVencimentoDaParcela__c : '',
                bloco: unit.Bloco__r ? unit.Bloco__r.Name : 'Desconhecido',
                status: unit.Status__c,
                numeroQuartos: unit.NumeroQuartos__c,
                color: colorStyle,
                numeroUnidade: lastTwoDigits,  // Use os últimos dois dígitos
                tipo: unit.Tipo__c,
                quantidadeSuites: unit.NumeroDeSuites__c,
                name: this.truncateName(unit.Name),
                andar: unit.Andar__c,
                tipoUnidade: unit.RecordType ? unit.RecordType.Name : 'Desconhecido',
                selected: false
            });
        });
    
        // Passo 2: Agrupar por Andares e Chunking
        floorMap.forEach(floor => {
            // Ordenar apartamentos dentro de cada andar pelo número completo da unidade
            floor.apartments.sort((a, b) => {
                return parseInt(a.numeroUnidade) - parseInt(b.numeroUnidade);
            });
    
            // Dividir em grupos de 6 apartamentos
            const apartmentChunks = this.chunkArray(floor.apartments, 6);
    
            apartmentChunks.forEach((chunk, index) => {
                floors.push({
                    id: floor.id + '-' + index,
                    andar: floor.andar,
                    apartments: chunk
                });
            });
        });
    
        // Ordenar por Andar
        floors.sort((a, b) => {
            return parseInt(a.andar) - parseInt(b.andar);
        });
    
        // Atualizar visibleFloors com todos os andares estruturados
        this.visibleFloors = floors;
    
        // Chamar pintarCores para garantir que todas as cores sejam aplicadas
        this.pintarCores();
    
        const apartmentsEvent = new CustomEvent('apartmentschange', {
            detail: floors
        });
        this.dispatchEvent(apartmentsEvent);
        return floors;
    }
    
    pintarCores() {
        if (!this.cores || !this.visibleFloors) {
            console.error('this.cores ou this.visibleFloors não estão definidos');
            return;
        }
    
        const floorMap = new Map();
    
        this.cores.forEach(cor => {
            floorMap.set(cor.status, cor.corHexadecimal);
        });
    
        this.visibleFloors.forEach(floor => {
            floor.apartments.forEach(apartment => {
                const corHexadecimal = floorMap.get(apartment.status) || '#FFFFFF'; // Define branco como cor padrão
                apartment.color = `background-color: ${corHexadecimal};`;
            });
        });

        const apartmentsEvent = new CustomEvent('apartmentschange', {
            detail: this.visibleFloors
        });
        this.dispatchEvent(apartmentsEvent);
    }
   
    pegarUltimosDoisNumeros(numero) {
        numero = String(numero);
        if (numero.length >= 2) {
            return numero.slice(-2);
        }
        return '';
    }
    
    
    chunkArray(array, chunkSize) {
        const results = [];
        for (let i = 0; i < array.length; i += chunkSize) {
            results.push(array.slice(i, i + chunkSize));
        }
        return results;
    }
    

    navigateToApartment(event) {
        const apartmentId = event.currentTarget.dataset.id;
        event.target.style.borderBottom = '2px solid black';
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: apartmentId,
                objectApiName: 'Apartment__c',
                actionName: 'view'
            }
        });
    }

    showUnderline(event) {
        event.target.style.borderBottom = '1px solid black';
        event.target.style.display = 'inline-block';
        event.target.style.cursor = 'zoom-in';
    }
    
    hideUnderline(event) {
        event.target.style.borderBottom = 'none';
    }


    handleSelecionarUnidade(event){
       
        let target = event.currentTarget;
        let unidadeSelecionada;
        let unidadeAnterior;

      

        this.visibleFloors.forEach(visibleFloor =>{
                if(unidadeSelecionada){return;}
                unidadeSelecionada = visibleFloor.apartments.find(unidade => unidade.id === target.dataset.id)
        })

        if(this.idUnidadeSelecionada){
            this.visibleFloors.forEach(visibleFloor =>{
                if(unidadeAnterior){return;}
                 unidadeAnterior = visibleFloor.apartments.find(unidade => unidade.id === this.idUnidadeSelecionada)
            })

            if(unidadeAnterior){
                unidadeAnterior.selected = false;
            }
        }

        unidadeSelecionada.selected = true;
        this.idUnidadeSelecionada = unidadeSelecionada.id;
  
        this.dispatchEvent(new CustomEvent('selecionarunidade', {
            detail: {produtoSelecionado: unidadeSelecionada}
        }));
    }
}