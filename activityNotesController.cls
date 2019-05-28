public class activityNotesController {

    

    public List<Activity__c> diaryActivities{get;set;} 


    public activityNotesController(ApexPages.StandardController controller) {
   
        file__c f  = (File__c)controller.getRecord();
        
        file__c file = [select id from File__c where id =: f.id];
        
        diaryActivities =  [select Id,DueDate__c,Status__c,ActivityType__c,CreatedDate,LotNotes__c,File__r.LotNumber__c from Activity__c where File__c = :file.id AND ActivityType__c Not in ('Seller / CAS Updates','Document Uploaded', 'Mail Received') limit 100];
      
        
    
    }




}