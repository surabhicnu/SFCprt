/****************************************************************************************
 * Name    : AutoPurgeBatchScheduler
 * Author  : Developer 
 * Date    : Dec 25, 2015 
 * Purpose : Batch Class for AutoPurging Audit logs
 
 Sample code for running Batch
 -----------------------------
    AutoPurgeBatchScheduler bthObj = new AutoPurgeBatchScheduler();
    DataBase.executeBatch(bthObj, 2000);

 Sample code for Scheduling Batch
 -----------------------------
    System.Schedule('Purge AuditLog Batch Job', '0 0 0 1 * ?', new AutoPurgeBatchScheduler()); // Run AuditLog purge Batch job 1st of every month

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE             AUTHOR                              DESCRIPTION
 * ---------------------------------------------------------------------------
 * 12/10/2015       Developer                             Created

*/
Global class AutoPurgeBatchScheduler implements Database.Batchable<sObject>,Schedulable{
    Global String   query;      // Dynamic SOQL Query
    Global Integer  batchSize;  // Batch Size

    /* Constructor assigning SOQL Query */
    Global AutoPurgeBatchScheduler(String qry){
        query = qry;
    }

    /* Default Constructor */
    Global AutoPurgeBatchScheduler(){}

    /* START method for Batch class */
    Global Database.QueryLocator start(Database.BatchableContext BC){
        if(query == null){
            DateTime dt             = System.now().addDays(-1*Integer.valueof(Label.Purge_AuditLogs_BatchRun_Days));
            query                   = 'SELECT Id from audit_logs__c where createddate <= :dt ';
            System.debug(' Query : ' + query);
        }
        return Database.getQueryLocator(query);
    }

    /* Execute batch logic calling Peddle Services for initial offer id/push lead */
    Global void execute(Database.BatchableContext BC, List<sObject> scope){
        delete (List<Audit_Logs__c>) scope;
    }

    /* Schedule Execute method for executing batch */
    Global void execute(SchedulableContext SC){
        AutoPurgeBatchScheduler bthjob = (query <> null) ? new AutoPurgeBatchScheduler(query) : new AutoPurgeBatchScheduler();
        batchSize = Integer.valueof(Label.Purge_AuditLogs_BatchSize);
        batchSize = (batchSize == null || batchSize < 1)? 10 : batchSize;
        Id processId = database.executeBatch(bthjob,batchSize);
    }

    /* Finish method for batch */
    Global void finish(Database.BatchableContext BC){
        AsyncApexJob a = 
                    [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
                        TotalJobItems, CreatedBy.Email
                        FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        // Send an email to the Apex job's submitter 
        // notifying of job completion. 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        list<String> toAddresses = new list<String>();
        toAddresses = Label.PurgeAuditLog_Email_To_Addressses.split(';');
        mail.setToAddresses(toAddresses);
        mail.setSubject('Purge AuditLog Batch Job : ' + a.Status);
        mail.setPlainTextBody ('The batch Apex job processed ' + a.TotalJobItems +
                                ' batches with '+ a.NumberOfErrors + ' failures.');
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(Exception e){}
    }
}