import { LightningElement, track } from 'lwc';
import buscarTodosCorretores from '@salesforce/apex/ConciergeController.buscarTodosCorretores';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class DistribuirCorretorModal extends LightningElement {
    @track corretores = [];
    @track corretorSelecionado = null;
    @track searchTerm = '';

    connectedCallback() {
        this.carregarCorretores();
    }

    carregarCorretores() {
        buscarTodosCorretores()
            .then(result => {
                this.corretores = result;
                console.log("Corretores encontrados: " + JSON.stringify(result));
            })
            .catch(error => {
                console.error("Erro ao buscar corretores: " + error);
            });
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSave() {
        if (!this.corretorSelecionado) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Erro ao salvar',
                message: 'Selecione um corretor para salvar.',
                variant: 'error'
            }));
            console.error('Nenhum corretor selecionado para salvar.');
            return;
        }
    
        console.log("Corretor selecionado: " + JSON.stringify(this.corretorSelecionado));
    
        this.dispatchEvent(new CustomEvent('salvar', {
            detail: {
                corretorId: this.corretorSelecionado.Id,
                nomeCorretor: this.corretorSelecionado.Apelido__c
            }
        }));
    
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSearch(event) {
        this.searchTerm = event.target.value;
        if (!this.searchTerm.trim()) {
            this.carregarCorretores();
            return;
        } else {
            buscarTodosCorretores()
                .then(result => {
                    console.log("Resultado encontrado: " + JSON.stringify(result));
                    this.corretores = result.filter(corretor =>
                        corretor.Apelido__c.toLowerCase().includes(this.searchTerm.toLowerCase())
                    );
                })
                .catch(error => {
                    console.log("Erro ao buscar corretores: " + error); 
                    console.error("Erro ao buscar corretores: " + error);
                });
        }
    }

    handleRadioChange(event) {
        const corretorId = event.target.dataset.id;
        this.corretorSelecionado = this.corretores.find(corretor => corretor.Id === corretorId);
    }

    handleNameClick(event) {
        const corretorId = event.target.dataset.id;
        this.corretorSelecionado = this.corretores.find(corretor => corretor.Id === corretorId);
        const inputs = this.template.querySelectorAll('lightning-input');
        inputs.forEach(input => {
            const inputId = input.dataset.id;
            if (inputId && inputId === this.corretorSelecionado.Id) {
                input.checked = true; 
            } else {
                input.checked = false; 
            }
        });

        //
        this.updateRadioSelection(corretorId);
    }

    handleRemoveCorretor() {
        this.corretorSelecionado = null;
        this.updateRadioSelection(null); // Desmarcar todos
    }

    updateRadioSelection(corretorId) {
        // Se a seleção for nula, desmarcar todos os botões de rádio
        const radios = this.template.querySelectorAll('lightning-input[type="radio"]');
       
    }
}