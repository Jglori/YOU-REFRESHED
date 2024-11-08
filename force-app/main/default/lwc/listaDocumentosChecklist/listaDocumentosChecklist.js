import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDeliveredDocumentsByAccountId from '@salesforce/apex/DocumentController.getDeliveredDocumentsByAccountId';
import retornarContactId from '@salesforce/apex/DocumentController.getContactsByAccountId';
import salvarImagem from '@salesforce/apex/DocumentController.salvarImagem';
import deletar from '@salesforce/apex/DocumentController.deletarDocumento';
import recuperar from '@salesforce/apex/DocumentController.recuperar';
import profissao from '@salesforce/apex/DocumentController.getContactRoles';
import documentos from '@salesforce/apex/DocumentController.buscarDocumento'
import documentosEntregues from '@salesforce/apex/DocumentController.verificarDocumentosEntreguesIndividuais'
import { CurrentPageReference } from 'lightning/navigation';

export default class ListaDocumentosChecklist extends LightningElement {
    @track accountId;
    @track documents = [];
    @track hasDocuments = false;
    @track showModal = false;
    @track showConfirmationModal = false; // Controla a exibição do modal de confirmação
    @track selectedDocumentText;
    @track selectedDocumentDescription;
    @track documentImageUrl;
    @track tipoModal = 'OK';
    @track contactId;
    @track texto = ''; // Mensagem do modal de confirmação

    @wire(CurrentPageReference)
    setPageRef(pageRef) {
        if (pageRef && pageRef.attributes) {
            this.accountId = pageRef.attributes.recordId;
            console.log("Id de conta " + pageRef.attributes.recordId);
            
            this.loadDocuments();
        }
    }

    loadDocuments() {
        getDeliveredDocumentsByAccountId({ accountId: this.accountId })
            .then(result => {
                console.log("Documentos " + JSON.stringify(result));
                this.documents = this.createDocumentList(result);
                this.hasDocuments = this.documents.length > 0;
                this.idContact();
            })
            .catch(error => {
                console.error('Erro ao carregar documentos:', error);
            });
    }

    idContact() {
        retornarContactId({ accountId: this.accountId })
            .then(result => {
                if (result.length > 0) {
                    this.contactId = result[0].Id; // Certifica-se de que result[0] existe
                    this.buscarDados(); // Move a chamada para buscarDados aqui
                }
            })
            .catch(error => {
                console.error('Erro ao obter contato:', error);
            });
    }
    
    buscarDados(){
        console.log("id de contato em buscar dados " + this.contactId);
        profissao({ contactId: this.contactId })
            .then(result => {
                if (result.length > 0) {
                    this.profissao = result[0].Role;
                    console.log("Profissão " + this.profissao);
                    this.documentacao();
                }
            })
            .catch(error => {
                console.error('Erro ao obter dados da profissão:', error);
            });
    }

    documentacao(){
        documentos({ papelContato: this.profissao })
            .then(result => {
                console.log("Resultado da consulta de documentos: " + JSON.stringify(result));
                this.documents = this.createDocumentList(result);
                this.hasDocuments = this.documents.length > 0;
                this.documentosEntregues();
            })
            .catch(error => {
                console.error("Erro ao obter documentos:", error);
            });
    }
    
    
    createDocumentList(documents) {
        console.log(documents);
        return documents.map(doc => ({
            id: doc.Id,
            label: doc.Name, 
            icon: 'doctype:document',
            completed: false,
            contactId: doc.Contato__c 
        }));
    }
    

    generateUniqueId() {
        return '_' + Math.random().toString(36).substr(2, 9);
    }

    handleViewClick(event) {
        const nomeDocumento = event.target.dataset.nomeId;
        
        console.log("Account id " + this.contactId)
        console.log("id " + this.contactId)
        console.log("id b " + this.accountId)
        console.log("Nome do documento " + nomeDocumento)
        this.tipoModal = "OK";
        const modal = this.template.querySelector('.modal');
        const modalContent = this.template.querySelector('.slds-modal__content');
        
        this.documentImageUrl = ''; 
        
        recuperar({ contactId: this.contactId, nomeDocumento: nomeDocumento })
            .then(result => {
                console.log("Resultado: " + JSON.stringify(result));
                
                let parsedResult;
                try {
                    parsedResult = JSON.parse(result);
                } catch (e) {
                    console.error("Erro ao analisar o JSON:", e);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erro',
                            message: 'Erro ao processar a resposta do servidor.',
                            variant: 'error',
                        })
                    );
                    return;
                }
    
                console.log("Parsed Result: " + JSON.stringify(parsedResult));
                console.log("Mensagem: '" + parsedResult.message + "'");
                
                const message = parsedResult.message ? parsedResult.message.trim() : '';
                if (message === "Documento não encontrado.") {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Ops, houve um problema!',
                            message: 'Documento não encontrado.',
                            variant: 'warning',
                        })
                    );
                } else if (parsedResult.mimeType === 'image/pdf') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Ops, houve um problema!',
                            message: 'Documentos do tipo PDF não podem ser visualizados. Faça o download para visualizar.',
                            variant: 'warning',
                        })
                    );
                } else if (parsedResult.documentUrl) {
                    // Exibir imagem se for um URL de documento
                    const timestamp = new Date().getTime();
                    this.documentImageUrl = `${parsedResult.documentUrl}?t=${timestamp}`;
                    
                    modalContent.innerHTML = `<img src="${this.documentImageUrl}" alt="${nomeDocumento}" style="width: 100%; height: auto;" />`;
                    modal.style.display = 'block'; 
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao obter a imagem do documento. Por favor, tente novamente mais tarde.',
                        variant: 'error',
                    })
                );
            });
    }

    handleDownloadClick(event) {
        const contactId = event.target.dataset.contactId;
        const nomeDocumento = event.target.dataset.nomeId;

        baixar({ contactId: this.contactId, nomeDocumento: nomeDocumento })
            .then(result => {
                if (result.startsWith('/sfc/servlet.shepherd/version/download/')) {
                    window.location.href = result;
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Ops, houve um problema!',
                            message: result,
                            variant: 'warning',
                        }),
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao obter o documento para download. Por favor, tente novamente mais tarde.',
                        variant: 'error',
                    }),
                );
            });
    }

    deletarArquivo(event) {
        const modal = this.template.querySelector('.modal');
        const modalContent = this.template.querySelector('.slds-modal__content');
        const modalHeader = this.template.querySelector('.slds-modal__header');
        const nomeDocumento = event.target.dataset.nomeId;
        this.selectedDocumentDescription = nomeDocumento;

        modalHeader.innerText = 'Deletar Documento';
        this.tipoModal = 'Deletar o arquivo';
        modalContent.innerText = `Tem certeza que deseja apagar o documento ?`;
        modal.style.display = 'block';
        this.selectedDocumentText = nomeArquivo;
        this.texto = 'Tem certeza que deseja apagar o documento?';
        this.showConfirmationModal = true;

      
    }


    handleSaveOptional() {
        if (this.tipoModal === "Deletar o arquivo") {
            this.deletarDocumento(this.selectedDocumentDescription);
        }
        
        if (this.tipoModal === "OK") {
            const modal = this.template.querySelector('.modal');
            modal.style.display = 'none';
        }
    }


    deletarDocumento(descricaoDocumento) {
        deletar({ accountId: this.contactId, fileName: descricaoDocumento })
        .then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Sucesso!',
                    message: 'Documento deletado com sucesso',
                    variant: 'success',
                }),
            );

            const modal = this.template.querySelector('.modal');
            modal.style.display = 'none';

            window.location.reload();
        })
        .catch(error => {
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Ops, houve um erro do nosso lado!',
                    message: 'Erro ao deletar o arquivo, tente novamente mais tarde',
                    variant: 'error',
                }),
            );
        });
    }

    handleCancelConfirmationClick() {
        this.showConfirmationModal = false; // Fechar o modal de confirmação
    }

    handleCancelClick() {
        console.log("entrei no metodo");
    
        const modal2 = this.template.querySelector('.modal');
        modal2.style.display = 'none';

        this.showModal = false;
    }
    
    handleUploadClick(event) {
        const documentId = event.target.dataset.id;
        const nomeArquivo = event.target.dataset.nomeId;
        
        console.log("handleUploadClick - documentId: ", documentId);
        console.log("handleUploadClick - nomeArquivo: ", nomeArquivo);
        
        const input = this.template.querySelector('input[type="file"]');
        input.dataset.id = documentId;
        input.dataset.nomeId = nomeArquivo; 
        input.click();
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const nomeDocumento = event.target.dataset.nomeId;
            const nomeArquivo = file.name;
            
            console.log("handleFileChange - nomeDocumento: ", nomeDocumento);
            console.log("handleFileChange - nomeArquivo: ", nomeArquivo);
            console.log("handleFileChange - file: ", file);
            
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                console.log("handleFileChange - base64 data: ", base64);
                this.saveImage(base64, nomeArquivo, nomeDocumento);
            };
            reader.readAsDataURL(file);
        } else {
            console.log("handleFileChange - No file selected.");
        }
    }
    
    saveImage(base64, fileName, nomeDocumento) {
        console.log("saveImage - base64: ", base64);
        console.log("saveImage - fileName: ", fileName);
        console.log("saveImage - nomeDocumento: ", nomeDocumento);
        console.log("saveImage - contactId: ", this.contactId);
        
        salvarImagem({ 
            contatoId: this.contactId, 
            fileName: fileName, 
            base64Data: base64,
            nomeArquivo: nomeDocumento 
        })
        .then(() => {
            console.log("saveImage - Imagem salva com sucesso.");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Imagem salva com sucesso',
                    variant: 'success',
                }),
            );
            this.documentosEntregues();
        })
        .catch(error => {
            console.log("saveImage - Erro ao salvar a imagem: ", JSON.stringify(error));
            const errorMessage = error.body && error.body.message ? error.body.message : 'Erro desconhecido';
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: `Erro ao salvar a imagem: ${errorMessage}`,
                    variant: 'error',
                }),
            );
        });
    }
    
    documentosEntregues() {
        // Chama o método Apex para verificar os documentos entregues
        documentosEntregues({ contatoId: this.contactId })
            .then(result => {
                console.log("Resultado " + JSON.stringify(result));
                
                // Atualiza o status dos documentos com o resultado obtido
                return this.atualizarStatusDocumentos(result);
            })
            .then(() => {
                // Se precisar fazer algo depois de atualizar o status dos documentos
                console.log("Status dos documentos atualizado com sucesso.");
            })
            .catch(error => {
                console.log("Erro " + JSON.stringify(error));
            });
    }
    
    atualizarStatusDocumentos(result) {
        // Itera sobre o resultado para encontrar o status dos documentos
        for (const contatoId in result) {
            const documentos = result[contatoId];
    
            // Atualiza a lista de documentos com base no status retornado
            this.documents.forEach(doc => {
                // Encontra o status do documento atual
                const status = documentos.find(d => d.documentName === doc.label);  // Usa `doc.label` para comparação
    
                // Se o status for encontrado, atualiza a propriedade `completed`
                if (status) {
                    doc.completed = status.isDelivered;
                } else {
                    // Caso não encontre o status, pode ser que o nome do documento não esteja correto
                    console.warn(`Documento não encontrado: ${doc.label}`);
                }
            });
        }
    
        // Força a atualização das propriedades rastreadas
        this.documents = [...this.documents];
    
        console.log("Status Atualizado:", JSON.stringify(this.documents));
    }
    
    
    
    get modalClass() {
        return this.showModal ? 'modal slds-modal__open' : 'modal';
    }

    get confirmationModalClass() {
        return this.showConfirmationModal ? 'modal slds-modal__open' : 'modal';
    }
}