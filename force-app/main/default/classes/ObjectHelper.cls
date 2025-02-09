public with sharing class ObjectHelper {
    public static Set<Id> getLookUpId(List<SObject> objects, String field){
        Set<Id> setId = new Set<Id>();

        for(SObject iObject : objects){
            if(iObject.get(field) != null){
                setId.add((Id) iObject.get(field));
            }
        }

        return setId;
    }

    public static List<ObjectMetadata> getObjects() {
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        
        List<ObjectMetadata> objectsMetadata = new List<ObjectMetadata>(); 
        for (String objectName : globalDescribe.keySet()) {
            Schema.SObjectType objectType = globalDescribe.get(objectName);
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();

            if (describeResult.isAccessible()) {
                objectsMetadata.add(new ObjectMetadata(
                    describeResult.getLabel(),
                    describeResult.getName()
                ));
            }
        }
        return objectsMetadata;
    }

    public static Map<String, List<FieldMetadata>> getReferenceFields(String objectName, String fieldName) {
        List<Schema.SObjectType> objects = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo();
        String objectSelected = objects[0].toString();
        Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectSelected).getDescribe().fields.getMap();

        Map<String, List<FieldMetadata>> objectFields = new Map<String, List<FieldMetadata>>(); 
        for(String key : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = fieldsMap.get(key).getDescribe();
            if (!objectFields.containsKey(objectSelected)) {
                objectFields.put(objectSelected, new List<FieldMetadata>());
            }
            objectFields.get(objectSelected).add(new FieldMetadata(
                fieldDesc.getLabel(),
                fieldDesc.getName(),
                fieldDesc.getType().toString()
            ));
        }

        return objectFields;
    }

    public static List<FieldMetadata> getFields(String objectName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        List<FieldMetadata> objectFields = new List<FieldMetadata>(); 
        for(String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldDesc = fieldMap.get(fieldName).getDescribe();
            objectFields.add(new FieldMetadata(
                fieldDesc.getLabel(),
                fieldDesc.getName(),
                fieldDesc.getType().toString()
            ));
        }

        return objectFields;
    }

    public static SubsequencialObjectMetada getSubReferenceFields(String objectName, String fieldName, String relationship) {
    List<Schema.SObjectType> objects = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(fieldName).getDescribe().getReferenceTo();
    
    if (objects.isEmpty()) {
        // Verifica se não encontrou referências
        return null;
    }

    String objectSelected = objects[0].toString();
    List<Schema.SObjectType> objectSubReference = Schema.getGlobalDescribe().get(objectSelected).getDescribe().fields.getMap().get(relationship).getDescribe().getReferenceTo();
    
    if (objectSubReference.isEmpty()) {
        // Verifica se não encontrou a sub-referência
        return null;
    }

    String objectSubSelected = objectSubReference[0].toString();
    Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(objectSubSelected).getDescribe().fields.getMap();

    SubsequencialObjectMetada subObject = new SubsequencialObjectMetada();
    subObject.objectMetadata = objectSelected;
    subObject.subObjectMetadata = objectSubSelected;

    List<FieldMetadata> objectFields = new List<FieldMetadata>();
    for (String key : fieldsMap.keySet()) {
        Schema.DescribeFieldResult fieldDesc = fieldsMap.get(key).getDescribe();
        objectFields.add(new FieldMetadata(
            fieldDesc.getLabel(),
            fieldDesc.getName(),
            fieldDesc.getType().toString()
        ));
    }
    subObject.values = objectFields;

    return subObject;
}


    public class ObjectMetadata {
        @AuraEnabled public String Label { get; set; }
        @AuraEnabled public String ApiName { get; set; }
    
        public ObjectMetadata(String label, String apiName) {
            this.Label = label;
            this.ApiName = apiName;
        }
    } 

    public class FieldMetadata {
        @AuraEnabled public String Label { get; set; }
        @AuraEnabled public String ApiName { get; set; }
        @AuraEnabled public String Type { get; set; }
    
        public FieldMetadata(String label, String apiName, String type) {
            this.Label = label;
            this.ApiName = apiName;
            this.Type = type;
        }
    } 

    public class SubsequencialObjectMetada {
        @AuraEnabled public String objectMetadata { get; set; }
        @AuraEnabled public String subObjectMetadata { get; set; }
        @AuraEnabled public List<FieldMetadata> values { get; set; }
    
        public SubsequencialObjectMetada(){}

        public SubsequencialObjectMetada(String objectMetadata, String subObjectMetadata, List<FieldMetadata> values) {
            this.objectMetadata = objectMetadata;
            this.subObjectMetadata = subObjectMetadata;
            this.values = values;
        }
    }
}