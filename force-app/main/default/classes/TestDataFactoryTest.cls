@IsTest
private class TestDataFactoryTest {

    // Teste para gerarConta sem tipo
    @IsTest
    static void testGerarConta() {
        Account conta = TestDataFactory.gerarConta();
        System.assertEquals('Conta de Teste', conta.Name, 'A conta deve ter o nome correto');
    }

    // Teste para gerarConta com tipo
    @IsTest
    static void testGerarContaComTipo() {
        Account conta = TestDataFactory.gerarConta('Cliente');
        System.assertEquals('Conta de Teste', conta.Name, 'A conta deve ter o nome correto');
        System.assertEquals('Cliente', conta.Type, 'A conta deve ter o tipo correto');
    }

    // Teste para gerarContaPessoal
    @IsTest
    static void testGerarContaPessoal() {
        Account contaPessoal = TestDataFactory.gerarContaPessoal();
        System.assertEquals('John', contaPessoal.FirstName, 'O primeiro nome da conta pessoal deve ser John');
        System.assertEquals('Doe', contaPessoal.LastName, 'O sobrenome da conta pessoal deve ser Doe');
        System.assertEquals('johndoe@example.com', contaPessoal.PersonEmail, 'O email da conta pessoal deve ser johndoe@example.com');
        System.assertNotEquals(null, contaPessoal.RecordTypeId, 'O RecordTypeId da conta pessoal deve ser preenchido');
    }

    // Teste para gerarContato
    @IsTest
    static void testGerarContato() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;
        Contact contato = TestDataFactory.gerarContato(conta);
        System.assertEquals(conta.Id, contato.AccountId, 'O contato deve estar associado à conta correta');
        System.assertEquals('Teste', contato.LastName, 'O sobrenome do contato deve ser Teste');
    }

 


    // Teste para gerarLead
    @IsTest
    static void testGerarLead() {
        Lead lead = TestDataFactory.gerarLead();
        System.assertEquals('Elera', lead.Company, 'A empresa do lead deve ser Elera');
        System.assertEquals('11960387699', lead.MobilePhone, 'O telefone do lead deve estar correto');
    }

    // Teste para gerarLead com Empreendimento
    @IsTest
    static void testGerarLeadComEmpreendimento() {
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
        insert empreendimento;
        Lead lead = TestDataFactory.gerarLead(empreendimento);
        System.assertEquals(empreendimento.Id, lead.EmpreendimentoInteresse__c, 'O empreendimento de interesse do lead deve ser correto');
    }

    // Teste para gerarProduto
    @IsTest
    static void testGerarProduto() {
        Product2 produto = TestDataFactory.gerarProduto();
      //  System.assertEquals('Produto de Teste', produto.Name, 'O nome do produto deve ser Produto de Teste');
      //  System.assertTrue(produto.isActive, 'O produto deve estar ativo');
    }

    // Teste para gerarTask
    @IsTest
    static void testGerarTask() {
        Lead lead = TestDataFactory.gerarLead();
        insert lead;
        Task task = TestDataFactory.gerarTask(lead);
       // System.assertEquals(lead.Id, task.WhoId, 'A task deve estar associada ao lead correto');
       // System.assertEquals('Chamada', task.Subject, 'O assunto da task deve ser Chamada');
    }

  

    // Teste para gerarEmpreendimento
    @IsTest
    static void testGerarEmpreendimento() {
        Empreendimento__c empreendimento = TestDataFactory.gerarEmpreendimento();
     //   System.assertEquals('Empreendimento de Teste', empreendimento.Name, 'O nome do empreendimento deve ser Empreendimento de Teste');
    }

    // Teste para gerarOportunidade
    @IsTest
    static void testGerarOportunidade() {
        Account conta = TestDataFactory.gerarConta();
        insert conta;
        Contact corretor = TestDataFactory.gerarContato(conta);
        insert corretor;
        Opportunity oportunidade = TestDataFactory.gerarOportunidade(conta, corretor);
        //System.assertEquals(conta.Id, oportunidade.AccountId, 'A oportunidade deve estar associada à conta correta');
      //  System.assertEquals(corretor.Id, oportunidade.Corretor__c, 'A oportunidade deve estar associada ao corretor correto');
    }
}