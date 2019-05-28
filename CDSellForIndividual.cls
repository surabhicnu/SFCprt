/****************************************************************************************
 * Name    : CDSellForIndividual 
 * Author  : Venkat
 * Date    : Oct 06, 2017 
 * Purpose : CDSellForIndividual - REST Class 
                HTTPPost :  createCDSellForIndividual - Create CopartDirect Person Lead.

 * ---------------------------------------------------------------------------
 * MODIFICATION HISTORY:
 * DATE             AUTHOR                              DESCRIPTION
 * ---------------------------------------------------------------------------
 * 10/06/2017       Venkat                               Created
 **/

@RestResource(urlMapping='/CDSellForIndividual/*')

global with sharing class CDSellForIndividual {
    public static final Id COPARTDIRECTPERSONLEADRTID = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(
                                    'CopartDirect Person Lead').getRecordTypeId();
    
    @HttpPost
    global static CDWrapper.CDCreateLeadResponse cdCreateLead(
                  CDWrapper.CDCreateLeadRequest cdCreateLeadReq){
        Boolean isException = false;
        Lead ld = new Lead (RecordTypeId = COPARTDIRECTPERSONLEADRTID);
        
        CDWrapper.CDCreateLeadResponse res = new CDWrapper.CDCreateLeadResponse();
        
        AuditLog audtLog = new AuditLog('CDSellForIndividual','cdCreateLead');
        audtLog.logSourceSystem('CDWebForm');

        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        mail.setToAddresses(Label.TPSELLER_OKTOPAYSTATUS_UPDATE_NOTIFICATION_EMAILADDRESSES.split(';'));
        mail.setSenderDisplayName('Salesforce Copart Persona Lead Error Email Notification');
        mail.setSubject(Label.TPSELLER_OKTOPAYSTATUS_UPDATE_NOTIFICATION_SUBJECT);
         
        String  exceptionEmailBody = '';
        if(cdCreateLeadReq <> null){
            audtLog.logRequestInfo(Json.serialize(cdCreateLeadReq));
        }
        
        String errorMessage = '';
        if(cdCreateLeadReq == null){
            errorMessage += Label.TPSELLER_OKTOPAYSTATUS_UPDATE_INVALID_REQUEST_ERRMSG + '\n';
            audtLog.logErrorMessage(errorMessage);
        }
        try{
        	ld.recordTypeId = (cdCreateLeadReq.recordTypeId <> null)?cdCreateLeadReq.recordTypeId : null;

            ld.Year__c       = cdCreateLeadReq.vehicleYear;
            ld.Make__c       = cdCreateLeadReq.vehicleMake;
            ld.Model__c      = cdCreateLeadReq.vehicleModel;
            ld.Veh_Miles__c  = (cdCreateLeadReq.approxMilesRun <> null)?cdCreateLeadReq.approxMilesRun : 0;
            ld.Lien__c       = cdCreateLeadReq.isLoaned;
            ld.FirstName     = cdCreateLeadReq.firstName;
            ld.LastName      = cdCreateLeadReq.lastName;
            ld.Phone         = cdCreateLeadReq.phoneNumber;
            ld.Email         = cdCreateLeadReq.eMailID;
            ld.PostalCode    = cdCreateLeadReq.zipPostalCode;
            ld.Referring_Employee_ID__c = cdCreateLeadReq.referralCode;

            insert ld;

            res.leadid = ld.id;
            res.status= 'Success';
        }
        catch(Exception e){
            res.status='Failure';
            res.errorMessage = 'Exception occured when processing Lead : ' + e.getMessage();
            isException = true;
        }

        audtLog.logResponseInfo(Json.serialize(res));
        audtLog.logStatusInfo(res.status);
        Audit_Logs__c auditLog = audtLog.saveLog();
        
        if(isException){
            exceptionEmailBody += '<br/><br/> AuditLog <a target="_blank" href="'+ URL.getSalesforceBaseUrl().toExternalForm() + '/' + auditLog.id +'">Link</a>';
            mail.setHTMLBody(exceptionEmailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });           
        }

        return res;
    }
}