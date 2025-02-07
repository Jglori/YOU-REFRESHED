import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getObjects from '@salesforce/apex/ObjectController.getObjects';
import getFields from '@salesforce/apex/ObjectController.getFields';
import getReferenceFields from '@salesforce/apex/ObjectController.getReferenceFields';
import getSubReferenceFields from '@salesforce/apex/ObjectController.getSubReferenceFields';

const columns = [
    { label: 'Rotulo', fieldName: 'rotulo' },
    { label: 'API', fieldName: 'api'},
    { label: 'Variável', fieldName: 'variavel'},
    {
        type: 'button-icon',
        fixedWidth: 60,
        typeAttributes: {
            iconName: 'utility:copy',
            name: 'copiar_variavel',
            title: 'Copiar',
            variant: 'bare',
            alternativeText: 'copiar',
            disabled: false,
        }
    },
    {
        type: 'button-icon',
        fixedWidth: 60,
        typeAttributes: {
            iconName: { fieldName: 'lookup' },
            name: 'ir_relacionamento',
            title: 'Ir para relacionamento',
            variant: 'bare',
            alternativeText: 'Ir para relacionamento',
            disabled: { fieldName: 'inativo' },
        }
    },

];

export default class GeradorVariaveis extends LightningElement {

    //controle de tela
    @track spinner = false;
    @track bloqueioEdicaoObjeto = false;
    columns = columns;

    //dados do objeto
    @track objetosCarregados = false;
    @track listaObjetos = [];
    @track objetoSelecionado = '';
    @track rotuloObjetoSelecionado;

    //dados dos campos
    @track carregandoCampos = false;
    @track camposCarregados = false;
    @track listaCampos = [];
    @track rotuloCampoSelecionado;

    //dados relacionamentos 1º Nivel
    @track carregandoRelacionamento = false;
    @track relacionamentosCarregados = false;
    @track listaRelacionamentos = [];
    @track valorRelacionamentoSelecionado = '';

    //dados relacionamentos 2º Nivel
    @track carregandoRelacionamento2 = false;
    @track relacionamentoNivel2Carregados = false;
    @track listaRelacionamentosNivel2 = [];
    @track valorRelacionamentoNivel2Selecionado = '';
    @track rotuloRelacionamentoNivel2Selecionado;
    @track objetoNivel2;

    //dados relacionamentos 3º Nivel
    @track carregandoRelacionamento3 = false;
    @track relacionamentoNivel3Carregados = false;
    @track listaRelacionamentosNivel3 = [];
    @track valorRelacionamentoNivel3Selecionado = '';
    @track rotuloRelacionamentoNivel3Selecionado;
    @track objetoNivel3;

    //dados relacionamentos 4º Nivel
    @track carregandoRelacionamento4 = false;
    @track relacionamentoNivel4Carregados = false;
    @track listaRelacionamentosNivel4 = [];
    @track valorRelacionamentoNivel4Selecionado = '';
    @track rotuloRelacionamentoNivel4Selecionado;
    @track objetoNivel4;

    //dados relacionamentos 5º Nivel
    @track carregandoRelacionamento5 = false;
    @track relacionamentoNivel5Carregados = false;
    @track listaRelacionamentosNivel5 = [];
    @track valorRelacionamentoNivel5Selecionado = '';
    @track rotuloRelacionamentoNivel5Selecionado;
    @track objetoNivel5;

    connectedCallback(){
        this.getObjects();
    }

    //Parent Handlers
    handleChangeObjeto(event) {
        this.objetoSelecionado = event.detail.value;
    }

    handleClickObjeto(){
        this.rotuloObjetoSelecionado = this.obterRotulo(this.listaObjetos, this.objetoSelecionado);
        this.bloqueioEdicaoObjeto = true;
        this.getFields();
    }

    handleClickLimparObjeto(){
        this.limpeza(0);
    }

    handleDeleteRelacionamento1(){
        this.limpeza(1)
    }

    handleDeleteRelacionamento2(){
        this.limpeza(2)
    }

    handleDeleteRelacionamento3(){
        this.limpeza(3)
    }

    handleDeleteRelacionamento4(){
        this.limpeza(4)
    }

    handleDeleteRelacionamento5(){
        this.limpeza(5)
    }

    handleRowAction(event) {
        var action = event.detail.action;
        var row = event.detail.row;
        switch (action.name) {
            case 'copiar_variavel':
                this.copiarVariavel(row.variavel);
                break;
            case 'ir_relacionamento':
                if(row.metodo == 'relacionamento nivel 1'){
                    this.valorRelacionamentoSelecionado = row.api;
                    this.rotuloCampoSelecionado = this.obterRotulo(this.listaObjetos, row.objeto);
                    this.getReferenceFields1(row.api, this.objetoSelecionado);
                    break;
                }
                if(row.metodo == 'relacionamento nivel 2'){
                    this.valorRelacionamentoNivel2Selecionado = row.api;
                    this.getReferenceFields2(this.objetoSelecionado,  this.valorRelacionamentoSelecionado, row.api);
                    break;
                }
                if(row.metodo == 'relacionamento nivel 3'){
                    this.valorRelacionamentoNivel3Selecionado = row.api;
                    this.getReferenceFields3(this.objetoNivel2,  this.valorRelacionamentoNivel2Selecionado, row.api);
                    break;
                }
                if(row.metodo == 'relacionamento nivel 4'){
                    this.valorRelacionamentoNivel4Selecionado = row.api;
                    this.getReferenceFields4(this.objetoNivel3,  this.valorRelacionamentoNivel3Selecionado, row.api);
                    break;
                }
                if(row.metodo == 'relacionamento nivel 5'){
                    this.valorRelacionamentoNivel5Selecionado = row.api;
                    this.getReferenceFields5(this.objetoNivel4,  this.valorRelacionamentoNivel4Selecionado, row.api);
                    break;
                }
                break;
            default:
                console.log('error')
                break;
        }
    }
   
    //metodos auxiliares
    obterRotulo(listaOpcoes, apiSelecionado){
        let retorno = 'API invalida';
        listaOpcoes.forEach(elemento =>{
            if(elemento.value == apiSelecionado){
                retorno = elemento.label;
            }
        })
        return retorno
    }

    alterarStringRelacionameto(string){
            if(string.endsWith('Id')){
                return string.slice(0, -2);
            }
            if(string.endsWith('__c')){
                 return string.slice(0, -1) + 'r';
            } 
            return string;   
    }

    monstraMessagem(titulo, messagem, variante) {
        const evt = new ShowToastEvent({
          title: titulo,
          message: messagem,
          variant: variante,
        });
        this.dispatchEvent(evt);
    }

    copiarVariavel(valor) {
        let input = document.createElement("input");
        input.value = valor;
        document.body.appendChild(input);
        input.focus();
        input.select();
        document.execCommand("Copy");
        input.remove();
        this.monstraMessagem('Sucesso', 'Variavel copiada para área de transferência', 'success');

    }


    limpeza(opcao){
        switch(opcao){
            case 0:
                //limpeza total do componente
                this.objetoSelecionado = '';
                this.bloqueioEdicaoObjeto = false
                this.listaCampos = [];
                this.camposCarregados = false;
                this.relacionamentosCarregados = false;
                this.listaRelacionamentos = [];
                this.relacionamentoNivel2Carregados = false;
                this.listaRelacionamentosNivel2 = [];
                this.relacionamentoNivel3Carregados = false;
                this.listaRelacionamentosNivel3 = [];
                this.relacionamentoNivel4Carregados = false;
                this.listaRelacionamentosNivel4 = [];
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
                break;
            case 1:
                //limpeza de dados de relacionamento nivel 1 e adiante
                this.relacionamentosCarregados = false;
                this.listaRelacionamentos = [];
                this.relacionamentoNivel2Carregados = false;
                this.listaRelacionamentosNivel2 = [];
                this.relacionamentoNivel3Carregados = false;
                this.listaRelacionamentosNivel3 = [];
                this.relacionamentoNivel4Carregados = false;
                this.listaRelacionamentosNivel4 = [];
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
                break;
            case 2:
                //limpeza de dados de relacionamento nivel 2 e adiante
                this.relacionamentoNivel2Carregados = false;
                this.listaRelacionamentosNivel2 = [];
                this.relacionamentoNivel3Carregados = false;
                this.listaRelacionamentosNivel3 = [];
                this.relacionamentoNivel4Carregados = false;
                this.listaRelacionamentosNivel4 = [];
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
                break;
            case 3:
                //limpeza de dados de relacionamento nivel 3 e adiante
                this.relacionamentoNivel3Carregados = false;
                this.listaRelacionamentosNivel3 = [];
                this.relacionamentoNivel4Carregados = false;
                this.listaRelacionamentosNivel4 = [];
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
                break;
            case 4:
                //limpeza de dados de relacionamento nivel 4 e adiante
                this.relacionamentoNivel4Carregados = false;
                this.listaRelacionamentosNivel4 = [];
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
                break;
            case 5:
                //limpeza de dados de relacionamento nivel 5
                this.relacionamentoNivel5Carregados = false;
                this.listaRelacionamentosNivel5 = [];
            default:
                console.log('Error');
                break;

        }
    }

    //metodos Apex
    getObjects(){
        getObjects()
            .then(result => {
                for (let key of result) {
                    this.listaObjetos.push({
                        label:key.Label + ' (API: ' + key.ApiName + ')', 
                        value:key.ApiName
                    });
                }
                this.objetosCarregados = true;
            })
            .catch(error => {
                console.error(error);
            });
    }

    getFields() {
        this.carregandoCampos = true;
        getFields({objectName: this.objetoSelecionado}) 
            .then(result => {
                for (let key of result) {
                    this.listaCampos.push({ 
                        rotulo:key.Label, 
                        api:key.ApiName, 
                        variavel: this.alterarStringRelacionameto(this.objetoSelecionado)  + '.' + key.ApiName, 
                        lookup: key.Type == 'REFERENCE'?'utility:arrow_right':'', 
                        inativo: key.Type == 'REFERENCE'? false:true,
                        metodo: 'relacionamento nivel 1',
                    });  
                 }
                 this.carregandoCampos = false;
                 this.camposCarregados = true;
            })
            .catch(error => {
                this.carregandoCampos = false;
                console.error(error);
            });
    }

    getReferenceFields1(campo, objeto){
        this.carregandoRelacionamento = true;
        this.limpeza(1);
        
        getReferenceFields({objectName: objeto, fieldName: campo}) 
        .then(result => {

            const obj = Object.keys(result)[0]; 
            result[obj].forEach(field => {
                this.listaRelacionamentos.push({ 
                    rotulo:field.Label, 
                    api:field.ApiName, 
                    variavel: this.alterarStringRelacionameto(objeto) + '.' + this.alterarStringRelacionameto(campo) + '.' + field.ApiName,
                    lookup: field.Type == 'REFERENCE'?'utility:arrow_right':'', 
                    inativo: field.Type == 'REFERENCE'? false:true,
                    metodo: 'relacionamento nivel 2',
                });
                this.rotuloCampoSelecionado = this.obterRotulo(this.listaObjetos, obj);
            });
            
            this.carregandoRelacionamento = false;
            this.relacionamentosCarregados = true;
        })
        .catch(error => {
            console.error('Error'+ error);
        });
    }

    getReferenceFields2(objeto, campo, relacionamento){
        this.carregandoRelacionamento2 = true;
        this.limpeza(2);
        getSubReferenceFields({objectName: objeto, fieldName: campo,  relationship: relacionamento})
            .then(result => {
                 
                result.values.forEach(field => {
                    console.log(field);
                    
                    this.listaRelacionamentos.push({ 
                        rotulo:field.Label, 
                        api:field.ApiName, 
                        variavel: this.alterarStringRelacionameto(objeto) + '.' 
                                + this.alterarStringRelacionameto(campo) + '.' 
                                + this.alterarStringRelacionameto(relacionamento) + '.' 
                                + field.ApiName,
                        lookup: field.Type == 'REFERENCE'?'utility:arrow_right':'', 
                        inativo: field.Type == 'REFERENCE'? false:true,
                        metodo: 'relacionamento nivel 3',
                    });
                    this.objetoNivel2 = result.objectMetadata;
                    this.rotuloRelacionamentoNivel2Selecionado = this.obterRotulo(this.listaObjetos, result.subObjectMetadata);
                });
                this.carregandoRelacionamento2 = false;
                this.relacionamentoNivel2Carregados = true;
            })
            .catch(error => {
                console.error('Error:', error);
            }); 
    }

    getSubReferenceFields3(objeto, campo, relacionamento){
        this.carregandoRelacionamento3 = true;
        this.limpeza(3);
        getSubReferenceFields({objectName: objeto, fieldName: campo,  relationship: relacionamento})
            .then(result => {
                result.values.forEach(field => {
                    this.listaRelacionamentosNivel3.push({  
                        rotulo:field.Label, 
                        api:field.ApiName, 
                        variavel: this.alterarStringRelacionameto(this.objetoSelecionado) + '.' 
                            + this.alterarStringRelacionameto(this.valorRelacionamentoSelecionado)  + '.' 
                            + this.alterarStringRelacionameto(this.valorRelacionamentoNivel2Selecionado)+ '.' 
                            + this.alterarStringRelacionameto(this.valorRelacionamentoNivel3Selecionado) + '.'
                            + field.ApiName,
                        lookup: field.Type == 'REFERENCE'?'utility:arrow_right':'', 
                        inativo: field.Type == 'REFERENCE'? false:true,
                        metodo: 'relacionamento nivel 4'
                    });
                    this.objetoNivel3 = result.objectMetadata;
                    this.rotuloRelacionamentoNivel3Selecionado = this.obterRotulo(this.listaObjetos, result.subObjectMetadata);                    
                })
                this.carregandoRelacionamento3 = false;
                this.relacionamentoNivel3Carregados = true;
            })
            .catch(error => {
                console.log('Error'+ JSON.stringify(error));
            }); 

    }

    getSubReferenceFields4(objeto, campo, relacionamento){
        this.carregandoRelacionamento4 = true;
        this.limpeza(4);
        getSubReferenceFields({objectName: objeto, fieldName: campo,  relationship: relacionamento})
            .then(result => {
                result.values.forEach(field => {
                    this.listaRelacionamentosNivel4.push({  
                        rotulo:field.Label, 
                        api:field.ApiName, 
                        variavel: this.alterarStringRelacionameto(this.objetoSelecionado) + '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoSelecionado)  + '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel2Selecionado)+ '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel3Selecionado)+ '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel4Selecionado)+ '.' 
                        + field.ApiName,
                        lookup: field.Type == 'REFERENCE'?'utility:arrow_right':'', 
                        inativo: field.Type == 'REFERENCE'? false:true,
                        metodo: 'relacionamento nivel 5'
                    });
                    this.objetoNivel4 = result.objectMetadata;
                    this.rotuloRelacionamentoNivel4Selecionado = this.obterRotulo(this.listaObjetos, result.subObjectMetadata);
                })
                this.carregandoRelacionamento4 = false;
                this.relacionamentoNivel4Carregados = true;
            })
            .catch(error => {
                console.log('Error'+ JSON.stringify(error));
            }); 

    }

    getSubReferenceFields5(objeto, campo, relacionamento){
        this.carregandoRelacionamento5 = true;
        this.limpeza(5);
        getSubReferenceFields({objectName: objeto, fieldName: campo,  relationship: relacionamento})
            .then(result => {
                result.values.forEach(field => {
                    this.listaRelacionamentosNivel5.push({  
                        rotulo:field.Label, 
                        api:field.ApiName, 
                        variavel: this.alterarStringRelacionameto(this.objetoSelecionado) + '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoSelecionado)  + '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel2Selecionado)+ '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel3Selecionado)+ '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel4Selecionado)+ '.' 
                        + this.alterarStringRelacionameto(this.valorRelacionamentoNivel5Selecionado)+ '.' 
                        + field.ApiName,
                        lookup: '', 
                        inativo: true
                        
                    });
                    this.objetoNivel5 = result.objectMetadata;
                    this.rotuloRelacionamentoNivel5Selecionado = this.obterRotulo(this.listaObjetos, result.subObjectMetadata);
                });
                this.carregandoRelacionamento5 = false;
                this.relacionamentoNivel5Carregados = true;
            })
            .catch(error => {
                console.log('Error'+ JSON.stringify(error));
            }); 

    }
}