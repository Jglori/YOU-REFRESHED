@isTest
public class ValidarCNPJTest {

    @isTest
    static void testCNPJValido() {
        String cnpj = '11222333000181';
        System.assertEquals(true, ValidarCNPJ.validarCNPJ(cnpj));
    }

    @isTest
    static void testCNPJInvalido() {
        String cnpj = '11222333000182';
        System.assertEquals(false, ValidarCNPJ.validarCNPJ(cnpj));
    }

    @isTest
    static void testCNPJTamanhoInvalido() {
        String cnpj = '1122233300018';
        System.assertEquals(false, ValidarCNPJ.validarCNPJ(cnpj));
    }

    @isTest
    static void testCNPJCaracteresNaoNumericos() {
        String cnpj = '11.222.333/0001-81';
        System.assertEquals(true, ValidarCNPJ.validarCNPJ(cnpj));
    }

    @isTest
    static void testCNPJComDigitosIguais() {
        String cnpj = '11111111111111';
        System.assertEquals(false, ValidarCNPJ.validarCNPJ(cnpj));
    }
}