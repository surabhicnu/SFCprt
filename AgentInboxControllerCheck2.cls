/****************************************************************************************
 * Name    : AgentInboxControllerCheck2
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



public class AgentInboxControllerCheck2{
    public static final list<String> NOTIFICATION_ACTIVITY_TYPES_LST = Label.AGENTINBOX_NOTIFICATION_ACTIVITY_TYPES.split(';');
    public static final list<String> OKTOPAY_ACTIVITY_TYPES_LST = Label.TP_OKTOPAY_ACTIVITYTYPES_LIST.split(';');
    public string       recordId              {get;set;}
    public File__c      fileObject            {get;set;}
    public File__c      fileObjectSearch      {get;set;}
    public Activity__c  diaryobject           {get;set;}
    public string       sellerName            {get;set;}
    public string       lh1AccountName        {get;set;}
    public date         dueDate               {get;set;}
    public string       queryActivity;
    public string    queryfileList;
    public string       fileSellerName      {get;set;}
    //public string       fileCreatedDate      {get;set;}
    public string       fileYardState  {get;set;}
    public string       yardState  {get;set;}

    public  list<Account>    sellerAcclst   {get;set;}  // sellerlist
    public  list<string>    leftselected    {get;set;}  // Left  panel unselected values
    public  list<string>    rightselected   {get;set;}  // Right panel selected values
    public  list<SelectOption>    yardStateFile   {get;set;}
    public  list<SelectOption>    yardStateActivity   {get;set;}
 
    Set<string>             leftvalues      = new Set<string>(); // Unselected Seller Code values
    Set<string>             rightvalues     = new Set<string>(); // Selected Seller Code values
    Set<String>             originalvalues  = new Set<String>(); // All Seller Code values

    public  list<string>    leftFilesselected    {get;set;}  // Left  panel unselected values
    public  list<string>    rightFilesselected   {get;set;}  // Right panel selected values
 
    Set<string>             leftFilesvalues      = new Set<string>(); // Unselected Seller Code values
    Set<string>             rightFilesvalues     = new Set<string>(); // Selected Seller Code values
    Set<String>             originalFilesvalues  = new Set<String>(); // All Seller Code values

   
    public void refreshActivity(){    
        // changes made by Abhinav on 11/29/2016, chaging the query filter from status <> close to status = open
        // changes made by Abhinav on 01/15/2017, added Due_Date_only__c in the query to fix the issue. The issue is Due Date is showing as next day date on th UI if Due date time is after 6:00 pm cst because it is showing GMT date
        // changes made by Nutan on 09/15/2018, added conditionto remove ok to pay from queue- AND (NOT(ActivityType__c IN : OKTOPAY_ACTIVITY_TYPES_LST))
        activityList = [Select id,Due_Date_only__c,Start_Due_Date__c,End_Due_Date__c,CreatedDate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.File_Compliance_Status__c, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,DueDate__c, Name, ActivityType__c, File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c NOT in ('Seller / CAS Updates','Document Uploaded') AND (ActivityType__c NOT IN : OKTOPAY_ACTIVITY_TYPES_LST) order by createddate desc limit 1000];
    }
  public pagereference filterAllFiles(){
          
            system.debug('********* fileYardState '+fileYardState);
            system.debug('********* fileSellerName '+rightFilesvalues);
            //system.debug('********* fileCreatedDate '+fileObject.Created_DateTime_Search__c);
            
            Date    fileStartCreatedDate;
            Date    fileEndCreatedDate;

            
            if(diaryobject.Start_Created_Date__c != null && diaryobject.End_Created_Date__c != null)
            {
                fileStartCreatedDate = diaryObject.Start_Created_Date__c;
                fileEndCreatedDate = diaryObject.End_Created_Date__c;

                system.debug('********* fileCreatedDate '+fileStartCreatedDate);
                //fileCreatedDate = Date.newInstance(fileCreatedDate.year(),fileCreatedDate.month(),fileCreatedDate.day());  
            }   
            system.debug('********* fileCreatedDate '+fileStartCreatedDate);
                      
            //if(fileObject.Created_DateTime_Search__c != null)
             //   fileCreatedDate  = fileObject.Created_DateTime_Search__c;//(fileObject.Created_DateTime_Search__c).date();
            system.debug('********* fileCreatedDate '+fileYardState);
            
            queryFileList = 'Select id,Owner1__r.name,First_SLA__c,createddate,FileStatus__c, ClaimNumber__c, File_Compliance_Status__c,ownerID,owner.name, LH1Account__c, LH1Account__r.Name,Type_of_Title_Procurement__c, Contact__c, Contact__r.Name, LotNumber__c, Seller__c, Seller__r.Name, State__c, Yard_State__c from File__c where FileStatus__c = \'New File\' and LotNumber__c != null  ';
            if( (rightFilesvalues.size() == 0) && (fileStartCreatedDate == null) && (fileEndCreatedDate == null))
                queryFileList = queryFileList + '  ';   
            
            else if((rightFilesvalues.size() == 0) && (fileStartCreatedDate != null) && (fileEndCreatedDate != null))
            {    
                queryFileList = queryFileList + 'AND SOLR_Created_Date__c >= :fileStartCreatedDate  AND SOLR_Created_Date__c <= :fileEndCreatedDate';
                system.debug('*********** queryFileList cre'+queryFileList);  
            }
            else if( (rightFilesvalues.size() > 0) && (fileStartCreatedDate == null) && (fileEndCreatedDate == null))
                queryFileList = queryFileList + 'AND Seller__r.Name IN: rightFilesvalues';  
            
            else if( (rightFilesvalues.size() > 0) && (fileStartCreatedDate == null) && (fileEndCreatedDate == null))
                queryFileList = queryFileList + '  AND Seller__r.Name IN: rightFilesvalues';  
            
            else if( (rightFilesvalues.size() == 0) && (fileStartCreatedDate != null) && (fileEndCreatedDate != null))
                queryFileList = queryFileList + '  AND SOLR_Created_Date__c >= :fileStartCreatedDate  AND SOLR_Created_Date__c <= :fileEndCreatedDate'; 
          
            else if( (rightFilesvalues.size() > 0) && (fileStartCreatedDate != null) && (fileEndCreatedDate != null))
                queryFileList = queryFileList + ' AND SOLR_Created_Date__c >= :fileStartCreatedDate  AND SOLR_Created_Date__c <= :fileEndCreatedDate AND Seller__r.Name IN: rightFilesvalues'; 
          
            else if( (rightFilesvalues.size() > 0) && (fileStartCreatedDate != null) && (fileEndCreatedDate != null))
                queryFileList = queryFileList + '  AND SOLR_Created_Date__c >= :fileStartCreatedDate  AND SOLR_Created_Date__c <= :fileEndCreatedDate AND Seller__r.Name IN: rightFilesvalues';                    
           
            else if( (rightFilesvalues.size() == 0) && (fileStartCreatedDate == null) && (fileEndCreatedDate == null))
                queryFileList = queryFileList;                    
               
            queryFileList = queryFileList + ' order by createddate asc limit 1000'; 
            system.debug('********* queryFileList '+queryFileList);     
            newfileList = Database.query(queryFileList);
            system.debug('********* newfileList '+newfileList);

               return null;
    }

    public pagereference filterActivities(){
        //DateTime    dt;
        if(diaryObject.Start_Due_Date__c != null & diaryObject.End_Due_Date__c != null){
           // dt = diaryObject.Due_Date__c;
           // Datetime startDate = Datetime.newInstance(dt.year(),dt.month(),dt.day(),23,59,59); //introduced as Nicole requested date specific search for diary activites
           // dt = Datetime.newInstance(dt.year(),dt.month(),dt.day()+1,23,59,59); 
                   system.debug('************** @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ rightSelected ');

              Date startDate = diaryObject.Start_Due_Date__c;
              Date endDate = diaryObject.End_Due_Date__c;
        
        }
        system.debug('********@@@@@@@@****** right@@Selected '+diaryObject.Start_Due_Date__c);
        system.debug('******@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@******** rightSelected@@@@ '+rightvalues);

        // changes made by Abhinav on 11/29/2016, chaging the query filter from status <> close to status = open    
        // changes made by Abhinav on 01/15/2017, added Due_Date_only__c in the query to fix the issue. The issue is Due Date is showing as next day date on th UI if Due date time is after 6:00 pm cst because it is showing GMT date
        // changes made by Nutan on 09/15/2018, added conditionto remove ok to pay from queue- AND (NOT(ActivityType__c IN : OKTOPAY_ACTIVITY_TYPES_LST))
        queryActivity = 'Select id,Due_Date_only__c,CreatedDate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.File_Compliance_Status__c, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c,File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c,Due_Date__c from Activity__c where status__c = \'Open\' AND RecordType.Name = \'File\'  AND ActivityType__c NOT in (\'Seller / CAS Updates\',\'Document Uploaded\') AND (ActivityType__c NOT IN : OKTOPAY_ACTIVITY_TYPES_LST)';
        
        //replacing sellerName with selected seller list rightvalues code
        if(rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.Seller__r.Name IN: rightvalues AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' '; 
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null){
            queryActivity = queryActivity + ' ';
        }   
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues'; //like \'%'+sellerName+'%\'';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + '  AND File__r.Seller__r.Name IN: rightvalues'; 
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' ';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.Seller__r.Name IN: rightvalues';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.Seller__r.Name IN: rightvalues';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND File__r.Seller__r.Name IN: rightvalues';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' ';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name like IN: rightvalues AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\'';
        else if( (rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity + '  AND File__r.Seller__r.Name IN: rightvalues AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + '  AND File__r.Seller__r.Name IN: rightvalues AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if(rightvalues.size() > 0 && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + '  AND File__r.Seller__r.Name IN: rightvalues AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate ';
        else if((rightvalues == null || rightvalues.size()<=0) && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + '  AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if( rightvalues.size() > 0 && diaryObject.ActivityType__c != null && diaryObject.Start_Due_Date__c != null && diaryObject.End_Due_Date__c != null && fileObject.LotNumber__c != null)
            queryActivity = queryActivity + ' AND File__r.Seller__r.Name IN: rightvalues AND Due_Date_only__c <=: endDate AND Due_Date_only__c >=: startDate AND File__r.LotNumber__c = \''+fileObject.LotNumber__c+'\' AND ActivityType__c = \''+diaryObject.ActivityType__c+'\'';
        else if( ((rightvalues == null || rightvalues.size()<=0) || rightvalues.size() <= 0 ) && diaryObject.ActivityType__c == null && diaryObject.Start_Due_Date__c == null && diaryObject.End_Due_Date__c == null && fileObject.LotNumber__c == null)
            queryActivity = queryActivity; //+ '  '; 
        
        if(!(lh1AccountName == null || lh1AccountName == '')){
            queryActivity = queryActivity + ' AND File__r.LH1Account__r.Name like \'%'+ lh1AccountName + '%\'';
        }
        queryActivity = queryActivity + ' order by Duedate__c asc limit 1000 ';     
        system.debug('************** queryActivity '+queryActivity); 
        activityList = Database.query(queryActivity);
        system.debug('************** activityList '+activityList); 
        notificationList = [Select id,File__r.FileStatus__c,createddate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c,File__r.LH1Account__r.name, File__r.LH1Account__r.id, File__r.LH1Account__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c in :NOTIFICATION_ACTIVITY_TYPES_LST order by CreatedDate asc limit 1000];
        return null;
    }
    
    public AgentInboxControllerCheck2(){
        activityFileMap = new Map<Id, List<Activity__c>>();
        diaryObject = new Activity__c ();
        fileObject = new File__c ();
        fileObjectSearch = new File__c ();
        leftselected    = new List<String>();
        rightselected   = new List<String>();
        leftFilesselected    = new List<String>();
        rightFilesselected   = new List<String>(); 
        yardStateFile  = new List<SelectOption>();
        yardStateActivity  = new List<SelectOption>();
        sellerAcclst = new List<Account>(); 
        retrieveList();
        //fileYardState = '';
        originalValues.clear();
        leftvalues.clear();
        rightvalues.clear();
        
        originalFilesValues.clear();
        leftFilesvalues.clear();
        rightFilesvalues.clear();
        
        sellerAcclst = [Select id, Name, ParentId from Account where RecordType.Name = 'TP Seller' AND ParentId != null limit 1000];
        //sellerAcclst = [Select id, Seller__c, Seller__r.Name from File__c where Seller__r.Name != null limit 1000];
        
        if(sellerAcclst == null){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No seller found!'));
        }
        else{
            // populating in originalValues set
            for(Account Act :sellerAcclst)
            {
                originalValues.add(Act.Name);
                originalFilesValues.add(Act.Name);
            }
            leftvalues.addAll(originalValues);
            leftFilesvalues.addAll(originalFilesValues);
        }
        
            //originalValues  =   new Set<String>(cont.Account.Sellercodes__c.split(','));
        
        
        // populating remaining unselected values in leftValues set.
        //leftvalues.addAll(originalValues);
        //leftvalues.removeAll(rightValues);
        for(String s : Label.TP_Yard_State.split(';')){
            yardStateFile.add(new SelectOption(s,s));
            yardStateActivity.add(new SelectOption(s,s));
        }
        
        yardStateFile.sort();
        yardStateActivity.sort(); 
        
        }
    
    public void retrieveList(){ 
        filterActivities();
               // filterAllFiles();

        //Added by Abhinav on 12/20/2016, updated the query to include Primary Owner Information under New Files section
        //Increased limit from 500 to 1000 to show more CAT lots on 15th Aug 18 by Nutan Sharma on request of Nicole
        newFileList = [Select id,Owner1__r.name,First_SLA__c,createddate,FileStatus__c, ClaimNumber__c, File_Compliance_Status__c,ownerID,owner.name, LH1Account__c, LH1Account__r.Name,Type_of_Title_Procurement__c, Contact__c, Contact__r.Name, LotNumber__c, Seller__c, Seller__r.Name, State__c, Yard_State__c from File__c where FileStatus__c = 'New File' and LotNumber__c != null order by createddate asc limit 1000];
        
        // 08/08/2016 update by Abhinav, changing the filter on query to show only Notitifications if Status is Open
        notificationList = [Select id,File__r.FileStatus__c,createddate,Activity_Compliance_Status__c, File__r.Seller__r.name, File__r.ClaimNumber__c,status__c,File__r.LotNumber__c,File__c,File__r.Seller__c,File__r.Yard_State__c,File__r.ownerid,File__r.owner.name, owner.name,ownerid,Duedate__c,Name, ActivityType__c from Activity__c where status__c = 'Open' AND RecordType.Name = 'File' AND ActivityType__c in :NOTIFICATION_ACTIVITY_TYPES_LST order by CreatedDate asc limit 1000];
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
    }
    }
    
    
    
    /*
        Method called for values in 
            unSelected is selected and 
            moved to selectedValues
    */
    public void selectClick(){
        //rightselected.clear();
        system.debug('********** leftselected '+leftselected);
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        //return null;
    }
  public void selectFilesClick(){
        //rightselected.clear();
        system.debug('********** leftselected '+leftFilesselected);
        if(leftFilesselected.size() > 0){
        for(String s : leftFilesselected){
            leftFilesvalues.remove(s);
            rightFilesvalues.add(s);
        }}
        //return null;
    }

    /*
        Method called for values in 
            selected is unSelected and 
            moved to unSelectedValues
    */    
    public void unSelectClick(){
        //leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        //return null;
    } 
    public void unSelectFilesClick(){
        //leftselected.clear();
        for(String s : rightFilesselected){
            rightFilesvalues.remove(s);
            leftFilesvalues.add(s);
        }
        //return null;
    } 
    
    /*
        Method called to move all Unselected values to Selected
    */
    public void selectAll(){
        //leftselected.clear();
        //rightselected.clear();

        for(String s : rightselected){
            rightvalues.remove(s);
        }

        leftvalues.clear();
        rightvalues.addAll(originalValues);

        //return null;
    }
    public void selectFilesAll(){

        for(String s : rightFilesselected){
            rightFilesvalues.remove(s);
        }

        leftFilesvalues.clear();
        rightFilesvalues.addAll(originalFilesValues);

        //return null;
    }
    
    /*
        Method called to move all Selected values to Unselected
    */ 
    public void unSelectAll(){
     
        //rightselected.clear();
        //leftselected.clear();

        for(String s : leftselected){
            leftvalues.remove(s);
        }

        rightvalues.clear();
        leftvalues.addAll(originalValues);

        //return null;
    }
    public void unSelectFilesAll(){
     
        //rightselected.clear();
        //leftselected.clear();

        for(String s : leftFilesselected){
            leftFilesvalues.remove(s);
        }

        rightFilesvalues.clear();
        leftFilesvalues.addAll(originalFilesValues);

        //return null;
    }
    
    /*
        Method to retrieve all Unselected value as SelectOption/picklist values
    */  
    public List<SelectOption> getUnSelectedValues(){
  
        list<SelectOption>  options     = new list  <SelectOption>();
        list<string>        tempList    = new list  <String>();

        tempList.addAll(leftvalues);
        tempList.sort();

        for(string s : tempList){
            options.add(new SelectOption(s,s));
        }

        return options;
    }
    public List<SelectOption> getUnSelectedFilesValues(){
  
        list<SelectOption>  Fileoptions     = new list  <SelectOption>();
        list<string>        tempFilesList    = new list  <String>();

        tempFilesList.addAll(leftFilesvalues);
        tempFilesList.sort();

        for(string s : tempFilesList){
            Fileoptions.add(new SelectOption(s,s));
        }

        return Fileoptions;
    }
    
    
    /*
        Method to retrieve all Selected value as SelectOption/picklist values
    */      
    public List<SelectOption> getSelectedValues(){
        list<SelectOption>  options1 = new list <SelectOption>();
        list<string>        tempList = new list <String>();
        
        tempList.addAll(rightvalues);
        tempList.sort();
        
        for(String s : tempList){
            options1.add(new SelectOption(s,s));
        }
        return options1;
    }
    public List<SelectOption> getSelectedFilesValues(){
        list<SelectOption>  optionsFiles1 = new list <SelectOption>();
        list<string>        tempFilesList = new list <String>();
        
        tempFilesList.addAll(rightFilesvalues);
        tempFilesList.sort();
        
        for(String s : tempFilesList){
            optionsFiles1.add(new SelectOption(s,s));
        }
        return optionsFiles1;
    }
    
    
    /* Returns if page has errorMessages */
    public boolean gethasErrorMessages(){
        return !(ApexPages.hasMessages());
    }    
}