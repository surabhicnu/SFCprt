public class ClaimAddNotes {

public UK_Claims__c objClaim {get;set;}
public Note objNote {get;set;}
public Task objTask {get;set;}
public Activity__c objActivityCA {get;set;}
//public List<Note> lstNotes {get;set;}
public List<RecordType> lstRT {get; set;}
public boolean edit {get;set;}
//public boolean editTask {get;set;}
public boolean editAct {get;set;}
public boolean editActCA {get;set;}
public boolean editActOM {get;set;}
public boolean editActSLA {get;set;}
public boolean editActOther {get;set;}
public boolean taskrt {get;set;}
public Id SelectedRecordType {get ;set;}


    public ClaimAddNotes(ApexPages.StandardController controller) {
        this.objClaim = (UK_Claims__c)controller.getRecord();
        this.objClaim = [Select id From UK_Claims__c where id=:objClaim.id limit 1];
        lstRT = new List<RecordType>();
        //objTask = new Task();
        objNote = new Note();
        objActivityCA = new Activity__c();
        edit = false;
        //editTask = false;
        editActCA = false;
        editActOM = false;
        editActSLA = false;
        editActOther = false;
        //taskrt = false;
        //lstNotes = new List<Note>();
        //lstNotes = [Select id, Title, Body, CreatedDate, Ownerid, Owner.Name from Note where Parentid =:objClaim.id];
    }
    
    public void edit() {
        edit = true;
        //return null;
    }
    //public void editTask() {
        //editTask = true;
        //return null;
    //}
    public void editActCA() {
        objActivityCA.RecordTypeID = rtClaim('UK Claims Contact Attempts');
        objActivityCA.ActivityType__c = 'Contact Attempt';
        editActCA = true;
        //return null;
    }
    public void editActOM() {
    objActivityCA.RecordTypeID = rtClaim('UK Claims Offer Made');
        objActivityCA.ActivityType__c = 'Offer Made';
        editActOM = true;
        //return null;
    }
    public void editActSLA() {
    objActivityCA.RecordTypeID = rtClaim('UK Claims Activity'); 
        editActSLA = true;
        //return null;
    }
    public void editActOther() {
    objActivityCA.RecordTypeID = rtClaim('UK Claims Activity'); 
        editActOther = true;
        //return null;
    }
    
    //code behind the Cancel button
    public void cancel() {
        edit = false;
        editActCA = false;
        editActOM = false;
        editActSLA = false;
        editActOther = false;
    }
    
    public PageReference save() {
        if(objNote.Title != null)
        {
            objNote.ParentId = objClaim.Id;
            try{
                insert objNote;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record has been saved.'));
            }catch(exception e){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Some error occured, contact to admin.'));
            system.debug('++++++++ Excption '+e);
            }    
        }
        objNote = new Note();
        edit = false;
        editActCA = false;
        editActOM = false;
        editActSLA = false;
        editActOther = false;
        //string claimURL = '/'+objClaim.id+'?inline=0';
        //PageReference pr = new PageReference(claimURL);
        //return pr;
        return null;
    }
    
    public Id rtClaim(String rtType)
    {
        lstRT = [Select id, Name from RecordType where sobjecttype =:'Activity__c'];
        if(lstRT.size() > 0)
        {
            for(RecordType rt :lstRT)
            {
                if(rtType == rt.Name)
                    SelectedRecordType = rt.id;
            }
        }
        return SelectedRecordType;
    }
    
    public PageReference saveAct() {
        
        /*if(editActCA == true)
            objActivityCA.RecordTypeID = rtClaim('UK Claims Contact Attempts');
        else if(editActOM == true)
            objActivityCA.RecordTypeID = rtClaim('UK Claims Offer Made');
        else
            objActivityCA.RecordTypeID = rtClaim('UK Claims Activity'); */
               
        objActivityCA.Claim_Settlement__c = objClaim.Id;
        try{
                insert objActivityCA;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Record has been saved'));
               
            }catch(exception e){ 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Some error occured, contact to admin.'));

            system.debug('++++++++ Excption '+e);
            } 
        //insert objActivityCA;
        
        edit = false;
        editActCA = false;
        editActOM = false;
        editActSLA = false;
        editActOther = false;
        objActivityCA = new Activity__c();
        //string claimURL = '/'+objClaim.id+'?inline=0';
        //PageReference pr = new PageReference(claimURL);
        //return pr;
        return null;
    }
    
    /*public PageReference save() {
        if(objNote.Title != null)
        {
            objNote.ParentId = objClaim.Id;
            insert objNote;
        }
        if(objActivity.Subject__c != null)
        {
            
            List<RecordType> lstRT = [Select id, name from RecordType where sobjecttype =:'Activity__c' and name =:'UK Claims Activity' limit 1];
            if(lstRT.size() > 0)
                objActivity.RecordTypeID = lstRT[0].id;
            objActivity.Claim_Settlement__c = objClaim.Id;
            insert objActivity;
        }
        if(objTask.Subject != null)
        {
             
            objTask.WhatId = objClaim.Id;
            insert objTask;
        }
        edit = false;
        editAct = false;
        editTask = false;
        return null;
    }
    
    public void changeRT() {
        System.debug('************* rt val '+SelectedRecordType);
        //List<RecordType> lstT = [Select id, name from RecordType where sobjecttype =:'Task' and name=:SelectedRecordType limit 1];
        if(SelectedRecordType != null)
            objTask.RecordTypeID = SelectedRecordType ;     
        System.debug('************* objTask'+objTask);
         
        taskrt = true;
        System.debug('************* taskrt'+taskrt);
    }
    
    public List<selectOption> getRecordTypes()
    {
        List<selectOption> rTypes = new List<selectOption>();    
        for (RecordType  a : 
                [Select Id, Name,DeveloperName FROM RecordType 
                where SobjectType = 'Task' and (name=:'UK Claims Contact Attempts' or name =:'UK Claims Offer Made')]) 
                {
                    rTypes.add(new selectOption(a.Id, a.Name));
                }
        return rTypes; 
    }*/
}