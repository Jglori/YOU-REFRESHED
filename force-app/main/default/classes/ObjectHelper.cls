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
}