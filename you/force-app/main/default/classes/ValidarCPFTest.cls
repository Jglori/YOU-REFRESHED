@isTest
public class ValidarCPFTest {

    @isTest
    static void testCPFValido() {
        String cpf = '12345678909';
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFInvalido() {
        String cpf = '12345678901';
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFTamanhoInvalido() {
        String cpf = '1234567890';
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFCaracteresNaoNumericos() {
        String cpf = '123.456.789-09';
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFComDigitosIguais() {
        String cpf = '11111111111';
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }
}