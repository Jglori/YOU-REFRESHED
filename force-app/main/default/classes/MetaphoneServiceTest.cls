@isTest
private class MetaphoneServiceTest {
    
    private static void setupTestData() {
    }
    
    @isTest
    static void testBuscaFoneticamente() {
        setupTestData();
        
        MetaphoneService service = new MetaphoneService();
        
        String palavra = 'João';
        List<String> nomes = new List<String>{ 'Joao', 'Joaquim', 'Joana', 'José' };
        
        Test.startTest();
        List<String> resultado = service.buscaFoneticamente(palavra, nomes);
        Test.stopTest();
        
    }
    
    @isTest
    static void testBuscaFoneticamenteSemCorrespondencia() {
        setupTestData();
        
        MetaphoneService service = new MetaphoneService();
        
        String palavra = 'Carlos';
        List<String> nomes = new List<String>{ 'Ricardo', 'Felipe', 'Lúcia' };
        
        Test.startTest();
        List<String> resultado = service.buscaFoneticamente(palavra, nomes);
        Test.stopTest();
        
    }
    
    @isTest
    static void testBuscaFoneticamenteComPalavrasSimilares() {
        setupTestData();
        
        MetaphoneService service = new MetaphoneService();
        
        String palavra = 'Filipe';
        List<String> nomes = new List<String>{ 'Felipe', 'Philipe', 'Phelipe', 'Flipo' };
        
        Test.startTest();
        List<String> resultado = service.buscaFoneticamente(palavra, nomes);
        Test.stopTest();
       
    }
    
    @isTest
    static void testBuscaFoneticamenteComComprimentosDiferentes() {
        setupTestData();
        
        MetaphoneService service = new MetaphoneService();
        
        String palavra = 'Ana';
        List<String> nomes = new List<String>{ 'Ana', 'Anais', 'Aninha', 'Nana' };
        
        Test.startTest();
        List<String> resultado = service.buscaFoneticamente(palavra, nomes);
        Test.stopTest();
        
  
    }
}