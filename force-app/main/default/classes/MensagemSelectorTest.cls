@isTest
public class MensagemSelectorTest {
    @isTest
    static void obterMensagensPorIdsTest() {
        Mensagem__c mensagem1 = new Mensagem__c(
            ChaveExterna__c = '5444775455221225',
            Certificado__c = 'Certificado1',
            ChaveExternaMidia__c = 'Midia1',
            ChaveExternaCliente__c = 'Cliente1',
            CodigoStatus__c = 1,
            Conteudo__c = 'Conteudo1',
            CorpoRequisicao__c = 'Corpo1',
            DataHora__c = DateTime.now(),
            De__c = '1234567890',
            NomeArquivo__c = 'Arquivo1.txt',
            Status__c = 'Ativo',
            Tipo__c = 'Tipo1',
            TipoMidia__c = 'TipoMidia1',
            URLMidia__c = 'http://example.com/media1'
        );

        Mensagem__c mensagem2 = new Mensagem__c(
            ChaveExterna__c = '5444775455221226',
            Certificado__c = 'Certificado2',
            ChaveExternaMidia__c = 'Midia2',
            ChaveExternaCliente__c = 'Cliente2',
            CodigoStatus__c = 2,
            Conteudo__c = 'Conteudo2',
            CorpoRequisicao__c = 'Corpo2',
            DataHora__c = DateTime.now().addDays(-1),
            De__c = '0987654321',
            NomeArquivo__c = 'Arquivo2.txt',
            Status__c = 'Inativo',
            Tipo__c = 'Tipo2',
            TipoMidia__c = 'TipoMidia2',
            URLMidia__c = 'http://example.com/media2'
        );

        insert new List<Mensagem__c> { mensagem1, mensagem2 };

        Set<Id> idsMensagens = new Set<Id>{ mensagem1.Id, mensagem2.Id };
        List<Mensagem__c> mensagens = MensagemSelector.obterMensagensPorIds(idsMensagens);

        Mensagem__c mensagemRetornada1 = mensagens[0];
        System.assertEquals('Certificado1', mensagemRetornada1.Certificado__c);
        System.assertEquals('Cliente1', mensagemRetornada1.ChaveExternaCliente__c);

        Mensagem__c mensagemRetornada2 = mensagens[1];
        System.assertEquals('Certificado2', mensagemRetornada2.Certificado__c);
        System.assertEquals('Cliente2', mensagemRetornada2.ChaveExternaCliente__c);
    }

    @isTest
    static void obterMensagensPorChavesExternasClientesTest() {
        Mensagem__c mensagem1 = new Mensagem__c(
            ChaveExterna__c = '5444775455221225',
            Certificado__c = 'Certificado1',
            ChaveExternaMidia__c = 'Midia1',
            ChaveExternaCliente__c = 'Cliente1',
            CodigoStatus__c = 1,
            Conteudo__c = 'Conteudo1',
            CorpoRequisicao__c = 'Corpo1',
            DataHora__c = DateTime.now(),
            De__c = '1234567890',
            NomeArquivo__c = 'Arquivo1.txt',
            Status__c = 'Ativo',
            Tipo__c = 'Tipo1',
            TipoMidia__c = 'TipoMidia1',
            URLMidia__c = 'http://example.com/media1'
        );

        Mensagem__c mensagem2 = new Mensagem__c(
            ChaveExterna__c = '5444775455221227',
            Certificado__c = 'Certificado3',
            ChaveExternaMidia__c = 'Midia3',
            ChaveExternaCliente__c = 'Cliente1',
            CodigoStatus__c = 2,
            Conteudo__c = 'Conteudo3',
            CorpoRequisicao__c = 'Corpo3',
            DataHora__c = DateTime.now().addDays(-1),
            De__c = '1122334455',
            NomeArquivo__c = 'Arquivo3.txt',
            Status__c = 'Inativo',
            Tipo__c = 'Tipo3',
            TipoMidia__c = 'TipoMidia3',
            URLMidia__c = 'http://example.com/media3'
        );

        insert new List<Mensagem__c> { mensagem1, mensagem2 };

        Set<String> chavesExternasClientes = new Set<String>{ 'Cliente1' };
        List<Mensagem__c> mensagensCliente = MensagemSelector.obterMensagensPorChavesExternasClientes(chavesExternasClientes);

        System.assert(mensagensCliente[0].DataHora__c <= mensagensCliente[1].DataHora__c, 'Mensagens devem estar em ordem crescente de DataHora');
    }
}