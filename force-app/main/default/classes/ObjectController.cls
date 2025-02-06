public with sharing class ObjectController {
    
    @AuraEnabled(cacheable=true)
    public static List<ObjectHelper.ObjectMetadata> getObjects() {
        try {
            return ObjectHelper.getObjects();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<ObjectHelper.FieldMetadata> getFields(String objectName){
        try {
            return ObjectHelper.getFields(objectName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, List<ObjectHelper.FieldMetadata>> getReferenceFields(String objectName, String fieldName){
        try {
            return ObjectHelper.getReferenceFields(objectName, fieldName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static ObjectHelper.SubsequencialObjectMetada getSubReferenceFields(String objectName, String fieldName, String relationship){
        try {
            return ObjectHelper.getSubReferenceFields(objectName, fieldName, relationship);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}