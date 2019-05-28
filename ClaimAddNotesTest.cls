/**
This class tests business logic for addNotes vf page
Version#        Date             Author              Description
----------------------------------------------------------------------------------
1.0             14-Dec-2015      Nutan Sharma        Initial Version
----------------------------------------------------------------------------------
Test coverage for ClaimAddNotesTest : 92%
*/
@isTest (SeeAllData=true)
private class ClaimAddNotesTest {

    static testMethod void myUnitTest() 
    {
        List<RecordType> pricingrt = [select id,name from RecordType where sobjecttype='Activity__c'];
        
        UK_Claims__c c = new UK_Claims__c();
        c.Claim_Number__c = 'eeeee';
        insert c;
        
        List<Activity__c> lstA = new LIST<Activity__c>();
        
        
        Test.startTest();
        apexpages.currentpage().getparameters().put('id',c.id);
        ClaimAddNotes objClaimAddNotes = new ClaimAddNotes(new ApexPages.StandardController(c));
        objClaimAddNotes.edit();
        objClaimAddNotes.editActCA();
        
        objClaimAddNotes.editActOther();
        objClaimAddNotes.cancel();
        objClaimAddNotes.save();
        objClaimAddNotes.saveAct();
        objClaimAddNotes.editActOM();
        
        objClaimAddNotes.save();
        objClaimAddNotes.saveAct();
        objClaimAddNotes.editActSLA();
        objClaimAddNotes.save();
        objClaimAddNotes.saveAct();
        Test.stopTest();
    }
}