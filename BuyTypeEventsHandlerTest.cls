/****************************************************************************************
 * Name    : BuyTypeEventsHandlerTest
 * Author  : Developer 
 * Date    : Oct 24, 2016 
 * Purpose : BuyTypeEventsHandlerTest: Test Class for BuyTypeEventsHandler.cls

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE          AUTHOR                           DESCRIPTION
 * ---------------------------------------------------------------------------
 * 10/24/2016    Developer                            Created

*/
@isTest (seealldata=false)
private class BuyTypeEventsHandlerTest {
    private static testMethod void BuyTypeEventsHandlerUnitTest() {
		Vehicle_Make__c vehMake = new Vehicle_Make__c(Name='ACURA',Make_Code__c='ACUR',Vehicle_Type_Code__c='V',	Vehicle_Type__c='AUTOMOBILE');
		insert vehMake;

		Vehicle_Model__c vehModel = new Vehicle_Model__c(Name='R8',Vehicle_Make__c=vehMake.id);
		insert vehModel;

		BuyType__c buyType = new BuyType__c(AuctionYearFrom__c='2001', GreyYearFrom__c='2002', GreyYearTo__c='2005', IsAuction__c=false, IsJunk__c=false, Make__c=vehMake.Name, TypeofVehicle__c=vehMake.Vehicle_Type__c, VehicleModel__c=vehModel.id);
		insert buyType;
		
        Test.startTest();
        buyType.IsAuction__c = true;
		update buyType;
        Test.stopTest();
    }
}