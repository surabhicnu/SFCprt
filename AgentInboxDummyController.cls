/****************************************************************************************
 * Name    : AgentInboxDummyController
 * Author  : Abhinav Byrneni
 * Date    : Dec 15, 2015 
 * Purpose : HomePage Controller, used for picking the Files,Activities and searching the Activities by CSRs

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE             AUTHOR                              DESCRIPTION
 * ---------------------------------------------------------------------------
 * 12/15/2015       Abhinav Byrneni                     Created
   08/08/2016       Abhinav Byrneni                     Updated
   11/29/2016       Abhinav Byrneni                     Updated
   12/20/2016       Abhinav Byrneni                     Updated
   01/15/2017       Abhinav Byrneni                     Updated
   09/16/2018       Nutan Sharma                        Updated

*/



public class AgentInboxDummyController{

    public String leftFilesselected { get; set; }

    public String fileYardState { get; set; }
    public static final list<String> NOTIFICATION_ACTIVITY_TYPES_LST = Label.AGENTINBOX_NOTIFICATION_ACTIVITY_TYPES.split(';');
    public static final list<String> OKTOPAY_ACTIVITY_TYPES_LST = Label.TP_OKTOPAY_ACTIVITYTYPES_LIST.split(';');
    public string       recordId        {get;set;}
    public File__c      fileObject      {get;set;}
    public Activity__c  diaryobject     {get;set;}
    public string       sellerName      {get;set;}
    public string       lh1AccountName  {get;set;}
    public date         dueDate         {get;set;}
    public string       queryActivity;

    public void refreshActivity(){    
        // changes made by Abhinav on 11/29/2016, chaging the query filter from status <> close to status = open
        // changes made by Abhinav on 01/15/2017, added Due_Date_only__c in the query to fix the issue. The issue is Due Date is showing as next day date on th UI if Due date time is after 6:00 pm cst because it is showing GMT date
        // changes made by Nutan on 09/15/2018, added conditionto remove ok to pay from queue- AND (NOT(ActivityType__c IN : OKTOPAY_ACTIVITY_TYPES_LST))
        activityList = [Select id,Due_Date_only__c,CreatedDate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.File_Compliance_Status__c, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.state__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,DueDate__c, Name, ActivityType__c, File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c NOT in ('Seller / CAS Updates','Document Uploaded') AND (ActivityType__c NOT IN : OKTOPAY_ACTIVITY_TYPES_LST) order by createddate desc limit 1000];
    }

    public pagereference filterActivities(){
        DateTime    dt;
        if(diaryObject.Due_Date__c != null){
            dt = diaryObject.Due_Date__c;
            Datetime startDateTime = Datetime.newInstance(dt.year(),dt.month(),dt.day(),23,59,59); //introduced as Nicole requested date specific search for diary activites
            dt = Datetime.newInstance(dt.year(),dt.month(),dt.day()+1,23,59,59); 
        }
        // changes made by Abhinav on 11/29/2016, chaging the query filter from status <> close to status = open    
        // changes made by Abhinav on 01/15/2017, added Due_Date_only__c in the query to fix the issue. The issue is Due Date is showing as next day date on th UI if Due date time is after 6:00 pm cst because it is showing GMT date
        // changes made by Nutan on 09/15/2018, added conditionto remove ok to pay from queue- AND (NOT(ActivityType__c IN : OKTOPAY_ACTIVITY_TYPES_LST))
        queryActivity = 'Select id,Due_Date_only__c,CreatedDate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.File_Compliance_Status__c, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.state__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c,File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c from Activity__c where status__c = \'Open\' AND RecordType.Name = \'File\'  AND ActivityType__c NOT in (\'Seller / CAS Updates\',\'Document Uploaded\') AND (ActivityType__c NOT IN : OKTOPAY_ACTIVITY_TYPES_LST)';
        
        if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND File__r.State__c = \''+fileObject.State__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' '; 
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null){
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\'';
        }   
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime ';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\''; 
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.Seller__r.Name like \'%'+sellerName+'%\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.State__c = \''+fileObject.State__c+'\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime ';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime ';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(fileObject.State__c != null && sellerName != null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime ';
        else if(fileObject.State__c != null && sellerName == null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.State__c = \''+fileObject.State__c+'\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(fileObject.State__c == null && sellerName != null && diaryObject.ActivityType__c != null && diaryObject.Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like \'%'+sellerName+'%\' AND DueDate__c <=: dt AND DueDate__c >=: startDateTime AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(fileObject.State__c == null && sellerName == null && diaryObject.ActivityType__c == null && diaryObject.Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity; //+ '  '; 
        
        if(!(lh1AccountName == null || lh1AccountName == '')){
            queryActivity = queryActivity + ' AND File__r.LH1Account__r.Name like \'%'+ lh1AccountName + '%\'';
        }
        queryActivity = queryActivity + ' order by Duedate__c asc limit 1000 ';      
        activityList = Database.query(queryActivity);
        notificationList = [Select id,File__r.FileStatus__c,createddate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.state__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c,File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c in :NOTIFICATION_ACTIVITY_TYPES_LST order by CreatedDate asc limit 1000];
        return null;
    }
    
    public AgentInboxDummyController(){
        activityFileMap = new Map<Id, List<Activity__c>>();
        diaryObject = new Activity__c ();
        fileObject = new File__c ();
        retrieveList();
    }
    
    public void retrieveList(){ 
        filterActivities();
        //Added by Abhinav on 12/20/2016, updated the query to include Primary Owner Information under New Files section
        //Increased limit from 500 to 1000 to show more CAT lots on 15th Aug 18 by Nutan Sharma on request of Nicole
        newFileList = [Select id,Owner1__r.name,First_SLA__c,createddate,FileStatus__c, ClaimNumber__c,Primary_Owner_s_Phone_Test__c, File_Compliance_Status__c,ownerID,owner.name, LH1Account__c, LH1Account__r.Name,Type_of_Title_Procurement__c, Contact__c, Contact__r.Name, LotNumber__c, Seller__c, Seller__r.Name, State__c, Yard_State__c from File__c where FileStatus__c = 'New File' and LotNumber__c != null order by createddate asc limit 1000];
        
        // 08/08/2016 update by Abhinav, changing the filter on query to show only Notitifications if Status is Open
        notificationList = [Select id,File__r.FileStatus__c,createddate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.state__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c in :NOTIFICATION_ACTIVITY_TYPES_LST order by CreatedDate asc limit 1000];
    }
    
    public pagereference acceptActivityOwnership() {
        activity__c act = [select id,ownerid, CreatedDate from activity__c where id =: recordId limit 1];
        act.ownerid = UserInfo.getUserId();
        act.Status__c = 'Open';
        act.Agent_started_date__C = system.today(); 
        update act;
        retrieveList();
        pagereference page = new pagereference('/'+recordId);
        page.setredirect(true);
        return null;
    }
    
    public pagereference acceptActivityAndChangeStatus() {
        activity__c act = [select id,ownerid, CreatedDate from activity__c where id =: recordId limit 1];
        act.ownerid = UserInfo.getUserId();
        act.Status__c = 'Close';
        act.Agent_started_date__C = system.today(); 
        update act;
        retrieveList();
        pagereference page = new pagereference('/'+recordId);
        page.setredirect(true);
        return null;
    }
    
    public Void acceptFileOwnership() {
        File__c f = [select id,ownerid,Filestatus__c from File__c where id =: recordId limit 1];
        f.ownerid = UserInfo.getUserId();
        f.Filestatus__c = 'Open File';
        f.Initial_Accept_Flag__c = true;
        update f;
        retrieveList();
        pagereference page = new pagereference('/'+recordId);
        page.setredirect(true);
    }

    public transient List<Activity__c>          notificationList{get;set;}
    public transient List<Activity__c>          activityList    {get;set;}
    public transient List<File__c>              newFileList     {get;set;}
    public transient List<File__c>              openFileList    {get;set;}
    public transient Map<Id, List<Activity__c>> activityFileMap {get;set;} 

    public Double offset{get{
        TimeZone tz = UserInfo.getTimeZone();
        //Milliseconds to Day
        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    }}    
}