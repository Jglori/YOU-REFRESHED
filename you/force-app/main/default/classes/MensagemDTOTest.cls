@isTest
public class MensagemDTOTest {

    @isTest
    static void testMensagemDTOConstructor() {
        // Criar um registro de Mensagem__c para o teste
        Mensagem__c mensagem = new Mensagem__c(
            Certificado__c = 'Certificado123',
            ChaveExterna__c = 'Chave123',
            ChaveExternaCliente__c = 'ChaveCliente123',
            ChaveExternaMidia__c = 'ChaveMidia123',
            CodigoStatus__c = 200,
            Conteudo__c = 'Conteúdo da mensagem',
            CorpoRequisicao__c = 'Corpo da requisição',
            DataHora__c = System.now(),
            De__c = 'Remetente',
            NomeArquivo__c = 'arquivo.pdf',
            Status__c = 'Enviado',
            Tipo__c = 'Tipo1',
            TipoMidia__c = 'Imagem',
            URLMidia__c = 'https://example.com/midia'
        );
        insert mensagem;

        Test.startTest();

        // Criar a instância de MensagemDTO com os dados do Mensagem__c
        MensagemDTO mensagemDTO = new MensagemDTO(mensagem);

        Test.stopTest();

        // Verificar os valores no MensagemDTO
        System.assertNotEquals(null, mensagemDTO, 'MensagemDTO não deve ser nulo.');
        System.assertEquals(mensagem.Id, mensagemDTO.id, 'ID deve ser o mesmo do Mensagem__c.');
        System.assertEquals('Certificado123', mensagemDTO.certificado, 'Certificado deve ser "Certificado123".');
        System.assertEquals('Chave123', mensagemDTO.chaveExterna, 'ChaveExterna deve ser "Chave123".');
        System.assertEquals('ChaveCliente123', mensagemDTO.chaveExternaCliente, 'ChaveExternaCliente deve ser "ChaveCliente123".');
        System.assertEquals('ChaveMidia123', mensagemDTO.chaveExternaMidia, 'ChaveExternaMidia deve ser "ChaveMidia123".');
        System.assertEquals(200, mensagemDTO.codigoStatus, 'CodigoStatus deve ser 200.');
        System.assertEquals('Conteúdo da mensagem', mensagemDTO.conteudo, 'Conteúdo deve ser "Conteúdo da mensagem".');
        System.assertEquals('Corpo da requisição', mensagemDTO.corpoRequisicao, 'CorpoRequisicao deve ser "Corpo da requisição".');
        System.assertEquals(System.now().date(), mensagemDTO.dataHora.date(), 'DataHora deve ser a data e hora esperadas.');
        System.assertEquals('Remetente', mensagemDTO.de, 'De deve ser "Remetente".');
        System.assertEquals('arquivo.pdf', mensagemDTO.nomeArquivo, 'NomeArquivo deve ser "arquivo.pdf".');
        System.assertEquals('Enviado', mensagemDTO.status, 'Status deve ser "Enviado".');
        System.assertEquals('Tipo1', mensagemDTO.tipo, 'Tipo deve ser "Tipo1".');
        System.assertEquals('Imagem', mensagemDTO.tipoMidia, 'TipoMidia deve ser "Imagem".');
        System.assertEquals('https://example.com/midia', mensagemDTO.urlMidia, 'URLMidia deve ser "https://example.com/midia".');
    }
}