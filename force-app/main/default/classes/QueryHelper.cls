public class QueryHelper {
    public static SObject selectAllFields(String objectName, Id recordId) {
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        List<String> fieldNames = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            fieldNames.add(fieldName);
        }

        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + objectName + ' WHERE Id = :recordId';
        System.debug('Query gerada: ' + query);

        return Database.query(query) != null ? Database.query(query) : new List<SObject>();
    }
}