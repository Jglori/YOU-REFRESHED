import { LightningElement, track } from 'lwc';

export default class EspelhoDeVendas extends LightningElement {
    @track apartments = [];
    @track filteredApartments = []; // Corrigido o nome da variável para 'filteredApartments'
    
    @track empreendimentoSelecionado;

    get getEmpreendimentoSelecionado(){
        return this.empreendimentoSelecionado;
    }

    get getFitleredApartments(){
        return this.filteredApartments;
    }

    selectEmpreendimento(event){
        const idEmpreendimento = event.detail.idEmpreendimento;

        this.empreendimentoSelecionado = idEmpreendimento;
    }

    changeApartments(event){
        this.apartments = event.detail
    }


    handleFilterUpdate(event) {
        this.filteredApartments = event.detail;
    }
    

    
    selecionarUnidade(event){
        this.dispatchEvent(new CustomEvent('selecionarunidade', {
            detail: event.detail
        }));
    }

    
}