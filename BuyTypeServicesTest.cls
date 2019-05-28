@isTest
private class BuyTypeServicesTest{
    
    static testMethod void testBuyTypeServices() {
        Test.startTest();
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
        b.GreyyearFrom__c = '1998';
        b.GreyyearTo__c = '2001';
        insert b;
                
        //do request
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/BuyTypeServices/';  
        req.httpMethod = 'GET';
        req.params.put('make', 'ACURA');
        req.params.put('model', 'CSX');
        req.params.put('year', '2000');
        RestContext.request = req;
        RestContext.response = res;

        BuyTypeServices.BuyTypeResponse finalList = BuyTypeServices.calculateBuyType();
        req.params.put('year', '2003');        
        RestContext.request = req;
        finalList = BuyTypeServices.calculateBuyType();
        system.assert(finalList <> null);
        Test.StopTest();
    }
}