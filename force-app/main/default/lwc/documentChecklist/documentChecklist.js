import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import retornarPapeisDeContato from '@salesforce/apex/DocumentController.retornarPapeisDeContato';
import getDocumentosPorPapeis from '@salesforce/apex/DocumentController.getDocumentosPorPapeis';
import { CurrentPageReference } from 'lightning/navigation';
import salvarImagem from '@salesforce/apex/DocumentController.salvarImagem';
import documentosEntregues from '@salesforce/apex/DocumentController.verificarDocumentosEntregues';
import deletar from '@salesforce/apex/DocumentController.deletarDocumento'
import recuperar from '@salesforce/apex/DocumentController.recuperar';
import baixar from '@salesforce/apex/DocumentController.baixarDocumento';

export default class DocumentChecklist extends LightningElement {
    @wire(CurrentPageReference)
    pageRef;
    

    @track showModal = false;
    @track selectedDocumentText;
    @track mandatoryDocuments = [];
    @track optionalDocuments = [];
    @track tipoModal = "OK";
    @track documentImageUrl;
    @track idContato;
    @track contactId;
    idsContatos = [];
    @track contactRoles = [];
    cargos = [];
    @track recordId;
    currentDocId;

    connectedCallback() {
        if (this.pageRef && this.pageRef.attributes) {
            this.recordId = this.pageRef.attributes.recordId;
            console.log("Id de oportunidade " + this.recordId);
        }
    }

    @wire(retornarPapeisDeContato, { oportunityId: '$recordId' })
    buscarNomes({ error, data }) {
        if (data) {
            console.log("Dados vindos: " + data);

            const cleanedData = data.replace(/\\/g, ''); 
            const jsonString = cleanedData.replace(/'/g, '"'); 

            try {
                const jsonData = JSON.parse(jsonString);

                console.log("Dados do back end " + JSON.stringify(jsonData));

                this.cargos = jsonData.map(cargo => ({
                    job: cargo.Role
                }));

                console.log("JSON ATUALIZADO " + JSON.stringify(this.cargos));

                this.contactRoles = jsonData.map(role => ({
                    id: role.ContactId,
                    contactName: role.ContactName,
                    job: role.Role,
                    dataEntrega: '',
                    mandatoryDocuments: [],
                    optionalDocuments: []
                }));

                this.idsContatos = jsonData.map(ids => ({
                    idContatos: ids.ContactId
                }));

                this.getDocumentos();
                
            } catch (e) {
                console.error("Erro ao tentar converter dados JSON: " + e);
            }
        } else if (error) {
            console.error("Erros: " + JSON.stringify(error));
        }
    }

    get jobRoles() {
        return this.cargos.map(cargo => cargo.job).filter(job => job !== null);
    }

    getDocumentos() {
        console.log("JSON NOVO " + JSON.stringify(this.jobRoles));
        getDocumentosPorPapeis({ papeis: this.jobRoles })
            .then(result => {
                this.classificarDocumentos(result);
                console.log('Documentos: ', JSON.stringify(this.documentos));
                this.documentosEntregues();  // Chame isso após a classificação dos documentos
            })
            .catch(error => {
                console.error('Error fetching documents: ', JSON.stringify(error));
            });
    }


    documentosEntregues() {
        const contatoIds = this.idsContatos.map(contato => contato.idContatos);

        console.log("IDS " + JSON.stringify(contatoIds));

        documentosEntregues({ contatoIds: contatoIds })
            .then(result => {
                console.log("Resultado " + JSON.stringify(result));
                this.atualizarStatusDocumentos(result);
            })
            .catch(error => {
                console.log("Erro " + JSON.stringify(error));
            });
    }

    
    atualizarStatusDocumentos(documentosMap) {
        this.contactRoles.forEach(role => {
            // Verifica se o ID do contato está presente no mapa de documentos
            if (documentosMap[role.id]) {
                // Obter os documentos associados ao ID do contato
                const documentos = documentosMap[role.id];
                
                // Função para obter o último documento com base no nome e data de entrega
                const getLatestDocument = (documentName) => {
                    return documentos
                        .filter(d => d.nomeDoDocumento === documentName)
                        .sort((a, b) => new Date(b.dataEntrega) - new Date(a.dataEntrega))[0];
                };
    
                // Atualiza documentos obrigatórios
                role.mandatoryDocuments.forEach(doc => {
                    const latestDocument = getLatestDocument(doc.Nome_do_Documento__c);
                    if (latestDocument) {
                        doc.completed = latestDocument.entregue;
                        doc.dataEntrega = latestDocument.entregue ? this.formatarData(latestDocument.dataEntrega) : '';
                    }
                });
    
                // Atualiza documentos opcionais
                role.optionalDocuments.forEach(doc => {
                    const latestDocument = getLatestDocument(doc.Nome_do_Documento__c);
                    if (latestDocument) {
                        doc.completed = latestDocument.entregue;
                        doc.dataEntrega = latestDocument.entregue ? this.formatarData(latestDocument.dataEntrega) : '';
                    }
                });
            }
        });
    
        // Força atualização da propriedade rastreada
        this.contactRoles = [...this.contactRoles];

        console.log('Documentos Atualizados agora ' + JSON.stringify(this.contactRoles));
    }
    
    
    formatarData(dataISO) {
        const date = new Date(dataISO);
        const dia = String(date.getDate()).padStart(2, '0');
        const mes = String(date.getMonth() + 1).padStart(2, '0'); // Janeiro é 0!
        const ano = date.getFullYear();
        return `Data de Entrega: ${dia}/${mes}/${ano}`;
    }


    classificarDocumentos(documentos) {
        documentos.forEach(doc => {
            this.contactRoles.forEach(role => {
                if (role.job && doc.Papel__c.includes(role.job)) {
                    if (doc.Obrigatorio__c) {
                        role.mandatoryDocuments.push({
                            Nome_do_Documento__c: doc.Nome_do_Documento__c,
                            completed: false,
                        });
                    } else {
                        role.optionalDocuments.push({
                            Nome_do_Documento__c: doc.Nome_do_Documento__c,
                            completed: false,
                        });
                    }
                }
            });
        });
        this.contactRoles = [...this.contactRoles];  // Força atualização da propriedade rastreada
    }
    


    formataremData(data) {
        const dateObj = new Date(data);
        const dia = dateObj.getDate().toString().padStart(2, '0');
        const mes = (dateObj.getMonth() + 1).toString().padStart(2, '0'); 
        const ano = dateObj.getFullYear();
        return `${dia}/${mes}/${ano}`;
    }
    handleUploadClick(event) {
        const documentId = event.target.dataset.id;
        const contactId = event.target.dataset.contactId;
        const nomeArquivo = event.target.dataset.nomeId
        const obrigatorio = event.target.dataset.completed;

        console.log("Obrigatorio " + obrigatorio);  
    
        const input = this.template.querySelector('input[type="file"]');
        input.dataset.id = documentId;
        input.dataset.contactId = contactId;
        input.dataset.nomeId = nomeArquivo; 
        input.dataset.completed = obrigatorio;
        input.click();
    }
    
    handleFileChange(event) {
        const file = event.target.files[0];
        const documentId = event.target.dataset.id;
        const contactId = event.target.dataset.contactId;
        const nomeDocumento = event.target.dataset.nomeId;
        const obrigatorio = event.target.dataset.completed;
    
        if (file) {
            const fileName = file.name;
            const fileType = file.type;
            const fileSize = file.size;
    
            // Para depuração
            console.log("Nome do documento: " + nomeDocumento);
            console.log("Tipo do documento: " + fileType);
            console.log("Tamanho do documento: " + fileSize);
    
            const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
    
            // Tipos MIME válidos
            const validFileTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    
            // Verificação do tipo de arquivo
            if (validFileTypes.includes(fileType)) {
                console.log('Tipo de arquivo válido.');
    
                // Verificação do tamanho do arquivo
                if (fileSize <= maxSizeInBytes) {
                    console.log('Tamanho do arquivo válido.');
    
                    const reader = new FileReader();
                    reader.onload = () => {
                        const base64 = reader.result.split(',')[1];
                        this.saveImage(base64, fileName, contactId, nomeDocumento, obrigatorio, fileType);
                    };
                    reader.readAsDataURL(file);
                } else {
                    console.error('O arquivo é muito grande.');
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Erro',
                            message: 'O arquivo é muito grande. O tamanho máximo permitido é 5 MB.',
                            variant: 'error',
                        })
                    );
                }
            } else {
                console.error('Tipo de arquivo não suportado.');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Tipo de arquivo não suportado. Apenas JPG, PNG e PDF são aceitos.',
                        variant: 'error',
                    })
                );
            }
        }
    }
    
    
    get isEmptyContactRoles() {
        console.log(this.contactRoles.length);
        return this.contactRoles.length === 0;
    }
    
    saveImage(base64, fileName, contactId , nomeDocumento , obrigatorio , fileType) {
        console.log("Base64: " + base64);
        console.log("FileName: " + fileName);
        console.log("ContactId: " + contactId);
        console.log("NomeDocumento: " + nomeDocumento);
        console.log("Obrigatorio: " + obrigatorio);
        console.log("FileType: " + fileType);
        salvarImagem({ 
            contatoId: contactId,
            opportunityId: this.recordId, 
            obrigatorio: obrigatorio,
            fileName: nomeDocumento, 
            base64Data: base64 ,
            tipoDocumento: fileType
        })
        .then(() => {
            console.log("Imagem salva com sucesso.");
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Imagem salva com sucesso',
                    variant: 'success',
                }),
            );
            this.resetModal();
            this.documentosEntregues();
        })
        .catch(error => {
            console.log("Erro ao salvar imagem: ", error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao salvar a imagem: ' + error.body.message,
                    variant: 'error',
                }),
            );
        });
    }

    resetModal() {
        // Seleciona o modal e o conteúdo do modal
        const modal = this.template.querySelector('.modal');
        const modalContent = this.template.querySelector('.slds-modal__content');
    
    
        if (modalContent) {
            modalContent.innerHTML = '';
        }
    
        this.documentImageUrl = '';
    }

    atualizarImagem(){

        this.documentImageUrl = ''; 
        
        // recuperar({ contactId: this.idContato, nomeDocumento: this.selectedDocumentDescription })
        //     .then(result => {
        //         this.documentImageUrl = result;

        //         console.log("URL da imagem: " + this.documentImageUrl);
        //     })
        //     .catch(error => {
        //         console.log("Erro ao recuperar imagem: ", error);
        //     });
    }
    updateDocumentStatus(docId) {
        const updateStatus = (docList) => docList.map(doc => {
            if (doc.id === docId) {
                return { ...doc, completed: true };
            }
            return doc;
        });
    
        this.mandatoryDocuments = updateStatus(this.mandatoryDocuments);
        this.optionalDocuments = updateStatus(this.optionalDocuments);
    }
    

    getDocumentRowClass(completed) {
        return completed ? 'document-row green-icon' : 'document-row';
    }

    handleViewClick(event) {
        const contactId = event.target.dataset.contactId;
        const nomeDocumento = event.target.dataset.nomeId;
        
        this.tipoModal = "OK";
        const modal = this.template.querySelector('.modal');
        const modalContent = this.template.querySelector('.slds-modal__content');
        
        this.documentImageUrl = ''; 
        
        recuperar({ contactId: contactId, nomeDocumento: nomeDocumento })
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
        
        baixar({ contactId: contactId, nomeDocumento: nomeDocumento })
            .then(result => {
                console.log("Resultado: " + JSON.stringify(result));
                if (result) {
                    const response = JSON.parse(result);
                    const base64Data = response.base64Data;
                    const mimeType = response.mimeType;
                    const fileExtension = mimeType.split('/')[1]; // Extrai a extensão do tipo MIME
                    const fileName = nomeDocumento || 'documento'; // Nome do arquivo para download
                    const fullFileName = `${fileName}.${fileExtension}`; // Nome completo do arquivo com extensão
                    
                    this.convertBase64ToBlob(base64Data, mimeType)
                        .then(blob => this.downloadFile(blob, fullFileName))
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
                            message: 'Documento não encontrado.',
                            variant: 'warning',
                        })
                    );
                }
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Erro',
                        message: 'Erro ao obter o documento para download. Por favor, tente novamente mais tarde.',
                        variant: 'error',
                    })
                );
            });
    }
    
    convertBase64ToBlob(base64Data, mimeType) {
        return new Promise((resolve, reject) => {
            try {
                const byteCharacters = atob(base64Data);
                const byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                const byteArray = new Uint8Array(byteNumbers);
                const blob = new Blob([byteArray], { type: mimeType }); // Usa o tipo MIME correto
                resolve(blob);
            } catch (error) {
                reject(error);
            }
        });
    }
    
    downloadFile(blob, fileName) {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = fileName; // Usa o nome do arquivo com a extensão correta
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
    
    
    

    getDocumentLabel(documentId) {
        const document = this.mandatoryDocuments.find(doc => doc.id === documentId) || this.optionalDocuments.find(doc => doc.id === documentId);
        return document ? document.label : '';
    }

    handleCancelClick() {
        const modal = this.template.querySelector('.modal');

        
        modal.style.display = 'none';
    }

    handleSaveOptional() {
        if (this.tipoModal === "Deletar o arquivo") {
            this.deletarDocumento(this.selectedDocumentDescription ,this.idContato);
        }
    
        if (this.tipoModal === "OK") {
            const modal = this.template.querySelector('.modal');
            modal.style.display = 'none';
        }
    }

   deletarDocumento(descricaoDocumento, idContato) {
    deletar({ contatoId: idContato, fileName: descricaoDocumento })
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

            // Atualiza a lista de documentos entregues após exclusão
            this.desativarCampo(descricaoDocumento , idContato);
        })
        .catch(error => {
            console.log("Erro ao deletar documento: ", error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message: 'Erro ao deletar o documento. Tente novamente mais tarde.',
                    variant: 'error',
                }),
            );
        });
}
    

    desativarCampo(descricaoDocumento, idContato) {
        // Varre o JSON para encontrar o contato correspondente pelo ID
        this.contactRoles.forEach(contact => {
            if (contact.id === idContato) {
                // Varre os documentos obrigatórios e atualiza o campo 'completed'
                contact.mandatoryDocuments.forEach(doc => {
                    if (doc.Nome_do_Documento__c === descricaoDocumento) {
                        doc.completed = false;
                    }
                });
    
                // Varre os documentos opcionais e atualiza o campo 'completed'
                contact.optionalDocuments.forEach(doc => {
                    if (doc.Nome_do_Documento__c === descricaoDocumento) {
                        doc.completed = false;
                    }
                });
            }
        });
    
        // Força a atualização dos documentos para garantir que as mudanças sejam refletidas no DOM
        this.contactRoles = [...this.contactRoles];
    
        console.log("Documentos atualizados: ", JSON.stringify(this.contactRoles));
    }
    
    handleReloadClick(){

        window.location.reload();
    }
    
}