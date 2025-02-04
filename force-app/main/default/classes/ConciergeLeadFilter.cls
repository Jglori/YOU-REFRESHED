public class ConciergeLeadFilter {
  @AuraEnabled(cacheable=true)
  public static String getLeadRecordType(String recordTypeDeveloperName) {

      RecordType rt = [
          SELECT Id 
          FROM RecordType 
          WHERE SObjectType = 'Lead' 
          AND DeveloperName = :recordTypeDeveloperName 
          LIMIT 1
      ];
 
      return rt.Id;
  }

  @AuraEnabled(cacheable=true)
  public static List<Lead> getLeadsExcludingCorretor(String email, String phone, String recordTypeDeveloperName) {
      if (recordTypeDeveloperName == 'Corretor') {
          return [SELECT Id, Name, Email, Phone 
                  FROM Lead 
                  WHERE (Email = :email OR Phone = :phone) 
                  AND RecordType.DeveloperName != :recordTypeDeveloperName 
                  LIMIT 1];
      }
      return new List<Lead>();  
  }
}