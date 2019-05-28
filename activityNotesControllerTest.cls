/****************************************************************************************
 * Name    : activityNotesControllerTest 
 * Author  : Developer 
 * Date    : September 07, 2016 
 * Purpose : ActivityNotesControllerTest : Test Class for ActivityNotesController.cls

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE          AUTHOR                           DESCRIPTION
 * ---------------------------------------------------------------------------
 * 08/07/2016       Developer                            Created

*/
@isTest (seealldata=false)
private class activityNotesControllerTest {
    private static testMethod void activityNotesControllerTest1(){
        // Create ParentAccount
        Account parentAccount   = new Account(name = 'ParentAccount');
        insert parentAccount;

        // Create seller
        Account seller          = new Account(name = 'Seller', ParentId = parentAccount.id);
        insert seller;

        list<SellerProfile__c> sellerProfList = new list<SellerProfile__c>(); 
        SellerProfile__c sellerProf = new SellerProfile__c(
                            EffectiveStartDate__c = System.today().adddays(-1),
                            EffectiveEndDate__c   = System.today().adddays(1),
                            FileCompletion__c     = 2,
                            Seller__c = parentAccount.id, 
                            FollowUpLOG__c = 4,
                            WaitingLOG__c = 5
                        );
        sellerProfList.add(sellerProf);
        SellerProfile__c sellerProf1 = new SellerProfile__c(
                            EffectiveStartDate__c = System.today().adddays(+2),
                            EffectiveEndDate__c   = System.today().adddays(+5),
                            FileCompletion__c     = 5,
                            FollowUpLOG__c = 2,
                            WaitingLOG__c = 3,
                            Seller__c = parentAccount.id
                        );                 
        sellerProfList.add(sellerProf1);
        insert sellerProfList;

        File__c fle = new File__c(seller__c = seller.id);
        insert fle; 
        
        Test.startTest();
        try{
                                        
            Activity__c act1 = new Activity__c(Status__c='Open', File__c =fle.id, ActivityType__c ='Follow Up LOG', recordtypeid = Schema.SObjectType.Activity__c.getRecordTypeInfosByName().get('File').getRecordTypeId());
            Activity__c act2 = new Activity__c(Status__c='Open', File__c =fle.id, ActivityType__c ='Waiting LOG', recordtypeid = Schema.SObjectType.Activity__c.getRecordTypeInfosByName().get('File').getRecordTypeId());
            list<Activity__c> actLst = new list<Activity__c>();
            actLst.add(act1);
            actLst.add(act2);
            insert actLst;


            activityNotesController activityNotesCntrl = new activityNotesController(
                                        new ApexPages.StandardController(fle));         
        }
        catch(Exception e){}
        Test.StopTest();
    }
}