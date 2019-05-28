/**
This class tests business logic for ClaimsendEmailandGenerateTest vf page
Version#        Date             Author              Description
----------------------------------------------------------------------------------
1.0             14-Dec-2015      Nutan Sharma        Initial Version
----------------------------------------------------------------------------------
Test coverage for ClaimsendEmailandGenerateTest : 92%
*/
@isTest (SeeAllData=true)
private class ClaimsendEmailandGenerateTest {

    static testMethod void myUnitTest() 
    {
        List<RecordType> pricingrt = [select id,name from RecordType where sobjecttype='Activity__c'];
        
        UK_Claims__c c = new UK_Claims__c();
        c.Claim_Number__c = 'eeeee';
        insert c;
        
        List<Activity__c> lstA = new LIST<Activity__c>();
        
        
        Test.startTest();
        apexpages.currentpage().getparameters().put('id',c.id);
        ClaimsendEmailandGenerate objClaimsendEmailandGenerate = new ClaimsendEmailandGenerate(new ApexPages.StandardController(c));
        objClaimsendEmailandGenerate.generatePersonalLetter();
        objClaimsendEmailandGenerate.generateSettlementOffer();
        objClaimsendEmailandGenerate.generateSalvageLetter();
        objClaimsendEmailandGenerate.generateSwiftSettlement();
        objClaimsendEmailandGenerate.generateRetentionSalvage();
        objClaimsendEmailandGenerate.generateUnableToLetter();
        
        objClaimsendEmailandGenerate.generateEldonSettlementOffer();
        objClaimsendEmailandGenerate.generateEldonSettlementFinal();
        objClaimsendEmailandGenerate.generateEldonSettlementPolicyValue();
        objClaimsendEmailandGenerate.generateEldonUnabletoContact();
        objClaimsendEmailandGenerate.generateEldonUnabletoValuation();
        Test.stopTest();
    }
}