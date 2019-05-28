/**
* @author Ramesh Chennupati
* @date 03/16/2012
* @description It is schedular class to schedule the cron job Cleanup Completed Tasks.
*/
global class CleanupcompletedTasks implements Schedulable{
    /**
    * @author Ramesh Chennupati
    * @date 03/16/2012
    * @description This method is to schedule the cron job.
    * @return None
    */
   global void execute(SchedulableContext SC) 
   {
        delCompTasks();
   }
    /**
    * @author Ramesh Chennupati
    * @date 03/16/2012
    * @description This method is to query the completed tasks and delete.
    * @return None
    */
   public void delCompTasks()
   {
        date lstModDate=date.today().addMonths(-4);
        boolean EndOfRecords=false;
        List<task> lstDelT = new List<task>();
        RecordType rt=[select id from RecordType where sobjecttype='Lead' and name=:'CopartDirect Person Lead' limit 1];
        
        list<Lead> lstLead =[select id, RecordTypeId, RecordType.Name, (select id, WhoId, Status from tasks where Status='Completed' and lastmodifieddate<:lstModDate) from Lead where RecordTypeId =:rt.id limit 50000];
        Map<Id,String> mapLeadIdRT = new Map<Id,String>();
        
        if(lstLead.size() > 0)
        {
            for(Lead L :lstLead)
            {
                if(mapLeadIdRT.get(L.Id) == null)
                    mapLeadIdRT.put(L.Id,L.RecordType.Name);
            }
        }
        
        
        while(!EndOfRecords)
        {
            list<task> delTaskLst=[select id, WhoId from task where status='Completed' and lastmodifieddate<:lstModDate limit 49000];
            if(delTaskLst.size()!=49000)
            {
                EndOfRecords=true;
            }
            
            if(delTaskLst.size() > 0)
            {
                for(Task T:delTaskLst)
                {
                    if(mapLeadIdRT.get(T.WhoId) != 'CopartDirect Person Lead')
                        lstDelT.add(T);
                }
            }
            
            if(lstDelT.size() > 0)
            {
                delete lstDelT;
            }    
        }
   }
}