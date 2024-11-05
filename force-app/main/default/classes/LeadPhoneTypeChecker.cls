public class LeadPhoneTypeChecker {

    // Método para verificar o tipo de objeto do campo Phone em um objeto Lead
    public static String checkPhoneType() {
        String phoneType;

        // Consulta para obter os metadados do campo Phone do objeto Lead
        Map<String, Schema.SObjectField> leadFields = Schema.SObjectType.Lead.fields.getMap();
        Schema.DescribeFieldResult phoneFieldDescribe = leadFields.get('Phone').getDescribe();

        // Verificar o tipo de objeto do campo Phone
        if (phoneFieldDescribe.getType() == Schema.DisplayType.PHONE) {
            phoneType = 'Phone';
        } else if (phoneFieldDescribe.getType() == Schema.DisplayType.URL) {
            phoneType = 'URL';
        } else {
            phoneType = 'Outro';
        }

        return phoneType;
    }
}