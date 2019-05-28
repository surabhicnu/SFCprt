public class B2BLVTIntegrationHelper {
    public static final     String              LVT_TOKEN_STR               = 'B2BOAUTHToken';
    public static final     String              LVT_UPDATE_STR              = 'B2BLVTUpdate';

    public static           list<Audit_Logs__c> audtLogsLst                 = new list<Audit_Logs__c>();
    public static           string              lvtOpporRecordId             = '';
    
    public static           String              accessToken                 = null;
    public static           String              tokenType                   = null;

    @Future (callout=true)
    public static void lvtUpdate(set<Id> opporIdSet){
        set<String> NPOSet = new set<String>();
        NPOSet.addall(Label.Non_Profit_Organization.split(';'));
        map<id, Opportunity> updtOpporMap = new map<id, Opportunity>();
        list<Opportunity> opporLst = [Select id, name, lot_Number__c,Junk_Vendor__r.Seller_Code__c,
                                Buy_Type__c,RecordTypeId,Junk_Vendor__r.LVT_Member_id__c,LVT_Review_Comments__c,
                                Junk_Vendor__r.LVT_Buyer_Id__c, Account.name,Account.Seller_Code__c, Account.Junk_Seller_Code__c,
                                Junk_Vendor__r.name, Junk_Vendor__r.LVT_Price__c, Junk_Vendor__r.LVT_Sale_Price__c,
                                Junk_Vendor__r.email_2__c,Junk_Vendor__r.Fax, Lot_Note__c,
                                Junk_Vendor__r.LVT_Delivery_Fee__c,Junk_Vendor__r.description
                                from opportunity where id in :opporIdSet];
        for(Opportunity oppor : opporLst){
            AuditLog audtLog    = new AuditLog('B2BLVTIntegrationHelper','lvtUpdate');
            audtLog.logSourceSystem('LVT');
            audtLog.logRecordId(oppor.id);            
            try{

            lvtOpporRecordId    =   oppor.id;
                        
            /* START of CREATING LVTUpdate REQUEST */
            LVTProcessWrapper.LVTProcessUpdateRequest lvtUpdateReq = new LVTProcessWrapper.LVTProcessUpdateRequest();
            lvtUpdateReq.lotNumber      = oppor.lot_Number__c;
            lvtUpdateReq.sellerIdAfter  = (oppor.Buy_Type__c == 'Junk' && oppor.Account.Junk_Seller_Code__c <> null)?oppor.Account.Junk_Seller_Code__c:null;
            if(oppor.Buy_Type__c == 'Junk'){
                lvtUpdateReq.sellerRefTxt   = (oppor.Junk_Vendor__r.LVT_Member_id__c==null?'':oppor.Junk_Vendor__r.LVT_Member_id__c)+'-'+(oppor.Junk_Vendor__r.LVT_Buyer_Id__c==null?'':oppor.Junk_Vendor__r.LVT_Buyer_Id__c);
            }
            lvtUpdateReq.releaseHold = (oppor.Buy_Type__c=='Auction')?'Y':null;
            lvtUpdateReq.comments       = 'BuyType:'+oppor.Buy_Type__c+(oppor.LVT_Review_Comments__c==null?'':'|'+oppor.LVT_Review_Comments__c);
            lvtUpdateReq.notes          = null;
                if(oppor.RecordTypeId == Schema.SObjectType.opportunity.getRecordTypeInfosByName().get('LVT B2B Donation Opportunity').getRecordTypeId() && 
                   oppor.Buy_Type__c=='Junk'){
                    if(oppor.Junk_Vendor__r.name != NULL && 
                       oppor.Junk_Vendor__r.name.trim()!= '' && 
                       oppor.Junk_Vendor__r.LVT_Buyer_Id__c != NULL && 
                     oppor.Junk_Vendor__r.LVT_Member_Id__c != NULL && 
                       oppor.Junk_Vendor__r.LVT_Price__c != NULL && oppor.Junk_Vendor__r.LVT_Sale_Price__c <> NULL &&
                     oppor.Junk_Vendor__r.LVT_Delivery_Fee__c != NULL
                    ){
                     lvtUpdateReq.notes = '';
                        lvtUpdateReq.notes += 'THIS IS A LVT ASSIGNMENT.**DO NOT ASSIGN TO A LIVE AUCTION** THIS LOT SHOULD BE DISPATCHED TO THE SUBLOT "'+oppor.Junk_Vendor__r.LVT_Buyer_Id__c+
                                  '", THEN AWARDED VIA SPECIAL SALE TO MEMBER NUMBER "'+oppor.Junk_Vendor__r.LVT_Member_Id__c+'" FOR $'+oppor.Junk_Vendor__r.LVT_Sale_Price__c+
                                  '. A DELIVERY FEE OF $'+oppor.Junk_Vendor__r.LVT_Delivery_Fee__c+' MUST BE ADDED TO THE LOT AFTER IT HAS BEEN AWARDED TO THE LVT VENDOR NUMBER ABOVE. ';
                        String additionalText = '';
                        if(oppor.Junk_Vendor__r.email_2__c <> NULL)
                            lvtUpdateReq.notes += 'Email - '+ oppor.Junk_Vendor__r.email_2__c;
                        if(oppor.Junk_Vendor__r.Fax <> NULL)
                            lvtUpdateReq.notes += ' Fax - '+ oppor.Junk_Vendor__r.Fax +' ';
                    }
                    //Added by Abhinav on 11/03/2016, we are sending LVT Junk Vendor Account's description as lot notes to CAS
                    if(oppor.Junk_Vendor__r.description <> NULL){
                        lvtUpdateReq.notes = ((lvtUpdateReq.notes == null)?'':lvtUpdateReq.notes)+' ' + oppor.Junk_Vendor__r.description;
                    }      
                }
                if(oppor.Lot_Note__c!=null && oppor.Lot_Note__c.trim()!=''){
                     lvtUpdateReq.notes =  ((lvtUpdateReq.notes == null)?'':lvtUpdateReq.notes)+ ' ' + oppor.Lot_Note__c;
                }
                system.debug('lvtUpdateReq.notes :' +lvtUpdateReq.notes);
                String jsonStr = Json.serialize(lvtUpdateReq, true);
                if(jsonStr <> null){
                    // Setting log RequestInfo
                    audtLog.logRequestInfo(jsonStr);
                    audtLog.setUrl(Integration_Settings__c.getInstance(LVT_UPDATE_STR).EndPoint__c);
                    
                    System.debug('jsonStr : ' + jsonStr);   
                    String strResp = sendRequest(LVT_UPDATE_STR, jsonStr);
                    System.debug('LVTUpdate Response: ' + strResp);
                    LVTProcessWrapper.LVTProcessUpdateResponse  tokenResp    =   (LVTProcessWrapper.LVTProcessUpdateResponse)JSON.deserialize(strResp ,
                                                        LVTProcessWrapper.LVTProcessUpdateResponse.class);      
                    // Setting log Response, saving 
                    audtLog.logResponseInfo(strResp);  
                    String logStatus = tokenResp.status;
                        
                    audtLog.logStatusInfo(logStatus);
                    audtLog.logErrorMessage(tokenResp.error);
                    
                    oppor.LVTService_Status__c       = logStatus;
                    oppor.LVTService_Error_Message__c = tokenResp.error;
                }
                audtLogsLst.add(audtLog.returnLog());
            }
            catch(Exception e){
                audtLog.logStatusInfo(Label.Log_Failure_Message);
                audtLog.logException(e);
                oppor.LVTService_Status__c       = Label.Log_Failure_Message;
                oppor.LVTService_Error_Message__c = e.getMessage();             
                audtLogsLst.add(audtLog.returnLog());
            }
            oppor.StageName = (oppor.LVTService_Status__c == 'Success')?'Assignment':'WAITING FOR TRIP CONFIRMATION';
            updtOpporMap.put(oppor.id, oppor);
            /* END of CREATING LVTUpdate REQUEST */
        }
        if(audtLogsLst <> null && audtLogsLst.size()>0){
            insert audtLogsLst;
        }
        if(updtOpporMap<> null && 
            updtOpporMap.size()>0){
            TriggerHandler.byPass('OpportunityEventsHandler');
            update updtOpporMap.values();
            TriggerHandler.clearAllBypasses();
            
        }
    }
    
    
    /* InitialOffer service to retrieve offerId */
    public static void retrieveAccessToken(){

        System.debug('*********** START retrieveAccessToken ************');
        // Initializing Log

        AuditLog audtLog    = new AuditLog('B2BLVTIntegrationHelper','retrieveAccessToken');
        audtLog.logSourceSystem('LVT');
        audtLog.logRecordId(lvtOpporRecordId);

        try{
            String body =   '';

            system.debug('retrieveAccessToken Request : ' + body);

            // Setting log RequestInfo
            audtLog.logRequestInfo(body);
            audtLog.setUrl(Integration_Settings__c.getInstance(LVT_TOKEN_STR).EndPoint__c);

            // Sending Httprequest to RMC
            String response = sendRequest(LVT_TOKEN_STR, body);
            System.debug('retrieveAccessToken HttpResponse : ' + response);

            // Setting log Response, saving 
            audtLog.logResponseInfo(response);
            
            if(response <> null){
                // Assigning httpResponse string to responseWrapper object
                LVTProcessWrapper.LVTProcessTokenResponse  tokenResp    =   (LVTProcessWrapper.LVTProcessTokenResponse)JSON.deserialize(response ,
                                                        LVTProcessWrapper.LVTProcessTokenResponse.class);

                accessToken = tokenResp.access_token;
                tokenType   = tokenResp.token_type;
                
                system.debug('retrieveAccessToken TokenResponse : ' + tokenResp);
                system.debug('retrieveAccessToken accessToken :' + accessToken);
                system.debug('retrieveAccessToken tokenType   :' + tokenType); 
                
                String logStatus = (tokenResp.message == null || tokenResp.message == '')?
                                    Label.Log_Success_Message:Label.Log_Failure_Message;
                    
                audtLog.logStatusInfo(logStatus);
                audtLog.logErrorMessage(tokenResp.message);
            }
            audtLogsLst.add(audtLog.returnLog());
        }
        catch(Exception e){
            audtLog.logStatusInfo(Label.Log_Failure_Message);
            audtLog.logException(e);
            audtLogsLst.add(audtLog.returnLog());
            throw new IllegalStateException(e.getMessage());
        }
        //audtLogsLst.add(audtLog.returnLog());
        system.debug('retrieveAccessToken audtLogsLst : ' + audtLogsLst);
        System.debug('*********** END retrieveAccessToken ************');
    }
    
    /*
        Logic to Send HTTP Request and Return Response.
        sendRequest(RequestBody, ServiceType eg: LVT Token,LVTUpdate)
    */
    public static  String  sendRequest(String serviceType, String body){

        System.debug('sendRequest ServiceType :' + serviceType);
        System.debug('sendRequest Body        :' + body);
        
        // Retrieve CustomSetting values for ServiceType
        Integration_Settings__c lvtIntSettings = Integration_Settings__c.getInstance(serviceType);

        //Setting the HTTP Request values based on CustomSettings ServiceType
        if(lvtIntSettings <> null){
            /* START Setting HTTP Request Values */
            HttpRequest httpReq = new HttpRequest();

            httpReq.setTimeout(lvtIntSettings.Timeout__c.intValue());
            httpReq.setMethod(lvtIntSettings.MethodType__c);
            httpReq.setEndpoint(lvtIntSettings.Endpoint__c);

            if(lvtIntSettings.ContentType__c <> null)
                httpReq.setHeader('Content-Type', lvtIntSettings.ContentType__c);
            
            if(lvtIntSettings.Authorization_Required__c && 
                accessToken == null  && 
                tokenType == null){
                retrieveAccessToken();
            }
            if(serviceType == 'B2BOAUTHToken'){
                    //Blob headerValue = Blob.valueOf(lvtIntSettings.accessToken__c +':' +lvtIntSettings.TokenSecret__c );
                    //String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    httpReq.setHeader('Authorization', 'Basic ' + lvtIntSettings.TokenSecret__c);
            }else if(accessToken <> null && tokenType <> null){
                    httpReq.setHeader('Authorization',tokenType +' '+accessToken);
            }                 
            
                if(body <> null)        
                    httpReq.setBody(body);
                /* END Setting HTTP Request Values */

                system.debug('SendRequest  httpRequest : ' + httpReq);
                Http            http        = new Http();
                HttpResponse    httpRes     = http.send(httpReq);

                system.debug('SendRequest  httpResponse : ' + httpRes);
                system.debug('SendRequest  httpResponse Body : ' + httpRes.getBody());

                //Returning Response Body
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 400){
                    return httpRes.getBody();
                }
                else{
                    throw new IllegalStateException('Exception Occurred when processing Sending LVT Update with http StatusCode : ' + httpRes.getStatusCode() + 'Http Body : ' + httpRes.getBody()); 
                }
            }
        return null;
    }    
}