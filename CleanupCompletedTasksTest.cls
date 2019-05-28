/**
* @author Ramesh Chennupati
* @date 03/19/2012
* @description It is a test class to prove the code coverage of CleanupCompletedTasks is more than 75%.
*/
@IsTest
private class CleanupCompletedTasksTest{
 
    /**
    * @author Ramesh Chennupati
    * @date 03/19/2012
    * @description It is a test method to get the code coverage of 
       clsAPSService.changeAssignment(RestRequest,RestResponse) method.
    * @return None
    */
    static testMethod void myUnitTest() 
    {
        List<RecordType> rtL = [SELECT id, Name FROM RecordType WHERE Name = 'CopartDirect Person Lead' AND SobjectType = 'Lead'];
        
        Lead objLd = new Lead();
        objLd.FirstName = 'first';
        objLd.LastName = 'test';
        objLd.Phone = '88969869696';
        objLd.PostalCode = '43026';
        objLd.Type_of_Vehicle__c = 'Automobile';
        objLd.Make__c = 'NISSAN';
        if(rtL.size() > 0)
                objLd.RecordTypeId = rtL[0].id;
        //if(rtL != null)
        //        objLd.RecordTypeId = rtL.id;
        objLd.Year_new__c = '2013';
        objLd.Lien__c= 'No';
        insert objLd;
        
        Task objT = new Task();
        objT.Status = 'Completed';
        objT.Subject = 'Test case';
        objT.Description = 'Testing case description';
        insert objT;
        
        CleanupcompletedTasks ct=new CleanupcompletedTasks();
        test.startTest();
        String jobId =system.schedule('CleanupTaskTest', '0 0 23 * * ?',ct);
        test.stopTest();
        
        system.assertNotEquals(null, jobId);
    }
}