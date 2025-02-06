public with sharing class Utils {

    private static String sfdcURL = URL.getOrgDomainUrl().toExternalForm();

    @AuraEnabled(cacheable=true)
    public static List<PicklistValueDto> getPicklistValues(String objAPIName, String fieldAPIName) {

        if (objAPIName == null) throw new AuraHandledException('o objeto não foi incializado.');
        if (fieldAPIName == null) throw new AuraHandledException('o field não foi incializado.');
        
        SObject subject = (SObject) Type.forName('Schema.' + objAPIName).newInstance();

        List<PicklistValueDto> pvd = new List<PicklistValueDto>();
        Schema.DescribeFieldResult fieldResult = subject.getSObjectType().getDescribe().fields.getMap().get(fieldAPIName).getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry entry : ple) {
            pvd.add(new PicklistValueDto(
                entry.getLabel(),
                entry.getValue()
            ));
        }
 
        return pvd;
    }


    // @AuraEnabled(cacheable=true)
    // public static List<PicklistValueDto> getPicklistValues(SObject subject, String fieldApiName) {
    //     Schema.DescribeSObjectResult objDescribe = subject.getSObjectType().getDescribe();
    //     String objectAPIName = objDescribe.getName();
    //     Id recordTypeId = (Id) subject.get('RecordTypeId');

    //     String restAPIURL = sfdcURL + '/services/data/v50.0/ui-api/object-info/'+objectAPIName+'/picklist-values/'+recordTypeId+'/'+fieldApiName;

    //     HttpRequest httpRequest = new HttpRequest();  
    //     httpRequest.setMethod('GET');  
    //     httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());     
    //     httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
    //     httpRequest.setEndpoint(restAPIURL);  

    //     String response = '';
    //     try {  

    //         Http http = new Http();  
    //         HttpResponse httpResponse = http.send(httpRequest);  

    //         if (httpResponse.getStatusCode() == 200 ) {  
    //             response = httpResponse.getBody();  
    //         } else { 
    //             throw new CalloutException( httpResponse.getBody() );  
    //         }  

    //     } catch(System.Exception e) {  
    //         throw e;  
    //     }

    //     Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
    //     List<Object> picklistEntries = (List<Object>) responseMap.get('values');
    //     List<PicklistValueDto> pvd = new List<PicklistValueDto>();
    //     for (Object entry : picklistEntries) {
    //         Map<String, Object> picklistEntry = (Map<String, Object>) entry;
    //         pvd.add(new PicklistValueDto(
    //             (String) picklistEntry.get('label'),
    //             (String) picklistEntry.get('value')
    //         ));
    //     }

    //     System.debug(pvd);
    //     return pvd;
    // }
    
    public static Integer getStepDifference(List<PicklistValueDto> picklistValues, String objectPicklistValue) {
        Integer c = 0;

        for (PicklistValueDto pvd : picklistValues) {
            System.debug(pvd.value);
            if (pvd.value == objectPicklistValue) return c;
            c++;
        }
        return -1;
    }

    public class PicklistValueDto {
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public String value { get; set; }

        public PicklistValueDto(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}