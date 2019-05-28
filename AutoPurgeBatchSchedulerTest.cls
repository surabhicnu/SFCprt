/****************************************************************************************
 * Name    : AutoPurgeBatchSchedulerTest
 * Author  : Developer 
 * Date    : Dec 25, 2015 
 * Purpose : AutoPurgeBatchSchedulerTest: Test Class for AutoPurgeBatchScheduler.cls

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE          AUTHOR                           DESCRIPTION
 * ---------------------------------------------------------------------------
 * 12/25/2015       Developer                            Created

*/
@isTest (seealldata=false)
private class AutoPurgeBatchSchedulerTest {
    private static testMethod void AutoPurgeBatchSchedulerUnitTest() {
        Test.startTest();
        String jobId = System.schedule('Auto Purge Audit Log Job Test','0 0 0 * * ?', new AutoPurgeBatchScheduler());
        Test.stopTest();
    }
    private static testMethod void AutoPurgeBatchSchedulerUnitTest1() {
        insert (new Audit_Logs__c());
        Test.startTest();
        AutoPurgeBatchScheduler autoPurgeBatch = new AutoPurgeBatchScheduler('Select id from audit_logs__c');
        Database.executeBatch(autoPurgeBatch, 200);
        //String jobId = System.schedule('Auto Purge Audit Log Job Test','0 0 0 * * ?', new AutoPurgeBatchScheduler());
        Test.stopTest();
    }    
}