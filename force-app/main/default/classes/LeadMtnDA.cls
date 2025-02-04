public class LeadMtnDA {

    public static Id obterLeadExistente(String email, String celular) {
        if (String.isBlank(email) && String.isBlank(celular)) {
            return null; 
        }

        List<String> conditions = new List<String>();
        if (String.isNotBlank(celular)) {
            conditions.add('(MobilePhone = :celular)');
            conditions.add('(CelularAdicional__c = :celular)');
            conditions.add('(CelularAdicional1__c = :celular)');
            conditions.add('(CelularAdicional2__c = :celular)');
            conditions.add('(CelularComercialAdicional__c = :celular)');
        }
        if (String.isNotBlank(email)) {
            conditions.add('(Email = :email)');
            conditions.add('(EmailAdicional__c = :email)');
        }

        if (conditions.isEmpty()) {
            return null;
        }

        String query = 'SELECT Id FROM Lead WHERE ' + String.join(conditions, ' OR ') + ' LIMIT 1';

        List<Lead> leads = Database.query(query);
        return (!leads.isEmpty()) ? leads[0].Id : null;
    }
}