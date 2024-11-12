import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retornarContactId from '@salesforce/apex/DocumentController.getContactsByAccountId';
import profissao from '@salesforce/apex/DocumentController.getContactRoles';
import documentosEntregues from '@salesforce/apex/DocumentController.verificarDocumentosEntregues';
import documentos from '@salesforce/apex/DocumentController.getDocumentosPorPapeis';
import salvarImagem from '@salesforce/apex/DocumentController.salvarImagemContato';
import deletar from '@salesforce/apex/DocumentController.deletarDocumento';
import recuperar from '@salesforce/apex/DocumentController.recuperar';
import baixar from '@salesforce/apex/DocumentController.baixarDocumento';
import { CurrentPageReference } from 'lightning/navigation';

export default class ListaDocumentosChecklist extends LightningElement {
    @track accountId;
    @track isLoading = false;
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
    cargo;

    @wire(CurrentPageReference)
    setPageRef(pageRef) {
        if (pageRef && pageRef.attributes) {
            this.accountId = pageRef.attributes.recordId;
            console.log(this.accountId);
            this.idContact();
        }
    }

    connectedCallback(){
        console.log("Id de account em connectedCallback " + this.accountId);
        this.idContact();
    }
    idContact() {
        console.log("Id de account em idContact " + this.accountId);
        retornarContactId({ accountId: this.accountId })
            .then(result => {
                if (result.length > 0) {
                    this.contactId = result[0].Id;
                   console.log("id de contato em idContact " + this.contactId);
                    this.buscarDados(); // Move a chamada para buscarDados aqui
                }
            })
            .catch(error => {
                console.error('Erro ao obter contato:', error);
            });
    }

    buscarDados() {
        console.log("ID de contato em buscar dados: " + this.contactId);
        profissao({ contactId: this.contactId })
            .then(result => {
                console.log("Resultado da profissão: ", JSON.stringify(result));
                if (result.length > 0) {
                    let profissoes = result.map(profissao => profissao.Role);
                    console.log("Profissões: ", JSON.stringify(profissoes));
                    this.plotarDocumentos(profissoes , this.contactId);
                } else {
                    console.warn("Nenhuma profissão encontrada.");
                }
            })
            .catch(error => {
                console.error('Erro ao obter dados da profissão:', error);
            });
    }
    
    plotarDocumentos(profissoes , contactId) {
        console.log("Profissões para plotar documentos: ", JSON.stringify(profissoes));
        documentos({ papeis: profissoes })
            .then(result => {
                console.log("Resultado dos documentos: ", JSON.stringify(result));
                
                const novosDocumentos = result.map(doc => ({
                    id: doc.Id,
                    label: doc.Nome_do_Documento__c,
                    obrigatorio: doc.Obrigatorio__c,
                    completed: doc.Entregue__c
                }));
                
                const documentosMap = new Map();
    
                novosDocumentos.forEach(doc => {
                    documentosMap.set(doc.label, doc);
                });
    
                const documentosAtualizados = this.documents.filter(doc => {
                    return !documentosMap.has(doc.label);
                });
    
                this.documents = [...documentosAtualizados, ...Array.from(documentosMap.values())];
    
                this.hasDocuments = this.documents.length > 0;
                console.log("Id de contato em plotar documentos: " + contactId);
                this.documentosEntregues(contactId);
            })
            .catch(error => {
                console.error('Erro ao obter documentos:', error);
            });
    }
    
    documentosEntregues(contactId) {
        console.log("ID de contato em documentosEntregues: " + contactId);  
        const contactIdLista = [contactId];
        console.log("Lista de contatos em documentosEntregues: " + JSON.stringify(contactIdLista));
        
        // Chama o método Apex e passa a lista de IDs de contato
        documentosEntregues({ contatoIds: contactIdLista })
            .then(result => {
                console.log("Resultado " + JSON.stringify(result));
                
                // Atualiza o status dos documentos com o resultado obtido
                return this.atualizarStatusDocumentos(result);
            })
            .then(() => {
                console.log("Status dos documentos atualizado com sucesso.");
            })
            .catch(error => {
                console.log("Erro " + JSON.stringify(error));
            });
    }
    
    atualizarStatusDocumentos(documentosMap) {
        console.log("JSON.stringify(this.documents): " + JSON.stringify(this.documents));
        console.log("documentosMap: " + JSON.stringify(documentosMap));
    
        // Itera sobre os documentos principais
        this.documents.forEach(doc => {
            // Itera sobre cada lista de documentos no mapa
            for (const [id, documentos] of Object.entries(documentosMap)) {
                // Verifica se há documentos com o mesmo nome
                documentos.forEach(entregue => {
                    if (entregue.nomeDoDocumento === doc.label) {
                        // Atualiza o status do documento
                        doc.completed = entregue.entregue;
                    }
                });
            }
        });
    
        // Força a atualização do estado dos documentos
        this.documents = [...this.documents];
        
        console.log("JSON Atualizado: " + JSON.stringify(this.documents));
    }
    
    handleUploadClick(event) {
        const documentId = event.target.dataset.id;
        const nomeArquivo = event.target.dataset.Nome_do_Documento__c
        const obrigatorio = event.target.dataset.obrigatorio;

        console.log("Obrigatorio " + obrigatorio);  
    
        const input = this.template.querySelector('input[type="file"]');
        input.dataset.id = documentId;
        input.dataset.nomeId = nomeArquivo; 
        input.dataset.completed = obrigatorio;
        input.click();
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        const nomeDocumento = event.target.dataset.nomeId
        const obrigatorio = event.target.dataset.completed;
        const nomeArquivo = file.name;
    
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                this.saveImage(base64, nomeDocumento , obrigatorio);
            };
            reader.readAsDataURL(file);
        }
    }
    
    saveImage(base64 , nomeDocumento , obrigatorio) {
       console.log(base64);
       console.log(nomeDocumento);
       console.log(obrigatorio);
        salvarImagem({ 
            contatoId: this.contactId,
            obrigatorio: obrigatorio,
            fileName: nomeDocumento, 
            base64Data: base64
        })
        .then(() => {
            console.log("entrou no metodo ");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Imagem salva com sucesso',
                    variant: 'success',
                }),
            );


            this.atualizar(nomeDocumento);
        
        })
        .catch(error => {
            console.log("Deu erro ");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao salvar a imagem: ' + error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    atualizar(nomeDocumento) {
        console.log("Documentos atuais " + JSON.stringify(this.documents));
        console.log("Nome do documento " + nomeDocumento);
        
        this.documents = this.documents.map(doc => {
            if (doc.label === nomeDocumento) {
                doc.completed = true;
            }
            return doc;
        });
    
        // Força o refresh
        this.documents = [...this.documents];
        console.log("Documentos atuais " + JSON.stringify(this.documents));
    }

    desativarDocumento(nomeDocumento) {
        this.documents = this.documents.map(doc => {
            if (doc.label === nomeDocumento) {
                doc.completed = false;
            }
            return doc;
        });
    
        // Força o refresh
        this.documents = [...this.documents];
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
        const nomeDocumento = event.target.dataset.nomeId;

        console.log(nomeDocumento)
        console.log(this.accountId)
        
        baixar({ contactId: this.contactId, nomeDocumento: nomeDocumento })
            .then(result => {
                if (result.startsWith('data:image/png;base64,')) {
                    this.convertBase64ToBlob(result)
                        .then(blob => this.downloadFile(blob , nomeDocumento))
                        .catch(error => {
                            console.error('Erro ao converter o base64 para Blob:', JSON.stringify(error));
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Erro',
                                    message: 'Erro ao converter o documento. Por favor, tente novamente mais tarde.',
                                    variant: 'error',
                                })
                            );
                        });
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Ops, houve um problema!',
                            message: result,
                            variant: 'warning',
                        })
                    );
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao obter o documento para download. Por favor, tente novamente mais tarde.',
                        variant: 'error',
                    })
                );
            });
    }

    convertBase64ToBlob(base64String) {
        return new Promise((resolve, reject) => {
            try {
                const base64Data = base64String.split(',')[1];
                const byteCharacters = atob(base64Data);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: 'image/png' }); 
                resolve(blob);
            } catch (error) {
                reject(error);
            }
        });
    }

    downloadFile(blob) {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = 'documento.png'; // Nome do arquivo para download
        document.body.appendChild(a);
        a.click();
        a.remove();
        window.URL.revokeObjectURL(url);
    }
    deletarArquivo(event) {
        const contactId = event.target.dataset.contactId;
        const nomeArquivo = event.target.dataset.nomeId
    
        console.log("Id de contato " + contactId)
        this.idContato = contactId;
        this.selectedDocumentDescription = nomeArquivo;
        const modal = this.template.querySelector('.modal');
        const modalContent = this.template.querySelector('.slds-modal__content');
        this.tipoModal = "Deletar o arquivo";
    
        modalContent.innerHTML = `<p>Tem certeza que deseja deletar o arquivo ?`;
        modal.style.display = 'block';
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
        this.selectedDocumentText = nomeDocumento;
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

        deletar({ contatoId: this.contactId, fileName: descricaoDocumento })
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

            this.desativarDocumento(descricaoDocumento);
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
        const obrigatorio = event.target.dataset.obrigatorio;
        
        console.log("handleUploadClick - documentId: ", documentId);
        console.log("handleUploadClick - nomeArquivo: ", nomeArquivo);
        
        const input = this.template.querySelector('input[type="file"]');
        input.dataset.id = documentId;
        input.dataset.nomeId = nomeArquivo; 
        input.dataset.obrigatorio = obrigatorio;
        input.click();
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        if (file) {
            const nomeDocumento = event.target.dataset.nomeId;
            const nomeArquivo = file.name;
            const nome = event.target.dataset.nomeId;
            const obrigatorio = event.target.dataset.obrigatorio;
            
            console.log("handleFileChange - nomeDocumento: ", nomeDocumento);
            console.log("handleFileChange - nomeArquivo: ", nomeArquivo);
            console.log("handleFileChange - file: ", file);
            console.log("handleFileChange - obrigatorio: ", obrigatorio);
            
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                console.log("handleFileChange - base64 data: ", base64);
                this.saveImage(base64, nomeDocumento, obrigatorio);
            };
            reader.readAsDataURL(file);
        } else {
            console.log("handleFileChange - No file selected.");
        }
    }
    
    saveImage(base64, nomeDocumento , obrigatorio) {
        console.log("saveImage - base64: ", base64);
        console.log("saveImage - nome do documento: ", nomeDocumento);
        console.log("saveImage - obrigatorio: ", obrigatorio);
        console.log("saveImage - contactId: ", this.contactId);
        
        salvarImagem({ 
            contatoId: this.contactId, 
            obrigatorio: obrigatorio,
            fileName: nomeDocumento, 
            base64Data: base64
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
            this.atualizar(nomeDocumento);
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
    
    get modalClass() {
        return this.showModal ? 'modal slds-modal__open' : 'modal';
    }

    get confirmationModalClass() {
        return this.showConfirmationModal ? 'modal slds-modal__open' : 'modal';
    }
}