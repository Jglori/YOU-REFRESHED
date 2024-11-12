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

    @isTest
    static void testCPFComTodosZeros() {
        String cpf = '00000000000';
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testInvocableMethod() {
        List<String> cpfs = new List<String>{'12345678909', '12345678901', '11111111111', '123.456.789-09'};
        List<Boolean> expectedResults = new List<Boolean>{true, false, false, true};
        System.assertEquals(expectedResults, ValidarCPF.validarCPFs(cpfs));
    }

    @isTest
    static void testCPFPrimeiroDigitoInvalido() {
        String cpf = '12345678919'; // CPF com primeiro dígito verificador inválido
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFPrimeiroDigitoZero() {
        String cpf = '11144477735'; // CPF onde o primeiro dígito verificador é 0
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFPrimeiroDigitoDez() {
        String cpf = '52998224725'; // CPF onde o primeiro dígito verificador é 10, que se torna 0
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFSegundoDigitoInvalido() {
        String cpf = '12345678902'; // CPF com segundo dígito verificador inválido
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFSegundoDigitoZero() {
        String cpf = '74682469000'; 
        System.assertEquals(false, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFSegundoDigitoDez() {
        String cpf = '52998224725';
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }

    @isTest
    static void testCPFSemCaracteresEspeciais() {
        String cpf = '12345678909';
        System.assertEquals(true, ValidarCPF.validarCPF(cpf));
    }
}