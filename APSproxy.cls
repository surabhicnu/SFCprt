public class APSproxy{
    
    Public static AuditLog audtLog = new AuditLog('APSproxy','addAssignment');
    public static String addAssignment(Opportunity oppcurrent){
      
        audtLog    = new AuditLog('APSproxy','addAssignment');
        audtLog.logSourceSystem('APSproxy');
        audtLog.logRecordId(oppcurrent.Id);
        audtLog.logOpportunity(oppcurrent.Id);
        Dom.Document xmlDoc=new Dom.Document();
        string accountName = '';
        //next line added to fix Apexpages.message issue on 02-08-2018
        List<String> lstError = new List<String>();
                
        try{
            list<Account> VehOwner = [Select Type, Name, PersonMobilePhone,Phone, LastName,recordtypeid, FirstName, Company_Code__c, BillingStreet, BillingState, BillingPostalCode, BillingCountry, BillingCity From Account where id=:oppcurrent.AccountId limit 1];
            //This code is added to fetch the name of Non Profit Organizations for CWH ----Vidhi
             set<String> NPOSet = new set<String>();
             NPOSet.addall(Label.Non_Profit_Organization.split(';'));
            // we had put this condition as there is a validation on name(length = 50 and length =60) in CAS
            if(VehOwner[0].name.length() > 50){
                accountName = VehOwner[0].name.substring(0,49);
            }else{
                accountName = VehOwner[0].name;
            }
            boolean AltPayeeErr=false;
            if(VehOwner[0].BillingStreet==null || VehOwner[0].BillingStreet.trim()==''){
                        //line 29,31 added to fix Apexpages.message issue on 02-08-2018
                        if(ApexPages.currentPage() != null)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Billing Street required.'));
                        lstError.add('Vehicle Owner Billing Street required.');
                        AltPayeeErr=true;
            }else if(VehOwner[0].BillingStreet.length()>30){
                        //line 35,37 added to fix Apexpages.message issue on 02-08-2018
                        if(ApexPages.currentPage() != null)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Billing Street cannot exceed 30 characters, including spaces.'));
                        lstError.add('Vehicle Owner Billing Street cannot exceed 30 characters, including spaces.');
                        AltPayeeErr=true;
            }
            if(VehOwner[0].BillingCity==null || VehOwner[0].BillingCity.trim()=='' || VehOwner[0].BillingState==null || VehOwner[0].BillingState.trim()==''){
                if(VehOwner[0].BillingPostalCode==null || VehOwner[0].BillingPostalCode.trim()==''){
                    //line 43,45 added to fix Apexpages.message issue on 02-08-2018
                    if(ApexPages.currentPage() != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Billing Postal Code or City and State required.'));
                    lstError.add('Vehicle Owner Billing Postal Code or City and State required.');
                    AltPayeeErr=true;
                }
                        
            }
            if(VehOwner[0].BillingState!=null && VehOwner[0].BillingState.length()>2){
                //line 52,54 added to fix Apexpages.message issue on 02-08-2018
                if(ApexPages.currentPage() != null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Billing State/Province abbreviation must be (two) 2 characters.'));
                lstError.add('Vehicle Owner Billing State/Province abbreviation must be (two) 2 characters.');
                AltPayeeErr=true;
            }
            if(VehOwner[0].BillingCountry!=null && VehOwner[0].BillingCountry.length()>2){
                //line 59,61 added to fix Apexpages.message issue on 02-08-2018
                if(ApexPages.currentPage() != null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Billing Country abbreviation must be (two) 2 characters.'));
                lstError.add('Vehicle Owner Billing Country abbreviation must be (two) 2 characters.');
                AltPayeeErr=true;
            } 
            if(AltPayeeErr){
            //line 66, method param changed from ApexPages.getMessages() to lstError added to fix Apexpages.message issue on 02-08-2018
                saveLog(lstError);
                return null;
            }               
            string OwnPhone='';
            if(VehOwner[0].Phone==null || VehOwner[0].Phone.trim()==''){
                if(VehOwner[0].PersonMobilePhone==null || VehOwner[0].PersonMobilePhone.trim()==''){
                    //line 73,75 added and 76 updated param to fix Apexpages.message issue on 02-08-2018
                    if(ApexPages.currentPage() != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Vehicle Owner Phone or Mobile Number required.'));
                    lstError.add('Vehicle Owner Phone or Mobile Number required.');
                    saveLog(lstError);
                    return null;
                }
                else{
                    OwnPhone=VehOwner[0].PersonMobilePhone;
                }
            }
            else{
                OwnPhone=VehOwner[0].Phone;
            }
            OwnPhone=OwnPhone.replace('-','').replace('(','').replace(') ','-');
            if(!OwnPhone.contains('-')){
                if(OwnPhone.length()>3){
                    OwnPhone = OwnPhone.substring(0,3)+'-'+OwnPhone.substring(3);
                }
            }
           //OwnPhone=(OwnPhone.length()>10)?OwnPhone.replace('-','').replace('(', '').replace(') ','-'):OwnPhone;
            String soap = 'http://schemas.xmlsoap.org/soap/envelope/';
            Dom.Xmlnode envelope = xmlDoc.createRootElement('Envelope', soap, 'soap');
            envelope.setNamespace('soap', soap);
            Dom.Xmlnode Header=envelope.addChildElement('Header', soap, 'soap');
            Dom.Xmlnode Body=envelope.addChildElement('Body', soap, 'soap');
            string bmsNS='http://www.cieca.com/BMS';
            Dom.Xmlnode bmsAdd=Body.addChildElement('DispositionAddRq', bmsNS, 'bms');
            bmsAdd.setNamespace('bms', bmsNS);
            (bmsAdd.addChildElement('RqUID', bmsNS, 'bms')).addTextNode(RandomStringUtils.randomUUID());
            Dom.Xmlnode DocumentInfo=bmsAdd.addChildElement('DocumentInfo', bmsNS, 'bms');
            (DocumentInfo.addChildElement('BMSVer', bmsNS, 'bms')).addTextNode('2.5.0');
            (DocumentInfo.addChildElement('DocumentType', bmsNS, 'bms')).addTextNode('S');
            (DocumentInfo.addChildElement('DocumentVerCode', bmsNS, 'bms')).addTextNode('EM');
            (DocumentInfo.addChildElement('DocumentVerNum', bmsNS, 'bms')).addTextNode('1');
            (DocumentInfo.addChildElement('CreateDateTime', bmsNS, 'bms')).addTextNode(DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''));//'2007-03-14T11:04:05.913-07:00');
            //(DocumentInfo.addChildElement('TransmitDateTime', bmsNS, 'bms')).addTextNode(DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''));//'2007-03-14T11:04:05.913-07:00');
            
            Dom.Xmlnode ReferenceInfo=DocumentInfo.addChildElement('ReferenceInfo', bmsNS, 'bms');
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId() && oppcurrent.Assignment_Notes__c!=null && oppcurrent.Assignment_Notes__c.trim()!=''){
                (ReferenceInfo.addChildElement('PassThroughInfo', bmsNS, 'bms')).addTextNode(oppcurrent.Assignment_Notes__c);
            }else if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
               //We are sending schedule pickup date in assignment node, added extra conditions as it was appending schecdule pickup date multiple times when assignment request throws any validation error
                //Used date.format() method as using format('MM/dd/yyyy') was showing one day less at CAS
                if(oppcurrent.Assignment_Notes__c != null && oppcurrent.SchedulePickupDate__c != null){              
                    string pickupDate = '-Scheduled Pickup Date :'+ oppcurrent.SchedulePickupDate__c.format() + ((oppcurrent.PickUp_Time__c == null) ? '' : ','+oppcurrent.PickUp_Time__c);
                    if(!oppcurrent.Assignment_Notes__c.contains('Scheduled Pickup Date')){ 
                        oppcurrent.Assignment_Notes__c = oppcurrent.Assignment_Notes__c + pickupDate;
                    }
                }else if(oppcurrent.Assignment_Notes__c == null && oppcurrent.SchedulePickupDate__c != null){
                    string pickupDate = oppcurrent.SchedulePickupDate__c.format() + ((oppcurrent.PickUp_Time__c == null) ? '' : ','+oppcurrent.PickUp_Time__c);
                    if(oppcurrent.Assignment_Notes__c == null || !oppcurrent.Assignment_Notes__c.contains('Scheduled Pickup Date')){
                        oppcurrent.Assignment_Notes__c = 'Scheduled Pickup Date -'+ pickupDate;
                    }     
                }
                if(oppcurrent.Assignment_Notes__c != null){
                    (ReferenceInfo.addChildElement('PassThroughInfo', bmsNS, 'bms')).addTextNode(oppcurrent.Assignment_Notes__c);
                } 
            }
            Dom.Xmlnode OtherReferenceInfo = ReferenceInfo.addChildElement('OtherReferenceInfo', bmsNS, 'bms');
            (OtherReferenceInfo.addChildElement('OtherReferenceName', bmsNS, 'bms')).addTextNode('Pickup');
            (OtherReferenceInfo.addChildElement('OtherRefNum', bmsNS, 'bms')).addTextNode((oppcurrent.Offer_Includes_Tow__c==true)?'Y':'N');
            
            Dom.Xmlnode EventInfo=bmsAdd.addChildElement('EventInfo',bmsNS, 'bms');
            Dom.Xmlnode AssignmentEvent=EventInfo.addChildElement('AssignmentEvent',bmsNS, 'bms');
            (AssignmentEvent.addChildElement('CreateDateTime', bmsNS, 'bms')).addTextNode(DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''));
            
            Dom.Xmlnode AdminInfo = bmsAdd.addChildElement('AdminInfo',bmsNS, 'bms');
            Dom.Xmlnode InsuranceCompany=AdminInfo.addChildElement('InsuranceCompany',bmsNS, 'bms');
            Dom.Xmlnode InsParty=InsuranceCompany.addChildElement('Party',bmsNS, 'bms');
            Dom.Xmlnode InsOrgInfo=InsParty.addChildElement('OrgInfo',bmsNS, 'bms');
            Dom.Xmlnode InsIDInfoCompanyCode=InsOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
            (InsIDInfoCompanyCode.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('InsuranceCompanyCode');
            
            //Added if and else part for CWH @Abhinav 09/24/2015, we are passing 'CWH' for IDNum
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                (InsIDInfoCompanyCode.addChildElement('IDNum', bmsNS, 'bms')).addTextNode((globalConstants.VPPSellarCodes.contains(oppcurrent.Seller_Code__c))?'COP':'DIR');
            }else{
                (InsIDInfoCompanyCode.addChildElement('IDNum', bmsNS, 'bms')).addTextNode('CWH'); //CWH
            }  
            Dom.Xmlnode InsIDInfoCompanyAssID=InsOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
            (InsIDInfoCompanyAssID.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('InsuranceCompanyAssignmentID');
            (InsIDInfoCompanyAssID.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(oppcurrent.Opportunity_Number__c);  //D222229 
            
            Dom.Xmlnode ClaimOffice=AdminInfo.addChildElement('ClaimOffice',bmsNS, 'bms');
            Dom.Xmlnode ClaParty=ClaimOffice.addChildElement('Party',bmsNS, 'bms');
            Dom.Xmlnode ClaOrgInfo=ClaParty.addChildElement('OrgInfo',bmsNS, 'bms');
            Dom.Xmlnode ClaIDInfo=ClaOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
            (ClaIDInfo.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('ClaimOffice');
            
            // Added if & else logic for CWH @Abhinav 09/24/2015, we are passing seller code of NPO
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                (ClaIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(oppcurrent.Seller_Code__c);
            }else{
                //Added the logic to change the seller code if the Buy Type is Junk --- Vidhi
                if(NPOSet.contains(oppcurrent.NonProfitOrganization__r.name) && oppcurrent.Buy_Type__c=='Junk'){
                    system.debug('-------------------------'+oppcurrent.CWH_Junk_Seller_Code__c);
                      
                    (ClaIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(oppcurrent.CWH_Junk_Seller_Code__c);
                    Dom.Xmlnode ClaIDInfo1 = ClaOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
                    (ClaIDInfo1.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('SellerRef');
                    (ClaIDInfo1.addChildElement('IDNum', bmsNS, 'bms')).addTextNode('LVT-M'+oppcurrent.Junk_Vendor__r.LVT_Member_id__c+'-S'+oppcurrent.Junk_Vendor__r.LVT_Buyer_Id__c);
                }
                else{
                    (ClaIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(oppcurrent.CWHSellerCode__c);
                }   
            }        
            /*   
            if(oppcurrent.Buy_Type__c == 'Junk' && oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                Dom.Xmlnode ClaIDInfo1 = ClaOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
                (ClaIDInfo1.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('SellerRef');
                (ClaIDInfo1.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(oppcurrent.Junk_Vendor__r.LVT_Member_id__c+oppcurrent.Junk_Vendor__r.LVT_Buyer_Id__c);
            
            } 
            */
            
            // Added else part for CWH @Abhinav 09/23/2015, we are not passing VPP offer amount for CWH         
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId() && oppcurrent.VPP_Offer_Amount__c!=null && String.valueOf(oppcurrent.VPP_Offer_Amount__c).trim()!=''){
                Dom.Xmlnode PolicyHolder=AdminInfo.addChildElement('PolicyHolder',bmsNS, 'bms');
                Dom.Xmlnode PHParty=PolicyHolder.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode PHPersonInfo=PHParty.addChildElement('PersonInfo',bmsNS, 'bms');
                Dom.Xmlnode PHPersonName=PHPersonInfo.addChildElement('PersonName',bmsNS, 'bms');
                if(oppcurrent.Assignment_Type__c=='Purchase'){
                    (PHPersonName.addChildElement('LastName', bmsNS, 'bms')).addTextNode((accountName.length() > 50) ? accountName.substring(0,49) : accountName);
                }
                else{
                    (PHPersonName.addChildElement('LastName', bmsNS, 'bms')).addTextNode(String.valueOf(oppcurrent.VPP_Offer_Amount__c));
                }
            }else if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                Dom.Xmlnode PolicyHolder=AdminInfo.addChildElement('PolicyHolder',bmsNS, 'bms');
                Dom.Xmlnode PHParty=PolicyHolder.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode PHPersonInfo=PHParty.addChildElement('PersonInfo',bmsNS, 'bms');
                Dom.Xmlnode PHPersonName=PHPersonInfo.addChildElement('PersonName',bmsNS, 'bms');
                (PHPersonName.addChildElement('LastName', bmsNS, 'bms')).addTextNode((accountName.length() > 50) ? accountName.substring(0,49) : accountName);
            }
            
            Dom.Xmlnode Owner=AdminInfo.addChildElement('Owner',bmsNS, 'bms');
            Dom.Xmlnode OwnerParty=Owner.addChildElement('Party',bmsNS, 'bms');
            Dom.Xmlnode OwnerPersonInfo=OwnerParty.addChildElement('PersonInfo',bmsNS, 'bms');
            Dom.Xmlnode OwnerPersonName=OwnerPersonInfo.addChildElement('PersonName',bmsNS, 'bms');
            if(VehOwner[0].FirstName!=null && VehOwner[0].FirstName.trim()!=''){
                (OwnerPersonName.addChildElement('FirstName', bmsNS, 'bms')).addTextNode((VehOwner[0].FirstName.length() > 24) ? VehOwner[0].FirstName.substring(0,23) : VehOwner[0].FirstName);
            }
            if(VehOwner[0].LastName!=null && VehOwner[0].LastName.trim()!=''){
                (OwnerPersonName.addChildElement('LastName', bmsNS, 'bms')).addTextNode((VehOwner[0].LastName.length() > 25) ? VehOwner[0].LastName.substring(0,24) : VehOwner[0].LastName);
            }
            if(oppcurrent.Offer_Includes_Tow__c){
                string companyName='';
                string VehLocationType='';
                string LocAddress1='',LocAddress2='',LocCity='',LocState='',LocPostalCode='',LocCountry='';
                string PickupContactPhone='',PickupContactFirstName='',PickupContactLastName='';
                if(oppcurrent.Pickup_Location_same_as_Owner_Address__c){
                    companyName=accountName;
                    LocAddress1=VehOwner[0].BillingStreet;
                    LocAddress2='';
                    LocCity=VehOwner[0].BillingCity;
                    LocState=VehOwner[0].BillingState;
                    
                    if((VehOwner[0].BillingPostalCode).containsWhitespace())
                    {
                        List<String> zipSp = (VehOwner[0].BillingPostalCode).split(' ');
                        LocPostalCode = zipSp[0];
                        
                    }
                    else
                        LocPostalCode=VehOwner[0].BillingPostalCode;
                    system.debug('*****PostalCode: '+LocPostalCode);
                    
                    LocCountry=VehOwner[0].BillingCountry;
                    
                    if(VehOwner[0].FirstName!=null && VehOwner[0].FirstName.trim()!=''){
                     PickupContactFirstName=(VehOwner[0].FirstName <> null && VehOwner[0].FirstName.length() > 28) ? VehOwner[0].FirstName.substring(0,27) : VehOwner[0].FirstName;
                    }
                   
                    PickupContactLastName=(VehOwner[0].LastName <> null && VehOwner[0].LastName.length() > 28) ? VehOwner[0].LastName.substring(0,27) : VehOwner[0].LastName;
                    PickupContactPhone=OwnPhone;
                   
                }
                else{
                    /*if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CopartDirect').getRecordTypeId())
                    {
                    companyName=accountName;
                    if(VehOwner[0].BillingStreet != null)
                            LocAddress1=VehOwner[0].BillingStreet;
                        LocAddress2='';
                        if(VehOwner[0].BillingCity != null)
                            LocCity=VehOwner[0].BillingCity;
                        if(VehOwner[0].BillingState != null)
                            LocState=VehOwner[0].BillingState;
                        if(VehOwner[0].BillingPostalCode != null)
                            LocPostalCode=VehOwner[0].BillingPostalCode;
                        if(VehOwner[0].BillingCountry != null)
                            LocCountry=VehOwner[0].BillingCountry;
                    PickupContactFirstName=oppcurrent.PUL_First_Name__c;
                        PickupContactLastName=oppcurrent.PUL_Last_Name__c;
                        PickupContactPhone=(oppcurrent.PUL_Phone_Number__c==null)?'':oppcurrent.PUL_Phone_Number__c;
                        PickupContactPhone=PickupContactPhone.replace('-','').replace('(', '').replace(') ','-');
                        if(!PickupContactPhone.contains('-')){
                            if(PickupContactPhone.length()>3)
                                PickupContactPhone = PickupContactPhone.substring(0,3)+'-'+PickupContactPhone.substring(3);
                        }
                    }
                    else
                    {*/
                        companyName=oppcurrent.Pickup_Location_Company_Name__c;
                    LocAddress1=oppcurrent.Pickup_Address1__c;
                    LocAddress2=(oppcurrent.Pickup_Address2__c==null)?'':oppcurrent.Pickup_Address2__c;
                    LocCity=oppcurrent.Pickup_Location_City__c;
                    LocState=oppcurrent.Pickup_Location_State__c;
                    
                    if((oppcurrent.Pickup_Location_Postal_Code__c).containsWhitespace())
                    {
                        List<String> zipSp = (oppcurrent.Pickup_Location_Postal_Code__c).split(' ');
                        LocPostalCode = zipSp[0];
                        
                    }
                    else
                        LocPostalCode=oppcurrent.Pickup_Location_Postal_Code__c;
                    system.debug('*****PostalCode2: '+LocPostalCode);
                    
                    
                    
                    LocCountry=oppcurrent.Pickup_Location_Country__c;
                    PickupContactFirstName=oppcurrent.Pickup_Location_Contact_First_Name__c;
                    if(oppcurrent.Pickup_Location_Contact_Last_Name__c != null)
                    PickupContactLastName=oppcurrent.Pickup_Location_Contact_Last_Name__c;
                    PickupContactPhone=(oppcurrent.Pickup_Location_Phone__c==null)?'':oppcurrent.Pickup_Location_Phone__c;
                    PickupContactPhone=PickupContactPhone.replace('-','').replace('(', '').replace(') ','-');
                    if(!PickupContactPhone.contains('-')){
                        if(PickupContactPhone.length()>3)
                            PickupContactPhone = PickupContactPhone.substring(0,3)+'-'+PickupContactPhone.substring(3);
                    
                    }
                //}
                }
                Dom.Xmlnode InitialPickUpLocationSite=AdminInfo.addChildElement('InitialPickUpLocationSite',bmsNS, 'bms');
                Dom.Xmlnode IniPickParty=InitialPickUpLocationSite.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode IniPickOrgInfo=IniPickParty.addChildElement('OrgInfo',bmsNS, 'bms');
                (IniPickOrgInfo.addChildElement('CompanyName',bmsNS, 'bms')).addTextNode(companyName);
                Dom.Xmlnode IniPickIDInfo=IniPickOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
                (IniPickIDInfo.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('VehicleLocationType');
                if(globalConstants.VPPSellarCodes.contains(oppcurrent.Seller_code__c)){
                    (IniPickIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode('B');
                }
                else{
                    if(oppcurrent.Pickup_Location_same_as_Owner_Address__c){
                        (IniPickIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode('R');
                    }
                    else{
                        string locType='R';
                        if(oppcurrent.Pickup_Location_Type__c!=null){
                            locType=oppcurrent.Pickup_Location_Type__c.substring(0,1);
                        }
                        (IniPickIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(locType);
                    }
                }
                Dom.Xmlnode IniPickCommunications=IniPickOrgInfo.addChildElement('Communications',bmsNS, 'bms');
                (IniPickCommunications.addChildElement('CommQualifier', bmsNS, 'bms')).addTextNode('SA');
                Dom.Xmlnode IniPickAddress=IniPickCommunications.addChildElement('Address',bmsNS, 'bms');
                (IniPickAddress.addChildElement('Address1', bmsNS, 'bms')).addTextNode(LocAddress1);
                if(LocAddress2.trim()!=''){
                    (IniPickAddress.addChildElement('Address2', bmsNS, 'bms')).addTextNode(LocAddress2);
                }
                if(LocCity!=null && LocCity.trim()!=''){
                    (IniPickAddress.addChildElement('City', bmsNS, 'bms')).addTextNode(LocCity);
                }
                if(LocState!=null && LocState.trim()!=''){
                    (IniPickAddress.addChildElement('StateProvince', bmsNS, 'bms')).addTextNode(LocState);
                }
                if(LocPostalCode!=null && LocPostalCode.trim()!=''){
                
                    (IniPickAddress.addChildElement('PostalCode', bmsNS, 'bms')).addTextNode(LocPostalCode);
                }
                if(LocCountry!=null && LocCountry.trim()!=''){
                    (IniPickAddress.addChildElement('CountryCode', bmsNS, 'bms')).addTextNode(LocCountry);
                }
                if(PickupContactPhone.trim()!=''){
                    Dom.Xmlnode IniPickCommunicationsWP=IniPickOrgInfo.addChildElement('Communications',bmsNS, 'bms');
                    (IniPickCommunicationsWP.addChildElement('CommQualifier', bmsNS, 'bms')).addTextNode('WP');
                    /*PickupContactPhone=PickupContactPhone.replace('-','').replace('(', '').replace(') ','-');
                    if(!PickupContactPhone.contains('-')){
                        if(PickupContactPhone.length()>3)
                            PickupContactPhone = PickupContactPhone.substring(0,3)+'-'+PickupContactPhone.substring(3);
                    }*/
                    (IniPickCommunicationsWP.addChildElement('CommPhone', bmsNS, 'bms')).addTextNode(PickupContactPhone);
                }
                Dom.Xmlnode IniPickContactInfo=IniPickParty.addChildElement('ContactInfo',bmsNS, 'bms');
                Dom.Xmlnode IniPickContactName=IniPickContactInfo.addChildElement('ContactName',bmsNS, 'bms');
                if(PickupContactFirstName!=null && PickupContactFirstName.trim()!=''){
                    (IniPickContactName.addChildElement('FirstName',bmsNS, 'bms')).addTextNode(PickupContactFirstName);
                }
                if(PickupContactLastName!=null && PickupContactLastName.trim()!=''){
                    (IniPickContactName.addChildElement('LastName',bmsNS, 'bms')).addTextNode(PickupContactLastName);
                }
            }
            //else
            {
            if(oppcurrent.Yard__c!=null && oppcurrent.Yard__c>0){
                Dom.Xmlnode DestinationLocationSite=AdminInfo.addChildElement('DestinationLocationSite',bmsNS, 'bms');
                Dom.Xmlnode DesParty=DestinationLocationSite.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode DesOrgInfo=DesParty.addChildElement('OrgInfo',bmsNS, 'bms');
                (DesOrgInfo.addChildElement('CompanyName', bmsNS, 'bms')).addTextNode(String.valueof(oppcurrent.Yard__c));//Yard Number.
            }
            }
            if(oppcurrent.Pickup_Note__c!=null && oppcurrent.Pickup_Note__c.trim()!=''){
                Dom.Xmlnode Consolidator=AdminInfo.addChildElement('Consolidator',bmsNS, 'bms');
                Dom.Xmlnode ConsolidParty=Consolidator.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode CosolidOrgInfo=ConsolidParty.addChildElement('OrgInfo',bmsNS, 'bms');
                Dom.Xmlnode CosolidIDInfo=CosolidOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
                (CosolidIDInfo.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('QF');
                (CosolidIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode('qq');
                (ConsolidParty.addChildElement('Memo', bmsNS, 'bms')).addTextNode(oppcurrent.Pickup_Note__c);
            }
            String userName;
            
            //Added if else logic for CWH @Abhinav 09/24/2015, we only send support agent CAS ID for CWH and not Primary Remarketing Specialist
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                if(globalConstants.VPPSellarCodes.contains(oppcurrent.Seller_code__c)){
                    userName=oppcurrent.Support_Agent__c;
                }else{
                    userName=oppcurrent.Primary_Remarketing_Specialist__c;
                }
            }else if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                userName=oppcurrent.Support_Agent__c;
            } 
            list<User> Adjusters=[Select Street, State, PostalCode, LastName, FirstName, EmployeeNumber, Email, Country, City, CAS_ID__c From User where name=:userName ];
            if(Adjusters.size()>0){
                User AdjusterUser=Adjusters[0];
                boolean IsAdjDetailsEmpty=false;
                if(AdjusterUser.CAS_ID__c==null || AdjusterUser.CAS_ID__c.trim()==''){
                    //line 352,354 added to fix Apexpages.message issue on 02-08-2018
                    if(ApexPages.currentPage() != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Adjuster CAS ID required.'));
                    lstError.add('Adjuster CAS ID required.');
                    IsAdjDetailsEmpty=true;
                }
                if(IsAdjDetailsEmpty){
                //line 359 updated param to fix Apexpages.message issue on 02-08-2018
                    saveLog(lstError);
                    return null;
                }
                Dom.Xmlnode Adjuster=AdminInfo.addChildElement('Adjuster',bmsNS, 'bms');
                Dom.Xmlnode AdjParty=Adjuster.addChildElement('Party',bmsNS, 'bms');
                Dom.Xmlnode AdjPersonInfo=AdjParty.addChildElement('PersonInfo',bmsNS, 'bms');
                Dom.Xmlnode AdjPersonName=AdjPersonInfo.addChildElement('PersonName',bmsNS, 'bms');
                (AdjPersonName.addChildElement('FirstName',bmsNS, 'bms')).addTextNode(AdjusterUser.FirstName);
                (AdjPersonName.addChildElement('LastName',bmsNS, 'bms')).addTextNode(AdjusterUser.LastName);
                Dom.Xmlnode AdjIDInfo=AdjPersonInfo.addChildElement('IDInfo',bmsNS, 'bms');
                (AdjIDInfo.addChildElement('IDQualifierCode', bmsNS, 'bms')).addTextNode('EmployeeID');
                (AdjIDInfo.addChildElement('IDNum', bmsNS, 'bms')).addTextNode(AdjusterUser.CAS_ID__c);
                Dom.Xmlnode AdjContactInfo=AdjParty.addChildElement('ContactInfo',bmsNS, 'bms');
                //Dom.Xmlnode AdjCommunicationsPh=AdjContactInfo.addChildElement('Communications',bmsNS, 'bms');
                //(AdjCommunicationsPh.addChildElement('CommQualifier',bmsNS, 'bms')).addTextNode('AdjusterPhone');
                //(AdjCommunicationsPh.addChildElement('CommPhone',bmsNS, 'bms')).addTextNode('707-4567878');
                Dom.Xmlnode AdjCommunicationsEmail=AdjContactInfo.addChildElement('Communications',bmsNS, 'bms');
                (AdjCommunicationsEmail.addChildElement('CommQualifier',bmsNS, 'bms')).addTextNode('AdjusterEmail');
                (AdjCommunicationsEmail.addChildElement('CommEmail',bmsNS, 'bms')).addTextNode(AdjusterUser.Email);
            }
            else{
                //line 381,383 added and 384 updated param to fix Apexpages.message issue on 02-08-2018
                if(ApexPages.currentPage() != null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'User details not found for "' + userName + '"'));
                lstError.add('User details not found for "' + userName + '"');
                saveLog(lstError);
                return null;
            }
            Dom.Xmlnode AlternateInsurer=AdminInfo.addChildElement('AlternateInsurer',bmsNS, 'bms');
            Dom.Xmlnode AltParty=AlternateInsurer.addChildElement('Party',bmsNS, 'bms');
            Dom.Xmlnode AltOrgInfo=AltParty.addChildElement('OrgInfo',bmsNS, 'bms');
            if(accountName!=null && accountName.trim()!=''){
                (AltOrgInfo.addChildElement('CompanyName',bmsNS, 'bms')).addTextNode(accountName);
            }
            Dom.Xmlnode AltContactInfo=AltParty.addChildElement('ContactInfo',bmsNS, 'bms');
            Dom.Xmlnode AltContactName=AltContactInfo.addChildElement('ContactName',bmsNS, 'bms');
            if(VehOwner[0].FirstName!=null && VehOwner[0].FirstName.trim()!=''){
                (AltContactName.addChildElement('FirstName',bmsNS, 'bms')).addTextNode((VehOwner[0].FirstName.length() > 28) ? VehOwner[0].FirstName.substring(0,27) : VehOwner[0].FirstName);
            }
            if(VehOwner[0].LastName!=null && VehOwner[0].LastName.trim()!=''){
                (AltContactName.addChildElement('LastName',bmsNS, 'bms')).addTextNode((VehOwner[0].LastName.length() > 28) ? VehOwner[0].LastName.substring(0,27) : VehOwner[0].LastName);
            }
            Dom.Xmlnode AltContactInfocomm=AltParty.addChildElement('ContactInfo',bmsNS, 'bms');
            Dom.Xmlnode AltCommunicationsSA=AltContactInfocomm.addChildElement('Communications',bmsNS, 'bms');
            (AltCommunicationsSA.addChildElement('CommQualifier',bmsNS, 'bms')).addTextNode('SA');
            Dom.Xmlnode AltAddress=AltCommunicationsSA.addChildElement('Address',bmsNS, 'bms');
            if(VehOwner[0].BillingStreet!=null && VehOwner[0].BillingStreet.trim()!=''){
                (AltAddress.addChildElement('Address1',bmsNS, 'bms')).addTextNode(VehOwner[0].BillingStreet);
            }
            if(VehOwner[0].BillingCity!=null && VehOwner[0].BillingCity.trim()!=''){
                (AltAddress.addChildElement('City',bmsNS, 'bms')).addTextNode(VehOwner[0].BillingCity);
            }
            if(VehOwner[0].BillingState!=null && VehOwner[0].BillingState.trim()!=''){
                (AltAddress.addChildElement('StateProvince',bmsNS, 'bms')).addTextNode(VehOwner[0].BillingState);
            }
            
            if(VehOwner[0].BillingPostalCode!=null && VehOwner[0].BillingPostalCode.trim()!=''){
                String zip;
                if((VehOwner[0].BillingPostalCode).containsWhitespace())
                    {
                        List<String> zipSp = (VehOwner[0].BillingPostalCode).split(' ');
                        zip = zipSp[0];
                        
                    }
                    else
                        zip =VehOwner[0].BillingPostalCode;
                    system.debug('*****PostalCode3: '+zip);
                    
                (AltAddress.addChildElement('PostalCode',bmsNS, 'bms')).addTextNode(zip);
               // (AltAddress.addChildElement('PostalCode',bmsNS, 'bms')).addTextNode(VehOwner[0].BillingPostalCode);
            }
            if(VehOwner[0].BillingCountry!=null && VehOwner[0].BillingCountry.trim()!=''){
                (AltAddress.addChildElement('CountryCode',bmsNS, 'bms')).addTextNode(VehOwner[0].BillingCountry);
            }
            Dom.Xmlnode AltCommunicationsWP=AltContactInfocomm.addChildElement('Communications',bmsNS, 'bms');
            (AltCommunicationsWP.addChildElement('CommQualifier',bmsNS, 'bms')).addTextNode('WP');
            /*if(OwnPhone <> null){
                OwnPhone=OwnPhone.replace('-','').replace('(', '').replace(') ','-');
                if(!OwnPhone.contains('-')){
                    if(OwnPhone.length()>3){
                        OwnPhone = OwnPhone.substring(0,3)+'-'+OwnPhone.substring(3);
                    }
                }
            }*/
            (AltCommunicationsWP.addChildElement('CommPhone',bmsNS, 'bms')).addTextNode(OwnPhone);
            Dom.Xmlnode Forwarder=AdminInfo.addChildElement('Forwarder',bmsNS, 'bms');
            Dom.Xmlnode FowParty=Forwarder.addChildElement('Party',bmsNS, 'bms');
            Dom.Xmlnode FowOrgInfo=FowParty.addChildElement('OrgInfo',bmsNS, 'bms');
            (FowOrgInfo.addChildElement('CompanyName',bmsNS, 'bms')).addTextNode('Copart SalesForce');
            Dom.Xmlnode FowIDInfo=FowOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
            (FowIDInfo.addChildElement('IDQualifierCode',bmsNS, 'bms')).addTextNode('TransportCompanyCode');
            (FowIDInfo.addChildElement('IDNum',bmsNS, 'bms')).addTextNode('SAL');
            Dom.Xmlnode FowIDInfo1=FowOrgInfo.addChildElement('IDInfo',bmsNS, 'bms');
            (FowIDInfo1.addChildElement('IDQualifierCode',bmsNS, 'bms')).addTextNode('TransportCompanyAssignmentID');
            (FowIDInfo1.addChildElement('IDNum',bmsNS, 'bms')).addTextNode(oppcurrent.Opportunity_Number__c);  
            Dom.Xmlnode ClaimInfo=bmsAdd.addChildElement('ClaimInfo',bmsNS, 'bms');
            string LeadSrc='CopartDirect';
            if(oppcurrent.Assignment_Type__c=='Purchase'){
                LeadSrc=string.valueof(oppcurrent.VPP_Offer_Amount__c);
            }
            else{
                if(oppcurrent.LeadSource!=null && oppcurrent.LeadSource.trim()!=''){
                    LeadSrc=oppcurrent.LeadSource;
                }
            }
            
            //For CWH, we are passigng Lead Number in ClaimNum node
            if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()) {
                //Added by Abhinav on 12/15/2016, For CARS NPO we are sending the Claim Number on Opportunity    
                if(oppcurrent.NonProfitOrganization__r.Company_Code__c == 'CRS')
                    (ClaimInfo.addChildElement('ClaimNum',bmsNS, 'bms')).addTextNode(oppcurrent.Claim_Number__c);
                else
                    (ClaimInfo.addChildElement('ClaimNum',bmsNS, 'bms')).addTextNode(oppcurrent.Lead_Number__c);
                
            }else {
                (ClaimInfo.addChildElement('ClaimNum',bmsNS, 'bms')).addTextNode(LeadSrc);
            }
            
            Dom.Xmlnode PolicyInfo=ClaimInfo.addChildElement('PolicyInfo',bmsNS, 'bms');
            (PolicyInfo.addChildElement('PolicyNum',bmsNS, 'bms')).addTextNode(OwnPhone);
            Dom.Xmlnode LossInfo=ClaimInfo.addChildElement('LossInfo',bmsNS, 'bms');
            Dom.Xmlnode Facts=LossInfo.addChildElement('Facts',bmsNS, 'bms');
            (Facts.addChildElement('LossDateTime',bmsNS, 'bms')).addTextNode(DateTime.now().format('yyyy-MM-dd\'T\'hh:mm:ss.SSS\'Z\''));
            if(oppcurrent.Type_of_Loss__c!=null && oppcurrent.Type_of_Loss__c.trim()!=''){
                String LossType=oppcurrent.Type_of_Loss__c;
                LossType=LossType.substring(0,1);
                (Facts.addChildElement('LossDescCode',bmsNS, 'bms')).addTextNode(LossType);
            }
            Dom.Xmlnode PrimaryPOI=Facts.addChildElement('PrimaryPOI',bmsNS, 'bms');
            if(oppcurrent.Damage_Code__c!=null && oppcurrent.Damage_Code__c!=''){
                string DamageCode=oppcurrent.Damage_Code__c;
                DamageCode=DamageCode.substring(0, 2);
                (PrimaryPOI.addChildElement('POICode',bmsNS, 'bms')).addTextNode(DamageCode);
            }
            (LossInfo.addChildElement('TotalLossInd',bmsNS, 'bms')).addTextNode('N');
            Dom.Xmlnode VehicleInfo=bmsAdd.addChildElement('VehicleInfo',bmsNS, 'bms');
            if(oppcurrent.VIN__c!=null && oppcurrent.VIN__c.trim()!=''){
                if(!StringUtils.isAlphanumeric(oppcurrent.VIN__c.trim())){
                    //line 485,487 added and 488 updated param to fix Apexpages.message issue on 02-08-2018
                    if(ApexPages.currentPage() != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'VIN must be alphaNumeric.'));
                    lstError.add('VIN must be alphaNumeric.');
                    saveLog(lstError);
                    return null;
                }
                Dom.Xmlnode VINInfo=VehicleInfo.addChildElement('VINInfo',bmsNS, 'bms');
                Dom.Xmlnode VIN=VINInfo.addChildElement('VIN',bmsNS, 'bms');
                (VIN.addChildElement('VINNum',bmsNS, 'bms')).addTextNode(oppcurrent.VIN__c);
            }
            Dom.Xmlnode VehicleDesc = VehicleInfo.addChildElement('VehicleDesc',bmsNS, 'bms');
            if(oppcurrent.year__c!=null && oppcurrent.year__c.trim()!=''){
                (VehicleDesc.addChildElement('ModelYear',bmsNS, 'bms')).addTextNode(oppcurrent.year__c);
            }
            if(oppcurrent.Make__c!=null && oppcurrent.Make__c.trim()!=''){
                string vehicleType='Automobile';
                if(oppcurrent.Type_of_Vehicle__c!=null && oppcurrent.Type_of_Vehicle__c.trim()!=''){
                    vehicleType=oppcurrent.Type_of_Vehicle__c;
                }
                list<Vehicle_Make__c> vm=[select name,make_code__c,vehicle_type_code__c from Vehicle_Make__c where Name=:oppcurrent.Make__c and Vehicle_Type__c=:vehicleType];
                if(vm.size()>0){
                    (VehicleDesc.addChildElement('MakeCode',bmsNS, 'bms')).addTextNode(vm[0].make_code__c);
                    (VehicleDesc.addChildElement('MakeDesc',bmsNS, 'bms')).addTextNode(vm[0].name);
                    if(oppcurrent.CAS_Model__c!=null){
                        list<Vehicle_Model__c> vModel=[select name from Vehicle_model__c where id=:oppcurrent.CAS_Model__c];
                        if(vModel.size()>0){
                            (VehicleDesc.addChildElement('ModelName',bmsNS, 'bms')).addTextNode(vModel[0].name);
                        }
                    }
                    (VehicleDesc.addChildElement('VehicleType',bmsNS, 'bms')).addTextNode(vm[0].vehicle_type_code__c);  
                }
            }
            //Dom.Xmlnode VehicleOptions=VehicleDesc.addChildElement('VehicleOptions',bmsNS, 'bms');
            //Dom.Xmlnode Option=VehicleOptions.addChildElement('Option',bmsNS, 'bms');
            //(Option.addChildElement('OptionCode',bmsNS, 'bms')).addTextNode('UT');
            //(Option.addChildElement('OptionDesc',bmsNS, 'bms')).addTextNode('Trailer');
            (VehicleDesc.addChildElement('KeysAvailableInd',bmsNS, 'bms')).addTextNode((oppcurrent.Has_Keys__c==true)?'Y':'N');
            //Dom.Xmlnode Paint=VehicleInfo.addChildElement('Paint',bmsNS, 'bms');
            //Dom.Xmlnode Exterior=Paint.addChildElement('Exterior',bmsNS, 'bms');
            //Dom.Xmlnode Color=Exterior.addChildElement('Color',bmsNS, 'bms');
            //(Color.addChildElement('ColorName',bmsNS, 'bms')).addTextNode('CREAM');
            //Dom.Xmlnode vehBody=VehicleInfo.addChildElement('Body',bmsNS, 'bms');
            //(vehBody.addChildElement('BodyStyle',bmsNS, 'bms')).addTextNode('SEDAN 4D');
            Dom.Xmlnode Condition=VehicleInfo.addChildElement('Condition',bmsNS, 'bms');
            if(oppcurrent.Is_Car_Drivable__c!=null){
                (Condition.addChildElement('DrivableInd',bmsNS, 'bms')).addTextNode((oppcurrent.Is_Car_Drivable__c=='Yes')?'Y':'N');
            }
            (Condition.addChildElement('TowCondition',bmsNS, 'bms')).addTextNode('Y');
            Dom.Xmlnode Valuation=VehicleInfo.addChildElement('Valuation',bmsNS, 'bms');
            (Valuation.addChildElement('ValuationType',bmsNS, 'bms')).addTextNode('ACV');
            
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId() && oppcurrent.ACV__c!=null && string.valueof(oppcurrent.ACV__c).trim()!=''){
                (Valuation.addChildElement('ValuationAmt',bmsNS, 'bms')).addTextNode(string.valueof(oppcurrent.ACV__c));
            }else if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId()){
                (Valuation.addChildElement('ValuationAmt',bmsNS, 'bms')).addTextNode('1');
            }
            
            //This code is added to insert Junk Vendor name in the Vehicle Memo field if Buy Type is Junk ---- Vidhi
            String lot_note='';
            if(oppcurrent.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId() && NPOSet.contains(oppcurrent.NonProfitOrganization__r.name) && oppcurrent.Buy_Type__c=='Junk'){
                if(oppcurrent.Junk_Vendor__r.name != NULL && oppcurrent.Junk_Vendor__r.name.trim()!= '' && oppcurrent.Junk_Vendor__r.LVT_Buyer_Id__c != NULL && 
                 oppcurrent.Junk_Vendor__r.LVT_Member_Id__c != NULL && oppcurrent.Junk_Vendor__r.LVT_Price__c != NULL && oppcurrent.Junk_Vendor__r.LVT_Sale_Price__c <> NULL &&
                 oppcurrent.Junk_Vendor__r.LVT_Delivery_Fee__c != NULL
                ){
                 // Added on 06/16/2016 by abhinav for as part of LVT enhancements (sendong Junk Vendor details like Member Id,Buyer Id, Price details etc)
                 //Update by Srinivas on 10/11/2016 to fit to 180 character limit when sending lot note to CAS, Abbreviated LOW VALUE TRIAGE to LVT
                    lot_note = 'THIS IS A LVT ASSIGNMENT.**DO NOT ASSIGN TO A LIVE AUCTION** THIS LOT SHOULD BE DISPATCHED TO THE SUBLOT "'+oppcurrent.Junk_Vendor__r.LVT_Buyer_Id__c+
                              '", THEN AWARDED VIA SPECIAL SALE TO MEMBER NUMBER "'+oppcurrent.Junk_Vendor__r.LVT_Member_Id__c+'" FOR $'+oppcurrent.Junk_Vendor__r.LVT_Sale_Price__c+
                              '. A DELIVERY FEE OF $'+oppcurrent.Junk_Vendor__r.LVT_Delivery_Fee__c+' MUST BE ADDED TO THE LOT AFTER IT HAS BEEN AWARDED TO THE LVT VENDOR NUMBER ABOVE. ';
                    String additionalText = '';
                    if(oppcurrent.Junk_Vendor__r.email_2__c <> NULL)
                        additionalText = 'Email - '+ oppcurrent.Junk_Vendor__r.email_2__c;
                    if(oppcurrent.Junk_Vendor__r.Fax <> NULL)
                        additionalText += ' Fax - '+ oppcurrent.Junk_Vendor__r.Fax +' ';    
                        
                     if(additionalText != '')
                         lot_note += additionalText; 
                }
                //Added by Abhinav on 11/03/2016, we are sending LVT Junk Vendor Account's description as lot notes to CAS
                if(oppcurrent.Junk_Vendor__r.description <> NULL){
                    lot_note += oppcurrent.Junk_Vendor__r.description;
                }      
            }
            if(oppcurrent.Lot_Note__c!=null && oppcurrent.Lot_Note__c.trim()!=''){
                 lot_note += oppcurrent.Lot_Note__c;
            }
            if(lot_note!=null && lot_note.trim()!=''){
                (VehicleInfo.addChildElement('VehicleMemo',bmsNS, 'bms')).addTextNode(lot_note);
            }
            
            //After discussion with Don,its confirmed that we don't need to send below data for Assignment_Type__c=='Standard' CWH
            if(oppcurrent.RecordTypeId != Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('CarswithHeart Person Opportunity').getRecordTypeId() && oppcurrent.Assignment_Type__c=='Purchase'){
                Dom.Xmlnode ServicesInfo=bmsAdd.addChildElement('ServicesInfo',bmsNS, 'bms');
                Dom.Xmlnode VehicleServices=ServicesInfo.addChildElement('VehicleServices',bmsNS, 'bms');
                Dom.Xmlnode VehicleService=VehicleServices.addChildElement('VehicleService',bmsNS, 'bms');
                (VehicleService.addChildElement('ServiceRequestCode',bmsNS, 'bms')).addTextNode('MSC');
                (VehicleService.addChildElement('ServiceDesc',bmsNS, 'bms')).addTextNode('PUBLIC PURCHASE PAYMENT');
                Dom.Xmlnode ChargeInfo=VehicleService.addChildElement('ChargeInfo',bmsNS, 'bms');
                (ChargeInfo.addChildElement('ChargeAmt',bmsNS, 'bms')).addTextNode(string.valueof(oppcurrent.VPP_Offer_Amount__c));
                (ChargeInfo.addChildElement('ChargeMemo',bmsNS, 'bms')).addTextNode('MiscAdvancedCharge');
            } 
            if(oppcurrent.Type_of_Sale__c=='Minimum Bid'){
                Dom.Xmlnode AuctionInfo=bmsAdd.addChildElement('AuctionInfo',bmsNS, 'bms');
                (AuctionInfo.addChildElement('RunNum',bmsNS, 'bms')).addTextNode('1');
                (AuctionInfo.addChildElement('MinimumBidAmt',bmsNS, 'bms')).addTextNode(String.valueof(oppcurrent.Min_Bid_Price__c));
                (AuctionInfo.addChildElement('ApprovalRequiredInd',bmsNS, 'bms')).addTextNode('false');
            }else if(oppcurrent.Type_of_Sale__c=='BTBA'){
                Dom.Xmlnode AuctionInfo=bmsAdd.addChildElement('AuctionInfo',bmsNS, 'bms');
                (AuctionInfo.addChildElement('RunNum',bmsNS, 'bms')).addTextNode('1');
                (AuctionInfo.addChildElement('MinimumBidAmt',bmsNS, 'bms')).addTextNode('0.0');
                (AuctionInfo.addChildElement('ApprovalRequiredInd',bmsNS, 'bms')).addTextNode('true');
            }
            else{
                Dom.Xmlnode AuctionInfo=bmsAdd.addChildElement('AuctionInfo',bmsNS, 'bms');
                (AuctionInfo.addChildElement('RunNum',bmsNS, 'bms')).addTextNode('1');
                string minBidAmt='0.0';
                if(oppcurrent.Min_Bid_Price__c!=null){
                    minBidAmt=String.valueof(oppcurrent.Min_Bid_Price__c);
                }
                (AuctionInfo.addChildElement('MinimumBidAmt',bmsNS, 'bms')).addTextNode(minBidAmt);
                (AuctionInfo.addChildElement('ApprovalRequiredInd',bmsNS, 'bms')).addTextNode('false');
            }
            system.debug(xmlDoc.toxmlstring());
            string SoapXML=xmlDoc.toxmlstring();
            Integer ContentLength = 0;
            ContentLength = SoapXML.length();
            string ContentLen;
            ContentLen = ContentLength.format();
            String endpoint_x =globalConstants.APSSrvURL;
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            req.setMethod('POST');
            req.setEndPoint(endpoint_x); 
            audtLog.setUrl(req.getEndpoint());
           
           // saveLog(ApexPages.getMessages());
            req.setHeader('Content-type','Content-Type: application/soap+xml;charset=UTF-8;action="addAssignment"');
            req.setHeader('Content-Length',ContentLen);
            req.setHeader('SoapAction',endpoint_x);
            req.setTimeout(120000);
            req.setBody(SoapXML);
             audtLog.logRequestInfo(req.getBody());
            System.Debug('+++++req.getBody+++++'+req.getBody());
                 
            res = h.send(req);       
            System.Debug('+++++res:+++++++++'+res);        
            String ApsResponse = res.getBody();
            lstError.add(ApsResponse);
            audtLog.logResponseInfo(res.getBody()); 
            saveLog(lstError);
            return ApsResponse;
            audtLog.logStatusInfo(Label.Log_Success_Message);
        }catch(Exception ex){
            System.debug('Error In AddAssignment : ' + ex);
            system.debug(xmlDoc.toxmlstring());
            if(!System.isFuture())
            {
            //line 644,647 added and 648 updated param to fix Apexpages.message issue on 02-08-2018
                if(ApexPages.currentPage() != null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Error In AddAssignment : ' + ex));
            }
            lstError.add('Error In AddAssignment : ' + ex);
            saveLog(lstError);
            return null;
            //audtLog.logErrorMessage(fileNoImageWrapper.message);
            audtlog.logException(ex);
            audtLog.logStatusInfo(Label.Log_Failure_Message);
        }
        //line 656 updated param to fix Apexpages.message issue on 02-08-2018
        saveLog(lstError);
        return null;        
    } 
    
    //commented this method and used to replicate the same to fix ApexPages.message issue
    /*public static void saveLog(list<ApexPages.Message> pageMsgLst){
        if(audtlog <> null){
            if(pageMsgLst <> null && pageMsgLst.size()>0){
                String audtErrMsg = '';
                for(ApexPages.Message msg : pageMsgLst){
                    audtErrMsg += msg.getSummary() + '\n';
                }
                audtlog.logErrorMessage(audtErrMsg);
            }
            audtLog.saveLog();
        }
    }*/
    
    //commented above function and replicating the same by avoiding ApexPaGes.Message by Nutan on 02-08-2018
    public static void saveLog(list<String> pageMsgLst){
        if(audtlog <> null){
            if(pageMsgLst <> null && pageMsgLst.size()>0){
                String audtErrMsg = '';
                for(String msg : pageMsgLst){
                    audtErrMsg += msg + '\n';
                }
                audtlog.logErrorMessage(audtErrMsg);
            }
            audtLog.saveLog();
        }
    }
}