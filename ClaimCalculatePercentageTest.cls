/**
This class tests business logic for ClaimCalculatePercentage 
Version#        Date             Author              Description
----------------------------------------------------------------------------------
1.0             14-Dec-2015      Nutan Sharma        Initial Version
----------------------------------------------------------------------------------
Test coverage for ClaimCalculatePercentageTest : 92%
*/
@isTest (SeeAllData=true)
private class ClaimCalculatePercentageTest {

    static testMethod void myUnitTest() 
    {
        List<RecordType> art = [select id,name from RecordType where sobjecttype='Account' and Name='UK Claim Seller'];
        
        Account A = new Account();
        A.Name = 'AXA';
        if(art.size() > 0)
            A.RecordTypeId = art[0].id;
        insert A;
        
        UK_Claims__c c = new UK_Claims__c();
        c.Claim_Number__c = 'eeeee';
        c.Salvage_Accepted__c = 'Y';
        c.Policy_Holder_Deceased__c = 'Y';
        
        c.Excess_Amount__c = 300;
        c.Value_of_offer_Accepted__c = 300;
        c.Category__c = 'B';
        c.Claim_Status__c = 'Closed';
        c.Seller__c = A.id;
        insert c;
        
        UK_Claims_Work_Order__c w = new UK_Claims_Work_Order__c ();
        w.Work_Order__c = 'PPH - Personal Plate Hold';
        w.Claim__c = c.id;
        w.Additional_Information__c = 'test';
        insert w;
        
        w.Additional_Information__c = 'testing';
        update w;
        
        List<RecordType> actrt = [select id,name from RecordType where sobjecttype='Activity__c' and Name='UK Claims Offer Made'];
        
        Activity__c act = new Activity__c ();
        act.Offer_Accepted__c = true;
        act.Claim_Settlement__c = c.id;
        act.Value_of_offer_Accepted__c = 350;
        act.Status__c = 'Open';
        if(actrt.size() > 0)
            act.RecordTypeId = actrt[0].id;
        insert act;
        
        //act.First_Contact_made__c = 'Y';
        act.ActivityType__c = '1st Call to PH SLA';
        act.Status__c = 'Close';
        update act;
        
        
        
        ClaimCalculatePercentage objClaimCalculatePercentage = new ClaimCalculatePercentage(new ApexPages.StandardController(c));
        ClaimCalculatePercentage.calculate(c.id);
        
        Account Aobj = new Account();
        Aobj.Name = 'Eldon';
        if(art.size() > 0)
            Aobj.RecordTypeId = art[0].id;
        insert Aobj;
        
        c.Bank_Details_confirmed_with_PolicyHolder__c = 'Y';
        c.First_Contact_made__c = 'Y';
        c.ICE_completed_date_time__c = system.now();
        c.Claim_Status__c = 'Open';
        c.Category__c = 'C';
        c.Seller__c = Aobj.id;
        c.Vehicle_Type__c = 'C Motorcycle/ATV';
        update c;
        
        ClaimCalculatePercentage.calculate(c.id);
    }
}