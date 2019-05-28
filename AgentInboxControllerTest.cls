/****************************************************************************************
 * Name    : AgentInboxControllerTest
 * Author  : Developer 
 * Date    : Dec 30, 2015 
 * Purpose : AgentInboxControllerTest: Test Class for AgentInboxController.cls

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE          AUTHOR                           DESCRIPTION
 * ---------------------------------------------------------------------------
 * 12/30/2015       Developer                            Created

*/
@isTest (seealldata=false)
private class AgentInboxControllerTest {

    @testSetup static void setup() {
        list<File__c> fileLst = Test.loadData(File__c.sObjectType, 'FileTestData');   
    }

    private static testMethod void agentInboxControllerAcceptActTest() {
          
        Test.StartTest();
     
        TriggerHandler.byPass('FileTriggerHandler');
        TriggerHandler.byPass('DiaryTriggerHandler');
        String activityFileRecordTypeId = Schema.SObjectType.Activity__c.getRecordTypeInfosByName().get('File').getRecordTypeId();
        list<File__c> fileLst= [Select id,name from File__c order by createddate desc limit 2];
        Activity__c act1 = new Activity__c(Status__c='Open', File__c =fileLst[0].id, Due_Date__c = System.today(), ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId,DueDate__c = system.today());
        Activity__c act2 = new Activity__c(Status__c='Open', File__c =fileLst[1].id, Due_Date__c = System.today(), ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId,DueDate__c = system.today());
        list<Activity__c> actLst = new list<Activity__c>();
        actLst.add(act1);
        actLst.add(act2);
        insert actLst;
        Date  fileCreatedDate;
       // if(file__c.Created_DateTime_Search__c != null)
        //fileCreatedDate = file__c.Created_DateTime_Search__c;

  
        AgentInboxController agentCntrl = new AgentInboxController();
        
        //Accept Activity
        agentCntrl.recordId  = actLst[0].id;
        agentCntrl.diaryobject = act1;
        
       
        // Double getVal= agentCntrl.offset();
             // agentCntrl.acceptFileOwnership();

        agentCntrl.acceptActivityOwnership();
        agentCntrl.acceptActivityAndChangeStatus();   
        agentCntrl.filterActivities();
        
        Test.StopTest(); 
    }

    private static testMethod void agentInboxControllerAcceptFileUnitTest() {
        Test.StartTest();
        String activityFileRecordTypeId = Schema.SObjectType.Activity__c.getRecordTypeInfosByName().get('File').getRecordTypeId();
        list<File__c> fileLst= [Select id,name from File__c order by createddate desc limit 2];
        Activity__c act1 = new Activity__c(Status__c='Open', File__c =fileLst[0].id, ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId, DueDate__c = system.today());
        Activity__c act2 = new Activity__c(Status__c='Open', File__c =fileLst[1].id, ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId, DueDate__c = system.today());
        list<Activity__c> actLst = new list<Activity__c>();
        actLst.add(act1);
        actLst.add(act2);
        Date startDate;
        Date endDate;
               

        //insert actLst;

        AgentInboxController agentCntrl = new AgentInboxController();
         //Accept File
        agentCntrl.recordId  =fileLst[0].id;
        agentCntrl.acceptFileOwnership();
                agentCntrl.dueDate = System.today();
        agentCntrl.sellerName = '';
        agentCntrl.fileSellerName = '';

        agentCntrl.refreshActivity();        
        
        Test.StopTest(); 
    }    
    
    private static testMethod void agentInboxControllerFilterUnitTest() {
        Test.StartTest();
        String activityFileRecordTypeId = Schema.SObjectType.Activity__c.getRecordTypeInfosByName().get('File').getRecordTypeId();
        list<File__c> fileLst= [Select id,name from File__c order by createddate desc limit 2];
        Activity__c act1 = new Activity__c(Status__c='Open', File__c =fileLst[0].id, ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId, DueDate__c = system.today());
        Activity__c act2 = new Activity__c(Status__c='Open', File__c =fileLst[1].id, ActivityType__c ='SLA', recordtypeid = activityFileRecordTypeId, DueDate__c = system.today());
        list<Activity__c> actLst = new list<Activity__c>();
        act1.Start_Due_Date__c = System.today();
        act1.End_Due_Date__c = System.today();
        act2.Start_Due_Date__c = System.today();
        act2.End_Due_Date__c = System.today();
        actLst.add(act1);
        actLst.add(act2);
        insert actLst;

        list<string> lst1 = new list<string>();
        lst1.add('tst');
        lst1.add('tst1');
        AgentInboxController agentCntrl = new AgentInboxController();
                       String baseURL = 'AgentInbox';
PageReference pageRef;

        //insert actLst;

        agentCntrl.diaryObject.DueDate__c = system.today();
        agentCntrl.filterActivities();
        agentCntrl.rightFilesselected = lst1;
        agentCntrl.leftFilesselected = lst1;
        agentCntrl.rightselected = lst1;
        agentCntrl.leftselected = lst1;
        agentCntrl.fileObject.State__c = 'NJ';
        //agentCntrl.fileObject.Seller__c = 'Kelly';
        agentCntrl.diaryObject.ActivityType__c = 'SLA';
        agentCntrl.diaryObject.DueDate__c = System.today();
        //agentCntrl.Start_Due_Date__c = System.today();
        //agentCntrl.End_Due_Date__c = System.today();
        agentCntrl.fileObject.LotNumber__c = '636587';
        agentCntrl.filterActivities();


         agentCntrl.diaryObject.ActivityType__c = null;
         agentCntrl.filterActivities();
 
         agentCntrl.diaryObject.DueDate__c = null;
         agentCntrl.filterActivities();               


        agentCntrl.fileObject.State__c = null;
        agentCntrl.filterActivities();    
        

         agentCntrl.fileObject.LotNumber__c = null;
         agentCntrl.filterActivities();       

         agentCntrl.diaryObject.ActivityType__c = 'SLA';
         agentCntrl.filterActivities();
                      
        agentCntrl.fileObject.State__c = 'NJ';
        agentCntrl.filterActivities();    
        
 
         agentCntrl.fileObject.LotNumber__c = '123213';
         agentCntrl.filterActivities();       

         agentCntrl.diaryObject.ActivityType__c = null;
         agentCntrl.filterActivities();        
         
        agentCntrl.fileObject.State__c = 'NJ';
        agentCntrl.diaryObject.ActivityType__c = null;
        agentCntrl.diaryObject.DueDate__c = system.today();
        agentCntrl.fileObject.LotNumber__c = null;      
        agentCntrl.filterActivities();        
        
        agentCntrl.fileObject.State__c = 'NJ';
        agentCntrl.diaryObject.ActivityType__c = null;
        agentCntrl.diaryObject.DueDate__c = null;
        agentCntrl.fileObject.LotNumber__c = '21312';       
        agentCntrl.filterActivities();        

        agentCntrl.fileObject.State__c = 'NJ';
        agentCntrl.diaryObject.ActivityType__c = 'SLA';
        agentCntrl.diaryObject.DueDate__c = null;
        agentCntrl.fileObject.LotNumber__c = '21312';       
        agentCntrl.filterActivities();        

        agentCntrl.fileObject.State__c = 'NJ';
        agentCntrl.diaryObject.ActivityType__c = 'SLA';
        agentCntrl.diaryObject.DueDate__c = System.today();
        agentCntrl.fileObject.LotNumber__c = '21233';       
        agentCntrl.filterActivities();              
        
        agentCntrl.fileObject.State__c = null;
        agentCntrl.diaryObject.ActivityType__c = 'SLA';
        agentCntrl.diaryObject.DueDate__c = System.today();
        agentCntrl.fileObject.LotNumber__c = '21233';       
        agentCntrl.filterActivities();              

        agentCntrl.fileObject.State__c = null;
        agentCntrl.diaryObject.ActivityType__c = null;
        agentCntrl.diaryObject.DueDate__c = System.today();
        agentCntrl.fileObject.LotNumber__c = '21233';       
        agentCntrl.filterActivities();          
        
        agentCntrl.fileObject.State__c = null;
        agentCntrl.diaryObject.ActivityType__c = 'SLA';
        agentCntrl.diaryObject.DueDate__c = System.today();
        agentCntrl.fileObject.LotNumber__c = null;      
        agentCntrl.filterActivities();    
        
        agentCntrl.filterAllFiles(); 
        agentCntrl.selectClick(); 
        agentCntrl.selectFilesClick(); 
        agentCntrl.unSelectClick(); 
        agentCntrl.unSelectFilesClick(); 
        agentCntrl.selectAll(); 
        agentCntrl.selectFilesAll(); 
        agentCntrl.unSelectAll();   
        
        agentCntrl.unSelectFilesAll(); 
        agentCntrl.getUnSelectedValues(); 
        agentCntrl.getUnSelectedFilesValues(); 
        agentCntrl.getSelectedValues(); 
        agentCntrl.getSelectedFilesValues(); 
        agentCntrl.gethasErrorMessages(); 
        Test.StopTest(); 
    }       
}