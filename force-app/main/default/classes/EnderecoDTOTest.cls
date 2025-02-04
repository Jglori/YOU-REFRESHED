@IsTest
private class EnderecoDTOTest {
    
    @IsTest
    static void testEnderecoDTOFields() {
        // Cria uma instância de EnderecoDTO e define valores para cada campo
        EnderecoDTO endereco = new EnderecoDTO();
        endereco.cep = '12345-678';
        endereco.logradouro = 'Rua Exemplo';
        endereco.numero = '123';
        endereco.complemento = 'Apto 101';
        endereco.bairro = 'Centro';
        endereco.localidade = 'Cidade Exemplo';
        endereco.uf = 'SP';
        endereco.ibge = '1234567';
        endereco.gia = '1234';
        endereco.ddd = '11';
        endereco.siafi = '5678';

        // Verifica se os valores dos campos foram atribuídos corretamente
        System.assertEquals('12345-678', endereco.cep, 'O campo cep está incorreto');
        System.assertEquals('Rua Exemplo', endereco.logradouro, 'O campo logradouro está incorreto');
        System.assertEquals('123', endereco.numero, 'O campo numero está incorreto');
        System.assertEquals('Apto 101', endereco.complemento, 'O campo complemento está incorreto');
        System.assertEquals('Centro', endereco.bairro, 'O campo bairro está incorreto');
        System.assertEquals('Cidade Exemplo', endereco.localidade, 'O campo localidade está incorreto');
        System.assertEquals('SP', endereco.uf, 'O campo uf está incorreto');
        System.assertEquals('1234567', endereco.ibge, 'O campo ibge está incorreto');
        System.assertEquals('1234', endereco.gia, 'O campo gia está incorreto');
        System.assertEquals('11', endereco.ddd, 'O campo ddd está incorreto');
        System.assertEquals('5678', endereco.siafi, 'O campo siafi está incorreto');
    }
}