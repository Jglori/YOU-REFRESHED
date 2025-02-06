import { refreshApex } from '@salesforce/apex';
import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocumentsForEachContactRole from '@salesforce/apex/DocumentController.getDocumentsForEachContactRole';
import { RefreshEvent } from 'lightning/refresh';
import salvarImagem from '@salesforce/apex/DocumentController.salvarImagem';
import deletar from '@salesforce/apex/DocumentController.deletar'
import recuperar from '@salesforce/apex/DocumentController.recuperar';
import baixar from '@salesforce/apex/DocumentController.baixarDocumento'; 
import Modal from 'c/modal';
import { formatData } from 'c/utils';


export default class DocumentChecklist extends LightningElement {
    @api recordId;
    @track opportunityContactRole = [];
    @track documents;
    @track isLoading = false;
    @track contactId;

    @track mandatory;
    @track optional;
    wiredDocumentos;
    wiredOpportunityContactRole;

    get isContactRoleEmpty() {
        return !this.opportunityContactRole || this.opportunityContactRole <= 0;
    }

    event = {
        success: (message) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message,
                    variant: 'success',
                }),
            );
        },
        error: (message) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Erro',
                    message,
                    variant: 'error',
                }),
            );
        },
        warning: (message) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Ops, houve um problema!',
                    message,
                    variant: 'warning',
                })
            )
        }
    }

    @wire(getDocumentsForEachContactRole, { opportunityId: '$recordId' })
    getDocumentsForEachContactRole(result) {
        this.wiredDocumentos = result;
        const { error, data } = result;
        
        if (data) {
            console.log("Filtred", data);
            this.opportunityContactRole = data.map(contact => {
                const mandatoryDocuments = contact.Documents.filter(doc => doc.Obrigatorio__c === true);
                const optionalDocuments = contact.Documents.filter(doc => doc.Obrigatorio__c === false);

                const filtredData = this.formatDocumentsData(mandatoryDocuments, optionalDocuments);

                return {
                    ...contact,
                    mandatoryDocuments: filtredData.updatedMandatoryDocuments,
                    optionalDocuments: filtredData.updatedOptionalDocuments,
                };
            });

        } else if (error) {
            console.error(error);
            this.event.error('Erro ao pegar novos documentos filtrados');
        }
    }

    formatDocumentsData(mandatoryDocuments, optionalDocuments) {
        const updatedMandatoryDocuments = mandatoryDocuments.map(doc => {
            return {
                ...doc,
                DataEntrega__c: doc.DataEntrega__c ? formatData(doc.DataEntrega__c) : doc.DataEntrega__c
            };
        });

        const updatedOptionalDocuments = optionalDocuments.map(doc => {
            return {
                ...doc,
                DataEntrega__c: doc.DataEntrega__c ? formatData(doc.DataEntrega__c) : doc.DataEntrega__c
            };
        });

        return {updatedMandatoryDocuments, updatedOptionalDocuments}
    }

    handleUploadClick(event) {
        event.target.value = '';
        const documentId = event.target.dataset.id;
        const contactId = event.target.dataset.contactId;
        const nomeArquivo = event.target.dataset.nomeId
        const obrigatorio = event.target.dataset.completed;

        const input = this.template.querySelector('input[type="file"]');
        input.dataset.id = documentId;
        input.dataset.contactId = contactId;
        input.dataset.nomeId = nomeArquivo; 
        input.dataset.completed = obrigatorio;

        input.click();
    }

    findDocumentByContactIdAndName(data, contactId, docMtdName) {
        const contact = data.find(it => it.ContactId === contactId);

        if(contact) {
            const document = contact.Documents.find(doc => doc.Name === docMtdName);
            return document;
        }

        return null
    }


    handleFileChange(event) {
        const file = event.target.files[0];
        const name = event.target.dataset.nomeId;
        const contactId = event.target.dataset.contactId;
        const doc = this.findDocumentByContactIdAndName(this.wiredDocumentos.data, contactId, name);
        
        if (file && doc) {
            const fileName = file.name;
            const fileType = file.type;
            const fileSize = file.size;
            const maxSizeInBytes = 5 * 1024 * 1024; // 5 MB
    
            const validFileTypes = ['image/jpeg', 'image/png', 'application/pdf'];
    
            if (validFileTypes.includes(fileType)) {
                if (fileSize <= maxSizeInBytes) {
                    const reader = new FileReader();
                    reader.onload = () => {
                        const base64 = reader.result.split(',')[1];
                        this.saveImage(contactId, base64, fileName, doc.Name, doc.Obrigatorio__c, fileType);
                    };
                    reader.readAsDataURL(file);
                } else {
                    console.error('O arquivo é muito grande.');
                    this.event.error('O arquivo é muito grande. O tamanho máximo permitido é 5 MB.');
                }
            } else {
                console.error('Tipo de arquivo não suportado.');
                this.event.error('Tipo de arquivo não suportado. Apenas JPG, PNG e PDF são aceitos.');
            }

            event.target.value = '';
        }
    }
   
    saveImage(contactId, base64, fileName, title, obrigatorio, fileType) {
        this.isLoading = true;
        salvarImagem({
            contactId,
            opportunityId: this.recordId, 
            obrigatorio,
            title,
            fileName,
            base64,
            fileType
        })
        .then((result) => {
            this.event.success('Imagem salva com sucesso');
            this.dispatchEvent(new RefreshEvent());
            refreshApex(this.wiredDocumentos);
        })
        .catch(error => {
            console.error("Erro ao salvar imagem: ", error);
            this.event.error('Erro ao salvar a imagem: ' + error.body.message);
        })
        .finally(() => {
            this.isLoading = false;
        });
    }

    handleViewClick(event) {
        const id = event.target.dataset.id;
        const contactId = event.target.dataset.contactId
        const contact = this.wiredDocumentos.data.find(it => it.ContactId === contactId);

        if(contact) {
            const doc = contact.Documents.find(doc => doc.Id === id);

            recuperar({ id })
            .then(result => {
                    if (result.mimeType != 'image/pdf') {
                        // Exibir imagem se for um URL de documento
                        const timestamp = new Date().getTime();
                        const documentImageUrl = `${result.documentUrl}?t=${timestamp}`;
                        
                        const img = document.createElement('img');
                        img.src = documentImageUrl;
                        img.alt = doc.Name;
                        img.style.width = '100%';
                        img.style.height = 'auto';

                        Modal.open({
                            label: 'Visualizar Documento',
                            size: 'small',
                            image: {
                                src: documentImageUrl,
                                alt: doc.Name,
                            },
                            isOneButton: true,
                            description: 'Modal para visualização de documento',
                        });
                    } else if (result.documentUrl) {
                        this.event.warning('Documentos do tipo PDF não podem ser visualizados. Faça o download para visualizar.',);
                    }
                })
                .catch(error => {
                    this.event.error('Erro ao obter a imagem do documento. Por favor, tente novamente mais tarde.' + error);
                });
        }        
    }
    
    handleDownloadClick(event) {
        const id = event.target.dataset.id;
        
        baixar({ id })
        .then(result => {
            const base64Data = result.base64Data;
            const mimeType = result.mimeType;
            const fileExtension = mimeType.split('/')[1]; // Extrai a extensão do tipo MIME
            const fileName = result.fileName || 'documento'; // Nome do arquivo para download
            const fullFileName = `${fileName}.${fileExtension}`; // Nome completo do arquivo com extensão
            
            this.convertBase64ToBlob(base64Data, mimeType)
            .then(blob => this.downloadFile(blob, fullFileName))
            .catch(error => {
                console.error('Erro ao converter o base64 para Blob:', JSON.stringify(error));
                this.event.error('Erro ao converter o documento. Por favor, tente novamente mais tarde.');
            });
        })
        .catch(error => {
            this.event.error('Erro ao obter o documento para download. Por favor, tente novamente mais tarde.' + error);
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
        const docId = event.target.dataset.id;         
        Modal.open({
            label: 'Deletar documento',
            size: 'small',
            content: 'Tem certeza que deseja deletar o arquivo ?',
            description: 'Modal para deleção de documento',
            confirmCallback: () => this.deletarDocumento(docId),
        })
    }

   deletarDocumento(id) {
    deletar({ id })
        .then(result => {
            this.event.success('Documento deletado com sucesso');
            this.dispatchEvent(new RefreshEvent());
            refreshApex(this.wiredDocumentos);
        })
        .catch(error => {
            console.error("Erro ao deletar documento: "+ JSON.stringify(error));
            this.event.error('Erro ao deletar o documento. Tente novamente mais tarde.');
        });
    }
    
}