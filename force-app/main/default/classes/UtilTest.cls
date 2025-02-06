@isTest
public class UtilTest {
    @testSetup
    static void setup() {
        // Criar registros necessários para os testes, se aplicável
    }
    
    @isTest
    static void testGetPicklistValues() {
        Test.startTest();
        List<Utils.PicklistValueDto> picklistValues = Utils.getPicklistValues('Opportunity', 'StageName');
        Test.stopTest();
        
        System.assertNotEquals(null, picklistValues, 'A lista de valores de picklist não deveria ser nula.');
        System.assert(picklistValues.size() > 0, 'A lista de valores de picklist deve conter elementos.');
    }
    
    @isTest
    static void testGetPicklistValuesWithNullObject() {
        try {
            Utils.getPicklistValues(null, 'StageName');
            System.assert(false, 'Deveria ter lançado uma exceção devido ao objeto nulo.');
        } catch (AuraHandledException e) {
            
        }
    }
    
    @isTest
    static void testGetPicklistValuesWithNullField() {
        try {
            Utils.getPicklistValues('Opportunity', null);
            System.assert(false, 'Deveria ter lançado uma exceção devido ao campo nulo.');
        } catch (AuraHandledException e) {
            
        }
    }
    
    @isTest
    static void testGetStepDifference() {
        List<Utils.PicklistValueDto> picklistValues = new List<Utils.PicklistValueDto>();
        picklistValues.add(new Utils.PicklistValueDto('Início', 'Step1'));
        picklistValues.add(new Utils.PicklistValueDto('Meio', 'Step2'));
        picklistValues.add(new Utils.PicklistValueDto('Fim', 'Step3'));
        
        Integer stepDiff = Utils.getStepDifference(picklistValues, 'Step2');
        System.assertEquals(1, stepDiff, 'A diferença de etapa deveria ser 1.');
    }
    
    @isTest
    static void testGetStepDifferenceInvalidValue() {
        List<Utils.PicklistValueDto> picklistValues = new List<Utils.PicklistValueDto>();
        picklistValues.add(new Utils.PicklistValueDto('Início', 'Step1'));
        picklistValues.add(new Utils.PicklistValueDto('Meio', 'Step2'));
        picklistValues.add(new Utils.PicklistValueDto('Fim', 'Step3'));
        
        Integer stepDiff = Utils.getStepDifference(picklistValues, 'Step4');
        System.assertEquals(-1, stepDiff, 'Deveria retornar -1 para um valor inexistente.');
    }
}