@isTest
public with sharing class QueryHelperTest {
    @TestSetup
    static void makeData(){
        Empreendimento__c emp = new Empreendimento__c();
        emp.Name = 'Empreendimento de Teste';
        emp.CNPJEmpreendimento__c = '11084433000199';
        insert emp;
    }

    @isTest
    static void testSelectAllFields(){
        Empreendimento__c emp = [SELECT Id, Name, CNPJEmpreendimento__c FROM Empreendimento__c LIMIT 1];
        SObject empSObject = QueryHelper.selectAllFields('Empreendimento__c', emp.Id);
        
        System.assertEquals(emp.Id, empSObject.get('Id'));
        System.assertEquals(emp.Name, empSObject.get('Name'));
        System.assertEquals(emp.CNPJEmpreendimento__c, empSObject.get('CNPJEmpreendimento__c'));
    }
}