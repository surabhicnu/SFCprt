/****************************************************************************************
 * Name    : beforeInsertLead_UpdateCityStateTest
 * Author  : Developer 
 * Date    : Jun 15, 2016 
 * Purpose : beforeInsertLead_UpdateCityStateTest: Test Class for beforeInsertLead_UpdateCityState Apex Trigger

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE          AUTHOR                           DESCRIPTION
 * ---------------------------------------------------------------------------
 * 06/15/2016       Developer                            Created

*/

@isTest (seealldata=false)
private class beforeInsertLead_UpdateCityStateTest {
    @testSetup static void setup() {
        // Create common test accounts
        list<Lead> ldLst = Test.loadData(Lead.sObjectType, 'PeddleLeadTestData');
        list<LVT_Rules__c> lvtRulesLst = Test.loadData(LVT_Rules__c.sObjectType, 'LVTRulesTestData');
        list<LVT_Rules_Field_Comparison_Mapping__c> lvtRulesFieldComparisonLst = Test.loadData(LVT_Rules_Field_Comparison_Mapping__c.sObjectType, 'LVTRulesFieldComparisonMappingTestData');
    }

    private static testMethod void LeadEventsHandlerUnitTest() {
        Test.startTest();
        LeadEventsHandler.suppress_BeforeEvents = true;
        LeadEventsHandler.suppress_AfterEvents  = true;
        Test.stopTest();
    }
    
    private static testMethod void myMethod(){
        
        list<buytype__c> bList = [select id from Buytype__c];
        delete bList;
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.IsAuction__c = true;
        insert b;
        
        
        
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        insert l;
        
        delete b;
    
    }
    
     private static testMethod void myMethod2(){
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.IsJunk__c = true;
        insert b;
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        insert l;
        
        delete b;
    
    }
    
    private static testMethod void myMethod3(){
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.GreyYearFrom__c = '2000';
        b.GreyYearTo__c = '2002';
        insert b;
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.year__c = '2004';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        insert l;
        
        delete b;
    
    }
    
    private static testMethod void myMethod4(){
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.GreyYearFrom__c = '2000';
        b.GreyYearTo__c = '2002';
        insert b;
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.year__c = '2002';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        insert l;
        
        delete b;
    
    }
    
    private static testMethod void myMethod5(){
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.AuctionYearFrom__c = '2000';
       
        insert b;
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.year__c = '2002';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        insert l;
        
        delete b;
    
    }
    
    private static testMethod void myMethod6(){
        
        Vehicle_Make__c make = new Vehicle_Make__c();
        make.Name = 'ACURA';
        make.Make_Code__c = 'ACUR';
        make.Vehicle_Type__c = 'AUTOMOBILE';
        make.Vehicle_Type_Code__c = 'V';
        insert make;
        
        Vehicle_Model__c model = new Vehicle_Model__c();
        model.Name = 'CSX';
        model.Vehicle_Make__c = make.Id;
        model.Make_Code__c = 'ACUR';
        insert model;
        
        BuyType__c b = new BuyType__c();
        b.TypeofVehicle__c = 'AUTOMOBILE';
        b.Make__c = 'ACURA';
        b.VehicleModel__c = model.Id;
        b.AuctionYearFrom__c = '2000';
       
        insert b;
    
        Lead l = new Lead();
        l.RecordTypeId = Schema.SObjectType.lead.getRecordTypeInfosByName().get('CopartDirect Person Lead').getRecordTypeId();
        l.LastName = 'lastName';
        l.Make__c = 'ACURA';
        l.Model__c = 'CSX';
        l.year__c = '1999';
        l.Type_Of_Vehicle__c = 'AUTOMOBILE';
        l.Auction_Buy_Reject__c = false;
        l.Price_Requested_VPA__c = UserInfo.getUserId();
        l.Manager_Price__c = 100;
        l.Pickup_Postal_Code__c = '75063';
        l.Junk_price_bump_request_denied__c = false;
        l.Pickup_Address1__c = 'a';
        l.Pickup_Address2__c = 'b';
        l.Pickup_City__c = 'IRVING';
        l.Pickup_Location_State__c = 'TX';
        l.Pickup_Postal_Code__c  = '67890';
        insert l;
        
        Lead le = [select Auction_Buy_Reject__c from Lead where id = :l.id];
        le.Auction_Buy_Reject__c = true;
        le.OwnerId = UserInfo.getUserId();
        le.Manager_Price__c = 200;
        le.wizard_step__c = '5';
        le.Pickup_Postal_Code__c = '75254';
        le.Junk_price_bump_request_denied__c = true;
        le.Pickup_Address1__c = 'c';
        le.Pickup_Address2__c = 'd';
        le.Pickup_City__c = 'DALLAS';
        le.Pickup_Location_State__c = 'DT';
        le.Pickup_Postal_Code__c  = '67891';
        update le;
        
    
    }

    private static testMethod void myMethod1() {
        list<Lead> ldLst = [SELECT Id, LastName, FirstName, Name, Unformatted_Phone__c,Phone, Email from lead limit 1];

        citypostalcode__c cityPostalCode = new citypostalcode__c(postalcode__c='30328',city__c='Atlanta',state__c='GA');
        insert cityPostalCode;
        
        Test.startTest();
        Lead ld = new lead(FirstName = ldLst[0].FirstName, LastName = ldLst[0].LastName, Phone = ldLst[0].Phone, Email = ldLst[0].Email, make__c = 'FORD',Type_of_Vehicle__c='AUTOMOBILE',Veh_Miles__c=200000,Model__c='Test',State='VA',Year__c='2000',LeadSource = 'www.copart.com',postalcode = '30328');
        insert ld;
        Test.stopTest();
    }
    
}