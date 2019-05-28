/**
* @author Ramesh Chennupati
* @date 09/09/2011
* @description This Class receives Assignment updates from Java client.
*/
@RestResource(urlMapping='/APSService/*')
global class clsAPSService{
	
	/**
	* @author Ramesh Chennupati
	* @date 09/09/2011
	* @description It accepts RestRequest from clients and process the Requestbody xml 
	   and send back the RestResponse back to client. The Requstbody xml is the Assignment
	   Update message. The values of this update xml replaces the Opportunity record values.
	* @param Restreq Apex Rest Request 
	* @param Restres Apex Rest Response
	* @return string returned after parsing the request xml.
	*/
	@HttpPost
    global static String changeAssignment(RestRequest Restreq, RestResponse Restres) 
    {
    	string RqUID='';
    	try
    	{
	    	string strRequest=Restreq.requestBody.tostring();
	    	//copartmailservice.sendemail('APS Request Message',''+strRequest, globalconstants.APSUpdates_toAddress,null,null,null);
	    	Dom.Document doc=new Dom.Document();
	    	doc.load(strRequest);
	    	 
	    	RqUID=XmlDoc.getElementText(xpathconstants.RqUID,doc,xpathconstants.APSUpdatesNS);
	    	String ACV=XmlDoc.getElementText(xpathconstants.ValuationAmt,doc,xpathconstants.APSUpdatesNS);
	    	String HasKeys=XmlDoc.getElementText(xpathconstants.KeysAvailableInd,doc,xpathconstants.APSUpdatesNS);
	    	String LotNumber=XmlDoc.getElementText(xpathconstants.StockNum,doc,xpathconstants.APSUpdatesNS);
	    	String MinimumBidPrice=XmlDoc.getElementText(xpathconstants.MinimumBidAmt,doc,xpathconstants.APSUpdatesNS);
	    	String SellingPriceHighBid=XmlDoc.getElementText(xpathconstants.ActualSoldAmt,doc,xpathconstants.APSUpdatesNS);
	    	String saleDate=XmlDoc.getElementText(xpathconstants.SaleDate,doc,xpathconstants.APSUpdatesNS);
	    	String CASModel=XmlDoc.getElementText(xpathconstants.ModelName,doc,xpathconstants.APSUpdatesNS);
	    	String IsCarDrivable=XmlDoc.getElementText(xpathconstants.DrivableInd,doc,xpathconstants.APSUpdatesNS);
	    	String Make=XmlDoc.getElementText(xpathconstants.MakeDesc,doc,xpathconstants.APSUpdatesNS);
	    	String TypeOfVehicle=XmlDoc.getElementText(xpathconstants.VehicleType,doc,xpathconstants.APSUpdatesNS);
	    	String VehMiles=XmlDoc.getElementText(xpathconstants.OdometerReading,doc,xpathconstants.APSUpdatesNS);
	    	String VIN=XmlDoc.getElementText(xpathconstants.VINNum,doc,xpathconstants.APSUpdatesNS);
	    	String Year=XmlDoc.getElementText(xpathconstants.ModelYear,doc,xpathconstants.APSUpdatesNS);
	    	String MakeCode=XmlDoc.getElementText(xpathconstants.MakeCode,doc,xpathconstants.APSUpdatesNS);
	    	String AdvanceMiscellaneousCharges=null;
	    	String AdvanceMiscellaneousChargeDesciption=null;
	    	String TotalAdvanceCharges=null;
	    	string CopartTowingCharge=null;
	    	String OppStage=null;
	    	String MemberPaidDate=XmlDoc.getElementText(xpathconstants.SellerPaidDate,doc,xpathconstants.APSUpdatesNS);
	    	String OpportunityNum='';
	    	try
	    	{
	    		dom.xmlnode VehicleServices=XmlDoc.getElement(xpathconstants.VehicleServices,Doc ,xpathconstants.APSUpdatesNS);
		    	Dom.Xmlnode[] VehicleServiceList=VehicleServices.getChildren();
		    	Dom.Xmlnode OrgInfo=XmlDoc.getElement(xpathconstants.InsOrgInfo,Doc ,xpathconstants.APSUpdatesNS);
		        Dom.Xmlnode[] IDInfo=OrgInfo.getChildren();
		        
		        for(Dom.XmlNode cnode:IDInfo)
		        {
		        	if(cnode.getName()=='IDInfo')
		        	{
		        		Dom.Xmlnode IDQualifierCode=cnode.getChildElement('IDQualifierCode', xpathconstants.APSUpdatesNS);
		        		if(IDQualifierCode.getText()==xpathconstants.InsIDQualifierCode)
		        		{
		        			Dom.Xmlnode IDNum=cnode.getChildElement('IDNum', xpathconstants.APSUpdatesNS);
		        			OpportunityNum=IDNum.getText();
		        		}
		        	}
		        }
		        
		        for(Dom.XmlNode VSNode:VehicleServiceList)
		        {
		        	string  ServiceRequestCode=XmlDoc.getChildElementText(xpathconstants.ServiceRequestCode,VSNode,xpathconstants.APSUpdatesNS);
		        	string  ServiceDesc=XmlDoc.getChildElementText(xpathconstants.ServiceDesc,VSNode,xpathconstants.APSUpdatesNS);
		        	if(ServiceRequestCode=='ADV')
		        	{
		        		TotalAdvanceCharges=XmlDoc.getChildElementText(xpathconstants.VSChargeAmt,VSNode,xpathconstants.APSUpdatesNS);
		        	}
		        	if(ServiceRequestCode=='SPT')
		        	{
		        		CopartTowingCharge=XmlDoc.getChildElementText(xpathconstants.VSChargeAmt,VSNode,xpathconstants.APSUpdatesNS);
		        	}
		        	if(ServiceRequestCode=='MSC' && (! globalconstants.NonMiscSrvDescSet.contains(ServiceDesc.tolowercase())))
		        	{
		        		string ChargeAmt=XmlDoc.getChildElementText(xpathconstants.VSChargeAmt,VSNode,xpathconstants.APSUpdatesNS);
		        		if(ChargeAmt!=null && ChargeAmt.trim()!='')
		        		{
		        			AdvanceMiscellaneousCharges=ChargeAmt;
		        			AdvanceMiscellaneousChargeDesciption=ServiceDesc;
		        		} 
		        	}
		        }
		        Dom.xmlnode EventInfo = XmlDoc.getElement(xpathconstants.EventInfo,doc,xpathconstants.APSUpdatesNS);
		        Dom.xmlnode[] EventList=EventInfo.getchildren();
		        for(Dom.xmlnode eventNode:EventList)
		        {
		        	if(eventNode.getName()=='OtherEvent')
		        	{
		        		string OtherEventTypeText=eventNode.getChildElement('OtherEventType', xpathconstants.APSUpdatesNS).getText();
		        		if(OtherEventTypeText.startswith('Status-'))
		        		{
		        			OppStage=OtherEventTypeText.substring(OtherEventTypeText.indexof('-')+1);
		        		}
		        		//if(OtherEventTypeText=='Event-BUYERP')
		        		//{
		        		//	MemberPaidDate=eventNode.getChildElement('OtherEventDateTime', xpathconstants.APSUpdatesNS).getText();	
		        		//}
		        	}
		        }
	    	}
	    	catch(Exception exp)
	    	{
	    		//copartmailservice.sendemail('Error in APS Update',''+exp, globalconstants.APSUpdates_toAddress,null,null,null);
	    		//Ignore parse exception.
	    	}
	        list<Opportunity> oplist=[select id,model__c,Copart_Towing_Charge__c,Advance_Miscellaneous_Charge_Description__c,Advance_Miscellaneous_Charges__c,Total_Advance_Charges__c,Accountid,seller_code__c,OwnerId,ACV__c,Has_Keys__c,VIN__c,Veh_Miles__c,Actual_Vehicle_Miles__c,StageName,Lot_Number__c,Min_Bid_Price__c,Selling_Price_High_Bid__c,Vehicle_Sale_Date__c,CAS_Model__c,Is_Car_Drivable__c,Make__c,Type_of_Vehicle__c,Year__c from Opportunity where Opportunity_Number__c=:OpportunityNum and Lot_Number__c=:LotNumber limit 1];
	        if(oplist!=null && oplist.size()>0)
	        {
	        	try
	        	{
		        	Opportunity op=oplist[0];
		        	decimal OldMinBidPrice=op.Min_Bid_Price__c;
		        	string oldStage=op.StageName;
		        	decimal oldSellingPrHighBid=(op.Selling_Price_High_Bid__c==null)?0:op.Selling_Price_High_Bid__c;
		        	op.ACV__c=(ACV!=null)?decimal.valueof(ACV):op.ACV__c;
			        op.Has_Keys__c=HasKeys!=null?(HasKeys.touppercase()=='Y'?true:false):op.Has_Keys__c;
			        op.VIN__c=VIN!=null?VIN:op.VIN__c;
			        //op.Veh_Miles__c=VehMiles!=null?Integer.valueof(VehMiles):op.Veh_Miles__c;
			        try{
			        	op.Actual_Vehicle_Miles__c = (VehMiles<>null && Integer.valueOf(vehMiles)>0)?Integer.valueOf(vehMiles):op.Actual_Vehicle_Miles__c;
			        }
			        catch(Exception e){}
			        op.StageName=OppStage!=null?(globalconstants.SFStageMap().get(OppStage)==null?op.StageName:globalconstants.SFStageMap().get(OppStage)):op.StageName;
			        op.Lot_Number__c=LotNumber!=null?LotNumber:op.Lot_Number__c;
			        op.Min_Bid_Price__c=MinimumBidPrice!=null?decimal.valueof(MinimumBidPrice):op.Min_Bid_Price__c;
			        op.Selling_Price_High_Bid__c=SellingPriceHighBid!=null?decimal.valueof(SellingPriceHighBid):op.Selling_Price_High_Bid__c;
			        op.Total_Advance_Charges__c=TotalAdvanceCharges!=null?decimal.valueof(TotalAdvanceCharges):op.Total_Advance_Charges__c;
			        op.Copart_Towing_Charge__c=CopartTowingCharge!=null?decimal.valueof(CopartTowingCharge):op.Copart_Towing_Charge__c;
			        op.Advance_Miscellaneous_Charges__c=(AdvanceMiscellaneousCharges!=null && AdvanceMiscellaneousCharges.trim()!='')?decimal.valueof(AdvanceMiscellaneousCharges):op.Advance_Miscellaneous_Charges__c;
			        op.Advance_Miscellaneous_Charge_Description__c=AdvanceMiscellaneousChargeDesciption!=null?AdvanceMiscellaneousChargeDesciption:op.Advance_Miscellaneous_Charge_Description__c;
			        op.Vehicle_Sale_Date__c=saleDate!=null?Date.valueof(saleDate):op.Vehicle_Sale_Date__c;
			        op.model__c=CASModel!=null?CASModel:op.model__c;
			        if(MemberPaidDate!=null && MemberPaidDate.trim()!='')
			        {
			        	if(op.Member_Paid_Date__c==null)
			        	{
			        		op.Member_Paid_Date__c=date.valueof(MemberPaidDate);
			        	}
			        }
			        list<Vehicle_Model__c> cmlist=[select id from Vehicle_Model__c where make_code__c=:MakeCode and name=:CASModel limit 1];
			        if(cmlist!=null && cmlist.size()>0)
			        {
			        	op.CAS_Model__c=cmlist[0].id;
			        }
			        else
			        {
			        	op.CAS_Model__c=null;
			        	op.model__c=null;
			        }
			        op.Is_Car_Drivable__c=IsCarDrivable!=null?(IsCarDrivable.touppercase()=='Y'?'Yes':IsCarDrivable.touppercase()=='N'?'No':''):op.Is_Car_Drivable__c;
			        op.Make__c=Make!=null?Make:op.Make__c;
			        string CpTypeOfVehicle=globalconstants.CopartVehTypeMap().get(TypeOfVehicle);
			        list<Vehicle_Make__c> vmlist=[select vehicle_Type__c from Vehicle_Make__c where make_code__c=:MakeCode and vehicle_type_code__c=:CpTypeOfVehicle limit 1];
			        if(vmlist!=null && vmlist.size()>0)
			        {
			        	op.Type_of_Vehicle__c=vmlist[0].vehicle_Type__c;
			        }
			        op.Year__c=Year!=null?Year.substring(0,4):op.Year__c;
			        update op;
			        
			        if(op.StageName==globalconstants.CancelStageDesc && oldStage!=op.StageName)
			        {
			        	createTask('Lot Number:' + op.Lot_Number__c + ' - Stage has changed to CANCELLED LOST.',op);
			        }
			        if(op.StageName==globalconstants.SoldStage && oldStage!=op.StageName)
			        {
			        	createTask('Lot Number:' + op.Lot_Number__c + ' - Vehicle sold.',op);
			        }
			        if(OldMinBidPrice!=op.Min_Bid_Price__c)
			        {
			        	if(!globalconstants.IgnoreMinBidChangeStages.contains(op.StageName))
			        	{
			        		createTask('Lot Number:' + op.Lot_Number__c + ' - Minimum Bid Price has changed',op);
			        	}
			        }
			        
			       			        
	        	}
	        	catch(Exception Excep)
	        	{
	        		copartmailservice.sendemail('Error in APS Update',''+Excep, globalconstants.APSUpdates_toAddress,null,null,null);
	        	}
	        }
	        return '<bms:DispositionChgRs xmlns:bms="http://www.cieca.com/BMS"><bms:RqUID>' + RqUID +'</bms:RqUID><bms:ApplicationStatus><bms:ApplicationStatusCode>Accept</bms:ApplicationStatusCode><bms:ApplicationError><bms:ErrorCode>00</bms:ErrorCode><bms:Severity>Info</bms:Severity><bms:ErrorDesc>Update Accepted. Lot - ' + LotNumber +' </bms:ErrorDesc></bms:ApplicationError></bms:ApplicationStatus></bms:DispositionChgRs>';
    	}
        catch(Exception ex)
        {
        	return '<bms:DispositionChgRs xmlns:bms="http://www.cieca.com/BMS"><bms:RqUID>' + RqUID +'</bms:RqUID><bms:ApplicationStatus><bms:ApplicationStatusCode>Reject</bms:ApplicationStatusCode><bms:ApplicationError><bms:ErrorCode>SF000</bms:ErrorCode><bms:Severity>Error</bms:Severity><bms:ErrorDesc>' + ex + '</bms:ErrorDesc></bms:ApplicationError></bms:ApplicationStatus></bms:DispositionChgRs>';
        }
    }
    /**
	* @author Ramesh Chennupati
	* @date 09/09/2011
	* @description It accepts Subject string and Opportunity Object to create a Task 
	   and force to send a email to owner along with remainder.
	* @param Subject Task Subject 
	* @param op Opportunity Object
	* @return None
	*/
    private static void createTask(string Subject,Opportunity op)
    {
    	list<contact> c=[select id from contact where accountid=:op.Accountid limit 1];
        Task t = new Task();
        Database.DMLOptions dmlo = new Database.DMLOptions();
        t.ownerid=op.OwnerId;
        t.subject=Subject;
        t.whoid=c.size()>0?c[0].id:null;
        t.whatid=op.id;
        t.isreminderset=true;
        t.reminderdatetime=datetime.now();
        dmlo.EmailHeader.triggerUserEmail = true;//This line sets Send Notification email option to true. 
        database.insert(t, dmlo);
    }
    
}