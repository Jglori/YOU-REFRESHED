import { LightningElement, api, wire } from 'lwc';

import PlaceholderImg from '@salesforce/resourceUrl/PlaceholderImg';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WhatsAppMensagem extends LightningElement {
    @api lead;
    @api mensagem;
    @api recordId;

    imagem = PlaceholderImg;

    @wire(CurrentPageReference)
    currentPageReference;

    get userTimeZone() {
        return this.currentPageReference.state.userTimeZone || 'America/Sao_Paulo';
    }
    
    get mensagemRemetente() {
        return String(this.mensagem.de) === String(this.lead.chaveExternaWhatsApp);
    }

    get listItemClassName() {
        return `slds-chat-listitem ${this.mensagemRemetente ? 'slds-chat-listitem_inbound' : 'slds-chat-listitem_outbound'}`;
    }

    get messageTextClassName() {  
        return `slds-chat-message__text ${this.mensagemRemetente ? 'slds-chat-message__text_inbound' : 'slds-chat-message__text_outbound'}`;
    }

    get messageFileClassName() {
        return `slds-chat-message__file ${this.mensagemRemetente ? 'slds-chat-message__file_inbound' : 'slds-chat-message__file_outbound'}`;
    }

    get messageImageClassName() {
        return `slds-chat-message__image ${this.mensagemRemetente ? 'slds-chat-message__image_inbound' : 'slds-chat-message__image_outbound'}`;
    }

    get texto() {
        return this.mensagem.tipo === 'text';
    }
    
    get image() {
        return this.mensagem.tipo === 'image';
    }
    
    get audio() {
        return this.mensagem.tipo === 'audio';
    }

    get document() {
        return this.mensagem.tipo === 'document';
    }

    get temConteudo() {
        return Boolean(this.mensagem.conteudo);
    }
    
    get urlAudio(){
        return this.mensagem.urlMidia;
    }

    baixarArquivo() {
        if (this.mensagem && this.mensagem.urlMidia) {
            const ancora = document.createElement('a');
            ancora.download = this.mensagem.nomeArquivo;
            ancora.href = this.mensagem.urlMidia;
            
            document.body.appendChild(ancora);
    
            ancora.click();
    
            document.body.removeChild(ancora);
        } else {
            console.error('Não foi possível baixar o arquivo: mensagem ou URL de mídia ainda não disponivel.');
            const event = new ShowToastEvent({
                title: 'Erro',
                message: 'Não foi possível baixar o arquivo: mensagem ou URL de mídia ainda não disponivel.',
                variant: 'error',
            });
            this.dispatchEvent(event);
        }
    }
    
}