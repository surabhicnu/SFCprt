@isTest (seealldata=false)
private class B2BLVTIntegrationHelperTest{

    public static String errorMessage;

    @testSetup static void setup() {
        // Create common test accounts
        Test.loadData(Integration_Settings__c.sObjectType, 'IntegrationSettingsTestData');
        list<LVT_Rules__c> lvtRulesLst                                          = Test.loadData(LVT_Rules__c.sObjectType, 'LVTRulesTestData');
        list<LVT_Rules_Field_Comparison_Mapping__c> lvtRulesFieldComparisonLst  = Test.loadData(LVT_Rules_Field_Comparison_Mapping__c.sObjectType, 'LVTRulesFieldComparisonMappingTestData');
    }
    
    static testMethod void postB2BLVTIntegrationHelper() {
        
        Integration_Settings__c b2bOAuth = Integration_Settings__c.getInstance('B2BOAUTHToken');
        Integration_Settings__c b2bLVTUpdate = Integration_Settings__c.getInstance('B2BLVTUpdate');
        
		MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(b2bOAuth.EndPoint__c, 'LVTB2BTokenResponseTestData');
        multimock.setStaticResource(b2bLVTUpdate.Endpoint__c, 'LVTB2BResponseTestData');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');

        Test.setMock(HttpCalloutMock.class, multimock);
        
        String JSONMsg              = [Select Body From StaticResource Where Name = 'LVTB2BProcessRequestData' LIMIT 1].body.toString();
        list<LVTProcessWrapper.LVTProcessRequest>  lvtRequestLst = (list<LVTProcessWrapper.LVTProcessRequest>) JSON.deSerialize(JSONMsg, list<LVTProcessWrapper.LVTProcessRequest>.class);
        list<LVTProcessWrapper.LVTProcessResponse>  lvtResponseLst = LVTProcessRest.upsertOpportunity(lvtRequestLst);
        Test.StartTest();
		Opportunity oppor = [Select id, name, buy_type__c from opportunity limit 1];
		oppor.buy_type__c = 'Auction';
		update oppor;
        Test.StopTest();
    }

	static testMethod void postB2BLVTIntegrationHelper1() {
        
        String JSONMsg              = [Select Body From StaticResource Where Name = 'LVTB2BProcessRequestData' LIMIT 1].body.toString();
        list<LVTProcessWrapper.LVTProcessRequest>  lvtRequestLst = (list<LVTProcessWrapper.LVTProcessRequest>) JSON.deSerialize(JSONMsg, list<LVTProcessWrapper.LVTProcessRequest>.class);
        list<LVTProcessWrapper.LVTProcessResponse>  lvtResponseLst = LVTProcessRest.upsertOpportunity(lvtRequestLst);
        Test.StartTest();
		Opportunity oppor = [Select id, name, buy_type__c from opportunity limit 1];
		oppor.buy_type__c = 'Auction';
		update oppor;
        Test.StopTest();
    }    
}